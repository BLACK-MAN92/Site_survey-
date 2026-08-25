import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

/// Result of preparing a captured photo for upload.
class PreparedPhoto {
  final File file;
  final int originalBytes;
  final int bytes;
  final int width;
  final int height;

  PreparedPhoto({
    required this.file,
    required this.originalBytes,
    required this.bytes,
    required this.width,
    required this.height,
  });
}

/// Raised when a photo cannot be brought under the upload ceiling.
class ImageProcessingException implements Exception {
  final String message;
  ImageProcessingException(this.message);

  @override
  String toString() => message;
}

/// Prepares captured photos for upload.
///
/// The backend compresses again to a 5MB storage ceiling, but it can only do
/// that to images that actually arrive. The API is hosted on Vercel, which
/// rejects request bodies over 4.5MB at the edge — before any application code
/// runs — so an unshrunk 8MB phone photo fails with an opaque platform 413.
/// Shrinking here is what makes the upload possible at all.
class ImageService {
  /// Upload ceiling. Deliberately below both the platform's 4.5MB edge limit
  /// and the API's own multer limit, leaving room for the multipart envelope.
  static const int maxUploadBytes = 3 * 1024 * 1024;

  /// Longest edge kept. Matches the backend's own cap, so re-encoding there is
  /// a no-op rather than a second round of quality loss.
  static const int maxEdgePx = 2560;

  /// Quality steps tried in order until the file fits under the ceiling.
  static const List<int> qualityLadder = [85, 75, 65, 55, 45, 35];

  /// Compresses [imagePath], stamping it with the site, time and GPS fix.
  ///
  /// The watermark is burnt into the pixels rather than left in EXIF because
  /// the backend strips metadata during its own re-encode, and because a
  /// visible stamp is what makes the photo usable as evidence in a report.
  Future<PreparedPhoto> prepareForUpload({
    required String imagePath,
    required String siteId,
    double? lat,
    double? lng,
  }) async {
    final original = File(imagePath);
    if (!original.existsSync()) {
      throw ImageProcessingException('The captured photo could not be found.');
    }

    final originalBytes = await original.length();
    final bytes = await original.readAsBytes();

    var decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw ImageProcessingException('The captured photo could not be read.');
    }

    // Phone cameras record orientation in EXIF rather than rotating pixels.
    // Baking it in now keeps the watermark upright and stops the photo being
    // stored sideways once metadata is dropped.
    decoded = img.bakeOrientation(decoded);

    if (decoded.width > maxEdgePx || decoded.height > maxEdgePx) {
      decoded = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: maxEdgePx)
          : img.copyResize(decoded, height: maxEdgePx);
    }

    _stamp(decoded, siteId: siteId, lat: lat, lng: lng);

    final dir = original.parent.path;
    final stem = p.basenameWithoutExtension(imagePath);
    final stampedPath = p.join(dir, '${stem}_stamped.jpg');
    final stamped = File(stampedPath);
    await stamped.writeAsBytes(img.encodeJpg(decoded, quality: 95));

    try {
      final outPath = p.join(dir, '${stem}_upload.jpg');

      // A fixed quality cannot promise a size — the same setting produces
      // wildly different files depending on the scene — so each attempt is
      // measured and the ladder walked until one fits.
      for (final quality in qualityLadder) {
        final result = await FlutterImageCompress.compressAndGetFile(
          stamped.absolute.path,
          outPath,
          quality: quality,
          keepExif: false,
        );

        if (result == null) continue;

        final out = File(result.path);
        final outBytes = await out.length();
        if (outBytes <= maxUploadBytes) {
          return PreparedPhoto(
            file: out,
            originalBytes: originalBytes,
            bytes: outBytes,
            width: decoded.width,
            height: decoded.height,
          );
        }
      }

      throw ImageProcessingException(
        'This photo could not be compressed below '
        '${(maxUploadBytes / 1024 / 1024).toStringAsFixed(0)}MB. '
        'Try again from further back or with less detail in frame.',
      );
    } finally {
      // The intermediate is large and lives in the cache directory; leaving one
      // behind per photo fills the device over a day of surveying.
      if (await stamped.exists()) {
        await stamped.delete();
      }
    }
  }

  void _stamp(
    img.Image image, {
    required String siteId,
    double? lat,
    double? lng,
  }) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final fix = (lat != null && lng != null)
        ? 'Lat ${lat.toStringAsFixed(5)}, Lng ${lng.toStringAsFixed(5)}'
        : 'GPS unavailable';
    final lines = ['Site: $siteId', timestamp, fix];

    const pad = 12;
    final font = image.width > 1400 ? img.arial24 : img.arial14;
    final lineHeight = font.lineHeight;
    final boxHeight = lineHeight * lines.length + pad * 2;

    // Dark plate behind the text: white-on-white is unreadable against a
    // bright sky or a concrete base, which is most of what gets photographed.
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - boxHeight,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(0, 0, 0, 140),
    );

    for (var i = 0; i < lines.length; i++) {
      img.drawString(
        image,
        lines[i],
        font: font,
        x: pad,
        y: image.height - boxHeight + pad + (i * lineHeight),
        color: img.ColorRgb8(255, 255, 255),
      );
    }
  }
}

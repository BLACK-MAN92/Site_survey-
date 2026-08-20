import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class ImageService {
  Future<File?> processAndWatermarkPhoto({
    required String imagePath,
    required String siteId,
    required double lat,
    required double lng,
  }) async {
    final originalFile = File(imagePath);
    if (!originalFile.existsSync()) return null;

    // 1. Read image to memory
    final bytes = await originalFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return null;

    // 2. Resize to <= 1920px on the long edge
    if (decodedImage.width > 1920 || decodedImage.height > 1920) {
      if (decodedImage.width > decodedImage.height) {
        decodedImage = img.copyResize(decodedImage, width: 1920);
      } else {
        decodedImage = img.copyResize(decodedImage, height: 1920);
      }
    }

    // 3. Apply Watermark
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final watermarkText = 'Site: $siteId\n$timestamp\nLat: $lat, Lng: $lng';
    
    img.drawString(
      decodedImage,
      watermarkText,
      font: img.arial24,
      x: 10,
      y: 10,
      color: img.ColorRgb8(255, 255, 255), // White text
    );

    // Write the watermarked image back to a temporary path
    final watermarkedPath = '${imagePath}_watermarked.jpg';
    final watermarkedFile = File(watermarkedPath);
    await watermarkedFile.writeAsBytes(img.encodeJpg(decodedImage, quality: 100));

    // 4. Compress the image to target <= 500KB and quality 80
    final compressedPath = '${imagePath}_compressed.jpg';
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      watermarkedFile.absolute.path,
      compressedPath,
      quality: 80,
    );

    return compressedFile != null ? File(compressedFile.path) : null;
  }
}

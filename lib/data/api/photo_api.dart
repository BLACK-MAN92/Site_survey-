import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import 'api_client.dart';

final photoApiProvider = Provider<PhotoApi>((ref) {
  return PhotoApi(ref.watch(dioProvider));
});

/// A stored photo, as the survey document needs it.
///
/// `publicId` and `url` are the two fields the API's photo subdocument requires;
/// the rest is kept so the dashboard can lay images out without downloading
/// them first, and so compression stays auditable.
class UploadedPhoto {
  final String publicId;
  final String url;
  final String category;
  final String? workItemKey;
  final int? width;
  final int? height;
  final int? bytes;
  final int? originalBytes;
  final String? format;

  UploadedPhoto({
    required this.publicId,
    required this.url,
    required this.category,
    this.workItemKey,
    this.width,
    this.height,
    this.bytes,
    this.originalBytes,
    this.format,
  });

  factory UploadedPhoto.fromJson(Map<String, dynamic> json) {
    return UploadedPhoto(
      publicId: json['public_id'] as String,
      url: json['url'] as String,
      category: json['category'] as String,
      workItemKey: json['workItemKey'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      bytes: json['bytes'] as int?,
      originalBytes: json['originalBytes'] as int?,
      format: json['format'] as String?,
    );
  }

  /// Shape accepted by `POST /surveys/:id/photos`.
  Map<String, dynamic> toAttachmentJson() => {
        'public_id': publicId,
        'url': url,
        'category': category,
        if (workItemKey != null) 'workItemKey': workItemKey,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (bytes != null) 'bytes': bytes,
        if (originalBytes != null) 'originalBytes': originalBytes,
        if (format != null) 'format': format,
      };
}

class PhotoUploadException implements Exception {
  final String message;
  PhotoUploadException(this.message);

  @override
  String toString() => message;
}

class PhotoApi {
  final Dio _dio;

  PhotoApi(this._dio);

  /// Uploads one already-compressed photo. The server compresses again to its
  /// own 5MB storage ceiling and returns the Cloudinary record to persist.
  Future<UploadedPhoto> uploadPhoto({
    required File file,
    required String siteId,
    required String surveyUuid,
    required String category,
    String? workItemKey,
  }) async {
    final formData = FormData.fromMap({
      'siteId': siteId,
      'surveyUuid': surveyUuid,
      'category': category,
      if (workItemKey != null) 'workItemKey': workItemKey,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    try {
      final response = await _dio.post(
        '/uploads/photo',
        data: formData,
        options: Options(
          // The Dio instance sets application/json for every request. Left in
          // place, multer sees a JSON content type wrapping a multipart body,
          // parses no file, and the request fails as FILE_REQUIRED.
          contentType: 'multipart/form-data',
          // Photo uploads are far slower than a JSON call on a field data
          // connection; the 15s default aborts uploads that would have landed.
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      final data = response.data['data'];
      if (data is! Map) {
        throw PhotoUploadException('The server did not return a stored photo.');
      }
      return UploadedPhoto.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw PhotoUploadException(_describe(e));
    }
  }

  String _describe(DioException e) {
    final status = e.response?.statusCode;

    if (e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'The upload timed out. Check your signal and retry — '
          'the photo is saved on the device.';
    }

    if (status == 413) {
      return 'The photo is too large to upload. Retake it at a lower '
          'resolution.';
    }
    if (status == 401) {
      return 'Your session expired during the upload. Sign in and retry.';
    }
    if (status == 403) {
      return 'Your account is not permitted to upload survey photos.';
    }
    if (status == 429) {
      return 'Too many uploads at once. Wait a moment and retry.';
    }

    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
    }

    if (status != null) {
      return 'The server rejected the upload ($status).';
    }
    return 'Could not reach the server to upload the photo. '
        'The photo is saved on the device — retry when you have signal.';
  }
}

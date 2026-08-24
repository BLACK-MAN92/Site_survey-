import '../../data/api/photo_api.dart';

/// Where a captured photo is in the capture → compress → upload pipeline.
enum PhotoUploadStatus { pending, uploading, uploaded, failed }

/// A photo taken during a survey, tracked from the shutter to Cloudinary.
///
/// The local path is kept even after a successful upload so the post-survey
/// ghost overlay has something to draw, and so a failed submission can be
/// retried without asking the engineer to walk the site again.
class CapturedPhoto {
  final String localPath;
  final String category;
  final String? workItemKey;
  final PhotoUploadStatus status;
  final UploadedPhoto? uploaded;
  final String? error;

  const CapturedPhoto({
    required this.localPath,
    required this.category,
    this.workItemKey,
    this.status = PhotoUploadStatus.pending,
    this.uploaded,
    this.error,
  });

  bool get isUploaded => status == PhotoUploadStatus.uploaded && uploaded != null;

  CapturedPhoto copyWith({
    PhotoUploadStatus? status,
    UploadedPhoto? uploaded,
    String? error,
    bool clearError = false,
  }) {
    return CapturedPhoto(
      localPath: localPath,
      category: category,
      workItemKey: workItemKey,
      status: status ?? this.status,
      uploaded: uploaded ?? this.uploaded,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

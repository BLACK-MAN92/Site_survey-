import 'dart:io';

import 'package:flutter/material.dart';

import '../../providers/captured_photo.dart';

/// Thumbnails of captured photos with their upload state.
///
/// The state badge matters: the survey document stores Cloudinary links, so a
/// photo that never uploaded is not evidence. Previously the grid showed a
/// generic icon per photo, which looked identical whether the upload had
/// succeeded, failed or never started.
class PhotoGrid extends StatelessWidget {
  final List<CapturedPhoto> photos;
  final void Function(String localPath) onRetry;
  final void Function(String localPath) onRemove;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onRetry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No photos yet. Tap Open Camera to start.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: photos.map((p) => _Thumb(photo: p, onRemove: onRemove)).toList(),
        ),
        ...photos.where((p) => p.status == PhotoUploadStatus.failed).map(
              (p) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.error ?? 'Upload failed.',
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onRetry(p.localPath),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final CapturedPhoto photo;
  final void Function(String localPath) onRemove;

  const _Thumb({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(photo.localPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Positioned(bottom: 2, left: 2, child: _badge()),
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              iconSize: 18,
              icon: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
              onPressed: () => onRemove(photo.localPath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge() {
    late final IconData icon;
    late final Color colour;
    late final String label;

    switch (photo.status) {
      case PhotoUploadStatus.pending:
        icon = Icons.schedule;
        colour = Colors.grey;
        label = 'Queued';
        break;
      case PhotoUploadStatus.uploading:
        icon = Icons.cloud_upload;
        colour = Colors.blue;
        label = 'Uploading';
        break;
      case PhotoUploadStatus.uploaded:
        icon = Icons.cloud_done;
        colour = Colors.green;
        label = 'Stored';
        break;
      case PhotoUploadStatus.failed:
        icon = Icons.error;
        colour = Colors.red;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(fontSize: 9, color: Colors.white)),
        ],
      ),
    );
  }
}

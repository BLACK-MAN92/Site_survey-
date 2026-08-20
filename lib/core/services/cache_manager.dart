import 'dart:io';

class CacheManager {
  final String cacheDirectoryPath;
  static const int retentionDays = 7;
  static const int maxCacheSizeBytes = 2 * 1024 * 1024 * 1024; // 2GB

  CacheManager({required this.cacheDirectoryPath});

  Future<void> evictOldPhotos() async {
    final dir = Directory(cacheDirectoryPath);
    if (!dir.existsSync()) return;

    final cutoffDate = DateTime.now().subtract(const Duration(days: retentionDays));
    int currentSizeBytes = 0;
    
    // Get all files and their metadata
    final List<File> allFiles = [];
    final List<FileStat> fileStats = [];

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final stat = await entity.stat();
        allFiles.add(entity);
        fileStats.add(stat);
        currentSizeBytes += stat.size;
      }
    }

    // Sort by modified time (oldest first)
    final fileIndices = List.generate(allFiles.length, (i) => i);
    fileIndices.sort((a, b) => fileStats[a].modified.compareTo(fileStats[b].modified));

    // Phase 1: Evict > 7 days old
    for (int i in fileIndices) {
      if (fileStats[i].modified.isBefore(cutoffDate)) {
        await _deleteFile(allFiles[i]);
        currentSizeBytes -= fileStats[i].size;
      }
    }

    // Phase 2: Evict oldest if still over 2GB cap
    for (int i in fileIndices) {
      if (currentSizeBytes <= maxCacheSizeBytes) break;
      if (allFiles[i].existsSync()) {
        await _deleteFile(allFiles[i]);
        currentSizeBytes -= fileStats[i].size;
      }
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to delete file: ${file.path}');
    }
  }
}

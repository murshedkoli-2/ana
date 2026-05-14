import 'package:hive/hive.dart';
import '../models/video.dart';

class VideoCacheService {
  static const String _videoCacheBox = 'video_cache';
  static const String _syncTimeKey = 'sync_time';

  late Box<dynamic> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox(_videoCacheBox);
  }

  // Save videos to cache
  Future<void> cacheVideos(List<Video> videos) async {
    final videoData = videos.map((v) => v.toJson()).toList();
    await _cacheBox.put('videos', videoData);
    await _cacheBox.put(_syncTimeKey, DateTime.now().toIso8601String());
  }

  // Save a single video to cache
  Future<void> cacheVideo(Video video) async {
    final videos = getCachedVideos();
    final index = videos.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      videos[index] = video;
    } else {
      videos.add(video);
    }
    await _cacheBox.put('videos', videos.map((v) => v.toJson()).toList());
  }

  // Delete a video from cache
  Future<void> deleteVideoFromCache(String videoId) async {
    final videos = getCachedVideos();
    videos.removeWhere((v) => v.id == videoId);
    await _cacheBox.put('videos', videos.map((v) => v.toJson()).toList());
  }

  // Get all cached videos
  List<Video> getCachedVideos() {
    final cachedData = _cacheBox.get('videos');
    if (cachedData == null) {
      return [];
    }

    try {
      final videoList = (cachedData as List).cast<Map<dynamic, dynamic>>();
      return videoList
          .map((video) => Video.fromJson(Map<String, dynamic>.from(video)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get cached video by ID
  Video? getCachedVideoById(String videoId) {
    final videos = getCachedVideos();
    try {
      return videos.firstWhere((v) => v.id == videoId);
    } catch (e) {
      return null;
    }
  }

  // Get last sync time
  DateTime? getLastSyncTime() {
    final syncTime = _cacheBox.get(_syncTimeKey);
    if (syncTime != null) {
      return DateTime.tryParse(syncTime);
    }
    return null;
  }

  // Clear all cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Close cache
  Future<void> close() async {
    await _cacheBox.close();
  }
}

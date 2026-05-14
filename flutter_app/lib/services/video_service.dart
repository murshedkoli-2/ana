import 'package:flutter/foundation.dart';
import '../models/video.dart';
import 'api_client.dart';

class VideoService extends ChangeNotifier {
  final ApiClient _apiClient;

  List<Video> _videos = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Video> get videos => _filteredVideos;
  List<Video> get _filteredVideos {
    if (_searchQuery.isEmpty) return _videos;
    return _videos
        .where((v) =>
            v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.url.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Stats
  int get totalCount => _videos.length;
  int get selectedCount =>
      _videos.where((v) => v.status == 'selected').length;
  int get createdCount => _videos.where((v) => v.status == 'created').length;
  int get publishedCount =>
      _videos.where((v) => v.status == 'published').length;

  VideoService(this._apiClient);

  // Fetch all videos
  Future<void> fetchVideos({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _apiClient.getVideos(status: status);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch filtered videos by status
  Future<List<Video>> fetchVideosByStatus(String status) async {
    try {
      return await _apiClient.getVideos(status: status);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Create video
  Future<Video> createVideo(String title, String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newVideo = await _apiClient.createVideo(title, url);
      _videos.add(newVideo);
      _isLoading = false;
      notifyListeners();
      return newVideo;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update video status
  Future<void> updateVideoStatus(String videoId, String newStatus) async {
    try {
      final updatedVideo = await _apiClient.updateVideoStatus(videoId, newStatus);
      final index = _videos.indexWhere((v) => v.id == videoId);
      if (index != -1) {
        _videos[index] = updatedVideo;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Delete video
  Future<void> deleteVideo(String videoId) async {
    try {
      await _apiClient.deleteVideo(videoId);
      _videos.removeWhere((v) => v.id == videoId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Search videos
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Get single video
  Video? getVideoById(String id) {
    try {
      return _videos.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'package:uuid/uuid.dart';
import '../models/video.dart';
import 'database_service.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message${code != null ? ' ($code)' : ''}';
}

class ApiClient {
  final DatabaseService _db = DatabaseService();
  static const String baseUrl = 'Neon PostgreSQL (Direct)';

  ApiClient({String? baseUrl});

  /// Get all videos, optionally filtered by status
  Future<List<Video>> getVideos({String? status}) async {
    try {
      final String sql;
      final List<Object?> params;

      if (status != null) {
        sql = '''
          SELECT id, title, url, status, created_at as createdAt, updated_at as updatedAt
          FROM videos
          WHERE status = @status
          ORDER BY created_at ASC
        ''';
        params = [status];
      } else {
        sql = '''
          SELECT id, title, url, status, created_at as createdAt, updated_at as updatedAt
          FROM videos
          ORDER BY created_at ASC
        ''';
        params = [];
      }

      final results = await _db.query(sql, params);
      return results.map((row) {
        return Video(
          id: row['id'] as String,
          title: row['title'] as String,
          url: row['url'] as String,
          status: row['status'] as String,
          createdAt: DateTime.parse(row['createdAt'].toString()),
          updatedAt: DateTime.parse(row['updatedAt'].toString()),
        );
      }).toList();
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch videos: $e',
        code: 'FETCH_ERROR',
        originalError: e,
      );
    }
  }

  /// Get a single video by ID
  Future<Video?> getVideo(String videoId) async {
    try {
      final sql = '''
        SELECT id, title, url, status, created_at as createdAt, updated_at as updatedAt
        FROM videos
        WHERE id = @id
        LIMIT 1
      ''';

      final result = await _db.querySingle(sql, [videoId]);
      if (result == null) return null;

      return Video(
        id: result['id'] as String,
        title: result['title'] as String,
        url: result['url'] as String,
        status: result['status'] as String,
        createdAt: DateTime.parse(result['createdAt'].toString()),
        updatedAt: DateTime.parse(result['updatedAt'].toString()),
      );
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch video: $e',
        code: 'FETCH_ERROR',
        originalError: e,
      );
    }
  }

  /// Create a new video
  Future<Video> createVideo(String title, String url) async {
    try {
      // Validate inputs
      final trimmedTitle = title.trim();
      final trimmedUrl = url.trim();

      if (trimmedTitle.isEmpty) {
        throw ApiException(
          message: 'Title cannot be empty',
          code: 'INVALID_TITLE',
        );
      }

      if (trimmedUrl.isEmpty) {
        throw ApiException(
          message: 'URL cannot be empty',
          code: 'INVALID_URL',
        );
      }

      if (!_isValidUrl(trimmedUrl)) {
        throw ApiException(
          message: 'Invalid URL format',
          code: 'INVALID_URL_FORMAT',
        );
      }

      final id = const Uuid().v4();
      final now = DateTime.now();

      final sql = '''
        INSERT INTO videos (id, title, url, status, created_at, updated_at)
        VALUES (@id, @title, @url, @status, @createdAt, @updatedAt)
        RETURNING id, title, url, status, created_at as createdAt, updated_at as updatedAt
      ''';

      final result = await _db.querySingle(sql, [
        id,
        trimmedTitle,
        trimmedUrl,
        'selected',
        now.toIso8601String(),
        now.toIso8601String(),
      ]);

      if (result == null) {
        throw ApiException(
          message: 'Failed to create video',
          code: 'CREATE_ERROR',
        );
      }

      return Video(
        id: result['id'] as String,
        title: result['title'] as String,
        url: result['url'] as String,
        status: result['status'] as String,
        createdAt: DateTime.parse(result['createdAt'].toString()),
        updatedAt: DateTime.parse(result['updatedAt'].toString()),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create video: $e',
        code: 'CREATE_ERROR',
        originalError: e,
      );
    }
  }

  /// Update video status
  Future<Video> updateVideoStatus(String videoId, String newStatus) async {
    try {
      // Validate status
      const validStatuses = ['selected', 'created', 'published'];
      if (!validStatuses.contains(newStatus)) {
        throw ApiException(
          message: 'Invalid status: $newStatus',
          code: 'INVALID_STATUS',
        );
      }

      final sql = '''
        UPDATE videos
        SET status = @status, updated_at = @updatedAt
        WHERE id = @id
        RETURNING id, title, url, status, created_at as createdAt, updated_at as updatedAt
      ''';

      final result = await _db.querySingle(sql, [
        newStatus,
        DateTime.now().toIso8601String(),
        videoId,
      ]);

      if (result == null) {
        throw ApiException(
          message: 'Video not found',
          code: 'NOT_FOUND',
        );
      }

      return Video(
        id: result['id'] as String,
        title: result['title'] as String,
        url: result['url'] as String,
        status: result['status'] as String,
        createdAt: DateTime.parse(result['createdAt'].toString()),
        updatedAt: DateTime.parse(result['updatedAt'].toString()),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to update video status: $e',
        code: 'UPDATE_ERROR',
        originalError: e,
      );
    }
  }

  /// Delete a video
  Future<void> deleteVideo(String videoId) async {
    try {
      final sql = 'DELETE FROM videos WHERE id = @id';
      final rowsAffected = await _db.execute(sql, [videoId]);

      if (rowsAffected == 0) {
        throw ApiException(
          message: 'Video not found',
          code: 'NOT_FOUND',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to delete video: $e',
        code: 'DELETE_ERROR',
        originalError: e,
      );
    }
  }

  /// Health check - verify database connection
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      const sql = 'SELECT NOW() as timestamp, COUNT(*) as videoCount FROM videos';
      final result = await _db.querySingle(sql);

      return {
        'status': 'ok',
        'database': 'Neon PostgreSQL (Direct)',
        'timestamp': result?['timestamp'] ?? DateTime.now().toIso8601String(),
        'videoCount': result?['videoCount'] ?? 0,
      };
    } catch (e) {
      throw ApiException(
        message: 'Health check failed: $e',
        code: 'HEALTH_CHECK_ERROR',
        originalError: e,
      );
    }
  }

  /// Validate URL format
  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }
}

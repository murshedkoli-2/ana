import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/app_config.dart';
import '../models/video.dart';
import '../services/video_service.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoId;

  const VideoDetailScreen({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isTransitioning = false;
  bool _isDeleting = false;
  String? _error;

  Future<void> _transitionStatus(
    BuildContext context,
    VideoService videoService,
    Video video,
  ) async {
    final nextStatus = video.getNextStatus();
    if (nextStatus == null) return;

    setState(() => _isTransitioning = true);

    try {
      await videoService.updateVideoStatus(video.id, nextStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video status updated to $nextStatus'),
            backgroundColor: const Color(AppConfig.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to update status: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
    }
  }

  Future<void> _deleteVideo(
    BuildContext context,
    VideoService videoService,
    Video video,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video?'),
        content: Text('Are you sure you want to delete "${video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppConfig.destructiveColor),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await videoService.deleteVideo(video.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video deleted successfully'),
            backgroundColor: Color(AppConfig.successColor),
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to delete video: $e');
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConfig.backgroundColor),
      appBar: AppBar(
        title: const Text('Video Details'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(AppConfig.backgroundColor),
      ),
      body: Consumer<VideoService>(
        builder: (context, videoService, _) {
          final video = videoService.getVideoById(widget.videoId);

          if (video == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Video not found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(AppConfig.textSecondary),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConfig.primaryColor),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error Message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(
                        color: const Color(0xFFFFCDD2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error,
                          color: Color(AppConfig.destructiveColor),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(AppConfig.destructiveColor),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _error = null),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                if (_error != null) const SizedBox(height: 24),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(video.getStatusColor()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        video.getStatusIcon(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        video.status.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  video.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(AppConfig.textPrimary),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),

                // URL
                _buildDetailRow(
                  context,
                  label: 'URL',
                  value: video.url,
                  isUrl: true,
                ),
                const SizedBox(height: 16),

                // Created Date
                _buildDetailRow(
                  context,
                  label: 'Created',
                  value: video.formattedDate,
                ),
                const SizedBox(height: 16),

                // Last Updated
                _buildDetailRow(
                  context,
                  label: 'Last Updated',
                  value: _formatDateTime(video.updatedAt),
                ),
                const SizedBox(height: 48),

                // Action Buttons
                if (video.canTransition())
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isTransitioning
                              ? null
                              : () => _transitionStatus(context, videoService, video),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(AppConfig.primaryColor),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isTransitioning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Mark as ${video.getNextStatus()?.toUpperCase() ?? 'NEXT'}',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isDeleting
                        ? null
                        : () => _deleteVideo(context, videoService, video),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(AppConfig.destructiveColor),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(AppConfig.destructiveColor),
                              ),
                            ),
                          )
                        : Text(
                            'Delete Video',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: const Color(AppConfig.destructiveColor),
                                  fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isUrl = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(AppConfig.textSecondary),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(AppConfig.surfaceColor),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(AppConfig.borderColor),
              width: 1,
            ),
          ),
          child: isUrl
              ? GestureDetector(
                  onTap: () async {
                    // In a real app, you would use url_launcher package
                    // For now, just show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening: $value')),
                    );
                  },
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(AppConfig.primaryColor),
                          decoration: TextDecoration.underline,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppConfig.textPrimary),
                      ),
                ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }
}

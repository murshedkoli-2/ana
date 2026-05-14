import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/app_config.dart';
import '../models/video.dart';
import '../services/video_service.dart';

class CreatedVideosScreen extends StatefulWidget {
  const CreatedVideosScreen({Key? key}) : super(key: key);

  @override
  State<CreatedVideosScreen> createState() => _CreatedVideosScreenState();
}

class _CreatedVideosScreenState extends State<CreatedVideosScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading to after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideos();
    });
  }

  void _loadVideos() {
    final videoService = context.read<VideoService>();
    videoService.fetchVideosByStatus('created').catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading videos: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConfig.backgroundColor),
      appBar: AppBar(
        title: const Text('Created Videos'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(AppConfig.backgroundColor),
      ),
      body: Consumer<VideoService>(
        builder: (context, videoService, _) {
          final videos =
              videoService.videos.where((v) => v.status == 'created').toList();

          if (videoService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(AppConfig.primaryColor),
              ),
            );
          }

          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No created videos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(AppConfig.textSecondary),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Move videos to created status to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(AppConfig.textTertiary),
                        ),
                  ),
                ],
              ),
            );
          }

          return _buildVideoGrid(context, videos);
        },
      ),
    );
  }

  Widget _buildVideoGrid(BuildContext context, List<Video> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(context, video);
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video) {
    return GestureDetector(
      onTap: () => context.pushNamed('video-detail', pathParameters: {'id': video.id}),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppConfig.surfaceColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(AppConfig.borderColor),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(video.getStatusColor()),
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  Text(
                    video.getStatusIcon(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      video.status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(AppConfig.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.formattedDate,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(AppConfig.textTertiary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

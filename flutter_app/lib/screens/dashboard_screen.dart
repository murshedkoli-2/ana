import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/app_config.dart';
import '../models/video.dart';
import '../services/video_service.dart';
import '../widgets/ui_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

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
    videoService.fetchVideos().catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading videos: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConfig.backgroundColor),
      appBar: _buildAppBar(context),
      body: Consumer<VideoService>(
        builder: (context, videoService, _) {
          return Column(
            children: [
              // Search Bar
              _buildSearchBar(context, videoService),
              // Filter Tabs
              _buildFilterTabs(context, videoService),
              // Video Grid
              Expanded(
                child: _buildVideoGrid(context, videoService),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-video'),
        backgroundColor: const Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(AppConfig.backgroundColor),
    );
  }

  Widget _buildSearchBar(BuildContext context, VideoService videoService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (query) => videoService.search(query),
        decoration: InputDecoration(
          hintText: 'Search videos...',
          hintStyle: const TextStyle(
            color: Color(AppConfig.textTertiary),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(AppConfig.textSecondary),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    videoService.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(AppConfig.surfaceColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(AppConfig.borderColor),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(AppConfig.borderColor),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(AppConfig.primaryColor),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, VideoService videoService) {
    final tabs = [
      ('All', 'all', videoService.totalCount),
      ('Selected', 'selected', videoService.selectedCount),
      ('Created', 'created', videoService.createdCount),
      ('Published', 'published', videoService.publishedCount),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedFilter == tab.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${tab.$1} (${tab.$3})'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = tab.$2;
                });
              },
              backgroundColor: const Color(AppConfig.surfaceColor),
              selectedColor: const Color(AppConfig.primaryColor),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(AppConfig.textPrimary),
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(AppConfig.primaryColor)
                    : const Color(AppConfig.borderColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoGrid(BuildContext context, VideoService videoService) {
    final videos = _selectedFilter == 'all'
        ? videoService.videos
        : videoService.videos
            .where((v) => v.status == _selectedFilter)
            .toList();

    if (videoService.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const VideoCardSkeleton();
        },
      );
    }

    if (videos.isEmpty) {
      return EmptyStateWidget(
        title: 'No videos found',
        description: _selectedFilter == 'all'
            ? 'Add your first video to get started'
            : 'No ${_selectedFilter} videos yet',
        icon: Icons.movie_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).size.width > 768 ? 3 : 1,
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
            // Status Badge
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
            // Content
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

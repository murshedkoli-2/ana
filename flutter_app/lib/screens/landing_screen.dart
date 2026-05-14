import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_config.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConfig.backgroundColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context),
            const SizedBox(height: 80),
            // Features Section
            _buildFeaturesSection(context),
            const SizedBox(height: 80),
            // Platforms Section
            _buildPlatformsSection(context),
            const SizedBox(height: 80),
            // CTA Section
            _buildCtaSection(context),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          // Logo/Title
          Text(
            'ANA',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: const Color(AppConfig.textPrimary),
                  fontWeight: FontWeight.w900,
                  fontSize: 72,
                ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            'Discover, Curate, and Share Your Favorite Videos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(AppConfig.textSecondary),
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 32),
          // Description
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'ANA helps you manage your video collection effortlessly. Select, create, and publish your favorite videos all in one place.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(AppConfig.textTertiary),
                    height: 1.6,
                  ),
            ),
          ),
          const SizedBox(height: 48),
          // CTA Button
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConfig.primaryColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Get Started',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': '⭐',
        'title': 'Select & Organize',
        'description': 'Handpick your favorite videos and organize them in one place.'
      },
      {
        'icon': '✏️',
        'title': 'Create & Enhance',
        'description': 'Edit video details and enhance your collection with metadata.'
      },
      {
        'icon': '✅',
        'title': 'Publish & Share',
        'description': 'Share your curated videos with your audience effortlessly.'
      },
      {
        'icon': '🔍',
        'title': 'Search & Filter',
        'description': 'Find videos quickly with powerful search and filtering options.'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Key Features',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(AppConfig.textPrimary),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 48),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: features
                .map((feature) => _buildFeatureCard(context, feature))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, String> feature) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            feature['icon']!,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          Text(
            feature['title']!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(AppConfig.textPrimary),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            feature['description']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(AppConfig.textSecondary),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Available On',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(AppConfig.textPrimary),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlatformBadge(context, '🌐 Web'),
              const SizedBox(width: 24),
              _buildPlatformBadge(context, '📱 Android'),
              const SizedBox(width: 24),
              _buildPlatformBadge(context, '🍎 iOS (Coming Soon)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(BuildContext context, String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(AppConfig.surfaceColor),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(AppConfig.borderColor),
          width: 1,
        ),
      ),
      child: Text(
        platform,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppConfig.textPrimary),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Ready to Start?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(AppConfig.textPrimary),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConfig.primaryColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Go to Dashboard',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

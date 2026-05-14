import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/app_config.dart';
import 'services/database_service.dart';
import 'services/api_client.dart';
import 'services/video_service.dart';
import 'services/auth_service.dart';
import 'services/share_handler.dart';
import 'services/preferences_service.dart';
import 'services/video_cache_service.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_video_screen.dart';
import 'screens/video_detail_screen.dart';
import 'screens/selected_videos_screen.dart';
import 'screens/created_videos_screen.dart';
import 'screens/published_videos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize database connection pool
  final dbService = DatabaseService();
  try {
    await dbService.init();
    print('✅ Database connection pool initialized');
  } catch (e) {
    print('❌ Failed to initialize database: $e');
    // Continue anyway - app will show error when trying to use database
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;
  late ApiClient _apiClient;
  late VideoService _videoService;
  late AuthService _authService;
  late ShareHandler _shareHandler;
  late PreferencesService _preferencesService;
  late VideoCacheService _videoCacheService;

  @override
  void initState() {
    super.initState();
    // Initialize synchronously
    _setupServices();
    _setupRouter();
    _handleSharedIntent();
    // Initialize async services in background
    _initializeAsyncServices();
  }

  void _setupServices() {
    // Synchronous service initialization
    _apiClient = ApiClient();
    _videoService = VideoService(_apiClient);
    _authService = AuthService(_apiClient);
    _shareHandler = ShareHandler();
    _preferencesService = PreferencesService();
    _videoCacheService = VideoCacheService();
  }

  Future<void> _initializeAsyncServices() async {
    try {
      // Initialize storage services asynchronously
      await _preferencesService.init();
      await _videoCacheService.init();
    } catch (e) {
      print('Error initializing async services: $e');
    }
  }

  Future<void> _initializeServices() async {
    // This method is kept for compatibility but no longer used
  }

  void _setupRouter() {
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/add-video',
          name: 'add-video',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return AddVideoScreen(
              initialTitle: extra?['title'],
              initialUrl: extra?['url'],
            );
          },
        ),
        GoRoute(
          path: '/video/:id',
          name: 'video-detail',
          builder: (context, state) => VideoDetailScreen(
            videoId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/selected',
          name: 'selected',
          builder: (context, state) => const SelectedVideosScreen(),
        ),
        GoRoute(
          path: '/created',
          name: 'created',
          builder: (context, state) => const CreatedVideosScreen(),
        ),
        GoRoute(
          path: '/published',
          name: 'published',
          builder: (context, state) => const PublishedVideosScreen(),
        ),
      ],
      initialLocation: '/',
    );
  }

  void _handleSharedIntent() {
    _shareHandler.handleIntent((title, url) {
      if (title != null && url != null) {
        _router.pushNamed(
          'add-video',
          extra: {
            'title': title,
            'url': url,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        Provider<PreferencesService>.value(value: _preferencesService),
        Provider<VideoCacheService>.value(value: _videoCacheService),
        ChangeNotifierProvider<VideoService>.value(value: _videoService),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
      ],
      child: MaterialApp.router(
        title: 'ANA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3b82f6),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFffffff),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFffffff),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Color(0xFF0f172a),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }

  @override
  void dispose() {
    _videoService.dispose();
    _authService.dispose();
    super.dispose();
  }
}

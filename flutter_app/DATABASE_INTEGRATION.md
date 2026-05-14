# Flutter App Database Integration

## Overview
The Flutter Android app uses the **same database** and **same API backend** as the Next.js web application. Both applications consume data from a Neon PostgreSQL database through Next.js API endpoints.

## Database Architecture

### Web App (Next.js)
- **Database**: Neon PostgreSQL (serverless)
- **ORM**: Drizzle ORM
- **Database URL**: Configured via `DATABASE_URL` environment variable in `.env.local`
- **Schema Location**: `db/schema.ts`
- **API**: `app/api/videos/route.ts`

### Flutter App
- **Backend**: Next.js API at `/api/videos`
- **HTTP Client**: Custom `ApiClient` with REST endpoints
- **Base URL**: Configured in `lib/models/app_config.dart`

## Video Schema (Shared)
Both apps use the same video data structure:

```
- id: UUID (auto-generated)
- title: String (required)
- url: String (required)
- status: Enum ['selected', 'created', 'published']
- createdAt: Timestamp (auto-set)
- updatedAt: Timestamp (auto-update)
```

## API Endpoints (Shared)

All endpoints are consumed by both web and Flutter apps:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/videos` | Get all videos (optional `?status=` filter) |
| GET | `/api/videos?status=selected` | Get videos by status |
| POST | `/api/videos` | Create new video |
| PATCH | `/api/videos` | Update video status |
| DELETE | `/api/videos?id={videoId}` | Delete video |

## Configuration

### For Local Development

#### 1. Start the Next.js Backend
```bash
cd F:\ana
npm run dev
```
The backend will run on `http://localhost:3000`

#### 2. Configure Flutter App (Already Done)
The Flutter app is configured to connect to `http://localhost:3000/api`

- **Web/Chrome**: Uses `http://localhost:3000/api`
- **Android Emulator**: Update to `http://10.0.2.2:3000/api`
- **Physical Device**: Use your machine's IP address `http://192.168.x.x:3000/api`

#### 3. Run Flutter App
```bash
cd F:\ana\flutter_app

# Web/Chrome (development)
flutter run -d chrome

# Android Emulator
flutter run -d <emulator-id>

# Physical Android Device
flutter run -d <device-id>
```

### For Production

#### 1. Update Flutter App Config
Edit `lib/models/app_config.dart` and change:
```dart
static const String apiBaseUrl = 'https://your-production-domain.com/api';
```

#### 2. Deploy Next.js Backend
Deploy your Next.js app to a hosting platform:
- **Vercel** (Recommended): `vercel deploy`
- **Netlify**: `netlify deploy`
- **Self-hosted**: Set up Node.js server with DATABASE_URL env var

#### 3. Ensure DATABASE_URL is Set
Make sure the production environment has `DATABASE_URL` configured:
```bash
# In production .env
DATABASE_URL="postgresql://..."
```

## API Client Implementation

### File: `lib/services/api_client.dart`

The Flutter app uses a custom `ApiClient` that mirrors the Next.js API:

```dart
// Get all videos
List<Video> videos = await apiClient.getVideos();

// Get videos by status
List<Video> selected = await apiClient.getVideos(status: 'selected');

// Create video
Video newVideo = await apiClient.createVideo('Title', 'https://...');

// Update video status
await apiClient.updateVideoStatus(videoId, 'created');

// Delete video
await apiClient.deleteVideo(videoId);

// Health check
Map response = await apiClient.healthCheck();
```

## Data Synchronization

### Real-time Sync
Both apps connect to the same backend, so:
- Changes in web app immediately appear in Flutter app
- Changes in Flutter app immediately appear in web app
- No data duplication - single source of truth (Neon PostgreSQL)

### Offline Support
The Flutter app includes optional offline caching:
- **VideoCacheService**: Stores videos locally using Hive
- **PreferencesService**: Stores user preferences locally
- Automatic sync when connection is restored

## Testing

### 1. Test API Connectivity
```bash
# From command line
curl http://localhost:3000/api/videos

# Expected response
[
  {
    "id": "uuid-here",
    "title": "Video Title",
    "url": "https://...",
    "status": "selected",
    "createdAt": "2024-...",
    "updatedAt": "2024-..."
  }
]
```

### 2. Test Flutter App
1. Add a video in Flutter app
2. Verify it appears in web app at `http://localhost:3000`
3. Update status in web app
4. Verify change appears in Flutter app
5. Delete from Flutter app
6. Verify deletion in web app

## Environment Variables

### Web App (.env.local)
```
DATABASE_URL="postgresql://neondb_owner:npg_D6Y7ihKktSXa@ep-rapid-wind-apix3grh-pooler.c-7.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
```

### Flutter App (lib/models/app_config.dart)
```dart
static const String apiBaseUrl = 'http://localhost:3000/api';
```

## Troubleshooting

### Issue: Flutter app can't connect to backend
**Solution**: 
- Check if Next.js is running: `npm run dev`
- Verify backend is on port 3000
- Check firewall/network access
- For Android emulator, use `10.0.2.2` instead of `localhost`

### Issue: Data not syncing between apps
**Solution**:
- Both apps must point to same API
- Verify DATABASE_URL is correctly set
- Check browser/app console for errors
- Restart both backend and app

### Issue: CORS errors (web only)
**Solution**:
- Update Next.js with CORS headers
- Add CORS middleware to API routes

## Security Notes

- Never commit DATABASE_URL with real credentials
- Use environment variables for sensitive data
- In production, use HTTPS only
- Validate all user inputs on both frontend and backend
- Implement proper authentication/authorization if needed

## Deployment Checklist

- [ ] DATABASE_URL configured in production environment
- [ ] Flutter app updated with production API URL
- [ ] Next.js backend deployed
- [ ] API endpoints accessible from Flutter app
- [ ] HTTPS enabled (production)
- [ ] Database backups configured
- [ ] Error logging configured
- [ ] Rate limiting configured

## References

- **Neon Database**: https://neon.tech
- **Drizzle ORM**: https://orm.drizzle.team
- **Next.js API Routes**: https://nextjs.org/docs/app/building-your-application/routing/route-handlers
- **Flutter HTTP**: https://pub.dev/packages/http

# API Parity Verification

This document verifies that the Flutter app and web app share the same API endpoints and database.

## Database Connection Flow

```
Flutter App
    ↓
[ApiClient - lib/services/api_client.dart]
    ↓
HTTP Requests to localhost:3000/api
    ↓
Next.js API Routes [app/api/videos/route.ts]
    ↓
Drizzle ORM [db/index.ts]
    ↓
Neon PostgreSQL [DATABASE_URL from .env.local]
    ↓
Video Table [db/schema.ts]
```

Web App uses the exact same flow:
```
Web App (TypeScript/React)
    ↓
Server-side fetch() to localhost:3000/api
    ↓
Next.js API Routes [app/api/videos/route.ts]
    ↓
Drizzle ORM [db/index.ts]
    ↓
Neon PostgreSQL [DATABASE_URL from .env.local]
    ↓
Video Table [db/schema.ts]
```

## API Endpoints Comparison

### GET /api/videos
**Purpose**: Retrieve all videos or filter by status

**Flutter Implementation**:
```dart
// lib/services/api_client.dart
Future<List<Video>> getVideos({String? status}) async {
  final uri = status != null
    ? '$baseUrl/videos?status=$status'
    : '$baseUrl/videos';
  
  final response = await http.get(Uri.parse(uri));
  // Parse and return list of videos
}
```

**Web Implementation**:
```typescript
// app/api/videos/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const status = searchParams.get("status");
  
  if (status !== null) {
    const result = await db
      .select()
      .from(videos)
      .where(eq(videos.status, status))
      .orderBy(asc(videos.createdAt));
    return NextResponse.json(result);
  }
  
  const result = await db.select().from(videos).orderBy(asc(videos.createdAt));
  return NextResponse.json(result);
}
```

**Same Database Query** ✅

---

### POST /api/videos
**Purpose**: Create a new video

**Flutter Implementation**:
```dart
// lib/services/api_client.dart
Future<Video> createVideo(String title, String url) async {
  final response = await http.post(
    Uri.parse('$baseUrl/videos'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'title': title, 'url': url}),
  );
  // Parse and return created video
}
```

**Web Implementation**:
```typescript
// app/api/videos/route.ts
export async function POST(request: NextRequest) {
  const body = await request.json();
  const { title, url } = body;
  
  // Validation...
  
  const result = await db
    .insert(videos)
    .values({ title: trimmedTitle, url: trimmedUrl, status: "selected" })
    .returning();
  
  return NextResponse.json(result[0], { status: 201 });
}
```

**Same Database Insert** ✅

---

### PATCH /api/videos
**Purpose**: Update video status

**Flutter Implementation**:
```dart
// lib/services/api_client.dart
Future<Video> updateVideoStatus(String videoId, String newStatus) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/videos'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'id': videoId, 'status': newStatus}),
  );
  // Parse and return updated video
}
```

**Web Implementation**:
```typescript
// app/api/videos/route.ts
export async function PATCH(request: NextRequest) {
  const body = await request.json();
  const { id, status } = body;
  
  // Validation...
  
  const result = await db
    .update(videos)
    .set({ status })
    .where(eq(videos.id, id))
    .returning();
  
  return NextResponse.json(result[0]);
}
```

**Same Database Update** ✅

---

### DELETE /api/videos
**Purpose**: Delete a video

**Flutter Implementation**:
```dart
// lib/services/api_client.dart
Future<void> deleteVideo(String videoId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/videos?id=$videoId'),
  );
  // Handle response
}
```

**Web Implementation**:
```typescript
// app/api/videos/route.ts
export async function DELETE(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get("id");
  
  // Validation...
  
  await db.delete(videos).where(eq(videos.id, id));
  return NextResponse.json({ success: true });
}
```

**Same Database Delete** ✅

---

## Data Model Comparison

### Flutter Video Model
```dart
// lib/models/video.dart
class Video {
  final String id;
  final String title;
  final String url;
  final String status; // 'selected', 'created', 'published'
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Web Video Schema
```typescript
// db/schema.ts
export const videos = pgTable("videos", {
  id: uuid("id").defaultRandom().primaryKey(),
  title: text("title").notNull(),
  url: text("url").notNull(),
  status: text("status", { enum: ["selected", "created", "published"] })
    .notNull()
    .default("selected"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull()
    .$onUpdate(() => new Date()),
});
```

**Same Structure** ✅

---

## Database Verification

### Neon PostgreSQL Connection
```
Flutter App → localhost:3000/api ← Next.js
                                      ↓
                            Drizzle ORM
                                      ↓
                        Neon PostgreSQL
                                      ↓
      DATABASE_URL from .env.local
      postgresql://user:pass@ep-xxx.neon.tech/db
```

### Shared Resources
- ✅ Same API Base URL: `http://localhost:3000/api`
- ✅ Same Drizzle ORM: `db/index.ts`
- ✅ Same Video Schema: `db/schema.ts`
- ✅ Same Database Connection: `DATABASE_URL`
- ✅ Same Video Table: `videos`

---

## Testing Same Database

### Verify Shared Data

1. **Add video in Flutter**
```dart
await videoService.createVideo("Test", "https://example.com/video.mp4");
```

2. **Check in Web App**
```bash
curl http://localhost:3000/api/videos
# Should return new video
```

3. **Update status in Web**
```bash
curl -X PATCH http://localhost:3000/api/videos \
  -H "Content-Type: application/json" \
  -d '{"id": "uuid-here", "status": "created"}'
```

4. **Verify in Flutter**
```dart
await videoService.fetchVideos();
// Should show updated status
```

5. **Delete in Flutter**
```dart
await videoService.deleteVideo(videoId);
```

6. **Verify in Web**
```bash
curl http://localhost:3000/api/videos
# Video should be gone
```

---

## Conclusion

✅ **The Flutter app and web app share the same:**
- PostgreSQL database (Neon)
- API endpoints (/api/videos)
- Data schema (Video model)
- CRUD operations (Create, Read, Update, Delete)

✅ **They use the same backend**: Next.js at localhost:3000

✅ **Data is synchronized in real-time** between all clients connected to the same API

✅ **No duplicate data**: Single source of truth (PostgreSQL)

The Flutter app is **not a separate system** - it's another client of the same backend service as the web app.

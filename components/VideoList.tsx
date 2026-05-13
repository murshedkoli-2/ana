import { db } from "@/db";
import { videos } from "@/db/schema";
import { eq, asc } from "drizzle-orm";
import VideoCard from "./VideoCard";

type Props = {
  status: "selected" | "created" | "published";
  title: string;
  showActions?: boolean;
};

export default async function VideoList({
  status,
  title,
  showActions = true,
}: Props) {
  const items = await db
    .select()
    .from(videos)
    .where(eq(videos.status, status))
    .orderBy(asc(videos.createdAt));

  return (
    <div>
      <h1 className="mb-6 text-2xl font-bold">{title}</h1>

      {items.length === 0 ? (
        <p className="text-gray-500">No videos found.</p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((video) => (
            <VideoCard
              key={video.id}
              video={{
                ...video,
                createdAt: video.createdAt?.toISOString() ?? null,
                updatedAt: video.updatedAt?.toISOString() ?? null,
              }}
              showActions={showActions}
            />
          ))}
        </div>
      )}
    </div>
  );
}

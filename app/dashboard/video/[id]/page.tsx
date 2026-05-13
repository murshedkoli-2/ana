import { db } from "@/db";
import { videos } from "@/db/schema";
import { eq } from "drizzle-orm";
import { notFound } from "next/navigation";
import VideoDetail from "@/components/VideoDetail";

export const dynamic = "force-dynamic";

type Props = {
  params: { id: string };
};

export default async function VideoDetailPage({ params }: Props) {
  const [video] = await db
    .select()
    .from(videos)
    .where(eq(videos.id, params.id))
    .limit(1);

  if (!video) notFound();

  return (
    <VideoDetail
      video={{
        ...video,
        createdAt: video.createdAt?.toISOString() ?? null,
        updatedAt: video.updatedAt?.toISOString() ?? null,
      }}
    />
  );
}

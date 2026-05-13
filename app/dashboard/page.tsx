import { db } from "@/db";
import { videos } from "@/db/schema";
import { asc } from "drizzle-orm";
import VideoCard from "@/components/VideoCard";

export const dynamic = "force-dynamic";

export default async function OverviewPage() {
  const allVideos = await db
    .select()
    .from(videos)
    .orderBy(asc(videos.createdAt));

  const counts = {
    total: allVideos.length,
    selected: allVideos.filter((v) => v.status === "selected").length,
    created: allVideos.filter((v) => v.status === "created").length,
    published: allVideos.filter((v) => v.status === "published").length,
  };

  return (
    <div>
      <h1 className="mb-6 text-2xl font-bold text-kling-text">Overview</h1>

      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <SummaryCard label="Total" count={counts.total} color="text-kling-text" />
        <SummaryCard label="Selected" count={counts.selected} color="text-yellow-400" />
        <SummaryCard label="Created" count={counts.created} color="text-blue-400" />
        <SummaryCard label="Published" count={counts.published} color="text-emerald-400" />
      </div>

      <h2 className="mb-4 text-xl font-semibold text-kling-text">All Videos</h2>

      {allVideos.length === 0 ? (
        <p className="text-gray-500">No videos found.</p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {allVideos.map((video) => (
            <VideoCard
              key={video.id}
              video={{
                ...video,
                createdAt: video.createdAt?.toISOString() ?? null,
                updatedAt: video.updatedAt?.toISOString() ?? null,
              }}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function SummaryCard({
  label,
  count,
  color,
}: {
  label: string;
  count: number;
  color: string;
}) {
  return (
    <div className="rounded-xl border border-white/5 bg-[#131929] p-5 shadow-sm">
      <p className="text-sm text-kling-text2">{label}</p>
      <p className={`text-3xl font-bold ${color}`}>{count}</p>
    </div>
  );
}

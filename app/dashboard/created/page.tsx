import VideoList from "@/components/VideoList";

export const dynamic = "force-dynamic";

export default function CreatedPage() {
  return <VideoList status="created" title="Created Videos" />;
}

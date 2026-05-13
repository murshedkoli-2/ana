import VideoList from "@/components/VideoList";

export const dynamic = "force-dynamic";

export default function SelectedPage() {
  return <VideoList status="selected" title="Selected Videos" />;
}

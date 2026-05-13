import VideoList from "@/components/VideoList";

export const dynamic = "force-dynamic";

export default function PublishedPage() {
  return (
    <VideoList
      status="published"
      title="Published Videos"
      showActions={false}
    />
  );
}

"use client";

import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { useState } from "react";

type Video = {
  id: string;
  title: string;
  url: string;
  status: "selected" | "created" | "published";
  createdAt: string | null;
  updatedAt: string | null;
};

const statusBadge = {
  selected: "bg-yellow-900/30 text-yellow-400 border border-yellow-600/30",
  created: "bg-blue-900/30 text-blue-400 border border-blue-600/30",
  published: "bg-emerald-900/30 text-emerald-400 border border-emerald-600/30",
};

type Props = {
  video: Video;
  showActions?: boolean;
};

function copyText(text: string) {
  try {
    if (navigator?.clipboard?.writeText) {
      navigator.clipboard.writeText(text);
      return true;
    }
  } catch {}
  try {
    const input = document.createElement("input");
    input.value = text;
    input.style.position = "fixed";
    input.style.opacity = "0";
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);
    return true;
  } catch {}
  return false;
}

export default function VideoCard({ video, showActions = true }: Props) {
  const router = useRouter();
  const pathname = usePathname();
  const [copied, setCopied] = useState(false);
  const [updating, setUpdating] = useState<string | null>(null);

  function handleCopy() {
    copyText(video.url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  async function updateStatus(newStatus: string) {
    setUpdating(newStatus);
    try {
      const res = await fetch("/api/videos", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: video.id, status: newStatus }),
      });
      if (!res.ok) throw new Error("Update failed");
      router.replace(pathname);
    } catch {
      setUpdating(null);
    }
  }

  return (
    <div className="rounded-xl border border-white/5 bg-[#0f1424] p-5 shadow-sm hover:border-kling-primary/20 hover:shadow-lg transition group">
      <div className="mb-3 flex items-start justify-between gap-3">
        <h3 className="text-base font-semibold text-kling-text truncate">{video.title}</h3>
        <span
          className={`shrink-0 rounded-full px-2.5 py-0.5 text-xs font-medium ${statusBadge[video.status]}`}
        >
          {video.status}
        </span>
      </div>

      <div className="mb-4 flex items-center gap-2">
        <a
          href={video.url}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-1 truncate text-sm text-kling-primary hover:text-kling-accent transition"
        >
          {video.url}
        </a>
        <button
          type="button"
          onClick={handleCopy}
          className={`shrink-0 rounded-lg px-2.5 py-1.5 text-xs font-medium transition ${
            copied
              ? "bg-emerald-900/30 text-emerald-400 border border-emerald-600/30"
              : "bg-white/5 text-kling-text3 border border-white/10 hover:bg-kling-primary/10 hover:text-kling-primary hover:border-kling-primary/30"
          }`}
          title="Copy video link"
        >
          {copied ? "Copied!" : "Copy"}
        </button>
      </div>

      {showActions && (
        <div className="flex flex-wrap items-center gap-2">
          {video.status === "selected" && (
            <button
              type="button"
              onClick={() => updateStatus("created")}
              disabled={updating !== null}
              className="rounded-lg bg-gradient-to-r from-kling-primary to-kling-accent px-4 py-1.5 text-sm text-white font-medium hover:shadow-lg hover:shadow-kling-primary/30 transition disabled:opacity-50"
            >
              {updating ? "Updating..." : "Move to Created"}
            </button>
          )}
          {video.status === "created" && (
            <button
              type="button"
              onClick={() => updateStatus("published")}
              disabled={updating !== null}
              className="rounded-lg bg-gradient-to-r from-emerald-600 to-emerald-500 px-4 py-1.5 text-sm text-white font-medium hover:shadow-lg hover:shadow-emerald-500/30 transition disabled:opacity-50"
            >
              {updating ? "Updating..." : "Publish"}
            </button>
          )}
          <Link
            href={`/dashboard/video/${video.id}`}
            className="ml-auto rounded-lg border border-white/10 bg-white/5 px-4 py-1.5 text-sm font-medium text-kling-text2 transition hover:bg-white/10 hover:text-kling-text"
          >
            Details →
          </Link>
        </div>
      )}
    </div>
  );
}

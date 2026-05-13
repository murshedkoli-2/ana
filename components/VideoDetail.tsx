"use client";

import { useRouter, usePathname } from "next/navigation";
import { useState } from "react";
import ConfirmModal from "./ConfirmModal";

type Video = {
  id: string;
  title: string;
  url: string;
  status: "selected" | "created" | "published";
  createdAt: string | null;
  updatedAt: string | null;
};

const statusColors: Record<string, string> = {
  selected: "bg-yellow-900/30 text-yellow-400 border border-yellow-600/30",
  created: "bg-blue-900/30 text-blue-400 border border-blue-600/30",
  published: "bg-emerald-900/30 text-emerald-400 border border-emerald-600/30",
};

type Props = {
  video: Video;
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

export default function VideoDetail({ video }: Props) {
  const router = useRouter();
  const pathname = usePathname();
  const [copied, setCopied] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [updating, setUpdating] = useState(false);

  function handleCopy() {
    copyText(video.url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  async function handleDelete() {
    setDeleting(true);
    try {
      const res = await fetch(`/api/videos?id=${video.id}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Delete failed");
      router.push("/dashboard");
    } catch {
      setDeleting(false);
      setShowDeleteModal(false);
    }
  }

  async function updateStatus(newStatus: string) {
    setUpdating(true);
    try {
      const res = await fetch("/api/videos", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: video.id, status: newStatus }),
      });
      if (!res.ok) throw new Error("Update failed");
      router.replace(pathname);
    } catch {
      setUpdating(false);
    }
  }

  return (
    <>
      <div className="mx-auto max-w-2xl">
        <button
          type="button"
          onClick={() => router.back()}
          className="mb-6 flex items-center gap-1.5 text-sm text-kling-text2 hover:text-kling-text transition"
        >
          ← Back
        </button>

        <div className="rounded-2xl border border-white/10 bg-[#0f1424] p-6 shadow-sm">
          <div className="mb-6 flex items-start justify-between gap-4">
            <div className="min-w-0 flex-1">
              <h1 className="truncate text-xl font-bold text-kling-text">
                {video.title}
              </h1>
              <span
                className={`mt-2 inline-block rounded-full px-3 py-0.5 text-xs font-medium ${statusColors[video.status]}`}
              >
                {video.status}
              </span>
            </div>
          </div>

          <div className="mb-6">
            <label className="mb-1.5 block text-xs font-medium uppercase tracking-wider text-kling-text3">
              Video URL
            </label>
            <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-white/[0.02] px-4 py-3">
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
                className={`shrink-0 rounded-lg px-3 py-1.5 text-xs font-medium transition ${
                  copied
                    ? "bg-emerald-900/30 text-emerald-400 border border-emerald-600/30"
                    : "bg-white/5 text-kling-text3 border border-white/10 hover:bg-kling-primary/10 hover:text-kling-primary hover:border-kling-primary/30"
                }`}
              >
                {copied ? "Copied!" : "Copy"}
              </button>
            </div>
          </div>

          <div className="mb-8 grid grid-cols-2 gap-4">
            <div>
              <label className="mb-1 block text-xs font-medium uppercase tracking-wider text-kling-text3">
                Created
              </label>
              <p className="text-sm text-kling-text2">
                {video.createdAt
                  ? new Date(video.createdAt).toLocaleDateString("en-US", {
                      year: "numeric",
                      month: "short",
                      day: "numeric",
                    })
                  : "—"}
              </p>
            </div>
            <div>
              <label className="mb-1 block text-xs font-medium uppercase tracking-wider text-kling-text3">
                Updated
              </label>
              <p className="text-sm text-kling-text2">
                {video.updatedAt
                  ? new Date(video.updatedAt).toLocaleDateString("en-US", {
                      year: "numeric",
                      month: "short",
                      day: "numeric",
                    })
                  : "—"}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-3 border-t border-white/5 pt-5">
            <a
              href={video.url}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-lg bg-gradient-to-r from-kling-primary to-kling-accent px-5 py-2 text-sm font-medium text-white shadow-lg transition hover:shadow-xl"
            >
              Open Video →
            </a>

            {video.status === "selected" && (
              <button
                type="button"
                onClick={() => updateStatus("created")}
                disabled={updating}
                className="rounded-lg bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-2 text-sm font-medium text-white shadow-lg transition hover:shadow-xl disabled:opacity-50"
              >
                {updating ? "Updating..." : "Move to Created"}
              </button>
            )}
            {video.status === "created" && (
              <button
                type="button"
                onClick={() => updateStatus("published")}
                disabled={updating}
                className="rounded-lg bg-gradient-to-r from-emerald-600 to-emerald-500 px-5 py-2 text-sm font-medium text-white shadow-lg transition hover:shadow-xl disabled:opacity-50"
              >
                {updating ? "Updating..." : "Publish"}
              </button>
            )}

            <button
              type="button"
              onClick={() => setShowDeleteModal(true)}
              disabled={updating}
              className="ml-auto rounded-lg border border-red-600/30 bg-red-900/20 px-5 py-2 text-sm font-medium text-red-400 transition hover:bg-red-900/40 hover:text-red-300 disabled:opacity-50"
            >
              Delete Video
            </button>
          </div>
        </div>
      </div>

      <ConfirmModal
        open={showDeleteModal}
        title="Delete Video"
        message={`Are you sure you want to delete "${video.title}"? This action cannot be undone.`}
        confirmLabel={deleting ? "Deleting..." : "Delete"}
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setShowDeleteModal(false)}
      />
    </>
  );
}

"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function AddVideoPage() {
  const router = useRouter();
  const [title, setTitle] = useState("");
  const [url, setUrl] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (!title.trim() || !url.trim()) {
      setError("All fields are required");
      return;
    }

    setLoading(true);
    try {
      const res = await fetch("/api/videos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: title.trim(), url: url.trim() }),
      });

      if (!res.ok) {
        const data = await res.json();
        setError(data.error || "Failed to add video");
        return;
      }

      router.push("/dashboard");
    } catch {
      setError("Network error. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <h1 className="mb-6 text-2xl font-bold text-kling-text">Add New Video</h1>

      <form
        onSubmit={handleSubmit}
        className="max-w-lg rounded-xl border border-white/5 bg-[#131929] p-6 shadow-sm"
      >
        <div className="mb-4">
          <label className="mb-1 block text-sm font-medium text-kling-text2">
            Title
          </label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full rounded-lg border border-white/10 bg-kling-bg2 px-3 py-2 text-kling-text placeholder:text-kling-text3 outline-none focus:border-kling-primary focus:ring-1 focus:ring-kling-primary transition"
            placeholder="Video title"
          />
        </div>

        <div className="mb-4">
          <label className="mb-1 block text-sm font-medium text-kling-text2">
            Video URL
          </label>
          <input
            type="url"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            className="w-full rounded-lg border border-white/10 bg-kling-bg2 px-3 py-2 text-kling-text placeholder:text-kling-text3 outline-none focus:border-kling-primary focus:ring-1 focus:ring-kling-primary transition"
            placeholder="https://example.com/video"
          />
        </div>

        {error && (
          <p className="mb-4 text-sm text-kling-red">{error}</p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="rounded-lg bg-gradient-to-r from-kling-primary to-kling-accent px-6 py-2 text-white font-medium hover:shadow-lg hover:shadow-kling-primary/30 disabled:opacity-50 transition"
        >
          {loading ? "Adding..." : "Add Video"}
        </button>
      </form>
    </div>
  );
}

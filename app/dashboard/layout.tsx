"use client";

import Link from "next/link";
import { useState } from "react";

const navItems = [
  { label: "Overview", href: "/dashboard" },
  { label: "Selected", href: "/dashboard/selected" },
  { label: "Created", href: "/dashboard/created" },
  { label: "Published", href: "/dashboard/published" },
  { label: "Add Video", href: "/dashboard/add" },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="dashboard flex min-h-screen">
      <div
        className={`fixed inset-0 bg-black/50 z-20 lg:hidden transition-opacity ${
          sidebarOpen ? "opacity-100" : "opacity-0 pointer-events-none"
        }`}
        onClick={() => setSidebarOpen(false)}
      />

      <aside
        className={`fixed lg:sticky top-0 left-0 z-30 h-screen w-64 bg-kling-bg2 p-6 flex flex-col border-r border-white/5 transition-transform lg:translate-x-0 ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-xl font-bold text-kling-text">
            <span className="text-kling-primary">◆</span> Dashboard
          </h2>
          <button
            type="button"
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden text-kling-text3 hover:text-kling-text transition"
            aria-label="Close sidebar"
          >
            ✕
          </button>
        </div>
        <nav className="flex flex-col gap-1">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="rounded-lg px-4 py-2 text-kling-text2 hover:text-kling-text hover:bg-white/5 transition"
              onClick={() => setSidebarOpen(false)}
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </aside>

      <main className="flex-1 min-w-0 p-4 lg:p-8 bg-kling-bg text-kling-text">
        <button
          type="button"
          onClick={() => setSidebarOpen(true)}
          className="lg:hidden mb-4 flex items-center gap-2 text-kling-text2 hover:text-kling-text transition"
          aria-label="Open sidebar"
        >
          <span className="text-lg">☰</span>
          <span className="text-sm font-medium">Menu</span>
        </button>
        {children}
      </main>
    </div>
  );
}

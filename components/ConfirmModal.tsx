"use client";

import { useEffect, useRef } from "react";

type Props = {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: "danger" | "warning";
  onConfirm: () => void;
  onCancel: () => void;
};

export default function ConfirmModal({
  open,
  title,
  message,
  confirmLabel = "Delete",
  cancelLabel = "Cancel",
  variant = "danger",
  onConfirm,
  onCancel,
}: Props) {
  const dialogRef = useRef<HTMLDivElement>(null);
  const onCancelRef = useRef(onCancel);
  onCancelRef.current = onCancel;

  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === "Escape") onCancelRef.current();
    };
    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [open]);

  useEffect(() => {
    if (open) {
      dialogRef.current?.focus();
      document.body.style.overflow = "hidden";
    }
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  if (!open) return null;

  const accentColor =
    variant === "danger"
      ? "from-red-600 to-red-500"
      : "from-yellow-600 to-yellow-500";

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onCancel}
      />
      <div
        ref={dialogRef}
        tabIndex={-1}
        className="relative w-full max-w-sm rounded-2xl border border-white/10 bg-[#0f1424] p-6 shadow-2xl shadow-black/50"
        style={{ animation: "cfmIn 0.2s ease both" }}
      >
        <div className="mb-5 flex items-center gap-3">
          <div
            className={`flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br ${accentColor} text-lg`}
          >
            {variant === "danger" ? "!" : "⚠"}
          </div>
          <h3 className="text-lg font-semibold text-kling-text">{title}</h3>
        </div>

        <p className="mb-6 text-sm leading-relaxed text-kling-text2">{message}</p>

        <div className="flex gap-3">
          <button
            type="button"
            onClick={onCancel}
            className="flex-1 rounded-lg border border-white/10 bg-white/5 px-4 py-2.5 text-sm font-medium text-kling-text2 transition hover:bg-white/10 hover:text-kling-text"
          >
            {cancelLabel}
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className={`flex-1 rounded-lg bg-gradient-to-r ${accentColor} px-4 py-2.5 text-sm font-medium text-white shadow-lg transition hover:shadow-xl active:scale-[0.97]`}
          >
            {confirmLabel}
          </button>
        </div>
      </div>

      <style>{`
        @keyframes cfmIn {
          from { opacity: 0; transform: scale(0.92) translateY(8px); }
          to { opacity: 1; transform: scale(1) translateY(0); }
        }
      `}</style>
    </div>
  );
}

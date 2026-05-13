"use client";

import { useEffect } from "react";

export default function KlingClient() {
  useEffect(() => {
    const cards = document.querySelectorAll<HTMLElement>(".kling-page .card");

    cards.forEach((card) => {
      card.style.opacity = "0";
      card.style.transform = "translateY(20px)";
      card.style.transition =
        "opacity 0.45s ease, transform 0.45s ease, box-shadow 0.25s, border-color 0.25s, background 0.25s";
    });

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry, i) => {
          if (entry.isIntersecting) {
            setTimeout(() => {
              const el = entry.target as HTMLElement;
              el.style.opacity = "1";
              el.style.transform = "translateY(0)";
            }, i * 50);
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1 }
    );

    cards.forEach((card) => observer.observe(card));

    const sectionCards = document.querySelectorAll<HTMLElement>(
      ".kling-page .card[id]"
    );
    const chips = document.querySelectorAll<HTMLElement>(
      ".kling-page .bookmark-chip"
    );
    const sectionObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            chips.forEach((c) => c.classList.remove("active"));
            const active = document.querySelector<HTMLElement>(
              `.kling-page .bookmark-chip[href="#${entry.target.id}"]`
            );
            if (active) active.classList.add("active");
          }
        });
      },
      { rootMargin: "-40% 0px -50% 0px" }
    );
    sectionCards.forEach((s) => sectionObserver.observe(s));

    return () => {
      observer.disconnect();
      sectionObserver.disconnect();
    };
  }, []);

  return null;
}

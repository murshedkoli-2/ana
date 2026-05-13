"use client";

import Link from "next/link";
import { useState, useCallback } from "react";
import KlingClient from "@/components/KlingClient";

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

function CopyBtn({ url }: { url: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(() => {
    copyText(url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }, [url]);

  return (
    <button type="button" onClick={handleCopy} className={`btn ${copied ? "btn-copy copied" : "btn-copy"}`}>
      {copied ? "✓ Copied" : "Copy Link"}
    </button>
  );
}

const platforms = [
  {
    id: "imagine",
    badge: { text: "Best Pick", cls: "best" },
    logo: "🎨",
    gradient: "linear-gradient(135deg,#6c47ff,#a855f7)",
    name: "Imagine.art",
    tag: "Kling 3.0",
    desc: "One of the best free options — get 100 free credits every single day after signup. Credits renew daily, letting you generate multiple motion-control videos without paying.",
    meta: ["100 free credits/day", "Credits renew daily", "Kling MC 3.0", "Web Browser"],
    primaryUrl: "https://www.imagine.art",
    primaryLabel: "Visit Imagine.art",
    mcUrl: "https://www.imagine.art/tools/kling-3-motion-control",
  },
  {
    id: "kapwing",
    badge: { text: "No Watermark", cls: "free" },
    logo: "✂️",
    gradient: "linear-gradient(135deg,#00c4a7,#00e5b6)",
    name: "Kapwing AI Studio",
    tag: "Kling 2.6",
    desc: "Full-featured online video editor with Kling 2.6 integrated. Free tier includes Kling with no watermark — extremely user-friendly for creators.",
    meta: ["No watermark", "Full video editor", "Kling MC 2.6", "Web Browser"],
    primaryUrl: "https://www.kapwing.com",
    primaryLabel: "Visit Kapwing",
    mcUrl: "https://www.kapwing.com/ai-video-editor",
  },
  {
    id: "piapi",
    badge: { text: "Developer", cls: "dev" },
    logo: "🔌",
    gradient: "linear-gradient(135deg,#f59e0b,#f97316)",
    name: "PiAPI Playground",
    tag: "Kling 2.6",
    desc: "A developer-focused API platform with a free demo. New users get limited credits to test clips up to ~5 seconds. No credit card needed for basic testing.",
    meta: ["Demo credits (limited)", "Up to ~5s clips", "Kling MC 2.6", "Web / API"],
    primaryUrl: "https://piapi.ai",
    primaryLabel: "Visit PiAPI",
    mcUrl: "https://piapi.ai/kling-api",
  },
  {
    id: "easemate",
    badge: { text: "0 Credits", cls: "free" },
    logo: "🌟",
    gradient: "linear-gradient(135deg,#3b82f6,#60a5fa)",
    name: "EaseMate AI",
    tag: "Kling 2.6 Pro + 3.0",
    desc: "AI tools aggregator offering both Kling 2.6 Pro and Kling 3.0 Motion Control. Both pages state '0 credits required' for generation. Sign-in may be needed.",
    meta: ["0 credits needed", "Both 2.6 Pro & 3.0", "Kling MC 2.6 + 3.0", "Web Browser"],
    primaryUrl: "https://easemate.ai",
    primaryLabel: "Visit EaseMate",
    mcUrl: "https://easemate.ai/kling-motion-control",
  },
  {
    id: "mediaio",
    badge: { text: "3-Day Trial", cls: "trial" },
    logo: "📹",
    gradient: "linear-gradient(135deg,#dc2626,#ef4444)",
    name: "Media.io",
    tag: "Kling 3.0",
    desc: "Trusted media suite offering a 3-day free trial with full access to all tools including Kling 3.0 Motion Control. Register for an account to activate the trial.",
    meta: ["3-day full trial", "Full Kling 3.0 access", "Kling MC 3.0", "Web Browser"],
    primaryUrl: "https://www.media.io",
    primaryLabel: "Visit Media.io",
    mcUrl: "https://www.media.io/ai-video-generator/kling.html",
  },
  {
    id: "higgsfield",
    badge: { text: "Free Limited", cls: "free" },
    logo: "🚀",
    gradient: "linear-gradient(135deg,#7c3aed,#a78bfa)",
    name: "Higgsfield.ai",
    tag: "Kling 3.0",
    desc: "Creative AI suite with Kling 3.0 support. Free accounts get limited Kling 3.0 generations — explicitly advertised as 'free access to Kling 3.0 with limited generations'.",
    meta: ["Free limited gens", "Kling 3.0 latest", "Kling MC 3.0", "Web Browser"],
    primaryUrl: "https://higgsfield.ai",
    primaryLabel: "Visit Higgsfield",
    mcUrl: "https://higgsfield.ai/models",
  },
  {
    id: "jai",
    badge: { text: "10 Credits", cls: "credits" },
    logo: "🏪",
    gradient: "linear-gradient(135deg,#059669,#34d399)",
    name: "JAI Portal",
    tag: "Kling 2.6 / 3.0",
    desc: "AI marketplace with pay-as-you-go pricing. New signups receive 10 free credits — spendable on any model including Kling Motion Control. No card required.",
    meta: ["10 free credits signup", "Pay-as-you-go", "Kling MC 2.6 + 3.0", "Web Browser"],
    primaryUrl: "https://jai.ai",
    primaryLabel: "Visit JAI Portal",
    mcUrl: "https://jai.ai/kling",
  },
  {
    id: "morph",
    badge: { text: "Free Trial", cls: "trial" },
    logo: "🎭",
    gradient: "linear-gradient(135deg,#0f172a,#334155)",
    name: "Morph Studio",
    tag: "Kling 2.6",
    desc: "AI video suite advertising 'Get Started For Free' with Kling 2.6 Motion Control. Available via web UI with signup — some usage limits apply on the free tier.",
    meta: ["Free to start", "Web UI access", "Kling MC 2.6", "Web Browser"],
    primaryUrl: "https://www.morphstudio.com",
    primaryLabel: "Visit Morph Studio",
    mcUrl: "https://www.morphstudio.com/editor",
  },
  {
    id: "twoshot",
    badge: { text: "Free Credits", cls: "free" },
    logo: "🎯",
    gradient: "linear-gradient(135deg,#be185d,#f472b6)",
    name: "TwoShot.ai",
    tag: "Kling 3.0",
    desc: "Reportedly offers free credits on signup for Kling 3.0 with no card required. Verify current availability on the site as limits and availability may change.",
    meta: ["Free signup credits", "Verify on site", "Kling MC 3.0", "Web Browser"],
    primaryUrl: "https://twoshot.ai",
    primaryLabel: "Visit TwoShot.ai",
    mcUrl: "https://twoshot.ai/tools",
  },
];

export default function Home() {
  const [navOpen, setNavOpen] = useState(false);

  return (
    <div className="kling-page">
      <KlingClient />

      <header className="header">
        <div className="header-bg" />
        <nav className="nav">
          <div className="logo">
            <div className="logo-icon">⚡</div>
            <span className="logo-text">
              KlingFree<span className="logo-accent">.ai</span>
            </span>
          </div>
          <button type="button" className="nav-toggle" onClick={() => setNavOpen(!navOpen)} aria-label="Toggle menu">
            {navOpen ? "✕" : "☰"}
          </button>
          <div className={`nav-links ${navOpen ? "open" : ""}`}>
            <a href="#platforms" onClick={() => setNavOpen(false)}>Platforms</a>
            <a href="#compare" onClick={() => setNavOpen(false)}>Compare</a>
            <a href="#safety" onClick={() => setNavOpen(false)}>Safety</a>
            <Link
              href="/dashboard"
              className="rounded-lg bg-[#6c47ff] px-4 py-1.5 text-sm font-medium text-white hover:bg-[#5a3ae6] transition"
              onClick={() => setNavOpen(false)}
            >
              Dashboard →
            </Link>
          </div>
        </nav>
        <div className="hero">
          <div className="hero-badge">AI Motion Control Guide</div>
          <h1 className="hero-title">
            Free <span className="gradient-text">Kling Motion Control</span>
            <br />
            Platforms Directory
          </h1>
          <p className="hero-sub">
            Access Kuaishou&apos;s powerful AI motion-transfer model for free
            across 9+ trusted platforms. No credit card required to start.
          </p>
          <div className="hero-stats">
            <div className="stat">
              <span className="stat-num">9+</span>
              <span className="stat-label">Free Platforms</span>
            </div>
            <div className="stat-divider" />
            <div className="stat">
              <span className="stat-num">0$</span>
              <span className="stat-label">To Get Started</span>
            </div>
            <div className="stat-divider" />
            <div className="stat">
              <span className="stat-num">100</span>
              <span className="stat-label">Daily Credits (Top Pick)</span>
            </div>
          </div>
        </div>
      </header>

      <div className="bookmark-bar">
        <div className="bookmark-inner">
          <span className="bookmark-label">Jump:</span>
          {platforms.map((p) => (
            <a key={p.id} href={`#${p.id}`} className="bookmark-chip">{p.logo} {p.name.split(" ")[0]}</a>
          ))}
        </div>
      </div>

      <main className="main-kling">
        <div className="section-header" id="platforms">
          <h2>Free & Trial Platforms</h2>
          <p>
            All platforms below are browser-based — no installation needed. Just
            sign up and start generating!
          </p>
        </div>

        <div className="cards-grid">
          {platforms.map((p, i) => (
            <div key={p.id} className={`card ${i < 2 ? "featured" : ""}`} id={p.id}>
              <div className={`card-badge ${p.badge.cls}`}>{p.badge.text}</div>
              <div className="card-header">
                <div className="card-logo" style={{ background: p.gradient }}>
                  {p.logo}
                </div>
                <div className="card-title-block">
                  <h3>{p.name}</h3>
                  <span className="model-tag">{p.tag}</span>
                </div>
              </div>
              <p className="card-desc">{p.desc}</p>
              <div className="card-meta">
                {p.meta.map((m) => (
                  <div key={m} className="meta-item">{m}</div>
                ))}
              </div>
              <div className="card-actions">
                <a href={p.primaryUrl} target="_blank" rel="noopener noreferrer" className="btn btn-primary">
                  {p.primaryLabel} →
                </a>
                <a href={p.mcUrl} target="_blank" rel="noopener noreferrer" className="btn btn-ghost">
                  Motion Control Link
                </a>
                <CopyBtn url={p.mcUrl} />
              </div>
            </div>
          ))}
        </div>

        <section className="compare-section" id="compare">
          <h2 className="section-title">Platform Comparison</h2>
          <div className="table-wrapper">
            <table className="compare-table">
              <thead>
                <tr>
                  <th>Platform</th>
                  <th>Model</th>
                  <th>Free Type</th>
                  <th>Limit</th>
                  <th>Watermark</th>
                  <th>Card Needed</th>
                  <th>Quick Link</th>
                </tr>
              </thead>
              <tbody>
                {[
                  ["🎨 Imagine.art", "Kling 3.0", "Daily credits", "100/day", "None", "No", "https://www.imagine.art"],
                  ["✂️ Kapwing", "Kling 2.6", "Free tier", "No watermark", "None", "No", "https://www.kapwing.com"],
                  ["🔌 PiAPI", "Kling 2.6", "Demo credits", "~5s clips", "Varies", "No", "https://piapi.ai"],
                  ["🌟 EaseMate 2.6", "Kling 2.6 Pro", "Free (0 credits)", "0 credits needed", "None", "No", "https://easemate.ai"],
                  ["🌟 EaseMate 3.0", "Kling 3.0", "Free (0 credits)", "0 credits needed", "None", "No", "https://easemate.ai"],
                  ["📹 Media.io", "Kling 3.0", "3-day trial", "Full access 3 days", "None", "No", "https://www.media.io"],
                  ["🚀 Higgsfield", "Kling 3.0", "Limited gens", "Limited", "Varies", "No", "https://higgsfield.ai"],
                  ["🏪 JAI Portal", "Kling 2.6/3.0", "10 credits", "10 one-time credits", "None", "No", "https://jai.ai"],
                  ["🎭 Morph Studio", "Kling 2.6", "Free trial", "Limited", "Varies", "No", "https://www.morphstudio.com"],
                  ["🎯 TwoShot", "Kling 3.0", "Signup credits", "Verify on site", "Varies", "No", "https://twoshot.ai"],
                ].map((row, i) => (
                  <tr key={i} className={i === 0 ? "best-row" : ""}>
                    <td><strong>{row[0]}</strong></td>
                    <td><span className="model-tag sm">{row[1]}</span></td>
                    <td>{row[2]}</td>
                    <td>{row[3]}</td>
                    <td>{row[4]}</td>
                    <td>{row[5]}</td>
                    <td><a href={row[6]} target="_blank" rel="noopener noreferrer" className="table-link">Open →</a></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="safety-section" id="safety">
          <div className="safety-icon">🛡️</div>
          <h2>Safety & Licensing Notice</h2>
          <p>
            All platforms listed are official, reputable services.{" "}
            <strong>
              Never download unofficial APKs or &quot;modded&quot; versions of
              Kling
            </strong>{" "}
            — they are malicious and violate licensing.
          </p>
          <div className="safety-grid">
            <div className="safety-item good">Use browser-based platforms only</div>
            <div className="safety-item good">Sign up only on official domains</div>
            <div className="safety-item bad">Avoid modded APK sites</div>
            <div className="safety-item bad">Avoid unofficial download links</div>
          </div>
        </section>
      </main>

      <footer className="footer">
        <p>
          KlingFree.ai — Community Resource Directory &nbsp;|&nbsp; Not
          affiliated with KuaiShou or Kling official &nbsp;|&nbsp; Always verify
          usage terms on each platform.
        </p>
      </footer>
    </div>
  );
}

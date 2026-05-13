import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        kling: {
          bg: "#080b14",
          bg2: "#0d1120",
          bg3: "#111827",
          card: "#131929",
          primary: "#6c47ff",
          accent: "#a855f7",
          cyan: "#06b6d4",
          green: "#10b981",
          red: "#ef4444",
          yellow: "#f59e0b",
          text: "#f0f4ff",
          text2: "#94a3b8",
          text3: "#64748b",
        },
      },
    },
  },
  plugins: [],
};

export default config;

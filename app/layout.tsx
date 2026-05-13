import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "KlingFree.ai – Free Motion Control Platforms Directory",
  description:
    "Find the best free platforms offering Kling Motion Control AI video generation. Compare Imagine.art, Kapwing, Media.io, Higgsfield, and more.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=Outfit:wght@400;600;700;800&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}

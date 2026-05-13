import { NextRequest, NextResponse } from "next/server";
import { db } from "@/db";
import { videos } from "@/db/schema";
import { eq, asc } from "drizzle-orm";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const status = searchParams.get("status") as
    | "selected"
    | "created"
    | "published"
    | null;

  const query = db.select().from(videos).orderBy(asc(videos.createdAt));
  const result = status
    ? await query.where(eq(videos.status, status))
    : await query;

  return NextResponse.json(result);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const { title, url } = body;

  if (!title || !url) {
    return NextResponse.json(
      { error: "Title and URL are required" },
      { status: 400 }
    );
  }

  const result = await db
    .insert(videos)
    .values({ title, url, status: "selected" })
    .returning();

  return NextResponse.json(result[0], { status: 201 });
}

export async function PATCH(request: NextRequest) {
  const body = await request.json();
  const { id, status } = body;

  if (!id || !status) {
    return NextResponse.json(
      { error: "ID and status are required" },
      { status: 400 }
    );
  }

  const validStatuses = ["selected", "created", "published"];
  if (!validStatuses.includes(status)) {
    return NextResponse.json({ error: "Invalid status" }, { status: 400 });
  }

  const result = await db
    .update(videos)
    .set({ status })
    .where(eq(videos.id, id))
    .returning();

  return NextResponse.json(result[0]);
}

export async function DELETE(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get("id");

  if (!id) {
    return NextResponse.json(
      { error: "ID is required" },
      { status: 400 }
    );
  }

  await db.delete(videos).where(eq(videos.id, id));
  return NextResponse.json({ success: true });
}

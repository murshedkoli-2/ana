import { pgTable, uuid, text, timestamp } from "drizzle-orm/pg-core";

export const videos = pgTable("videos", {
  id: uuid("id").defaultRandom().primaryKey(),
  title: text("title").notNull(),
  url: text("url").notNull(),
  status: text("status", { enum: ["selected", "created", "published"] })
    .notNull()
    .default("selected"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull()
    .$onUpdate(() => new Date()),
});

export type Video = typeof videos.$inferSelect;
export type NewVideo = typeof videos.$inferInsert;

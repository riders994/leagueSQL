-- Seed data for "fantasy_sports"."dim_task_kind".
-- Requires the table to already exist (see sql/ddl/schedule.sql).
--
-- One row per kind of scheduled task the bot knows how to fire. The key is the
-- name itself, which is the same string the bot's handler registry uses, so a
-- new kind is one row here plus one handler in the bot and no DDL at all.
--
-- Idempotent, unlike the rumor seeds: this table grows a row at a time as new
-- kinds of chrontask are added, so re-running it must not collide with what is
-- already there.
--
-- Columns:
--   task_kind              varchar  -- natural key; matches the bot's handler name
--   task_kind_description  varchar  -- what firing one does

INSERT INTO "fantasy_sports"."dim_task_kind"
  ("task_kind", "task_kind_description")
VALUES
  ('reminder', 'Posts a message to a DM, a channel, or a channel with mentions.'),
  ('weekly', 'Runs one of the league''s weekly processes and reports it to a channel.')
ON CONFLICT ("task_kind") DO UPDATE
  SET "task_kind_description" = EXCLUDED."task_kind_description";

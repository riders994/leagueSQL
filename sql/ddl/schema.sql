-- Consolidated DDL for the fantasy_sports schema.
-- Combines wojbot_db_init.sql, fix_dims.sql, fact_line_score.sql and fact_rotos.sql
-- into a single script that builds the final schema in one pass.
--
-- Grains:
--   dim_league           = real-life league / franchise (one per Discord server)
--   dim_online_league    = one online platform-league per season (child of dim_league)
--   dim_manager          = the person, platform-independent
--   dim_manager_platform = that person's identity on one platform (handle + account id)
--   dim_team             = one manager's team in one online league in one season
--
--   Real-life refs : mvw_fact_league_managers                  -> dim_league
--   Online refs    : dim_team, fact_elos, fact_rotos           -> dim_online_league
--   Team refs      : fact_line_score                           -> dim_team
--
-- "platform" lives on dim_online_league, not dim_league, so a franchise that
-- migrates (ESPN -> Sleeper) keeps its history pinned to the right platform.
-- Resolve a manager's handle for a season by joining dim_manager_platform on
-- (manager_id, dim_online_league.platform).
--
-- The rumor subsystem (fact_rumor + its lookup dims) lives in rumors.sql,
-- which must be run after this script.

-- Drop everything child-first so foreign keys never block a rebuild.
-- Grouped by dependency level; order within a level does not matter.

-- Level 0: facts. Nothing references these.
DROP TABLE IF EXISTS "fantasy_sports"."fact_line_score";
DROP TABLE IF EXISTS "fantasy_sports"."fact_rotos";
DROP TABLE IF EXISTS "fantasy_sports"."fact_elos";
DROP TABLE IF EXISTS "fantasy_sports"."fact_dynasty_elos";
DROP TABLE IF EXISTS "fantasy_sports"."mvw_fact_league_managers";
-- Lives in rumors.sql, but references dim_league, so it has to go first or the
-- dim_league drop below fails. Rerun rumors.sql after this script to restore it.
DROP TABLE IF EXISTS "fantasy_sports"."fact_rumor";

-- Level 1: referenced only by the facts above.
DROP TABLE IF EXISTS "fantasy_sports"."dim_team";
DROP TABLE IF EXISTS "fantasy_sports"."dim_manager_platform";

-- Level 2: referenced by dim_team and the online-grain facts.
DROP TABLE IF EXISTS "fantasy_sports"."dim_online_league";

-- Level 3: roots.
DROP TABLE IF EXISTS "fantasy_sports"."dim_league";
DROP TABLE IF EXISTS "fantasy_sports"."dim_manager";

-- ---------------------------------------------------------------------------
-- Dimensions
-- ---------------------------------------------------------------------------

-- The person. Nothing platform-specific belongs here.
CREATE TABLE "fantasy_sports"."dim_manager" (
  "manager_id" int,
  "player_name" varchar,
  "discord_id" varchar,
  PRIMARY KEY ("manager_id")
);

-- One person's identity on one platform. A manager in an ESPN league and a
-- Sleeper league has two rows here, each with its own handle and account id.
-- Natural key is (manager_id, platform); no surrogate since no fact points here.
CREATE TABLE "fantasy_sports"."dim_manager_platform" (
  "manager_id" int,
  "platform" varchar,
  "platform_user_id" varchar,
  "display_name" varchar,
  PRIMARY KEY ("manager_id", "platform"),
  -- One platform account maps to at most one person, so a stray duplicate
  -- handle can't silently split someone's history across two managers.
  CONSTRAINT "UQ_dim_manager_platform_account"
    UNIQUE ("platform", "platform_user_id"),
  CONSTRAINT "FK_dim_manager_platform_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

-- Real-life league: one row per franchise / Discord server.
-- Platform-agnostic on purpose: a franchise can migrate platforms between
-- seasons, so "which platform" is a property of the season, not the franchise.
CREATE TABLE "fantasy_sports"."dim_league" (
  "league_id" int,
  "discord_server_id" bigint,
  "league_name" varchar,
  PRIMARY KEY ("league_id")
);

-- Online league: one row per platform league per year, parented to a real-life league.
-- Carries the platform, which is what pins a season's teams and manager handles
-- to the right rows in dim_manager_platform.
CREATE TABLE "fantasy_sports"."dim_online_league" (
  "online_league_id" int,
  "league_id" int,
  "platform" varchar,
  "platform_league_id" varchar,
  "league_year" int,
  PRIMARY KEY ("online_league_id"),
  CONSTRAINT "FK_dim_online_league_league_id"
    FOREIGN KEY ("league_id")
      REFERENCES "fantasy_sports"."dim_league"("league_id")
);

CREATE TABLE "fantasy_sports"."dim_team" (
  "team_id" int,
  "team_name" varchar,
  "manager_id" int,
  "online_league_id" int,
  "platform_team_id" varchar,
  "league_year" int,
  "is_commish" bool,
  "is_champion" bool,
  "comanager_id" int,
  "place_finish" int,
  PRIMARY KEY ("team_id"),
  CONSTRAINT "FK_dim_team_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id"),
  CONSTRAINT "FK_dim_team_comanager_id"
    FOREIGN KEY ("comanager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id"),
  CONSTRAINT "FK_dim_team_online_league_id"
    FOREIGN KEY ("online_league_id")
      REFERENCES "fantasy_sports"."dim_online_league"("online_league_id")
);

-- ---------------------------------------------------------------------------
-- Real-life-grain facts
-- ---------------------------------------------------------------------------

CREATE TABLE "fantasy_sports"."mvw_fact_league_managers" (
  "league_id" int,
  "manager_id" int,
  CONSTRAINT "FK_mvw_fact_league_managers_league_id"
    FOREIGN KEY ("league_id")
      REFERENCES "fantasy_sports"."dim_league"("league_id"),
  CONSTRAINT "FK_mvw_fact_league_managers_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

-- ---------------------------------------------------------------------------
-- Online-grain facts
-- ---------------------------------------------------------------------------

CREATE TABLE "fantasy_sports"."fact_dynasty_elos" (
  "team_id" int,
  "league_id" int,
  "manager_id" int,
  "manager_name" varchar,
  "week" int,
  "elo" float,
  CONSTRAINT "FK_fact_elos_league_id"
    FOREIGN KEY ("league_id")
      REFERENCES "fantasy_sports"."dim_league"("league_id"),
  CONSTRAINT "FK_fact_elos_team_id"
    FOREIGN KEY ("team_id")
      REFERENCES "fantasy_sports"."dim_team"("team_id"),
  CONSTRAINT "FK_fact_elos_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

CREATE TABLE "fantasy_sports"."fact_elos" (
  "team_id" int,
  "online_league_id" int,
  "manager_id" int,
  "manager_name" varchar,
  "week" int,
  "elo" float,
  CONSTRAINT "FK_fact_elos_online_league_id"
    FOREIGN KEY ("online_league_id")
      REFERENCES "fantasy_sports"."dim_online_league"("online_league_id"),
  CONSTRAINT "FK_fact_elos_team_id"
    FOREIGN KEY ("team_id")
      REFERENCES "fantasy_sports"."dim_team"("team_id"),
  CONSTRAINT "FK_fact_elos_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

CREATE TABLE "fantasy_sports"."fact_rotos" (
  "team_id" int,
  "online_league_id" int,
  "manager_id" int,
  "manager_name" varchar,
  "week" int,
  "score" float,
  CONSTRAINT "FK_fact_rotos_online_league_id"
    FOREIGN KEY ("online_league_id")
      REFERENCES "fantasy_sports"."dim_online_league"("online_league_id"),
  CONSTRAINT "FK_fact_rotos_team_id"
    FOREIGN KEY ("team_id")
      REFERENCES "fantasy_sports"."dim_team"("team_id"),
  CONSTRAINT "FK_fact_rotos_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

-- ---------------------------------------------------------------------------
-- Team-grain facts
-- ---------------------------------------------------------------------------

CREATE TABLE "fantasy_sports"."fact_line_score" (
  "team_id" int,
  "league_year" int,
  "week" int,
  "category" varchar,
  "value" float,
  CONSTRAINT "FK_fact_line_score_team_id"
    FOREIGN KEY ("team_id")
      REFERENCES "fantasy_sports"."dim_team"("team_id")
);

DROP TABLE IF EXISTS "fantasy_sports"."fact_elos";
DROP TABLE IF EXISTS "fantasy_sports"."mvw_fact_league_managers";
DROP TABLE IF EXISTS "fantasy_sports"."fact_rumor";
DROP TABLE IF EXISTS "fantasy_sports"."dim_team";
DROP TABLE IF EXISTS "fantasy_sports"."dim_manager";
DROP TABLE IF EXISTS "fantasy_sports"."dim_league";
DROP TABLE IF EXISTS "fantasy_sports"."dim_release_type";
DROP TABLE IF EXISTS "fantasy_sports"."dim_rumor_form";
DROP TABLE IF EXISTS "fantasy_sports"."dim_source_type";

CREATE TABLE "fantasy_sports"."dim_source_type" (
  "source_type_id" int,
  "source_type_name" varchar,
  "source_type_level" int,
  "is_internal" bool,
  "valid_forms" int[],
  PRIMARY KEY ("source_type_id")
);

CREATE TABLE "fantasy_sports"."dim_rumor_form" (
  "rumor_form_id" int,
  "form_text" varchar,
  "form_title" varchar,
  "required_fills" varchar,
  "valid_sources" int[],
  "valid_releases" int[],
  PRIMARY KEY ("rumor_form_id")
);

CREATE TABLE "fantasy_sports"."dim_release_type" (
  "release_type_id" int,
  "release_type_name" varchar,
  "release_type_level" int,
  "valid_forms" int[],
  PRIMARY KEY ("release_type_id")
);

CREATE TABLE "fantasy_sports"."dim_league" (
  "league_id" int,
  "discord_server_id" int,
  "league_name" varchar,
  "platform" varchar,
  "platform_league_id" varchar,
  "league_year" int,
  PRIMARY KEY ("league_id")
);

CREATE TABLE "fantasy_sports"."fact_rumor" (
  "rumor_id" int,
  "league_id" int,
  "rumor_form_id" int,
  "source_type_id" int,
  "release_type_id" int,
  "player_discord_id" int,
  "rumor_text" varchar,
  PRIMARY KEY ("rumor_id"),
  CONSTRAINT "FK_fact_rumor_league_id"
    FOREIGN KEY ("league_id")
      REFERENCES "fantasy_sports"."dim_league"("league_id"),
  CONSTRAINT "FK_fact_rumor_rumor_form_id"
    FOREIGN KEY ("rumor_form_id")
      REFERENCES "fantasy_sports"."dim_rumor_form"("rumor_form_id"),
  CONSTRAINT "FK_fact_rumor_source_type_id"
    FOREIGN KEY ("source_type_id")
      REFERENCES "fantasy_sports"."dim_source_type"("source_type_id"),
  CONSTRAINT "FK_fact_rumor_release_type_id"
    FOREIGN KEY ("release_type_id")
      REFERENCES "fantasy_sports"."dim_release_type"("release_type_id")
);

CREATE TABLE "fantasy_sports"."dim_manager" (
  "manager_id" int,
  "player_name" varchar,
  "display_name" varchar,
  "discord_id" varchar,
  "is_comanager" bool,
  PRIMARY KEY ("manager_id")
);

CREATE TABLE "fantasy_sports"."dim_team" (
  "team_id" int,
  "team_name" varchar,
  "manager_id" int,
  "league_id" int,
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
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

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

CREATE TABLE "fantasy_sports"."fact_elos" (
  "team_id" int,
  "league_id" int,
  "league_year" int,
  "manager_id" int,
  "manager_name" varchar,
  "is_dynasty" bool,
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

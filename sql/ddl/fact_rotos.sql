DROP TABLE IF EXISTS "fantasy_sports"."fact_rotos";

CREATE TABLE "fantasy_sports"."fact_rotos" (
  "team_id" int,
  "league_id" int,
  "league_year" int,
  "manager_id" int,
  "manager_name" varchar,
  "week" int,
  "score" float,
  CONSTRAINT "FK_fact_rotos_league_id"
    FOREIGN KEY ("league_id")
      REFERENCES "fantasy_sports"."dim_league"("league_id"),
  CONSTRAINT "FK_fact_rotos_team_id"
    FOREIGN KEY ("team_id")
      REFERENCES "fantasy_sports"."dim_team"("team_id"),
  CONSTRAINT "FK_fact_rotos_manager_id"
    FOREIGN KEY ("manager_id")
      REFERENCES "fantasy_sports"."dim_manager"("manager_id")
);

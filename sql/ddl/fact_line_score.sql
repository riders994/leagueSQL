DROP TABLE IF EXISTS "fantasy_sports"."fact_line_score";

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

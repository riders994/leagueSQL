DROP TABLE IF EXISTS fantasy.dim_stats;

CREATE TABLE fantasy.dim_stats (
    id SERIAL PRIMARY KEY
  , name     VARCHAR(40)
);

CREATE INDEX stat_id_index ON fantasy.dim_stats (id);
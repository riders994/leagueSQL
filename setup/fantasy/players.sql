DROP TABLE IF EXISTS fantasy.players;

CREATE TABLE fantasy.players (
    playerid SERIAL PRIMARY KEY
  , name     VARCHAR(40)
  , team     VARCHAR(40)
);

CREATE INDEX player_id_index ON fantasy.players (playerid);
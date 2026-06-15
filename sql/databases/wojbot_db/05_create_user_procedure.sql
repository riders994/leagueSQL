CREATE OR REPLACE PROCEDURE create_user(username text, password text)
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', username, password);
  EXECUTE format('GRANT consumer TO %I', username);
END;
$$;

-- Schema USAGE for all roles
GRANT USAGE ON SCHEMA public, unmodeled_data, fantasy_sports TO consumer;
GRANT USAGE ON SCHEMA public, unmodeled_data, fantasy_sports TO manager;
GRANT USAGE ON SCHEMA public, unmodeled_data, fantasy_sports TO power_user;
GRANT USAGE ON SCHEMA public, unmodeled_data, fantasy_sports TO moderator;

-- consumer: SELECT on all schemas
GRANT SELECT ON ALL TABLES IN SCHEMA public TO consumer;
GRANT SELECT ON ALL TABLES IN SCHEMA unmodeled_data TO consumer;
GRANT SELECT ON ALL TABLES IN SCHEMA fantasy_sports TO consumer;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO consumer;
ALTER DEFAULT PRIVILEGES IN SCHEMA unmodeled_data GRANT SELECT ON TABLES TO consumer;
ALTER DEFAULT PRIVILEGES IN SCHEMA fantasy_sports GRANT SELECT ON TABLES TO consumer;

-- manager: inherits consumer, adds EXECUTE
GRANT consumer TO manager;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO manager;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA unmodeled_data TO manager;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA fantasy_sports TO manager;

GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO manager;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA unmodeled_data TO manager;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA fantasy_sports TO manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO manager;
ALTER DEFAULT PRIVILEGES IN SCHEMA unmodeled_data GRANT EXECUTE ON FUNCTIONS TO manager;
ALTER DEFAULT PRIVILEGES IN SCHEMA fantasy_sports GRANT EXECUTE ON FUNCTIONS TO manager;

-- power_user: inherits manager, adds CREATE/INSERT/UPDATE on public and unmodeled_data
GRANT manager TO power_user;

GRANT CREATE ON SCHEMA public TO power_user;
GRANT CREATE ON SCHEMA unmodeled_data TO power_user;

GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO power_user;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA unmodeled_data TO power_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, UPDATE ON TABLES TO power_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA unmodeled_data GRANT INSERT, UPDATE ON TABLES TO power_user;

-- moderator: owns unmodeled_data and fantasy_sports, explicit privs on public
GRANT power_user TO moderator;

ALTER SCHEMA unmodeled_data OWNER TO moderator;
ALTER SCHEMA fantasy_sports OWNER TO moderator;

GRANT CREATE ON SCHEMA public TO moderator;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO moderator;

ALTER DEFAULT PRIVILEGES IN SCHEMA unmodeled_data GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO moderator;
ALTER DEFAULT PRIVILEGES IN SCHEMA fantasy_sports GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO moderator;

GRANT DELETE ON ALL TABLES IN SCHEMA public TO moderator;
GRANT DELETE ON ALL TABLES IN SCHEMA unmodeled_data TO moderator;
GRANT DELETE ON ALL TABLES IN SCHEMA fantasy_sports TO moderator;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT DELETE ON TABLES TO moderator;
ALTER DEFAULT PRIVILEGES IN SCHEMA unmodeled_data GRANT DELETE ON TABLES TO moderator;
ALTER DEFAULT PRIVILEGES IN SCHEMA fantasy_sports GRANT DELETE ON TABLES TO moderator;

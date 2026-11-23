-- Runs once, when the Postgres data directory is first created.
-- Authentik keeps its data in its own database inside the same Postgres.
CREATE DATABASE authentik;

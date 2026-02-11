#!/bin/bash
set -e

# These variables come from the container's environment
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    CREATE USER "$POSTGRES_N8N_USER" WITH PASSWORD '$POSTGRES_N8N_PASSWORD';
    CREATE DATABASE n8n_queue;
    GRANT ALL PRIVILEGES ON DATABASE n8n_queue TO "$POSTGRES_N8N_USER";
    ALTER DATABASE n8n_queue OWNER TO "$POSTGRES_N8N_USER";
EOSQL

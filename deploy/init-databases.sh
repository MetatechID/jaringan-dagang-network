#!/bin/bash
# Create additional databases needed by Jaringan Dagang services.
# The default POSTGRES_DB (jaringan_dagang) is created automatically by the
# postgres entrypoint; this script handles any extra databases.

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE beckn_registry;
    GRANT ALL PRIVILEGES ON DATABASE beckn_registry TO $POSTGRES_USER;
EOSQL

#!/bin/bash
set -e

PGDATA=/home/postgres/pgsql-17/data
PG_BIN=/home/postgres/pgsql-17/bin

# Add shared_preload_libraries if not already set
grep -q "pg_extension_base" $PGDATA/postgresql.conf || \
    echo "shared_preload_libraries = 'pg_extension_base'" >> $PGDATA/postgresql.conf

# Start PostgreSQL
$PG_BIN/pg_ctl start -D $PGDATA -w

# Create pg_lake extension if not exists
$PG_BIN/psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS pg_lake CASCADE;"

# Configure S3/RustFS
$PG_BIN/psql -U postgres -c "SET pg_lake_iceberg.default_location_prefix TO '${S3_LOCATION_PREFIX}';"

# Keep container alive
tail -f $PGDATA/log/postgresql*.log

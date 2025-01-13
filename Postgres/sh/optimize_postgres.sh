#!/bin/bash

# Create log directory
mkdir -p sql/logs

# PostgreSQL configuration optimized for SDE
echo "Configuring PostgreSQL parameters optimized for SDE..."
psql -U postgres -d $POSTGRES_DB -f "sql/alter_system_parameters.sql"

# Grant privileges for user SDE
echo "Granting privileges for SDE user..."
psql -U postgres -d $POSTGRES_DB -f "sql/grant_unlimited_privileges_sde.sql"

# Configure ST_GEOMETRY
echo "Configuring ST_GEOMETRY..."
psql -U postgres -d $POSTGRES_DB -f "sql/configure_st_geometry.sql"

echo "PostgreSQL optimization completed."

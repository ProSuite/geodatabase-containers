#!/bin/bash

# Create the SDE tablespace
echo "Creating SDE tablespace..."
psql -U postgres -d $POSTGRES_DB -f "sql/create_sde_tablespace.sql"

echo "SDE tablespace created."

#!/bin/bash

# Set the directory for the tablespace
TABLESPACE_DIR="/var/lib/postgresql/sde_data"

# Ensure the directory exists
if [ ! -d "$TABLESPACE_DIR" ]; then
    echo "Directory $TABLESPACE_DIR does not exist. Creating it..."
    mkdir -p "$TABLESPACE_DIR"
    chown postgres:postgres "$TABLESPACE_DIR"
    chmod 700 "$TABLESPACE_DIR"
    echo "Directory $TABLESPACE_DIR created and permissions set."
else
    echo "Directory $TABLESPACE_DIR already exists."
    # Fix ownership and permissions in case they are incorrect
    chown postgres:postgres "$TABLESPACE_DIR"
    chmod 700 "$TABLESPACE_DIR"
    echo "Directory $TABLESPACE_DIR ownership and permissions fixed."
fi

# Execute the SQL script to setup the tablespace and role
echo "Running SQL script to configure tablespace and role..."
psql -U postgres -d postgres -f /sql/create_sde_tablespace.sql


#!/bin/bash

# Create log directory
mkdir -p sql/logs

# oracle configuration parameters optimized for SDE:
# "Configure parameters optimized for SDE"
sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@/sql/alter_system_parameters.sql"

# "Grant unlimited tablespace for user SDE"
sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba  "@/sql/grant_unlimited_tablespace_sde.sql"

# "Configuring shapelib for ST_GEOMETRY"
sqlplus sde/$SDE_PASSWORD@localhost:1521/$ORACLE_PDB "@/sql/configure_shapelib.sql"
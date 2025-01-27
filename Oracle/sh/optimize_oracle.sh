#!/bin/bash

# Create log directory
mkdir -p sql/logs
mkdir -p /opt/oracle/esrilib && cp /license/libst_shapelib.so /opt/oracle/esrilib/libst_shapelib.so

# oracle configuration parameters optimized for SDE:
# "Configure parameters optimized for SDE"
sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@/sql/alter_system_parameters.sql"

# "Grant unlimited tablespace for user SDE"
sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba  "@/sql/grant_unlimited_tablespace_sde.sql"

# "Configuring shapelib for ST_GEOMETRY"
sqlplus sde/$SDE_PASSWORD@localhost:1521/$ORACLE_PDB "@/sql/configure_shapelib.sql"
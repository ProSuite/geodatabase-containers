#!/bin/bash
sqlplus / as sysdba '@/sql/create_sde_tablespace.sql' $TNS_NAME $ORACLE_PDB
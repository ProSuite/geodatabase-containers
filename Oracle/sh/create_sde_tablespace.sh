#!/bin/bash
sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba '@/sql/create_sde_tablespace.sql' $ORACLE_SID $ORACLE_PDB
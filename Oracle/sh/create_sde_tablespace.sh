#!/bin/bash
sqlplus / as sysdba '@/sql/create_sde_tablespace.sql' $ORACLE_SID $ORACLE_PDB
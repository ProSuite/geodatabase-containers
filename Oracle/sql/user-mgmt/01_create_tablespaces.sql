SET TERMOUT OFF
SPOOL /opt/oracle/scripts/setup/logs/01_create_tablespaces.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________
DEFINE data_dir=/opt/oracle/oradata/&1/&2/
DEFINE schema_owner=&3

alter system set db_create_file_dest='&data_dir' scope=both;

--- Just one table space for the data and the indexes. Users is already created from the start:
--- NOTE: Do not use oracle managed files otherwise the DB cannot be cloned/unplugged
create tablespace &schema_owner
    datafile '&data_dir.&schema_owner.dbf' size 1024m
    autoextend on maxsize unlimited
    extent management local autoallocate
    segment space management auto;


quit
spool off
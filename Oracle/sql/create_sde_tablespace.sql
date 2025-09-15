SET TERMOUT OFF
SPOOL /sql/logs/create_sde_tablespace.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

show con_name

alter system set db_create_file_dest='/opt/oracle/oradata/&1/&2/' scope=both;

--- IMPORTANT: tablespace has to be called SDE_DATA!
--- Create the SDE tablespace in the same location to simplify DB cloning and unplugging
create tablespace sde_data
    datafile '/opt/oracle/oradata/&1/&2/sde_data.dbf' size 64m
    autoextend on maxsize unlimited
    extent management local autoallocate
    segment space management auto;

quit
spool off
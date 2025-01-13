SET TERMOUT OFF
SPOOL /opt/oracle/scripts/setup/logs/00_alter_password_life_time.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

show con_name;
alter profile DEFAULT limit password_life_time UNLIMITED;

alter session set container=&1;
show con_name;
alter profile DEFAULT limit password_life_time UNLIMITED;

quit
spool off
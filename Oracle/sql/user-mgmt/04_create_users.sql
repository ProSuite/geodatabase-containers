SET TERMOUT OFF
SPOOL /opt/oracle/scripts/setup/logs/04_create_users.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

@/opt/oracle/scripts/setup/sql/users/create_roles.sql
@/opt/oracle/scripts/setup/sql/users/create_users.sql
@/opt/oracle/scripts/setup/sql/users/grant_roles.sql

quit
spool off
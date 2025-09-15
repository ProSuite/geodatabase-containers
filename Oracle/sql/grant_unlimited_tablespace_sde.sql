
SET TERMOUT OFF
SPOOL /sql/logs/grant_unlimited_tablespace_sde.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

--- Allow logfile creation to SDE during the reconcile process:
GRANT UNLIMITED TABLESPACE TO SDE;

quit

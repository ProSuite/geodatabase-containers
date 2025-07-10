
SET TERMOUT OFF
SPOOL /sql/logs/grant_unlimited_tablespace_sde.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

--- Allow logfile creation to SDE during the reconcile process:
GRANT UNLIMITED TABLESPACE TO SDE;

quit

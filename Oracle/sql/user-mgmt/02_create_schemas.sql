SET TERMOUT OFF
SPOOL /opt/oracle/scripts/setup/logs/02_create_schemas.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
--- ______________________________________________________

create user &1 identified by &2
	default tablespace &1
	temporary tablespace temp
	quota unlimited on &1
	quota unlimited on users;


create user delivery_manager identified by delivery_manager
	default tablespace &1
	temporary tablespace temp
	quota unlimited on &1
	quota unlimited on users;

create user graticules_manager identified by graticules_manager
	default tablespace &1
	temporary tablespace temp
	quota unlimited on &1
	quota unlimited on users;

GRANT CONNECT TO &1;
GRANT RESOURCE TO &1;
GRANT CONNECT TO delivery_manager;
GRANT RESOURCE TO delivery_manager;
GRANT CONNECT TO graticules_manager;
GRANT RESOURCE TO graticules_manager;

quit
spool off
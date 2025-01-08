SET TERMOUT OFF
SPOOL .\sql\logs\unplug_pdb.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
-- ______________________________________________________

define ORACLE_SID=&1
define PDB=&2
define EXCHANGE_DIR_NAME=&3
define TNS=&4

-- Set lower and upper case PDB names
COLUMN temp_val NEW_VALUE LOW_PDB
SELECT LOWER('&PDB') AS temp_val FROM dual;

COLUMN temp_val NEW_VALUE UPP_PDB
SELECT UPPER('&PDB') AS temp_val FROM dual;

alter session set container=cdb$root;

alter pluggable database &PDB close instances=all;

alter pluggable database &PDB open read only instances=all;

CREATE pluggable DATABASE clone
    FROM &PDB FILE_NAME_CONVERT=('/opt/oracle/oradata/&ORACLE_SID/&UPP_PDB', '/opt/oracle/&EXCHANGE_DIR_NAME/clone/&PDB', '/opt/oracle/oradata/&ORACLE_SID/&LOW_PDB', '/opt/oracle/&EXCHANGE_DIR_NAME/clone/&PDB');

alter pluggable database clone unplug
    into '/opt/oracle/&EXCHANGE_DIR_NAME/clone/&PDB..xml';

alter pluggable database &PDB close instances=all;

drop pluggable database clone;

alter pluggable database &PDB open read write instances=all;

quit
spool off
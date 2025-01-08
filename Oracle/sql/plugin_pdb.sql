SET TERMOUT OFF
SPOOL .\sql\logs\plugin_pdb.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON
-- ______________________________________________________

define ORACLE_SID=&1
define PDB=&2
define EXCHANGE_DIR_NAME=&3

-- drop default PDB
alter pluggable database ORCLPDB1 close instances=all;
drop pluggable database ORCLPDB1 including datafiles;

create pluggable database &PDB using '/opt/oracle/&EXCHANGE_DIR_NAME/&PDB..xml'
file_name_convert=('/opt/oracle/&EXCHANGE_DIR_NAME/&PDB/', '/opt/oracle/oradata/&ORACLE_SID/&PDB/');

alter pluggable database &PDB open instances=all;
alter session set container = &PDB;

quit
spool off
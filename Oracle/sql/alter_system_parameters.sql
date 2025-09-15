---
---	Name:       alter_system_parameters.sql
---
---	Purpose:    Alter the configuration parameters for geodatabase usage 
---
--- Run as:     SDE
--- ______________________________________________________

SET TERMOUT OFF
SPOOL  /sql/logs/alter_system_parameters.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON

SET SERVEROUTPUT ON

--- see suggestions in https://desktop.arcgis.com/en/arcmap/latest/extensions/maritime-charting-guide/admin-pl-oracle/creating-and-configuring-the-geodatabase-in-oracle.htm

--- in case we need to use DATAPUMP
alter system set deferred_segment_creation=false scope=both;

--- the default is exceeded even in a single-user system quite easily (requires gdb_util.update_open_cursors to run after the creation of the enterprise GDB)
--- If you used ALTER SYSTEM, restart the database. open_cursors is set immediately. For recyclebin and session_cached_cursors the database must be restarted.
alter system set open_cursors=10000 scope=both;
alter system set recyclebin=off scope=spfile;
alter system set session_cached_cursors=150 scope=spfile;

--- Important, because we have changed OPEN_CURSORS. See https://pro.arcgis.com/en/pro-app/latest/help/data/geodatabases/manage-oracle/update-open-cursors.htm
--- If this step is skipped, bad things will happen in the future!
GRANT INHERIT PRIVILEGES ON USER SYS TO SDE;
EXECUTE sde.gdb_util.update_open_cursors;
REVOKE INHERIT PRIVILEGES ON USER SYS FROM SDE;

-- restart database
SHUTDOWN IMMEDIATE
STARTUP

quit

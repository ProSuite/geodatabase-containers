---		Name:		grant_rw_all_tables.sql
---		Purpose:	grants r/w access on all tables
---					in the schema of the connected 
---					user, to the roles given as input parameters
---    __________________________________________________________

SET TERMOUT OFF
SPOOL .\sql\logs\grant_rw_all_tables.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON
SET SERVEROUTPUT ON

declare
	CURSOR table_cur IS
		SELECT table_name 
		  FROM user_tables 
		 WHERE table_name not like 'BIN$%' 
		 ORDER BY table_name;

	CURSOR sequence_cur IS
		SELECT sequence_name 
		  FROM user_sequences 
		 ORDER BY sequence_name;

	SQL_STMT VARCHAR2(200);

begin
	dbms_output.enable (1000000);

    dbms_output.put_line ('tables:');

	FOR TableRec in table_cur LOOP
		SQL_STMT := 'grant select on "' || TableRec.table_name || '" to &1';
		dbms_output.put_line (SQL_STMT);
		EXECUTE IMMEDIATE SQL_STMT;

		SQL_STMT := 'grant insert on "' || TableRec.table_name || '" to &2';
		dbms_output.put_line (SQL_STMT);
		EXECUTE IMMEDIATE SQL_STMT;

		SQL_STMT := 'grant update on "' || TableRec.table_name || '" to &2';
		dbms_output.put_line (SQL_STMT);
		EXECUTE IMMEDIATE SQL_STMT;

		SQL_STMT := 'grant delete on "' || TableRec.table_name || '" to &2';		
		dbms_output.put_line (SQL_STMT);
		EXECUTE IMMEDIATE SQL_STMT;
	END LOOP;
	
    dbms_output.put_line ('sequences:');

	FOR SeqRec in sequence_cur LOOP
		SQL_STMT := 'grant select on "' || SeqRec.sequence_name || '" to &2';
		dbms_output.put_line (SQL_STMT);
		EXECUTE IMMEDIATE SQL_STMT;
	END LOOP;
end;
/

SET SERVEROUTPUT OFF

quit;
create user &1 identified by &2
    default tablespace &3
    temporary tablespace temp
    quota unlimited on users;

GRANT &4 TO &1;
GRANT UNLIMITED TABLESPACE TO &1;

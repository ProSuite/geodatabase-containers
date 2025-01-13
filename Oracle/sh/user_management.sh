create_role() {
    local role=$1

    sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba CREATE ROLE $role;
}

grant_role() {
    local role=$1
    local user=$2

    sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba GRANT $role to $user;
}

create_schema_owner() {
    local user=$1
    local password=$2
    local tablespace=$3

    sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@../sql/user-mgnt/create_user.sql" $user $password $tablespace
    grant_role $user CONNECT
    grant_role $user RESOURCE
}

create_user() {
    local user=$1
    local password=$2
    local role=$3

    sqlplus sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@../sql/user-mgnt/create_user.sql" $user $password USERS $role
}
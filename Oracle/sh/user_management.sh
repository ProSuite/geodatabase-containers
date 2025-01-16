# These are a couple of utility functions that help to manage a simple user setup

create_role() {
    local role=$1

    sqlplus -s sys/"$ORACLE_PWD"@localhost:1521/"$ORACLE_PDB" as sysdba <<EOF
CREATE ROLE $role;
EXIT;
EOF
}

grant_role() {
    local role=$1
    local user=$2

    sqlplus -s sys/"$ORACLE_PWD"@localhost:1521/"$ORACLE_PDB" as sysdba <<EOF
GRANT $role to $user;
EXIT;
EOF
}

grant_rw_all_tables() {
    local role1=$1
    local role2=$2

    sqlplus -s sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@/sql/user-management/grant_rw_all_tables.sql" $role1 $role2
}

create_user() {
    local user=$1
    local password=$2
    local tablespace=$3

    sqlplus -s sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba "@/sql/user-management/create_user.sql" $user $password $tablespace
}

create_schema_owner() {
    local user=$1
    local password=$2
    local tablespace=$3

    create_user $user $password $tablespace
    grant_role CONNECT $user
    grant_role RESOURCE $user 
}

create_user_with_role() {
    local user=$1
    local password=$2
    local role=$3

    create_user $user $password USERS
    grant_role $role $user
    sqlplus -s sys/$ORACLE_PWD@localhost:1521/$ORACLE_PDB as sysdba <<EOF
GRANT UNLIMITED TABLESPACE TO $user;
EXIT;
EOF
}
# These are a couple of utility functions that help to manage a simple user setup

create_role() {
    local role=$1
    local pdb_var=${2:-ORACLE_PDB}  # Default to ORACLE_PDB if no second argument is passed
    local pdb_value=${!pdb_var}     # Indirect expansion to get the value of the variable name passed

    sqlplus -s sys/"$ORACLE_PWD"@localhost:1521/"$pdb_value" as sysdba <<EOF
CREATE ROLE $role;
EXIT;
EOF
}

grant_role() {
    local role=$1
    local user=$2
    local pdb_var=${3:-ORACLE_PDB}
    local pdb_value=${!pdb_var}

    sqlplus -s sys/"$ORACLE_PWD"@localhost:1521/"$pdb_value" as sysdba <<EOF
GRANT $role to $user;
EXIT;
EOF
}

grant_rw_all_tables() {
    local role1=$1
    local role2=$2
    local pdb_var=${3:-ORACLE_PDB}
    local schema_user_var=${4:-SCHEMA_USER}
    local schema_pw_var=${5:-SCHEMA_PW}

    local pdb_value=${!pdb_var}
    local schema_user_value=${!schema_user_var}
    local schema_pw_value=${!schema_pw_var}

    sqlplus -s $schema_user_value/$schema_pw_value@localhost:1521/$pdb_value "@/sql/user-management/grant_rw_all_tables.sql" $role1 $role2
}

create_user() {
    local user=$1
    local password=$2
    local tablespace=$3
    local pdb_var=${4:-ORACLE_PDB}
    local pdb_value=${!pdb_var}

    sqlplus -s sys/$ORACLE_PWD@localhost:1521/$pdb_value as sysdba "@/sql/user-management/create_user.sql" $user $password $tablespace
}

create_schema_owner() {
    local user=$1
    local password=$2
    local tablespace=$3
    local pdb_var=${4:-ORACLE_PDB}
    local pdb_value=${!pdb_var}

    create_user $user $password $tablespace $pdb_var
    grant_role CONNECT $user $pdb_var
    grant_role RESOURCE $user $pdb_var
}

create_user_with_role() {
    local user=$1
    local password=$2
    local role=$3
    local pdb_var=${4:-ORACLE_PDB}
    local pdb_value=${!pdb_var}

    create_user $user $password USERS $pdb_var
    grant_role $role $user $pdb_var
    sqlplus -s sys/$ORACLE_PWD@localhost:1521/$pdb_value as sysdba <<EOF
GRANT UNLIMITED TABLESPACE TO $user;
EXIT;
EOF
}
-- Validate required variable
\if :{?sde_password}
\else
\echo ERROR: sde_password variable was not provided. Aborting.
\quit 1
\endif

-- Create SDE_DATA tablespace if it does not exist
SELECT 'CREATE TABLESPACE SDE_DATA LOCATION ''/var/lib/postgresql/sde_data'''
WHERE NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA')
\gexec

-- Create SDE role if it does not exist
SELECT format(
    'CREATE ROLE sde WITH LOGIN PASSWORD %L SUPERUSER CREATEDB CREATEROLE INHERIT',
    :'sde_password'
)
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sde')
\gexec


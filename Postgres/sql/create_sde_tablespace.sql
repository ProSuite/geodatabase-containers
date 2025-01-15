-- Check if tablespace exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA') THEN
        RAISE NOTICE 'SDE_DATA tablespace does not exist. Proceeding with creation.';
        CREATE TABLESPACE SDE_DATA LOCATION '/var/lib/postgresql/sde_data';
    ELSE
        RAISE NOTICE 'SDE_DATA tablespace already exists. Skipping .';
    END IF;
END $$;

-- Post-creation validation
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA') THEN
        CREATE TABLESPACE SDE_DATA LOCATION '/var/lib/postgresql/sde_data';
    END IF;
END $$;


--Create SDE role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sde') THEN
        CREATE ROLE sde WITH LOGIN PASSWORD 'postgres';
        ALTER ROLE sde WITH SUPERUSER CREATEDB CREATEROLE INHERIT;
        RAISE NOTICE 'SDE role created successfully.';
    ELSE
        RAISE NOTICE 'SDE role already exists. Skipping creation.';
    END IF;
END $$;


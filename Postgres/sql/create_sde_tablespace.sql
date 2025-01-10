-- Pre-checks or preparations
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA') THEN
        RAISE NOTICE 'SDE_DATA tablespace does not exist. Proceeding with creation.';
    ELSE
        RAISE NOTICE 'SDE_DATA tablespace already exists. Skipping creation.';
    END IF;
END $$;

-- Create the tablespace
DO $$ 
BEGIN
    -- Ensure the directory exists at the OS level (to be executed via shell before running this script)
    IF NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA') THEN
        CREATE TABLESPACE SDE_DATA LOCATION '/var/lib/postgresql/sde_data';
    END IF;
END $$;

-- Post-creation check or actions
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'SDE_DATA') THEN
        RAISE NOTICE 'SDE_DATA tablespace creation successful.';
    ELSE
        RAISE EXCEPTION 'Failed to create SDE_DATA tablespace.';
    END IF;
END $$;

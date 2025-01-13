-- Grant privileges to SDE user
DO $$ 
BEGIN
    RAISE NOTICE 'Execution Date: %', NOW();
END $$;

-- Grant UNLIMITED TABLESPACE equivalent in PostgreSQL
ALTER ROLE sde WITH CREATEDB CREATEROLE;

-- Log completion
DO $$ 
BEGIN
    RAISE NOTICE 'Privileges granted to SDE user successfully.';
END $$;

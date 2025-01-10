-- Configure st_geometry library for SQL access
-- Log the configuration
DO $$ 
BEGIN
    RAISE NOTICE 'Execution Date: %', NOW();
END $$;

-- Set library path and permissions
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_proc
        WHERE proname = 'st_geometry'
    ) THEN
        RAISE NOTICE 'Creating st_geometry function...';
        CREATE OR REPLACE FUNCTION st_geometry(input text)
        RETURNS text AS '/usr/lib/postgresql/15/lib/st_geometry.so', 'st_geometry'
        LANGUAGE C IMMUTABLE STRICT;
    ELSE
        RAISE NOTICE 'st_geometry function already exists.';
    END IF;
END $$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION st_geometry(text) TO public;

-- Log completion
DO $$ 
BEGIN
    RAISE NOTICE 'st_geometry configuration completed successfully.';
END $$;

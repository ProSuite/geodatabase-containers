-- Log the date and time of execution
DO $$ 
BEGIN
    RAISE NOTICE 'Execution Date: %', NOW();
END $$;

-- Update PostgreSQL configuration parameters
ALTER SYSTEM SET max_connections = 500;
ALTER SYSTEM SET work_mem = '64MB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET shared_buffers = '2GB';
ALTER SYSTEM SET effective_cache_size = '4GB';
ALTER SYSTEM SET max_parallel_workers_per_gather = 4;
ALTER SYSTEM SET wal_buffers = '16MB';

-- Apply changes and reload configuration
SELECT pg_reload_conf();

-- Log completion
DO $$ 
BEGIN
    RAISE NOTICE 'System parameters altered successfully.';
END $$;

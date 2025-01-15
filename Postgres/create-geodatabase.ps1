# Set global error action preference to stop the script on any error
$ErrorActionPreference = "Stop"

# Import the Invoke-SafeCommand function from helpers\safe-command.ps1
. ..\helpers\safe-command.ps1

Write-Host "Loading .env file..."
Get-Content .env | ForEach-Object {
  if (-not ([string]::IsNullOrWhiteSpace($_))) {
    $name, $value = $_.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
      return
    }
    Set-Content env:\$name $value
  }
}

Set-Content env:\KEYCODES_FILE "$env:LICENSE_DIR/keycodes"
Set-Content env:\ST_GEOMETRY_SO_FILE "$env:LICENSE_DIR/st_geometry.so"

# Check if Docker Desktop is running
Write-Host "Checking if Docker Desktop is running..."
$process = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "Docker Desktop is already running."
} else {
    Write-Host "Docker Desktop is not running. Starting it now..."

    # Start Docker Desktop
    Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe" -NoNewWindow

    # Wait until Docker Desktop is fully running
    Write-Host "Waiting for Docker Desktop to start..."
    while (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 10
    }
    Write-Host "Docker Desktop has started successfully."
    Start-Sleep -Seconds 10
}

# Ensure st_geometry.so is available on the host
if (-not (Test-Path $env:ST_GEOMETRY_SO_FILE)) {
    Write-Host "st_geometry.so not found at $env:ST_GEOMETRY_SO_FILE" -ForegroundColor Red
    exit 1
} else {
    Write-Host "st_geometry.so found at $env:ST_GEOMETRY_SO_FILE" -ForegroundColor Green
}

# Copy st_geometry.so into the container



# # Check if esri blobs exist
# Write-Host "Checking esri blobs..."
# $envVars = @("$env:KEYCODES_FILE", "$env:SHAPELIB_SO_FILE", "$env:ARCPY_ENV_PATH")

# foreach ($var in $envVars) {
#         if (Test-Path $var -ErrorAction Stop) {
#             Write-Host "Path $var exists" -ForegroundColor Green
#         } else {
#             Write-Host "Path $var does not exist" -ForegroundColor Red -ErrorAction Stop
#         }
#     }

Write-Host "Building Postgres Container..."
Invoke-SafeCommand -Command 'docker compose up --wait'
Invoke-SafeCommand -Command 'docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/setup_shapelib.sh'

$PG_CONF_PATH = "/var/lib/postgresql/data/postgresql.conf"

# Add shared_preload_libraries to postgresql.conf
Write-Host "Updating postgresql.conf to include st_geometry.so..."
docker exec -it ${env:CONTAINER_NAME} bash -c 'echo "shared_preload_libraries = \"/usr/lib/postgresql/15/lib/st_geometry.so\"" >> /var/lib/postgresql/data/postgresql.conf'
# Restart PostgreSQL to apply changes
Write-Host "Restarting PostgreSQL to apply configuration changes..."
docker restart ${env:CONTAINER_NAME}


# Load st_geometry into PostgreSQL
#Write-Host "Loading st_geometry library into PostgreSQL..."
#docker exec -it $env:CONTAINER_NAME psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "LOAD 'st_geometry';"

Write-Host "Geodatabase setup complete!" -ForegroundColor Green
#docker exec -it ${env:CONTAINER_NAME} bash -c \"CREATE ROLE sde WITH LOGIN PASSWORD '$env:SDE_PASSWORD';\"
$containerName = $env:CONTAINER_NAME
docker exec -it $containerName bash -c "CREATE ROLE sde WITH LOGIN PASSWORD '$env:SDE_PASSWORD';"


Write-Host "PostgreSQL DB Container is up and running. Creating SDE Schema..."
#docker exec -it ${env:CONTAINER_NAME} bash -c "mkdir -p /var/lib/postgresql/sde_data && chmod 700 /var/lib/postgresql/sde_data"
#docker exec -it ${env:CONTAINER_NAME} bash -c "psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c \"CREATE TABLESPACE SDE_DATA LOCATION '/var/lib/postgresql/sde_data';\""
docker exec -it ${env:CONTAINER_NAME} mkdir -p /var/lib/postgresql/sde_data
Invoke-SafeCommand -Command 'docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/create_sde_tablespace.sh'

Write-Host "Are you happy with the PostgreSQL output and want to continue? Press Enter to proceed or Ctrl+C to cancel." -BackgroundColor Cyan
Read-Host



Write-Host "Postgresql configuration updated and reloaded successfully!" -ForegroundColor Green


Write-Host "Creating enterprise geodatabase..."
$PG_CONNECTION_STRING = "127.0.0.1,$env:POSTGRES_PORT"

# Run the enterprise geodatabase creation command
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_egdb.py --DBMS POSTGRESQL -i $PG_CONNECTION_STRING --auth DATABASE_AUTH `
    -U $env:POSTGRES_USER -P $env:POSTGRES_PASSWORD `
    -D $env:POSTGRES_DB -u sde -p $env:SDE_PASSWORD `
    -l $env:KEYCODES_FILE --type ST_GEOMETRY

# Some follow-up scripts might require the compress_log table to exist. It is created in the first compress
New-Item -Name "var" -ItemType Directory -Force
#$POSTGRES_DB="postgresdb"
$connectionFile = "${env:POSTGRES_DB}_as_sde.sde"
$connectionFileFolder = Join-Path -Path (Get-Location) -ChildPath "var"

Write-Host "Create SDE connection file $connectionFile"
$DATABASE_PLATFORM = "PostgreSQL"  # Change this to "ORACLE" if using Oracle
$CONNECTION_STRING = "127.0.0.1,$env:POSTGRES_PORT"
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_sde_file.py $connectionFileFolder $connectionFile $DATABASE_PLATFORM $CONNECTION_STRING $env:POSTGRES_USER $env:POSTGRES_PASSWORD
if ($?) { Write-Host "SDE connection file created" }
else { exit(2) }


Write-Host "Compressing $connectionFile  in $connectionFileFolder..."
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\compress.py $connectionFileFolder $connectionFile
if ($?) { Write-Host "Geodatabase compressed" }
else { exit(3) }

# Optimize
Invoke-SafeCommand -Command "docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/optimize_postgres.sh"

Write-Host "Geodatabase setup completed" -ForegroundColor Green



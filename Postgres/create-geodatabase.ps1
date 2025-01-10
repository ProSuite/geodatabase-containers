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

Write-Host "Building Postgres Container..."
Invoke-SafeCommand -Command 'docker compose up --wait'

# Copy st_geometry.so into the running container
Write-Host "Copying st_geometry.so to the container..."
docker cp $env:ST_GEOMETRY_SO_FILE ${env:CONTAINER_NAME}:/usr/lib/postgresql/15/lib/st_geometry.so

# Set permissions for st_geometry.so
Write-Host "Setting proper permissions for st_geometry.so..."
docker exec -it $env:CONTAINER_NAME chmod 755 /usr/lib/postgresql/15/lib/st_geometry.so

# Load st_geometry into PostgreSQL
Write-Host "Loading st_geometry library into PostgreSQL..."
docker exec -it $env:CONTAINER_NAME psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "LOAD 'st_geometry';"

Write-Host "Geodatabase setup complete!" -ForegroundColor Green

# Create SDE schema with mounted sh and sql scripts
Write-Host "PostgreSQL DB Container is up and running. Creating SDE Schema..."
docker exec -it ${env:CONTAINER_NAME} mkdir -p /var/lib/postgresql/sde_data
Invoke-SafeCommand -Command "docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/create_sde_tablespace.sh"

Write-Host "Are you happy with the PostgreSQL output and want to continue? Press Enter to proceed or Ctrl+C to cancel." -BackgroundColor Cyan
Read-Host

Write-Host "Creating enterprise geodatabase..."
$PG_CONNECTION_STRING = "127.0.0.1:$env:POSTGRES_PORT/$env:POSTGRES_DB"

& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_egdb.py --DBMS POSTGRESQL -i $PG_CONNECTION_STRING --auth DATABASE_AUTH `
    -U postgres -P $env:POSTGRES_PASSWORD `
    -u sde -p $env:SDE_PASSWORD `
    -t sde_data -l $env:KEYCODES_FILE
if ($?) { Write-Host "Enterprise Geodatabase created" }
else { exit(1) }

# Some follow-up scripts might require the compress_log table to exist. It is created in the first compress
New-Item -Name "var" -ItemType Directory -Force

$connectionFile = "${env:POSTGRES_DB}_as_sde.sde"
$connectionFileFolder = Join-Path -Path (Get-Location) -ChildPath "var"

Write-Host "Create SDE connection file $connectionFile"
$CONNECTION_STRING="127.0.0.1:$env:POSTGRES_PORT/$env:POSTGRES_DB"
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_sde_file.py $connectionFileFolder $connectionFile $CONNECTION_STRING sde $env:SDE_PASSWORD
if ($?) { Write-Host "SDE connection file created" }
else { exit(2) }

Write-Host "Compressing $connectionFile ..."
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\compress.py $connectionFileFolder $connectionFile
if ($?) { Write-Host "Geodatabase compressed" }
else { exit(3) }

# Optimize
Invoke-SafeCommand -Command "docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/optimize_postgres.sh"

Write-Host "Geodatabase setup completed" -ForegroundColor Green

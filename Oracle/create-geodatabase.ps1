# Set global error action preference to stop the script on any error
$ErrorActionPreference = "Stop"

# Import the Invoke-SafeCommand function from helpers\safe-command.ps1
. ..\helpers\safe-command.ps1

# Load .env file
Write-Host "Loading .env..."
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
Set-Content env:\SHAPELIB_SO_FILE "$env:LICENSE_DIR/libst_shapelib.so"

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

# Check if esri blobs exist
Write-Host "Checking esri blobs..."
$envVars = @("$env:KEYCODES_FILE", "$env:SHAPELIB_SO_FILE", "$env:ARCPY_ENV_PATH")

foreach ($var in $envVars) {
        if (Test-Path $var -ErrorAction Stop) {
            Write-Host "Path $var exists" -ForegroundColor Green
        } else {
            Write-Host "Path $var does not exist" -ForegroundColor Red -ErrorAction Stop
        }
    }

# Login to Oracle Container Registry
Write-Host "Logging in to container-registry-zurich.oracle.com..."
Write-Host "Use your Token as Password, generate it here: container-registry.oracle.com"
Write-Host "Make sure you accepted the conditions under container-registry.oracle.com > Databases > Enterprise"
Invoke-SafeCommand -Command 'docker login container-registry-zurich.oracle.com'


# Build Container
Write-Host "Building Oracle Container..."
Invoke-SafeCommand -Command 'docker compose up --wait'

# Create SDE schema with mounted sh and sql scripts
Write-Host "Oracle DB Container is up and running. Creating SDE Schema..."
Invoke-SafeCommand -Command 'docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/create_sde_tablespace.sh'
Write-Host "Are you happy with the SQL*Plus Output and want to continue? Press Enter to proceed or Ctrl+C to cancel." -BackgroundColor Cyan
Read-Host

Write-Host "Creating enterprise geodatabase..."
$EASY_CONNECTION_STRING = "//127.0.0.1:$env:ORACLE_PORT/$env:ORACLE_PDB"

& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_egdb.py --DBMS ORACLE -i $EASY_CONNECTION_STRING --auth DATABASE_AUTH `
    -U sys -P $env:ORACLE_PWD `
    -u sde -p $env:SDE_PASSWORD `
    -t sde_data -l $env:KEYCODES_FILE
if ($?) { Write-Host "Enterprise Geodatabase created" }
else { exit(1) }

# Some follow-up scripts might require the compress_log table to exist. It is created in the first compress
New-Item -Name "var" -ItemType Directory -Force

$connectionFile = "${env:ORACLE_PDB}_as_sde.sde"
$connectionFileFolder = Join-Path -Path (Get-Location) -ChildPath "var"

Write-Host "Create SDE connection file $connectionFile"
$CONNECTION_STRING="127.0.0.1:$env:ORACLE_PORT/$env:ORACLE_PDB"
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\create_sde_file.py $connectionFileFolder $connectionFile $DATABASE_PLATFORM $CONNECTION_STRING sde $env:SDE_PASSWORD
if ($?) { Write-Host "SDE connection file created" }
else { exit(2) }

Write-Host "Compressing $connectionFile ..."
& "$env:ARCPY_ENV_PATH" ..\helpers\arcpy\compress.py $connectionFileFolder $connectionFile
if ($?) { Write-Host "Geodatabase compressed" }
else { exit(3) }

# Optimize
Invoke-SafeCommand -Command 'docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/optimize_oracle.sh'

Write-Host "Geodatabase setup completed" -ForegroundColor Green

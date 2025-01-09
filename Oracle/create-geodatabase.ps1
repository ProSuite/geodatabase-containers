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
$envVars = @("$env:KEYCODES_FILE", "$env:SHAPELIB_SO_FILE", "$env:LOCALAPPDATA$env:ARCPY_ENV_PATH\python.exe")

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
if (!(Test-Path -Path .\logs)) {
    New-Item -ItemType Directory -Path .\logs
}
Invoke-SafeCommand -Command 'docker compose up --wait > logs/container-startup-logs.txt 2>&1'

# Create SDE schema with mounted sh and sql scripts
Write-Host "Oracle DB Container is up and running. Creating SDE Schema..."
Invoke-SafeCommand -Command 'docker exec -it ${env:CONTAINER_NAME} /bin/bash /sh/create_sde_tablespace.sh'
Write-Host "Are you happy with the SQL*Plus Output and want to continue? Press Enter to proceed or Ctrl+C to cancel." -BackgroundColor Cyan
Read-Host

Write-Host "Creating enterprise geodatabase..."
& "$env:LOCALAPPDATA$env:ARCPY_ENV_PATH\python.exe" ..\helpers\arcpy\create_egdb.py --DBMS ORACLE -i $env:TNS_NAME --auth DATABASE_AUTH `
    -U sys -P $env:ORACLE_PWD `
    -u sde -p $env:SDE_PASSWORD `
    -t sde_data -l $env:KEYCODES_FILE
if ($?) { Write-Host "Enterprise Geodatabase created" }
else { exit(1) }

## WIP


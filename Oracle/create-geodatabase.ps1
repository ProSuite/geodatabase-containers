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

Write-Host "Logging in to container-registry-zurich.oracle.com..."
docker login container-registry-zurich.oracle.com

Write-Host "Building Oracle Container..."
if (!(Test-Path -Path .\logs)) {
    New-Item -ItemType Directory -Path .\logs
}
docker compose up --wait > logs/container-startup-logs.txt 2>&1

Write-Host "Oracle DB Container is up and running. Creating SDE Schema..."
sqlplus sys/$env:LOCALAPPDATA$env:ORACLE_PWD@$env:TNS_NAME as sysdba "@.\sql\create_sde_tablespace.sql" $env:TNS_NAME DATA

Write-Host "Creating enterprise geodatabase..."
& "$env:LOCALAPPDATA$env:ARCPY_ENV_PATH\python.exe" ..\helpers\arcpy\create_egdb.py --DBMS ORACLE -i $env:TNS_NAME --auth DATABASE_AUTH `
    -U sys -P $env:ORACLE_PWD `
    -u sde -p $env:SDE_PASSWORD `
    -t sde_data -l $env:KEYCODES_FILE
if ($?) { Write-Host "Enterprise Geodatabase created" }
else { exit(1) }

## WIP


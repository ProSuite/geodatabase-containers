# PostgreSQL Container

## Additional prerequisites

- Installer for the esri extension in PostgreSQL (st_geometry or PostGIS)
- To interact with the container you will need PostgreSQL client tools installed locally.
- Have ArcGIS Pro up and running during container creation.

## Create a PostgreSQL Geodatabase Container

### Environment variables

To build your container you will need to create a .env file in the Postgres folder
Example with all the necessary variables

```txt
CONTAINER_NAME=prosuite-db-postgres-1510-base

# Port that binds the PostgreSQL port to your host
POSTGRES_PORT=5432

# PostgreSQL environment variables
POSTGRES_DB=postgresdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=xxxx1

# Geodatabase specific
# esri gdb admin user (sde)
SDE_PASSWORD=xxxx3

# esri dependency paths (on your local system)
# LICENSE_DIR should contain both:
# - file: keycodes
# - st_geometry.so
LICENSE_DIR=\path\to\your\keycodesAndStGeometrySo
ARCPY_ENV_PATH=\path\to\your\Python\envs\arcgispro-py3\python.exe
```

### Create the container

After you have fullfilled all the prerequisites in the global readme and this postgres specific readme,
you can create the container by running create-geodabase.ps1 from powershell.

## Notes on Docker

The create-geodatabase script uses the docker-compose.yml and the Dockerfile to build the docker containers. You can extend it as required to build your container.

- sql helper scripts are run directly within the container from the two .sh scripts in the .sh folder
- arcpy helper scripts are run on your host machine and connect to the server with a connection string.

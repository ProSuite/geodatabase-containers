# Oracle DB Container
## Additional prerequisites
- An oracle developer account for the oracle container registry:
    - https://container-registry.oracle.com/ords/f?p=113:10
    - **Important:** In your account, go to Database containers and accept the terms for the enterprise container.
- Installer for the esri extension in oracle (libst_shapelib.so)
- To interact with the container you will need to install the Oracle Client locally.
    - Install Client Home from: https://www.oracle.com/database/technologies/oracle19c-windows-downloads.html (Refer to https://silentinstallhq.com/oracle-database-19c-client-silent-install-how-to-guide/ for help.)
    - Set the ORACLE_HOME environment variable
- Have ArcGIS Pro up and running during container creation.

## Create an Oracle Geodatabase Container

### Environment variables
To build your container you will need to create a .env file in the Oracle folder
Example with all the necessary variables
```
CONTAINER_NAME=prosuite-db-oracle-193-base

# Port that binds the oracle port to your host
# Oracle Enterprise Manager will be on port ${ORACLE_PORT}1
ORACLE_PORT=1521

# Oracle environment variables (required by oracle image)
# ORACLE_SID: Only capitalized Alpha-Numeric Chars allowed (no - _ . ...)
ORACLE_SID=ORACLEBASE
ORACLE_PWD=xxxx1
ORACLE_PDB=DATA

# Oracle Paths (Bind mounts)
# This is where your database files will reside
EXCHANGE_DIR=C:\\bin\\oracle\\exchange
ORADATA_DIR=C:\\bin\\oracle\\oradata

# Geodatabase specific
# esri gdb admin user (sde)
SDE_PASSWORD=xxxx3

# esri dependency paths (on your local system)
# license dir should contain both the keycodes file and the libst_shapelib.so file
LICENSE_DIR=C:\Program Files\ESRI\License\
ARCPY_ENV_PATH=\path\to\your\Python\envs\arcgispro-py3\python.exe
```
### Create the container
After you have fullfilled all the prerequisites in the global readme and the oracle specific readme, you can create the container by running create-geodabase.ps1 from powershell.

**Important:** If you created a container before, you might need to delete the following two directories:
- EXCHANGE_DIR > see env variable for path
- ORADATA_DIR > see env variable for path

## Notes on Docker
The create-geodatabase script uses the docker-compose.yml and the Dockerfile to build the docker containers. You can extend it as required to build your container.

- sql helper scripts are run directly within the container from the two .sh scripts in the .sh folder
- arcpy helper scripts are run on your host machine and connect to the server with an easyconncet string.


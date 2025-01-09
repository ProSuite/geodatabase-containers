.env example

```
CONTAINER_NAME=prosuite-db-oracle-193-base

ORACLE_PWD=xxxx
ORACLE_PDB=ORCLPDB1
SCHEMA_OWNER=Schema_Owner
SCHEMA_OWNER2=Schema_Owner2
SCHEMA_OWNER_PASSWORD=xxxx
SDE_PASSWORD=xxxx


# Only capitalized Alpha-Numeric Chars allowed (no - _ . ...)
TNS_NAME=ORACLEBASE

# Oracle Paths
EXCHANGE_DIR=C:\\bin\\oracle\\exchange
ORADATA_DIR=C:\\bin\\oracle\\oradata

# esri blobs
KEYCODES_FILE=C:\\Program Files\\ESRI\\License10.8\\sysgen\\keycodes
SHAPELIB_SO_FILE=.\\libst_shapelib.so
ARCPY_ENV_PATH=\\Programs\\ArcGIS\\Pro\\bin\\Python\\envs\\arcgispro-py3
```

Login to Oracle CR
docker login container-registry-zurich.oracle.com

Make sure docker Desktop is running
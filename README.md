# ESRI Geodatabase Containers
This repo contains geodatabase docker containers for oracle and postgres.

## Prerequisites
- Docker Desktop is installed (https://docs.docker.com/desktop/)
- ArcGIS Account with "Professional" license or higher (Needed for ArcPy).
- A keycodes file to authorize "ArcGIS Server Basic" (Needed for the spatial extension in the db.)
    - How to generate keycodes files: https://support.esri.com/en-us/knowledge-base/how-to-generate-a-keycodes-file-to-authorize-an-enterpr-000024911
    - You can get a .prvc file on my.esri.com (Licensing > Start Licensing > Enterprise > Developer for ArcGIS Server)

## Building the database containers
After all of the above prerequisites are fullfilled you can refer to the readme in the respective db folders (oracle or postgres) on how to build the containers.

**Important:** Do not push any of the built containers into a public container registry, because they will contain your ArcGIS Server license.

## License
MIT License

## Contribute
TBD
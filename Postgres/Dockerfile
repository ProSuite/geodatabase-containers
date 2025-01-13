# Base image for PostgreSQL with PostGIS
FROM postgis/postgis:15-3.3


# Copy initialization scripts
# COPY init-scripts/ /docker-entrypoint-initdb.d/
COPY ./sh /sh

# Expose PostgreSQL port
# EXPOSE 5432

# Start the PostgreSQL server
CMD ["postgres"]

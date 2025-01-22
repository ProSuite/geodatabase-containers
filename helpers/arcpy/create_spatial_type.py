import sys
import traceback
import arcpy


def create_spatial_type(connection_file, sde_password, shapelib_path="/usr/lib/postgresql/15/lib/", tablespace = "sde_data"):
    """
    Function that creates the spatial type on a db.
    Note: Standard arguments for shapelib_path and tablespace are arguments that were hardcoded in old implementation.
    :param connection_file: Path to an sde connection file to the db.
    :param sde_password: Password for the schema_owner (i.e. Password for the user in the sde file).
    :param shapelib_path: Path to the shapelib file on the container.
    :param tablespace: The tablespace in which to create the spatial type.
    """
    print("Creating ST_GEOMETRY spatial type...")
    arcpy.CreateSpatialType_management(connection_file,sde_password,tablespace,shapelib_path)

if __name__ == '__main__':
    connection_file = sys.argv[1]
    sde_password = sys.argv[2]
    try:
        shapelib_path = sys.argv[3]
    except IndexError as e:
        shapelib_path = None
    try:
        tablespace = sys.argv[4]
    except IndexError as e:
        tablespace = None

    if not shapelib_path and not tablespace:
        create_spatial_type(connection_file, sde_password)
    elif not tablespace:
        create_spatial_type(connection_file, sde_password, shapelib_path)
    else:
        raise AttributeError("")

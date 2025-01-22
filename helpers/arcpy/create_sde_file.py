import sys
from typing import Literal

import arcpy
import os 

def create_sde_file(target_folder: str, sde_filename: str, db: Literal['ORACLE', 'POSTGRESQL'], instance: str, user: str, pw: str) -> None:
    """
    Creates an SDE connection file to load a connection.
    :param target_folder: The folder in which to store the file
    :param sde_filename: The name of the file (Must be unique within the target folder)
    :param db: The db to which the connection is made
    :param instance: A db connection string as is defined in arcpy.CreateDataBaseConnection_management
    :param user: User for which to create the connection
    :param pw: Password of the user
    """
    arcpy.env.overwriteOutput = True

    if not os.path.exists(target_folder):
        os.mkdir(target_folder)

    print(f"Creating SDE connection file here: {target_folder}\{sde_filename}")
    arcpy.CreateDatabaseConnection_management(
        out_folder_path=target_folder,
        out_name=sde_filename,
        database_platform=db,  # Dynamically pass the database platform
        instance=instance,
        account_authentication='DATABASE_AUTH',
        username=user,
        password=pw,
        save_user_pass='SAVE_USERNAME'
    )

    for i in range(arcpy.GetMessageCount()):
        arcpy.AddReturnMessage(i)

if __name__ == '__main__':
    out_folder_path = sys.argv[1]
    sde_file_name = sys.argv[2]
    database_platform: Literal['ORACLE', 'POSTGRESQL'] = sys.argv[3]  # Add this parameter to specify the database platform (e.g., POSTGRESQL, ORACLE)
    instance = sys.argv[4]
    user = sys.argv[5]
    pw = sys.argv[6]

    create_sde_file(target_folder=out_folder_path, sde_filename=sde_file_name, db=database_platform, instance=instance, user=user, pw=pw)
import os
import traceback
import sys
import arcpy

def create_version(sde_file_path, sde_file_name, version_name):
    """
Creates a version in an ArcSDE geodatabase.

Parameters:
sde_file_path (str): The path to the directory containing the SDE connection file.
sde_file_name (str): The name of the SDE connection file.
version_name (str): The name of the version to create.

Returns:
bool: True if the version is created successfully, False otherwise.
    """
    ws = os.path.join(sde_file_path, sde_file_name)
    arcpy.env.overwriteOutput = True

    print('Set workspace: {}'.format(ws))
    arcpy.env.workspace = ws

    print('Creating version {} ...'.format(version_name))

    try:
        arcpy.management.CreateVersion(ws, "SDE.DEFAULT", version_name, "PUBLIC")

        for i in range(arcpy.GetMessageCount()):
            arcpy.AddReturnMessage(i)
        print('Version created successfully.')
        return True

    except Exception as e:
        print('An error occurred while creating the version:')
        print(traceback.format_exc())
        return False


if __name__ == "__main__":
    # Example usage
    sde_file_path = sys.argv[1]
    sde_file_name = sys.argv[2]
    version_name = sys.argv[3]


    success = create_version(sde_file_path, sde_file_name, version_name)
    if success:
        print("Version created successfully.")
    else:
        print("Failed to create version.")

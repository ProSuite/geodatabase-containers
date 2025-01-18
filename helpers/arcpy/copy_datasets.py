import os
import sys
from typing import Optional

from create_sde_file import create_sde_file
import data_copy_utils


def copy_datasets(source_gdb_path: str,
                  instance: str,
                  user: str,
                  password: str,
                  sde_target_folder: str,
                  sde_filename: Optional[str] = 'schema_user.sde',
                  db_type: Optional[str] = 'ORACLE'):
    """
    Copy a gdb into a database container.
    You can either use a .env file to provide connection information to the target db,
    or provide a target instace analogous to instance in CreateDatabaseConnection_management as well
    as a username and password.
    :param source_gdb_path: The path to the gdb you want to copy
    :param db_type: Either 'ORACLE' or 'POSTGRESQL'
    :param instance: See arcpy.CreateDatabaseConnection_management
    :param user: Db username
    :param password: Db password
    :param sde_target_folder: The folder to store the sde files that are created
    :param sde_filename: How to call the sde file of the user that copies the data.
    """
    if not os.path.exists(sde_target_folder):
        os.makedirs(sde_target_folder)
    create_sde_file(target_folder=sde_target_folder, sde_filename=sde_filename, db=db_type, instance=instance, user=user, pw=password)
    schema_user_sde_file_path= os.path.join(sde_target_folder, sde_filename)

    data_copy_utils.copy_data(source_gdb_path, schema_user_sde_file_path)
    data_copy_utils.register_data_as_versioned(schema_user_sde_file_path)
    data_copy_utils.rebuild_indexes(schema_user_sde_file_path)
    data_copy_utils.analyze_datasets(schema_user_sde_file_path)

def rebuild_system(instance,
                   user: str,
                   password: str,
                   db_type: Optional[str] = 'ORACLE',
                   sde_target_folder: Optional[str] = os.path.join('sde_files'),
                   sde_filename: Optional[str] = 'sde_user.sde'):
    """
    Rebuilds the system in that it ensures that all the indexes are set correctly.
    i.e., calls RebuildIndexes_management with the sde user and the include_system parameter set to 'System'
    """
    if not os.path.exists(sde_target_folder):
        os.makedirs(sde_target_folder)
    
    create_sde_file(target_folder=sde_target_folder, sde_filename=sde_filename, db=db_type, instance=instance, user=user, pw=password)
    sde_user_sde_file_path= os.path.join(sde_target_folder, sde_filename)

    data_copy_utils.rebuild_indexes_state_lineage(sde_user_sde_file_path)
    data_copy_utils.analyze_state_lineage(sde_user_sde_file_path)



if __name__ == '__main__':
    source_gdb_path = sys.argv[1]
    instance = sys.argv[2]
    schema_user = sys.argv[3]
    schema_password = sys.argv[4]
    sde_user = sys.argv[5]
    sde_password = sys.argv[6]
    sde_target_folder = sys.argv[7]
    
    copy_datasets(source_gdb_path=source_gdb_path,
                  instance=instance,
                  user=schema_user,
                  password=schema_password,
                  sde_target_folder=sde_target_folder,
                  sde_filename=f'{schema_user}_{instance}')
    rebuild_system(instance=instance,
                   user=sde_user,
                   password=sde_password,
                   sde_target_folder=sde_target_folder,
                   sde_filename=f'sde_user_{schema_user}_{instance}')

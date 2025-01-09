import sys
import traceback
import arcpy
import os 

arcpy.env.overwriteOutput = True

try:
    out_folder_path = sys.argv[1]
    sde_file_name = sys.argv[2]
    instance = sys.argv[3]
    user = sys.argv[4]
    pw = sys.argv[5]

    if not os.path.exists(out_folder_path):
        os.mkdir(out_folder_path)

    if pw is None:
        raise ValueError('Password is not set.')

    print('')
    print('Creating SDE connection file \'{0}\\{1}\''.format(out_folder_path, sde_file_name))

    arcpy.CreateDatabaseConnection_management(out_folder_path=out_folder_path, out_name=sde_file_name, database_platform='ORACLE', instance=instance, account_authentication='DATABASE_AUTH', username=user, password=pw, save_user_pass='SAVE_USERNAME')
    
    for i in range(arcpy.GetMessageCount()):
         arcpy.AddReturnMessage(i)  
    print('')

except Exception as e:
    print(e)
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)


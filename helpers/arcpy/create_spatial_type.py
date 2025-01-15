import sys
import traceback
import arcpy

# As it has been set up in the image:
#shapelib_path = "/opt/oracle/esrilib/libst_shapelib.so"
shapelib_path = "/usr/lib/postgresql/15/lib/"
try:
    print('')
    print("Creating ST_GEOMETRY spatial type...")
    connection_file = sys.argv[1]
    print('sys user connection: \'{}\''.format(connection_file))
    sde_password = sys.argv[2]
    # TODO: shapelib_path should be passed as an argument instead of hardcoding it as above (See below).
    # shapelib_path = sys.argv[3]
    # print(f"Path to shapelib file: {shapelib_path}")

    # https://pro.arcgis.com/en/pro-app/2.8/tool-reference/data-management/create-enterprise-geodatabase.htm
    print('tablespace: sde_data')
    tablespace = "sde_data"
    arcpy.CreateSpatialType_management(connection_file,sde_password,tablespace,shapelib_path)

    for i in range(arcpy.GetMessageCount()):
        arcpy.AddReturnMessage(i)
    print('')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)

import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]

ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True


try:
    print('')
    print('Set workspace: {}'.format(ws))
    arcpy.env.workspace = ws
    print('Rebuilding indexes of states and state lineages tables...')
    # NOTE: You must be the geodatabase administrator to use this parameter.
    # include_system: "SYSTEM"
    # arcpy.management.AnalyzeDatasets("C:\\temp\\connection.sde", "SYSTEM")
    #
    # According to this link datasets list has to be empty for rebuilding system indexes:
    # https://pro.arcgis.com/en/pro-app/latest/help/data/geodatabases/manage-sql-server/rebuild-system-table-indexes.htm#GUID-27A36228-7B36-4A2C-B80E-855ED168D65C
    arcpy.RebuildIndexes_management(ws,
                                    "SYSTEM",
                                    [],
                                    "ALL")
    for i in range(arcpy.GetMessageCount()):
        arcpy.AddReturnMessage(i)
    print('')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)

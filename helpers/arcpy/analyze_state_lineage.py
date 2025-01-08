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
    print('Analyzing states and state lineages tables...')
    # NOTE: You must be the geodatabase administrator to use this parameter.
    # include_system: "SYSTEM"
    # arcpy.management.AnalyzeDatasets("C:\\temp\\connection.sde", "SYSTEM")
    arcpy.AnalyzeDatasets_management(ws,
                                     "SYSTEM", [],
                                     "NO_ANALYZE_BASE",
                                     "NO_ANALYZE_DELTA",
                                     "NO_ANALYZE_ARCHIVE")
    for i in range(arcpy.GetMessageCount()):
        arcpy.AddReturnMessage(i)
    print('')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)

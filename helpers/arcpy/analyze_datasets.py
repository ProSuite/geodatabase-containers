import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]

ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True


try:
    # the user in this workspace must be the owner of the data to analyze.
    print('')
    print('Set workspace: {}'.format(ws))
    arcpy.env.workspace = ws
    print('Analyzing datasets...')

    user = arcpy.Describe(ws).connectionProperties.user

    # Get all stand alone tables, feature classes.
    datasets = arcpy.ListTables(user + "*") + arcpy.ListFeatureClasses(user + "*")

    # Get datasets and feature classes from feature datasets
    for dataset in arcpy.ListDatasets(user + "*", "Feature"):
        arcpy.env.workspace = os.path.join(ws, dataset)
        # this lists feature classes but not
        # relationship classes or topology classes. This is what we want.
        # arcpy.ListDatasets("user" + "*") lists topology classes as well
        # throws an exception with arcpy.RebuildIndexes_management
        datasets += arcpy.ListFeatureClasses(user + "*")

    # reset the workspace
    arcpy.env.workspace = ws

    # Note: to use the "SYSTEM" option the workspace user must be an administrator.
    arcpy.AnalyzeDatasets_management(ws,
                                     "NO_SYSTEM", datasets,
                                     "ANALYZE_BASE",
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

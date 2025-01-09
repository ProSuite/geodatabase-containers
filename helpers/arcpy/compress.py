import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]

ws = os.path.join(sde_file_path, sde_file_name)
print(ws)
arcpy.env.overwriteOutput = True

arcpy.env.workspace = ws

print('')
print('Compressing {}...'.format(ws))

try:
    arcpy.management.Compress(ws)

    for i in range(arcpy.GetMessageCount()):
        arcpy.AddReturnMessage(i)
    print('')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)

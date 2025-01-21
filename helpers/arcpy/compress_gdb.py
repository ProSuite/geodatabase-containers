import os
import sys
import arcpy

def compress_gdb(sde_file_path):
    print('Compressing {}...'.format(sde_file_path))

    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path
    arcpy.management.Compress(sde_file_path)

if __name__ == '__main__':
    sde_path = sys.argv[1]
    sde_file_name = sys.argv[2]

    sde_file_path = os.path.join(sde_path, sde_file_name)
    compress_gdb(sde_file_path)

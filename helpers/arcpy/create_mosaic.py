import sys
import traceback
import arcpy

def create_mosaic(sde_file, mosaic_name):
    """
    Creates a mosaic for the given dataset
    """
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file

    print(f'Creating mosaic in {sde_file} ...')
    spatial_reference="PROJCS['CH1903+_LV95',GEOGCS['GCS_CH1903+',DATUM['D_CH1903+',SPHEROID['Bessel_1841',6377397.155,299.1528128]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Hotine_Oblique_Mercator_Azimuth_Center'],PARAMETER['False_Easting',2600000.0],PARAMETER['False_Northing',1200000.0],PARAMETER['Scale_Factor',1.0],PARAMETER['Azimuth',90.0],PARAMETER['Longitude_Of_Center',7.439583333333333],PARAMETER['Latitude_Of_Center',46.95240555555556],UNIT['Meter',1.0]],VERTCS['LHN95',VDATUM['Landeshohennetz_1995'],PARAMETER['Vertical_Shift',0.0],PARAMETER['Direction',1.0],UNIT['Meter',1.0]];-27386400 -32067900 1000;-100000 1000;0 1;0.01;0.01;0.01;IsHighPrecision"
    mosaic = arcpy.CreateMosaicDataset_management(in_workspace=ws,in_mosaicdataset_name=mosaic_name,coordinate_system=spatial_reference,num_bands="1",pixel_type="32_BIT_FLOAT",product_definition="NONE",product_band_definitions="#")

    #mosaic = os.path.join(ws, sde_file_name)
    # Increase the size of the NAME field
    arcpy.DeleteField_management(mosaic,"NAME")
    arcpy.AddField_management(mosaic, "NAME", "TEXT", "#", "#", "200", "#", "#", "#", "#")

    arcpy.AddField_management(mosaic, "RC_ID_CREATION","LONG","#","#","#","#","NULLABLE","NON_REQUIRED","#")
    arcpy.AddField_management(mosaic, "RANK","LONG","#","#","#","#","NULLABLE","NON_REQUIRED","#")

    arcpy.AddField_management(mosaic, "RC_NAME_CREATION","TEXT","#","#","200","#","NULLABLE","NON_REQUIRED","#")
    arcpy.AddField_management(mosaic, "CREATION_DATE","DATE","#","#","#","#","NULLABLE","NON_REQUIRED","#")

    arcpy.AddField_management(mosaic, "TILING","TEXT","#","#","8","#","NULLABLE","NON_REQUIRED","#")
    arcpy.AddField_management(mosaic, "TILE_INDEX_X","LONG","#","#","#","#","NULLABLE","NON_REQUIRED","#")
    arcpy.AddField_management(mosaic, "TILE_INDEX_Y","LONG","#","#","#","#","NULLABLE","NON_REQUIRED","#")

    #Rasterpath
    arcpy.AddField_management(mosaic, "RASTERPATH","TEXT","#","#",300,"#","NULLABLE","NON_REQUIRED","#")

    arcpy.SetMosaicDatasetProperties_management(in_mosaic_dataset=mosaic,rows_maximum_imagesize="4100",columns_maximum_imagesize="15000", allowed_compressions="None;JPEG;LZ77;LERC", default_compression_type="None",JPEG_quality="75",LERC_Tolerance="0.01",resampling_type="BILINEAR",clip_to_footprints="NOT_CLIP",footprints_may_contain_nodata="FOOTPRINTS_MAY_CONTAIN_NODATA",clip_to_boundary="CLIP",color_correction="NOT_APPLY",allowed_mensuration_capabilities="#",default_mensuration_capabilities="NONE",allowed_mosaic_methods="ByAttribute",default_mosaic_method="ByAttribute",order_field="ZORDER",order_base="0",sorting_order="DESCENDING",mosaic_operator="FIRST",blend_width="#",view_point_x="#",view_point_y="#",max_num_per_mosaic="#",cell_size_tolerance="#",cell_size="0 0",metadata_level="BASIC",transmission_fields="NAME;MINPS;MAXPS;LOWPS;HIGHPS;TAG;GROUPNAME;PRODUCTNAME;CENTERX;CENTERY;ZORDER;RC_ID_CREATION;RC_NAME_CREATION;CREATION_DATE;TILING;RASTERPATH;SHAPE.AREA;SHAPE.LEN",use_time="DISABLED",start_time_field="#",end_time_field="#",time_format="#",geographic_transform="#",max_num_of_download_items="#",max_num_of_records_returned="#",data_source_type="GENERIC",minimum_pixel_contribution="#")

    print('Finished creating mosaic')


if __name__ == '__main__':
    sde_file = sys.argv[1]
    mosaic_name = sys.argv[2]
    create_mosaic(sde_file, mosaic_name)
import os

import arcpy

def copy_data(source_gdb_path: str, target_sde_path:str):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = source_gdb_path

    def copy_esri(entity_type, esri_entity):
        """
        Performs the actual copy of the dataset, feature class etc.
        """
        source_path = os.path.join(arcpy.env.workspace, esri_entity)
        target_path = os.path.join(target_sde_path, esri_entity)

        if arcpy.Exists(target_path):
            print(f'Skipping {entity_type} {source_path} because it already exists')
        else:
            print(f'Copy dataset {source_path} to {target_path}')
            arcpy.management.Copy(source_path, target_path)

    datasets = arcpy.ListDatasets()
    for dataset in datasets:
        copy_esri('feature dataset', dataset)

    feature_classes = arcpy.ListFeatureClasses()
    for feature_class in feature_classes:
        copy_esri('feature class', feature_class)

    tables = arcpy.ListTables()
    for table in tables:
        copy_esri('table', table)


def register_data_as_versioned(sde_file_path, exceptions_list = ()):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path

    if len(exceptions_list) > 0:
        print(f'Except datasets {exceptions_list}')

    def register_as_versioned(esri_entity):
        if dataset in exceptions_list:
            print(f"Dont register as versioned {esri_entity}")
            return

        try:
            arcpy.management.RegisterAsVersioned(os.path.join(sde_file_path, esri_entity), 'NO_EDITS_TO_BASE')
        except arcpy.ExecuteError as e:
            print(e)
            print(f'Skipping {esri_entity}, cannot be verioned.')

    datasets = arcpy.ListDatasets()
    for dataset in datasets:
        register_as_versioned(dataset)

    feature_classes = arcpy.ListFeatureClasses()
    for feature_class in feature_classes:
        register_as_versioned(feature_class)

    tables = arcpy.ListTables()
    for table in tables:
        register_as_versioned(table)


def rebuild_indexes(sde_file_path):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path

    user = arcpy.Describe(sde_file_path).connectionProperties.user
    datasets = arcpy.ListTables(user + "*") + arcpy.ListFeatureClasses(user + "*")
    for dataset in arcpy.ListDatasets(user + "*", "Feature"):
        # This lists feature classes but not relationship classes or topology classes.
        # arcpy.ListDatasets("user" + "*") lists topology classes as well which throws an exception with arcpy.RebuildIndexes_management
        arcpy.env.workspace = os.path.join(sde_file_path, dataset)
        datasets += arcpy.ListFeatureClasses(user + "*")

    # Note: to use the "SYSTEM" option the workspace user must be an administrator.
    arcpy.env.workspace = sde_file_path
    arcpy.RebuildIndexes_management(sde_file_path, "NO_SYSTEM", datasets, "ALL")


def analyze_datasets(sde_file_path):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path

    user = arcpy.Describe(sde_file_path).connectionProperties.user
    datasets = arcpy.ListTables(user + "*") + arcpy.ListFeatureClasses(user + "*")
    for dataset in arcpy.ListDatasets(user + "*", "Feature"):
        arcpy.env.workspace = os.path.join(sde_file_path, dataset)
        # This lists feature classes but not relationship classes or topology classes.
        # arcpy.ListDatasets("user" + "*") lists topology classes as well
        # throws an exception with arcpy.RebuildIndexes_management
        datasets += arcpy.ListFeatureClasses(user + "*")

    # Note: to use the "SYSTEM" option the workspace user must be an administrator.
    arcpy.env.workspace = sde_file_path
    arcpy.AnalyzeDatasets_management(sde_file_path,
                                     "NO_SYSTEM",
                                     datasets,
                                     "ANALYZE_BASE",
                                     "NO_ANALYZE_DELTA",
                                     "NO_ANALYZE_ARCHIVE")


def rebuild_indexes_state_lineage(sde_file_path):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path

    arcpy.RebuildIndexes_management(sde_file_path,
                                    "SYSTEM",
                                    [],
                                    "ALL")

def analyze_state_lineage(sde_file_path):
    arcpy.env.overwriteOutput = True
    arcpy.env.workspace = sde_file_path

    arcpy.AnalyzeDatasets_management(sde_file_path,
                                     "SYSTEM", [],
                                     "NO_ANALYZE_BASE",
                                     "NO_ANALYZE_DELTA",
                                     "NO_ANALYZE_ARCHIVE")
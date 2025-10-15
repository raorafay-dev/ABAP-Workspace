REPORT z_bapi_mat.

*----------------------------------------------------------------------*
* Program: Material Creation using BAPI_MATERIAL_SAVEDATA
* Description: Creates a finished goods material with basic data
*----------------------------------------------------------------------*

DATA: lv_material    TYPE mara-matnr,
      lv_mtart       TYPE mara-mtart VALUE 'FERT',  "Material Type
      lv_mbrsh       TYPE mara-mbrsh VALUE 'M',     "Industry Sector
      lv_plant       TYPE marc-werks VALUE '1000',  "Plant
      lv_storage_loc TYPE mard-lgort VALUE '1001'.  "Storage Location

* BAPI Structures
DATA: ls_headdata    TYPE bapimathead,
      ls_clientdata  TYPE bapi_mara,
      ls_clientdatax TYPE bapi_marax,
      ls_plantdata   TYPE bapi_marc,
      ls_plantdatax  TYPE bapi_marcx,
      ls_storageloc  TYPE bapi_mard,
      ls_storagelocx TYPE bapi_mardx,
      lt_desc        TYPE TABLE OF bapi_makt,
      ls_desc        TYPE bapi_makt,
      lt_return      TYPE TABLE OF bapiret2,
      ls_return      TYPE bapiret2.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  lv_material = 'Z_TEST_MAT_001'.  "Material Number

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  " Fill Header Data
  ls_headdata-material      = lv_material.
  ls_headdata-ind_sector    = lv_mbrsh.
  ls_headdata-matl_type     = lv_mtart.
  ls_headdata-basic_view    = 'X'.

  " Fill Basic Data (Client Level) - No description here
  ls_clientdata-base_uom    = 'EA'.     "Base Unit - Each
  ls_clientdata-matl_group  = '01'.    "Material Group
  " Set flags for fields being populated
  ls_clientdatax-base_uom   = 'X'.
  ls_clientdatax-matl_group = 'X'.

  " Fill Material Description (MAKT table)
  ls_desc-langu = sy-langu.
  ls_desc-matl_desc = 'Test material 001'.
  APPEND ls_desc TO lt_desc.

  " Fill Plant Data - MATERIAL NUMBER IS REQUIRED
  ls_plantdata-plant        = lv_plant.
  ls_plantdata-mrp_type     = 'PD'.     "MRP Type
  ls_plantdata-mrp_ctrler   = '001'.    "MRP Controller
  ls_plantdata-lotsizekey   = 'EX'.     "Lot Size
  ls_plantdata-proc_type    = 'F'.      "Procurement Type (In-house)
  " Set flags for plant data
  ls_plantdatax-plant       = lv_plant.
  ls_plantdatax-mrp_type    = 'X'.
  ls_plantdatax-mrp_ctrler  = 'X'.
  ls_plantdatax-lotsizekey  = 'X'.
  ls_plantdatax-proc_type   = 'X'.

  " Fill Storage Location Data - MATERIAL NUMBER IS REQUIRED
  ls_storageloc-plant       = lv_plant.
  ls_storageloc-stge_loc    = lv_storage_loc.
  " Set flags for storage location
  ls_storagelocx-plant      = lv_plant.
  ls_storagelocx-stge_loc   = lv_storage_loc.

*----------------------------------------------------------------------*
* Call BAPI to Create Material
*----------------------------------------------------------------------*
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = ls_headdata
      clientdata           = ls_clientdata
      clientdatax          = ls_clientdatax
      plantdata            = ls_plantdata
      plantdatax           = ls_plantdatax
      storagelocationdata  = ls_storageloc
      storagelocationdatax = ls_storagelocx
    IMPORTING
      return               = ls_return
    TABLES
      materialdescription  = lt_desc.

*----------------------------------------------------------------------*
* Check Results and Commit
*----------------------------------------------------------------------*
  APPEND ls_return to lt_return.
  WRITE: / ls_return-message.

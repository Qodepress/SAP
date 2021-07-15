*&---------------------------------------------------------------------*
*& Include          ZFI_BDC_KE21N_REF_TOP
*&---------------------------------------------------------------------*

*** Generated data section with specific formatting - DO NOT CHANGE  ***
TYPES: BEGIN OF ty_record,
* data element: RKE_VRGAR
         vrgar         TYPE rke_vrgar,
* data element: DAERF
         budat(010),
* data element: RKE_BELNR
         belnr         TYPE rke_belnr,
* data element: FRWAE
         frwae         TYPE frwae,
* data element:
         value_02(031),
* data element:
         value_05(031),
* data element:
         unit_02(005),
       END OF ty_record.

DATA: lv_budat_int TYPE daerf.

*******************************
* EXCEL FM variable
*******************************
DATA : gv_scol TYPE i VALUE '1',
       gv_srow TYPE i VALUE '1',
       gv_ecol TYPE i VALUE '256',
       gv_erow TYPE i VALUE '65536'.
DATA: gt_tab   TYPE filetable,
      gv_subrc TYPE i.
*----------------------------------------------------------------------*
*   DATA data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   gt_bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA:   gw_bdcdata TYPE bdcdata.
*       messages of call transaction
DATA:   gt_messtab TYPE STANDARD TABLE OF bdcmsgcoll.
DATA:   gw_messtab TYPE bdcmsgcoll.

*******************************
* Internal Tables & Work Areas
*******************************
DATA: gt_upload TYPE STANDARD TABLE OF ty_record.
DATA: gw_upload TYPE  ty_record.

*******************************
* Constants
*******************************
CONSTANTS: gc_tcode(5) TYPE c VALUE 'KE21N'.

*&---------------------------------------------------------------------*
*& Include          ZFI_BDC_KE21N_REF_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_xls_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_xls_data TABLES p_table
                  USING  p_file
                         p_scol
                         p_srow
                         p_ecol
                         p_erow.

  DATA : lt_excel TYPE STANDARD TABLE OF  kcde_cells.
  DATA : lw_excel TYPE kcde_cells.
  DATA : lv_index TYPE i.
  FIELD-SYMBOLS : <fs>.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      filename                = p_file
      i_begin_col             = p_scol
      i_begin_row             = p_srow
      i_end_col               = p_ecol
      i_end_row               = p_erow
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.

  ENDIF.
  IF lt_excel[] IS INITIAL.
***   Shoot Error
  ELSE.
    SORT lt_excel BY row col.
    LOOP AT lt_excel INTO lw_excel.
      IF lw_excel-row EQ 1.
        CONTINUE.
      ENDIF.
      MOVE lw_excel-col TO lv_index.
      ASSIGN COMPONENT lv_index OF STRUCTURE p_table TO <fs>.
      MOVE lw_excel-value TO <fs>.
      AT END OF row.
        APPEND p_table.
        CLEAR p_table.
      ENDAT.

    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_data .
  REFRESH: gt_messtab, gt_bdcdata.
  CLEAR gw_bdcdata.

  IF gt_upload IS NOT INITIAL.

    CLEAR: gw_upload.
    LOOP AT gt_upload INTO gw_upload.

      PERFORM bdc_dynpro      USING 'SAPMKEI2' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'CEST0-BELNR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEXT'.
      PERFORM bdc_field       USING 'CEST1-VRGAR'
                                    gw_upload-vrgar.
      PERFORM bdc_field       USING 'CEST1-BUDAT'
                                    gw_upload-budat.
      PERFORM bdc_field       USING 'RADIOVAL1'
                                    abap_true.
      PERFORM bdc_field       USING 'RADIOCURR1'
                                    space.
      PERFORM bdc_field       USING 'RADIOCURR2'
                                    abap_true.
      PERFORM bdc_field       USING 'CEST0-BELNR'
                                    gw_upload-belnr.
      PERFORM bdc_dynpro      USING 'SAPMKEI2' '0200'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=TAB2'.
      PERFORM bdc_dynpro      USING 'SAPMKEI2' '0200'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEXT'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'GT_LINES_VAL-VALUE(05)'.
      PERFORM bdc_field       USING 'CEST1-FRWAE'
                                    gw_upload-frwae.
      PERFORM bdc_field       USING 'GT_LINES_VAL-VALUE(02)'
                                    gw_upload-value_02.
      PERFORM bdc_field       USING 'GT_LINES_VAL-VALUE(05)'
                                    gw_upload-value_05.
      PERFORM bdc_field       USING 'GT_LINES_VAL-UNIT(02)'
                                    gw_upload-unit_02.
      PERFORM bdc_dynpro      USING 'SAPMKEI2' '0200'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=BUCH'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'GT_LINES_VAL-VALUE(01)'.
      PERFORM bdc_field       USING 'CEST1-FRWAE'
                                    gw_upload-frwae.
      CALL TRANSACTION gc_tcode WITH AUTHORITY-CHECK USING gt_bdcdata
                       MODE   p_mode
                       UPDATE p_update
                       MESSAGES INTO gt_messtab.

      CLEAR: gw_upload.
      REFRESH gt_bdcdata.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_file_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- DATAFILE
*&---------------------------------------------------------------------*
FORM read_file_name  CHANGING VALUE(p_filename).

  REFRESH: gt_tab.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = 'Select File'
      default_filename = '*.xls'
      multiselection   = ' '
    CHANGING
      file_table       = gt_tab
      rc               = gv_subrc.
  LOOP AT gt_tab INTO p_filename.
*    so_fpath-sign = 'I'.
*    so_fpath-option = 'EQ'.
*    append so_fpath.
  ENDLOOP.
ENDFORM.

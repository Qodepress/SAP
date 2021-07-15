*&---------------------------------------------------------------------*
*& Include          ZFI_BDC_KE21N_REF_SUB
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING VALUE(program) VALUE(dynpro).
  CLEAR gw_bdcdata.
  gw_bdcdata-program  = program.
  gw_bdcdata-dynpro   = dynpro.
  gw_bdcdata-dynbegin = 'X'.
  APPEND gw_bdcdata TO gt_bdcdata.
  CLEAR gw_bdcdata.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING VALUE(fnam) VALUE(fval).
  IF fval <> space.
    CLEAR gw_bdcdata.
    gw_bdcdata-fnam = fnam.
    gw_bdcdata-fval = fval.
    APPEND gw_bdcdata TO gt_bdcdata.
    CLEAR gw_bdcdata.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
  DATA lv_title TYPE lvc_title.

  IF  gt_messtab IS NOT INITIAL.
    lv_title = 'Display Msg for upload'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_grid_title          = lv_title
        i_structure_name      = 'BDCMSGCOLL'
        i_screen_start_column = 10
        i_screen_start_line   = 20
        i_screen_end_column   = 100
        i_screen_end_line     = 40
      TABLES
        t_outtab              = gt_messtab.

    IF sy-subrc <> 0.
*********** Error Logic Here
    ENDIF.
  ENDIF.
ENDFORM.

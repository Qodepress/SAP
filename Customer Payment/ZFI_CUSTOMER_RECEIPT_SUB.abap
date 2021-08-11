*&---------------------------------------------------------------------*
*& Include          ZFI_CUSTOMER_RECEIPT_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
  PERFORM alv_fcat.
  PERFORM alv_top_of_page.
  PERFORM alv_options.
  PERFORM alv USING gt_input.
ENDFORM.
FORM build_catalog USING VALUE(fieldname)
                         VALUE(ref_tabname)
                         VALUE(ref_fieldname)
                         VALUE(seltext_m).
  col = col + 1.
  gwa_fieldcatalog-col_pos        = col.
  gwa_fieldcatalog-fieldname      = fieldname.
  gwa_fieldcatalog-ref_tabname    = ref_tabname.
  gwa_fieldcatalog-ref_fieldname  = ref_fieldname.
  gwa_fieldcatalog-seltext_m      = seltext_m.

  APPEND gwa_fieldcatalog TO gt_fieldcatalog.
  CLEAR gwa_fieldcatalog.
ENDFORM.
FORM alv_options.
  is_layout-colwidth_optimize = abap_true.
  is_layout-info_fieldname = 'ROWCOLOR'.
*  is_layout-box_fieldname = 'SEL'.
*  is_layout-zebra = 'X'.
  gv_repid = sy-repid.
ENDFORM.
FORM alv USING table TYPE STANDARD TABLE.
*  PF-Status: SAPLSALV - Standard
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = gc_pf_status
      i_callback_user_command  = gc_ucommand
      is_layout                = is_layout
      it_fieldcat              = gt_fieldcatalog
      it_events                = gt_events
    TABLES
      t_outtab                 = table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e002(zfiac) DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM PFSTATUS                                            *
*---------------------------------------------------------------------*
*Form for settings the pf status to the alv
FORM zstandard USING ut_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  read_file_name
*&---------------------------------------------------------------------*
FORM read_file_name CHANGING p_filepath.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 100
      text       = 'Customer Payment'.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
    IMPORTING
      file_name     = p_filepath.
ENDFORM.                    " read_file_name
*&---------------------------------------------------------------------*
*& Form read_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_file USING p_filepath.
  DATA: lv_filename  LIKE  rlgrap-filename,
        lv_separator TYPE  c,
        lt_input     TYPE  kcde_intern,
        lw_input     TYPE  LINE OF kcde_intern,
        lv_index     TYPE i.

  CONSTANTS: lc_gb(4) TYPE c VALUE 'C111'.
  CONSTANTS: lc_lg(4) TYPE c VALUE 'C211'.
  CONSTANTS: lc_ye(4) TYPE c VALUE 'C311'.
  CONSTANTS: lc_bg(4) TYPE c VALUE 'C411'.
  CONSTANTS: lc_gr(4) TYPE c VALUE 'C511'.
  CONSTANTS: lc_rd(4) TYPE c VALUE 'C611'.
  CONSTANTS: lc_do(4) TYPE c VALUE 'C711'.

  CONSTANTS: pipe TYPE c VALUE '|'.

  FIELD-SYMBOLS: <output> TYPE any.
  MOVE p_filepath TO lv_filename.
  CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
    EXPORTING
      i_filename      = lv_filename
      i_separator     = pipe
    TABLES
      e_intern        = lt_input[]
    EXCEPTIONS
      upload_csv      = 1
      upload_filetype = 2
      OTHERS          = 3.

  IF sy-subrc = 0.
* Implement suitable error handling here
    CLEAR: gw_input, lw_input.
    LOOP AT lt_input INTO lw_input.
      MOVE : lw_input-col TO lv_index.
      ASSIGN COMPONENT lv_index OF STRUCTURE gw_input TO <output>.
      MOVE : lw_input-value TO <output>.
      AT END OF row.
        APPEND gw_input TO gt_input.
        CLEAR: gw_input, lw_input.
      ENDAT.
    ENDLOOP.

*************************COLOR
*1  C111      Grey Blue - lc_gb
*2  C211      Light Grey - lc_lg
*3  C311      Yellow - lc_ye
*4  C411      Blue Green - lc_bg
*5  C511      Green - lc_gr
*6  C611      Red - lc_rd
*7  C711      Dull Orange lc_do
******************************
***********Color Coding - Heading
    CLEAR: gw_input.
    LOOP AT gt_input INTO gw_input WHERE field_1 = gc_ph.
      gw_input-rowcolor = lc_ye.
      MODIFY gt_input FROM gw_input TRANSPORTING rowcolor.
      CLEAR: gw_input.
    ENDLOOP.

***********Color Coding - Items
    CLEAR: gw_input.
    LOOP AT gt_input INTO gw_input WHERE field_1 = gc_pd.
      gw_input-rowcolor = lc_gb.
      MODIFY gt_input FROM gw_input TRANSPORTING rowcolor.
      CLEAR: gw_input.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form alV_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_top_of_page .
  gw_events-name = slis_ev_top_of_page.
  gw_events-form = 'TOP_OF_PAGE'.
  APPEND gw_events TO gt_events.
  CLEAR gw_events .
ENDFORM.
FORM build_top_of_page USING typ TYPE c
                             info TYPE slis_entry.

  gw_htop-typ = typ .
  gw_htop-info = info .
  APPEND gw_htop TO gt_ttop .
  CLEAR gw_htop .

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_ttop
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*
*     I_ALV_FORM         =
    .
ENDFORM.
FORM pop_list_display USING gw_input TYPE ty_input.
  DATA lt_show_msg LIKE gt_error.
  DATA lw_show_msg LIKE gw_error.

  PERFORM process_data USING space CHANGING gw_input.

  IF gt_return IS NOT INITIAL.
    DATA lv_title TYPE lvc_title.
    IF gw_input-field_1 EQ gc_ph.
      CONCATENATE 'Return Message for :' gw_input-field_7 INTO lv_title SEPARATED BY space.
      PERFORM build_show_msg USING gw_input-field_7 CHANGING lt_show_msg.
    ELSE.
      CONCATENATE 'Return Message for :' gw_input-field_2 INTO lv_title SEPARATED BY space.
      PERFORM build_show_msg USING gw_input-field_2 CHANGING lt_show_msg.
    ENDIF.
    SORT lt_show_msg BY message.
    DELETE ADJACENT DUPLICATES FROM lt_show_msg COMPARING ALL FIELDS.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_grid_title          = lv_title
        i_structure_name      = 'ZBAPIRET2'
        i_screen_start_column = 10
        i_screen_start_line   = 20
        i_screen_end_column   = 100
        i_screen_end_line     = 40
      TABLES
        t_outtab              = lt_show_msg.

    IF sy-subrc <> 0.
      MESSAGE e003(zfiac) DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.
FORM build_show_msg USING VALUE(p_doc) CHANGING lt_show_msg LIKE gt_error.
  DATA lw_show_msg LIKE gw_error.

  CLEAR: gw_error, lw_show_msg.
  LOOP AT gt_error INTO gw_error WHERE doc_no EQ p_doc.
    MOVE-CORRESPONDING gw_error TO lw_show_msg.
    APPEND lw_show_msg TO lt_show_msg.
    CLEAR: gw_error, lw_show_msg.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_iban_details
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_iban_details USING VALUE(iban) CHANGING gw_zarvatobank TYPE zarvatobank.
  CLEAR: gw_zarvatobank.
  SELECT iban
         bukrs
         bankn
         prctr
         hktid
         incm_gl
         special_gl
         discount_gl
         nuz_acc
    INTO CORRESPONDING FIELDS OF gw_zarvatobank
    UP TO 1 ROWS
    FROM zarvatobank
    WHERE iban = iban  ORDER BY PRIMARY KEY.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form Build_msg
*&---------------------------------------------------------------------*
*ICON_4 ICON_MESSAGE_INFORMATION       '@19@'."  Information message
*ICON_4 ICON_MESSAGE_WARNING           '@1A@'."  Warning
*ICON_4 ICON_MESSAGE_ERROR             '@1B@'."  Error message
*ICON_2 ICON_ACTION_FAULT              '@9O@'."  Incorrect request
*ICON_2 ICON_ACTION_SUCCESS            '@9P@'."  Request successful
*&---------------------------------------------------------------------*
FORM build_msg USING VALUE(p_fromret)
                     VALUE(p_doc)
                     VALUE(p_type)
                     VALUE(p_message)
                     VALUE(p_message_v1)
                     VALUE(p_message_v2)
                     VALUE(p_message_v3)
                     VALUE(p_message_v4).

  CLEAR gw_error.
  IF p_fromret EQ abap_true.
    CLEAR: gw_return, gw_error.
    IF gt_return IS NOT INITIAL.
      DELETE gt_return WHERE type IS INITIAL
                         AND message IS INITIAL
                         AND message_v1 IS INITIAL
                         AND message_v2 IS INITIAL
                         AND message_v3 IS INITIAL
                         AND message_v4 IS INITIAL.

      LOOP AT gt_return INTO gw_return.
        PERFORM set_msg USING p_doc
                              gw_return-type
                              gw_return-message
                              gw_return-message_v1
                              gw_return-message_v2
                              gw_return-message_v3
                              gw_return-message_v4.
      ENDLOOP.
    ENDIF.
  ELSE.
    PERFORM set_msg USING p_doc
                          p_type
                          p_message
                          p_message_v1
                          p_message_v2
                          p_message_v3
                          p_message_v4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_msg_status
*&---------------------------------------------------------------------*
*ICON_4 ICON_MESSAGE_INFORMATION       '@19@'."  Information message
*ICON_4 ICON_MESSAGE_WARNING           '@1A@'."  Warning
*ICON_4 ICON_MESSAGE_ERROR             '@1B@'."  Error message
*ICON_2 ICON_ACTION_FAULT              '@9O@'."  Incorrect request
*ICON_2 ICON_ACTION_SUCCESS            '@9P@'."  Request successful
*&---------------------------------------------------------------------*
FORM set_msg_status USING VALUE(p_type) CHANGING VALUE(status).
  CONSTANTS: lc_info(4) TYPE c VALUE '@19@'.
  CONSTANTS: lc_warn(4) TYPE c VALUE '@1A@'.
  CONSTANTS: lc_errr(4) TYPE c VALUE '@1B@'.
  CONSTANTS: lc_sucs(4) TYPE c VALUE '@9P@'.

  CASE: p_type.
    WHEN 'I'.
      status = lc_info.
    WHEN 'W'.
      status = lc_warn.
    WHEN 'E'.
      status = lc_errr.
    WHEN OTHERS.
      status = lc_sucs.
  ENDCASE.
ENDFORM.
FORM set_msg USING VALUE(p_doc)
                   VALUE(p_type)
                   VALUE(p_message)
                   VALUE(p_message_v1)
                   VALUE(p_message_v2)
                   VALUE(p_message_v3)
                   VALUE(p_message_v4).
  IF p_type IS NOT INITIAL
    AND p_message IS NOT INITIAL.
    PERFORM set_msg_status USING p_type CHANGING gw_error-icon.
    MOVE p_type TO gw_error-type.
    MOVE p_doc TO gw_error-doc_no.
    MOVE p_message TO gw_error-message.
    MOVE p_message_v1 TO gw_error-message_v1.
    MOVE p_message_v2 TO gw_error-message_v2.
    MOVE p_message_v3 TO gw_error-message_v3.
    MOVE p_message_v4 TO gw_error-message_v4.
    APPEND gw_error TO gt_error.
    CLEAR: gw_error, gw_return.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_gl_account
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_ZARVATOBANK_BUKRS
*&      --> GW_ZARVATOBANK_BANKN
*&      --> GC_ACCOUNT_ID
*&      <-- LV_HKONT
*&---------------------------------------------------------------------*
FORM get_gl_account  USING    VALUE(p_bukrs)
                              VALUE(p_bankn)
                              VALUE(p_accid)
                     CHANGING VALUE(p_hkont).
  SELECT hkont
    INTO p_hkont
    UP TO 1 ROWS
    FROM t012k
    WHERE bukrs = p_bukrs
      AND bankn = p_bankn
      AND hktid = p_accid
      ORDER BY PRIMARY KEY.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_taxcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_ITEM_XBLNR
*&      <-- LV_MWSKZ
*&---------------------------------------------------------------------*
FORM get_origin_doc_data  USING   VALUE(p_doc)
                                  VALUE(p_company)
                                  VALUE(p_xblnr)
                         CHANGING gw_acdoca.


  CONSTANTS: lc_rev TYPE acdoca-linetype VALUE '30000'.
  CONSTANTS: lc_bschl TYPE acdoca-bschl VALUE '50'.
  CONSTANTS: lc_docty TYPE bkpf-blart VALUE 'RV'.

  DATA lv_belnr TYPE belnr_d.
  DATA p_fiscalyr TYPE gjahr.
  p_fiscalyr = sy-datum+0(4).

  SELECT belnr
    INTO lv_belnr
    UP TO 1 ROWS
    FROM bkpf
    WHERE bukrs = p_company
      AND gjahr = p_fiscalyr
      AND xblnr = p_xblnr
      AND blart = lc_docty
      ORDER BY PRIMARY KEY.


    IF sy-subrc EQ 0.
      SELECT mwskz prctr paobjnr       "#EC CI_DB_OPERATION_OK[2431747]
        kunnr
        matnr_pa
        kunwe
        fkart
        kdauf
        kdpos
        rbukrs
        werks
        segment
        vkorg
        vtweg
        spart
        prctr
        crmfigr_pa
        kmland_pa
        kmmakl_pa
        kmvkgr_pa
        partner_pa
        prodh_pa
        crmcsty_pa
        crmelem_pa
        cityc_pa
        counc_pa
        ktokd_pa
        mtart_pa
        paph1_pa
        paph2_pa
        paph3_pa
        xcpdk_pa
        matnr_pa
        paph4_pa
        paph5_pa
        mvgr1_pa
        mvgr2_pa
        mvgr3_pa
        mvgr4_pa
        mvgr5_pa
        wwcou_pa
        wwddc_pa
        zzsem_pa
        INTO CORRESPONDING FIELDS OF gw_acdoca
        UP TO 1 ROWS
        FROM acdoca
        WHERE rbukrs = p_company
          AND belnr = lv_belnr
          AND gjahr = p_fiscalyr
          AND linetype = lc_rev
          AND bschl = lc_bschl
          ORDER BY PRIMARY KEY.
      ENDSELECT.
    ENDIF.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_costcenter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_ZARVATOBANK_BUKRS
*&      --> LC_DISCGL
*&      --> GW_ZARVATOBANK_PRCTR
*&      <-- LV_KOSTL
*&---------------------------------------------------------------------*
FORM get_costcenter  USING    VALUE(p_bukrs)
                              VALUE(p_discgl)
                              VALUE(p_prctr)
                     CHANGING VALUE(p_kostl).

  DATA: lv_kstar TYPE kstar.
  MOVE: p_discgl TO lv_kstar.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_discgl
    IMPORTING
      output = lv_kstar.

  SELECT kostl
    INTO p_kostl
    UP TO 1 ROWS
    FROM tka3p
    WHERE bukrs = p_bukrs
      AND kstar = lv_kstar
      AND prctr = p_prctr
      ORDER BY PRIMARY KEY.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_customer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_HEAD_KUNNR
*&      <-- LV_KUNNR
*&---------------------------------------------------------------------*
FORM get_customer  USING    VALUE(p_doc)
                            VALUE(p_ackunnr)
                   CHANGING VALUE(p_kunnr)
                            VALUE(p_name1).


  SELECT partner                                        "#EC CI_NOFIELD
    INTO p_kunnr
    UP TO 1 ROWS
    FROM but000
    WHERE bu_sort2 = p_ackunnr
      ORDER BY PRIMARY KEY.

    IF sy-subrc EQ 0.
      SELECT name1                                      "#EC CI_NOFIELD
        INTO p_name1
        UP TO 1 ROWS
        FROM kna1
        WHERE kunnr = p_kunnr
        ORDER BY PRIMARY KEY.
      ENDSELECT.
    ELSE.
      IF p_kunnr IS INITIAL.
***** build error output
        PERFORM build_msg USING space
                                p_doc
                                'E'
                                TEXT-002
                                space
                                space
                                space
                                space.
      ENDIF.
    ENDIF.
  ENDSELECT.


ENDFORM.

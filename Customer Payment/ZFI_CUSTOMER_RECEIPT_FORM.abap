*&---------------------------------------------------------------------*
*& Include          ZFI_CUSTOMER_RECEIPT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data USING VALUE(p_commit) CHANGING gw_line TYPE ty_input.
  DATA line_cnt TYPE n VALUE 1.
  DATA header_txt TYPE bktxt.
  DATA lv_paobjnr TYPE acdoca-paobjnr.
  DATA lv_hkont TYPE hkont.
  DATA lv_mwskz TYPE mwskz.
  DATA lv_kostl TYPE kostl.
  DATA lv_kunnr TYPE kunnr.
  DATA lv_name1 TYPE kna1-name1.
  DATA lv_prctr TYPE prctr.
  DATA lv_tabix TYPE sy-tabix.
  DATA lv_tabii TYPE sy-tabix.

  CONSTANTS: lc_strctrnm1 TYPE te_struc VALUE 'POSTING_KEY',
             lc_strctrnm2 TYPE te_struc VALUE 'PSG_SEG',
             lc_pstky     TYPE valuepart VALUE '15',
             lc_docty     TYPE valuepart VALUE 'DZ'.

  DATA lt_item LIKE gt_item.
  DATA lt_head LIKE gt_head.

  lt_head = gt_head.
  lt_item = gt_item.

*  7/2
  IF gw_line IS NOT INITIAL.
    IF gw_line-field_1 EQ gc_ph.
      DELETE lt_head WHERE doc_number NE gw_line-field_7.
      DELETE lt_item WHERE doc_number NE gw_line-field_7.
    ENDIF.
    IF gw_line-field_1 EQ gc_pd.
      DELETE lt_head WHERE doc_number NE gw_line-field_2.
      DELETE lt_item WHERE doc_number NE gw_line-field_2.
    ENDIF.
  ENDIF.

  CLEAR: gw_head, gw_item.
  SORT lt_head BY doc_number DESCENDING.
  LOOP AT lt_head INTO gw_head.
    lv_tabii = sy-tabix.
    SORT lt_item BY doc_number DESCENDING.
    LOOP AT lt_item INTO gw_item WHERE doc_number = gw_head-doc_number.
      lv_tabix = sy-tabix.
      AT NEW doc_number. " @will only be Entered once for all now line items. [START AT]

        CLEAR: gw_header, line_cnt, gw_acdoca.
        line_cnt = 1.
        REFRESH: gt_accountgl,
                 gt_accountrcv,
                 gt_accounttax,
                 gt_currencyamount,
                 gt_criteria,
                 gt_extension2,
                 gt_return.

        READ TABLE gt_item INTO gw_item INDEX lv_tabix.
        READ TABLE gt_head INTO gw_head INDEX lv_tabii.
        PERFORM get_iban_details USING gw_head-iban CHANGING gw_zarvatobank.
        PERFORM convert_to_internal USING gw_zarvatobank-discount_gl gw_zarvatobank-discount_gl.
        PERFORM convert_to_internal USING gw_zarvatobank-incm_gl gw_zarvatobank-incm_gl.

        IF gw_zarvatobank IS NOT INITIAL.
          PERFORM get_gl_account USING gw_zarvatobank-bukrs gw_zarvatobank-bankn gw_zarvatobank-hktid CHANGING lv_hkont.
          PERFORM get_customer   USING gw_head-doc_number gw_head-kunnr CHANGING lv_kunnr lv_name1.
          IF gw_head-tax_amt NE 0.
            PERFORM  get_origin_doc_data  USING gw_head-doc_number gw_zarvatobank-bukrs gw_item-xblnr CHANGING gw_acdoca.
            lv_mwskz   = gw_acdoca-mwskz.
            lv_prctr   = gw_acdoca-prctr.
            lv_paobjnr = gw_acdoca-paobjnr.
            IF lv_prctr IS INITIAL
              AND gw_zarvatobank-prctr IS NOT INITIAL.
              MOVE gw_zarvatobank-prctr TO lv_prctr.
            ENDIF.
          ENDIF.
          PERFORM get_costcenter USING gw_zarvatobank-bukrs gw_zarvatobank-discount_gl lv_prctr CHANGING lv_kostl.
        ENDIF.
        CONCATENATE gw_head-blart gw_item-xblnr gw_head-kunnr INTO header_txt.
        PERFORM validation USING gw_head gw_item gw_zarvatobank.
        PERFORM convert_to_internal USING lv_kunnr lv_kunnr.

**************************************
** HEADER ENTRY
**************************************
********* Set Document Header
        PERFORM set_doc_headr USING gw_zarvatobank-bukrs "Company Code
                                    lc_docty             "Document Type
                                    gw_head-budat        "Document Date
                                    header_txt           "Header Text
                                    gw_item-xblnr.       "Arvato Document Number

**************************************
** ITEM ENTRY
**************************************
**************************************
** Line Item 1 Entry
**************************************
********** Set Document Items
        IF gw_item-xblnr IS INITIAL.
          MOVE gw_zarvatobank-prctr TO lv_prctr.
        ENDIF.

        PERFORM set_gl USING line_cnt               "Item number
                             gw_zarvatobank-incm_gl "GL Account
                             gw_zarvatobank-bukrs   "Company code
                             lc_docty               "Document Type
                             space                  "Tax Code
                             lv_name1                "Item Text
                             lv_prctr               "profit center
                             space.                 "Cost Center

********** Set Document Currency
        PERFORM set_currency USING line_cnt             "Item Number
                                   gw_head-waers        "Currency
                                   gw_item-pay_amt      "Payment amount
                                   space.               "Base Amount

      ENDAT.  " @will only be Entered once for all now line items. [END AT]
**************************************
** Line Item 2 Entry if Discount
**************************************
      IF gw_item-cash_disc IS NOT INITIAL.

        IF gw_item-xblnr IS INITIAL.
          MOVE gw_zarvatobank-prctr TO lv_prctr.
        ENDIF.
        PERFORM  get_origin_doc_data  USING gw_head-doc_number gw_zarvatobank-bukrs gw_item-xblnr CHANGING gw_acdoca.
        lv_mwskz   = gw_acdoca-mwskz.
        lv_prctr   = gw_acdoca-prctr.
        lv_paobjnr = gw_acdoca-paobjnr.

        line_cnt = line_cnt + 1.
********** Set Document Items
        PERFORM set_gl USING line_cnt                                "Item number
                             gw_zarvatobank-discount_gl              "GL Account
                             gw_zarvatobank-bukrs                    "Company code
                             lc_docty                                "Document Type
                             lv_mwskz                                "Tax Code
                             lv_name1                                "Item Text
                             lv_prctr                                "profit center
                             space.                                  "Cost Center

********** Copy Profitibility Segment
        PERFORM set_extensions USING lc_strctrnm2      "Structure Name
                                     line_cnt          "Value Part 1
                                     lv_paobjnr        "Value Part 2
                                     space             "Value Part 3
                                     space.            "Value Part 4

********** Set Document Currency
        PERFORM set_currency USING line_cnt             "Item Number
                                   gw_head-waers        "Currency
                                   gw_item-cash_disc    "Discount amount
                                   space.               "Base Amount

********************************** LACC9F20
        PERFORM get_set_psg USING:
                  line_cnt 'KNDNR'    gw_acdoca-kunnr,
                  line_cnt 'ARTNR'    gw_acdoca-matnr_pa,
                  line_cnt 'KUNWE'    gw_acdoca-kunwe,
                  line_cnt 'FKART'    gw_acdoca-fkart,
                  line_cnt 'KAUFN'    gw_acdoca-kdauf,
                  line_cnt 'KDPOS'    gw_acdoca-kdpos,
                  line_cnt 'COUNC'    gw_acdoca-rbukrs,
                  line_cnt 'WERKS'    gw_acdoca-werks,
                  line_cnt 'SEGMENT'  gw_acdoca-segment,
                  line_cnt 'VKORG'    gw_acdoca-vkorg,
                  line_cnt 'VTWEG'    gw_acdoca-vtweg,
                  line_cnt 'SPART'    gw_acdoca-spart,
                  line_cnt 'PRCTR'    gw_acdoca-prctr,
                  line_cnt 'KMLAND'   gw_acdoca-kmland_pa,
                  line_cnt 'KMMAKL'   gw_acdoca-kmmakl_pa,
                  line_cnt 'VKGRP'    gw_acdoca-kmvkgr_pa,
                  line_cnt 'PARTNER'  gw_acdoca-partner_pa,
                  line_cnt 'PRODH'    gw_acdoca-prodh_pa,
                  line_cnt 'CRMCSTY'  gw_acdoca-crmcsty_pa,
                  line_cnt 'CRMELEM'  gw_acdoca-crmelem_pa,
                  line_cnt 'CITYC'    gw_acdoca-cityc_pa,
                  line_cnt 'COUNC'    gw_acdoca-counc_pa,
                  line_cnt 'KTOKD'    gw_acdoca-ktokd_pa,
                  line_cnt 'MTART'    gw_acdoca-mtart_pa,
                  line_cnt 'PAPH1'    gw_acdoca-paph1_pa,
                  line_cnt 'PAPH2'    gw_acdoca-paph2_pa,
                  line_cnt 'PAPH3'    gw_acdoca-paph3_pa,
                  line_cnt 'XCPDK'    gw_acdoca-xcpdk_pa,
                  line_cnt 'MATNR'    gw_acdoca-matnr_pa,
                  line_cnt 'PAPH1'    gw_acdoca-paph4_pa,
                  line_cnt 'PAPH5'    gw_acdoca-paph5_pa,
                  line_cnt 'MVGR1'    gw_acdoca-mvgr1_pa,
                  line_cnt 'MVGR2'    gw_acdoca-mvgr2_pa,
                  line_cnt 'MVGR3'    gw_acdoca-mvgr3_pa,
                  line_cnt 'MVGR4'    gw_acdoca-mvgr4_pa,
                  line_cnt 'MVGR5'    gw_acdoca-mvgr5_pa,
                  line_cnt 'WWCOU'    gw_acdoca-wwcou_pa,
                  line_cnt 'WWDDC'    gw_acdoca-wwddc_pa,
                  line_cnt 'ZZSEM'    gw_acdoca-zzsem_pa.
      ENDIF.

**************************************
** Line Item 3 Entry if Discount
** Line Item 2 Entry if no Discount
**************************************
      line_cnt = line_cnt + 1.
********** Set Account Recievable
      DATA lv_gl_ind TYPE umskz.
      DATA lvp_mwskz TYPE mwskz.

****************** Add Special GL for Advance or Not NUZ Account
      IF gw_item-xblnr IS INITIAL AND  gw_zarvatobank-nuz_acc IS INITIAL.
        lv_gl_ind = gw_zarvatobank-special_gl.
        MOVE gw_zarvatobank-prctr TO lv_prctr.
      ELSE.
****************** Else Remove It.
        lv_gl_ind = space.
      ENDIF.

      IF gw_item-cash_disc IS INITIAL.
        lvp_mwskz = space.
      ELSE.
        lvp_mwskz = lv_mwskz.
      ENDIF.

      PERFORM set_accountrcv USING line_cnt              "Item Number
                                   lv_kunnr              "Customer
                                   gw_zarvatobank-bukrs  "Company Code
                                   lvp_mwskz             "Tax Code
                                   lv_name1              "Item Text
                                   gw_item-xblnr         "Assignment Number
                                   lv_gl_ind.            "Special GL Indicator

      gw_item-inv_amt = gw_item-inv_amt * -1.
********** Set Document Currency
      PERFORM set_currency USING line_cnt             "Item Number
                                 gw_head-waers        "Currency
                                 gw_item-inv_amt      "Invoice amount
                                 space.               "Base Amount

********** Extension to Set Posting Key to 15
      IF gw_item-xblnr IS NOT INITIAL.
        PERFORM set_extensions USING lc_strctrnm1       "Structure Name
                                     line_cnt          "Value Part 1
                                     lc_pstky          "Value Part 2
                                     space             "Value Part 3
                                     space.            "Value Part 4
      ENDIF.

**************************************
** Line Item 4 Entry if Discount
**************************************
      IF gw_item-cash_disc IS NOT INITIAL.
        line_cnt = line_cnt + 1.
********* Calculate Tax
        PERFORM calculate_tax USING gw_zarvatobank-bukrs    "Company code
                                    gw_head-waers           "Currency
                                    gw_item-cash_disc       "Amount               "#EC CI_FLDEXT_OK[2610650]
                                    lv_mwskz                "Tax Code
                              CHANGING gw_mwdat.

        PERFORM set_tax USING line_cnt                       "Item Numner
                              gw_mwdat-hkont                 "GL Account
                              gw_mwdat-ktosl                 "Account Key
                              gw_mwdat-kschl                 "Condition Key
                              lv_mwskz.                      "Tax Code

********** Set Document Currency
        PERFORM set_currency USING line_cnt             "Item Number
                                   gw_head-waers        "Currency                 "#EC CI_FLDEXT_OK[2610650]
                                   gw_mwdat-wmwst       "Invoice amount           "#EC CI_FLDEXT_OK[2610650]
                                   gw_mwdat-kawrt.      "Base Amount
      ENDIF.

      AT END OF doc_number.

        IF p_commit NE abap_true.
***   Check the parking document
          PERFORM check_document USING: gw_header
                                        gt_accountgl  "#EC CI_FLDEXT_OK
                                        gt_accountrcv
                                        gt_accounttax
                                        gt_currencyamount
                                        gt_criteria
                                        gt_extension2
                               CHANGING gt_return.

          IF gw_line IS NOT INITIAL.
            EXIT.
          ENDIF.

***** Build error output
          PERFORM build_msg USING abap_true
                                  gw_head-doc_number
                                  space
                                  space
                                  space
                                  space
                                  space
                                  space.

          CLEAR gw_error.
          IF gt_error IS NOT INITIAL.
            READ TABLE gt_error INTO gw_error WITH KEY type = 'S'.
            IF gw_error IS NOT INITIAL.
              "Success
              PERFORM set_document_processing_status USING 'S' gw_item-doc_number.
            ENDIF.
            CLEAR gw_error.

            READ TABLE gt_error INTO gw_error WITH KEY type = 'E'.
            IF gw_error IS NOT INITIAL.
              "Set Error
              PERFORM set_document_processing_status USING 'E' gw_item-doc_number.
            ENDIF.
            CLEAR gw_error.
          ENDIF.

          PERFORM set_document_company_code USING gw_item-doc_number  gw_zarvatobank-bukrs.
          PERFORM set_document_tax_code USING gw_item-doc_number lv_mwskz.


        ELSE.
***     Park Document with Commit
          PERFORM park_document USING: gw_header
                                       gt_accountgl   "#EC CI_FLDEXT_OK
                                       gt_accountrcv
                                       gt_accounttax
                                       gt_currencyamount
                                       gt_criteria
                                       gt_extension2
                              CHANGING gt_return.
        ENDIF.
      ENDAT.
      CLEAR: gw_item.
    ENDLOOP.
    CLEAR: gw_head.
  ENDLOOP.


*  Leave the program once he file is commited to park.
  IF p_commit EQ abap_true.
    IF sy-subrc <> 0.
      MESSAGE e005(zfiac) DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE s004(zfiac) DISPLAY LIKE 'I' WITH gv_total_doc.
      CALL TRANSACTION sy-tcode.
*       LEAVE TO SCREEN 1000.
      LEAVE PROGRAM.
*       LEAVE TO LIST-PROCESSING.
    ENDIF.
  ENDIF.
ENDFORM.
*&-gw_--------------------------------------------------------------------*
*& Form alv_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_fcat .
  PERFORM build_catalog USING:
         'ICON'       space space     'Status',
         'BUKRS'      space space     'Company Code',
         'MWSKZ'      space space     'Tax Code',
         'FIELD_1'    space space     'Header/Details',
         'FIELD_2'    space space     'Date/Doc No.',
         'FIELD_3'    space space     'Customer/Inv.Ref.No',
         'FIELD_4'    space space     'Payment Amount',
         'FIELD_5'    space space     'Currency/Ex.Rate',
         'FIELD_6'    space space     'IBAN Account',
         'FIELD_7'    space space     'Doc No./Cash Disc.',
         'FIELD_8'    space space     'Doc Type/Calc. Info',
         'FIELD_9'    space space     'Ex.Rate',
         'FIELD_10'   space space     'Base Amount',
         'FIELD_11'   space space     'Bank Fee',
         'FIELD_12'   space space     'Bank Fee EUR',
         'FIELD_13'   space space     'Tax Amount'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_structure
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_split .
  IF gt_input[] IS NOT INITIAL.
    CLEAR: gw_input.
    LOOP AT gt_input INTO gw_input.
      CASE gw_input-field_1.
        WHEN gc_ph.
          MOVE gw_input-field_1 TO gw_head-hheader.
          MOVE gw_input-field_2 TO gw_head-budat.
          MOVE gw_input-field_3 TO gw_head-kunnr.
          MOVE gw_input-field_4 TO gw_head-amount.
          MOVE gw_input-field_5 TO gw_head-waers.
          MOVE gw_input-field_6 TO gw_head-iban.
          MOVE gw_input-field_7 TO gw_head-doc_number.
          MOVE gw_input-field_8 TO gw_head-blart.
          MOVE gw_input-field_9 TO gw_head-kursf.
          MOVE gw_input-field_10 TO gw_head-base_amt.
          MOVE gw_input-field_11 TO gw_head-bank_fee.
          MOVE gw_input-field_12 TO gw_head-bank_free_eu.
          MOVE gw_input-field_13 TO gw_head-tax_amt.

          APPEND gw_head TO gt_head.
          CLEAR gw_head.
        WHEN gc_pd.
          MOVE gw_input-field_1 TO gw_item-iheader.
          MOVE gw_input-field_2 TO gw_item-doc_number.
          MOVE gw_input-field_3 TO gw_item-xblnr. "#EC CI_FLDEXT_OK[2610650]
          MOVE gw_input-field_4 TO gw_item-pay_amt. "#EC CI_FLDEXT_OK[2610650]
          MOVE gw_input-field_5 TO gw_item-kursf_inv.
          MOVE gw_input-field_6 TO gw_item-inv_amt. "#EC CI_FLDEXT_OK[2610650]
          MOVE gw_input-field_7 TO gw_item-cash_disc. "#EC CI_FLDEXT_OK[2610650]
          MOVE gw_input-field_8 TO gw_item-cal_info. "#EC CI_FLDEXT_OK[2610650]

          APPEND gw_item TO gt_item.
          CLEAR gw_item.
      ENDCASE.
      CLEAR: gw_input.
    ENDLOOP.
  ENDIF.
ENDFORM.
FORM top_of_page.
  REFRESH: gt_ttop.

  DATA: lv_total_doc(5) TYPE c.
  DATA: lv_total_err(5) TYPE c VALUE 0.
  DATA: lv_msg1 TYPE slis_entry.
  DATA: lv_msg2 TYPE slis_entry.
  DATA: lv_msg3 TYPE slis_entry.

  DATA lt_input LIKE gt_input.
  DATA lt_error LIKE gt_error.

  lt_input = gt_input.
  lt_error = gt_error.

************ Get total document count
  DELETE lt_input WHERE field_1 EQ gc_pd.
  DESCRIBE TABLE lt_input LINES lv_total_doc.
  CONCATENATE 'Total Documents:' lv_total_doc INTO lv_msg1 SEPARATED BY space.
  gv_total_doc = lv_total_doc.

************ Get total error count
  DELETE lt_error WHERE type EQ 'S'.
  IF lt_error IS NOT INITIAL.
    SORT lt_error BY message.
    DELETE ADJACENT DUPLICATES FROM lt_error COMPARING message.
    DESCRIBE TABLE lt_error LINES lv_total_err.
    CONCATENATE 'Error Found:' lv_total_err INTO lv_msg2 SEPARATED BY space.
    lv_msg3 = 'Posting Not Possible'.
  ELSE.
    CONCATENATE 'Error Found:' lv_total_err INTO lv_msg2 SEPARATED BY space.
    lv_msg3 = 'Posting Possible'.
  ENDIF.

************ Get total count

  PERFORM build_top_of_page USING:
        'H' 'Arvato Customer Payment',
        'S' lv_msg1,
        'S' lv_msg2,
        'S' lv_msg3.

ENDFORM.
*----------------------------------------------------------*
*       FORM HANDLE_USER_COMMAND                                 *
*----------------------------------------------------------*
*       --> R_UCOMM                                        *
*       --> RS_SELFIELD                                    *
*----------------------------------------------------------*
FORM handle_user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

** Check function code
  CASE r_ucomm.
    WHEN '&PARK'.
      CLEAR gw_error.
      READ TABLE gt_error INTO gw_error WITH KEY type = 'E'.
      IF gw_error IS INITIAL.
        CLEAR gw_line.
        PERFORM process_data USING abap_true CHANGING gw_line .
      ENDIF.
    WHEN '&IC1'.
      CLEAR: gw_input.
      READ TABLE gt_input INTO gw_input INDEX rs_selfield-tabindex.
      IF gw_input IS NOT INITIAL.
        PERFORM pop_list_display USING gw_input.
      ENDIF.
      CLEAR: gw_input.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validation USING gw_head TYPE ty_header
                      gw_item TYPE ty_item
                      gw_zarvatobank TYPE zarvatobank.

  IF gw_head-iban IS INITIAL.
***** Build error output
    PERFORM build_msg USING space
                            gw_head-doc_number
                            'E'
                            TEXT-001
                            space
                            space
                            space
                            space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_document_processing_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_document_processing_status USING VALUE(p_status)
                                          VALUE(p_doc).
  CLEAR gw_input.
  LOOP AT gt_input INTO gw_input WHERE field_1 EQ gc_ph
                                   AND field_7 EQ p_doc.

    CASE p_status.
      WHEN 'S'.
        gw_input-icon = gc_green.
      WHEN 'E'.
        gw_input-icon = gc_red.
    ENDCASE.
    MODIFY gt_input FROM gw_input TRANSPORTING icon.
    CLEAR gw_input.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_document_company_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GE_HEADER
*&---------------------------------------------------------------------*
FORM set_document_company_code  USING VALUE(p_doc) VALUE(p_company).
  CLEAR gw_input.
  LOOP AT gt_input INTO gw_input WHERE field_1 EQ gc_ph
                                   AND field_7 EQ p_doc.

    gw_input-bukrs = p_company.
    MODIFY gt_input FROM gw_input TRANSPORTING bukrs.
    CLEAR gw_input.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_document_tax_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GE_HEADER
*&---------------------------------------------------------------------*
FORM set_document_tax_code  USING VALUE(p_doc) VALUE(p_txcod).
  CLEAR gw_input.
  LOOP AT gt_input INTO gw_input WHERE field_1 EQ gc_ph
                                   AND field_7 EQ p_doc.

    gw_input-mwskz = p_txcod.
    MODIFY gt_input FROM gw_input TRANSPORTING mwskz.
    CLEAR gw_input.
  ENDLOOP.
ENDFORM.

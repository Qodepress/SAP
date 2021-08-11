*&---------------------------------------------------------------------*
*& Include          ZFI_CUSTOMER_RECEIPT_DOC
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Setup Document Header
*&---------------------------------------------------------------------*
FORM set_doc_headr USING VALUE(p_company)
                         VALUE(p_doctype)
                         VALUE(p_date)
                         VALUE(p_headertxt)
                         VALUE(p_refdoc).
  CONSTANTS: lc_rfbu(4) TYPE c VALUE 'RFBU',
             lc_park    TYPE c VALUE '2'.

  gw_header-bus_act    = lc_rfbu.
  gw_header-username   = sy-uname.
  gw_header-fisc_year  = sy-datum+0(4).
  gw_header-pstng_date = sy-datum.
  gw_header-fis_period = sy-datum+4(2).
  gw_header-doc_status = lc_park.
  MOVE p_company TO gw_header-comp_code.
  MOVE p_date TO gw_header-doc_date.
  MOVE p_doctype TO gw_header-doc_type.
  MOVE p_refdoc TO gw_header-ref_doc_no.
  MOVE p_headertxt TO gw_header-header_txt.
ENDFORM.
*&---------------------------------------------------------------------*
*& Setup Document GL
*&---------------------------------------------------------------------*
FORM set_gl USING VALUE(p_itemno)
                  VALUE(p_glaccount)
                  VALUE(p_company)
                  VALUE(p_doctype)
                  VALUE(p_taxcode)
                  VALUE(p_itemtxt)
                  VALUE(p_profcenter)
                  VALUE(p_costcenter).

  gw_accountgl-pstng_date = sy-datum.
  gw_accountgl-value_date = sy-datum.
  gw_accountgl-fisc_year  = sy-datum+0(4).
  gw_accountgl-fis_period = sy-datum+4(2).
  MOVE p_itemno TO gw_accountgl-itemno_acc.
  MOVE p_glaccount TO gw_accountgl-gl_account.
  MOVE p_company TO gw_accountgl-comp_code .
  MOVE p_doctype TO gw_accountgl-doc_type .
  MOVE p_taxcode TO gw_accountgl-tax_code .
  MOVE p_itemtxt TO gw_accountgl-item_text.
  MOVE p_profcenter TO gw_accountgl-profit_ctr.
  MOVE p_costcenter TO gw_accountgl-costcenter.

  APPEND gw_accountgl TO gt_accountgl.
  CLEAR gw_accountgl.
ENDFORM.
*&---------------------------------------------------------------------*
*& Setup Document Account Recievable
*&---------------------------------------------------------------------*
FORM set_accountrcv USING VALUE(p_itemno)
                          VALUE(p_customer)
                          VALUE(p_company)
                          VALUE(p_taxcode)
                          VALUE(p_itemtxt)
                          VALUE(p_assnum)
                          VALUE(p_sglind).

  CONSTANTS: lc_int(3)  TYPE c VALUE 'INT'.

  gw_accountrcv-bline_date = sy-datum.
  gw_accountrcv-c_ctr_area = lc_int.
  MOVE p_itemno TO gw_accountrcv-itemno_acc.
  MOVE p_customer TO gw_accountrcv-customer.
  MOVE p_company TO gw_accountrcv-comp_code.
  MOVE p_taxcode TO gw_accountrcv-tax_code.
  MOVE p_itemtxt TO gw_accountrcv-item_text.
  MOVE p_sglind  TO gw_accountrcv-sp_gl_ind.
  MOVE p_assnum  TO gw_accountrcv-alloc_nmbr.

  APPEND gw_accountrcv TO gt_accountrcv.
  CLEAR gw_accountrcv.
ENDFORM.
*&---------------------------------------------------------------------*
*& Calculate Document TAX
*&---------------------------------------------------------------------*
FORM calculate_tax USING VALUE(p_bukrs)
                         VALUE(p_waers)
                         p_wrbtr TYPE wmwst
                         VALUE(p_mwskz)
                   CHANGING gw_mwdat TYPE rtax1u15.

  DATA: lv_wrbtr TYPE bseg-wrbtr.
  MOVE p_wrbtr TO lv_wrbtr.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs           = p_bukrs
      i_mwskz           = p_mwskz
      i_waers           = p_waers
      i_wrbtr           = lv_wrbtr
    TABLES
      t_mwdat           = gt_mwdat
    EXCEPTIONS
      bukrs_not_found   = 1
      country_not_found = 2
      mwskz_not_defined = 3
      mwskz_not_valid   = 4
      ktosl_not_found   = 5
      kalsm_not_found   = 6
      parameter_error   = 7
      knumh_not_found   = 8
      kschl_not_found   = 9
      unknown_error     = 10
      account_not_found = 11
      txjcd_not_valid   = 12
      OTHERS            = 13.
  IF sy-subrc EQ 0.                          "#EC CI_FLDEXT_OK[2610650]
    READ TABLE gt_mwdat INTO gw_mwdat INDEX 1.        "#EC CI_FLDEXT_OK
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Setup Document TAX
*&---------------------------------------------------------------------*
FORM set_tax USING VALUE(p_itemno)
                   VALUE(p_glacc)
                   VALUE(p_acckey)
                   VALUE(p_condkey)
                   VALUE(p_txcode).

  MOVE p_itemno TO gw_accounttax-itemno_acc.
  MOVE p_glacc TO gw_accounttax-gl_account.
  MOVE p_acckey TO gw_accounttax-acct_key.
  MOVE p_condkey TO gw_accounttax-cond_key.
  MOVE p_txcode TO gw_accounttax-tax_code.

  APPEND gw_accounttax TO gt_accounttax.
  CLEAR gw_accounttax.
ENDFORM.
*&---------------------------------------------------------------------*
*& Setup Document Currency
*&---------------------------------------------------------------------*
FORM set_currency USING VALUE(p_itemno)
                        VALUE(p_currency)
                        p_amount TYPE wmwst
                        VALUE(p_baseamt).

  CONSTANTS: lc_curr_typ(2) TYPE c VALUE '00'.

*  gw_currencyamount-amt_doccur = CONV i( p_amount ) .
  MOVE p_itemno TO gw_currencyamount-itemno_acc.
  MOVE lc_curr_typ TO gw_currencyamount-curr_type.
  MOVE p_currency TO gw_currencyamount-currency.
  MOVE p_baseamt TO gw_currencyamount-amt_base.
  MOVE p_amount TO gw_currencyamount-amt_doccur.

  APPEND gw_currencyamount TO gt_currencyamount.
  CLEAR gw_currencyamount.
ENDFORM.
*&---------------------------------------------------------------------*
*& Setup Extension
*&---------------------------------------------------------------------*
FORM set_extensions USING VALUE(structure)
                          VALUE(valuepart1)
                          VALUE(valuepart2)
                          VALUE(valuepart3)
                          VALUE(valuepart4).

  MOVE structure TO gw_extension2-structure.
  MOVE valuepart1 TO gw_extension2-valuepart1.
  MOVE valuepart2 TO gw_extension2-valuepart2.
  MOVE valuepart3 TO gw_extension2-valuepart3.
  MOVE valuepart4 TO gw_extension2-valuepart4.

  APPEND gw_extension2 TO gt_extension2.
  CLEAR gw_extension2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Setup PSG Critertia
*&---------------------------------------------------------------------*
FORM get_set_psg USING VALUE(p_item)
                       VALUE(p_field)
                       VALUE(p_val).

  PERFORM convert_to_internal USING p_item p_item.
  MOVE p_item TO gw_criteria-itemno_acc.
  MOVE p_field TO gw_criteria-fieldname.
  MOVE p_val TO gw_criteria-character.

  APPEND gw_criteria TO gt_criteria.
  CLEAR gw_criteria.
ENDFORM.
*&---------------------------------------------------------------------*
*& Convert to internal format
*&---------------------------------------------------------------------*
FORM convert_to_internal USING p_input TYPE clike
                               p_output TYPE clike.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = p_output.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GW_HEADER
*&      --> GT_ACCOUNTGL
*&      --> GT_CURRENCYAMOUNT
*&      --> GT_EXTENSION1
*&      --> GC_TEST
*&      <-- GT_RETURN
*&---------------------------------------------------------------------*
FORM check_document  USING   gw_header TYPE bapiache09
                             gt_accountgl TYPE STANDARD TABLE
                             gt_accountrcv TYPE STANDARD TABLE
                             gt_tax TYPE STANDARD TABLE
                             gt_currencyamount TYPE STANDARD TABLE
                             gt_criteria TYPE STANDARD TABLE
                             gt_extension2 TYPE STANDARD TABLE
                    CHANGING gt_return TYPE STANDARD TABLE.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'   "#EC CI_USAGE_OK[2628704]
  "#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader    = gw_header
    TABLES
      accountgl         = gt_accountgl   "#EC CI_FLDEXT_OK
      accountreceivable = gt_accountrcv
      accounttax        = gt_tax
      currencyamount    = gt_currencyamount
      criteria          = gt_criteria
      return            = gt_return
      extension2        = gt_extension2.

  IF sy-subrc <> 0.
    MESSAGE e001(zfiac) DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form park_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM park_document USING: gw_header TYPE bapiache09
                          gt_accountgl TYPE STANDARD TABLE
                          gt_accountrcv TYPE STANDARD TABLE
                          gt_tax TYPE STANDARD TABLE
                          gt_currencyamount TYPE STANDARD TABLE
                          gt_criteria TYPE STANDARD TABLE
                          gt_extension2 TYPE STANDARD TABLE
                 CHANGING gt_return TYPE STANDARD TABLE.

  DATA: lgt_return TYPE STANDARD TABLE OF bapiret2.
  DATA: lgw_return TYPE bapiret2.
  REFRESH: lgt_return.


  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK[2438131]
  "#EC CI_USAGE_OK[2628704]
    EXPORTING
      documentheader    = gw_header
    TABLES
      accountgl         = gt_accountgl  "#EC CI_FLDEXT_OK
      accountreceivable = gt_accountrcv
      accounttax        = gt_tax
      currencyamount    = gt_currencyamount "#EC CI_USAGE_OK
      criteria          = gt_criteria
      return            = gt_return
      extension2        = gt_extension2.


  IF sy-subrc <> 0 .
********* Collect Return Value for Error
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = lgw_return.
********* Rollback If Error or Test.
    IF lgw_return IS NOT INITIAL.
      APPEND lgw_return TO gt_return.
      CLEAR: lgw_return.
    ENDIF.
  ELSE.
********* Collect Return Value for Success
    IF lgt_return IS NOT INITIAL.
      CLEAR: gw_return.
      LOOP AT lgt_return INTO gw_return.
        APPEND gw_return TO gt_return.
        CLEAR: gw_return.
      ENDLOOP.
    ENDIF.
********* Commit If Success
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

ENDFORM.

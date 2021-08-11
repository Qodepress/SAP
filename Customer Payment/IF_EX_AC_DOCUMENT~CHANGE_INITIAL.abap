*----------------------------------------------------------------------*
* Modification Information
*----------------------------------------------------------------------*
* Date            : <30-09-2020>
* Author          : <Dhananjayan/DK>
* Transport number: <>
* Description     : <CHN1 sales order is already lost when K_COBL_CHECK is
*called, forcing the system to send the error message KI235 when
* FM AC_DOCUMENT_CREATE  called. for that added Sales order No & item>
*----------------------------------------------------------------------*
METHOD if_ex_ac_document~change_initial.
  DATA: ls_item     TYPE accit,
        ls_item_upd TYPE accit,
        ls_item_bsx TYPE accit,
        ls_ekpo     TYPE ekpo,
        lt_update   TYPE TABLE OF accit_sub,
        ls_update   TYPE accit_sub.

  IF sy-tcode = 'MIGO' OR sy-tcode = 'MIGO_GR'.
    CLEAR: lt_update[].
    LOOP AT im_document-item INTO ls_item WHERE ktosl = 'GBB'
                                            AND ebeln IS NOT INITIAL
                                            AND ebelp IS NOT INITIAL.

      SELECT SINGLE * FROM ekpo INTO ls_ekpo WHERE ebeln = ls_item-ebeln
                                               AND ebelp = ls_item-ebelp.

      IF sy-subrc = 0 AND ls_ekpo-knttp = 'X' AND ls_ekpo-pstyp = '3'.

        READ TABLE im_document-item INTO ls_item_upd
                                            WITH KEY ktosl = 'KBS'
                                                     ebeln = ls_item-ebeln
                                                     ebelp = ls_item-ebelp.
        IF sy-subrc = 0.
          CLEAR ls_update.
          ls_update-mandt = ls_item-mandt.
          ls_update-awtyp = ls_item-awtyp.
          ls_update-awref = ls_item-awref.
          ls_update-aworg = ls_item-aworg.
          ls_update-posnr = ls_item-posnr.
          ls_update-kdauf = ls_item-kdauf.  "+CHN1 Changed by DK 0n 11.09.2020
          ls_update-kdpos = ls_item-kdpos.  "+CHN1 Changed by DK 0n 11.09.2020
          ls_update-pprctr = ls_item_upd-pprctr.
*          ls_update-prctr = ls_item-pprctr.
          APPEND ls_update TO lt_update.
        ENDIF.

***        LOOP AT im_document-item INTO ls_item_bsx
***                                    WHERE ktosl = 'BSX'
***                                         AND ebeln = ls_item-ebeln
***                                         AND ebelp = ls_item-ebelp.
***          CLEAR ls_update.
***          ls_update-mandt = ls_item_bsx-mandt.
***          ls_update-awtyp = ls_item_bsx-awtyp.
***          ls_update-awref = ls_item_bsx-awref.
***          ls_update-aworg = ls_item_bsx-aworg.
***          ls_update-posnr = ls_item_bsx-posnr.
***          ls_update-pprctr = ls_item_upd-pprctr.
***          ls_update-prctr = ls_item-pprctr.
***          APPEND ls_update TO lt_update.
***        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF NOT lt_update IS INITIAL.
***      DELETE ADJACENT DUPLICATES FROM lt_update COMPARING ALL FIELDS.
      ex_document-item[] = lt_update[].
    ENDIF.

  ENDIF.
" add by sherin 04 06 2014
  DATA: wa_header TYPE acchd.
  IF sy-xprog NE 'SAPMSSY1'.
*---<SAPLBPFC> is for Posting      with BAPI: BAPI_ACC_DOCUMENT_POST
*---<SAPCNVE > is for Posting(Tax) with BAPI: BAPI_ACC_DOCUMENT_POST
*---<SAPMSSY1> is for Test(Check)  with BAPI: BAPI_ACC_DOCUMENT_CHECK
    CLEAR wa_header.
    wa_header = im_document-header.
    ex_document-header-bktxt = wa_header-bktxt.
    CLEAR wa_header.
  ENDIF.


" add by A.Kumar 13.07.2021
  IF sy-tcode EQ 'ZARVTOPAY'.
*---<SAPLBPFC> is for Posting      with BAPI: BAPI_ACC_DOCUMENT_POST
*---<SAPCNVE > is for Posting(Tax) with BAPI: BAPI_ACC_DOCUMENT_POST
*---<SAPMSSY1> is for Test(Check)  with BAPI: BAPI_ACC_DOCUMENT_CHECK
    CLEAR wa_header.
    wa_header = im_document-header.
    ex_document-header-bktxt = wa_header-bktxt.
    CLEAR wa_header.
  ENDIF.

ENDMETHOD.

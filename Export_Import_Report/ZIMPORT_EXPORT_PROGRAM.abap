*&---------------------------------------------------------------------*
*& Report ZTEST0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest0002.


****************************** CHANGED BY A.KUMAR 10082021
TYPES: BEGIN OF st_display,
         objek TYPE ausp-objek,
         relgr TYPE c LENGTH 2,  " Release Group
         relst TYPE c LENGTH 2,  " Release Strategy
         atinn TYPE ausp-atinn,
         klart TYPE ausp-klart,
         atwrt TYPE ausp-atwrt,
         frgxt TYPE t16ft-frgxt, " Description of release strategy
         statu TYPE kssk-statu,  " release status
         descr TYPE c LENGTH 10, " Released description
         docty TYPE c LENGTH 30, " Document type
         poval TYPE c LENGTH 30, " Po value
         purgr TYPE ekko-ekgrp,  " c LENGTH 30, " Purchase group
         eknam TYPE t024-eknam,  " Description of EKGRP
         frgcd TYPE t16fs-frgc1, " c LENGTH 30,
         uname TYPE agr_users-uname,
         fname TYPE adrp-name_first,
         lname TYPE adrp-name_last,
         cname TYPE adrp-name_text,
         value TYPE ausp-atwrt,
       END OF st_display.

TYPES: BEGIN OF ot_list ,
         output(1500) TYPE c,
       END OF ot_list.
****************************** CHANGED BY A.KUMAR 10082021

DATA: ls_essr         TYPE essr,       "Added by A.Kumar 10082021
      ls_ekko         TYPE ekko,       "Added by A.Kumar 10082021
      gt_display      TYPE STANDARD TABLE OF st_display,   "Added by A.Kumar 10082021
      ls_display      TYPE st_display,   "Added by A.Kumar 10082021
      lv_frgco        TYPE frgco,
      lv_ses          TYPE lblni,
      ls_final_relcod TYPE zmm_final_relcod,
      lt_listobject   TYPE STANDARD TABLE OF  abaplist,
      ls_listobject   TYPE abaplist,
      o_list          TYPE STANDARD TABLE OF ot_list,
      os_list         TYPE ot_list.

CONSTANTS: lc_sr TYPE frggr VALUE 'SR'. "Added by A.Kumar 10082021

BREAK-POINT.

lv_ses = '1000080374'.
lv_frgco = 'DM'.

SELECT SINGLE lblni frggr frgsx ebeln ebelp
  INTO CORRESPONDING FIELDS OF ls_essr
  FROM essr
  WHERE lblni = lv_ses.

IF sy-subrc EQ 0.

  SELECT SINGLE ekgrp
    INTO CORRESPONDING FIELDS OF ls_ekko
    FROM ekko
    WHERE ebeln = ls_essr-ebeln.

  IF sy-subrc EQ 0.
    SUBMIT zmm_fiori_authorization_data
      WITH s_frggr = ls_essr-frggr
      WITH s_frgsx = ls_essr-frgsx
      WITH s_ekgrp = ls_ekko-ekgrp
      WITH s_frgco = lv_frgco
      EXPORTING LIST TO MEMORY
      AND RETURN.

    BREAK-POINT.
    IMPORT gt_display = gt_display FROM MEMORY ID lc_sr.

    IF gt_display[] IS NOT INITIAL.
      CLEAR ls_display.
      LOOP AT gt_display INTO ls_display.
        ls_final_relcod-lblni = lv_ses.
        ls_final_relcod-frgco = lv_frgco.
        ls_final_relcod-usnam = ls_display-uname.
*        MODIFY zmm_final_relcod FROM ls_final_relcod.
        CLEAR ls_display.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDIF.

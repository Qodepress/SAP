METHOD if_ex_acc_document~change.
  DATA: lc_accit      TYPE LINE OF accit_tab,
        lc_extension2 TYPE LINE OF bapiparex_tab_ac.


  LOOP AT c_extension2 INTO lc_extension2 WHERE valuepart2 IS NOT INITIAL.
    READ TABLE c_accit INTO lc_accit WITH KEY posnr = lc_extension2-valuepart1.
    IF sy-subrc EQ 0.
      lc_accit-bschl = lc_extension2-valuepart2.
      MODIFY c_accit FROM lc_accit INDEX sy-tabix TRANSPORTING bschl .
    ENDIF.
  ENDLOOP.
ENDMETHOD.

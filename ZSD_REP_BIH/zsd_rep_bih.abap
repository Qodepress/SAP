*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                          Program Details                              *
*----------------------------------------------------------------------*
* Program Name         :  ZSD_REP_DIS                                  *
* Title                :  [IGT-SD] Sales Order History                 *
* Program Type         :  Report/Executable                            *
* Created By           :  ANKIT KUMAR                                  *
* Started On           :  16.05.2014                                   *
* Completed On         :  28.05.2014                                   *
* Logical Database     :  NA                                           *
* Transaction Code     :  ZSDBIH                                       *
* Development Client   :  100                                          *
* Development Class    :  ZSD                                          *
* Transport Request No.:  IEDK901282                                   *
* Functional Consultant:                                               *
* Description          :  [IGT-SD] Sales Order History                 *
*----------------------------------------------------------------------*
*-------------------------Modification History-------------------------*
*Code|  Changed By     |Changed On|       Reason                       *
*----------------------------------------------------------------------*
*    |                 |          |                                    *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZSD_REP_BIH
*&
*&---------------------------------------------------------------------*
*&
*Read Sales Order fromm VBAP, VBAK
*Read all Invoice from VBFA
*Based on VBFA invoice, READ VBRK, VBRP
*Display as ALV
*&
*&---------------------------------------------------------------------*
REPORT zsd_rep_bih.

TYPE-POOLS: slis,abap.
TABLES: vbap,vbak,vbfa,vbrk,vbrp,bkpf,bseg,bsid,bsad,prps,kna1,proj,konv,ztkschl.
TABLES: zsd_s_dis_cond.

DATA  i_fy(004) TYPE  c.
DATA  run_date  TYPE dats.
DATA: v_sdate   TYPE bkpf-budat,
      v_edate   TYPE bkpf-budat.
DATA: v_psdate  TYPE bkpf-budat,
      v_pedate  TYPE bkpf-budat.
DATA: v_osdate(010),
      v_oedate(010).
DATA: v_pspnr TYPE c.

TYPES: BEGIN OF ty_final,
        month TYPE s003-spbup,
        vbelv TYPE vbelv,
        vbeln TYPE vbeln,
        augbl TYPE augbl,
        augcp TYPE augcp,
        augdt TYPE augdt,
        fkdat TYPE fkdat,
        budat TYPE budat,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        sfakn TYPE sfakn,
       cbelnr TYPE belnr_d,
       cbukrs TYPE bukrs,
       cgjahr TYPE gjahr,
        bukrs TYPE bukrs,
        pspnr TYPE ps_pspid,
        psptx TYPE ps_post1,
        posnr TYPE ps_psp_pnr,
        postx TYPE ps_post1,
*        conmt TYPE netwr,
*        dismt TYPE netwr,
*        wrbtr LIKE bseg-wrbtr,     "Amt in local currency
*        dmbtr LIKE bseg-dmbtr,     "Amt in Document currency
*        dmbt2 LIKE bseg-dmbt2,     "Amt in Document currency 2
*        netwr TYPE netwr,
        wrbtr TYPE wrbtr,
        wskto TYPE wskto,
        wmwst TYPE wmwst,
        dmbtr TYPE dmbtr,
        sknto TYPE sknto,
        mwsts TYPE mwsts,
        kunnr TYPE kunnr,
        kunam TYPE name1,
        sownm TYPE tdline,
        usr01 TYPE usr01prps,
        usr02 TYPE usr02prps,
        usr03 TYPE usr03prps,
*        waerk TYPE vbrk-waerk,
        dis   TYPE konv-kwert ,
        disr  TYPE konv-kbetr,
*        curr  TYPE konv-waers ,
        opfil TYPE string,
        mofil TYPE string,
        dctyp(20),
        geoar TYPE prps-geoar,
        serln TYPE prps-serln,
        poski TYPE ps_poski,
        mask_budat(10) TYPE c,
        mask_fkdat(10) TYPE c,
        hwaer TYPE hwaer,
        waers TYPE waers,
        kursf TYPE kursf,
        kurs2 TYPE kurs2,
     d_twaers TYPE dmbtr,
     l_twaers TYPE dmbtr,
     htext    TYPE text,
**************  Condition types
        hwae2 TYPE hwae2,
        zdsf  TYPE kwert,
        zotr  TYPE kwert,
        zdis  TYPE kwert,
        zdnt  TYPE kwert,
        zfrd  TYPE kwert,
        zaer  TYPE kwert,
        zser  TYPE kwert,
        zcst  TYPE kwert,
        zcsw  TYPE kwert,
        zsbc  TYPE kwert,
        zvat  TYPE kwert,

        hwae2d TYPE hwae2,
        zdsfd  TYPE kwert,
        zotrd  TYPE kwert,
        zdisd  TYPE kwert,
        zdntd  TYPE kwert,
        zfrdd  TYPE kwert,
        zaerd  TYPE kwert,
        zserd  TYPE kwert,
        zcstd  TYPE kwert,
        zcswd  TYPE kwert,
        zsbcd  TYPE kwert,
        zvatd  TYPE kwert,
  END OF ty_final.

TYPES: BEGIN OF ty_report,
        vbelv TYPE vbelv,     "Sales Order No
        vbeln TYPE vbeln,     "Billing Document
        bukrs TYPE bukrs,     "Company code
        gjahr TYPE gjahr,     "Year
        belnr TYPE belnr_d,   "Document Number
        dctyp(20),            "Billing Type
        htext TYPE text,
**        fkdat TYPE fkdat,
**        budat TYPE budat,
        mask_fkdat(10) TYPE c, "Billing Date
        mask_budat(10) TYPE c, "Posting Date
        psptx TYPE ps_post1,   "Project Description
        poski TYPE ps_poski,   "WBS Element
*        postx TYPE ps_post1,   "WBS Description
         waers TYPE waers,      "Local Currency
        dmbtr TYPE dmbtr,       "Amount In Loc Curr
        sknto TYPE sknto,       "Discount In Loc Curr.
        mwsts TYPE mwsts,       "Tax In Loc Curr
     l_twaers TYPE dmbtr,
        kursf TYPE kursf,       "Exchange Rate
        hwaer TYPE hwaer,       "Document Currency
        wrbtr TYPE wrbtr,       "Amount In Doc Curr
        wskto TYPE wskto,       "Discount In Doc Curr.
        wmwst TYPE wmwst,       "Tax In Doc Curr.
     d_twaers TYPE dmbtr,       "Discount In Doc Curr.
        kunnr TYPE kunnr,       "Customer Number
        kunam TYPE name1,       "Customer Name
        usr01 TYPE usr01prps,
        usr02 TYPE usr02prps,
        usr03 TYPE usr03prps,
        geoar TYPE prps-geoar,
        opfil TYPE string,
        mofil TYPE string,
**************  Condition types
        hwae2  TYPE hwae2,
        zdsf   TYPE kwert,
        zotr   TYPE kwert,
        zdis   TYPE kwert,
        zdnt   TYPE kwert,
        zfrd   TYPE kwert,
        zaer   TYPE kwert,
       END OF ty_report.

TYPES: BEGIN OF ty_bseg,
          mandt TYPE  bseg-mandt,
          belnr TYPE  bseg-belnr,
          bukrs TYPE  bseg-bukrs,
          gjahr TYPE  bseg-gjahr,
          vbeln TYPE  bseg-vbeln,
          augdt TYPE  bseg-augdt,
          augbl TYPE  bseg-augbl,
          saknr TYPE  bseg-saknr,
          bschl TYPE  bseg-bschl,
          wrbtr TYPE wrbtr,
          wskto TYPE wskto,
          wmwst TYPE wmwst,
          dmbtr TYPE dmbtr,
          sknto TYPE sknto,
          mwsts TYPE mwsts,
          augcp TYPE augcp,
       END OF ty_bseg.

DATA t_final TYPE STANDARD TABLE OF ty_final.
DATA w_final TYPE ty_final.
*********************Reporting
DATA t_report TYPE STANDARD TABLE OF ty_report WITH HEADER LINE.
DATA w_report TYPE ty_report.

DATA: it_dis   TYPE STANDARD TABLE OF zsd_s_dis_cond.
DATA: wa_dis   TYPE zsd_s_dis_cond.

DATA: t_vbap TYPE STANDARD TABLE OF vbap WITH HEADER LINE,
      t_vbak TYPE STANDARD TABLE OF vbak WITH HEADER LINE,
      t_vbfa TYPE STANDARD TABLE OF vbfa WITH HEADER LINE,
      t_vbrk TYPE STANDARD TABLE OF vbrk WITH HEADER LINE,
      t_vbrp TYPE STANDARD TABLE OF vbrp WITH HEADER LINE,
      t_bkpf TYPE STANDARD TABLE OF bkpf WITH HEADER LINE,
      t_bsid TYPE STANDARD TABLE OF bsid WITH HEADER LINE,
      t_bsad TYPE STANDARD TABLE OF bsad WITH HEADER LINE,
      t_skat TYPE STANDARD TABLE OF skat WITH HEADER LINE,
      t_prps TYPE STANDARD TABLE OF prps WITH HEADER LINE,
      t_konv TYPE STANDARD TABLE OF konv WITH HEADER LINE,
*********************BSEG
      t_bseg TYPE STANDARD TABLE OF ty_bseg.

*******Work Area
DATA: w_bseg TYPE ty_bseg.
DATA: w_bkpf TYPE bkpf.

TYPES: BEGIN OF ty_xblnr,
       v_xblnr_from_vbeln(16) TYPE c,
       END OF ty_xblnr.

DATA : t_xblnr TYPE STANDARD TABLE OF ty_xblnr.
DATA : w_xblnr TYPE ty_xblnr.

************************ALV Grid Control
DATA it_fieldcat TYPE STANDARD TABLE OF lvc_s_fcat.
DATA it_exclude  TYPE slis_t_extab.
DATA wa_exclude  TYPE slis_extab.
DATA gd_layout   TYPE lvc_s_layo.
DATA wa_fieldcat TYPE lvc_s_fcat.
DATA title       TYPE lvc_title.

DATA g_save TYPE c.
DATA g_exit TYPE c.
DATA g_variant  LIKE disvariant.
DATA gx_variant LIKE disvariant.
DATA idx TYPE sy-tabix.


DATA:t_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
     t_list_top_of_page     TYPE slis_t_listheader,
     is_layout              TYPE slis_layout_alv.

DATA status   TYPE gui_status.
DATA p_posid  TYPE ps_posid.
DATA p_posnr  TYPE ps_posnr.
DATA col_pos  TYPE i.
DATA gv_repid TYPE sy-repid.

RANGES ra_pspnr FOR prps-pspnr.
RANGES ra_vbeln FOR vbak-vbeln.

DATA txtid TYPE thead-tdid.
DATA txtnm TYPE thead-tdname.
DATA txtob TYPE thead-tdobject.
DATA tline TYPE STANDARD TABLE OF tline WITH HEADER LINE.

DATA report_name TYPE string.
DATA document_st TYPE string.
DATA n           TYPE string.

******************************Excel Templete
TYPES: BEGIN OF ty_templete,
        bukrs  TYPE bkpf-bukrs,
        gjahr  TYPE bkpf-gjahr,
        belnr  TYPE bkpf-belnr,
        f1     TYPE string,
        f2(10) TYPE c,
        f3     TYPE c,
        vbeln  TYPE vbrk-vbeln,
       END OF ty_templete.

DATA: default_month(10) TYPE c,
          this_month(3) TYPE c,
           this_year(2) TYPE c,
             di_fy(004) TYPE c.

DATA: BEGIN OF t_field OCCURS 0,
         field_name(30),
         END OF t_field.

DATA: BEGIN OF rep_field OCCURS 0,
         field_name(30),
         END OF rep_field.

DATA: v_month        TYPE string,
      v_year         TYPE string,
      l_monthname    TYPE string,
      v_l_monthname  TYPE string,
      file_name      TYPE string.

DATA: t_excel  TYPE STANDARD TABLE OF ty_templete,
      w_excel  TYPE ty_templete.
DATA: gd_repid LIKE sy-repid,
      ref_grid TYPE REF TO cl_gui_alv_grid.

****************INVOICING************************************
DATA: formname                 TYPE tdsfname,
      lf_fm_name               TYPE rs38l_fnam,
      v_language               TYPE sflangu VALUE 'E',
      v_e_devtype              TYPE rspoptype,
      v_bin_filesize           TYPE i,
      v_name                   TYPE string,
      v_fullpath               TYPE string,
      v_filename               TYPE string,
      st_job_output_info       TYPE ssfcrescl,
      st_document_output_info  TYPE ssfcrespd,
      st_job_output_options    TYPE ssfcresop,
      st_output_options        TYPE ssfcompop,
      st_control_parameters    TYPE ssfctrlop,
      it_docs                  TYPE STANDARD TABLE OF docs,
      it_lines                 TYPE STANDARD TABLE OF tline.

DATA: o_dis TYPE REF TO zcl_sd_dis.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
SELECT-OPTIONS  so_bukrs  FOR bkpf-bukrs DEFAULT '1000' TO '2800' OBLIGATORY.
SELECT-OPTIONS  so_fkdat  FOR vbrk-fkdat OBLIGATORY.
SELECT-OPTIONS  so_kunnr  FOR vbak-kunnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
PARAMETER: rb1 RADIOBUTTON GROUP rbg1 DEFAULT 'X',
           rb2 RADIOBUTTON GROUP rbg1,
           rb3 RADIOBUTTON GROUP rbg1.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETER: d_loc TYPE string DEFAULT 'C:\Invoice'.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b4.

AT SELECTION-SCREEN.
  PERFORM pai_of_selection_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_help_variant.

INITIALIZATION.
  n = 0.
*****************************
  report_name = 'Customer billing analysis report'.
*****************************
  status = 'ZSD_REP_BIH' .
*************************  Excel Templete Header
********* Field 1
  CLEAR t_field.
  t_field-field_name = 'Company Code'.
  APPEND t_field.

********* Field 2
  CLEAR t_field.
  t_field-field_name = 'Fiscal Year'.
  APPEND t_field.

********* Field 3
  CLEAR t_field.
  t_field-field_name = 'Document Number'.
  APPEND t_field.

********* Field 4
  CLEAR t_field.
  t_field-field_name = 'Output Type'.
  APPEND t_field.

********* Field 5
  CLEAR t_field.
  t_field-field_name = 'For Month'.
  APPEND t_field.

********* Field 6
  CLEAR t_field.
  t_field-field_name = 'W/Header'.
  APPEND t_field.

  PERFORM get_report_header.
  PERFORM get_start_end_date.
  MOVE: 'BT'     TO so_fkdat-option,
         v_sdate TO so_fkdat-low,
         v_edate TO so_fkdat-high,
         '*'     TO so_kunnr-low.
  APPEND: so_fkdat, so_kunnr.

START-OF-SELECTION.
  PERFORM get_so_details.
  PERFORM get_bh_final.

END-OF-SELECTION.
  PERFORM display_alv_list.
*&---------------------------------------------------------------------*
*&      Form  GET_SO_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_so_details.

  SELECT *
    FROM bkpf
    INTO TABLE t_bkpf
    WHERE bukrs IN so_bukrs
      AND budat IN so_fkdat
      AND blart IN ('RV','DR','DG').

  LOOP AT t_bkpf.
    SELECT *
      FROM bkpf
      INTO w_bkpf
      WHERE bukrs = t_bkpf-bukrs
        AND belnr = t_bkpf-stblg
        AND gjahr = t_bkpf-gjahr
        AND blart IN ('AB').
      APPEND w_bkpf TO t_bkpf.
    ENDSELECT.
  ENDLOOP.

  IF t_bkpf[] IS NOT INITIAL.
    SELECT *
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE t_bseg
      FOR ALL ENTRIES IN t_bkpf
      WHERE bukrs = t_bkpf-bukrs
        AND belnr = t_bkpf-belnr
        AND gjahr = t_bkpf-gjahr
        AND bschl IN ('01','07','11','12')
        AND kunnr IN so_kunnr.
  ENDIF.

  IF t_bkpf[] IS NOT INITIAL.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE t_bsid
      FOR ALL ENTRIES IN t_bkpf
      WHERE bukrs = t_bkpf-bukrs
        AND belnr = t_bkpf-belnr
        AND gjahr = t_bkpf-gjahr
        AND buzei = '1'
        AND bschl IN ('01','07','11','12')
        AND blart IN ('AB','RV','DR','DZ')
        AND kunnr IN so_kunnr.
  ENDIF.

  IF t_bkpf[] IS NOT INITIAL.
    SELECT *
      FROM bsad
      INTO CORRESPONDING FIELDS OF TABLE t_bsad
      FOR ALL ENTRIES IN t_bkpf
      WHERE bukrs = t_bkpf-bukrs
        AND belnr = t_bkpf-belnr
        AND gjahr = t_bkpf-gjahr
        AND buzei = '1'
        AND bschl IN ('01','07','11','12')
        AND blart IN ('AB','RV','DR','DZ')
        AND kunnr IN so_kunnr.
  ENDIF.

  IF t_bseg[] IS NOT INITIAL.
    SELECT *
      FROM vbrk
      INTO TABLE t_vbrk
      FOR ALL ENTRIES IN t_bseg
      WHERE vbeln = t_bseg-vbeln
        AND fkart IN ('F2','L2','ZL2','ZG2','S1').
  ENDIF.

  IF t_bseg[] IS NOT INITIAL.
    SELECT *
      FROM vbrp
      INTO TABLE t_vbrp
      FOR ALL ENTRIES IN t_bseg
      WHERE vbeln = t_bseg-vbeln.

  ENDIF.

  IF t_vbrk[] IS NOT INITIAL.
    SELECT *
      FROM konv
      INTO TABLE t_konv
      FOR ALL ENTRIES IN t_vbrk
      WHERE knumv = t_vbrk-knumv.
  ENDIF.

  IF t_vbrk[] IS NOT INITIAL.
    SELECT *
      FROM vbfa
      INTO TABLE t_vbfa
      FOR ALL ENTRIES IN t_vbrk
      WHERE vbeln = t_vbrk-vbeln
        AND vbtyp_n IN ('N','M','P','O')
        AND vbtyp_v IN ('C','K','L').
  ENDIF.

  IF t_vbfa[] IS NOT INITIAL.
    SELECT *
      FROM vbak
      INTO TABLE t_vbak
      FOR ALL ENTRIES IN t_vbfa
      WHERE vbeln = t_vbfa-vbelv
        AND vbtyp = 'C'
        AND auart = 'ZPRJ'.
  ENDIF.

ENDFORM.                    " GET_SO_DETAILS

*&---------------------------------------------------------------------*
*&      Form  CHECK_CLEARED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bh_final.
  IF rb1 = 'X'.                                                                   "All Items
    document_st = 'All_Items'.
    LOOP AT t_bseg INTO w_bseg.
      LOOP AT t_vbrk INTO vbrk WHERE vbeln = w_bseg-vbeln.
        CREATE OBJECT o_dis
          EXPORTING
            v_billing_document = vbrk-vbeln.

        REFRESH it_dis.
        CALL METHOD o_dis->zif_dis_report~get_final_report
          IMPORTING
            it_dis = it_dis.

        LOOP AT t_vbrp INTO vbrp WHERE vbeln = vbrk-vbeln.
          CLEAR:w_final,kna1,prps,proj.
          SELECT SINGLE * FROM kna1 WHERE kunnr = vbrk-kunag.
          SELECT SINGLE * FROM prps WHERE pspnr = vbrp-ps_psp_pnr.
          SELECT SINGLE * FROM proj WHERE pspnr = prps-psphi.
          SELECT SINGLE * FROM bkpf WHERE belnr = w_bseg-belnr
                                      AND bukrs = w_bseg-bukrs
                                      AND gjahr = w_bseg-gjahr.

          w_final-kurs2  = bkpf-kurs2.
          w_final-hwae2  = bkpf-hwae2.
          w_final-hwae2d = bkpf-hwaer.
          w_final-sfakn  = vbrk-sfakn.

          IF vbrk-sfakn IS NOT INITIAL.
            SELECT SINGLE belnr bukrs gjahr
              FROM bseg
              INTO (w_final-cbelnr, w_final-cbukrs, w_final-cgjahr)
              WHERE vbeln = vbrk-sfakn.
          ENDIF.


          SELECT SINGLE budat waers hwaer kursf
          INTO (w_final-budat, w_final-waers, w_final-hwaer, w_final-kursf)
          FROM bkpf
          WHERE xblnr = vbrk-vbeln.

          PERFORM read_sow_name.
          PERFORM read_header_text.
          w_final-belnr = w_bseg-belnr.
          w_final-vbeln = w_bseg-vbeln.
          w_final-bukrs = w_bseg-bukrs.
          w_final-gjahr = w_bseg-gjahr.
          w_final-augdt = w_bseg-augdt.
          w_final-augcp = w_bseg-augcp.

          IF vbrk-fkart = 'S1'.
            w_final-wrbtr = - w_bseg-wrbtr.
          ELSE.
            w_final-wrbtr = w_bseg-wrbtr.
          ENDIF.

          IF vbrk-fkart = 'S1'.
            w_final-dmbtr = - w_bseg-dmbtr.
          ELSE.
            w_final-dmbtr = w_bseg-dmbtr.
          ENDIF.

          IF vbrk-fkart = 'S1'.
            w_final-wskto = - w_bseg-wskto.
          ELSE.
            w_final-wskto = w_bseg-wskto.
          ENDIF.

          IF vbrk-fkart = 'S1'.
            w_final-wmwst = - w_bseg-wmwst.
          ELSE.
            w_final-wmwst = w_bseg-wmwst.
          ENDIF.

          IF vbrk-fkart = 'S1'.
            w_final-mwsts = - w_bseg-mwsts.
          ELSE.
            w_final-mwsts = w_bseg-mwsts.
          ENDIF.

          IF vbrk-fkart = 'S1'.
            w_final-sknto = - w_bseg-sknto.
          ELSE.
            w_final-sknto = w_bseg-sknto.
          ENDIF.

          CASE vbrk-fkart.
            WHEN 'F2' OR 'L2'.
              w_final-dctyp = 'Invoice'.
*            WHEN 'L2'.
*              w_final-dctyp = 'Debit Memo'.
            WHEN 'ZG2'.
              w_final-dctyp = 'Credit Note'.
            WHEN 'ZL2'.
              w_final-dctyp = 'Debit Note'.
            WHEN 'S1'.
              w_final-dctyp = 'Cancelled Invoices'.
          ENDCASE.

          LOOP AT t_vbfa INTO vbfa WHERE vbeln = vbrk-vbeln.
            w_final-vbelv = vbfa-vbelv.
            w_final-fkdat = vbrk-fkdat.
            w_final-pspnr = proj-pspnr.
            w_final-psptx = proj-post1.
            w_final-posnr = vbrp-ps_psp_pnr.
            w_final-postx = prps-post1.
            w_final-usr01 = prps-usr01.
            w_final-usr02 = prps-usr02.
            w_final-usr03 = prps-usr03.
            w_final-geoar = prps-geoar.
            w_final-serln = prps-serln.

            SELECT SINGLE poski
              FROM prps
              INTO w_final-poski
              WHERE pspnr = vbrp-ps_psp_pnr.

            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-fkdat
              IMPORTING
                output = w_final-mask_fkdat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_fkdat WITH '/'.


            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-budat
              IMPORTING
                output = w_final-mask_budat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_budat WITH '/'.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv

                                                  kposn = vbrp-posnr
                                                  kschl = 'ZDSF'.
            IF sy-subrc = 0.
*              w_final-dismt = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSER'.
            IF sy-subrc = 0.
              w_final-zser = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCST'.
            IF sy-subrc = 0.
              w_final-zcst = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCSW'.

            IF sy-subrc = 0.
              w_final-zcsw = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSBC'.

            IF sy-subrc = 0.
              w_final-zsbc = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZVAT'.

            IF sy-subrc = 0.
              w_final-zvat = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                               kposn = vbrp-posnr
                                               kschl = 'ZDIS'.
            IF sy-subrc = 0.
              w_final-dis = konv-kwert.
              w_final-disr = konv-kbetr.
*              w_final-curr = konv-waers.
            ENDIF.
            w_final-kunnr = vbrk-kunag.
            w_final-kunam = kna1-name1.
*            w_final-waerk = vbrk-waerk.

            w_final-l_twaers = w_final-dmbtr + w_final-mwsts - w_final-sknto.
            w_final-d_twaers = w_final-dmbtr + w_final-wmwst - w_final-wskto.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
      PERFORM get_condition_final.
      IF w_final IS NOT INITIAL.
        COLLECT w_final INTO t_final.
        SORT t_final ASCENDING BY bukrs gjahr fkdat budat.
        DESCRIBE TABLE t_final.
        n = sy-tfill.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF rb2 = 'X'.                                                                   "Cleared Items
    document_st = 'Cleared_Items'.
    LOOP AT t_bsad INTO bsad.
      LOOP AT t_vbrk INTO vbrk WHERE vbeln = bsad-vbeln.
        w_final-sfakn = vbrk-sfakn.
        CREATE OBJECT o_dis
          EXPORTING
            v_billing_document = vbrk-vbeln.

        REFRESH it_dis.
        CALL METHOD o_dis->zif_dis_report~get_final_report
          IMPORTING
            it_dis = it_dis.

        LOOP AT t_vbrp INTO vbrp WHERE vbeln = vbrk-vbeln.
          CLEAR:w_final,kna1,prps,proj.
          SELECT SINGLE * FROM kna1 WHERE kunnr = vbrk-kunag.
          SELECT SINGLE * FROM prps WHERE pspnr = vbrp-ps_psp_pnr.
          SELECT SINGLE * FROM proj WHERE pspnr = prps-psphi.
          SELECT SINGLE * FROM bkpf WHERE belnr = w_bseg-belnr
                                      AND bukrs = w_bseg-bukrs
                                      AND gjahr = w_bseg-gjahr.

          w_final-kurs2  = bkpf-kurs2.
          w_final-hwae2  = bkpf-hwae2.
          w_final-hwae2d = bkpf-hwaer.

          IF vbrk-sfakn IS NOT INITIAL.
            SELECT SINGLE belnr bukrs gjahr
              FROM bseg
              INTO (w_final-cbelnr, w_final-cbukrs, w_final-cgjahr)
              WHERE vbeln = vbrk-sfakn.
          ENDIF.

          SELECT SINGLE budat waers hwaer kursf
          INTO (w_final-budat, w_final-waers, w_final-hwaer, w_final-kursf)
          FROM bkpf
          WHERE xblnr = vbrk-vbeln.

          PERFORM read_sow_name.
          PERFORM read_header_text.
          w_final-belnr = bsad-belnr.
          w_final-vbeln = bsad-vbeln.
          w_final-bukrs = bsad-bukrs.
          w_final-gjahr = bsad-gjahr.

          w_final-wrbtr = bsad-wrbtr.
          w_final-dmbtr = bsad-dmbtr.
          w_final-wskto = bsad-wskto.
          w_final-wmwst = bsad-wmwst.
          w_final-sknto = bsad-sknto.
          w_final-mwsts = bsad-mwsts.

          LOOP AT t_vbfa INTO vbfa WHERE vbeln = vbrk-vbeln.
            w_final-vbelv = vbfa-vbelv.
            w_final-fkdat = vbrk-fkdat.
            w_final-pspnr = proj-pspnr.
            w_final-psptx = proj-post1.
            w_final-posnr = vbrp-ps_psp_pnr.
            w_final-postx = prps-post1.
            w_final-usr01 = prps-usr01.
            w_final-usr02 = prps-usr02.
            w_final-usr03 = prps-usr03.
*            w_final-netwr = vbrp-netwr.

            SELECT SINGLE poski
              FROM prps
              INTO w_final-poski
              WHERE pspnr = vbrp-ps_psp_pnr.


            CASE vbrk-fkart.
              WHEN 'F2' OR 'L2'.
                w_final-dctyp = 'Invoice'.
*              WHEN 'L2'.
*                w_final-dctyp = 'Debit Memo'.
              WHEN 'ZG2'.
                w_final-dctyp = 'Credit Note'.
              WHEN 'ZL2'.
                w_final-dctyp = 'Debit Note'.
              WHEN 'S1'.
                w_final-dctyp = 'Cancelled Invoices'.
            ENDCASE.

            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-fkdat
              IMPORTING
                output = w_final-mask_fkdat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_fkdat WITH '/'.


            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-budat
              IMPORTING
                output = w_final-mask_budat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_budat WITH '/'.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                  kposn = vbrp-posnr
                                                  kschl = 'ZDSF'.
            IF sy-subrc = 0.
*              w_final-dismt = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSER'.

            IF sy-subrc = 0.
              w_final-zser = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCST'.

            IF sy-subrc = 0.
              w_final-zcst = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCSW'.

            IF sy-subrc = 0.
              w_final-zcsw = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSBC'.

            IF sy-subrc = 0.
              w_final-zsbc = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZVAT'.

            IF sy-subrc = 0.
              w_final-zvat = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZDIS'.
            IF sy-subrc = 0.
              w_final-dis = konv-kwert.
              w_final-disr = konv-kbetr.
*              w_final-curr = konv-waers.
            ENDIF.
            w_final-kunnr = vbrk-kunag.
            w_final-kunam = kna1-name1.
*            w_final-waerk = vbrk-waerk.

            w_final-l_twaers = w_final-dmbtr + w_final-mwsts - w_final-sknto.
            w_final-d_twaers = w_final-dmbtr + w_final-wmwst - w_final-wskto.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
      PERFORM get_condition_final.
      IF w_final IS NOT INITIAL.
        COLLECT w_final INTO t_final.
        SORT t_final ASCENDING BY bukrs gjahr fkdat budat.
        DESCRIBE TABLE t_final.
        n = sy-tfill.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF rb3 = 'X'.                                                                   "Not Cleared Items
    document_st = 'Not_Cleared_Items'.
    LOOP AT t_bsid INTO bsid.
      LOOP AT t_vbrk INTO vbrk WHERE vbeln = bsid-vbeln.
        w_final-sfakn = vbrk-sfakn.

        CREATE OBJECT o_dis
          EXPORTING
            v_billing_document = vbrk-vbeln.

        REFRESH it_dis.
        CALL METHOD o_dis->zif_dis_report~get_final_report
          IMPORTING
            it_dis = it_dis.

        LOOP AT t_vbrp INTO vbrp WHERE vbeln = vbrk-vbeln.
          CLEAR:w_final,kna1,prps,proj.
          SELECT SINGLE * FROM kna1 WHERE kunnr = vbrk-kunag.
          SELECT SINGLE * FROM prps WHERE pspnr = vbrp-ps_psp_pnr.
          SELECT SINGLE * FROM proj WHERE pspnr = prps-psphi.
          SELECT SINGLE * FROM bkpf WHERE belnr = w_bseg-belnr
                                      AND bukrs = w_bseg-bukrs
                                      AND gjahr = w_bseg-gjahr.

          w_final-kurs2  = bkpf-kurs2.
          w_final-hwae2  = bkpf-hwae2.
          w_final-hwae2d = bkpf-hwaer.

          IF vbrk-sfakn IS NOT INITIAL.
            SELECT SINGLE belnr bukrs gjahr
              FROM bseg
              INTO (w_final-cbelnr, w_final-cbukrs, w_final-cgjahr)
              WHERE vbeln = vbrk-sfakn.
          ENDIF.

          SELECT SINGLE budat waers hwaer kursf
          INTO (w_final-budat, w_final-waers, w_final-hwaer, w_final-kursf)
          FROM bkpf
          WHERE xblnr = vbrk-vbeln.

          PERFORM read_sow_name.
          PERFORM read_header_text.
          w_final-belnr = bsid-belnr.
          w_final-vbeln = bsid-vbeln.
          w_final-bukrs = bsid-bukrs.
          w_final-gjahr = bsid-gjahr.

          w_final-wrbtr = bsid-wrbtr.
          w_final-dmbtr = bsid-dmbtr.
          w_final-wskto = bsid-wskto.
          w_final-wmwst = bsid-wmwst.
          w_final-sknto = bsid-sknto.
          w_final-mwsts = bsid-mwsts.
          w_final-augdt = bsid-augdt.

          SELECT SINGLE augcp
             INTO w_final-augcp
             FROM bseg
            WHERE bukrs = bsid-belnr
              AND belnr = bsid-belnr
              AND gjahr = bsid-gjahr.

          CASE vbrk-fkart.
            WHEN 'F2' OR 'L2'.
              w_final-dctyp = 'Invoice'.
*            WHEN 'L2'.
*              w_final-dctyp = 'Debit Memo'.
            WHEN 'ZG2'.
              w_final-dctyp = 'Credit Note'.
            WHEN 'ZL2'.
              w_final-dctyp = 'Debit Note'.
            WHEN 'S1'.
              w_final-dctyp = 'Cancelled Invoices'.
          ENDCASE.

          LOOP AT t_vbfa INTO vbfa WHERE vbeln = vbrk-vbeln.
            w_final-vbelv = vbfa-vbelv.
            w_final-fkdat = vbrk-fkdat.
            w_final-usr01 = prps-usr01.
            w_final-usr02 = prps-usr02.
            w_final-usr03 = prps-usr03.
*            w_final-netwr = vbrp-netwr.
*****************PROJ-PSPNR = PRPS-PSPHI
            w_final-pspnr = proj-pspnr.
            w_final-psptx = proj-post1.
            w_final-posnr = vbrp-ps_psp_pnr.
            w_final-postx = prps-post1.

            SELECT SINGLE poski
                FROM prps
                INTO w_final-poski
                WHERE pspnr = vbrp-ps_psp_pnr.

            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-fkdat
              IMPORTING
                output = w_final-mask_fkdat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_fkdat WITH '/'.


            CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
              EXPORTING
                input  = w_final-budat
              IMPORTING
                output = w_final-mask_budat.

            REPLACE ALL OCCURRENCES OF '.' IN w_final-mask_budat WITH '/'.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                  kposn = vbrp-posnr
                                                  kschl = 'ZDSF'.
            IF sy-subrc = 0.
*              w_final-dismt = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSER'.

            IF sy-subrc = 0.
              w_final-zser = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCST'.

            IF sy-subrc = 0.
              w_final-zcst = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZCSW'.

            IF sy-subrc = 0.
              w_final-zcsw = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZSBC'.

            IF sy-subrc = 0.
              w_final-zsbc = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                                 kposn =  vbrp-posnr
                                                 kschl = 'ZVAT'.

            IF sy-subrc = 0.
              w_final-zvat = konv-kwert.
            ENDIF.

            READ TABLE t_konv INTO konv WITH KEY knumv =  vbrk-knumv
                                               kposn = vbrp-posnr
                                               kschl = 'ZDIS'.
            IF sy-subrc = 0.
              w_final-dis = konv-kwert.
              w_final-disr = konv-kbetr.
*              w_final-curr = konv-waers.
            ENDIF.
            w_final-kunnr = vbrk-kunag.
            w_final-kunam = kna1-name1.
*            w_final-waerk = vbrk-waerk.

            w_final-l_twaers = w_final-dmbtr + w_final-mwsts - w_final-sknto.
            w_final-d_twaers = w_final-dmbtr + w_final-wmwst - w_final-wskto.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
      PERFORM get_condition_final.
      IF w_final IS NOT INITIAL.
        COLLECT w_final INTO t_final.
        SORT t_final ASCENDING BY bukrs gjahr fkdat budat.
        DESCRIBE TABLE t_final.
        n = sy-tfill.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM t_final COMPARING ALL FIELDS.
ENDFORM.                    " GET_BH_FINAL
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_list .
  PERFORM build_fieldcat.
  PERFORM top-of-page  USING t_list_top_of_page.
  PERFORM build_layout USING is_layout.
  PERFORM display_list.
ENDFORM.                    " DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  READ_SOW_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_sow_name .
  CLEAR:txtid,txtnm,txtob,tline.
  REFRESH tline.

  txtid = '0002'.
  txtnm = vbrk-vbeln.
  txtob = 'VBBK'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = txtid
      language                = sy-langu
      name                    = txtnm
      object                  = txtob
    TABLES
      lines                   = tline
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE tline INDEX 1.
  w_final-sownm = tline-tdline.

ENDFORM.                    " READ_SOW_NAME
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout USING ps_layout TYPE slis_layout_alv.
  gd_layout-cwidth_opt = 'X'.
  gd_layout-zebra      = 'X'.
  APPEND wa_exclude TO it_exclude.
ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcat .
  PERFORM insert_fieldcat USING:
                                 'VBELV'  'Sales Order No.'        'X'   space space       space   space space 'X'    space,
                                 'VBELN'  space                    'X'   space 'VBRK'      'VBELN' space space 'X'    space,
                                 'BUKRS'  space                    space space 'BSEG'      'BUKRS' space space 'X'    space,
                                 'GJAHR'  space                    space space 'BSEG'      'GJAHR' space space 'X'    space,
                                 'BELNR'  space                    'X'   space 'BSEG'      'BELNR' space space 'X'    space,
                                 'SFAKN'  space                    'X'   space 'VBRK'      'SFAKN' space space 'X'    space,
                                'CBELNR'  'Cancel ref. doc.no'     'X'   space  space       space  space space 'X'    space,
                                 'DCTYP'  'Billing Type'           space space space       space   space space 'X'    space,
                                 'FKDAT'  space                    space space 'VBRK'      'FKDAT' space space space  space,
                                 'BUDAT'  space                    space space 'BKPF'      'BUDAT' space space space  space,
                                 'AUGCP'  space                    space space 'BSEG'      'AUGCP' space space space  space,
                                 'AUGDT'  space                    space space 'BSEG'      'AUGDT' space space space  space,
                                 'PSPNR'  space                    space space 'PROJ'      'PSPNR' space space space  space,
                                 'PSPTX'  'Project Description'    space space 'PRPS'      'POST1' space space space  space,
                                 'HTEXT'  'Biling Month'           space space  space       space space space space  space,
                                 'POSNR'  space                    space space 'PRPS'      'PSPNR' space space space  space,
                                 'POSTX'  'WBS Description'        space space 'PRPS'      'POST1' space space space  space,
************************************************************
**                                'SOWNM'  'SOW Name'               space space space       space   space space space  space,
*                                 'CONMT'  'Confirm Amt.'           space space space       space   space space space  space,
*                                 'DISMT'  'Discount(ZDSF)'         space space space       space   space space space  space,
*                                 'DIS'    'Penalty Discount(ZDIS)' space space space       space   space space space  space,
*                                 'NETWR'  space                    space space 'VBRP'      'NETWR' space space space  space,
*                                 'DMBT2'  'Amount In Loc Curr 2'   space space space        space  space space space  space,
*                                 'WAERK'  space                    space space 'VBRK'      'WAERK' space space space  space,
***************************************************  Local Currency
                                 'WAERS'  'Loc Currency'            space space space        space space space space  space,
                                 'DMBTR'  'Amount In Loc Curr'      space space space        space  space space space  space,
                                 'SKNTO'  'Discount In Loc Curr.'   space space space        space  space space space  space,
                                 'MWSTS'  'Tax In Loc Curr'         space space space        space  space space space  space,
                              'D_TWAERS'  'Total in Loc. Curr'      space space space        space  space space space  space,
*************************************************
                                 'KURSF'  'Exchange Rate'           space space space        space space space space  space,
**************************************************** Document Currency
                                 'HWAER'  'Doc Curr'                space space space        space  space space space  space,
                                 'WRBTR'  'Amount In Doc Curr'      space space space        space space space space  space,
                                 'WSKTO'  'Discount In Doc Curr.'   space space space        space space space space  space,
                                 'WMWST'  'Tax In Doc Curr.'        space space space        space space space space  space,
                              'D_TWAERS'  'Total in Doc. Curr'      space space space        space  space space space  space,
*                                 'CURR'   'Unit'                   space space space       space   space space space  space,
                                 'KUNNR'  space                     space space 'KNA1'      'KUNNR' space space space  space,
                                 'KUNAM'  'Customer Name'           space space space        space  space space space  space,
                                 'USR01'  space                     space space 'PRPS'      'USR01' space space space  space,
                                 'USR02'  space                     space space 'PRPS'      'USR02' space space space  space,
                                 'USR03'  space                     space space 'PRPS'      'USR03' space space space  space,
                                 'GEOAR'  space                     space space 'PRPS'      'GEOAR' space space space  space,
                                'HWAE2'  'Group Currency'           space space  space       space  space space space  space,
                                 'ZDSF'  'Round off'                space space  space       space  space space space  space,
                                 'ZOTR'  'One time revenue'         space space  space       space  space space space  space,
                                 'ZDIS'  'SLA Penalty'              space space  space       space  space space space  space,
                                 'ZDNT'  'IT Downtime'              space space  space       space  space space space  space,
                                 'ZFRD'  'Discount Fraud'           space space  space       space  space space space  space,
                                 'ZAER'  'Discount Agent Error'     space space  space       space  space space space  space,
                                 'ZSER'  'Service Tax'              space space  space       space  space space space  space,
                                 'ZCST'  'CST With C Form'          space space  space       space  space space space  space,
                                 'ZCSW'  'CST Without C Form'       space space  space       space  space space space  space,
                                 'ZSBC'  'Swacch Bharat Tax'        space space  space       space  space space space  space,
                                 'ZVAT'  'VAT'                      space space  space       space  space space space  space,
                                'HWAE2D'  'Document Currency'                 space space  space       space  space space space  space,
                                 'ZDSFD'  'Document Round off'                space space  space       space  space space space  space,
                                 'ZOTRD'  'Document One time revenue'         space space  space       space  space space space  space,
                                 'ZDISD'  'Document SLA Penalty'              space space  space       space  space space space  space,
                                 'ZDNTD'  'Document IT Downtime'              space space  space       space  space space space  space,
                                 'ZFRDD'  'Document Discount Fraud'           space space  space       space  space space space  space,
                                 'ZAERD'  'Document Discount Agent Error'     space space  space       space  space space space  space,
                                 'ZSERD'  'Document Service Tax'              space space  space       space  space space space  space,
                                 'ZCSTD'  'Document CST With C Form'          space space  space       space  space space space  space,
                                 'ZCSWD'  'Document CST Without C Form'       space space  space       space  space space space  space,
                                 'ZSBCD'  'Document Swacch Bharat Tax'        space space  space       space  space space space  space,
                                 'ZVATD'  'Document VAT'                      space space  space       space  space space space  space,
*                                 'SERLN'  space                    space space 'PRPS'      'SERLN' space space space  space,
                                 'OPFIL'  'O/P Type'                space space 'ZTKSCHL'   'ZKSCHL'   'X'   space space  'X'.
ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_list .

  CONCATENATE 'Customer billing analysis report [' n ' Hits]' INTO title.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                =
*     I_BUFFER_ACTIVE                   =
     i_callback_program                = gv_repid
     i_callback_pf_status_set          = 'SET_PF_STATUS'
     i_callback_user_command           = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
     i_grid_title                      = title
*     I_GRID_SETTINGS                   =
     is_layout_lvc                     = gd_layout
     it_fieldcat_lvc                   = it_fieldcat
     it_excluding                      = it_exclude
*     IT_SPECIAL_GROUPS_LVC             =
*     IT_SORT_LVC                       =
*     IT_FILTER_LVC                     =
*     IT_HYPERLINK                      =
*     IS_SEL_HIDE                       =
     i_default                         = 'X'
     i_save                            = 'A'
     is_variant                        = g_variant
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT_LVC                      =
*     IS_REPREP_ID_LVC                  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 =
*     I_HTML_HEIGHT_END                 =
*     IT_ALV_GRAPHICS                   =
*     IT_EXCEPT_QINFO_LVC               =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          = t_final
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISPLAY_LIST
*&---------------------------------------------------------------------*
*&      Form  INSERT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0928   text
*      -->P_SPACE  text
*      -->P_0930   text
*      -->P_SPACE  text
*      -->P_0932   text
*      -->P_0933   text
*----------------------------------------------------------------------*
FORM insert_fieldcat  USING    value(p_field)
                               value(p_fname)
                               p_hotp
                               p_no_out
                               p_rtab
                               p_rfield
                               p_edit
                               p_width
                               p_fixed
                               p_help.

  wa_fieldcat-fieldname     = p_field.
  wa_fieldcat-reptext       = p_fname.
  wa_fieldcat-hotspot       = p_hotp.
  wa_fieldcat-no_out        = p_no_out.
  wa_fieldcat-ref_field     = p_rfield.
  wa_fieldcat-ref_table     = p_rtab.
  wa_fieldcat-edit          = p_edit.
  wa_fieldcat-outputlen     = p_width.
  wa_fieldcat-fix_column    = p_fixed.
  wa_fieldcat-f4availabl    = p_help.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
ENDFORM.                    " INSERT_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F4_HELP_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_help_variant .
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.                    " F4_HELP_VARIANT
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen .
  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant = gx_variant.
  ELSE.
    PERFORM initialize_variant.
  ENDIF.
ENDFORM.                    " PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  INITIALIZE_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_variant .
  g_save = 'A'.
  gv_repid =  sy-repid.
  CLEAR g_variant.
  g_variant-report = gv_repid.
  gx_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.
ENDFORM.                    " INITIALIZE_VARIANT
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_UCOMM       text
*      -->RS_SELFIELED  text
*----------------------------------------------------------------------*
FORM user_command USING p_ucomm TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE p_ucomm.
    WHEN '&IC1'.
      CASE rs_selfield-fieldname.
        WHEN 'VBELN'.
          IF rs_selfield-sel_tab_field = '1-VBELN'.
            READ TABLE t_final INTO w_final INDEX rs_selfield-tabindex.
            IF sy-subrc = 0.
              SET PARAMETER ID 'VF' FIELD w_final-vbeln.
              CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN 'BELNR'.
          READ TABLE t_final INTO w_final INDEX rs_selfield-tabindex.
          IF sy-subrc = 0.
            SET PARAMETER ID 'BLN' FIELD  w_final-belnr.
            SET PARAMETER ID 'BUK' FIELD  w_final-bukrs.
            SET PARAMETER ID 'GJR' FIELD  w_final-gjahr.
          ENDIF.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

        WHEN 'CBELNR'.
          READ TABLE t_final INTO w_final INDEX rs_selfield-tabindex.
          IF sy-subrc = 0.
            SET PARAMETER ID 'BLN' FIELD  w_final-cbelnr.
            SET PARAMETER ID 'BUK' FIELD  w_final-cbukrs.
            SET PARAMETER ID 'GJR' FIELD  w_final-cgjahr.
          ENDIF.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

        WHEN 'VBELV'.
          READ TABLE t_final INTO w_final INDEX rs_selfield-tabindex.
          IF sy-subrc = 0.
            SET PARAMETER ID: 'AUN' FIELD  w_final-vbelv.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'SFAKN'.
          READ TABLE t_final INTO w_final INDEX rs_selfield-tabindex.
          IF sy-subrc = 0.
            SET PARAMETER ID 'VF' FIELD w_final-sfakn.
            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
***********************************Downloading the templete for invoicing
    WHEN '&DOWN'.
      PERFORM get_current_month.
      PERFORM check_for_alv_update.
      PERFORM get_excel_final USING p_ucomm.
      PERFORM save_template.

    WHEN '&INV'.
      PERFORM get_current_month.
      PERFORM check_for_alv_update.
      PERFORM get_excel_final USING p_ucomm.
      PERFORM get_form_name.

    WHEN '&REP'.
      PERFORM get_current_month.
      PERFORM check_for_alv_update.
      PERFORM download_report.
  ENDCASE.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  TOP-OF-PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_LIST_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM top-of-page  USING p_t_list_top_of_page.
  DATA: title1 LIKE sy-title,
        title2 LIKE sy-title.
  title2 = report_name.
  DATA: ls_line TYPE slis_listheader.
  DATA: top_date(10) TYPE c.
  CLEAR ls_line.
ENDFORM.                    " TOP-OF-PAGE
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_list_top_of_page.
ENDFORM. "TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS status EXCLUDING rt_extab.
ENDFORM.                    "set_pf_status
*&---------------------------------------------------------------------*
*&      Form  GET_START_END_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_start_end_date .
  run_date = sy-datum.
  CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
    EXPORTING
      iv_date             = run_date
    IMPORTING
      ev_month_begin_date = v_sdate
      ev_month_end_date   = v_edate.

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      input  = v_sdate
    IMPORTING
      output = v_osdate.

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      input  = v_edate
    IMPORTING
      output = v_oedate.

ENDFORM.                    " GET_START_END_DATE

*&---------------------------------------------------------------------*
*&      Form  call_form_inv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_form_inv .

  CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
    EXPORTING
      i_language    = v_language
      i_application = 'SAPDEFAULT'
    IMPORTING
      e_devtype     = v_e_devtype.
  st_output_options-tdprinter     = v_e_devtype.
  st_control_parameters-no_dialog = 'X'.
  st_control_parameters-getotf    = 'X'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = formname
*     variant            = ' '
*     direct_call        = ' '
    IMPORTING
      fm_name            = lf_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  CALL FUNCTION lf_fm_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      control_parameters   = st_control_parameters
*     MAIL_APPL_OBJ        =
*     MAIL_RECIPIENT       =
*     MAIL_SENDER          =
      output_options       = st_output_options
*     USER_SETTINGS        = 'X'
      l_vbeln              = w_excel-vbeln
      l_for_m              = w_excel-f2
      opt1                 = w_excel-f3
      program              = 'ZSD_INV_PRT'
    IMPORTING
      document_output_info = st_document_output_info
      job_output_info      = st_job_output_info
      job_output_options   = st_job_output_options
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*.........................CONVERT TO OTF TO PDF.......................*
  CALL FUNCTION 'CONVERT_OTF_2_PDF'
    IMPORTING
      bin_filesize           = v_bin_filesize
    TABLES
      otf                    = st_job_output_info-otfdata
      doctab_archive         = it_docs
      lines                  = it_lines
    EXCEPTIONS
      err_conv_not_possible  = 1
      err_otf_mc_noendmarker = 2
      OTHERS                 = 3.

*........................GET THE FILE NAME TO STORE....................*
*  CONCATENATE: w_excel-f2 '_' w_excel-belnr '.pdf' INTO v_name.
  CONCATENATE: w_excel-belnr '.pdf' INTO v_name.
  CONCATENATE  d_loc '\' w_excel-gjahr '\' w_excel-bukrs '\' v_name INTO v_fullpath.

*..................................DOWNLOAD AS FILE....................*
  MOVE v_fullpath TO v_filename.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = v_bin_filesize
      filename                = v_filename
      filetype                = 'BIN'
    TABLES
      data_tab                = it_lines
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

ENDFORM.                    " CALL_FORM_INV
*&---------------------------------------------------------------------*
*&      Form  GET_CURRENT_MONTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_current_month .


  CALL FUNCTION 'CACS_DATE_GET_YEAR_MONTH'
    EXPORTING
      i_date  = sy-datum
    IMPORTING
      e_month = v_month
      e_year  = v_year.

  CASE v_month.
    WHEN 01. l_monthname = 'January'.
    WHEN 02. l_monthname = 'February'.
    WHEN 03. l_monthname = 'March'.
    WHEN 04. l_monthname = 'April'.
    WHEN 05. l_monthname = 'May'.
    WHEN 06. l_monthname = 'June'.
    WHEN 07. l_monthname = 'July'.
    WHEN 08. l_monthname = 'August'.
    WHEN 09. l_monthname = 'Aeptember'.
    WHEN 10. l_monthname = 'October'.
    WHEN 11. l_monthname = 'November'.
    WHEN 12. l_monthname = 'December'.
  ENDCASE.

  PERFORM get_current_fiscal_year.

**********default_month
  this_month = l_monthname.
  SHIFT v_year RIGHT CIRCULAR BY 2 PLACES.
  this_year = v_year.
  CONCATENATE this_month this_year INTO default_month SEPARATED BY ''''.
************************************************************************************

ENDFORM.                    " GET_CURRENT_MONTH
*&---------------------------------------------------------------------*
*&      Form  GET_EXCEL_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_excel_final USING value(p_ucomm).
  LOOP AT t_final INTO w_final WHERE opfil = 'RD00'.
    w_excel-bukrs = w_final-bukrs.
    w_excel-gjahr = w_final-gjahr.
    w_excel-belnr = w_final-belnr.
    w_excel-f1    = w_final-opfil.

    IF w_final-mofil IS INITIAL.
      w_excel-f2    = default_month.
    ELSE.
      w_excel-f2    = w_final-mofil.
    ENDIF.

    w_excel-f3    = 'X'.

    IF p_ucomm = '&INV'.
      w_excel-vbeln = w_final-vbeln.
    ENDIF.
    APPEND w_excel TO t_excel.
    CLEAR: w_excel, w_final.
  ENDLOOP.

  LOOP AT t_final INTO w_final WHERE opfil = 'RD01'.
    w_excel-bukrs = w_final-bukrs.
    w_excel-gjahr = w_final-gjahr.
    w_excel-belnr = w_final-belnr.
    w_excel-f1    = w_final-opfil.

    IF w_final-mofil IS INITIAL.
      w_excel-f2    = default_month.
    ELSE.
      w_excel-f2    = w_final-mofil.
    ENDIF.

    w_excel-f3    = 'X'.

    IF p_ucomm = '&INV'.
      w_excel-vbeln = w_final-vbeln.
    ENDIF.
    APPEND w_excel TO t_excel.
    CLEAR: w_excel, w_final.
  ENDLOOP.

  LOOP AT t_final INTO w_final WHERE opfil = 'RD02'.
    w_excel-bukrs = w_final-bukrs.
    w_excel-gjahr = w_final-gjahr.
    w_excel-belnr = w_final-belnr.
    w_excel-f1    = w_final-opfil.

    IF w_final-mofil IS INITIAL.
      w_excel-f2    = default_month.
    ELSE.
      w_excel-f2    = w_final-mofil.
    ENDIF.

    w_excel-f3    = 'X'.

    IF p_ucomm = '&INV'.
      w_excel-vbeln = w_final-vbeln.
    ENDIF.
    APPEND w_excel TO t_excel.
    CLEAR: w_excel, w_final.
  ENDLOOP.

  LOOP AT t_final INTO w_final WHERE opfil = 'RD03'.
    w_excel-bukrs = w_final-bukrs.
    w_excel-gjahr = w_final-gjahr.
    w_excel-belnr = w_final-belnr.
    w_excel-f1    = w_final-opfil.

    IF w_final-mofil IS INITIAL.
      w_excel-f2    = default_month.
    ELSE.
      w_excel-f2    = w_final-mofil.
    ENDIF.

    w_excel-f3    = 'X'.

    IF p_ucomm = '&INV'.
      w_excel-vbeln = w_final-vbeln.
    ENDIF.
    APPEND w_excel TO t_excel.
    CLEAR: w_excel, w_final.
  ENDLOOP.

  LOOP AT t_final INTO w_final WHERE opfil = 'RD04'.
    w_excel-bukrs = w_final-bukrs.
    w_excel-gjahr = w_final-gjahr.
    w_excel-belnr = w_final-belnr.
    w_excel-f1    = w_final-opfil.

    IF w_final-mofil IS INITIAL.
      w_excel-f2    = default_month.
    ELSE.
      w_excel-f2    = w_final-mofil.
    ENDIF.

    w_excel-f3    = 'X'.

    IF p_ucomm = '&INV'.
      w_excel-vbeln = w_final-vbeln.
    ENDIF.
    APPEND w_excel TO t_excel.
    CLEAR: w_excel, w_final.

  ENDLOOP.
ENDFORM.                    " GET_EXCEL_FINAL
*&---------------------------------------------------------------------*
*&      Form  CHECK_FOR_ALV_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_alv_update .
  DATA: ref_grid TYPE REF TO cl_gui_alv_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data .
  ENDIF.
ENDFORM.                    " CHECK_FOR_ALV_UPDATE
*&---------------------------------------------------------------------*
*&      Form  GET_CURRENT_FISCAL_YEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_current_fiscal_year .
*      CLEAR:i_fy.
*
*      CALL FUNCTION 'GM_GET_FISCAL_YEAR'
*        EXPORTING
*          i_date                     = run_date
*          i_fyv                      = 'V3'
*        IMPORTING
*          e_fy                       = i_fy
*        EXCEPTIONS
*          fiscal_year_does_not_exist = 1
*          not_defined_for_date       = 2
*          OTHERS                     = 3.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*      MOVE i_fy TO v_year .
ENDFORM.                    " GET_CURRENT_FISCAL_YEAR
*&---------------------------------------------------------------------*
*&      Form  GET_FORM_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_form_name .
  LOOP AT t_excel INTO w_excel.
    CASE w_excel-f1.
      WHEN 'RD00'.
        formname = 'ZSD_INV_TNM'.
        PERFORM call_form_inv.
      WHEN 'RD01'.
        formname = 'ZSD_INV_FXD'.
        PERFORM call_form_inv.
      WHEN 'RD02'.
        formname = 'ZSD_INV_UKF'.
        PERFORM call_form_inv.
      WHEN 'RD03'.
        formname = 'ZSD_INV_TM2'.
        PERFORM call_form_inv.
      WHEN 'RD04'.
        formname = 'ZSD_INV_DCR'.
        PERFORM call_form_inv.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " GET_FORM_NAME
*&---------------------------------------------------------------------*
*&      Form  SAVE_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_template .

  LOOP AT t_final INTO w_final.
    CONCATENATE w_final-gjahr l_monthname document_st 'as_on' sy-datum INTO v_l_monthname SEPARATED BY '_'.
    CONCATENATE v_l_monthname 'xls' INTO file_name SEPARATED BY '.'.
    CLEAR w_final.
  ENDLOOP.

  DATA location TYPE string.
  CONCATENATE d_loc '\Templetes\' file_name INTO location.

  CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                        = location
        filetype                        = 'ASC'
        append                          = ' '
        write_field_separator           = 'X'
        header                          = '00'
        trunc_trailing_blanks           = ' '
        write_lf                        = 'X'
        col_select                      = ' '
        col_select_mask                 = ' '
        dat_mode                        = ' '
        confirm_overwrite               = ' '
        no_auth_check                   = ' '
        codepage                        = ' '
        ignore_cerr                     = abap_true
        replacement                     = '#'
        write_bom                       = ' '
        trunc_trailing_blanks_eol       = 'X'
        wk1_n_format                    = ' '
        wk1_n_size                      = ' '
        wk1_t_format                    = ' '
        wk1_t_size                      = ' '
        write_lf_after_last_line        = abap_true
        show_transfer_status            = abap_true
*        IMPORTING
*          filelength                      =
      TABLES
        data_tab                        = t_excel
        fieldnames                      = t_field
  EXCEPTIONS
    file_write_error                = 1
    no_batch                        = 2
    gui_refuse_filetransfer         = 3
    invalid_type                    = 4
    no_authority                    = 5
    unknown_error                   = 6
    header_not_allowed              = 7
    separator_not_allowed
    filesize_not_allowed            = 9
    header_too_long                 = 10
    dp_error_create                 = 11
    dp_error_send                   = 12
    dp_error_write                  = 13
    unknown_dp_error                = 14
    access_denied                   = 15
    dp_out_of_memory                = 16
    disk_full                       = 17
    dp_timeout                      = 18
    file_not_found                  = 19
    dataprovider_exception          = 20
    control_flush_error             = 21
    OTHERS                          = 22
              .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SAVE_TEMPLATE
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_report .
  LOOP AT t_final INTO w_final.
    CONCATENATE w_final-gjahr l_monthname document_st 'as_on' sy-datum INTO v_l_monthname SEPARATED BY '_'.
    CONCATENATE v_l_monthname 'xls' INTO file_name SEPARATED BY '.'.
**********************
    MOVE-CORRESPONDING w_final TO w_report.
    APPEND w_report TO t_report.
    CLEAR: w_final,prps.
  ENDLOOP.

  DATA location TYPE string.
  CONCATENATE d_loc '\Reports\' file_name INTO location.

  CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                        = location
        filetype                        = 'ASC'
        append                          = ' '
        write_field_separator           = 'X'
        header                          = '00'
        trunc_trailing_blanks           = ' '
        write_lf                        = 'X'
        col_select                      = ' '
        col_select_mask                 = ' '
        dat_mode                        = ' '
        confirm_overwrite               = ' '
        no_auth_check                   = ' '
        codepage                        = ' '
        ignore_cerr                     = abap_true
        replacement                     = '#'
        write_bom                       = ' '
        trunc_trailing_blanks_eol       = 'X'
        wk1_n_format                    = ' '
        wk1_n_size                      = ' '
        wk1_t_format                    = ' '
        wk1_t_size                      = ' '
        write_lf_after_last_line        = abap_true
        show_transfer_status            = abap_true
*        IMPORTING
*          filelength                      =
      TABLES
        data_tab                        = t_report
        fieldnames                      = rep_field
  EXCEPTIONS
    file_write_error                = 1
    no_batch                        = 2
    gui_refuse_filetransfer         = 3
    invalid_type                    = 4
    no_authority                    = 5
    unknown_error                   = 6
    header_not_allowed              = 7
    separator_not_allowed
    filesize_not_allowed            = 9
    header_too_long                 = 10
    dp_error_create                 = 11
    dp_error_send                   = 12
    dp_error_write                  = 13
    unknown_dp_error                = 14
    access_denied                   = 15
    dp_out_of_memory                = 16
    disk_full                       = 17
    dp_timeout                      = 18
    file_not_found                  = 19
    dataprovider_exception          = 20
    control_flush_error             = 21
    OTHERS                          = 22
              .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " DOWNLOAD_REPORT
*&---------------------------------------------------------------------*
*&      Form  GET_REPORT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_report_header .
*************************  Excel Report Header
********* Field 1
  CLEAR rep_field.
  rep_field-field_name = 'Sales Order No'.
  APPEND rep_field.

********* Field 2
  CLEAR rep_field.
  rep_field-field_name = 'Billing Document'.
  APPEND rep_field.

********* Field 3
  CLEAR rep_field.
  rep_field-field_name = 'Company code'.
  APPEND rep_field.

********* Field 4
  CLEAR rep_field.
  rep_field-field_name = 'Year'.
  APPEND rep_field.

********* Field 5
  CLEAR rep_field.
  rep_field-field_name = 'Document Number'.
  APPEND rep_field.

********* Field 29 "added on 09-11-2015
  CLEAR rep_field.
  rep_field-field_name = 'Last Billed Month'.
  APPEND rep_field.


********* Field 6
  CLEAR rep_field.
  rep_field-field_name = 'Billing Type'.
  APPEND rep_field.

********* Field 7
  CLEAR rep_field.
  rep_field-field_name = 'Billing Date'.
  APPEND rep_field.

********* Field 8
  CLEAR rep_field.
  rep_field-field_name = 'Posting Date'.
  APPEND rep_field.

********* Field 9
  CLEAR rep_field.
  rep_field-field_name = 'Project Description'.
  APPEND rep_field.

********* Field 10
  CLEAR rep_field.
  rep_field-field_name = 'WBS Element'.
  APPEND rep_field.

********* Field 11
  CLEAR rep_field.
  rep_field-field_name = 'Local Currency'.
  APPEND rep_field.

********* Field 12
  CLEAR rep_field.
  rep_field-field_name = 'Amount in Local Currency'.
  APPEND rep_field.

********* Field 13
  CLEAR rep_field.
  rep_field-field_name = 'Discount in Local Currency'.
  APPEND rep_field.

********* Field 14
  CLEAR rep_field.
  rep_field-field_name = 'Tax in Local Currency'.
  APPEND rep_field.

********* Field 15
  CLEAR rep_field.
  rep_field-field_name = 'Total in Local Currency'.
  APPEND rep_field.

********* Field 16
  CLEAR rep_field.
  rep_field-field_name = 'Exchange Rate'.
  APPEND rep_field.

********* Field 17
  CLEAR rep_field.
  rep_field-field_name = 'Document Currency'.
  APPEND rep_field.

********* Field 18
  CLEAR rep_field.
  rep_field-field_name = 'Amount in Document Currency'.
  APPEND rep_field.

********* Field 19
  CLEAR rep_field.
  rep_field-field_name = 'Discount in Document Currency'.
  APPEND rep_field.

********* Field 20
  CLEAR rep_field.
  rep_field-field_name = 'Tax in Document Currency'.
  APPEND rep_field.

********* Field 21
  CLEAR rep_field.
  rep_field-field_name = 'Total in Document Currency'.
  APPEND rep_field.

********* Field 22
  CLEAR rep_field.
  rep_field-field_name = 'Customer'.
  APPEND rep_field.

********* Field 23
  CLEAR rep_field.
  rep_field-field_name = 'Customer Name'.
  APPEND rep_field.

********* Field 24
  CLEAR rep_field.
  rep_field-field_name = 'Vertical'.
  APPEND rep_field.

********* Field 25
  CLEAR rep_field.
  rep_field-field_name = 'Client'.
  APPEND rep_field.

********* Field 26
  CLEAR rep_field.
  rep_field-field_name = 'Billing Model'.
  APPEND rep_field.

********* Field 27
  CLEAR rep_field.
  rep_field-field_name = 'Geography'.
  APPEND rep_field.
ENDFORM.                    " GET_REPORT_HEADER
*&---------------------------------------------------------------------*
*&      Form  READ_HEADER_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_header_text .
  DATA: txtid TYPE thead-tdid.
  DATA: txtnm TYPE thead-tdname.
  DATA: txobj TYPE thead-tdobject.
  DATA: dline TYPE STANDARD TABLE OF tline.
  DATA: waline TYPE tline.

  txtid = 'BILM'.
  txtnm = vbrk-vbeln .
  txobj = 'VBBK'.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = txtid
      language                = sy-langu
      name                    = txtnm
      object                  = txobj
    TABLES
      lines                   = dline
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE dline INTO waline INDEX 1.
  w_final-htext = waline-tdline.
  CLEAR waline.
  REFRESH dline.
ENDFORM.                    " READ_HEADER_TEXT
**&---------------------------------------------------------------------*
**&      Form  GET_CONDITION_FINAL
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM get_condition_final .
  DATA: v_kurs2  TYPE string.

  MOVE w_final-kurs2 TO v_kurs2.
  LOOP AT it_dis INTO wa_dis.
    REPLACE ALL OCCURRENCES OF '-' IN v_kurs2 WITH space.
    REPLACE ALL OCCURRENCES OF '/' IN v_kurs2 WITH space.
    CONDENSE v_kurs2.

    w_final-zdsfd = wa_dis-zdsf.
    w_final-zotrd = wa_dis-zotr.
    w_final-zdisd = wa_dis-zdis.
    w_final-zdntd = wa_dis-zdnt.
    w_final-zfrdd = wa_dis-zfrd.
    w_final-zaerd = wa_dis-zaer.
    w_final-zserd = w_final-zser.
    w_final-zcstd = w_final-zcst.
    w_final-zcswd = w_final-zcsw.
    w_final-zsbcd = w_final-zsbc.
    w_final-zvatd = w_final-zvat.

    IF v_kurs2 NE 0.
      w_final-zdsf = wa_dis-zdsf / v_kurs2.
      w_final-zotr = wa_dis-zotr / v_kurs2.
      w_final-zdis = wa_dis-zdis / v_kurs2.
      w_final-zdnt = wa_dis-zdnt / v_kurs2.
      w_final-zfrd = wa_dis-zfrd / v_kurs2.
      w_final-zaer = wa_dis-zaer / v_kurs2.
      w_final-zser = w_final-zserd / v_kurs2.
      w_final-zcst = w_final-zcstd / v_kurs2.
      w_final-zcsw = w_final-zcswd / v_kurs2.
      w_final-zsbc = w_final-zsbcd / v_kurs2.
      w_final-zvat = w_final-zvatd / v_kurs2.
    ELSE.
      w_final-zdsf = wa_dis-zdsf.
      w_final-zotr = wa_dis-zotr.
      w_final-zdis = wa_dis-zdis.
      w_final-zdnt = wa_dis-zdnt.
      w_final-zfrd = wa_dis-zfrd.
      w_final-zaer = wa_dis-zaer.
      w_final-zser = w_final-zserd.
      w_final-zcst = w_final-zcstd.
      w_final-zcsw = w_final-zcswd.
      w_final-zsbc = w_final-zsbcd.
      w_final-zvat = w_final-zvatd.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_CONDITION_FINAL

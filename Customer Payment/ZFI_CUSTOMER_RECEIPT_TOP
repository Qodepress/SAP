*&---------------------------------------------------------------------*
*& Include          ZFI_CUSTOMER_RECEIPT_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis, icon.  " SLIS contains all the ALV data types
*--------------------------------------------
* ALV Variables
*--------------------------------------------
DATA: gt_fieldcatalog  TYPE slis_t_fieldcat_alv,
      gwa_fieldcatalog TYPE slis_fieldcat_alv,
      gv_repid         LIKE sy-repid.
DATA: is_layout TYPE slis_layout_alv.
DATA: g_repid LIKE sy-repid.
DATA: gw_htop TYPE LINE OF slis_t_listheader.
DATA: gt_ttop TYPE slis_t_listheader.
DATA: gw_events TYPE slis_alv_event,
      gt_events TYPE slis_t_event.

*--------------------------------------------
* CONSTANTS
*--------------------------------------------
CONSTANTS: gc_pf_status TYPE slis_formname VALUE 'ZSTANDARD',
           gc_ucommand  TYPE slis_formname VALUE  'HANDLE_USER_COMMAND',
           gc_ph(2)     TYPE c VALUE 'PH',
           gc_pd(2)     TYPE c VALUE 'PD',
           gc_green(4)  TYPE c VALUE '@08@',
           gc_yellow(4) TYPE c VALUE '@09@',
           gc_red(4)    TYPE c VALUE '@0A@'.

*--------------------------------------------
* Internal Tables & Workareas
*--------------------------------------------
DATA: gt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
      gt_accountrcv     TYPE STANDARD TABLE OF bapiacar09,
      gt_accounttax     TYPE STANDARD TABLE OF bapiactx09,
      gt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
      gt_criteria       TYPE STANDARD TABLE OF bapiackec9,
      gt_extension2     TYPE STANDARD TABLE OF bapiparex,
      gt_return         TYPE STANDARD TABLE OF bapiret2.
DATA  gt_mwdat           TYPE STANDARD TABLE OF rtax1u15.

DATA: gw_header         TYPE bapiache09,
      gw_accountgl      TYPE bapiacgl09,
      gw_accountrcv     TYPE bapiacar09,
      gw_accounttax     TYPE bapiactx09,
      gw_currencyamount TYPE bapiaccr09,
      gw_criteria       TYPE bapiackec9,
      gw_extension2     TYPE bapiparex,
      gw_return         TYPE bapiret2.
DATA  gw_mwdat          TYPE rtax1u15.

DATA: gt_t012k TYPE STANDARD TABLE OF t012k.
DATA: gt_tka3p TYPE STANDARD TABLE OF tka3p.
*--------------------------------------------
* Variables
*--------------------------------------------
DATA  col TYPE i VALUE 0.
DATA: p_filename TYPE string.
DATA: gv_total_doc TYPE c.
*--------------------------------------------
* Strutures
*--------------------------------------------
"Arvato Doc Number
"Payment Header
"Payment Date
"Customer
"Amount
"Currency
"Correvio - IBAN Account
"Arvato FI Doc Type
"Ex.Rate
"Base Amount
"Bank Fee	Bank Fee EUR
"Tax Amount
"Payment Details
"Inv Ref Number
"Payment Amount
"Ex.Rate  Invoice
"Amt  Cash Discount
"Calculation Info
*************************************************
TYPES: BEGIN OF ty_input,
***************** Display Fields
         field_1(2)   TYPE c,
         field_2(40)  TYPE c,
         field_3(40)  TYPE c,
         field_4(40)  TYPE c,
         field_5(40)  TYPE c,
         field_6(40)  TYPE c,
         field_7(40)  TYPE c,
         field_8(40)  TYPE c,
         field_9(40)  TYPE c,
         field_10(40) TYPE c,
         field_11(40) TYPE c,
         field_12(40) TYPE c,
         field_13(40) TYPE c,
***************** Fetched Fields
         bukrs        TYPE bukrs,
         mwskz        TYPE mwskz,
**************** Configuration Fields
         rowcolor(4)  TYPE c, "Row Color
         icon(4)      TYPE c, "Icon name
       END OF ty_input.

*--------------------------------------------
* Header
*--------------------------------------------
TYPES: BEGIN OF ty_header,
         hheader(2)     TYPE c, "Payment Header
         budat          TYPE budat, "Payment Date
         kunnr          TYPE kunnr, "Customer
         amount         TYPE bapiwrbtr, "Amount
         waers          TYPE waers, "Currency
         iban(34)       TYPE c, "Correvio - IBAN Account
         doc_number(20) TYPE c, "Arvato Doc Number
         blart          TYPE blart, "Arvato FI Doc Type
         kursf          TYPE kursf , "Ex.Rate
         base_amt       TYPE bapiwrbtr, "Base Amount
         bank_fee       TYPE bapiwrbtr, "Bank Fee
         bank_free_eu   TYPE bapiwrbtr, "Bank Fee	Euro
         tax_amt        TYPE bapiwrbtr, "Tax Amount
       END OF ty_header.

*--------------------------------------------
* Item
*--------------------------------------------
TYPES: BEGIN OF ty_item,
         iheader(2)     TYPE c, "Payment Header
         doc_number(20) TYPE c, "Arvato Doc Number
         xblnr          TYPE xblnr, "Inv Ref Number
         pay_amt        TYPE wmwst, "Payment Amount
         kursf_inv      TYPE kursf, "Ex.Rate  Invoice
         inv_amt        TYPE wmwst, "Invoice Amount
         cash_disc      TYPE wmwst, "Amt  Cash Discount
         cal_info       TYPE wmwst, "Calculation Info
       END OF ty_item.

*--------------------------------------------
* Error
*--------------------------------------------
DATA:gt_error TYPE STANDARD TABLE OF zbapiret2.
DATA:gw_error TYPE zbapiret2 .

*--------------------------------------------
* Internal Tables & Work Area
*--------------------------------------------
DATA:gt_input TYPE STANDARD TABLE OF ty_input.
DATA:gw_input TYPE ty_input.
DATA:gw_line TYPE ty_input.
DATA:gt_head TYPE STANDARD TABLE OF ty_header.
DATA:gw_head TYPE ty_header.
DATA:gt_item TYPE STANDARD TABLE OF ty_item.
DATA:gw_item TYPE ty_item .
DATA:gw_zarvatobank TYPE zarvatobank.
DATA:gw_acdoca TYPE acdoca.

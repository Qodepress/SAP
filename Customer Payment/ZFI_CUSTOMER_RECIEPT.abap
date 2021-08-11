*&---------------------------------------------------------------------*
*& Report ZFI_CUSTOMER_RECEIPT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_customer_receipt.
**&--------------------------------------------------------------------*
*& Program Name     : ZFI_CUSTOMER_RECEIPT                             *
*& Title            : Arvato Customer Developement                     *
*& Module Name      : FI                                               *
*& Sub-Module       : -                                                *
*& Author           : Ankit Kumar                                      *
*& Create Date      : 12-07-2021                                       *
*& Logical DB       : None                                             *
*& Program Type     : Method                                           *
*& Transport No.    : ADEK902968                                       *
*& SIR/ CR No.      : Correvio Arvato Customer                         *
*& SAP Release      : S4 HANA 1909                                     *
*& Description      : Executable pgm for posting customer payment      *
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Modification Information
*-----------------------------------------------------------------------
* Date            :
* Author          :
* Transport number:
* Description     :
*-----------------------------------------------------------------------

******Top Include: Global Data
INCLUDE zfi_customer_receipt_top.
******Scr Include: Selection Screen
INCLUDE zfi_customer_receipt_scr.
******Sub Modules
INCLUDE zfi_customer_receipt_sub.
******Program Features
INCLUDE zfi_customer_receipt_form.
******Document Park & Check Features
INCLUDE zfi_customer_receipt_doc.

INITIALIZATION.

START-OF-SELECTION.
**read data from the CSV file.
  PERFORM read_file USING p_loclfn.
**Split data line into header and items.
  PERFORM data_split.
**Data validation for processing.
  CLEAR gw_line.
  PERFORM process_data USING space CHANGING gw_line.

END-OF-SELECTION.
*******Display ALV
  PERFORM display.

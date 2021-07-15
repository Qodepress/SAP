*&---------------------------------------------------------------------*
*& Include          ZFI_BDC_KE21N_REF_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-000.
PARAMETERS:  p_file LIKE rlgrap-filename
               DEFAULT 'c:\test.xls' OBLIGATORY.   " File Name
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-001.
  PARAMETER p_mode TYPE ctu_params-dismode DEFAULT 'N'.
  PARAMETER p_update TYPE ctu_params-updmode DEFAULT 'A'.
SELECTION-SCREEN END OF BLOCK block2.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
* To provide F4 help for file name
  PERFORM read_file_name CHANGING p_file.

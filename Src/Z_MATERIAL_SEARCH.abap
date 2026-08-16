*&---------------------------------------------------------------------*
*& Report Z_MATERIAL_ASSIGNMENT
*&---------------------------------------------------------------------*
*& Created by : Moaz Khaled & Yousef Waleed
*& Created At : 11/8/2026
*&---------------------------------------------------------------------*
REPORT Z_MATERIAL_SEARCH MESSAGE-ID zsd.

TABLES: MARA,MAKT.

 TYPES: BEGIN OF ITAB,
          MATNR LIKE MARA-MATNR, "Material_Number
          ERSDA LIKE MARA-ERSDA, "Created on
          MTART LIKE MARA-MTART, "Material Type
          MATKL LIKE MARA-MATKL, "Material Group
          MEINS LIKE MARA-MEINS, "Base Measuring unit
          MAKTX LIKE MAKT-MAKTX, "Description (in english)
        END OF ITAB.

DATA: it_mats TYPE STANDARD TABLE OF ITAB,
      WA TYPE ITAB,
      it_fcat TYPE slis_t_fieldcat_alv,
      wa_fcat TYPE slis_fieldcat_alv.

"---Selection-Screen---
"Variables Business meaning inside Text Elements

SELECTION-SCREEN BEGIN OF BLOCK SCR WITH FRAME TITLE Text-001.
  SELECT-OPTIONS: s_MAT FOR MARA-MATNR,
                  s_TYP FOR MARA-MATKL,
                  s_DES FOR MAKT-MAKTX.
SELECTION-SCREEN END OF BLOCK SCR.

START-OF-SELECTION.
  SELECT
    MARA~MATNR ,
    MARA~ERSDA ,
    MARA~MTART ,
    MARA~MATKL ,
    MARA~MEINS ,
    MAKT~MAKTX
  FROM MARA
  LEFT JOIN MAKT
  ON MARA~MATNR = MAKT~MATNR AND MAKT~SPRAS = 'E'
  INTO CORRESPONDING FIELDS OF TABLE @it_mats
  WHERE MARA~MATNR IN @s_MAT
    AND MARA~MATKL IN @s_TYP
    AND MAKT~MAKTX IN @s_DES.

  PERFORM Alv_Display.


"ALV_DISPLAY_SUBROUTINE
Form Alv_Display.
  IF SY-SUBRC = 4.
    "MESSAGE id 'ZSD' type 'S' number '001' DISPLAY LIKE 'E'.
    MESSAGE e001(zsd).
  ELSEIF SY-SUBRC = 8.
    MESSAGE e002(zsd).
  ELSEIF SY-SUBRC >= 12.
    MESSAGE id 'ZSD' type 'E' number '003'.
  Else.
      CLEAR wa_fcat.
      wa_fcat-fieldname = 'MATNR'.
      wa_fcat-seltext_m = 'Material Number'.
      APPEND wa_fcat TO it_fcat.

      CLEAR wa_fcat.
      wa_fcat-fieldname = 'MTART'.
      wa_fcat-seltext_m = 'Material Type'.
      APPEND wa_fcat TO it_fcat.

      CLEAR wa_fcat.
      wa_fcat-fieldname = 'MAKTX'.
      wa_fcat-seltext_m = 'Description'.
      APPEND wa_fcat TO it_fcat.

      CLEAR wa_fcat.
      wa_fcat-fieldname = 'MATKL'.
      wa_fcat-seltext_m = 'Material Group'.
      APPEND wa_fcat TO it_fcat.

      CLEAR wa_fcat.
      wa_fcat-fieldname = 'MEINS'.
      wa_fcat-seltext_m = 'Base Measuring unit'.
      APPEND wa_fcat TO it_fcat.

      CLEAR wa_fcat.
      wa_fcat-fieldname = 'ERSDA'.
      wa_fcat-seltext_m = 'Created on'.
      APPEND wa_fcat TO it_fcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
      i_callback_program = sy-repid
        it_fieldcaT = it_fcat
      TABLES
        t_outtab = it_mats.
  ENDIF.
EndForm.
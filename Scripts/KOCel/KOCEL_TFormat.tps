-- KOCEL TFormat
-- create 14.05.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 19.01.2015
--*****************************************************************************
--
CREATE OR REPLACE TYPE KOCEL.TFORMAT as object(
Fmt NUMBER,
Tag NUMBER(9),

/*See constants in Format package.*/

  /*Cell Font.*/
/*Name of the font, like Arial or Times New Roman.*/
Font_Name VARCHAR2(90),
/*Height of the font (in units of 1/20th of a point).
 A Font_Size20=200 means 10 points.*/
Font_Size20 NUMBER(9),
/*Index on the color palette. See constants in Format package*/
Font_Color NUMBER(9),
/*Style of the font, such as bold or italics.*/
Font_Style NUMBER(2),
/*Underline type.*/
Font_Underline NUMBER(1),
/*Font family, (see Windows API LOGFONT structure).*/
Font_Family NUMBER(3),
/*Character set. (see Windows API LOGFONT structure)*/
Font_CharSet NUMBER(3),

  /*Cell borders.*/
Left_Style NUMBER(2),
Left_Color NUMBER(9),
Right_Style NUMBER(2),
Right_Color NUMBER(9),
Top_Style NUMBER(2),
Top_Color NUMBER(9),
Bottom_Style NUMBER(2),
Bottom_Color NUMBER(9),
Diagonal NUMBER(1),
Diagonal_Style NUMBER(2),
Diagonal_Color NUMBER(9),

  /* Format string.
(For example, "yyyy-mm-dd" for a date format, 
 or "#.00" for a numeric 2 decimal format)
This format string is the same you use in Excel unde "Custom" format when
formatting a cell, and it is documented in Excel documentation.*/
Format_String VARCHAR2(128),

  /*Fill style.
Fill pattern and color for the background of a cell.*/
Fill_Pattern NUMBER(2),
/*Color for the foreground of the pattern. It is used when the pattern is
 solid, but not when it is automatic.*/
Fill_FgColor NUMBER(9),
/*Color for the background of the pattern.  If the pattern is solid it has no
 effect, but it is used when pattern is automatic.*/
Fill_BgColor NUMBER(9),

  /* Alignment on the cell.*/
/*Horizontal alignment on the cell.*/
H_Alignment NUMBER(1),
/*Vertical alignment on the cell.*/
V_Alignment NUMBER(1),

  /* Other Formatting*/
Wrap_Text  NUMBER(1),
Shrink_To_Fit NUMBER(1),
/*Text Rotation in degrees. 0 -  90 is up, 91 - 180 is down, 255 is vertical.*/
Text_Rotation NUMBER(3),
/*Indent value.(in characters)*/
Text_Indent NUMBER(3),
E_Locked NUMBER(1),
E_Hidden NUMBER(1),
/*Parent style. Not currently supported.*/
Parent_Fmt NUMBER(9),

/* Загрузка из базы. Если Fmt нулл или не существует,
  то создаётся новый формат с параметрами по умолчанию.*/
CONSTRUCTOR FUNCTION TFORMAT( Fmt in NUMBER default null)
return SELF AS RESULT,
/*Сохранение формата. 
  Если идентификатор формата не существует, то присваивается новый.
  Если аналогичный формат сушествует,
  то просто возвращается его идентификатор.*/
MEMBER FUNCTION Save(self in out KOCEL.TFORMAT) return NUMBER);

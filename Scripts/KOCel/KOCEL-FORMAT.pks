CREATE OR REPLACE PACKAGE KOCEL.FORMAT
-- KOCEL  FORMAT package
-- Definitions for the formats in a cell.
-- create 30.01.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 02.01.2011 19.01.2015 06.02.2015
--*****************************************************************************
is

-- Horizontal Alignment on a cell.
--  
-- General Alignment. (Text to the left, numbers to the right and Errors and
-- booleans centered)
ha_general constant NUMBER(1):=0;
-- Aligned to the left.
ha_left constant NUMBER(1):=1;
-- Horizontally centered on the cell.
ha_center constant NUMBER(1):=2;
-- Aligned to the right.
ha_right constant NUMBER(1):=3;
-- Repeat the text to fill the cell width.
ha_fill constant NUMBER(1):=4;
-- Justify with spaces the text so it fills the cell width.
ha_justify constant NUMBER(1):=5;
-- Centered on a group of cells.
ha_center_across_selection constant NUMBER(1):=6;

-- Vertical Alignment on a cell.
--
-- Aligned to the top.
va_top constant NUMBER(1):=0;
-- Vertically centered on the cell
va_center constant NUMBER(1):=1;
-- Aligned to the bottom.
va_bottom constant NUMBER(1):=2;
-- Justified on the cell.
va_justify constant NUMBER(1):=3;
-- Distributed on the cell.
va_distributed constant NUMBER(1):=4;

-- Left_Style, Right_Style, Top_Style, Bottom_Style. 
-- Cell border style.
--
-- None
bs_None constant NUMBER(2):=0;
-- Thin
bs_Thin constant NUMBER(2):=1;
-- Medium
bs_Medium constant NUMBER(2):=2;
-- Dashed
bs_Dashed constant NUMBER(2):=3;
-- Dotted
bs_Dotted constant NUMBER(2):=4;
-- Thick
bs_Thick constant NUMBER(2):=5;
-- Double
bs_Double constant NUMBER(2):=6;
-- Hair
bs_Hair constant NUMBER(2):=7;
-- Medium dashed
bs_Medium_dashed constant NUMBER(2):=8;
-- Dash dot
bs_Dash_dot constant NUMBER(2):=9;
-- Medium_dash_dot
bs_Medium_dash_dot constant NUMBER(2):=10;
-- Dash dot dot
bs_Dash_dot_dot constant NUMBER(2):=11;
-- Medium dash dot dot
bs_Medium_dash_dot_dot constant NUMBER(2):=12;
-- Slanted dash dot
bs_Slanted_dash_dot constant NUMBER(2):=13;

-- Pattern style for a cell.
--
-- Automatic
ps_Automatic constant NUMBER(2):= 0;
-- None
ps_None constant NUMBER(2):= 1;
-- Solid
ps_Solid constant NUMBER(2):= 2;
-- Gray 50
ps_Gray50 constant NUMBER(2):= 3;
-- Gray 75
ps_Gray75 constant NUMBER(2):= 4;
-- Gray 25
ps_Gray25 constant NUMBER(2):= 5;
-- Horizontal
ps_Horizontal constant NUMBER(2):= 6;
-- Vertical
ps_Vertical constant NUMBER(2):= 7;
-- Down
ps_Down constant NUMBER(2):= 8;
-- Up
ps_Up constant NUMBER(2):= 9;
-- Diagonal hatch.
ps_Checker constant NUMBER(2):= 10;
-- bold diagonal.
ps_SemiGray75 constant NUMBER(2):= 11;
-- thin horz lines
ps_LightHorizontal constant NUMBER(2):= 12;
-- thin vert lines
ps_LightVertical constant NUMBER(2):= 13;
-- thin \ lines
ps_LightDown constant NUMBER(2):= 14;
-- thin / lines
ps_LightUp constant NUMBER(2):= 15;
-- thin horz hatch
ps_Grid constant NUMBER(2):= 16;
-- thin diag
ps_CrissCross constant NUMBER(2):= 17;
-- 12.5 % gray
ps_Gray16 constant NUMBER(2):= 18;
-- 6.25 % gray
ps_Gray8 constant NUMBER(2):= 19;

-- Diagonal_Style. Diagonal border for a cell.
--
-- Cell doesn't have diagonal borders.
db_None constant NUMBER(1):= 0;
-- Cell has a diagonal border going from top left to bottom right.
db_DiagDown constant NUMBER(1):= 1;
-- Cell has a diagonal border going from top right to bottom left.</summary>
db_DiagUp constant NUMBER(1):= 2;
-- Cell has both diagonal borders creating a cross.
db_Both constant NUMBER(1):= 3;

-- Font_style for a cell.
--
Normal constant NUMBER(2):= 0;
-- Font is bold.
Bold constant NUMBER(2):= 1;
not_Bold constant NUMBER(2):= 30;
-- Font is italic.
Italic constant NUMBER(2):= 2;
not_Italic constant NUMBER(2):= 29;
-- Font is striked out.
StrikeOut constant NUMBER(2):= 4;
not_StrikeOut constant NUMBER(2):= 27;
-- Font is superscript
Superscript constant NUMBER(2):= 8;
not_Superscript constant NUMBER(2):= 23;
-- Font is subscript.
Subscript constant NUMBER(2):= 16;
not_Subscript constant NUMBER(2):= 15;

-- Font_Underline. Types of underline you can make in an Excel cell.
--
-- No underline.
u_None constant NUMBER(1):= 0;
-- Simple
u_Single constant NUMBER(1):= 1;
-- Double
u_Double constant NUMBER(1):= 2;
-- Simple underline, but not underlining spaces between words.
u_SingleAccounting constant NUMBER(1):= 3;
-- Double underline, but not underlining spaces between words.
u_DoubleAccounting constant NUMBER(1):= 4;

-- Color constants.
--
clBlack constant PLS_INTEGER:=  0;
clMaroon constant PLS_INTEGER:=  128;
clGreen constant PLS_INTEGER:=  32768;
clOlive constant PLS_INTEGER:=  32896;
clNavy constant PLS_INTEGER:=  8388608;
clPurple constant PLS_INTEGER:=  8388736;
clTeal constant PLS_INTEGER:=  8421376;
clGray constant PLS_INTEGER:=  8421504;
clSilver constant PLS_INTEGER:=  12632256;
clRed constant PLS_INTEGER:=  255;
clLime constant PLS_INTEGER:=  65280;
clYellow constant PLS_INTEGER:=  65535;
clBlue constant PLS_INTEGER:=  16711680;
clFuchsia constant PLS_INTEGER:=  16711935;
clAqua constant PLS_INTEGER:=  16776960;
clLtGray constant PLS_INTEGER:=  12632256;
clDkGray constant PLS_INTEGER:=  8421504;
clWhite constant PLS_INTEGER:=  16777215;
clSkyBlue constant PLS_INTEGER:=  15780518;
clCream constant PLS_INTEGER:=  15793151;
clMedGray constant PLS_INTEGER:=  10789024;
clNone constant PLS_INTEGER:=  536870911;
clDefault constant PLS_INTEGER:=  536870912;

-- Direct and revers conversions for format constants (name2number, number2name).
-- Pipelined functions returns sets of names.

function Name2Color(val in VARCHAR2) return NUMBER;
function Color2Name(val in NUMBER) return VARCHAR2;

function get_CellHorAlignment(val in NUMBER) return VARCHAR2;
function get_CellHorAlignment(val in VARCHAR2) return NUMBER;
function get_CellHorAlignments return KOCEL.TSTRINGS pipelined;

function get_CellVertAlignment(val in NUMBER) return VARCHAR2;
function get_CellVertAlignment(val in VARCHAR2) return NUMBER;
function get_CellVertAlignments return KOCEL.TSTRINGS pipelined;

function get_CellBorderStyle(val in NUMBER) return VARCHAR2;
function get_CellBorderStyle(val in VARCHAR2) return NUMBER;
function get_CellBorderStyles return KOCEL.TSTRINGS pipelined;

function get_CellPatternStyle(val in NUMBER) return VARCHAR2;
function get_CellPatternStyle(val in VARCHAR2) return NUMBER;
function get_CellPatternStyles return KOCEL.TSTRINGS pipelined;

function get_CellDiagBorder(val in NUMBER) return VARCHAR2;
function get_CellDiagBorder(val in VARCHAR2) return NUMBER;
function get_CellDiagBorders return KOCEL.TSTRINGS pipelined;

function get_CellFontStyle(val in NUMBER) return VARCHAR2;
function And_CellFontStyle(val in NUMBER,style in NUMBER) return NUMBER;

function get_CellUnderlineStyle(val in NUMBER) return VARCHAR2;
function get_CellUnderlineStyle(val in VARCHAR2) return NUMBER;
function get_CellUnderlineStyles return KOCEL.TSTRINGS pipelined;

-- Format equality function.
function EQ(fmt1 KOCEL.TFORMAT, fmt2 KOCEL.TFORMAT) return BOOLEAN;
-- This is for use in Sql, it returns 1 if true or 0 if false.
function S_EQ(fmt1 KOCEL.TFORMAT, fmt2 KOCEL.TFORMAT) return NUMBER;

END;
/

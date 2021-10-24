CREATE OR REPLACE PACKAGE KOCEL.CELL
-- KOCEL  CELL package
-- by Nikolai Krasilnikov
-- create 17.04.2009
-- update 18.05.2009 15.12.2009 28.01.2010 01.02.2010 13.02.2010 03.03.2010
--        17.08.2011 11.11.2014 20.02.20
--*****************************************************************************

AS
-- ���� ������ �������� KOCEL.SHEETS_ad.
ClearBOOKS BOOLEAN; 
-- !!! �������� ��������� �������������� ����� ��� �����. �������������� ������ ��������� �������� � ��������� ���������� �������� ����� � ����.

-- ��� ��������� �������� � ����� ����� �������� ������ ���� �� ����� N,D,S.
-- ��� ������������� ������������ ���������� �� �������� ������� ��������������
-- ����. 
type TCellValue is record(
R NUMBER(6),
C NUMBER(3),
N FLOAT(49),
D DATE,
S VARCHAR2(4000),
F VARCHAR2(4000)
);

type TColumn is Table of TCellValue index by BINARY_INTEGER;
type TRow is Table of TCellValue index by BINARY_INTEGER;
type TRange is Table of TColumn index by BINARY_INTEGER;

-- ������� (��������) � �������� (���������) �����, ������������ �� ���������.
inBOOK VARCHAR2(255);
inSHEET VARCHAR2(255);
outBOOK VARCHAR2(255);
outSHEET VARCHAR2(255);

tmpRange TRange;

overwrite constant BOOLEAN:= true;

-- �������� ����� ����� � (���) �����.
-- ���� ���� ��� ����������, �� ������.
-- ����� ����������, ���� � ��� ������ ���� ����.
-- ���� ����� ����������, ���� � ������� �������� ������ ���� ������.
-- � ������ ������ ��������� ������� ������ � ������(R=0 � C=0).
PROCEDURE New_SHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2);

-- �������� ������ �����.
PROCEDURE New_outSHEET;
-- �������� ������ ����� � ��������� ��� ��� ������� �� ���������.
PROCEDURE New_outSHEET(newSHEET in VARCHAR2);
PROCEDURE New_outSHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2);

-- �������� ��� ���� ����������.
FUNCTION is_inSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN;
FUNCTION is_inSHEET_exist return BOOLEAN;
FUNCTION is_outSHEET_exist return BOOLEAN;
FUNCTION is_outSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN;
FUNCTION isSHEET_exist(eSHEET in VARCHAR2,eBOOK in VARCHAR2)
return BOOLEAN;

-- ��������� �������� �� ������� ����� � (���) �����.
FUNCTION Val(CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

-- ��������� �������� �� ����� �����,�����.
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

FUNCTION Val(CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

-- ��������� �������� �� ����� �����,�����.
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

-- ��������, ��� �������� ����.
FUNCTION isDate(CellValue in TCellValue)
return BOOLEAN;

-- ��������, ��� �������� �����.
FUNCTION isNumber(CellValue in TCellValue)
return BOOLEAN;

-- ��������, ��� �������� null.
FUNCTION isNull(CellValue in TCellValue)
return BOOLEAN;

-- ��������, ��� �������� ������.
FUNCTION isString(CellValue in TCellValue)
return BOOLEAN;

-- ��������, ��� ������������ �������.
FUNCTION hasFormula(CellValue in TCellValue)
return BOOLEAN;

--��������� ��������, ��� ����. ���� ��� �� ����, �� ����.
FUNCTION asDate(CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

--��������� ��������, ��� �����. ���� ��� �� �����, �� ����.
FUNCTION asNumber(CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

--��������� ��������, ��� ������.
FUNCTION asString(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

--��������� �������.
FUNCTION Formula(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

-- ��������� �������.
-- ��������� �������� ����������� ��������, ���� �������� ����������� � �����
-- ��� �� ����� � ����� ��������� �������.
-- ��� ������ ����, ���������� ������ �������, ������������ ������, ���� ������
-- ������� ���� �������� �������������.
-- � ����� ������, ��� ����������� ������ ����� ������������ �������� ��������:
-- first,next,last.
-- ������ ������� ������������� ������ ���� � �����. 
FUNCTION GetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(entColumn in VARCHAR2)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn;

-- ��������� ����.
-- ��������� �������� ����������� ��������, ���� �������� ����������� � �����
-- ��� �� ����� � ����� ��������� �������.
-- ��� ������� � �������� ����, ���������� ������ ���� ����� ��������������
-- ������ � ��� ������, ���� ��� ������ ���� �������� �������������.
-- � ����� ������, ��� ����������� ������ ����� ������������ �������� ��������:
-- first,next,last.
-- ������ ������� ������������� ������ ������� � �����.
FUNCTION GetRow(StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(entRow in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                entRow in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                entRow in NUMBER)
return TRow;

FUNCTION GetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

-- ��������� ���������.
-- ��������� �������� ����������� ��������, ���� �������� ����������� � �����
-- ��� �� ����� � ����� ��������� �������.
-- � ����� ������, ��� ����������� ������ ����� ������������ �������� ��������:
-- first,next,last.
-- ������� ������� �������������: ������ - ������ ����, ������ ������ �������.
FUNCTION GetRange(StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;


-- ���������� ��������.
-- �������� ����������� ������ �������� ����� R,C.
-- ���� ���� (N,D,S) ���������� ������������, �� ������.
PROCEDURE SetVal(val in TCellValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,val in TCellValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2, val in TCellValue);

-- ���������� ��������, ���� �������� KOCEL.TVALUE.
PROCEDURE SetVal(val in KOCEL.TValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,val in KOCEL.TValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2,val in KOCEL.TValue);


-- ���������� ��������, ��� ����.
PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in NUMBER,
                       val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE);

PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in VARCHAR2,
                       val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE);

-- ���������� ��������, ��� �����.
PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in NUMBER,
                         val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER);

-- ���������� ��������, ��� ������.
PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

-- ���������� �������.
-- �������� ��� ���� �� ����������.
PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

-- ���������� �������.
-- ���������� ���������� �������� �������� �������,
-- � �� ����� (R,C) ��������.
-- ������������� ������� ��������� �� ��������� �����, ������ ������� �����
-- ��� ������������ ���������� ��� ��������� ������� ���������� ���������.
-- ��� ���������� �������� ��������� �������� ����� ����� ��������� ��������,
-- ��������� ��������� (setVal), � ����� �� �������.
PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(asColumn in VARCHAR2,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn);

-- ���������� ����.
-- ���������� ���������� �������� �������� �������,
-- � �� ����� (R,C) ��������.
-- ������������� ������� ��������� �� ��������� �����, ������ ������� �����
-- ��� ������������ ���������� ��� ��������� ������� ���������� ���������.
-- ��� ���������� �������� ��������� �������� ����� ����� ��������� ��������,
-- ��������� ��������� (setVal), � ����� �� �������.
PROCEDURE SetRow(StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

-- ���������� ���������.
-- ���������� ���������� �������� �������� �������,
-- � �� ����� (R,C) ��������.
-- ������������� ������� ��������� �� ��������� �����, ������ ������� �����
-- ��� ������������ ���������� ��� ��������� ������� ���������� ���������.
-- ��� ���������� �������� ��������� �������� ����� ����� ��������� ��������,
-- ��������� ��������� (setVal), � ����� �� �������.
PROCEDURE SetRange(StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

-- ����������� �����.
PROCEDURE CopySHEET(fromSHEET in VARCHAR2,fromBook in VARCHAR2,
                    toSHEET in VARCHAR2,toBook in VARCHAR2,
										doOverwrire in BOOLEAN default false);

-- ����������� �����.
PROCEDURE CopyBook(fromBook in VARCHAR2,toBook in VARCHAR2,
                   doOverwrire in BOOLEAN default false);
                   
-- �������������� �����.
PROCEDURE RenameBook(fromBook in VARCHAR2,toBook in VARCHAR2);

-- �������� �����.
PROCEDURE DeleteBook(DBook in VARCHAR2);

-- �������� �����.
PROCEDURE DeleteSheet(DBook in VARCHAR2, DSheet in VARCHAR2);

-- ������� ������ ���� ������ �����.
-- ������� ������ � �������������� ������� �������.
-- ����������� ������ �������������.
PROCEDURE ClearBook(DBook in VARCHAR2);
PROCEDURE ClearOutBook;

-- ������� ������ ����� �����.
-- ������� ������ � �������������� ������� �������.
-- ����������� ������ �������������.
PROCEDURE ClearSheet(DBook in VARCHAR2, DSheet in VARCHAR2);
PROCEDURE ClearOutSheet(DSheet in VARCHAR2);
PROCEDURE ClearOutSheet;

-- �������������� ������� ��� ����, ��������� �� ���, ��� �������.
-- ������������� �������� ������������.
-- ����������� ������ �������� � �����, ������� �� ����.
FUNCTION Dates(RowVals in TRow)
return KOCEL.TDATES pipelined;

FUNCTION Dates(ColumnVals in TColumn)
return KOCEL.TDATES pipelined;

-- �������������� ������� ��� ����, ��������� �� �����, ��� �������.
-- ������������� �������� ������������.
-- ����������� ������ �������� � ������, ������� �� ����.
FUNCTION Nums(RowVals in TRow)
return KOCEL.TNUMS pipelined;

FUNCTION Nums(ColumnVals in TColumn)
return KOCEL.TNUMS pipelined;

-- �������������� ������� ��� ����, ��������� �� �����, ��� �������.
-- ������������� �������� ������������.
-- ����������� ������ ��������, ���� ������ �� ������.
FUNCTION Strings(RowVals in TRow)
return KOCEL.TSTRINGS pipelined;

FUNCTION Strings(ColumnVals in TColumn)
return KOCEL.TSTRINGS pipelined;

-- �������������� ����� ������� � �����.
FUNCTION Col2Num(columnChar in VARCHAR2) return NUMBER;

-- �������������� ������ ������� � ������.
FUNCTION Col2Char(columnNum in NUMBER) return VARCHAR2;


-- �������������� ��������� ��� �������.
-- ������ ������� ������ ���� �� 1 �� 26 (A..Z).
-- ������������� � ��������� ���� ������������.
FUNCTION RANGE(OutRange in TRange)
return KOCEL.TCELLS pipelined;

-- �������������� ����� ��� �������.
-- ������ ������� ������ ���� �� 1 �� 26 (A..Z).
-- ������������� � ����� ���� ������������.
FUNCTION Vals(anySHEET in VARCHAR2,anyBOOK in VARCHAR2)
return KOCEL.TCELLS pipelined;

-- �������������� ��������� ����� ��� �������.
-- ������ ������� ������ ���� �� 1 �� 26 (A..Z).
-- ������������� � ����� ���� ������������.
FUNCTION inVals
return KOCEL.TCELLS pipelined;

-- �������������� ����� ��� ������� � ���� ��������, ��������������� � ������.
-- ������ ������� ������ ���� �� 1 �� 26 (A..Z).
-- ������������� � ����� ���� ������������.
FUNCTION Vals_as_Str(anySHEET in VARCHAR2,anyBOOK in VARCHAR2)
return KOCEL.TSCELLS pipelined;

end CELL;
/

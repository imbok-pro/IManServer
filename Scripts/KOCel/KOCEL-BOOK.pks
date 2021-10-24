CREATE OR REPLACE PACKAGE KOCEL.BOOK
-- KOCEL BOOK package
-- create 08.02.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 
--*****************************************************************************

as
-- ������������ ���������� ������.
procedure ClearData;
-- �������� � ���������� ������.
procedure PrepareData(UBOOK in VARCHAR2);

-- ������������� ��� ������� ��������� ������ ����� "UBOOK".
-- ���� ����� ����� 0, � ��� ����, �� ��� ���������� �������� �����.
function Pars return KOCEL.TSHEET_PARS pipelined;

-- ������������� ��� ������� �������, �������������� � ����� "UBOOK".
-- ���� "Fmt" �������� ������������� �������, � ���� "Tag" ���������� �����.
-- ������ ������ �������� ���������� �������� � ���� "Tag".
function Formats return KOCEL.TFORMATS pipelined;

-- ������������� ��� ������� ������ ������ ����� "UBOOK".
-- ������ ������ �������� �� �����, � ���������� ������.
-- ���������� � ������ ����� � �� ������ �������� � ������.
function Sheets return KOCEL.TSHEET_NUMS pipelined;

-- ������������� ��� ������� ������� � ������ ����� �����  "USHEET" �� �����
-- "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Sheet_Row_s(USHEET in VARCHAR2) return KOCEL.TROW_DATAS pipelined;

-- ������������� ��� ������� ������� � ������ ����� ������ ����� "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Row_s return KOCEL.TROW_DATAS pipelined;

-- ������������� ��� ������� ������� � ������ ������� �����  "USHEET" �� �����
-- "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Sheet_Column_s(USHEET in VARCHAR2) return KOCEL.TCOLUMN_DATAS
pipelined;

-- ������������� ��� ������� ������� � ������ ������� ������ ����� "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Column_s return KOCEL.TCOLUMN_DATAS pipelined;

-- ������������� ��� ������� ������ ����� "USHEET" �� ����� "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Sheet_Cells(USHEET in VARCHAR2) return KOCEL.TCELL_DATAS pipelined;

-- ������������� ��� ������� ������ ����� "UBOOK".
-- ���� "Fmt" �������� �� ������������� ���������, � �����,
-- �������������� �������� ���� "Tag" � ���������� ������� � �������
-- "SHEET_FORMATS" ��� ������ �����.
function Cells return KOCEL.TCELL_DATAS pipelined;

-- ������������� ��� ������� ����������� ������ ����a "USHEET" �� �����
-- "UBOOK".
function Sheet_MCells(USHEET in VARCHAR2) return KOCEL.TMCELL_DATAS pipelined;

-- ������������� ��� ������� ����������� ������ ������ ����� "UBOOK".
function MCells return KOCEL.TMCELL_DATAS pipelined;

END;
/

CREATE OR REPLACE PACKAGE WForms.Params 
-- Params Package
-- by Nikolay Krasilnikov 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 30.09.2010  
-- update 05.10.2010 01.12.2010 10.12.2010 14.12.2010 20.08.2015 14.01.2021
--        19.01.2021 27.01.2021 17.04.2021

-- ����� ��������� ������� ini ����� - ��������� � ��������������� ���������
-- �������� ����.
AS
--- (Params.pks )
--  ������ �������� ��������, ����������� ��� ���������� ���������� ����������,
--  ��� ������� ������������.
TYPE TFORM_PARAM is RECORD 
(
/* ��� ���������� ��� ��� �����(�����).*/
OBJ_NAME VARCHAR2(4000),
/* ��� ���������.*/
PROP_NAME VARCHAR2(128),
/* �������� ��������� � ���� ������.*/
PROP_VALUE VARCHAR2(4000),
/* ������� ��������� ����������.*/
ORD NUMBER(9),
/* ���� ��� ���� �� ����, �� �������� �����.*/
PROP_CLOB CLOB
);
TYPE TFORM_PARAMS is TABLE of TFORM_PARAM;
 
-- ������� ��������� ���������� �� ���������� ����� ���������� �����.
-- ���� ����������� ��������� ��������� � ���������� ���������� � ����������,
-- �� ������� ���������� ������� �������� ����������,
-- ����� ������������ ������ �������.
-- ������ ���������� �������� ��������� �������:
--  select OBJ_NAME,PROP_NAME,PROP_VALUE,ORD, PROP_CLOB 
--    from Table( FormParams.Get(pAppName, pFormName, pSingnature))
-- � ���������� �������� ������������� �� ������� � �������.
-- ������� ���������� ��������� ����� ��� �������� ������������.
-- ���� ��� ���������� ��� �������� ������������,
-- �� ������� ���������� ��������� �� ��������� (������������ - ����).
-- ���� ��� ���������� �� ���������, �� ������������ ������ �������.
 function Get(
   pAppName VARCHAR2,
   pFormName VARCHAR2,
   pSingnature NUMBER) 
   return TFORM_PARAMS pipelined;

-- ������ ��������� ����� � ����. 
-- ��� ������ ���������� ��������, �� ���������� �� ����� ��� �� ���������.
-- ���� ����� ��� ��������� ����������, �� ���������� �����������������
-- ��������� ���������.
procedure SetValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName VARCHAR2,
  pPropValue VARCHAR2,
  pOrd NUMBER,
  pPropClob CLOB default null
  );

-- �������� ���� ���������� ���������� ����� �� ����. 
-- ��� ������ ���������� ��������, �� ���������� �� ����� ��� �� ���������.
-- ���� ����� ��� ��������� ����������, �� ���������� �����������������
-- ��������� ���������.
procedure DelObject(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2);
 
-- �������� ��������������� ��������� ����� �� ����. 
-- ������ ��������� ���������� ��������, �� ���������� �� ����� ��� ��
-- ���������.
-- ���� ����� ��� ��������� ����������, �� ���������� �����������������
-- ��������� ���������.
procedure DelValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName VARCHAR2);

-- �� ���������� �������������� ����� ���������� ������� ��� ��������� ���
-- �������� ���������. 
procedure SetCommit(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER);
  
-- ������� ����� ���������� �� ��������� �� ������ ����������
-- ������������, �� ��������� ��������. 
procedure SetDefault(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER,
  pUser VARCHAR2 default null);  

FUNCTION S_UpEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER;
PRAGMA RESTRICT_REFERENCES(S_UpEQ,WNPS);  

FUNCTION S_EQ(a1 NUMBER, a2 NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

END Params;
/

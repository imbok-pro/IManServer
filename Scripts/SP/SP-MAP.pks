CREATE OR REPLACE PACKAGE SP.Map
-- Map package 
-- ������� ������������ ��������
-- ����� ��������� ����� KOCEL
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.07.2014 
-- update 

AS
type TMAP IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(128);
type TMAPS IS TABLE OF TMAP INDEX BY VARCHAR2(128);
type TMAPREC is record
( 
  BOOK VARCHAR2(256), Sheet VARCHAR2(256),
  KeyColumn NUMBER(6),
  ValueColumn NUMBER(6)
);
type TMAPRECS IS TABLE OF TMAPREC INDEX BY VARCHAR2(128);
-- ������������ �������� ������, �������� � ��� ���� - 128 ��������!


-- ������� ������������� �������� �� �����.
FUNCTION V(MapName IN VARCHAR2, K IN VARCHAR2)  return VARCHAR2;

-- ������� ������������� �������� �� �����.
-- ������������ ��������� �������������� ��� ����������� �����.
FUNCTION V(K IN VARCHAR2)  return VARCHAR2;


-- ��������� ����������� ����� ����� (����������)
PROCEDURE NEW(
  -- ��� ����� (������������ � ���� ����� ���������� ������� ������ ����)
  MapName IN VARCHAR2,
  -- ��� ����� � ����� � ������� ��������� ������� �����
  BOOK IN VARCHAR2, Sheet IN VARCHAR2,
  -- ��� ������� � ����� ���� �����
  KeyColumn IN VARCHAR2, KeyColumnRow IN NUMBER,
  -- ��� ������� � ����� ���� ��������.
  ValueColumn IN VARCHAR2, ValueColumnRow IN NUMBER);

END MAP;  

CREATE OR REPLACE PACKAGE SP.B
-- BUILD package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.09.2010
-- update 01.11.2010 19.11.2010 17.12.2010 04.03.2011 10.05.2011 01.11.2011
--        20.12.2011 20.03.2012 28.03.2012 28.11.2014 06.01.2015 31.03.2015
--        29.07.2021

AS
-- �� ���� ���������� � �������� ������� ������ ��� ������������� �� �������
-- �������� ���� ��� �� �������� �����, �� ���� ������ ������ �� �����.
--
-- ������������ ���������� � ����������� ���.
-- ������ �������� ����� ���������� ���� ��� ��� �������� ����� ��������������.
-- ���� ������� �������������� �����, �� ������� ���������� ����. 
-- ���� �� ������� �������������� �����,
-- �� ������� ���������� ��������� �� ������.
FUNCTION COMPILE_MACRO(MACRO_FULL_NAME IN VARCHAR2)return VARCHAR2;
FUNCTION COMPILE_MACRO(MACRO_ID IN NUMBER) return VARCHAR2;
--
-- ������������ ���� ����������� � ����������� ���.
-- ���� ������� �������������� �����, �� ������� ���������� ����. 
-- ���� �� ������� �������������� �����,
-- �� ������� ���������� ��������� �� ������.
FUNCTION COMPILE_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2) return VARCHAR2;
FUNCTION COMPILE_MACRO_BODY(MACRO_ID IN NUMBER) return VARCHAR2;
--
-- ������� ��������������� ��� ������� � �������� � ���������� ����������
-- �������������� �������� ����������������.
-- ��������� ����� �� ������� � ��������������� ����� �������� ��� ������
-- ������� SP.COMPILE_ERRORS.
FUNCTION COMPILE_ALL return NUMBER;
--
-- ������� ������������� ��� ��������� ���� ������ ��������������.
FUNCTION MACRO_BODY_SOURCE(MACRO_FULL_NAME IN VARCHAR2) 
  return SP.TSOURCE pipelined;
FUNCTION MACRO_BODY_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
  return CLOB;
FUNCTION MACRO_BODY_LISTING_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
  return CLOB;
FUNCTION MACRO_BODY_SOURCE(MACRO_ID IN NUMBER) return SP.TSOURCE pipelined;
-- ������� ������������� ��� ��������� ������ ���������� ���� ������
-- ��������������.
FUNCTION MACRO_BODY_ERRORS(MACRO_NAME IN VARCHAR2) 
  return SP.TERROR_RECORDS pipelined;
FUNCTION MACRO_BODY_ERRORS(MACRO_ID IN NUMBER)
  return SP.TERROR_RECORDS pipelined;
-- ������� ������������� ��� ��������� ������ ���������� ������� �������,
-- ��������� ��������� FUNCTIONS ��������������.
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_FULL_NAME IN VARCHAR2) 
  return SP.TERROR_RECORDS pipelined;
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_ID IN NUMBER)
  return SP.TERROR_RECORDS pipelined;
-- ��������� ������� ������ �� ����� SP_IM, ������� �� ����� ���������������
-- �������������.
PROCEDURE DROP_MACRO;
-- ��������� ������� ����� ��������������.
PROCEDURE DROP_MACRO(MACRO_FULL_NAME IN VARCHAR2);
PROCEDURE DROP_MACRO(MACRO_ID IN NUMBER);
-- ��������� ������� ���� ������ ��������������.
PROCEDURE DROP_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2); 
PROCEDURE DROP_MACRO_BODY(MACRO_ID IN NUMBER);

-- ������� ���������� ��������� ������� ("VALID" ��� "INVALID")
FUNCTION STATUS(MACRO_ID IN NUMBER) return VARCHAR;

-- ������� ���������� ������� ��� ��������� ������ ��������������.
-- �������� Q=-1, ��������� ������������� ��������������,
-- ����������� ������������ �������������� ��� ���������� ���. 
FUNCTION MACRO_SOURCE(MACRO_FULL_NAME IN VARCHAR2, Q in NUMBER default 0) 
  return SP.TSOURCE pipelined;
FUNCTION MACRO_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2,
                              Q in NUMBER default 0)
  return CLOB;

-- ������� ���������� ������� ��� ��������� ������ �������������.
-- �������� Q=-1, ��������� ������������� ��������������,
-- ����������� ������������ �������������� ��� ���������� ���.
FUNCTION MACRO_SOURCES(Macros IN SP.TNUMBERS, Q in NUMBER default -1) 
  return SP.TSOURCE pipelined;
  
-- ������� ���������� ������� ��� ��������� ������ �������������,
-- ��������� ����� ��������� ����.
-- ���� �������� Changed_After => null, �� ���������� null. 
FUNCTION MACRO_SOURCES_AS_CLOB(Changed_After IN DATE)
  return CLOB;

-- ��������� ��������� ��������������.
-- ��� ������������ ������ �����������. 
-- ���� ������ ������ ��������,
-- �� ����������� ������� "Clone_of".
PROCEDURE CloneMacro(
     MacroName IN VARCHAR2,
	   NewShortName IN VARCHAR2 default null);
END B;
/

CREATE OR REPLACE PACKAGE SP.C
-- Cache package 
-- ����� ��� ����������� ���������� ������� ������
-- ����� ���������� ��������� ������� SP.Obj_Cache
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 10.05.2017
-- update 14.11.2017 22.11.2017 30.11.2017 03.12.2017 05.12.2017

AS
TYPE TOBJECTS IS TABLE OF NUMBER INDEX BY SP.MOD_OBJ_PARS_CACHE.SET_KEY%type;

-- ��������� ��������� ��� ���������� �������.
-- ��������� ���������� �������� ���������� ����������, ����� ��������
-- ����������� ���� �������� ������������ ������ ��������.
-- ���� ���������� ��������� � ��� ������, ��������� ��� ��������� � �������
-- ����������, �� ���������� ������������ ��������� addObject.
PROCEDURE setOBJECT(Object_ID in NUMBER);

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
-- ���� �������� setKey �� ������������, �� ����� ���������� ������������� "1"
PROCEDURE setOBJECT(Object_ID in NUMBER, setKey in VARCHAR2);

-- ��������� ��������� ��� ���������� �������.
-- ��������� ������������, ���� ���������� ��������� � ��� ������,
-- ��������� ��� ��������� � ������� ����������.
PROCEDURE addOBJECT(Object_ID in NUMBER, setKey in VARCHAR2);

-- ������� ������������� �������� ������� ������.
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return SP.TMPAR;

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return SP.TMPAR;

-- ������� ������������� �������� ��������� ������� ������. 
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2;

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2;

-- ������� ������������� �������� ��������� ������� ������. 
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2;

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2;

-- ������� ������������� �������� ��������� ������� ������. 
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return DATE;

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return DATE;

-- ������� ������������� �������� ��������� ������� ������. 
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return NUMBER;

-- �������� setKey ������������ ��� ������������� �������������� ������������� 
-- ���� ���������� ��������.
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return NUMBER;

END C;  

CREATE OR REPLACE PACKAGE SP.OUTPUT
-- SP OUTPUT package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 14.10.2010 17.11.2010 22.11.2010 11.02.2011 10.05.2011 03.06.2013
--        10.06.2013 10.10.2013 11.07.2014 08.09.2014 04.11.2014 22.03.2015
--        25.03.2015 10.07.2015 17.01.2018 19.01.2017 03.10.2018 21.04.2021

AS
FMT VARCHAR2(80):=NULL;
NLS VARCHAR2(80):=NULL;
-- ���� ���� ���� ����������, �� ��� ��������� ������ ����� �����������
-- �����������, ��� ����������� ����� �������.
Not_Truncated BOOLEAN := true;
-- ���������� ���������, ���������������� ������ ��������.
-- ������ �������� ������������, ��� ����������� ������������������ ����������
-- �������� �������� ����. ����������� ������������������ �������� ����
-- ���������� ��� �������� ����������� ������ � �������� ��������.
C_SEQUENCES CONSTANT VARCHAR2(30):='SEQUENCES';
C_TYPES CONSTANT VARCHAR2(30):='TYPES';
C_ENUMS CONSTANT VARCHAR2(30):='ENUMS';
C_ROLES CONSTANT VARCHAR2(30):='ROLES';
C_ROLES_RELS CONSTANT VARCHAR2(30):='ROLES_RELS';
C_USERS CONSTANT VARCHAR2(30):='USERS';
C_USER_ROLES CONSTANT VARCHAR2(30):='USER_ROLES';
C_GROUPS CONSTANT VARCHAR2(30):='GROUPS';
C_ALIASES CONSTANT VARCHAR2(30):='ALIASES';
C_GLOBALS CONSTANT VARCHAR2(30):='GLOBALS';
C_USERS_GLOBALS CONSTANT VARCHAR2(30):='USERS_GLOBALS';
C_DOCS CONSTANT VARCHAR2(30):='DOCS';
C_ARRS CONSTANT VARCHAR2(30):='ARRAYS';
C_CATALOG_TREE CONSTANT VARCHAR2(30):='CATALOG_TREE';
C_OBJECTS CONSTANT VARCHAR2(30):='OBJECTS';
C_OBJECT_PARS CONSTANT VARCHAR2(30):='OBJECT_PARS';
C_OBJECT_RELS CONSTANT VARCHAR2(30):='OBJECT_RELS';
C_MACROS CONSTANT VARCHAR2(30):='MACROS';
C_MODELS CONSTANT VARCHAR2(30):='MODELS';
C_MODEL_OBJECTS CONSTANT VARCHAR2(30):='MODEL_OBJECTS';
C_MODEL_OBJECT_PARS CONSTANT VARCHAR2(30):='MODEL_OBJECT_PARS';
C_MODEL_OBJECT_RELS CONSTANT VARCHAR2(30):='MODEL_OBJECT_RELS';
C_MODEL_OBJECT_STORIES CONSTANT VARCHAR2(30):='MODEL_OBJECT_STORIES';
C_MODEL_OBJECT_REL_STORIES CONSTANT VARCHAR2(30):='MODEL_OBJECT_REL_STORIES';

-- ����� �������� ������� � ����������� ����.
PROCEDURE RESET;

-- ������� �����.
PROCEDURE TYPES;

-- ������� ����������� ��������.
PROCEDURE Enums;

-- ������� �����.
PROCEDURE ROLES;

-- ������� ������������� � �� �����.
PROCEDURE Users;

-- ������� ����������� ���������� ����������.
PROCEDURE Globals;

-- ������� �������� ���������� ���������� ��������������� ��������������.
PROCEDURE GlobalValues;

-- ������� ������ ��������.
PROCEDURE CatalogTree;

-- ������� �����.
PROCEDURE Groups;

-- ������� ����������.
PROCEDURE DOCs;

-- ������� ��������, �� ���������� � ����������������.
PROCEDURE CATALOG(SetOfID TNUMBERS DEFAULT NULL);

-- ������� ��������. E��� ����� ����������� ��� �����������, 
-- �� ������������ ��� �������.
PROCEDURE ARRAYS(SetOfGroupID TNUMBERS DEFAULT NULL);

-- ������� �������� ������� � �� ����������.
PROCEDURE MODEL;

END OUTPUT;
/

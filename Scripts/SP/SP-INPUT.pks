CREATE OR REPLACE PACKAGE SP.INPUT
-- SP Input package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 13.10.2010 18.11.2010 22.11.2010 29.11.2010 20.12.2010 11.01.2011
--        13.01.2012 15.03.2012 04.06.2013 10.06.2013 22.08.2013 25.08.2013
--        04.10.2013 11.10.2013 16.10.2013 27.11.2013 13.02.2014 12.06.2014
--        13.06.2013 14.06.2014 15.07.2014 30.08.2014 08.09.2014 17.10.2014
--        04.11.2014 26.11.2014 28.11.2014 03.01.2015 06.01.2015 22.03.2015
--        25.03.2015 31.03.2015 20.04.2015-21.04.2015 10.07.2015 10.10.2016
--        12.04.2017 17.01.2018-19.01.2018 08.09.2021
AS
type TCatObject is Record(Name VARCHAR2(4000),ID NUMBER,GID NUMBER);
-- 1
FMT VARCHAR2(80) := NULL;
-- 2
NLS VARCHAR2(80) := NULL;
-- 3
CurType NUMBER := NULL;
-- 4
CurObject NUMBER := NULL;
-- 5
CurModelObject NUMBER:= NULL;
-- 6
CurDocGroupName SP.GROUPS.NAME%type := '';
-- 7
CurMacroCommand NUMBER := NULL;
-- 8
CurMacroLine NUMBER := NULL;
-- 9
CurMacroLineRef NUMBER := NULL;
-- 10
CurUser VARCHAR2(30) := NULL;
-- 11
CurPOID SP.COMMANDS.COMMENTS%type := '';
-- 12
CurParent SP.COMMANDS.COMMENTS%type := '\';
-- 13
CurModel NUMBER := NULL; 
-- 14
CurModelObjectParent NUMBER := NULL;
-- 15
CurAppName VARCHAR2(128) := NULL;
-- 16
CurFormName VARCHAR2(128) := NULL;
-- 17
CurSignature NUMBER := NULL;
-- 18
CurFormUserName VARCHAR2(128) := NULL;
-- 19
CurFormObjectName SP.COMMANDS.COMMENTS%type := NULL;
-- 20
CurParName VARCHAR2(128) := '';
-- 21
CurArrName SP.ARRAYS.NAME%type := '';
-- 22
CurArrGroup SP.GROUPS.NAME%type := '';
-- ������� ����������� ��������� ����������� ��������.
Safe BOOLEAN := false;

-- ����� ��������� ������� � ����������� ����, ������� ��������� ������.
PROCEDURE RESET;

-- ��������� ������� ����.
PROCEDURE SET_NLS(DFMT IN VARCHAR2, DNLS IN VARCHAR2);

-- ���������� ����.
PROCEDURE ROLE(NAME IN VARCHAR2, Comments IN VARCHAR2, ORA in NUMBER);

-- ���������� �������� �����.
PROCEDURE ROLE_REL(NAME IN VARCHAR2, PARENT IN VARCHAR2);

-- ���������� ������������. (������ ����������) 
PROCEDURE USER(NAME IN VARCHAR2, PSW IN VARCHAR2);

-- ���������� ���� ������������.
PROCEDURE UserRole(NAME IN VARCHAR2, RoleName IN VARCHAR2);

-- ������������� ������������������.
PROCEDURE SEQ(NAME IN VARCHAR2, LAST_NUM IN NUMBER);

-- ���������� ����, ��� ����������, ���� ��� ����������.
PROCEDURE "Type"(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  -- ���� ���� �������� �� ��������, �� �������� �����������,
  -- � ��������� ���� �������������.
  CheckVal IN VARCHAR2 DEFAULT NULL,
	StringToVal IN VARCHAR2 DEFAULT NULL,
	ValToString IN VARCHAR2 DEFAULT NULL,
	SetOfValues IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- ���������� ��� ���������� ������������ ��������, ���� �������� ����������.
PROCEDURE Enum(
  NAME IN VARCHAR2,
	Comments IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
  EType IN VARCHAR2 DEFAULT NULL,
  EN IN NUMBER DEFAULT NULL,
  ED IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL, -- ������ ����
  DNLS IN VARCHAR2 DEFAULT NULL, -- ���� ����
  ES IN VARCHAR2 DEFAULT NULL,
	EX IN NUMBER DEFAULT NULL,
	EY IN NUMBER DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- ���������� ����������� ��������� � ��������� ��� �������� �� ���������
-- ��� ������ ������������.
PROCEDURE GlobalPar(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
	ParType IN VARCHAR2,
  Reaction IN VARCHAR2 DEFAULT NULL,
  R_ONLY IN NUMBER DEFAULT NULL,
	V IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL 
  );

-- ��������� �������� ����������� ��������� ����������� ������������.
-- ���� ��� ������������ �� �������, �� ��������� ���������� ������������
-- ������������ ��� ������������, �������� ������ ��� ��������� ��������.
	PROCEDURE GlobalParValue(
  ParName IN VARCHAR2,
  V IN VARCHAR2,
  UserName IN VARCHAR2 DEFAULT NULL);

-- ���������� ���� ������ ��������.
-- ���� ����� ��������� �������� �������� ����, �� ����� ���������
-- ��������� "ParentNode" �������� "\".
PROCEDURE Node(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParentNode IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL);

-- ���������� ������, � ��������, � ��������,
-- � ������� ��� �������������� ����� ������ ��������
-- � ���� ��������������.
PROCEDURE BGroup(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER default null,
  Line IN NUMBER default null,
	Comments IN VARCHAR2 default null,
  Parent_Name IN VARCHAR2 default null,
  RoleName IN VARCHAR2 default null,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER default null);
  
-- ��������� ������ - ���������� ������ �� ������ ������.
-- ������ ���������� ��������� �������.
PROCEDURE Alias(
  GroupName IN VARCHAR2,
  -- ��� ������ => ������ ��� �������
  ObjectName IN VARCHAR2);
  
-- ���������� ���������, ��� �������, ������ �� ������, � ������ ���������
-- ������ ����� ������, � ����� ����� ������� � ��������������.
PROCEDURE DOC(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER default null);

-- ���������� ��������.!!!!
PROCEDURE DOCs(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
	Q IN NUMBER default null);
  
-- ���������� �������� �������.
PROCEDURE ArrValue(
  -- ������ ��� �������.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- �������� �������.
  indX in NUMBER DEFAULT NULL,
  indY in NUMBER DEFAULT NULL,
  indZ in NUMBER DEFAULT NULL,
  -- ��������� ������.
  indS in VARCHAR2 DEFAULT NULL,
  -- ������ �� ����.
  indD in DATE DEFAULT NULL,
  -- ��������� �������� ���� �������� �������� �������.
  T IN VARCHAR2, 
  -- ��������� �������� �������� �������.  
  V IN VARCHAR2 DEFAULT NULL, 
  -- ���� ���������� ��� ��������� ��������
  MDATE IN VARCHAR2 DEFAULT NULL,
  -- ������������, ���������� ��� ����������� ��������.
  MUSER IN VARCHAR2 DEFAULT NULL
  );

-- ���������� �������.
-- ���� ��� ������� �������� �����,
-- �� ��������� ��� ��� ���� ������ ��� �������.
-- � ���� ������ ��� ������ ������� ������������.
PROCEDURE OBJECT(
  NAME IN VARCHAR2,
  OID IN VARCHAR2 DEFAULT NULL,
  Kind IN VARCHAR2 DEFAULT NULL, -- (Single, Composit, Macro, Operation)
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
	GroupName IN VARCHAR2 DEFAULT NULL,
  -- ��� ������� �������, ��� ���������� ���� ��� ������� � ������ ������.
  Pars IN VARCHAR2 DEFAULT NULL,
  -- ��������� ���������� (������, ��������� �� ���� ���������� ����� �������),
  -- ������� �� �����������.
  ExceptPars IN VARCHAR2 DEFAULT NULL,
  UsingRole IN VARCHAR2 DEFAULT NULL,
  EditRole IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUser IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  -- ���� �������� ����� "-1", �� ��� ���������� ���,
  -- ��������� �������� ���� ���������� � ����������� � ������������
  -- ��������������.
  -- ��� ���� ����� ������� ������������ OID!
	Q IN NUMBER DEFAULT NULL);

-- ���������� ��������� �������.
-- ��������� ����������� ���������� ������������ ������� ��� �������,
-- ������������ ����������� CurObject � CurObjectGroup.
-- ���� ������ ������� �� ����������, �� ������ ������ ������������� �� �����.
-- ���� ��� ������� �������� �����, �� ���������� ��� ������ ��� �������,
-- � ���� ������ ������� �������� "ObjectGroup" ������������.
-- ����� ��� ����� ������ ���������� ��� �������� �������������.
-- ���� ���������� ���� ��� �������� DFMT ��� DNLS, �� ��� ����������
-- ���������� ��� ����������� �������.
PROCEDURE ObjectPar(
  NAME IN VARCHAR2,
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParType IN VARCHAR2,
  V IN VARCHAR2 DEFAULT NULL,-- ��������� ��������
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
	X IN NUMBER DEFAULT NULL,
	Y IN NUMBER DEFAULT NULL,
  -- ���������� ��������, ������� �� ����������� :
  -- (R/W, R_Only , Required, ReadWrite, ReadOnly, Fixed)
  R_ONLY IN VARCHAR2 DEFAULT 'R/W',
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL -- ��� ������� �������� Object_ID
  );

-- ���������� ������������. ���� ��� ������� ����,
-- �� ������������ ��������� ����������� ������.
-- �������� ����� ������� ���� ��� ������ ������� ������������������
-- ����������� �������� ��������.
-- ���� ������ ������� �� ����������, �� ������ ������ ������������� �� �����.
-- ���� ��� ������� �������� �����, �� ���������� ��� ������ ��� �������,
-- � ���� ������ ������� �������� "ObjectGroup" ������������.
-- ���������� ��� ������������� �������.
-- ����� ��� ����� ������ ���������� ��� �������� �������������.
-- �� �������������� ��� ������ ������� ��� �� ����������  � � �����������
-- ������������� �������.
PROCEDURE Macro(
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
  -- ���� ����� ������ �� ��������,
  -- �� ��������� ����� �� ������� ������ �������������.
  LineNum IN NUMBER DEFAULT NULL,
  Command IN VARCHAR2,
	Comments IN VARCHAR2 DEFAULT NULL,
  Alias IN VARCHAR2 DEFAULT NULL,
  UsedObject IN VARCHAR2 DEFAULT NULL,
  UsedObjectGroup IN VARCHAR2 DEFAULT NULL,
	MacroBlock IN VARCHAR2 DEFAULT NULL,
	Condition IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- ����������  ������.
PROCEDURE MODEL(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
  PERSISTENT IN NUMBER DEFAULT 0,
  LOCAL IN NUMBER DEFAULT 0,
  USING_ROLE IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL
  );

-- ���������� ������� ������.
PROCEDURE ModelObject(
  -- ��� ������. ���� �������, �� ������������ ���������� ��������.
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- ��� ������� � ������.
  ObjectName IN VARCHAR2,
  -- ���������� ������������� ������� � ��������� ������.
  OID IN VARCHAR2 DEFAULT NULL,
  -- ������ �� ���������� ������������� ������������� �������.
  -- �������� null, ��������� �� ������������� ������������ �������� ObjectPath
  -- ���� ������� ��� ���������, �� ������������ ���������� ��������.
  POID IN VARCHAR2 DEFAULT NULL,
  -- ���������� ��� ������������� ������� � ������.
  -- ���� ���������� ������ ������ ������ ������,
  -- �� ���������� ��������� ObjectPath �������� '/'.
  -- ���� ������������ �������� POID, �� �������� ����� ��������� �����
  -- ���������������.
  -- ���� �������, �� ������������ ���������� ��������.
  ObjectPath IN VARCHAR2 DEFAULT NULL,
  -- ��� ��������� ��������� � ��������.
  -- ���� ��� ��������� ������� �������� �����, 
  -- �� ���������� ��� ������ ��� �������,
  -- � ���� ������ ������� �������� "CatalogGroupName" ������������.
  CatalogName IN VARCHAR2,
  -- ��� ������ ��������� ������� � ��������. 
  -- ��� ���������� ������� ��������� �������������� ������������ ����� �
  -- ��������. ��������� ��� ������������� � �������� ������ ���������� ������.
  CatalogGroupName IN VARCHAR2 DEFAULT NULL,
	-- ��� ������������ ������� - ��������������� ������������ ������.
  -- ���� ��� ��������� ������� �������� �����, 
  -- �� ���������� ��� ������ ��� �������,
  -- � ���� ������ ������� �������� "CatalogGroupName" ������������.
	CompositName IN VARCHAR2 DEFAULT NULL,
  -- ������ ���������.
	CompositGroupName IN VARCHAR2 DEFAULT NULL,
	-- ��� ������������ �������, � �������� ���� ������ ���������� �������
  -- ������.
  -- ���� ��� ��������� ������� �������� �����, 
  -- �� ���������� ��� ������ ��� �������,
  -- � ���� ������ ������� �������� "CatalogGroupName" ������������.
	StartCompositName IN VARCHAR2 DEFAULT NULL,
  -- ������ ������������ �������, � �������� ���� ������ ���������� �������
  -- ������.
  StartCompositGroupName IN VARCHAR2 DEFAULT NULL,
  -- ����, ��������� ����������� ������.
  Modified IN BOOLEAN  DEFAULT NULL,
  -- ���� ������������� ������� ������.
  UsingRoleName IN VARCHAR2 DEFAULT NULL,
  -- ���� ��������� ������� ������.
  EditRoleName IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- ���������� �� ����������� ��� ���������������� ����������� ���������
-- ������� ������.
-- ���� ��� ������ � ��� ������� (� ��� OID) ����� ����,
-- �� ��������� ����������� ���������� ������������ �������.
PROCEDURE ModelObjectPar(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- ���������� ������������� �������.
  OID IN VARCHAR2 DEFAULT NULL,
  -- ���������� ��� ������� ������ ������������,
  -- ���� ������ ���������� �������������.
  -- ���� ������� ��� OID ��� � FullName, �� ������������ ���������� ��������.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- ��� ���������.
  NAME IN VARCHAR2,
  -- ��� ���������, ��������� ��� ��������� ���������� �������,
  -- ����������, ������������� � �������� ��������� ������� � ��������.
  T IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
  X IN NUMBER DEFAULT NULL,
  Y IN NUMBER DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  );

-- ���������� ��������� ���� ������ �� ������ ������.
-- ���� ��� ������ � ��� ������� (� ��� OID) ����� ����,
-- �� ��������� ����������� ���������� ������������ �������.
PROCEDURE ModelObjectRel(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- ���������� ������������� �������.
  OID IN VARCHAR2 DEFAULT NULL,
  -- ���������� ��� ������� ������. 
  -- ������������ ���� ������ ���������� �������������.
  -- ���� ������� ���, �� ������������ ���������� ��������.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- ��� ���������.
  NAME IN VARCHAR2,
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  );

-- ���������� ������� ��������� ������� ������.
-- ���� ��� ������ � ��� ������� (� ��� OID) ����� ����,
-- �� �������� ����������� ���������� ������������ �������.
-- ���� ��� ��������� �������,
-- �� ����������� ������� ���������� ������������ ���������.
PROCEDURE ModelObjectParStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- ���������� ������������� �������.
  OID VARCHAR2 DEFAULT NULL,
  -- ���������� ��� ������� ������. 
  -- ������������ ���� ������ ���������� �������������.
  -- ���� ������� ���, �� ������������ ���������� ��������.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- ��� ���������. ���� ������ ���� ���������� ��������.
  NAME IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
  X IN NUMBER DEFAULT NULL,
  Y IN NUMBER DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  );

-- ���������� ������� ������ �������� ������.
-- ���� ��� ������ � ��� ������� (� ��� OID) ����� ����,
-- �� �������� ����������� ���������� ������������ �������.
-- ���� ��� ��������� �������,
-- �� ����������� ������� ���������� ������������ ���������.
PROCEDURE ModelObjectRelStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- ���������� ������������� �������.
  OID VARCHAR2 DEFAULT NULL,
  -- ���������� ��� ������� ������. 
  -- ������������ ���� ������ ���������� �������������.
  -- ���� ������� ���, �� ������������ ���������� ��������.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- ��� ���������. ���� ������ ���� ���������� ��������.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- ������ �� OID ����� ���������.
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  );

-- ���������� ����������� ��������� ����� ����������.
-- ���� ��� ����������, ��� �����, � ��������� ��� ��� ������� ����� ����,
-- �� ��������� ����������� � ���������� ������������ �������.
-- ���������� � ������ ������������.
-- ��� ��������� ������ ���������, ����������������� �����,
-- ������������ �������� �������� ����������,
-- ����������� � ���������� ������� ���� ���������.
PROCEDURE FormPar(
  AppName IN VARCHAR2 DEFAULT NULL,
  FormName IN VARCHAR2 DEFAULT NULL,
  FormSignature IN NUMBER DEFAULT NULL,
  UserName IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  NAME IN VARCHAR2,
  V IN VARCHAR2,
  Ord IN NUMBER
  );

END INPUT;
/

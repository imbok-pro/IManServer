-- SP Global Pars
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010
-- update 22.09.2010 12.10.2010 03.11.2010 08.11.2010 17.11.2010 13.05.2011
--        02.11.2011 24.11.2011 21.12.2011 13.01.2012 16.03.2012 01.06.2013
--        10.06.2013 20.08.2013 25.08.2013 30.09.2013 03.10.2013 02.07.2014
--        26.08.2014 30.08.2014 29.01.2015 04.02.2015 22.04.2015 05.07.2015
--        09.07.2015 06.11.2015 22.11.2016 12.09.2017 21.01.2021 23.01.2021
--        09.09.2021
--*****************************************************************************

-------------------------------------------------------------------------------	
CREATE TABLE SP.GLOBAL_PAR_S
(
  ID NUMBER,
  NAME VARCHAR2(128) NOT NULL,
  COMMENTS VARCHAR2(4000) not NULL,
  TYPE_ID NUMBER(9) NOT NULL,
	E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
  Y NUMBER,
	REACTION VARCHAR2(4000),
	R_ONLY NUMBER(1) default 0 not Null,
  GROUP_ID NUMBER default 9 NOT NULL,
	CONSTRAINT PK_GLOBAL_PAR_S PRIMARY KEY (ID),
  CONSTRAINT REF_GLOBAL_PAR_S_to_TYPES_ID
  FOREIGN KEY (TYPE_ID) 
  REFERENCES SP.PAR_TYPES (ID) ON DELETE CASCADE,
  CONSTRAINT REF_GLOBAL_PAR_S_to_GROUPS_ID
  FOREIGN KEY (GROUP_ID) 
  REFERENCES SP.GROUPS (ID)
);

CREATE UNIQUE INDEX SP.GLOBAL_PAR_S_NAME 
  ON SP.GLOBAL_PAR_S (upper(NAME));
CREATE INDEX SP.GLOBAL_PAR_S_TYPE_ID ON SP.GLOBAL_PAR_S (TYPE_ID);
CREATE INDEX SP.GLOBAL_PAR_S_GROUP_ID ON SP.GLOBAL_PAR_S (GROUP_ID);

COMMENT ON Table SP.GLOBAL_PAR_S IS '���������� ���������.(SP-GLOBALS.sql)';

COMMENT ON COLUMN SP.GLOBAL_PAR_S.ID        IS '������������� ���������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.NAME      
  IS '��� ���������. ��� ���������, �������� ��� ��������������� ��� �������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.COMMENTS  IS '�������� ���������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.TYPE_ID   IS '��� ���������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.GROUP_ID  IS '������ ���������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.E_VAL     IS '����������� ��������.';	
COMMENT ON COLUMN SP.GLOBAL_PAR_S.N         IS '��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.D         IS '��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.S         IS '��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.X         IS '��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.Y         IS '��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.REACTION 
  IS '���� PL/SQL, ����������� ����� ���������� ���������. ��� ��������� ���������� ����������� ��� ������������ ����� ����� ���������� ������� ������� ����������, ������ ������� ���������� �� �������� � ���������� ������ �����, ��������� �������� �������� ��������������� ���������� � ��������� ���������� (���������) ��������, ��������, ��� ��� ��������� ���������� ������. ������ ����� �������� �������� "P" ���� "SP.TGPAR", ���������� ����� ��������.';
COMMENT ON COLUMN SP.GLOBAL_PAR_S.R_ONLY 
  IS '���� 1, �� ��� �������� ������ ��� ������ �� ������ ������������ �� ������ ������ ��� ����� ������. ��� �������� ���� TGPar ������� ��������� � ������ ������������ ����� ������������ �������� �� ��������� ������� SP.GLOBAL_PAR_S(� ������ ���������� ��������������� �������� � �������� � SP.USERS_GLOBALS), 2 - �������� ��������� ��������� ��� ���� � �����. -1 ������ ������ ���� �������, �� ����� ���������� �������� ���������. �������� -1 � 2 �������� ������ ��� ���������� ����������.';

-- �������� ���������� ����������, ��������������� � ���������� �������������.
-------------------------------------------------------------------------------	
CREATE TABLE SP.USERS_GLOBALS
(
  ID NUMBER,
  GL_PAR_ID NUMBER not NULL,
  SP_USER VARCHAR2(60),
	E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER,
	CONSTRAINT PK_USERS_GLOBALS PRIMARY KEY (ID),
  CONSTRAINT REF_USERS_GLOBALS_to_P_PAR_S
  FOREIGN KEY (GL_PAR_ID) 
  REFERENCES SP.GLOBAL_PAR_S (ID) ON DELETE CASCADE
);

CREATE UNIQUE INDEX SP.USERS_GLOBALS_PAR_USER 
  ON SP.USERS_GLOBALS(Upper(SP_USER),GL_PAR_ID);
CREATE INDEX SP.USERS_GLOBALS_GL_PAR_ID ON SP.USERS_GLOBALS(GL_PAR_ID);

COMMENT ON Table SP.USERS_GLOBALS 
  IS '�������� ���������� ����������, ��������������� � ���������� �������������.(SP-GLOBALS.sql)';

COMMENT ON COLUMN SP.USERS_GLOBALS.ID        IS '������������� ���������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.GL_PAR_ID      
  IS '������ �� �������� �� ���������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.SP_USER   
  IS '��� ������������. ��������� IMan �� ��������� �������������, ������������ ������ ���������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.E_VAL     IS '����������� ��������.';	
COMMENT ON COLUMN SP.USERS_GLOBALS.N         IS '��������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.D         IS '��������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.S         IS '��������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.X         IS '��������.';
COMMENT ON COLUMN SP.USERS_GLOBALS.Y         IS '��������.';

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_strR_ONLY(RO in NUMBER)
return VARCHAR2
-- �������������� � ��������� �������� �������� ����������� ��������� ���������
-- (SP-GLOBALS.sql)
as
begin
  case RO
	  when 0  then return 'R/W';
		when 1  then return 'R_ONLY';
		when 2  then return 'Fixed';
    when -1 then return 'Required';
    when -2 then return 'Storyless';
else
	  raise_application_error(-20033,
		  'SP.to_strR_ONLY, �������� �������� R_ONLY: '||to_Char(RO)||'!');
	end case;
end;
/

GRANT EXECUTE ON SP.to_strR_ONLY to public;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_R_ONLY(RO in VARCHAR2)
return NUMBER
-- �������������� ���������� �������� ����������� ��������� ���������
-- � ��������. �� ��������� ������������� R/W.
-- (SP_GLOBALS.sql)
as
begin
  if RO is NULL then return 0; end if;
  case upper(RO)
	  when 'R/W'  then return 0;
		when 'R_ONLY'  then return 1;
	  when 'READWRITE'  then return 0;
		when 'READONLY'  then return 1;
		when 'FIXED'  then return 2;
    when 'REQUIRED' then return -1;
    when 'STORYLESS' then return -2;
else
	  raise_application_error(-20033,
		  'SP.to_R_ONLY, �������� �������� R_ONLY: '||RO||'!');
	end case;
end;
/

GRANT EXECUTE ON SP.to_R_ONLY to public;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.R_ONLY_VAL_S(GLOBALS in NUMBER default null)
return REPLICATION.TIDENTIFIERS pipelined
-- �������� ��������� �������� ����������� ��������� ���������
-- ��� ������������� ������� �������� ��� �������������� ���������� ����������
-- ���������� �������� � �������� ��������� ����� �������� �������� (�� ����).
-- (SP_GLOBALS.sql)
as
begin
  pipe row('R/W');
	pipe row('R_ONLY');
	if Globals is not null then pipe row('FIXED'); end if;
  if Globals is null then pipe row('REQUIRED'); end if;
  if Globals is null then pipe row('STORYLESS'); end if;
 return;
end;
/

GRANT EXECUTE ON SP.R_ONLY_VAL_S to public;


--*****************************************************************************
-- ���������� �������� ���������� ���������� �� ���������.
declare
	tmp SP.COMMANDS.COMMENTS%type; 
  i NUMBER;
begin
i:=0;

-- TestValue
-------------------------------------------------------------------------------
tmp:='�������� ��� �������� � ������� �����, ��������������� ��������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'testTValue',tmp,
  SP.G.TNoValue,null,null,NULL,null,null,null,
	null,
  SP.G.Required,4);
i:=i+1;

-- DEBUG_MODE
-------------------------------------------------------------------------------
tmp:='��������� ��� ��������� �������� ���������� ��������� ������. �� ��������� - ���������. ��������� �������� �������� � ���������� ���������, ������� ����������� �������� � ������. �������� �� ������� ������� ���������� � ����������� ����������� ��������� ���������� ����������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'DEBUG_MODE',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
	'DEBUG_OUTPUT.SETSTATE(case p.Val.N when 0 then false else true end);',
  SP.G.REQUIRED,4);
i:=i+1;
	
-- S_VERSION
-------------------------------------------------------------------------------
tmp:='������ ����.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'S_VERSION',tmp,
  SP.G.TInteger,Null,500,sysdate,null,null,null,
	'',
	SP.G.Fixed,5);	
i:=i+1;
	
-- Check_ValEnabled
-------------------------------------------------------------------------------
tmp:='��������� ��� ��������� �������� �����. '||
	'�� ��������� - ���������';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'Check_ValEnabled',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
	'SP.Set_CheckValEnabled(P.Val.N);',
  SP.G.REQUIRED,4);
i:=i+1;
	
-- TimeOut
-------------------------------------------------------------------------------
tmp:='TimeOut ��� ������ ������� � �������� �� ��������� 30 ������. ����� ������ ����������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,
  'TimeOut', 
  tmp,
  SP.G.TDouble,
  Null,
  30 ,
  NULL,
  null,
  null,
  null,
	'',
	SP.G.ReadWrite,4);
i:=i+1;
	
-- MessagesOn
-------------------------------------------------------------------------------
tmp:='���������� ��� ������������ ���������';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'MessagesOn',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
	'',
	SP.G.ReadWrite,4);	
i:=i+1;

-- NLang
-------------------------------------------------------------------------------
tmp:='NLS_Language �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_Language',tmp,
  SP.G.TNLang,'RU',null,null,'RUSSIAN',null,null,
	'SP.SetNLS_Language(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;
 
-- NTerritory
-------------------------------------------------------------------------------
tmp:='NLS_Territory �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_Territory',tmp,
  SP.G.TNTerritory,'RU',null,null,'RUSSIA',null,null,
	'SP.SetNLS_Territory(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;
 
-- NNumChars 
-------------------------------------------------------------------------------
tmp:='���������� ����������� � ����������� ����� �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_Numeric_Characters',tmp,
  SP.G.TNNumChars,'DPointTBlank',null,null,'. ',null,null,
	'SP.SetNNumChars(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;

-- NSort 
-------------------------------------------------------------------------------
tmp:='NLS_SORT �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_SORT',tmp,
  SP.G.TNSort,'RU',null,null,'RUSSIAN',null,null,
	'SP.SetNLS_SORT(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;
	
-- NDateFormat 
-------------------------------------------------------------------------------
tmp:='NLS_DATE_FORMAT �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_DATE_FORMAT',tmp,
  SP.G.TNDFormat,null,null,null,'DD.MM.RRRR HH24:MI:SS',null,null,
	'SP.SetNLS_DFormat(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;

-- NDLang
-------------------------------------------------------------------------------
tmp:='NLS_Date_Language �������� ������������.';	
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NLS_Date_Language',tmp,
  SP.G.TNLang,'RU',null,null,'RUSSIAN',null,null,
	'SP.SetNLS_Date_Language(p.VAL.S);',
	SP.G.REQUIRED,4);	
i:=i+1;

-- USER_PWD
-------------------------------------------------------------------------------
tmp:='������� �������� ������ ������������. ������������ ����� ��� ���������� ������ ������������.';  
 INSERT INTO SP.GLOBAL_PAR_S 
   VALUES(i,'USER_PWD',tmp,
   SP.G.TStr4000,null,null,null,null,null,null,
   null,
  SP.G.REQUIRED,4);  
 i:=i+1;
 
-- USER_COMMENTS
-------------------------------------------------------------------------------
tmp:='������� �������� ��� �������� ������������.';  
 INSERT INTO SP.GLOBAL_PAR_S 
   VALUES(i,'USER_COMMENTS',tmp,
   SP.G.TStr4000,null,null,null,null,null,null,
   null,
  SP.G.REQUIRED,4);  
 i:=i+1;
 
-- USER_GROUP
-------------------------------------------------------------------------------
tmp:='������� ��������, ���������� �������������� ������������ � ������.';  
 INSERT INTO SP.GLOBAL_PAR_S 
   VALUES(i,'USER_GROUP',tmp,
   SP.G.TGROUP,null,null,null,null,null,null,
   null,
  SP.G.REQUIRED,4);  
 i:=i+1;
 
-- CurModel
-------------------------------------------------------------------------------
tmp:='T������ ��� ������.';
insert into SP.GLOBAL_PAR_S
  VALUES (i,'CurModel',tmp,
   SP.G.TStr4000,null,null,null,'DEFAULT',null,null,
   'SP.Set_CurModel(p.VAL.S);',
    SP.G.REQUIRED,4);	
i:=i+1;
	
-- CurBuh
-------------------------------------------------------------------------------
-- ������� ��� ����������� (������ ����� ������). 
tmp:='������� ��� ����������� (������ ����� ������). ������ �������� ��������� � CurModel, ��������, ��� �������������� ����� ������.';
insert into SP.GLOBAL_PAR_S
  VALUES (i,'CurBuh',tmp,
   SP.G.TStr4000,null,null,null,'Buh||Example',null,null,
   'SP.Set_CurBuh(p.VAL.S);',
    SP.G.REQUIRED,4);	
i:=i+1;	

-- Create_Model
-------------------------------------------------------------------------------
tmp:='P�������� ��������������� �������� �������� �� ������� �������, �������� ����������� ������� �� ���������� ������. �� ��������� - ���������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'Create_Model',tmp,
  SP.G.TBoolean,'false',0,NULL,null,null,null,
	'SP.Set_Create_Model(P.Val.N);',
  SP.G.REQUIRED,4);
i:=i+1;

-- Delete_Start_Composit
-------------------------------------------------------------------------------
tmp:='���� ���������� ���� ����, �� ��� ������ ��������������, ���������� ����������� ��������, ��������� ���������� ������ (��������� ������ ���). �� ��������� - ��������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'Delete_Start_Composit',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
	'SP.Set_Delete_Start_Composit(P.Val.N);',
  SP.G.REQUIRED,4);
i:=i+1;

-- TypesGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ����� ��������, ������������� VG_Types.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'TypesGroup',tmp,
  SP.G.TGroup,null,3,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''TypesGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- TypesGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ����� ��������, ������������� VG_Types.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'TypesGroupROOT',tmp,
  SP.G.TGroup,null,3,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''TypesGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- ParsGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ���������� ��������, ������������� VG_COMMAND_PAR_S  � VG_MODEL_OBJECT_PARS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'ParsGroup',tmp,
  SP.G.TGroup,null,1,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''ParsGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- ParsGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ���������� ��������, ������������� VG_COMMAND_PAR_S  � VG_MODEL_OBJECT_PARS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'ParsGroupROOT',tmp,
  SP.G.TGroup,null,1,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''ParsGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- GlobalsGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ���������� ����������, ������������� VG_GLOBALS, VG_USERS_GLOBALS � VG_GLOBAL_PAR_S.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'GlobalsGroup',tmp,
  SP.G.TGroup,null,4,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''GlobalsGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- GlobalsGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ���������� ����������, ������������� VG_GLOBALS, VG_USERS_GLOBALS � VG_GLOBAL_PAR_S.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'GlobalsGroupROOT',tmp,
  SP.G.TGroup,null,4,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''GlobalsGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- CatalogTreeGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ������������� VG_CATALOG_TREE.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'CatalogTreeGroup',tmp,
  SP.G.TGroup,null,5,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''CatalogTreeGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- CatalogTreeGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ������������� VG_CATALOG_TREE.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'CatalogTreeGroupROOT',tmp,
  SP.G.TGroup,null,5,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''CatalogTreeGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- UsedObjectGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ������������� VG_USED_OBJECTS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'UsedObjectGroup',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''UsedObjectGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- UsedObjectGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ������������� VG_USED_OBJECTS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'UsedObjectGroupROOT',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''UsedObjectGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- ObjectsGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ��� ������������� VG_OBJECTS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'ObjectsGroup',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''ObjectsGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- ObjectsGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ��� ������������� VG_OBJECTS.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'ObjectsGroupROOT',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
	'SP.GRAPH2TREE.SetRoot(P.Val.N, ''ObjectsGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- NewObjectsGroup
-------------------------------------------------------------------------------
tmp:='�������� ���������� �������� ������� ����� ��� ������ ������ ��� ����� ���������� �������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NewObjectsGroup',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
  'SP.GRAPH2TREE.SetRoot(P.Val.N, ''NewObjectsGroup'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- NewObjectsGroupROOT
-------------------------------------------------------------------------------
tmp:='�������� ���������� ������ ����� ��� ������ ������� ����� ��� ����� ���������� �������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'NewObjectsGroupROOT',tmp,
  SP.G.TGroup,null,2,NULL,null,null,null,
  'SP.GRAPH2TREE.SetRoot(P.Val.N, ''NewObjectsGroupROOT'');',
  SP.G.REQUIRED,4);
i:=i+1;

-- ServerService
-------------------------------------------------------------------------------
tmp:='�������� ��������� ������ ���������� ������������ ��� ������������ �������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'ServerService',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
  null,
  SP.G.ReadOnly,4);
i:=i+1;

-- TEST_MACRO_PARS
-------------------------------------------------------------------------------
tmp:='P�������� �������� ���������� �� ������� ������������ �������� � �� ������������ ��������, ��������������� ������ ��� ������.  �� ��������� - ���������.';
INSERT INTO SP.GLOBAL_PAR_S 
  VALUES(i,'TEST_MACRO_PARS',tmp,
  SP.G.TBoolean,'true',1,NULL,null,null,null,
  ' SP.TG.TEST_MACRO_PARS := P.Val.N = 1;',
  SP.G.REQUIRED,4);
i:=i+1;

-- ...
	
end;
/	

-- ���������� ��������� �������� ������������.
-- ���� ������������ ��� � ���������� ������� ���������� ����������,
-- �� � ������� ������� ������� ��������� �� ���������. 
-- ���� ����� ���� �������� ������ � �����, �� �������� ��� ��������� ��������
-- � ������� ���������� ���������� �������������.  
-------------------------------------------------------------------------------	
CREATE GLOBAL TEMPORARY TABLE SP.WORK_GLOBAL_PAR_S
( 
  UG_ID NUMBER,
  NAME VARCHAR2(128) NOT NULL,
  TYPE_ID NUMBER(9) NOT NULL,
  CHECK_VAL ROWID,
	E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER,
	REACTION VARCHAR2(4000),
	R_ONLY NUMBER(1) default 0 not Null
  )
ON COMMIT PRESERVE ROWS;

CREATE UNIQUE INDEX SP.UK_WORK_GLOBAL_PAR_S 
  on SP.WORK_GLOBAL_PAR_S(upper(NAME));	

COMMENT ON Table SP.WORK_GLOBAL_PAR_S 
  IS '���������� ��������� ������������ �������� ������.';

COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.UG_ID  
  IS 'ID � ������� �������� ���������� ���������� ������������� ��� ����, ���� �������� �� ���������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.NAME
  IS '��� ���������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.TYPE_ID
  IS '��� ���������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.CHECK_VAL
  IS '������ �� ��������� �������� �������� ��������� ��������� ��� ����, ���� ��������� �� ����������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.E_VAL 
  IS '��� �������� �������������� ����.';	
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.N 
  IS '��������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.D         
  IS '��������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.S         
  IS '��������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.X         
  IS '��������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.Y         
  IS '��������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.REACTION 
  IS '���� pl/sql, ����������� ����� ���������� ���������.';
COMMENT ON COLUMN SP.WORK_GLOBAL_PAR_S.R_ONLY 
  IS '���� >0 �� ��� �������� ������ ��� ������.';
				
grant select,update on SP.WORK_GLOBAL_PAR_S to public;	

-- end of file



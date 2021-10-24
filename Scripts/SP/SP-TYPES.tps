-- TYPES
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010 
-- update 06.09.2010 14.09.2010 16.09.2010 08.10.2010 13.10.2010 20.10.2010
--        28.10.2010 19.11.2010 24.11.2010 10.12.2010 17.12.2010 09.02.2011
--		    18.03.2011 11.05.2011 17.10.2011 10.11.2011 27.01.2012 11.04.2012 
--        04.04.2013 09.04.2013 04.06.2013 17.06.2013 22.08.2013 16.10.2013
--        22.06.2014 27.10.2014 
-- update 09.09.2014 by Evgeniy Piatakov
-- update by Nikolay Krasilnikov 27.10.2014 22.03.2015 25.05.2015 08.07.2015
--        23.12.2015 11.02.2016 29.02.2016 27.10.2016
-------------------------------------------------------------------------------
-- ������ � ����� ����� ��� ������������� � SQL Developer(������ ��� ��������). 
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSTRINGS 
/* ������� ������.*/
/* SP-TYPES.tps*/
IS TABLE OF VARCHAR2(4000)
                   ');
END;
/
GRANT EXECUTE ON SP.TSTRINGS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSHORTSTRINGS 
/* �������� ������.*/
/* SP-TYPES.tps*/
IS TABLE OF VARCHAR2(128) 
                   ');
END;
/
GRANT EXECUTE ON SP.TSHORTSTRINGS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TS_VALUE_COMMENTS 
/* SP-TYPES.tps*/
/* �������� � ����������� � ����. 
������ ��� ���������� ��������� ������, � �������� ���������������
��������� ������ �������� ��� ����������� ���� TValue.*/
AS OBJECT
(
/* ������������� ��������.*/
ID NUMBER,
/* ��������.*/
S_VALUE VARCHAR2(4000),
/* ����������� � ��������.*/
COMMENTS VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TS_VALUE_COMMENTS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TS_VALUES_COMMENTS 
/*����� �������� � �������������.
������ ��� ���������� ��������� ������, � �������� ���������������
��������� ������ �������� ��� ����������� ���� TValue.*/
/* SP-TYPES.tps*/
IS TABLE OF SP.TS_VALUE_COMMENTS 
                    ');
END;
/
GRANT EXECUTE ON SP.TS_VALUES_COMMENTS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TROLE_REC 
/* ������, ���������� �������������, ��� � �������� ����.
������ ��� ���������� ��������� ������.
   SP-TYPES.tps*/
AS OBJECT
(
/* ������������� ����.
������ ������: ������������� ����||'L'||�������||D||��������� */             
NODE VARCHAR2(128),
/* ����, ���������� ����� �� ���� ����. */
PNODE VARCHAR2(128),
/* ��� ����.*/
NAME  VARCHAR2(128),
/* ������� �����.*/
LEAF NUMBER(1)
);
/
GRANT EXECUTE ON SP.TROLE_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TROLE_RECORDS 
/* ����� �� �������, ���������� �������������, ��� � �������� ����.
������ ��� ���������� ��������� ������.
   SP-TYPES.tps*/
IS TABLE OF SP.TROLE_REC 
                    ');
END;
/
GRANT EXECUTE ON SP.TROLE_RECORDS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TERROR_REC 
/* ������, ���������� �������� �� ������� ��� ��������������� ��� ���������� 
�������� ����.
   SP-TYPES.tps*/
AS OBJECT
(
/* �������� �������.*/
OWNER VARCHAR2(30),
/* ��� �������.*/
NAME VARCHAR2(30),
/* ��� �������.*/
TYPE VARCHAR2(12),
/* �������� �� ������ ����, ���������� ������.*/
LINE NUMBER,
/* ��������� �� ������� � ������ ����.*/
POSITION NUMBER,
/* ��������� �� ������.*/
TEXT VARCHAR2(4000),
/* �������, �������� �� ������ ������ ���������� �� ������ ��� 
���������������. */
ATTRIBUTE VARCHAR2(9)
);
/
GRANT EXECUTE ON SP.TERROR_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TERROR_RECORDS 
/*  ���� �� �������, ���������� ��������� �� ������� ��� ��������������
�����������.
    SP-TYPES.tps*/
IS TABLE OF SP.TERROR_REC 
                    ');
END;
/
GRANT EXECUTE ON SP.TERROR_RECORDS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TIMAN_PAR_REC 
/*  ������ ��� ������������ ��� �������� �������� ���������� ������� ������ ��� ������������. ��� ������ � ������� SP.MACRO ������������ ��� �������� �������� �������. ��������� ���� ��������� �� ���������� ��������� ������� SP.WORK_OBJECTS_PAR_S  SP-TYPES.tps*/
AS OBJECT
(
/* ��� ���������. */
NAME VARCHAR2(255),
/* ��� ���������.*/
T NUMBER(9),
/* ��� �������� ��� ������������� �����.*/
E VARCHAR2(128),
/* ���� ��������.*/
N NUMBER,
/* ���� ��������.*/
D DATE,
/* ���� ��������.*/
S VARCHAR2(4000),
/* ���� ��������.*/
X NUMBER,
/* ���� ��������.*/
Y NUMBER,
/* ������ ���� ������������ ��� ����������� ������� � ������������� � ������� Get_User_Input. ���� R_ONLY = 0, �� �������� ��������� ����� ������ � ����������. ���� R_ONLY = 1, �� �������� ��������� ����� ������ ������. ���� R_ONLY = -1, �� �������� ��������� ������ ���� ����������� ��������� �������������. */
R_ONLY NUMBER(1),
/* ������ ���� ������������ ��� �������� ���������� �������� � ����� �������. ������ �������� ������� ���� ����� ���� ��� ������ �������� �������, ��� � ���������� ��������������� �������.*/
OBJECT_INDEX NUMBER,
/* ����������� ������ ������.*/
CONSTRUCTOR FUNCTION TIMAN_PAR_REC 
RETURN SELF AS RESULT,
/* ����������� ������ ������ �� ����� ��������� � ��� ��������.*/
CONSTRUCTOR FUNCTION TIMAN_PAR_REC(pName IN VARCHAR2,pVal IN SP.TVALUE, oIndex IN NUMBER DEFAULT null)
RETURN SELF AS RESULT,
/* ��������� ����������� ������ ��� ��������� � ��� ��������.*/
MEMBER PROCEDURE Assign(self IN OUT SP.TIMAN_PAR_REC,
                        pName IN VARCHAR2,
                        pVal IN SP.TVALUE,
                        oIndex IN NUMBER DEFAULT null)
);
/
GRANT EXECUTE ON SP.TIMAN_PAR_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TIMAN_PARS 
/* ����� �� �������, ���������� ��� � �������� ���������.
������ ��� ���������� ��������� ������.
SP-TYPES.tps*/
IS TABLE OF SP.TIMAN_PAR_REC
                    ');
END;
/
GRANT EXECUTE ON SP.TIMAN_PARS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TNUMBERS 
/* ������� �� �������� �����.
    SP-TYPES.tps*/
IS TABLE OF NUMBER
                    ');
END;
/
GRANT EXECUTE ON SP.TNUMBERS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TFORM_PARAM 
/*  ������ �������� ��������, ����������� ��� ���������� ���������� ����������,
��� ������� ������������.
    SP-TYPES.tps*/
AS OBJECT
(
/* ��� ���������� ��� ��� �����(�����).*/
OBJ_NAME VARCHAR2(4000),
/* ��� ���������.*/
PROP_NAME VARCHAR2(128),
/* �������� ��������� � ���� ������.*/
PROP_VALUE VARCHAR2(4000),
/* ������� ��������� ����������.*/
ORD NUMBER(9)
);
/
GRANT EXECUTE ON SP.TFORM_PARAM TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TFORM_PARAMS 
/*  ������� ������� ����������.
    SP-TYPES.tps*/
IS TABLE OF SP.TFORM_PARAM
                    ');
END;
/
GRANT EXECUTE ON SP.TFORM_PARAMS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TSOURCE_LINE 
/* ������, �������������� ������ ���� ���������.
   SP-TYPES.tps*/
AS OBJECT
(
/* ����� ������.*/
LINE NUMBER(9),
/* ���������� ������.*/
TEXT VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TSOURCE_LINE TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSOURCE 
/* �������, �������������� �������.
    SP-TYPES.tps*/
IS TABLE OF SP.TSOURCE_LINE
                    ');
END;
/
GRANT EXECUTE ON SP.TSOURCE TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TREL
/* ������, �������������� ����� �������.
   SP-TYPES.tps*/
as OBJECT
(
GR NUMBER,
INC NUMBER,
R_TYPE NUMBER,
ID NUMBER
);
/
GRANT EXECUTE ON SP.TREL to PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TRELS
/* ������� ������.
   SP-TYPES.tps*/
IS TABLE OF SP.TREL;
                    ');
END;
/
GRANT EXECUTE ON SP.TRELS to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TGRAPH2TREE_NODE as OBJECT
/* ������, �������������� ����� �������, ����� �������������� � ������.
   SP-TYPES.tps*/
(
/*������������� ��������.
������ ������: ������������� ����||'L'||�������||D||��������� */             
NODE VARCHAR2(128),
/*������������� ��������*/             
PNODE VARCHAR2(128),
/* �������� ��������*/
TEXT VARCHAR2(128),
/* ������� ����� ������.*/
LEAF NUMBER(1),
/* ���������� ����� ������ � �����.*/
LINE NUMBER(9)
);
/
GRANT EXECUTE ON SP.TGRAPH2TREE_NODE to PUBLIC;
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TGRAPH2TREE_NODES
/* ������� ������, ��������������� � ������.
   SP-TYPES.tps*/
IS TABLE OF SP.TGRAPH2TREE_NODE;
                    ');
END;
/
GRANT EXECUTE ON SP.TGRAPH2TREE_NODES to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TMODEL_OBJECT_RECORD as OBJECT
/* ������, �������������� ������ ������, ������������ ��� ������������
   ������ �������� ������������ �������� �����.
   SP-TYPES.tps*/
(
  ID NUMBER,
  MODEL_ID NUMBER,
  MOD_OBJ_NAME VARCHAR2(128),
  OID VARCHAR2(40),
  OBJ_ID NUMBER,
  PARENT_MOD_OBJ_ID NUMBER,
	COMPOSIT_ID NUMBER,
	START_COMPOSIT_ID NUMBER,
  MODIFIED NUMBER(1),
  M_DATE DATE,
  M_USER VARCHAR2(60),
  OBJ_LEVEL NUMBER,
  FULL_NAME VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TMODEL_OBJECT_RECORD to PUBLIC;
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TMODEL_OBJECTS
/* �������, �������������� ������� ������.
   SP-TYPES.tps*/
IS TABLE OF SP.TMODEL_OBJECT_RECORD;
                    ');
END;
/
GRANT EXECUTE ON SP.TMODEL_OBJECTS to PUBLIC;


-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
create or replace TYPE SP.TPKFNote as Object(
        /* ��� - ��������� ���� �� ��������� ������������  
        SP-TYPES.tps  */
        /* ������������� ��������� � �������� ��� */
    Teg varchar2(128),
        /* ���� ���������*/
    TegValue varchar2(4000),
        /* �������� ���������*/
    fullfileName varchar2(4000),
        /* �������� ����� ��� ��� ������������� ������������ */
    pkfInputNum varchar2(32),
    author varchar2(256) ,
    crDateTime date,
        /* ����� ��������  */
    LoadNum int,
     /* ���������� ����� ��������� � ����� ��������� ��� ������ ���� */
    Num int,
     /* ��������� ���� ����� ���������, ������������ ������������������� */
    SeqNum integer
);
                    ');
END;
/
GRANT EXECUTE ON SP.TPKFNote to PUBLIC;

BEGIN
    EXECUTE IMMEDIATE('
        /* ��� - ������� ��������� �����, ��� pipeline �������   
        SP-TYPES.tps  */ 
    create or replace type SP.TPKFNoteTable as table of SP.TPKFNote;
    ');
END;
/
GRANT EXECUTE ON SP.TPKFNoteTable to PUBLIC;

-- end of file

-- WFORMS tables
-- by Irina Gracheva 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 30.09.2010  
-- update 21.10.2010 23.11.2010 21.12.2011 08.07.2015 09.11.2017 13.11.2017
--        03.10.2018 14.01.2021 27.01.2021
--*****************************************************************************

-- ������ ��������� ����, ���������� � ����.

-------------------------------------------------------------------------------
CREATE TABLE WFORMS.FORM_SIGN_S
(
  ID NUMBER,
  USER_NAME VARCHAR2(30),
  APP_NAME VARCHAR2(128) NOT NULL,
  FORM_NAME VARCHAR2(128) NOT NULL,
  SIGNATURE NUMBER(10),
  M_DATE DATE,
  CONSTRAINT PK_FORM_SIGN_S PRIMARY KEY (ID)
);

CREATE unique INDEX WFORMS.FORM_SIGN_S_UN 
  ON WFORMS.FORM_SIGN_S(upper(USER_NAME), upper(APP_NAME), upper(FORM_NAME),
                    SIGNATURE);

COMMENT ON TABLE WFORMS.FORM_SIGN_S IS '������� ���� ����������, ��������� ������� ����������� � ����.(WForms.sql)';

COMMENT ON COLUMN WFORMS.FORM_SIGN_S.ID       		 	IS '������������� �����';
COMMENT ON COLUMN WFORMS.FORM_SIGN_S.USER_NAME     	IS '��� ������������';
COMMENT ON COLUMN WFORMS.FORM_SIGN_S.APP_NAME     	IS '��� ����������';
COMMENT ON COLUMN WFORMS.FORM_SIGN_S.FORM_NAME     	IS '��� �����';
COMMENT ON COLUMN WFORMS.FORM_SIGN_S.SIGNATURE      IS '���������';
COMMENT ON COLUMN WFORMS.FORM_SIGN_S.M_DATE         IS '���� �������� ���������';

CREATE TABLE WFORMS.FORM_PARAMS
(
  ID NUMBER,
  FS_ID NUMBER,
  OBJ_NAME VARCHAR2(4000) NOT NULL,
  PROP_NAME VARCHAR2(128) NOT NULL,
  PROP_VALUE VARCHAR2(4000),
  ORD NUMBER(9),
  M_DATE DATE,
  PROP_CLOB CLOB Default NULL,
  CONSTRAINT PK_FORM_PARAMS PRIMARY KEY (ID),
  CONSTRAINT REF_FORM_PARAMS_to_FORM_SIGN_S
    FOREIGN KEY (FS_ID) 
    REFERENCES WFORMS.FORM_SIGN_S (ID) ON DELETE CASCADE
);

CREATE unique INDEX WFORMS.FORM_PARAMS_UN 
  ON WFORMS.FORM_PARAMS(FS_ID, upper(OBJ_NAME), upper(PROP_NAME));
CREATE INDEX WFORMS.FORM_PARAMS_FS_ID ON WFORMS.FORM_PARAMS(FS_ID);
CREATE INDEX WFORMS.FORM_PARAMS_OBJ_NAME ON WFORMS.FORM_PARAMS(OBJ_NAME);
CREATE INDEX WFORMS.FORM_PARAMS_PROP_NAME ON WFORMS.FORM_PARAMS(PROP_NAME);

COMMENT ON TABLE WFORMS.FORM_PARAMS IS '��������� ��������� ���������� ���� ���������� ��� ������� ������������.(WForms.sql)';

COMMENT ON COLUMN WFORMS.FORM_PARAMS.ID    
 	IS '������������� ���������';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.FS_ID 
 	IS '������ �� ������������� �����';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.OBJ_NAME     
	IS '��� �������';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.PROP_NAME  
 	IS '��� ��������';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.PROP_VALUE  
  IS '�������� ��������';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.ORD         
  IS '����� �� �������';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.M_Date         
  IS '���� ��������� ��� ���������.';
COMMENT ON COLUMN WFORMS.FORM_PARAMS.PROP_CLOB  
  IS '�������� ��������, �������� ����� ����� 4000 ����';

-- end of file


-- SP GROUPS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013  
-- update 04.06.2013 10.06.2013 25.08.2013 01.10.2013 10.10.2013 22.05.2014
--        04.06.2014 13.06.2014 24.08.2014-26.08.2014 30.08.2014 08.09.2014
--        08.07.2015 22.11.2016 19.01.2018 18.01.2021
--*****************************************************************************

-- ������� ��������������� (�������) � �������� (Alias).
CREATE TABLE SP.GROUPS
(
  ID NUMBER,
  IM_ID NUMBER,
  NAME VARCHAR2(128) NOT NULL,
  COMMENTS VARCHAR2(4000) NOT NULL,
  ALIAS NUMBER,
  EDIT_ROLE NUMBER DEFAULT NULL,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  
  CONSTRAINT PK_GROUPS PRIMARY KEY (ID),
	
  CONSTRAINT REF_GROUPS_TO_ROLES 
  FOREIGN KEY (EDIT_ROLE)
  REFERENCES SP.SP_ROLES ON DELETE CASCADE
);

CREATE UNIQUE INDEX SP.GROUPS_NAME ON SP.GROUPS (UPPER(NAME)); 
CREATE INDEX SP.GROUPS_EDIT_ROLE ON SP.GROUPS (EDIT_ROLE); 

COMMENT ON TABLE SP.GROUPS 
  IS '������� ��������������� (�������). (SP-GROUPS.SQL)' ;

COMMENT ON COLUMN SP.GROUPS.ID        IS '������������� ������.';
COMMENT ON COLUMN SP.GROUPS.IM_ID        IS '������������� �����������.';
COMMENT ON COLUMN SP.GROUPS.NAME      IS '��� ������.';
COMMENT ON COLUMN SP.GROUPS.COMMENTS  IS '�������� ������.';
COMMENT ON COLUMN SP.GROUPS.ALIAS  IS '������� ����, ��� ������ ������ �������� ��������� ������� ������. �������� ���� - ������ �� ������ ������. ���� ������ �������� ���������, �� ��� �� ����� ����� �����.';
COMMENT ON COLUMN SP.GROUPS.EDIT_ROLE 
  IS '���� �������������� ������. �������������� ��� ��������� �������� ��� ���������� �������. ���� null, �� ������������� ����� ������ �������������.';
COMMENT ON COLUMN SP.GROUPS.M_DATE 
  IS '���� �������� ��� ��������� ������.';
COMMENT ON COLUMN SP.GROUPS.M_USER 
  IS '������������ ��������� ��� ���������� ������.';

declare
tmp SP.COMMANDS.COMMENTS%type;
begin
tmp:='������ ��� ����������';
insert into SP.GROUPS VALUES (0,null,'DOCs',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ����� ���������� �� ���������.';
insert into SP.GROUPS VALUES (1,null,'Object_Pars',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ �������� �� ���������.';
insert into SP.GROUPS VALUES (2,null,'Objects',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ����� ����� �� ���������.';
insert into SP.GROUPS VALUES (3,null,'Types',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ����� ���������� ���������� �� ���������.';
insert into SP.GROUPS VALUES (4,null,'Globals',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ����� ����� �������� �� ���������.';
insert into SP.GROUPS VALUES (5,null,'CatalogItems',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ��������� ��������.';
insert into SP.GROUPS VALUES (6,null,'SysObjects',tmp,null,null,
                              to_date('05-01-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ����������� ��������.';
insert into SP.GROUPS VALUES (7,null,'Enums',tmp,null,null,
                              to_date('30-08-2014','dd-mm-yyyy'), 'SP');
tmp:='������ ALIAS �� ���������.';
insert into SP.GROUPS VALUES (8,null,'ALIASes',tmp,null,null,
                              to_date('30-08-2014','dd-mm-yyyy'), 'SP');
tmp:='������ �������������������� ����� ��� ����������. ��� ������� ������������� �� ���������.';
insert into SP.GROUPS VALUES (9,null,'OTHER',tmp,null,null,
                              to_date('30-08-2014','dd-mm-yyyy'), 'SP');
tmp:='������ �������� �� ���������.';
insert into SP.GROUPS VALUES (10,null,'Arrays',tmp,null,null,
                              to_date('19-01-2018','dd-mm-yyyy'), 'SP');                              
tmp:='������ ������������� ����������. ������������� ��� ���������� ������, �� ������� ��������� � �������� �������.';
insert into SP.GROUPS VALUES (11,null,'NoCatalogue',tmp,null,null,
                              to_date('18-01-2021','dd-mm-yyyy'), 'SP');
tmp:='������ ��������� ����������������. ������������� ��� ���������� ������, �� ������������ � ������� ����������.';
insert into SP.GROUPS VALUES (12,null,'System',tmp,null,null,
                              to_date('18-01-2021','dd-mm-yyyy'), 'SP');
end;
/

CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_GROUPS
(
  NEW_ID NUMBER,
  NEW_IM_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_COMMENTS VARCHAR2(4000),
  NEW_ALIAS NUMBER,
  NEW_EDIT_ROLE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_IM_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_ALIAS NUMBER,
  OLD_EDIT_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_GROUPS
  IS '��������� �������, ���������� �������� ��������� �������. (SP-GROUPS.sql)';

CREATE GLOBAL TEMPORARY TABLE SP.DELETED_GROUPS
(
  OLD_ID NUMBER,
  OLD_IM_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_ALIAS NUMBER,
  OLD_EDIT_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_GROUPS
  IS '��������� �������, ���������� �������� �������� �������. (SP-GROUPS.sql)';

-- ������� ������ ����� (�������).
CREATE TABLE SP.REL_S
(
  ID NUMBER,
  GR NUMBER NOT NULL,
  INC NUMBER NOT NULL,
  PREV_ID NUMBER,
  R_TYPE NUMBER DEFAULT 0 NOT NULL,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  
  CONSTRAINT PK_REL_S PRIMARY KEY (ID),
  CONSTRAINT CHK_REL_S CHECK (ID!=PREV_ID),
  
  CONSTRAINT REF_REL_INTERNAL
  FOREIGN KEY (PREV_ID) 
  REFERENCES SP.REL_S (ID) ON DELETE SET NULL,

  CONSTRAINT REF_REL_S_to_GROUPS
  FOREIGN KEY (GR)
  REFERENCES SP.GROUPS ON DELETE CASCADE,
	
  CONSTRAINT REF_REL_S_to_INC_GROUPS
  FOREIGN KEY (INC)
  REFERENCES SP.GROUPS ON DELETE CASCADE
);

/* ������ ����� ���� ���� ��� �������� ������ ������*/
CREATE UNIQUE INDEX SP.REL_S_U_REL ON SP.REL_S (GR,INC,R_TYPE);   
CREATE UNIQUE INDEX SP.REL_S_ORDER ON SP.REL_S(GR, PREV_ID);

CREATE INDEX SP.REL_S_GR ON SP.REL_S(GR);
CREATE INDEX SP.REL_S_INC ON SP.REL_S(INC);
CREATE INDEX SP.REL_S_PREV_ID ON SP.REL_S(PREV_ID);

CREATE INDEX SP.REL_S_U_REL_TYPE ON SP.REL_S (R_TYPE);   

COMMENT ON TABLE SP.REL_S IS '��������� �����. (SP-GROUPS.SQL)' ;

COMMENT ON COLUMN SP.REL_S.ID        IS '������������� �����.';
COMMENT ON COLUMN SP.REL_S.GR        IS '������ �� ������.';
COMMENT ON COLUMN SP.REL_S.INC       IS '������ �� ���������� ������.';
COMMENT ON COLUMN SP.REL_S.PREV_ID
  IS '������ �� ������������� ���������� ������ (��� ���������������� �����).';
COMMENT ON COLUMN SP.REL_S.R_TYPE    IS '��� �����.';
COMMENT ON COLUMN SP.REL_S.M_DATE 
  IS '���� �������� ��� ��������� �����.';
COMMENT ON COLUMN SP.REL_S.M_USER 
  IS '������������ ��������� ��� ���������� �����.';

-- ������ �������������� ��������
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (0, 1, 9, null, to_date('30-08-2014','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (1, 3, 9, null, to_date('30-08-2014','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (2, 4, 9, null, to_date('30-08-2014','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (3, 5, 9, null, to_date('30-08-2014','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (4, 7, 9, null, to_date('30-08-2014','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (5, 1, 11, 0, to_date('18-01-2021','dd-mm-yyyy'), 'SP');
insert into SP.REL_S (ID, GR, INC, PREV_ID, M_DATE, M_USER) 
  values (6, 1, 12, 5, to_date('18-01-2021','dd-mm-yyyy'), 'SP');
commit;

--   
CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_REL_S
(
  NEW_ID NUMBER,
  NEW_GR NUMBER,
  NEW_INC NUMBER,
  NEW_PREV_ID NUMBER,
  NEW_R_TYPE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
--   
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_REL_S
(
  NEW_ID NUMBER,
  NEW_GR NUMBER,
  NEW_INC NUMBER,
  NEW_PREV_ID NUMBER,
  NEW_R_TYPE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_GR NUMBER,
  OLD_INC NUMBER,
  OLD_PREV_ID NUMBER,
  OLD_R_TYPE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_REL_S
  IS '��������� �������, ���������� �������� ��������� �������. (SP-GROUPS.sql)';
--   
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_REL_S
(
  OLD_ID NUMBER,
  OLD_GR NUMBER,
  OLD_INC NUMBER,
  OLD_PREV_ID NUMBER,
  OLD_R_TYPE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_REL_S
  IS '��������� �������, ���������� �������� �������� �������. (SP-GROUPS.sql)';
  
  
-- end of file   

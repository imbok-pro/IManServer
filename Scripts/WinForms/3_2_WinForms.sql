-- �������� ������ �������� ����� WFORMS
-- create 14.01.2021
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 
--
--*****************************************************************************
-- ������� .
declare
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from ALL_USERS where USERNAME='WFORMS';
	if tmpVar>0 then
	  execute immediate('DROP USER "WFORMS" Cascade');
  end if;  
end;
/
--
CREATE USER WFORMS IDENTIFIED BY "W"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;
/  
--	
CREATE SEQUENCE WFORMS.SIGSEQ
  START WITH 100
  INCREMENT BY 100
  MINVALUE 100
  NOCYCLE 
  NOORDER
  CACHE 10;
/
CREATE SEQUENCE WFORMS.SEQ
  START WITH 100
  INCREMENT BY 100
  MINVALUE 100
  NOCYCLE 
  NOORDER
  CACHE 10;
/
-- ����.
-- �������.
@"WForms.sql"
-- ���������.
@"WForms.trg"
-- �����
@"Params.pks"
@"Params.pkb"
--
GRANT EXECUTE on WFORMS.Params to public;
CREATE OR REPLACE public synonym WFORMPARAMS for WFORMS.Params;
-- ��������������� ������� � �������� � ������� ���������.
declare
  tmpVar VARCHAR2(38);
begin
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='WFORMS');
	O('WFORMS Invalid Obj before: '||tmpVar);	 
   sys.utl_recomp.recomp_serial('WFORMS');
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='WFORMS');
	O('after: '||tmpVar);	 
end;
/

-- ����� ������� �������� KOCEL.
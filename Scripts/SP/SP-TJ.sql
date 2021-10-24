-- ������� TJ (Total Jornal) 
-- by Azarov SP-TJ.sql 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 12.02.2018
-- update 08.06.2018 27.03.2019

--truncate TABLE "SP"."TJ_CABLES" 
--drop  TABLE "SP"."TJ_CABLES" 

  CREATE GLOBAL TEMPORARY TABLE "SP"."TJ_CABLES" 
   (
    "CID" NUMBER PRIMARY KEY, 
	"CNAME" VARCHAR2(4000 BYTE),     
    "DEVICE1ID" NUMBER, 
    "DEVICE2ID" NUMBER,   
    "DEVICE1"   VARCHAR2(256 BYTE), 
    "DEVICE2"   VARCHAR2(256 BYTE),    
    "PLACE1"    VARCHAR2(256 BYTE), 
    "PLACE2"    VARCHAR2(256 BYTE), 
    "SYSTEMID"  NUMBER, 
    "SYSTEM"    VARCHAR2(4000 BYTE), 
    "�"        INTEGER    
    --"WORKID" NUMBER, 
	--"WORKNAME" VARCHAR2(4000 BYTE)    
    )
  ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE "SP"."TJ_CABLES" IS '������� ������ �� ������� TJ - ��� ��� ��������.';

COMMENT ON COLUMN SP.TJ_CABLES.CID is '���������� ������������� ������ � ���� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.CNAME is '��� ������ � ���� ������.';

COMMENT ON COLUMN SP.TJ_CABLES.DEVICE1ID is '���������� ������������� ������ ���������� (� ���� ������), �� �������� (��� �� ���� ��������) ���� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE2ID is '���������� ������������� ������� ���������� (� ���� ������), � �������� (��� � ���� ��������) ���� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE1 is '��� ������ ���������� (� ���� ������), �� �������� (��� �� ���� ��������) ���� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE2 is '��� ������� ���������� (� ���� ������), � �������� (��� � ���� ��������) ���� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.PLACE1 is '��� ����� ������ ����������.';
COMMENT ON COLUMN SP.TJ_CABLES.PLACE2 is '��� ����� ������� ����������.';

COMMENT ON COLUMN SP.TJ_CABLES.SYSTEMID is '���������� ������������� �������, � ������� ��������� ������.';
COMMENT ON COLUMN SP.TJ_CABLES.SYSTEM is '��� �������, � ������� ��������� ������.';

COMMENT ON COLUMN SP.TJ_CABLES."�" is '���������� ����� ������, ���������� ��� �������� �� ���������� ������� (�� ������������ ����� Excel). ����� �������������� ��� ����������';

--COMMENT ON COLUMN SP.TJ_CABLES.WORKID is '���������� ������������� ������ � ���� ������. ������ - ���� �������� ������ TJ.';
--COMMENT ON COLUMN SP.TJ_CABLES.WORKNAME is '��� ������ � ���� ������.';

GRANT SELECT ON SP.TJ_CABLES to public;

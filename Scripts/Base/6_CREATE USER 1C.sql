-- ������ �������� ����� "1C" ����������� � �������� "1C:�����������"
-- by Serhey Azarov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.02.16
-- update 08.11.16 27.07.2017 04.12.2018
--*****************************************************************************
--
-- ��������� �� sys sysdba
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='1C');
  if tmpVar!=0 then 
    execute immediate('
      DROP USER "1C" CASCADE
    ');
  end if;
end;
/

CREATE USER "1C" IDENTIFIED BY p
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;
/
GRANT CONNECT TO "1C";
/

CREATE TABLE "1C".CONTRACTS 
   (	
      ObjectId VARCHAR2(50), 
      ObjectName NVARCHAR2(255), 
      ObjectDescription NVARCHAR2(255), 
      
      ProjectId VARCHAR2(50), 
      ProjectName NVARCHAR2(255), 
      ProjectDescription NVARCHAR2(255), 

      "Id" VARCHAR2(50), 
      ParentID VARCHAR2(50),
      "Type" NVARCHAR2(10),

      "Name" NVARCHAR2(400), 
      "Number" NVARCHAR2(100), 
      InsideNumber NVARCHAR2(25), 
      "Date" DATE,

      ContractorSide NVARCHAR2(10), 
      ContractorName NVARCHAR2(255), 
      Description NVARCHAR2(255)
   );
 
COMMENT ON TABLE "1C".CONTRACTS 
  IS '������� ���������, ���������������� �� 1C, - ��� ������� � TDMS. ���� 6_CREATE USER 1C.sql';

COMMENT ON COLUMN "1C".CONTRACTS.ObjectId  IS '������������� ������� ��������������, � �������� ��������� �������.';   
COMMENT ON COLUMN "1C".CONTRACTS.ObjectName  IS '����������� ������� ��������������, � �������� ��������� �������.';   
COMMENT ON COLUMN "1C".CONTRACTS.ObjectDescription  IS '���������� � ������� �������������� (� ����� ������� ��������).';   

COMMENT ON COLUMN "1C".CONTRACTS.ProjectId  IS '������������� �������, � �������� ��������� �������.';   
COMMENT ON COLUMN "1C".CONTRACTS.ProjectName  IS '����������� �������, � �������� ��������� �������.';   
COMMENT ON COLUMN "1C".CONTRACTS.ProjectDescription  IS '���������� � ������� (� ����� ������� ��������.)';   

COMMENT ON COLUMN "1C".CONTRACTS."Id"  IS '������������� �������� (GUID � 1�).';  
COMMENT ON COLUMN "1C".CONTRACTS.ParentID  IS 'GUID ���������(�������������) ��������.';  
COMMENT ON COLUMN "1C".CONTRACTS."Type"  IS '��� �������� (�������, ���.���������� ��� ��������).';  

COMMENT ON COLUMN "1C".CONTRACTS."Name"  IS '������� (������� ��������).';  
COMMENT ON COLUMN "1C".CONTRACTS."Number"  IS '����� ��������.';  
COMMENT ON COLUMN "1C".CONTRACTS.InsideNumber  IS '���������� ����� ��������';   
COMMENT ON COLUMN "1C".CONTRACTS."Date"  IS '���� ��������.';  

COMMENT ON COLUMN "1C".CONTRACTS.ContractorSide  IS '������� ����������� �������� (�������� ���  ���������).';   
COMMENT ON COLUMN "1C".CONTRACTS.ContractorName  IS '������������ (���) �����������.';   
COMMENT ON COLUMN "1C".CONTRACTS.Description  IS '��������� �������� ��������.';   

GRANT SELECT,UPDATE,DELETE,INSERT on "1C".CONTRACTS to "1C";

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='SP');
  if tmpVar!=0 then 
    execute immediate('
      GRANT SELECT,UPDATE,DELETE,INSERT on "1C".CONTRACTS to SP
    ');
  end if;
end;

CREATE TABLE "1C".DepartmentSalary
   (	
      Id NUMBER, 
      Department NVARCHAR2(255), 
      Salary NUMBER
   );
 
COMMENT ON TABLE "1C".DepartmentSalary 
  IS '������� ���� ������� ����������� �������. ���� 6_CREATE USER 1C.sql';

COMMENT ON COLUMN "1C".DepartmentSalary.Department IS '����������� ������.';   
COMMENT ON COLUMN "1C".DepartmentSalary.Salary  IS '����� ������� ����������� ������.';   

/

--GRANT "SP_ADMIN_ROLE" TO "PROG";
--GRANT SELECT,UPDATE,DELETE,INSERT on "1C".CONTRACTS to "SP_ADMIN_ROLE";

-- end of script




CREATE OR REPLACE PACKAGE SP.E3C
-- ������ � ��������� Zuken e3.Series
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-19
-- update 2018-03-21 2019-02-01 2021-02-12:2021-02-17

AS

Type T_MODEL_OBJECT_PAR_S Is Table Of SP.MODEL_OBJECT_PAR_S%ROWTYPE;
--==============================================================================
E3C_LINK VARCHAR2(128);
E3C_SCHEMA VARCHAR2(128);
--==============================================================================
--�� ������ ������� 40-���������� ������, ��������� �������� ������������� SHA1
--
--���� ������� �� 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION SHA1(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2; 
--==============================================================================
--�� ������ ������� 32-���������� ������, ��������� �������� ������������� MD5
--
--���� ������� �� 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION MD5(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2; 
--==============================================================================
--���������� ��� Link'� � �� Zuken e3.series
Function GetE3C_LINK Return Varchar2;
--==============================================================================
--C������ ������ OID �� ������, ��������� �������� ������������� SHA1
FUNCTION Str2OID(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2;
--==============================================================================
--���������� ����� ���� ������� �������� Zuken e3.series 
Function GetCatalogClasses Return  SP.G.TOBJECTS;
--==============================================================================
--���������� ������ �������� �� ��� OID
Function GetCatalogObject(OID$ In Varchar2) Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ��� ������� ��������, ������������� ������� ������
Function GetCatalogObjects(ClassName$ In Varchar2) Return SP.G.TOBJECTS;
--==============================================================================
-- ����������, ���������� �� ��������� LPNTR$ � ���� cable.Entry  
Function IsCable(LPNTR$ In Varchar2) Return Boolean;
--==============================================================================
-- ����������, ���������� �� LPNTR, ��������������� COMPONENT_OID$  
--� ���� cable.Entry  
Function IsCable(COMPONENT_OID$ In Varchar2) Return Boolean;
--==============================================================================
--���������� ���������� � �������� � ������
--������� ��������� NAME, OID � POID. 
Function GetWiresAndBundles(COMPONENT_OID$ In Varchar2) Return SP.G.TOBJECTS;
--==============================================================================
--�������� � ������
Function Par2StrDEBUG(ParID$ In Number) Return Varchar2;
--==============================================================================
--��� ���� �������� ������� ROOT_MOD_OBJ_ID
--���� ��� ���������, ��������� ��������� ������� ���� ����� ���� ModDate$
FUNCTION GetModifiedPars(
ROOT_MOD_OBJ_ID$ In Number  --������ ��������� ��������
, ModDate$ In DATE  --����, ����� ������� ��������� ���� ��������
) 
return SP.E3C.T_MODEL_OBJECT_PAR_S pipelined;
--==============================================================================
--���������� ������ (����� ������ ��. ����).
--��� ���� �������� ������� ROOT_MOD_OBJ_ID
--���� ��� ���������, ��������� ��������� ������� ���� ����� ���� ModDate$
--
--������ ������� ������������� ��� �������� ��������� (������) �� ������ TJ
--� ������ Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --������ ��������� ��������
, ModDate$ In DATE  --����, ����� ������� ��������� ���� ��������
) 
return SP.G.TOBJECTS;

/*
--Implementation pattern
Declare
  ObjSet#  SP.G.TOBJECTS;
Begin
ObjSet# := SP.E3C.GetModifiedObjectPars(

ROOT_MOD_OBJ_ID$ => 11539400 
, ModDate$ => TO_DATE('2019-01-28 00:00:00','YYYY-MM-DD HH24:MI:SS')
--))
); 

DBMS_OUTPUT.Put_Line('Count = '||ObjSet#.Count);
End;
*/
--==============================================================================
-- ���� ��� ���������, ����� ����������, Rel � SymRel, 
-- ��������� ��������� ������� ���� ����� ���� ModDate$
Function GetObjParamVals(ModObjID$ In Number, ModDate$ In DATE) 
Return SP.MO.TPars Pipelined;
--==============================================================================
--��� ���� �������� ������� ROOT_MOD_OBJ_ID
--���� ��� ���������, ��������� ��������� ������� ���� ����� ���� ModDate$
--
--������ ������� ������������� ��� �������� ��������� (������) �� ������ TJ
--� ������ Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --������ ��������� ��������
, ModDate$ In DATE  --����, ����� ������� ��������� ���� ��������
, ObjectID$ In Number -- ID ������� ��������, ��� �������� ������������� ���������
) 
return SP.G.TOBJECTS;
/*
--Implementation pattern

Declare
  ObjSet#  SP.G.TOBJECTS;
Begin
ObjSet# := SP.E3C.GetModifiedObjectPars(

ROOT_MOD_OBJ_ID$ => 2696588000 
, ModDate$ => TO_DATE('2019-01-28 00:00:00','YYYY-MM-DD HH24:MI:SS')
, ObjectID$ => SP.TJ_WORK.GetObjectID(SP.TJ_WORK.SINAME_DEVICE)
); 

DBMS_OUTPUT.Put_Line('Count = '||ObjSet#.Count);
End;

*/
--==============================================================================
--������ ������ ���� �������� � ����� From$ �� ����� To$
--��� ����� ������, ����� �� �������� ����� ������ �����
-- � ������ ������� ������ ������, � ������ ��� ������� �������� 
-- ���������� �� ����� ������.
Procedure UpdateStartComositRef(From$ In Varchar2, To$ In Varchar2);
/*
--Implementation pattern
Begin
    SP.E3C.UpdateStartComositRef
    ('E3=>TJ (��������� ������)_OBSOLETE', 'E3=>TJ (��������� ������)');
    commit;
End;
*/
--==============================================================================
-- ��� ������ WorkID$ ���������� ���� ��������� ������������� �� TJ � ������ 
-- Zuken e3.series.
-- ���� WorkID$ �� ���� ID ������, �� ����������.
-- ���� � ������ ��������� �������� "SYNC_DATE_FROM_TJ_TO_E3", �� ������
-- ��� �� ��������� 2000-01-01 � ���������� ��� ��������.
Function GetSyncDateFromTJ2E3(WorkID$ In Number) Return Date;
/*
--Implementation pattern

select SP.E3C.GetSynkDateFromTJ2E3(1234567890) as ddd From Dual;

select SP.E3C.GetSynkDateFromTJ2E3(2696588800) as ddd From Dual;

select SP.E3C.GetSynkDateFromTJ2E3(2696588000) as ddd From Dual;

*/
--==============================================================================

/*
--�����
begin

DBMS_OUTPUT.put_line(SP.E3C.E3C_LINK);

end;
*/
End E3C;
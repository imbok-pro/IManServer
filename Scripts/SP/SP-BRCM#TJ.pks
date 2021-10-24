create or replace PACKAGE SP.BRCM#TJ 
AS 
-- ��������� �������� ������ ��
-- 1. ������ Pln.BRCM.Server � ��������� ������ TJ  
-- 2. ��������� ����� BRCM � ��������� ������ TJ (��������) 
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-03-21
-- update 2019-07-15 2019-09-25 2019-11-11 2020-07-02:2020-07-03

--==============================================================================
Type AA_ParamName2Name Is Table Of SP.MODEL_OBJECT_PAR_S.NAME%TYPE
Index By SP.MODEL_OBJECT_PAR_S.NAME%TYPE;

Type AA_Numbers Is Table Of Number Index By BINARY_INTEGER;
--------------------------------------------------------------------------------
--��������������� ���
Type R_IndexedName Is Record
(
  NAME1 SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
  NUM NUMBER
);

Type T_IndexedNames Is Table Of R_IndexedName;
--==============================================================================
--ID ������
Work$ID SP.MODELS.ID%TYPE;


--------------------------------------------------------------------------------
--������� ������������������ �������� ������ ����������� ������.  
Type R_CABLE_WAY_SEGMENT Is Record
(
    --���������� ����� �������� � ������������������
    ORDINAL BINARY_INTEGER,
    --������ �� RL_RID �������� � ������ ��������� RLINE
    RL_RID_S AA_Numbers, 
    X1 SP.BRCM_RLINE.X1%TYPE, 
    Y1 SP.BRCM_RLINE.Y1%TYPE, 
    Z1 SP.BRCM_RLINE.Z1%TYPE,  
    X2 SP.BRCM_RLINE.X2%TYPE,
    Y2 SP.BRCM_RLINE.Y2%TYPE,
    Z2 SP.BRCM_RLINE.Z2%TYPE,
    LENGTH Number,  --����� ��������
    HP_RWID SP.MODEL_OBJECT_PAR_S.S%TYPE,
    COURSE_NAME SP.BRCM_RLINE.COURSE_NAME%TYPE,
    --����� ����� (������ ����) � �����
    SHELF_NUM SP.BRCM_RLINE.SHELF_NUM%TYPE,
    ORIENTATION Number(1,0), --{-1; 0; +1}
    IS_PART Number(1,0), -- {0; 1} 0-�����, 1- ����� �� RLINE_ELEMENT (��������, ��� �� �����. ���� �����, ����� �� ����� ������������ ������ � BRCM)
    OID SP.BRCM#DUMP.T$GUID_STR
);

--���� ������������������ �����, ����� ������� ����� ������. 
Type AA_CABLE_WAY_SEGMENT_CHAIN Is Table Of R_CABLE_WAY_SEGMENT 
Index By BINARY_INTEGER; 

--==============================================================================
-- ���������� ��� ��������� ������������ ������ TJ, ��������������� ����� 
-- ��������� ������������, ������������� �� ������ Pln.BRCM.Server ��� null
Function TJ_EQP_ParamNull(BRCM_ParamName$ Varchar2) Return varchar2;
--..............................................................................
-- ���������� ��� ��������� ������������ ������ TJ, ��������������� ����� 
-- ��������� ������������, ������������� �� ������ Pln.BRCM.Server.
Function TJ_EQP_Param(BRCM_ParamName$ Varchar2) Return varchar2;

/*

*/
--==============================================================================
--��������� ��������������� ����� � ������������ � ��������
Function PipelineNames( tab$ In T_IndexedNames) 
Return T_IndexedNames Pipelined;
/*

*/
--==============================================================================
--�������� ��� ���������� � ������� ������
Procedure ClearPackage;
--==============================================================================
--������� ���������� �� �������� �� BRCM DUMP � TJ
Procedure DevicesEXP;
--==============================================================================
--�������� ������ ���������� ������� �� BRCM||DUMP � ��������� ������ ������ TJ.
--����� �������� ������ ��������� ��������� ���������� ���������� ��������
--SP.TG.Cur_MODEL_ID:=600;  --TJ||Hydroproject
Procedure BRCM_DUMP_2_TJ(WorkID$ In Number);
/*  
--Implementation pattern


Begin
  SP.BRCM#TJ.ClearPackage;
  SP.BRCM#DUMP.SetDumpModelName(DumpModelName$ => 'BRCM||DUMP EBCEEB 2019-10-15');
  
  
  SP.BRCM#DUMP.BRCM_CFC_PREPARE;
 
 --MODEL_ID:=5800;  TJ||���������������� ���� (�� � �)
  SP.BRCM#TJ.BRCM_DUMP_2_TJ(WorkID$ => 3498170100);                                                  
  
  commit;
End;

*/
--==============================================================================

END BRCM#TJ;
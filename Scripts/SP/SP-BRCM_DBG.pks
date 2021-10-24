create or replace PACKAGE SP.BRCM_DBG
-- ���������� ��������� ��� ������ � �������� ��������� BRCM
-- File: SP-BRCM_DBG.pks
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-26
-- update 2019-09-27
As

Type R_CABLE_WAY_RLINE Is Record
(
    --���������� ����� �������� � ������������������
    ORDINAL SP.BRCM_CFC.ORDINAL%TYPE,
    RL_RID SP.BRCM_RLINE.RL_RID%TYPE,
    RL_EID SP.BRCM_RLINE.RL_EID%TYPE, 
    RL_DESIGN_FILE SP.BRCM_RLINE.RL_DESIGN_FILE%TYPE, 
    "X1" SP.BRCM_RLINE.X1%TYPE, 
    "Y1" SP.BRCM_RLINE.Y1%TYPE, 
    "Z1" SP.BRCM_RLINE.Y1%TYPE,  
    "X2" SP.BRCM_RLINE.X2%TYPE,
    "Y2" SP.BRCM_RLINE.X2%TYPE,
    "Z2" SP.BRCM_RLINE.X2%TYPE,
    LENGTH SP.BRCM_RLINE.LENGTH%TYPE,  --����� ��������
    HP_RWID SP.BRCM_RLINE.HP_RWID%TYPE,
    COURSE_NAME SP.BRCM_RLINE.COURSE_NAME%TYPE
);

Type T_CABLE_WAY_RLINE Is Table Of R_CABLE_WAY_RLINE; 
--==============================================================================
--�� ����� ������ ���������� ������������� �� ORDINAL ������������������ RLIne, 
--�������� � ������
--���� ��� ������ ������� �������, �� �� ���������� ������
Function V_CABLE_RLINES(CableNo$ In Varchar2) 
Return  T_CABLE_WAY_RLINE Pipelined;
/*
Implementation pattern

Begin
  SP.BRCM#TJ.ClearPackage;
  SP.BRCM#DUMP.SetDumpModelName(DumpModelName$ => 'BRCM||DUMP EBCEEB 2019-10-15');
  
  SP.BRCM#DUMP.BRCM_CFC_PREPARE;
  SP.BRCM#TJ.BRCM_DUMP_2_TJ(WorkID$ => 2705480400);                                                  
End;

--------------------------------------------------------------------------------
Select * 
From TABLE(SP.BRCM_DBG.V_CABLE_RLINES(CableNo$ => '=00BUA2000BUA20-1003'))
;

--------------------------------------------------------------------------------
-- ������� �������, ��� ������� ������� RLINEs � COURSE_NAME
-- �������� �� Null � 'Air Gap'
Select ca.* 
From SP.BRCM_CABLE ca
WHERE Exists(
              SELECT * FROM SP.BRCM_CFC cf
              Where cf.CBL_RID=ca.CBL_RID
              And Exists(Select * From SP.BRCM_RLINE rl
                          Where rl.RL_RID=cf.RL_RID
                          And  Not rl.COURSE_NAME Is Null
                          And Not rl.COURSE_NAME In ('Air Gap')
                          )
            )
Order By ca."HP_CableNo"            
;

*/
--==============================================================================
--���������� 1, ���� RLINE ������ � ������ �������� (������������).
--� ��������� ������ ���������� 0.
Function IsTee(RL_RID$ In Number) Return Number;
/*
Implementation pattern

Begin
--TEST_001 

SP.BRCM#DUMP.SetDumpModelName(DumpModelName$ => 'BRCM||DUMP EBCEEB 2019-09-06');
  SP.BRCM#DUMP.BRCM_AREP_PREPARE;
  SP.BRCM#DUMP.BRCM_CFC_PREPARE;

End;

Select SP.BRCM_DBG.IsTee(RL_RID$ => 3108576100) as val From Dual
;
*/
--==============================================================================


End BRCM_DBG;
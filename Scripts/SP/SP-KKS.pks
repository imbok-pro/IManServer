CREATE OR REPLACE PACKAGE SP.KKS
-- ������ � ������ KKS
-- ��. �������� 
-- TJ.21.KKS-������������� �������.������� ���������.pdf
-- � ����� ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\TJ\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-04
-- update 2019-09-12 2020-12-04 2021-06-22:2021-06-26

AS

--������ ������� KKS ���� ������ � ������������ ������������ ����������
--�������� KKS.
Type AA_KKSAllowedSymbols Is Table Of Varchar2(64) Index By BINARY_INTEGER;

--K��������� ��������, ���������� ��� ���� �������� (������ �������) 
-- � ������� KKS 
kks_Agregate_Len CONSTANT BINARY_INTEGER:=2;
--K��������� ��������, ���������� ��� ���� ������� � ������� KKS 
kks_System_Len  CONSTANT BINARY_INTEGER:=3;
--K��������� ��������, ���������� ��� ������ ���������� � ������� KKS 
kks_SubSystem_Len CONSTANT BINARY_INTEGER:=2;


--K��������� ��������, ���������� ��� ���� ���������� � ���������� � ������� KKS 
kks_EqpClass_Len CONSTANT BINARY_INTEGER:=2;
-- K��������� ��������, ���������� ��� ������ ���������� � ���������� 
-- � ������� KKS 
kks_EqpNumber_Len CONSTANT BINARY_INTEGER:=3;
-- K��������� ��������, ���������� ��� ��������������� ���� ���������� � 
-- ���������� � ������� KKS 
kks_EqpAdd_Len CONSTANT BINARY_INTEGER:=1;


No_KKS CONSTANT Varchar2(20):='BHE KKS';

--���������� ����� � KKS: ����� ���������� �������� �� ����������� O � I
kks_ABC CONSTANT Varchar2(32):='ABCDEFGHJKLMNPQRSTUVWXYZ';

--==============================================================================
--���������� ������,� ������� ����������� KKS-������� ��������� � {}
Function DetectDeprecatedSymbols(str$ In Out NoCopy Varchar2) Return Varchar2;

--==============================================================================
--���������� ��� �������� �� ��������� 
Function Get_kks_defa_agregate Return Varchar2;
/*
--Implementation pattern

select SP.KKS.Get_kks_defa_agregate as ttt from dual
;

*/
--==============================================================================
--���������� ��� ���������� �� ��������� ('00') 
Function Get_kks_defa_subsystem Return Varchar2;
--==============================================================================
--���������� �������� ������� ��� �������������������� ��������� � �������
-- '00BHE KKS00' 
Function Get_No_KKS_Idx Return Varchar2;
--==============================================================================
-- ��� ������� ������ kks$ ���������� �������������� ��� �������� � 
-- ������� kks_rest$ ������� ������, �� ������� ���� �������� �� ��������� 
-- ��������:
-- 0. ������� ��������� ����� '=', ���� ��� ����
-- 1. ���� ������ kks_Agregate_Len = 2 �������� ������ kks$ ���� ����� 
--    '00BJC30', �� �������� �� � ���������� ��������� '00' � 
--    ������� kks_rest$='BJC30'.
-- 2. ���� � ������ ������ ���� ������, ��� kks_Agregate_Len ��������, �� 
--    ����������� � ��� ����� ������ ���������� �����.
--    �. '3BJC30' => ��������� '03', kks_rest$='BJC30'
--    b. 'BJC30' => ��������� '00', kks_rest$='BJC30'
Function Get_AgregatePart
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2;

/*
--Implementation pattern

declare
  kks_rest# varchar2(400);
  part1# varchar2(20);
  str_in# varchar2(400);
begin
  str_in# := '==23BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==3BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

end;

*/
--==============================================================================
-- ��� ������� ������ kks$ ���������� ������������� ��� ������� � 
-- ������� kks_rest$ ������� ������, �� ������� ���� ������� �� ��������� 
-- ��������:
-- 1. ���� ������ kks_System_Len = 3 �������� ������ kks$ ���� ���������� ����� 
--    'BJC30', �� �������� �� � ���������� ��������� 'BJC' � 
--    ������� kks_rest$='30'.
-- 2 B ��������� ������ '7JC30' ���������� ��������� No_KKS='BHE KKS' � 
--    ������� kks_rest$='7JC30'.
Function Get_SystemPart
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2;

/*
--Implementation pattern

declare
  kks_rest# varchar2(400);
  part1# varchar2(20);
  str_in# varchar2(400);
begin
  str_in# := '==23BJC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := 'BJC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '7JC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := 'JC';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

end;

*/
--=============================================================================
--����������� ������� ������ �, ���� ��� ����������, �� ��������� �� ��� �����:
-- 1. kks_agregate$ - ��� ��������
-- 2. kks_system$ -��� �������
-- 3. kks_subsystem$ - ��� ����������
--    ���, ��� ��� ������������ ���� ������ 
--    (kks_agregate$||kks_system$||kks_subsystem$) 
--    ���������� ������ ���, 
-- � ���������� ������.
--
-- ���������� ������� ������ ������������ ��������� �������:
-- 1. ���������� � ���������� �������� '=' ��� �� �������� �������� '='
-- 2. ����� ���� ��� ����� ������ ������� (���� ���� ������ ����, �� 
--    ��� ����������� ������ �����)
-- 3. ����� ���� ��� ����� ���� �������
-- 4. ����� ���� ��� ����� ������ ���������� (���� ���� ������ ����, �� 
--    ��� ����������� ������ ������)
--
--���� ������� ������ ������, �� ���������� ���� � �������� ��������� ���������
-- ��������� �������:
-- kks_agregate$ <- '00'
-- kks_system$ <- SP.KKS.No_KKS
-- kks_subsystem$ <- kks$ 
--
--� ��������� ������� ���������� ���� � �������� ��������� ��������� ��������� 
-- kks_agregate$ <- '00'
-- kks_system$ <- SP.KKS.No_KKS
-- kks_subsystem$ <- kks$ 
Function SplitShortKKS(
kks$ In Varchar2, kks_agregate$ In Out varchar2
, kks_system$ In Out Varchar2, kks_subsystem$ In Out varchar2) Return Boolean;

/*
--Implementation pattern

declare
  kks# varchar2(400);
  kks_agregate# varchar2(400);
  kks_system# varchar2(400);
  kks_subsystem# varchar2(400);
  bo# Boolean;
begin
  kks# := '==23BJC30';
  
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC30';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BIC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '7JC30';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=JC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'JC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------
end;

*/
--==============================================================================
--����������� ������� ������ kks$ �, ���� ��� ����������, 
-- �� �������� �� �� ��� �����:
-- 1. sys_num$ - ����� �������
-- 2. sys_code$ -��� �������
-- 3. subsys_num$ - ����� ����������
--    ���, ��� ��� ������������ ���� ������ 
--    (sys_num$||sys_code$||subsys_num$) 
--    ���������� ������ ��� �������, 
-- � ���������� ������.
-- ���������� ������� ������ ������������ ��������� �������:
-- 1. ���������� � ���������� �������� '=' ��� �� �������� �������� '='
-- 2. ����� ���� ��� ����� ������ ������� (���� ���� ������ ����, �� 
--    ��� ����������� ������ �����)
-- 3. ����� ���� ��� ����� ���� �������
-- 4. ����� ���� ��� ����� ������ ����������
-- 5. ����� ����� ���� ��������-��������� ��� ����� (� ��� ����� �������) �����
--
--���� ������� ������ ������, �� ���������� ���� � �������� ��������� ���������
-- ��������� �������:
-- sys_num$ <- '00'
-- sys_code$ <- SP.KKS.No_KKS
-- subsys_num$ <- kks$ 
--
--� ��������� ������� ��� ������������� ������ ������� ���������� ���� � 
-- �������� ��������� ��������� ��������� 
-- sys_num$ <- '00'
-- sys_code$ <- SP.KKS.No_KKS
-- subsys_num$ <- kks$ 
Function SplitLongKKS(
kks$ In Varchar2, sys_num$ In Out varchar2
, sys_code$ In Out Varchar2, subsys_num$ In Out varchar2) Return Boolean;
/*
--Implementation pattern

declare
  kks# varchar2(400);
  kks_agregate# varchar2(400);
  kks_system# varchar2(400);
  kks_subsystem# varchar2(400);
  bo# Boolean;
begin
  kks# := '==23BJC30';
  
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC30';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BIC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '7JC30';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=JC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'JC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=30PUL10�L001';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------


end;

*/

--==============================================================================
--�� ���� KKS �������, �������� �������� �������.
Function GetKKSIndex(kks$ in varchar2) Return varchar2;
--==============================================================================
-- ������ ������������� ���� �� ��������� ������� ��������� �����
 Function Cyr2Lat(str$ varchar2) Return varchar2;
--==============================================================================
--���������� ���������� ������� ��� ������ ������� ���� KKS �������
-- ������������� (ex: 00SBB03BR005A) 
Function GetKKSAlowedSysmbols(iBase$ In BINARY_INTEGER) 
Return SP.KKS.AA_KKSAllowedSymbols;
--==============================================================================
End KKS;
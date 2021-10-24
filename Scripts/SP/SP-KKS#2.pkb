CREATE OR REPLACE PACKAGE BODY SP.KKS#2
AS
-- ������ � ������ KKS � ������������� ��������� ��������
-- ��. �������� 
-- PM01.TJ. ���� ������ ��������� ������� ������������������ �����.docx
-- � ����� ...\vm-polinom\Scripts\Data\Hydro\TJ\00.Docs\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-06-22
-- update 2021-06-23:2021-06-27

--  ID ���� "��������� �������"
KKS#ROOT#ID Number := null;

--  ���������� ������� � ������� ���� KOCEL (��. ������� GetKKS(...))
KKSAllowedSymbols#AA SP.KKS.AA_KKSAllowedSymbols;
--==============================================================================
--������������� KKS#ROOT#ID := Null 
Procedure ClearKKS_RootID
Is
Begin
  KKS#ROOT#ID:=Null;
End ClearKKS_RootID;
--==============================================================================
--���������� ID ������� � ������ '��������� �������' ������� ������
Function GetKKS_RootID Return Number
As
Begin
  If KKS#ROOT#ID Is Null Then
    SELECT ID Into KKS#ROOT#ID 
    From SP.MODEL_OBJECTS
    Where MODEL_ID=GET_MODEL_ID()
    And Upper(MOD_OBJ_NAME)='��������� �������'
    ;
  End If;
  Return KKS#ROOT#ID;
Exception When NO_DATA_FOUND Then
  raise_application_error(-20033
  , '� ������ ID ['||GET_MODEL_ID()
  ||'] �� ������ ������ � ������ "��������� �������".');    
  When TOO_MANY_ROWS Then
  raise_application_error(-20033
  , '� ������ ID ['||GET_MODEL_ID()
  ||'] ���������� ����� ������ ������� � ������ "��������� �������".');    
End GetKKS_RootID;
--==============================================================================
--���������� ����� � ID �������� ������� � ������� ������ �������������� 
-- ��������� ������� ������� ��������� ������.
--� ������ �� ���������, ������������ ������ ������������� �������.
--Tax1_AA$ ������������� ������ ������������� ��������
--Tax2_AA$ ������������� ������ ������������� ��������
Procedure GetTaxons12Level
(Tax1_AA$ in out NoCopy AA_Taxon2ID, Tax2_AA$ in out NoCopy AA_Taxon2ID)
As
Begin
  Tax1_AA$.Delete;
  Tax2_AA$.Delete;

  For r1 In
  (Select mo1.ID, mo1.MOD_OBJ_NAME 
    From SP.MODEL_OBJECTS mo1
    Where mo1.PARENT_MOD_OBJ_ID=SP.KKS#2.GetKKS_RootID()
  )Loop
    Tax1_AA$(r1.MOD_OBJ_NAME):=r1.ID;
  End Loop;
  
  For r2 In
  (Select mo2.ID, mo2.MOD_OBJ_NAME 
    From SP.MODEL_OBJECTS mo1, SP.MODEL_OBJECTS mo2
    Where mo1.PARENT_MOD_OBJ_ID=SP.KKS#2.GetKKS_RootID()
    And mo2.PARENT_MOD_OBJ_ID = mo1.ID
  )Loop
    Tax2_AA$(r2.MOD_OBJ_NAME):=r2.ID;
  End Loop;
  
End GetTaxons12Level;
--==============================================================================
--���������� ����� � ID ������ � ��������� �������������� 
-- ��������� ������� ������� ��������� ������.
--� ������ �� ���������, ����������� ������ ������������� ������.
--SubSys_AA$ ������������� ������ ������ � ���������
Procedure GetSubSystems
(SubSys_AA$ in out NoCopy SP.TJ_WORK.AA_ObjName2ID)
As
Begin
  SubSys_AA$.Delete;

  For r1 In
  (Select mo3.ID, mo3.MOD_OBJ_NAME 
    From SP.MODEL_OBJECTS mo1, SP.MODEL_OBJECTS mo2, SP.MODEL_OBJECTS mo3
    Where mo1.PARENT_MOD_OBJ_ID=SP.KKS#2.GetKKS_RootID()
    And mo2.PARENT_MOD_OBJ_ID = mo1.ID
    And mo3.PARENT_MOD_OBJ_ID = mo2.ID
  )Loop
    SubSys_AA$(r1.MOD_OBJ_NAME):=r1.ID;
    
    For r2 In
    (Select mo4.ID, mo4.MOD_OBJ_NAME 
      From SP.MODEL_OBJECTS mo4
      Where mo4.PARENT_MOD_OBJ_ID=r1.ID
    )Loop
      SubSys_AA$(r2.MOD_OBJ_NAME):=r2.ID;
    End Loop;
    
  End Loop;

End GetSubSystems;
--==============================================================================
--  �������� KKS-��� �� ��������� ����� ���� KOCEL
--
--  ����� ��������� - ��� IColMax$-IColMin$+1, 
--  �.�. ���������� �������� � ���� KKS
--  � ��������� ����� ������� ������������ ������ ��������� ������ 7, � 12
--  ��� ��������� ���������� ������ 7 ������� ���������� � ���������� KKSFull$
--  ������ ���� ������ � ���������� ������ 7 (ex: 00SAS03).
--  ��� ��������� ��������� ������ 12 ������� ����������  � ���������� KKSFull$ 
--  ���� ������ � ��������� ������ 7 (ex: 00SBB03), 
--  ���� ���� ��������� ������ 12 (ex: 00SBB03BR005).
--  ��� ������ ������ ��������� ������� ���������� ����������.
Function GetKKS(
kRow$ In KOCEL.CELL.TRow      --��: ������������� ��� ����� ����� KOCEL
, IColMin$ In BINARY_INTEGER  --��: ������ ��������� ������� ������� KKS
, IColMax$ In BINARY_INTEGER  --��: ����� ��������� ������� ������� KKS
, BuffLog$ In Out NOCopy DEBUG_LOG.TBUFF_LOG  -- ����� ������ ������ ��.������
, SysNum$ In Out varchar2     --���: ����� ������� (2)
, SysCode$ In Out Varchar2    --���: ��� ������� (3)
, SubSysNum$ In Out varchar2  --���: ����� ���������� (2)
, UnitCode$ In Out Varchar2   --���: ��� ���������� � ������� ������� (5)
, KKSFull$  In Out Varchar2   --���: ������ ��� KKS (7 ��� 12)
) Return Boolean
Is
  EmptyColCount# BINARY_INTEGER;
  EmtyColMax# BINARY_INTEGER;
  Mes# Varchar2(4000);
  ts# Varchar2(4000);
  kks_system_part_len# BINARY_INTEGER; -- ����� ��������� ����� ���� KKS
  iRow## BINARY_INTEGER; --���������� ����������, ������ ����� �������
  
  
  --����������� �������� KOCEL.CELL.TCellValue � ������ �� ������ �������, ���
  -- ���� ��������� ��������� � ���������� ts#.
  -- ���� ��������� �� ���� ����� ��� ������, �� ���������� false.
  -- ���� ���������� ������ �������� ������ �������, �� ���������� false 
  Function TOChar1( kv# KOCEL.CELL.TCellValue) Return Boolean
  As
  Begin
    If KOCEL.CELL.isString(kv#) Then
      ts#:=kv#.S;
    ElsIf KOCEL.CELL.isNumber(kv#) Then
      ts#:=to_char(kv#.N);
    Else
      Return False;
    End If;
    
    If LENGTH(ts#)<> 1 Then
      Return False;
    End If;
    Return True;
  End;
  
  --  ���������� ������ � ��������� ts# ���������, ���� ������ � ������� iC 
  --  ����������, ������� � �������� ����� ��� ������
  Function NotEmptyCell(iC$ In BINARY_INTEGER) Return Boolean
  Is
  Begin
    If kRow$.Exists(iC$) then
      If TOChar1(kRow$(iC$)) Then
        If Not ts# Is Null Then
          Return true;
        End If;
      Else
        Mes#:='��� '||kRow$(kRow$.First).R||' ������� '||iC$
        ||' �������� ������������ ������ ['||ts#||'] ���� KKS.';
        BuffLog$.AppendLine(Mes#);
        Return false;
      End If;
    End If;
    Return false;
  End;
Begin
  ------------------------------------------------------------------------------
  D('Start','DEBUG SP.KKS#2.GetKKS');
  If kRow$ Is Null Or kRow$.First Is Null Then
    Return false;
  End If;
  
  iRow##:=kRow$(kRow$.First).R;
  ------------------------------------------------------------------------------
  
  If KKSAllowedSymbols#AA.Count<2 Then
    KKSAllowedSymbols#AA := SP.KKS.GetKKSAlowedSysmbols(iBase$ => IColMin$);
  End If;
  D('After SP.KKS.GetKKSAlowedSysmbols','DEBUG SP.KKS#2.GetKKS');
  KKSFull$:='';
  EmptyColCount# := 0;
  EmtyColMax#:=SP.KKS.kks_Agregate_Len+SP.KKS.kks_System_Len;
  --D('IColMin$ = '||IColMin$||', IColMax$ = '||IColMax$,'DEBUG SP.KKS#2.GetKKS');
  for iCol In IColMin$..IColMax$ Loop
    If NotEmptyCell(iCol) then
      KKSFull$:=KKSFull$||ts#;
    Elsif iCol < EmtyColMax# + IColMin$ Then                    
      If iRow##=148 Then
         D('2. For iRow ='||iRow##||' Not Exists iCol = '||iCol,'DEBUG SP.KKS#2.GetKKS');
      End If;
      EmptyColCount#:=EmptyColCount#+1;
      If EmptyColCount#>= EmtyColMax# Then
        --  ���������� ������, ��������� ��������� ����� ���� KKS 
        --  (������ 5 ��������) ������
        Return false;
      End If;
    Elsif iCol = IColMin$+EmtyColMax#+SP.KKS.kks_SubSystem_Len Then
      If iRow##=148 Then
         D('3. For iRow ='||iRow##||' Not Exists iCol = '||iCol,'DEBUG SP.KKS#2.GetKKS');
      End If;
      --  ������� �� �����, ��������� ��������� ����� ���� (������ 7 ��������) 
      --  ������� � ������ ������ ���� ���������� �� ������ (������)
      Exit;
    Else
      If iRow##=148 Then
         D('4. For iRow ='||iRow##||' Not Exists iCol = '||iCol,'DEBUG SP.KKS#2.GetKKS');
      End If;
      -- ������ � ����� ���� ����������
      Mes#:='��� '||kRow$(kRow$.First).R||' �������� ������������ ��� KKS ['
      ||KKSFull$||'] � ����� ���� ����������.';
      BuffLog$.AppendLine(Mes#);
      Return false;
    End If;
  End Loop;
  
  If Not SP.KKS.SplitLongKKS(KKSFull$, SysNum$,SysCode$, SubSysNum$) Then
     Mes#:= '��� '||kRow$(kRow$.First).R||' �������� ������������ ��� KKS ['||  
     SP.KKS.DetectDeprecatedSymbols(KKSFull$)||'].';
    KKSFull$:=SP.KKS.Cyr2Lat(KKSFull$);
    If SP.KKS.SplitLongKKS(KKSFull$, SysNum$, SysCode$, SubSysNum$) Then
      BuffLog$.AppendLine(Mes#); 
    Else                                                
      Mes#:='��� '||kRow$(kRow$.First).R
      ||' �������� ������������ ��� KKS ['||KKSFull$||']';
      BuffLog$.AppendLine(Mes#);
      Return false;
    End If; 
  End If;
  kks_system_part_len# := 
    SP.KKS.kks_Agregate_Len+SP.KKS.kks_System_Len+SP.KKS.kks_SubSystem_Len; 
  If LENGTH(KKSFull$) > kks_system_part_len# Then
    UnitCode$ := SUBSTR(KKSFull$,kks_system_part_len#+1);
  Else
    UnitCode$ := Null;
  End If;

  D('Finish Before Return True.','DEBUG SP.KKS#2.GetKKS');

  Return true;
End;
--==============================================================================
--���������� ID ������� �� ID ��� ����������������� ������
-- ��� Null
Function GetChildID(ParentID$ In Number, UnitName$ In Varchar2) Return Number
Is
  rv Number;
Begin
  SELECT ID Into rv 
  From SP.MODEL_OBJECTS
  Where PARENT_MOD_OBJ_ID=ParentID$
  And MOD_OBJ_NAME=UnitName$
  ;
  
  Return rv;
Exception When NO_DATA_FOUND Then
  Return Null;
End;
--==============================================================================

BEGIN
  null;
END KKS#2;
CREATE OR REPLACE PACKAGE BODY SP.E3#TJ
as
-- ��������� ������ ������� ���� Zuken e3.Series � Total Journal
-- ��. �������� 
-- E3.02.������������� ������ �� �� E3 � TJ.������� ���������.pdf
-- � ����� ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\E3\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-07-03
-- update 2019-09-12 2019-10-28 2019-12-27 2020-07-29 2020-12-16 2021-01-19

E#M VARCHAR2(4000);
--==============================================================================
--������� ����������, ��������� ���������� ������������� ������ ���������� 
--�������  � ����������� E3 => TJ.

--��������� ������ �����
LocationParams_ SP.G.TMACRO_PARS;
--��������� ������ �������
SystemParams_ SP.G.TMACRO_PARS;

--������������ ���������
DeviceDynaParams_ SP.G.TMACRO_PARS;
CableDynaParams_ SP.G.TMACRO_PARS;
CableWireDynaParams_ SP.G.TMACRO_PARS;

--�� ������������ ���������, ����������� ��� ���������� E3=>TJ
--������ � ������������ ����������� ���������� ��� ��������� ����������
DeviceStatParams_ SP.G.TMACRO_PARS;
DevicePinStatParams_ SP.G.TMACRO_PARS;
CableStatParams_ SP.G.TMACRO_PARS;
CableWireStatParams_ SP.G.TMACRO_PARS;

--���������, ������������� � API Zuken e3.series
--������� E3RP �������� E3 requested parameters
--����� ���������� ������� ���� Device Pin, ������������� � API Zuken e3.series
E3RP_DevicePin_ SP.G.TMACRO_PARS;
--����� ���������� ������� ���� Cable Wire, ������������� � API Zuken e3.series
E3RP_CableWire_ SP.G.TMACRO_PARS;
--==============================================================================
kks_AGREGATE_OBJECT_ID_ Number;
kks_SYSTEM_OBJECT_ID_ Number;
kks_SUBSYSTEM_OBJECT_ID_ Number;

--==============================================================================
--����������
--��� ������� ���������� � ������
REP_MODEL_OBJECT_NAME CONSTANT Varchar2(20):='����������';

RepArray_SINGLE_ID_ Number;

--�������� ������ ����������
SOURCE_SAPR_ Varchar2(128);
--����� ������� (������)
sPROJECT_NUMBER_ Varchar2(40);
--==============================================================================
--��� ������� �����
--���� ������ ��������, ��  ������ �� ������������
--���� ������ �������, �� ���������� � ��� ������ (mess1$)
--� ����� �������� ������ ������� (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 )
As
Begin
  If NVL(LENGTH(mess1$),0)+NVL(LENGTH(mess2$),0) < 4000 Then
    mess1$:=mess1$||mess2$;
    Return;
  End If;
  
  D(mess1$,Tag$);
  mess1$:='[�����������...]'||CHR(10)||CHR(13)||mess2$;
  
  Return;
End;

--==============================================================================
--�������� (���������) ��������� �� From$ � To$
Procedure COPY_MACRO_PARS
(From$ In SP.G.TMACRO_PARS, To$ In Out NoCopy SP.G.TMACRO_PARS)
As
  i# SP.V_MODEL_OBJECT_PARS.PARAM_NAME%TYPE;
Begin
  i#:=From$.First;
  While Not i# is Null 
  Loop
    To$(i#):=From$(i#);
    i#:=From$.Next(i#);
  End Loop;
End COPY_MACRO_PARS;

--==============================================================================
-- ������� ��������� �� ������ From$, 
-- ������� �� ���������� � ��������� ������ Etalon$
Procedure REMOVE_MACRO_PARS
(Etalon$ In SP.G.TMACRO_PARS, From$ In Out NoCopy SP.G.TMACRO_PARS)
As
  i# SP.V_MODEL_OBJECT_PARS.PARAM_NAME%TYPE;
Begin
  i#:=From$.First;
  While Not i# is Null 
  Loop
    If Not Etalon$.Exists(i#) Then
      From$.Delete(i#);
    End If;
    i#:=From$.Next(i#);
  End Loop;
End REMOVE_MACRO_PARS;
--==============================================================================
--�������� (���������) ������� �� From$ � To$
Procedure COPY_OBJECTS
(From$ In SP.G.TOBJECTS, To$ In Out NoCopy SP.G.TOBJECTS)
As
  i# BINARY_INTEGER;
Begin
  If To$.Count < 1 Then
    To$:=From$;
    Return;
  End If;
  
  i#:=From$.First;
  While Not i# is Null 
  Loop
    To$(To$.Last+1):=From$(i#);
    i#:=From$.Next(i#);
  End Loop;
  Return;
End COPY_OBJECTS;
--==============================================================================
--���������� ID ������� ������ �� PARENT_MOD_OBJ_ID$ � ��� ����� 
Function Get_MOD_OBJ_ID
(PARENT_MOD_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) Return Number
As
  rv# Number;
Begin
  
  Select ID Into rv#
  From SP.MODEL_OBJECTS
  WHERE PARENT_MOD_OBJ_ID = PARENT_MOD_OBJ_ID$
  AND MOD_OBJ_NAME = MOD_OBJ_NAME$
  ;
  
  Return rv#;
  
Exception When NO_DATA_FOUND Then
  
  E#M:='������ ������ MOD_OBJ_NAME ['||MOD_OBJ_NAME$||'] PARENT_MOD_OBJ_ID ='
  ||to_char(PARENT_MOD_OBJ_ID$)||' �� ������.';
  
  D(E#M,'Error In SP.E3#TJ.Get_MOD_OBJ_ID');
  
  raise_application_error(-20033,'Error In SP.E3#TJ.Get_MOD_OBJ_ID: '||E#M );   
  
End Get_MOD_OBJ_ID;
--==============================================================================
--���������� ������ ���������� ������ 
--'TJ.singles.�����', 'TJ.singles.�������'
Procedure GetE3AllParamForSingle
( ObjFullName$ In Varchar2, Params$ In Out SP.G.TMACRO_PARS)
As
Begin
  For r In(
    Select op.NAME 
      , op.TYPE_ID, op.E_VAL, op.N
      , op.D, op.S, op.X, op.Y
    From SP.V_OBJECTS ob
    Inner Join SP.OBJECT_PAR_S op
    ON op.OBJ_ID=ob.ID
    Where ob.FULL_NAME=ObjFullName$
    And ob.KIND='SINGLE'
  )Loop
    Params$(r.NAME):=TValue(ValueType => r.TYPE_ID,E => r.E_VAL,
        N => r.N, D => r.D, S => r.S, X => r.X, Y => r.Y);
  End Loop;
End GetE3AllParamForSingle;
--==============================================================================
--���������� ������ ������������� (�� READ_ONLY)���������� ������  
--'TJ.singles.�����', 'TJ.singles.�������'
Procedure GetE3AllEditableParamForSingle
( ObjFullName$ In Varchar2, Params$ In Out NoCopy SP.G.TMACRO_PARS)
As
Begin
  For r In(
    Select op.NAME 
      , op.TYPE_ID, op.E_VAL, op.N
      , op.D, op.S, op.X, op.Y
    From SP.V_OBJECTS ob
    Inner Join SP.OBJECT_PAR_S op
    ON op.OBJ_ID=ob.ID
    And op.R_ONLY<>1  --Not ReadOnly
    Where ob.FULL_NAME=ObjFullName$
    And ob.KIND='SINGLE'
  )Loop
    Params$(r.NAME):=TValue(ValueType => r.TYPE_ID,E => r.E_VAL,
        N => r.N, D => r.D, S => r.S, X => r.X, Y => r.Y);
  End Loop;
  
End GetE3AllEditableParamForSingle;
--==============================================================================
--���������� ������ ������������� (�� READ_ONLY)���������� ������  
--'TJ.singles.�����', 'TJ.singles.�������'
Procedure GetE3AllRequiredParamForSingle
( ObjFullName$ In Varchar2, Params$ In Out NoCopy SP.G.TMACRO_PARS)
As
Begin
  For r In(
    Select op.NAME 
      , op.TYPE_ID, op.E_VAL, op.N
      , op.D, op.S, op.X, op.Y
    From SP.V_OBJECTS ob
    Inner Join SP.OBJECT_PAR_S op
    ON op.OBJ_ID=ob.ID
    And op.R_ONLY=-1  --Required
    Where ob.FULL_NAME=ObjFullName$
    And ob.KIND='SINGLE'
  )Loop
    Params$(r.NAME):=TValue(ValueType => r.TYPE_ID,E => r.E_VAL,
        N => r.N, D => r.D, S => r.S, X => r.X, Y => r.Y);
  End Loop;
End GetE3AllRequiredParamForSingle;
--==============================================================================
--���������� ����� ���������� ������ �����
Function Get_Locati�nSingleParams Return SP.G.TMACRO_PARS
Is
Begin 
  If LocationParams_.Count<1 Then
    GetE3AllEditableParamForSingle(ObjFullName$ => SP.TJ_WORK.SINAME_LOCATION
            , Params$ => LocationParams_);
  End If;
  Return LocationParams_;
End Get_Locati�nSingleParams;
--==============================================================================
--���������� ����� ���������� ������ �������
Function Get_SystemSingleParams Return SP.G.TMACRO_PARS
Is
Begin 
  If SystemParams_.Count<1 Then
    GetE3AllEditableParamForSingle(
            ObjFullName$ => SP.TJ_WORK.SINAME_FUNCTIONAL_SYSTEM
            , Params$ => SystemParams_);
  End If;
  Return SystemParams_;
End Get_SystemSingleParams;
--==============================================================================
--���������� ������ DynaParams$ ������������ ���������� ������ 
--'TJ.singles.�������', 'TJ.singles.������', 'TJ.singles.���� ������'
Procedure GetE3DynaParamForSingle
( ObjFullName$ In Varchar2, DynaParams$ In Out NoCopy SP.G.TMACRO_PARS)
As
Begin
  For r In(
    Select op.NAME 
      , op.TYPE_ID, op.E_VAL, op.N
      , op.D, op.S, op.X, op.Y
    From SP.V_OBJECTS ob
    Inner Join SP.OBJECT_PAR_S op
    ON op.OBJ_ID=ob.ID
    ----------------------------------------------------------------------------
    --����� ������������ ���������� ���������� �� HP_ ��� AEP_ 
    AND (op.NAME LIKE 'HP_%'  Or op.NAME LIKE 'AEP_%') 
    ----------------------------------------------------------------------------
    Where ob.FULL_NAME=ObjFullName$
    And ob.KIND='SINGLE'
  )Loop
    DynaParams$(r.NAME):=TValue(ValueType => r.TYPE_ID,E => r.E_VAL,
        N => r.N, D => r.D, S => r.S, X => r.X, Y => r.Y);
  End Loop;
End;
--==============================================================================
--���������� ����� ������������ ���������� ����������
Function Get_DeviceDynaParams Return SP.G.TMACRO_PARS
Is
Begin 
  If DeviceDynaParams_.Count<1 Then
    GetE3DynaParamForSingle(ObjFullName$ => SP.TJ_WORK.SINAME_DEVICE
            , DynaParams$ => DeviceDynaParams_);
  End If;
  Return DeviceDynaParams_;
End Get_DeviceDynaParams;
--==============================================================================
--���������� ����� ����������� ���������� ����������, ����������� ��� ����������
Function Get_DeviceStatParams Return SP.G.TMACRO_PARS
Is
Begin 
  If DeviceStatParams_.Count<1 Then
    DeviceStatParams_('IS_SYSTEM'):=B_(true);     
    DeviceStatParams_('�������'):=SP.TVALUE(SP.G.TRel,'');              
    DeviceStatParams_('POSITION'):=SP.TVALUE(SP.G.TStr4000,'');          
    DeviceStatParams_('ASSIGNMENT'):=SP.TVALUE(SP.G.TStr4000,'');
    DeviceStatParams_('NAME'):=S_('');  
    DeviceStatParams_('OID'):=SP.TVALUE(SP.G.TOID,'');  
    --��� ������������ ��������� 
    DeviceStatParams_('POID'):=SP.TVALUE(SP.G.TOID,''); 
    DeviceStatParams_('CABLE_END_LOCATION'):=S_('');       --����� (Rel)
    DeviceStatParams_('E3TYPE'):=S_('');        
    DeviceStatParams_('E3SUBTYPE'):=S_('');      
    DeviceStatParams_('PART_NUMBER'):=S_('');      
    DeviceStatParams_('DOT_NET_TYPE'):=S_('');                       
    DeviceStatParams_('IsTerminal'):=B_(false);     
    DeviceStatParams_('IsTerminalBlock'):=B_(false);  
  End If;
  Return DeviceStatParams_;
End Get_DeviceStatParams;
--==============================================================================
--���������� ����� ����������� ���������� ������, ����������� ��� ����������
Function Get_CableStatParams Return SP.G.TMACRO_PARS
Is
Begin 
  If CableStatParams_.Count<1 Then
    CableStatParams_('IS_SYSTEM'):=B_(true);     
    CableStatParams_('�������'):=SP.TVALUE(SP.G.TRel,'');              
    CableStatParams_('POSITION'):=S_('');  
    CableStatParams_('ASSIGNMENT'):=SP.TVALUE(SP.G.TStr4000,''); 
    CableStatParams_('NAME'):= S_('');
    CableStatParams_('OID'):=S_('');
    CableStatParams_('E3TYPE'):=S_('');
    CableStatParams_('DOT_NET_TYPE'):=S_('');
  End If;
  Return CableStatParams_;
End Get_CableStatParams;
--==============================================================================
--���������� ����� ������������ ���������� ������
Function Get_CableDynaParams Return SP.G.TMACRO_PARS
Is
Begin 
  If CableDynaParams_.Count<1 Then
    GetE3DynaParamForSingle(ObjFullName$ => SP.TJ_WORK.SINAME_CABLE
            , DynaParams$ => CableDynaParams_);
  End If;
  Return CableDynaParams_;
End Get_CableDynaParams;
--==============================================================================
--���������� ����� ����������� ���������� ���� ������, 
--����������� ��� ����������
Function Get_CableWireStatParams Return SP.G.TMACRO_PARS
Is
Begin 
  If CableWireStatParams_.Count<1 Then
    CableWireStatParams_('IS_SYSTEM'):=B_(false);     
    CableWireStatParams_('NAME'):= S_('');
    CableWireStatParams_('OID'):=S_('');
    CableWireStatParams_('POID'):=S_('');              
    CableWireStatParams_('E3TYPE'):=S_('');
    CableWireStatParams_('DOT_NET_TYPE'):=S_('');
    CableWireStatParams_('REF_PIN_FIRST'):=SP.TVALUE(SP.G.TRel,'');              
    CableWireStatParams_('REF_PIN_SECOND'):=SP.TVALUE(SP.G.TRel,'');
  End If;
  Return CableWireStatParams_;
End Get_CableWireStatParams;

--==============================================================================
--���������� ����� ������������ ���������� ���� ������
Function Get_CableWireDynaParams Return SP.G.TMACRO_PARS
Is
Begin 
  If CableWireDynaParams_.Count<1 Then
    GetE3DynaParamForSingle(ObjFullName$ => SP.TJ_WORK.SINAME_CABLE_WIRE
            , DynaParams$ => CableWireDynaParams_);
  End If;
  Return CableWireDynaParams_;
End Get_CableWireDynaParams;
--==============================================================================
--�������� �� �������� �������-����������������-������� �� ParentModObjID$,
--� ������� �������� ��������� SOURCE_SAPR ��������� � SourceSapr$
Procedure MarkToDelete1(ParentModObjID$ In Number, SourceSapr$ In Varchar2)
Is
  CURSOR cuMO_UPD
  Is
  SELECT mo.ID
  FROM SP.MODEL_OBJECTS mo
  WHERE mo.PARENT_MOD_OBJ_ID=ParentModObjID$
  AND EXISTS(SELECT * FROM SP.MODEL_OBJECT_PAR_S mop 
              Where mop.MOD_OBJ_ID=mo.ID
              AND mop.NAME='SOURCE_SAPR'
              AND mop.S=SourceSapr$ 
            )
  FOR UPDATE OF TO_DEL
  ;
  
  --crow SP.MODEL_OBJECTS%ROWTYPE;
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
Begin
  Open cuMO_UPD;
  
  Loop
  
    Fetch cuMO_UPD into ModObjId#;
    
    Exit When cuMO_UPD%NotFound;
    
    Update SP.MODEL_OBJECTS Set TO_DEL = 1 Where Current Of cuMO_UPD;
    
  End Loop;
  
  D('� ������� ID = '|| to_char(ParentModObjID$)||' �������� �� �������� '
  ||to_char(cuMO_UPD%ROWCOUNT)||' �������� � SOURCE_SAPR ['||SourceSapr$||'].'
  ,'Info SP.E3#TJ.MarkToDelete 1');
  
  Close cuMO_UPD;
  
End MarkToDelete1;
--==============================================================================
--�������� �� �������� �������-������� �� RootModObjID$,
--� ������� �������� ��������� SOURCE_SAPR ��������� � SourceSapr$
Procedure MarkToDeleteDesc(RootModObjID$ In Number)
Is

  CURSOR cuMO_UPD
  Is
  With V_OP As (select  op1.ID 
      from SP.OBJECT_PAR_S op1
      Where op1.NAME='SOURCE_SAPR'
      Order By op1.ID
      )
  Select mo.ID 
  From SP.MODEL_OBJECTS mo 

  Inner Join SP.MODEL_OBJECT_PAR_S mop
  ON mop.MOD_OBJ_ID=mo.ID

  Where mop.OBJ_PAR_ID In (
        select  ID 
        from V_OP 
        )
  And mop.S=SOURCE_SAPR
  Start With mo.ID=RootModObjID$  
  Connect by Prior mo.ID=mo.PARENT_MOD_OBJ_ID
  FOR UPDATE OF TO_DEL
  ;
  
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
Begin

  Open cuMO_UPD;
  
  Loop
  
    Fetch cuMO_UPD into ModObjId#;
    
    Exit When cuMO_UPD%NotFound;
    
    Update SP.MODEL_OBJECTS Set TO_DEL = 1 Where Current Of cuMO_UPD;
    
  End Loop;
  
  D('� ������� ID = '|| to_char(RootModObjID$)||' �������� �� �������� '
  ||to_char(cuMO_UPD%ROWCOUNT)||' �������� � SOURCE_SAPR ['
  ||SOURCE_SAPR||'].','Info SP.E3#TJ.MarkToDelete 3');
  
  Close cuMO_UPD;
  
End MarkToDeleteDesc;
--==============================================================================
--������� ��� �������-������� �� RootModObjID$,
--� ������� �������� OBJ_ID ��������� � ObjectID$
Procedure DeleteObjects(RootModObjID$ In Number, ObjectID$ In Number)
Is
  CURSOR cuMO_UPD
  Is
  Select mo.ID 
  From SP.MODEL_OBJECTS mo 

  Where mo.OBJ_ID=ObjectID$
  Start With mo.ID=RootModObjID$  
  Connect by Prior mo.ID=mo.PARENT_MOD_OBJ_ID
  FOR UPDATE
  ;
  
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
Begin
  Open cuMO_UPD;
  
  Loop
  
    Fetch cuMO_UPD into ModObjId#;
    
    Exit When cuMO_UPD%NotFound;
    
    Delete From SP.MODEL_OBJECTS Where Current Of cuMO_UPD;
    
  End Loop;
  
  D('� ������� ID = '|| to_char(RootModObjID$)||' ������o '
  ||to_char(cuMO_UPD%ROWCOUNT)||' �������� � OBJ_ID ['||to_char(ObjectID$)||'].'
  ,'Info SP.E3#TJ.DeleteObjects');
  
  Close cuMO_UPD;
  
End DeleteObjects;
--==============================================================================
--�������� �� �������� �������-����������������-������� �� ParentModObjID$,
--� ������� �������� ��������� ObjParID$ ��������� � SourceSapr$
Procedure MarkToDelete
(ParentModObjID$ In Number, ObjParID$ In Number)
Is

  CURSOR cuMO_UPD
  Is
  SELECT mo.ID
  FROM SP.MODEL_OBJECTS mo
  WHERE mo.PARENT_MOD_OBJ_ID=ParentModObjID$
  AND EXISTS(SELECT * FROM SP.MODEL_OBJECT_PAR_S mop 
              Where mop.MOD_OBJ_ID=mo.ID
              AND mop.OBJ_PAR_ID=ObjParID$
              AND mop.S=SOURCE_SAPR 
            )
  FOR UPDATE OF TO_DEL
  ;
  
  --crow SP.MODEL_OBJECTS%ROWTYPE;
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
Begin
  
  Open cuMO_UPD;
  
  Loop
  
    Fetch cuMO_UPD into ModObjId#;
    
    Exit When cuMO_UPD%NotFound;
    
    Update SP.MODEL_OBJECTS Set TO_DEL = 1 Where Current Of cuMO_UPD;
    
  End Loop;
  
  D('� ������� ID = '|| to_char(ParentModObjID$)||' �������� �� �������� '
  ||to_char(cuMO_UPD%ROWCOUNT)||' �������� � SOURCE_SAPR ['||SOURCE_SAPR||'].'
  ,'Info SP.E3#TJ.MarkToDelete 2');
  
  Close cuMO_UPD;
  
End MarkToDelete;
--==============================================================================
--�������� ������� ��������, � ������� ModObjID$
Procedure UnMarkToDelete(ModObjID$ In Number)
As
Begin
  Update SP.MODEL_OBJECTS 
  Set TO_DEL=0
  Where ID=ModObjID$;
End;

--==============================================================================
--�������� ID ������� ������ �� ��� ������, ����� � ������� ��������
--���� ������� �� ����������, �� ������ ���.
Function GetOrCreateObject
(ModObjName$ In varchar2, PID$ in Number, ObjectID$ In Number) return Number
as                        
 id# Number;     
 P# SP.G.TMACRO_PARS;
 EM# Varchar2(4000);
begin 
  Begin
    select id into id# from SP.MODEL_OBJECTS 
    where PARENT_MOD_OBJ_ID = PID$ 
    and MOD_OBJ_NAME = ModObjName$ 
    and OBJ_ID = ObjectID$;
    return id#;
  Exception When NO_DATA_FOUND then    
    Null;
  End; 
  P#('NAME') := S_(ModObjName$);     
  P#('PID'):= N_(PID$);    
--    ����������� ������ ���������� ������       
    EM#:=SP.M.TEST_PARAMS(P#, ObjectID$);
    if EM# is not null then 
      D(EM#, 'ERROR In SP.E3#TJ.GetOrCreateObject');
      raise_application_error(-20033, EM#);    
    end if;                      
    id# := SP.MO.MERGE_OBJECT(ModelObject => P#, CatalogID => ObjectID$);    
  return id#;       
end;
--==============================================================================
--�������� ID ������� ������ �� ��� ������, ����� � ������� ��������
--���� ������� �� ����������, �� ������ ���.
Function GetOrCreateObject
(ModObjName$ In varchar2, PID$ in Number, catFullname In varchar2) return Number
as                        
 CatalogID# Number; 
begin 
  begin
    select ID into CatalogID# from SP.V_OBJECTS where FULL_NAME = catFullname;
  exception when NO_DATA_FOUND then
     print('No Catalog '||catFullname || ' !!!');  
     raise NO_DATA_FOUND;
  end; 
  
  return GetOrCreateObject
    (ModObjName$ =>ModObjName$, PID$=>PID$, ObjectID$ => CatalogID#);
end;
--==============================================================================
--������� ��� �������, � ������� ������� FOLDER_ID$ � ���� SubFolderName$
--���� ���� ����������� (FOLDER_ID$/SubFolderName$) �� �������, 
--�� ������ �� ������
Procedure DeleteSubfolderContainment
(FOLDER_ID$ In Number, SubFolderName$ In Varchar2)
As                        
  SUB_FOLDER_ID# Number;      
Begin

 SELECT mo.ID Into SUB_FOLDER_ID#              
 FROM SP.MODEL_OBJECTS mo          
 WHERE mo.MOD_OBJ_NAME=SubFolderName$
 AND mo.PARENT_MOD_OBJ_ID=FOLDER_ID$;  
                                             
 DELETE FROM SP.MODEL_OBJECTS           
 WHERE PARENT_MOD_OBJ_ID=SUB_FOLDER_ID#
 ;

  D('���������� ������� ['||SubFolderName$||'] �������.'
  ,'INFO SP.E3#TJ.DeleteSubfolderContainment');

Exception When NO_DATA_FOUND Then
  D('����� ['||SubFolderName$||'] �� �������.'
  ,'WARNING SP.E3#TJ.DeleteSubfolderContainment');
End DeleteSubfolderContainment;
--==============================================================================
--������� �������-����������������-������� �� ParentModObjID$,
--� ������� SP.MODEL_OBJECTS.TO_DEL = 1.
--���� ��������� ������, �� ����� �������������� � ��� � ����� 
--'WARNING SP.E3#TJ.DeleteMarked' � ���������� ��������.
Procedure DeleteMarked(ParentModObjID$ In Number)
Is
CURSOR cuMO_UPD
  Is
  SELECT mo.ID, mo.MOD_OBJ_NAME 
  FROM SP.MODEL_OBJECTS mo
  WHERE mo.PARENT_MOD_OBJ_ID=ParentModObjID$
  And mo.TO_DEL=1
  FOR UPDATE
  ;
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
  ModObjName# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  --������� ���������� ��������.
  err_cnt# BINARY_INTEGER;
Begin
  Open cuMO_UPD;
  err_cnt#:=0;
  Loop
  
    Fetch cuMO_UPD into ModObjId#, ModObjName#;
    
    Exit When cuMO_UPD%NotFound;
    
    begin
      Delete SP.MODEL_OBJECTS Where Current Of cuMO_UPD;
    Exception When OTHERS Then
      err_cnt#:=err_cnt#+1;
      D('������ �������� ������� ID = '||to_char(ModObjId#)||', NAME ['
      ||ModObjName#||']:'||CHR(13)||CHR(10)||SQLERRM
      ,'WARNING SP.E3#TJ.DeleteMarked');
    End;
  End Loop;
  
    D('� ������� ID = '|| to_char(ParentModObjID$)||' ������� '
  ||to_char(cuMO_UPD%ROWCOUNT-err_cnt#)||' ��������.'
  ,'Info SP.E3#TJ.DeleteMarked');
  
  Close cuMO_UPD;
End DeleteMarked;
--==============================================================================
--������� �������-������� �� ParentModObjID$,
-- � ������� SP.MODEL_OBJECTS.OBJ_ID = ObjectID$
-- � SP.MODEL_OBJECTS.TO_DEL = 1.
--���� ��������� ������, �� ����� �������������� � ��� � ����� 
--'WARNING SP.E3#TJ.DeleteMarkedDesc' � ���������� ��������.
Procedure DeleteMarkedDesc(ParentModObjID$ In Number, ObjectID$ In Number)
Is
CURSOR cuMO_UPD
  Is
  SELECT mo.ID, mo.MOD_OBJ_NAME 
  FROM SP.MODEL_OBJECTS mo
    Where mo.OBJ_ID=ObjectID$
    And mo.TO_DEL=1
    Start With mo.PARENT_MOD_OBJ_ID=ParentModObjID$  
    Connect by Prior mo.ID=mo.PARENT_MOD_OBJ_ID
  FOR UPDATE
  ;
  ModObjId# SP.MODEL_OBJECTS.ID%TYPE;
  ModObjName# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  --������� ���������� ��������.
  err_cnt# BINARY_INTEGER;
Begin
  Open cuMO_UPD;
  err_cnt#:=0;
  Loop
  
    Fetch cuMO_UPD into ModObjId#, ModObjName#;
    
    Exit When cuMO_UPD%NotFound;
    
    begin
      Delete SP.MODEL_OBJECTS Where Current Of cuMO_UPD;
    Exception When OTHERS Then
      err_cnt#:=err_cnt#+1;
      D('������ �������� ������� ID = '||to_char(ModObjId#)||', NAME ['
      ||ModObjName#||']:'||CHR(13)||CHR(10)||SQLERRM
      ,'WARNING SP.E3#TJ.DeleteMarkedDesc');
    End;
  End Loop;
  
    D('� ������� ID = '|| to_char(ParentModObjID$)||' ������� '
  ||to_char(cuMO_UPD%ROWCOUNT-err_cnt#)||' ��������.'
  ,'Info SP.E3#TJ.DeleteMarkedDesc');
  
  Close cuMO_UPD;
End DeleteMarkedDesc;
--==============================================================================
--������ ������ ��� ������ ��� � �������� ��� TO_DEL=0
Function CreateOrUpdate
(IP$ In Out NoCopy SP.G.TMACRO_PARS, UsedObjectID$ In Number) 
Return Varchar2
Is
  EM# Varchar2(4000);
  ModObjID# Number;
Begin
  EM#:=SP.M.TEST_PARAMS(IP$,UsedObjectID$);
  If Not EM# Is Null Then
    D(EM#||CHR(13)||CHR(10)||SP.TO_.STR(IP$)
                ,'ERROR In SP.E3#TJ.CreateOrUpdate');
    Return EM#;
  End If;
  ModObjID#:=SP.MO.MERGE_OBJECT(IP$,UsedObjectID$);
  
--  D('UnMarkToDelete :'||CHR(13)||CHR(10)||SP.TO_.STR(IP$)
--  ,'DEBUG SP.E3#TJ.CreateOrUpdate');
  
  UnMarkToDelete(ModObjID#);
  Return EM#;
Exception When OTHERS Then
  EM#:='������ SP.E3#TJ.CreateOrUpdate:'||SQLERRM;
  D(EM#,'ERROR SP.E3#TJ.CreateOrUpdate');
  Return EM#;
End;
--==============================================================================
--������ ������ ��� ������ ���, �� ������� ��� TO_DEL=0
Function CreateOrUpdate
(UsedObjectID$ In Number, IP$ In Out NoCopy SP.G.TMACRO_PARS, ModObjID$ In Out Number) 
Return Varchar2
Is
  EM# Varchar2(4000);
Begin
  ModObjID$:=null;
  EM#:=SP.M.TEST_PARAMS(IP$,UsedObjectID$);
  If Not EM# Is Null Then
    D(EM#||CHR(13)||CHR(10)||SP.TO_.STR(IP$)
                ,'ERROR In SP.E3#TJ.CreateOrUpdate');
    Return EM#;
  End If;
  ModObjID$:=SP.MO.MERGE_OBJECT(IP$,UsedObjectID$);
  
  Return EM#;
Exception When OTHERS Then
  EM#:='������ SP.E3#TJ.CreateOrUpdate:'||SQLERRM;
  D(EM#,'ERROR SP.E3#TJ.CreateOrUpdate');
  Return EM#;
End;
--==============================================================================
-- ������� (�������) ��� ��������� ���� TRel � ���� �������� ���� 
-- LOCATION_OBJECT, ���������� ������ WorkID$.
-- ������ ID ������ ����� ������ ID ������ ������� �������, �������� �������� � 
--�������� �������� ����� 
Procedure ClearLocationRELs(WorkID$ In Number)
As
Begin
  For loc In (
      SELECT mo.ID  As LOCATION_ID , mo.MOD_OBJ_NAME as LOCATION_NAME
    -- mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
    -- , mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    -- , mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
      FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(RootModObjID$ => WorkID$
      , ObjectID$ => SP.TJ_WORK.Get_LOCATION_OBJECT_ID )) mo
  )Loop
    
    Delete From SP.MODEL_OBJECT_PAR_S
    Where MOD_OBJ_ID=loc.LOCATION_ID
    And TYPE_ID=SP.G.TRel;
    
  End Loop;
End ClearLocationRELs;  
--==============================================================================
--������� ���������� E3 �� ������ TJ
-- ���������� ������� ���� ������� � ���������� � API Zuken e3.Series 
-- � ��� �� ������, �� ������ OID
--������� ���������� ���� ��� ��� ����� DeviceName$, �� OID �� ����� DeviceOID$
--� ��������� ������ - ������ �� ������.
--TODO �� �������� �� ������, ����� ���-������ ��������� �� ����������
-- ��� ���� �� ��� �����.
--������� ������ ����������� � �������������� E3=>TJ (��������� ������)
Procedure DeleteE3Device(
PID$ In Number  --ID �������-������ ����������
, DeviceName$ In Varchar2  --��� ����������
, DeviceOID$ In Varchar2   --OID ����������
)
Is
  DeviceID# Number;
Begin
  
  Begin
    Select ID Into DeviceID#
    From SP.V_MODEL_OBJECTS mo
    Where mo.PARENT_MOD_OBJ_ID=PID$
    And mo.MOD_OBJ_NAME=DeviceName$
    And mo.OID<>DeviceOID$
    ;
  Exception When NO_DATA_FOUND Then
    Return;
  End;

  --�������� ��� ������ �� ���� ���������� ����������
  --�.�. �������� ��� ������ �� ����� ������� DeviceID#                                             
  Update SP.MODEL_OBJECT_PAR_S
  SET N=null
  WHERE TYPE_ID=SP.G.TRel 
  AND N In (                 
    SELECT ID From SP.MODEL_OBJECTS                
    WHERE PARENT_MOD_OBJ_ID=DeviceID#
    );                                                             
                               
--  Begin
  
    Delete From SP.MODEL_OBJECTS
    Where ID=DeviceID#;
--  Exception When OTHERS Then          
--    EM:='������ �������� ������� ['||DeviceName$||'] ID='||to_char(DeviceID#)
--    ||':'||CHR(13)||CHR(10)||SQLERRM;
--  End;
  
  
End DeleteE3Device;
--==============================================================================
--������� ������ ��� �������, � ������� PARENT=ParentID$
  --ParentID$:=668152500;
Procedure DeleteCablesWihoutPositions(ParentID$ In Number) 
As
  ID# Number;
  Name# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  
  CURSOR moCur
  IS
  SELECT ID, MOD_OBJ_NAME
  FROM SP.MODEL_OBJECTS mo
  WHERE mo.PARENT_MOD_OBJ_ID=ParentID$
  AND NOT EXISTS(SELECT * FROM SP.MODEL_OBJECT_PAR_S mop
                  WHERE mop.MOD_OBJ_ID=mo.ID
                  And mop.NAME='POSITION')
  FOR UPDATE;
  
Begin
  Open moCur;
  Loop
    Fetch moCur Into ID#, Name#;
    Exit When moCur%NOTFOUND;
    --pipe row(Name#);
    Delete From SP.MODEL_OBJECTS Where Current Of moCur;
  End Loop;
  
  Close moCur;
End;
--==============================================================================
--##############################################################################
--������ � ��������������� KKS � ������ TJ
--==============================================================================
-- ������ ���������� kks_AGREGATE_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_AGREGATE_OBJECT_ID Return Number
As
Begin
  If kks_AGREGATE_OBJECT_ID_ Is Null Then
    kks_AGREGATE_OBJECT_ID_:=SP.TJ_WORK.GetObjectID(kks_AGREGATE_OBJECT_NAME);
  End If;
  Return kks_AGREGATE_OBJECT_ID_;
End;

--==============================================================================
-- ������ ���������� kks_SYSTEM_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_SYSTEM_OBJECT_ID Return Number
As
Begin
  If kks_SYSTEM_OBJECT_ID_ Is Null Then
    kks_SYSTEM_OBJECT_ID_:=SP.TJ_WORK.GetObjectID(kks_SYSTEM_OBJECT_NAME);
  End If;
  Return kks_SYSTEM_OBJECT_ID_;
End;

--==============================================================================
-- ������ ���������� kks_SUBSYSTEM_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_SUBSYSTEM_OBJECT_ID Return Number
As
Begin
  If kks_SUBSYSTEM_OBJECT_ID_ Is Null Then
    kks_SUBSYSTEM_OBJECT_ID_:=SP.TJ_WORK.GetObjectID(kks_SUBSYSTEM_OBJECT_NAME);
  End If;
  Return kks_SUBSYSTEM_OBJECT_ID_;
End;
--==============================================================================
--������� ����� ������ ���� R_KKS_2FOLDER
Function New_R_KKS_2FOLDER
(DEVICE_FOLDER_ID$ In Number, CABLE_FOLDER_ID$ In Number) Return R_KKS_2FOLDER
As
  rv# R_KKS_2FOLDER;
Begin
  rv#.DEVICE_FOLDER_ID := DEVICE_FOLDER_ID$;
  rv#.CABLE_FOLDER_ID := CABLE_FOLDER_ID$;
  Return rv#;
End New_R_KKS_2FOLDER;
--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ���������� 
--  1. KKS_1FOLDER_AA$ - ������ KKS -> ������ �������������� 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - ������ KKS -> (ID ����� ����������, ID ����� ������) 
Procedure Get_KKS_STRUCTURE_INDEXES(ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS)
Is
  name2# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  name3# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
  For r In
  ( Select 
      mo1.ID as ID1, 
      mo1.MOD_OBJ_NAME as NAME1,
      
      mo2.ID as ID2, 
      mo2.MOD_OBJ_NAME as NAME2,

      mo3.ID as ID3, 
      mo3.MOD_OBJ_NAME as NAME3,

      mo4d.ID as DEVICE_FOLDER_ID, 
      mo4c.ID as CABLE_FOLDER_ID 

    From SP.MODEL_OBJECTS mo1
    
    Left Outer Join SP.MODEL_OBJECTS mo2
    On mo2.PARENT_MOD_OBJ_ID=mo1.ID
    And mo2.OBJ_ID = Get_kks_SYSTEM_OBJECT_ID
    
    Left Outer Join SP.MODEL_OBJECTS mo3
    On mo3.PARENT_MOD_OBJ_ID=mo2.ID
    And mo3.OBJ_ID = Get_kks_SUBSYSTEM_OBJECT_ID

    Left Outer Join SP.MODEL_OBJECTS mo4d
    On mo4d.PARENT_MOD_OBJ_ID=mo3.ID
    And mo4d.MOD_OBJ_NAME = DEVICE_SECTION_NAME --'����������'

    Left Outer Join SP.MODEL_OBJECTS mo4c
    On mo4c.PARENT_MOD_OBJ_ID=mo3.ID
    And mo4c.MOD_OBJ_NAME = CABLE_SECTION_NAME  --'������'

    Where mo1.PARENT_MOD_OBJ_ID=ParentID$
    And mo1.OBJ_ID = Get_kks_AGREGATE_OBJECT_ID
  )Loop
    KKS_1FOLDER_AA$(r.NAME1):=r.ID1;
    If Not r.ID2 Is Null Then
      name2# := r.NAME1||r.NAME2;
      KKS_1FOLDER_AA$(name2#):=r.ID2;
      If Not r.ID3 Is Null Then
        name3# := name2#||r.NAME3;
        KKS_1FOLDER_AA$(name3#):=r.ID3;
        
        KKS_2FOLDER_AA$(name3#) := 
              New_R_KKS_2FOLDER(r.DEVICE_FOLDER_ID, r.CABLE_FOLDER_ID);
      End If;
    End If;
  End Loop; 
End Get_KKS_STRUCTURE_INDEXES;
--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ������������ KKS-�������������
--������� �� E3Systems$
--  1. KKS_1FOLDER_AA$ - ������ KKS -> ������ �������������� 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - ������ KKS -> (ID ����� ����������, ID ����� ������) 
Procedure COMPLETE_KKS_STRUCTURE(
ParentID$ In Number, E3Systems$ In Out NoCopy SP.G.TOBJECTS
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS)
Is
  kk# BINARY_INTEGER;
  kks# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;    
  kks_agregate# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_system# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_subsystem# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  bo# Boolean;
  boDev# Boolean;
  boCab# Boolean;
  
  kks_agregate_id# Number;
  kks_system_id# Number;
  kks_subsystem_id# Number;
  kks_system_key# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_subsystem_key# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  
  IP# SP.G.TMACRO_PARS;  -- ��������� �������� KKS 
  IPG# SP.G.TMACRO_PARS; -- ��������� ����� ������ � ����������
  R2Folder#  R_KKS_2FOLDER;
  EM# Varchar2(4000);
Begin
   IP#('SP3DTYPE'):=V_('IType','UnSupported');
   IPG#('SP3DTYPE'):=V_('IType','GenericSystem');

  If KKS_1FOLDER_AA$.Count <1 Then
    Get_KKS_STRUCTURE_INDEXES(ParentID$ => ParentID$
    , KKS_1FOLDER_AA$ => KKS_1FOLDER_AA$, KKS_2FOLDER_AA$ => KKS_2FOLDER_AA$);
  End If;

  kk#:=E3Systems$.First;
  while not kk# Is Null Loop         
    kks#:=E3Systems$(kk#)('NAME').AsString;
    bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);
    
    If KKS_1FOLDER_AA$.Exists(kks_agregate#) Then
      kks_agregate_id#:=KKS_1FOLDER_AA$(kks_agregate#);
    Else
      IP#('NAME'):=S_(kks_agregate#);
      IP#('PID'):=ID_(ParentID$);
      EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_AGREGATE_OBJECT_ID
        , IP$ => IP#, ModObjID$ => kks_agregate_id#);
      KKS_1FOLDER_AA$(kks_agregate#):= kks_agregate_id#;
    End if;
    
    kks_system_key#:=kks_agregate#||kks_system#;   
    If KKS_1FOLDER_AA$.Exists(kks_system_key#) Then
      kks_system_id#:=KKS_1FOLDER_AA$(kks_system_key#);
    Else
      IP#('NAME'):=S_(kks_system#);
      IP#('PID'):=ID_(kks_agregate_id#);
      EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_SYSTEM_OBJECT_ID
        , IP$ => IP#, ModObjID$ => kks_system_id#);
      KKS_1FOLDER_AA$(kks_system_key#):= kks_system_id#;
    End if;

    kks_subsystem_key#:=kks_system_key#||kks_subsystem#;   
    If KKS_1FOLDER_AA$.Exists(kks_subsystem_key#) Then
      kks_subsystem_id#:=KKS_1FOLDER_AA$(kks_subsystem_key#);
    Else
      IP#('NAME'):=S_(kks_subsystem#);
      IP#('PID'):=ID_(kks_system_id#);
      EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_SUBSYSTEM_OBJECT_ID
        , IP$ => IP#, ModObjID$ => kks_subsystem_id#);
      KKS_1FOLDER_AA$(kks_subsystem_key#):= kks_subsystem_id#;
    End if;

    If Not KKS_2FOLDER_AA$.Exists(kks_subsystem_key#) Then
      boDev# := false;
      boCab# := false;
    Else
      R2Folder#:=KKS_2FOLDER_AA$(kks_subsystem_key#);
      boDev# := Not R2Folder#.DEVICE_FOLDER_ID Is Null;
      boCab# := Not R2Folder#.CABLE_FOLDER_ID Is Null;
    End If;

    If Not boDev# Then
      IPG#('NAME'):=S_(DEVICE_SECTION_NAME);
      IPG#('PID'):=ID_(kks_subsystem_id#);
      IPG#('����������'):=S_('���������� ������� '||kks_subsystem_key#||'.');
      EM#:=CreateOrUpdate(UsedObjectID$ => SP.TJ_WORK.Get_GENERYC_SYSTEM_OBJECT_ID
        , IP$ => IPG#, ModObjID$ => R2Folder#.DEVICE_FOLDER_ID);
      
      If Not EM# Is Null Then
        D('������ �������� �������� ��� "'||DEVICE_SECTION_NAME||'":'
        ||CHR(10)||EM#, 'ERROR In SP.E3#TJ.COMPLETE_KKS_STRUCTURE');
      End If;
    End if;


    If Not boCab# Then
      IPG#('NAME'):=S_(CABLE_SECTION_NAME);
      IPG#('PID'):=ID_(kks_subsystem_id#);
      IPG#('����������'):=S_('������ ������� '||kks_subsystem_key#||'.');
      EM#:=CreateOrUpdate(UsedObjectID$ => SP.TJ_WORK.Get_GENERYC_SYSTEM_OBJECT_ID
        , IP$ => IPG#, ModObjID$ => R2Folder#.CABLE_FOLDER_ID);

      If Not EM# Is Null Then
        D('������ �������� �������� ��� "'||CABLE_SECTION_NAME||'":'
        ||CHR(10)||EM#, 'ERROR In SP.E3#TJ.COMPLETE_KKS_STRUCTURE');
      End If;
    End if;

    If not (boDev# And boCab#) Then
      KKS_2FOLDER_AA$(kks_subsystem_key#):= R2Folder#;
    End if;
    
    kk#:=E3Systems$.Next(kk#);            
  End Loop;
  
End COMPLETE_KKS_STRUCTURE;

--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ������������ KKS-�������������
-- ���������, ���������������� ��� �������� �������������������� ������, 
-- ��������������� ��������
--  1. 00
--  2. 00BHE KKS
--  3. 00BHE KKS00
Procedure COMPLETE_KKS_STRUCTURE_BHE_KKS(
ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS)
Is
  kks_defa_agregate_Id# Number; 
  kks_defa_system_Id# Number;
  kks_defa_subsystem_Id# Number;
  kks_idx# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  IP# SP.G.TMACRO_PARS;  -- ��������� �������� KKS 
  IPG# SP.G.TMACRO_PARS; -- ��������� ����� ������ � ����������
  EM# Varchar2(4000);
  
  boDev# Boolean;
  boCab# Boolean;
  R2Folder#  R_KKS_2FOLDER;
  
Begin
  IP#('SP3DTYPE'):=V_('IType','UnSupported');
  IPG#('SP3DTYPE'):=V_('IType','GenericSystem');

  If Not KKS_1FOLDER_AA$.Exists(SP.KKS.Get_kks_defa_agregate) Then 
      IP#('NAME'):=S_(SP.KKS.Get_kks_defa_agregate);
      IP#('PID'):=ID_(ParentID$);
      EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_AGREGATE_OBJECT_ID
        , IP$ => IP#, ModObjID$ => kks_defa_agregate_Id#);
      KKS_1FOLDER_AA$(SP.KKS.Get_kks_defa_agregate):= kks_defa_agregate_Id#;
  Else
    kks_defa_agregate_Id#:=KKS_1FOLDER_AA$(SP.KKS.Get_kks_defa_agregate);
  End If;
  
  kks_idx#:=SP.KKS.Get_kks_defa_agregate||SP.KKS.No_KKS;
  If KKS_1FOLDER_AA$.Exists(kks_idx#) Then
    kks_defa_system_Id#:=KKS_1FOLDER_AA$(kks_idx#);
  Else
    IP#('NAME'):=S_(SP.KKS.No_KKS);
    IP#('PID'):=ID_(kks_defa_agregate_Id#);
    EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_SYSTEM_OBJECT_ID
      , IP$ => IP#, ModObjID$ => kks_defa_system_Id#);
    KKS_1FOLDER_AA$(kks_idx#):= kks_defa_system_Id#;
  End if;

  kks_idx#:=kks_idx#||SP.KKS.Get_kks_defa_subsystem;
  If KKS_1FOLDER_AA$.Exists(kks_idx#) Then
    kks_defa_subsystem_Id#:=KKS_1FOLDER_AA$(kks_idx#);
  Else
    IP#('NAME'):=S_(SP.KKS.Get_kks_defa_subsystem);
    IP#('PID'):=ID_(kks_defa_system_Id#);
    EM#:=CreateOrUpdate(UsedObjectID$ => Get_kks_SUBSYSTEM_OBJECT_ID
      , IP$ => IP#, ModObjID$ => kks_defa_subsystem_Id#);
    KKS_1FOLDER_AA$(kks_idx#):= kks_defa_subsystem_Id#;
  End if;
  ------------------------------------------------------------------------------
  If Not KKS_2FOLDER_AA$.Exists(kks_idx#) Then
    boDev# := false;
    boCab# := false;
  Else
    R2Folder#:=KKS_2FOLDER_AA$(kks_idx#);
    boDev# := Not R2Folder#.DEVICE_FOLDER_ID Is Null;
    boCab# := Not R2Folder#.CABLE_FOLDER_ID Is Null;
  End If;

  If Not boDev# Then
    IPG#('NAME'):=S_(DEVICE_SECTION_NAME);
    IPG#('PID'):=ID_(kks_defa_subsystem_Id#);
    IPG#('����������'):=S_('������������������� �� �������� ����������.');
    EM#:=CreateOrUpdate(UsedObjectID$ => SP.TJ_WORK.Get_GENERYC_SYSTEM_OBJECT_ID
      , IP$ => IPG#, ModObjID$ => R2Folder#.DEVICE_FOLDER_ID);
    
    If Not EM# Is Null Then
      D('������ �������� �������� ��� "'||DEVICE_SECTION_NAME||'":'
      ||CHR(10)||EM#, 'ERROR In SP.E3#TJ.COMPLETE_KKS_STRUCTURE');
    End If;
  End if;


  If Not boCab# Then
    IPG#('NAME'):=S_(CABLE_SECTION_NAME);
    IPG#('PID'):=ID_(kks_defa_subsystem_Id#);
    IPG#('����������'):=S_('������������������� �� �������� ������.');
    EM#:=CreateOrUpdate(UsedObjectID$ => SP.TJ_WORK.Get_GENERYC_SYSTEM_OBJECT_ID
      , IP$ => IPG#, ModObjID$ => R2Folder#.CABLE_FOLDER_ID);

    If Not EM# Is Null Then
      D('������ �������� �������� ��� "'||CABLE_SECTION_NAME||'":'
      ||CHR(10)||EM#, 'ERROR In SP.E3#TJ.COMPLETE_KKS_STRUCTURE');
    End If;
  End if;

  If not (boDev# And boCab#) Then
    KKS_2FOLDER_AA$(kks_idx#):= R2Folder#;
  End if;
  
End COMPLETE_KKS_STRUCTURE_BHE_KKS;
--==============================================================================
--������� ��� ���������� � ������ ������, ������� ��������� � ���������� ������
Procedure RepClear
Is
Begin
  SOURCE_SAPR_ := Null;
  sPROJECT_NUMBER_:=Null;
End RepClear;
--==============================================================================
--��������� DevicePin, ������������� � API Zuken e3.Series
Function E3RP_DevicePin Return SP.G.TMACRO_PARS
Is
Begin
  If E3RP_DevicePin_.Count<2 Then
  
  GetE3AllRequiredParamForSingle(
    ObjFullName$ => SP.TJ_WORK.SINAME_DEVICE_PIN
  , Params$ => E3RP_DevicePin_);
    
    E3RP_DevicePin_('OID'):=SP.TVALUE(SP.G.TOID,'');
    E3RP_DevicePin_('POID'):=SP.TVALUE(SP.G.TOID,'');
    E3RP_DevicePin_('E3TYPE'):=S_('');        
    E3RP_DevicePin_('E3SUBTYPE'):=S_('');      
    E3RP_DevicePin_('DOT_NET_TYPE'):=S_('');                       
  End If;
  Return E3RP_DevicePin_;
End;
--==============================================================================
--��������� Cable Wire, ������������� � API Zuken e3.Series
Function E3RP_CableWire Return SP.G.TMACRO_PARS
Is
Begin
  If E3RP_CableWire_.Count<2 Then
  
  GetE3AllRequiredParamForSingle(
    ObjFullName$ => SP.TJ_WORK.SINAME_CABLE_WIRE
  , Params$ => E3RP_CableWire_);
    
    E3RP_CableWire_('REF_PIN_FIRST'):=SP.TVALUE(SP.G.TRel,'');
    E3RP_CableWire_('REF_PIN_SECOND'):=SP.TVALUE(SP.G.TRel,'');

    E3RP_CableWire_('OID'):=SP.TVALUE(SP.G.TOID,'');
    E3RP_CableWire_('POID'):=SP.TVALUE(SP.G.TOID,'');
    E3RP_CableWire_('E3TYPE'):=S_('');        
    E3RP_CableWire_('DOT_NET_TYPE'):=S_('');                       
  End If;
  Return E3RP_CableWire_;
End E3RP_CableWire;
--==============================================================================
--��������� ������������� R_REP_ARRAYS_INFO � �������
Function to_str(rai$ In R_REP_ARRAYS_INFO) Return Varchar2
Is
Begin
  Return 'Deleted('||rai$.DELETED_GROUP_ID||', '||rai$.DELETED_ARRAY_NAME
  ||'), Inserted('||rai$.INSERTED_GROUP_ID||', '||rai$.INSERTED_ARRAY_NAME
  ||'), Updated('||rai$.UPDATED_GROUP_ID||', '||rai$.UPDATED_ARRAY_NAME||')';
End to_str;
--==============================================================================
--�������������� ���������� ������
-- vSOURCE_SAPR_
-- sPROJECT_NUMBER_
Procedure Set_SOURCE_SAPR(E3_JOB_OID$ In Varchar2)
As
  s# Varchar2(120);
  
  --��������� ����� ������� �� E3_JOB_OID$
  Function extract_project_number Return Varchar2
  Is
    k# BINARY_INTEGER;
    rv# Varchar2(40);
  Begin
    
    k#:=INSTR(E3_JOB_OID$,'@');
    
    If k# < 1 Then
      E#M:='OID ['||E3_JOB_OID$||'] ������� Zuken e3.series �� ��������'
      ||' ������������� �������-����������� "@".';
      D(E#M,'Error In SP.E3#TJ.Set_SOURCE_SAPR');
      rv#:=E3_JOB_OID$;
--      raise_application_error(-20033
--        , 'Error In SP.E3#TJ.Set_SOURCE_SAPR:'||CHR(13)||CHR(10)||E#M);  
    ElsIf k# = 1 Then
      E#M:='OID ['||E3_JOB_OID$||'] ������� Zuken e3.series �� ��������'
      ||' Gid �������, �������� ����� ������������ ��������-������������ "@".';
      D(E#M,'Error In SP.E3#TJ.Set_SOURCE_SAPR');
      raise_application_error(-20033
        , 'Error In SP.E3#TJ.Set_SOURCE_SAPR:'||CHR(13)||CHR(10)||E#M);  
    Else
      rv#:=SUBSTR(E3_JOB_OID$,k#+1);
    End If;
    
    
    If rv# Is Null Then
      E#M:='OID ['||E3_JOB_OID$||'] ������� Zuken e3.series �� �������� ������'
      ||' �������, �������� ����� ������������� �������-����������� "@".';
      D(E#M,'Error In SP.E3#TJ.Set_SOURCE_SAPR');
      raise_application_error(-20033
        , 'Error In SP.E3#TJ.Set_SOURCE_SAPR:'||CHR(13)||CHR(10)||E#M);    
    End If;
    Return rv#;
  End;
Begin
  s#:='e3:'||E3_JOB_OID$;

  If SOURCE_SAPR_ Is Null Then
    null;
  ElsIf  SOURCE_SAPR_ = s# Then
    Return;  --������ �� ������
  Else 
    RepClear;
  End If;

  SOURCE_SAPR_ := s#;
  sPROJECT_NUMBER_:=extract_project_number;

End Set_SOURCE_SAPR;
--==============================================================================
--���������� ���������� ������ SOURCE_SAPR
Function SOURCE_SAPR Return Varchar2
Is
Begin
  If SOURCE_SAPR_ Is Null Then
    E#M:='���������� ������ SP.E3#TJ.SOURCE_SAPR �� ����������������.'
    ||' ��� � ������������� ������� ������������ ��������� ������'
    ||' SP.E3#TJ.Set_SOURCE_SAPR.';
    D(E#M,'Error In SP.E3#TJ.SOURCE_SAPR');
    raise_application_error(-20033
      , 'Error In SP.E3#TJ.SOURCE_SAPR:'||CHR(13)||CHR(10)||E#M);    
  End If;
  Return SOURCE_SAPR_;
End SOURCE_SAPR;
--==============================================================================
--���������� ���������� ������ SOURCE_SAPR
Function PROJECT_NUMBER Return Varchar2
Is
Begin
  If sPROJECT_NUMBER_ Is Null Then
    E#M:='���������� ������ SP.E3#TJ.PROJECT_NUMBER �� ����������������.'
    ||' ��� � ������������� ������� ������������ ��������� ������'
    ||' SP.E3#TJ.Set_SOURCE_SAPR.';
    D(E#M,'Error In SP.E3#TJ.SOURCE_SAPR');
    raise_application_error(-20033
      , 'Error In SP.E3#TJ.SOURCE_SAPR:'||CHR(13)||CHR(10)||E#M);    
  End If;
  Return sPROJECT_NUMBER_;
End PROJECT_NUMBER;
--==============================================================================
--������� ��� �������-�������-������ �� RootModObjID$
Procedure DeleteCables(RootModObjID$ In Number)
Is
Begin
  DeleteObjects(RootModObjID$, SP.TJ_WORK.Get_CABLE_OBJECT_ID);
End;

--==============================================================================
--������� ��� �������-�������-���������� �� RootModObjID$
Procedure DeleteDevices(RootModObjID$ In Number)
Is
Begin
  DeleteObjects(RootModObjID$, SP.TJ_WORK.Get_DEVICE_OBJECT_ID);
End;

--==============================================================================
-- ������ ���������� RepArray_SINGLE_ID �, � ������ �������������, 
-- �������� ���.
Function Get_RepArray_SINGLE_ID Return Number
As
Begin
  If RepArray_SINGLE_ID_ Is Null Then
    
    Select ID Into RepArray_SINGLE_ID_
    From SP.V_OBJECTS
    Where FULL_NAME=RepArray_SINGLE_NAME
    ;
    
  End If;
  Return RepArray_SINGLE_ID_;
End Get_RepArray_SINGLE_ID;
--==============================================================================
--���������� ���������� �� �������� ���������� �������������� ��������
--������ MODEL_ID$
--���� � ������ �� ������������� �������������� �������, �� ��� ���� 
--������������ ������ ����� Null.
Function Get_REP_ARRAYS_INFO(MODEL_ID$ In Number) Return R_REP_ARRAYS_INFO
as
  rv# R_REP_ARRAYS_INFO; 
  RepModObjID# Number;
  s# SP.MODEL_OBJECT_PAR_S.S%TYPE;
  name# SP.MODEL_OBJECT_PAR_S.NAME%TYPE;
  em# Varchar2(4000);
  --��������� GROUP_ID � ARRAY_NAME, 
  --���������� ��������� �� ������ ��� null
  function get_info2
  (s$ In varchar2, gr_id$ in out number, arr_name$ in out varchar2)
  return varchar2
  As
    ip# BINARY_INTEGER;
    em1# Varchar2(4000);
    gr_name# Varchar2(4000);
  Begin
    ip#:=INSTR(s$,'.');
    If ip#=0 Then
      em1#:='�������� ['||s$||'] ��������� [%1] �� �������� �����.';
      Return em1#;
    End If;
    gr_name#:=SUBSTR(s$,1,ip#-1);
    Begin
      Select ID Into gr_id$
      From SP.GROUPS
      Where Name=gr_name#
      ;
    Exception When NO_DATA_FOUND Then
      em1#:='������ ['||gr_name#||'] ��� ��������� [%1] �� ��������� ['||s$
      ||'] �� ������� � ������� SP.GROUPS.';
      Return em1#;
    When TOO_MANY_ROWS Then
      em1#:='��� ��������� [%1] �� ��������� ['||s$
      ||'] ������� SP.GROUPS ������� ��������� ����� � ������ ['
      ||gr_name#||'].';
      Return em1#;
    End;
    arr_name$:=RTRIM(SUBSTR(s$,ip#+1));
    Return em1#;
  End;
Begin
  Begin
    Select ID Into RepModObjID#
    From SP.MODEL_OBJECTS 
    Where MODEL_ID=MODEL_ID$
    And OBJ_ID=Get_RepArray_SINGLE_ID
    ;
  Exception When NO_DATA_FOUND Then
    --� ������ �� ������������� �������������� �������
    E#M:='� ������ MODEL_ID = '||MODEL_ID$
    ||'�� ������������� �������������� �������.';
    D(E#M,'Warning In SP.E3#TJ.Get_REP_ARRAYS_INFO');
    Return rv#;
  End;
  
  For r In (
    Select PARAM_NAME As NAME, VAL
    From SP.V_MODEL_OBJECT_PARS 
    Where MOD_OBJ_ID=RepModObjID#
    And TYPE_ID=SP.G.TArr
  )Loop
  
    If r.NAME='Inserted' Then
      em#:=get_info2(r.VAL, rv#.INSERTED_GROUP_ID, rv#.INSERTED_ARRAY_NAME);
    ElsIf r.NAME='Deleted' Then
      em#:=get_info2(r.VAL, rv#.DELETED_GROUP_ID, rv#.DELETED_ARRAY_NAME);
    ElsIf r.NAME='Updated' Then
      em#:=get_info2(r.VAL, rv#.UPDATED_GROUP_ID, rv#.UPDATED_ARRAY_NAME);
    Else
      E#M:='������������ ��� ��������� ['||r.NAME||'].';
      D(E#M,'ERROR In SP.E3#TJ.Get_REP_ARRAYS_INFO');
      raise_application_error(-20033, E#M);    
    End If;
    
    If Not em# Is Null Then
      E#M:=REPLACE(em#,'[%1]','['||r.NAME||']');
      D(E#M,'ERROR In SP.E3#TJ.Get_REP_ARRAYS_INFO');
      raise_application_error(-20033, E#M);    
    End If;
    
  End Loop;
  return rv#;
End Get_REP_ARRAYS_INFO;
--==============================================================================
--������������ �������� ���������� ������.
--1.	�� ������� Inserted ��������� ��� ��������, 
--    ������������ � ������� Deleted.
--2.	�� ������� Updated ��������� ��� ��������, 
--    ������������ � ������� Deleted.
--3.	�� ������� Updated ��������� ��� ��������, 
--    ������������ � ������� Inserted.
--4.	�� ������� Updated ��������� ��� ��������� ��������.
Procedure NormalizeRepArrays(MODEL_ID$ In Number)
Is
 ra_info# R_REP_ARRAYS_INFO;
 
  --������ ��� �������� ��������� (���� S) ������� �� ������� Updated,
  --�������� ������ ������ � ����������� ID
  Cursor CurDup#
  Is
    With c1 As (
      Select MIN(ID) as MIN_ID, COUNT(ID) as CNT, S as OID
      From SP.ARRAYS
      Where GROUP_ID=ra_info#.UPDATED_GROUP_ID
      And NAME=ra_info#.UPDATED_ARRAY_NAME
      GROUP BY S),
    c2 As (  
      SELECT * FROM c1
      Where CNT>1)
    Select * From SP.ARRAYS arr
      Where arr.GROUP_ID=ra_info#.UPDATED_GROUP_ID
      And arr.NAME=ra_info#.UPDATED_ARRAY_NAME
      AND Exists (Select * From c2
                  Where c2.MIN_ID<>arr.ID
                  AND c2.OID = arr.S)
    For Update
    ;

 -- �������� ������� �� ������� SP.ARRAYS � ������������ � ������, 
 -- ������� ��������� ������, ��� ����������� � ����
 Procedure delete_existing(FromGroupID$ In Number, FromArrayName$ In varchar2
  , ExistingGroupID$ In Number, ExistingArrayName$ In Varchar2)
 As
    Cursor Cur123#
    Is
    Select * From SP.ARRAYS arr
      Where arr.GROUP_ID=FromGroupID$
      And arr.NAME = FromArrayName$
      And Exists (Select * From SP.ARRAYS de
                  Where de.GROUP_ID=ExistingGroupID$
                  And de.NAME=ExistingArrayName$
                  And de.S=arr.S)
      For Update
      ;
  Begin
    For r In Cur123# Loop
      Delete From SP.ARRAYS Where CURRENT Of Cur123#;
    End Loop;
  End;
    
Begin
  ra_info#:=Get_REP_ARRAYS_INFO(MODEL_ID$);
  -- �������� ������� �� ������� Inserted, ������� ���������� 
  -- � ������� Deleted
  delete_existing(ra_info#.INSERTED_GROUP_ID, ra_info#.INSERTED_ARRAY_NAME
  , ra_info#.DELETED_GROUP_ID, ra_info#.DELETED_ARRAY_NAME);
  
  -- �������� ������� �� ������� Updated, ������� ���������� 
  -- � ������� Deleted
  delete_existing(ra_info#.UPDATED_GROUP_ID, ra_info#.UPDATED_ARRAY_NAME
  , ra_info#.DELETED_GROUP_ID, ra_info#.DELETED_ARRAY_NAME);

  -- �������� ������� �� ������� Updated, ������� ���������� � ������� Inserted
  delete_existing(ra_info#.UPDATED_GROUP_ID, ra_info#.UPDATED_ARRAY_NAME
  , ra_info#.INSERTED_GROUP_ID, ra_info#.INSERTED_ARRAY_NAME);
  
  --�������� ��������� ������� �� ������� Updated
  For r In CurDup# Loop
    Delete From SP.ARRAYS Where CURRENT Of CurDup#;
  End Loop;
End NormalizeRepArrays;  
--==============================================================================
--�������� ���� ��������, OID ������� ���������������� � ������� �Deleted� 
-- ��� GROUP_NAME �RepArrays� �� ������ MODEL_ID$.
-- ���� OID ������������ � ������ �������, �� �������� �� ������� SP.ARRAYS
-- �� ����������.
Procedure RepDelete(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2)
Is
  ra_info# R_REP_ARRAYS_INFO;  
  --������ ��� �������� ������� �� SP.ARRAYS
  Cursor CurArr#
  Is
    Select * From SP.ARRAYS 
    Where GROUP_ID=ra_info#.DELETED_GROUP_ID
    And NAME=ra_info#.DELETED_ARRAY_NAME
    And S LIKE '%@'||JOB_NUMBER$
    For Update
    ;
  
  boFound Boolean;
  EM# Varchar2(200);
Begin
  E#M:='';
  EM#:='������� ������� � ������ ������� � ����������� OID:'||CHR(13)||CHR(10);
  D_Long(E#M,EM#,'Info SP.E3#TJ.RepDelete');

  ra_info#:=Get_REP_ARRAYS_INFO(MODEL_ID$);

  For ra In CurArr# Loop
    
    Delete From SP.MODEL_OBJECTS
    Where MODEL_ID=MODEL_ID$
    And OID=ra.S
    ;
    
    BoFound:=False;
    For ro In (
      Select * From SP.MODEL_OBJECTS
      Where OID=ra.S
    )Loop
      boFound:=True;
      D_Long(E#M,'MODEL_ID = '||to_char(ro.MODEL_ID)||', OID ['||ra.S||']'
      ||CHR(13)||CHR(10),'Info SP.E3#TJ.RepDelete');
    End Loop;
    
    If boFound = False Then
      Delete From SP.ARRAYS Where Current Of CurArr#;
    End If;
    
  End Loop;
  
  If E#M <> EM# Then
    D(E#M,'Info SP.E3#TJ.RepDelete');
  End If;
  
End;
--==============================================================================
--���������� ������ OIDs ����������� ��������
Function GetInsertedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS
As
  ra_info# R_REP_ARRAYS_INFO;
  rv# SP.TSHORTSTRINGS;
Begin

  ra_info#:=Get_REP_ARRAYS_INFO(MODEL_ID$);

  Select S 
  Bulk Collect Into rv# 
  From SP.ARRAYS 
  Where GROUP_ID=ra_info#.INSERTED_GROUP_ID
  And NAME=ra_info#.INSERTED_ARRAY_NAME
  And S LIKE '%@'||JOB_NUMBER$
    ;

  Return rv#;
End GetInsertedOIDs;
--==============================================================================
--���������� ������ OIDs ����������� ��� ��������� ��������
--������� ���� ����������� ������, ����� - ���������.
Function GetInsertedOrUpdatedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS
As
  ra_info# R_REP_ARRAYS_INFO;
  rv# SP.TSHORTSTRINGS;
Begin

  ra_info#:=Get_REP_ARRAYS_INFO(MODEL_ID$);

--D('INSERTED_GROUP_ID ='||ra_info#.INSERTED_GROUP_ID
--||'INSERTED_ARRAY_NAME ['||ra_info#.INSERTED_ARRAY_NAME
--||'], UPDATED_GROUP_ID ='||ra_info#.UPDATED_GROUP_ID
--||'UPDATED_ARRAY_NAME ['||ra_info#.UPDATED_ARRAY_NAME
--||'], JOB_NUMBER = '||JOB_NUMBER$||', MODEL_ID='||MODEL_ID$||'.'
--,'DEBUG SP.E3#TJ.GetInsertedOrUpdatedOIDs');

  Select S 
  Bulk Collect Into rv# 
  From SP.ARRAYS 
  Where GROUP_ID=ra_info#.INSERTED_GROUP_ID
  And NAME=ra_info#.INSERTED_ARRAY_NAME
  And S LIKE '%@'||JOB_NUMBER$
    ;

  For r in (
    Select Distinct S 
    From SP.ARRAYS 
    Where GROUP_ID=ra_info#.UPDATED_GROUP_ID
    And NAME=ra_info#.UPDATED_ARRAY_NAME
    And S LIKE '%@'||JOB_NUMBER$
  )Loop
    rv#.EXTEND;
    rv#(rv#.Count):=r.S;
  End Loop;

  Return rv#;
End GetInsertedOrUpdatedOIDs;
--==============================================================================
-- ������ � ����� ������� ��������� ������ ������ ����������, ���� ��� ���, � 
-- ���������� ��� false.
-- ���� ������ ����������, �� ���������� true.
-- ���� ����� �������� ���������, �� ���������� ����������.
Function Create1ReplicationObject(
RepModObjID$ In Out Number  --ID ������� ���������� �����������
) return Boolean
as                        
 P# SP.G.TMACRO_PARS;
 EM# Varchar2(4000);
 begin 
  Begin
    select id into RepModObjID$ from SP.MODEL_OBJECTS 
    where MODEL_ID = SP.GET_Model_ID 
    and OBJ_ID = Get_RepArray_SINGLE_ID;
    return True;
  Exception When NO_DATA_FOUND then    
    Null;
  End; 
  
  P#('NAME') := S_('/'||REP_MODEL_OBJECT_NAME); 
  P#('Inserted') := SP.TVALUE(SP.G.TArr,'RepArrays.Inserted@'||PROJECT_NUMBER);
  P#('Updated') := SP.TVALUE(SP.G.TArr,'RepArrays.Updated@'||PROJECT_NUMBER);
  P#('Deleted') := SP.TVALUE(SP.G.TArr,'RepArrays.Deleted@'||PROJECT_NUMBER);
  
--    ����������� ������ ���������� ������       
  EM#:=SP.M.TEST_PARAMS(P#, Get_RepArray_SINGLE_ID);
  if EM# is not null then 
    D(EM#, 'ERROR In SP.E3#TJ.Create1ReplicationObject');
    raise_application_error(-20033, EM#);    
  end if;                      
  RepModObjID$ := SP.MO.MERGE_OBJECT
      (ModelObject => P#, CatalogID => Get_RepArray_SINGLE_ID);    
  return False;       
 end;
--==============================================================================
--������� �������������� ������� �������� ������ � ������� (Job) Zuken e3.series.
Procedure ClearReplicationArrays(MODEL_ID$ In Number)
Is  
  --replication arrays info
  ra_info# R_REP_ARRAYS_INFO;
  PROJECT_NUMBER# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE; 
Begin
  ra_info#:=Get_REP_ARRAYS_INFO(MODEL_ID$ => MODEL_ID$);
  Begin
    PROJECT_NUMBER#:=PROJECT_NUMBER;
  Exception When Others Then
    PROJECT_NUMBER# := Null;
  End;
  
  D('Info: '||to_str(ra_info#)||'; PROJECT_NUMBER ['||PROJECT_NUMBER#||']'
  ,'DEBUG SP.E3#TJ.ClearReplicationArrays');
  
  If PROJECT_NUMBER# Is Null Then
    Delete from SP.ARRAYS
    Where Name=ra_info#.DELETED_ARRAY_NAME
    And GROUP_ID= ra_info#.DELETED_GROUP_ID
    ;
  
    Delete from SP.ARRAYS
    Where Name=ra_info#.INSERTED_ARRAY_NAME
    And GROUP_ID= ra_info#.INSERTED_GROUP_ID
    ;
    
    Delete from SP.ARRAYS
    Where Name=ra_info#.UPDATED_ARRAY_NAME
    And GROUP_ID= ra_info#.UPDATED_GROUP_ID
    ;
  Else
    Delete from SP.ARRAYS
    Where Name=ra_info#.DELETED_ARRAY_NAME
    And GROUP_ID= ra_info#.DELETED_GROUP_ID
    And S LIKE '%@'||PROJECT_NUMBER#
    ;
  
    Delete from SP.ARRAYS
    Where Name=ra_info#.INSERTED_ARRAY_NAME
    And GROUP_ID= ra_info#.INSERTED_GROUP_ID
    And S LIKE '%@'||PROJECT_NUMBER#
    ;
    
    Delete from SP.ARRAYS
    Where Name=ra_info#.UPDATED_ARRAY_NAME
    And GROUP_ID= ra_info#.UPDATED_GROUP_ID
    And S LIKE '%@'||PROJECT_NUMBER#
    ;
  End If;  
End ClearReplicationArrays;
--==============================================================================
--������� �������������� ������� ������� ������ � ������� (Job) Zuken e3.series.
Procedure ClearReplicationArrays
Is  
  --replication arrays info
  ra_info# R_REP_ARRAYS_INFO;
Begin
  ClearReplicationArrays(MODEL_ID$ => SP.TG.Cur_MODEL_ID);
  
End ClearReplicationArrays;
--==============================================================================
-- ��� ������� ������� �� ModObjs$ �������� ��� SymRel �� Rel, 
-- ��� ���� ��������� OID �� ������� ����������� OID2OID_AA.
Procedure AllSymRel2Rel(ModObjs$ In Out NoCopy SP.G.TOBJECTS
,OID2OID_AA$ In AA_ShortStr2ShortStr)
--����������� ��� ��������� ���� �������� ���� SymRel � Rel
As
ii# BINARY_INTEGER;
mon# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;  
v# SP.TVALUE;                           
v1# SP.TVALUE;
vs# VARCHAR2(4000);        
--id# Number;
OID# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
ii#:=ModObjs$.First;                        
While ii# is Not Null Loop                              
    mon#:=ModObjs$(ii#).First;    
    while mon# is not null Loop   
      v#:=ModObjs$(ii#)(mon#);      
      If v#.TypeName='SymRel' Then         
        --vs#:='=OID>'||v#.AsString;   
        vs#:=v#.AsString;                             
        If instr(vs#,'=OID>')=1 Then   
          OID#:=SUBSTR(vs#,6);
        Else
          OID#:=vs#;  
        End If;                            
                                    
        If OID2OID_AA$.Exists(OID#) Then      
          OID#:=OID2OID_AA$(OID#);                  
        End If;           
                                      
        vs#:='=OID>'||OID#;
        v1#:=Rel_(OID => vs#);                     
        ModObjs$(ii#)(mon#):=v1#;      
      End If;                        
      mon#:=ModObjs$(ii#).Next(mon#); 
    End Loop;                           
  ii#:=ModObjs$.Next(ii#);                       
End Loop;                                       
Exception When OTHERS Then
  E#M:='�������� ['||mon#||'] ������� ['||ModObjs$(ii#)('NAME').AsString
  ||'] ����� �������������� �������� ['||vs#||'].'||CHR(13)||CHR(10)||SQLERRM;
  D( E#M,'ERROR In SP.E3#TJ.AllSymRel2Rel');
  raise_application_error(-20033,'ERROR In SP.E3#TJ.AllSymRel2Rel: '||E#M );   
End;
--==============================================================================
-- � ������� � ������� ii$ �������������� ������� OBJECTS$ ������ ������, 
-- �� ������ �������������� �������� ������� IDX$,
-- ��� ParamName$ - ������� ��������� ��� ���������-������. 
Procedure ChangeRefOID 
(OBJECTS$ In Out NoCopy SP.G.TOBJECTS, ii$ in Number
, ParamName$ in Varchar2, IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr)
As                                                                       
--� OBJECTS(ii) ������ ��� ��������� NameFrom �� NameTo ����� ������� � ��������
OID# SP.V_MODEL_OBJECTS.OID%TYPE;    
le# BINARY_INTEGER;    
bu# VARCHAR2(4000);                    
Begin           
  If OBJECTS$(ii$).Exists(ParamName$) Then                   
                                   
    bu#:=OBJECTS$(ii$)(ParamName$).AsString;  

    If bu# Is Null Then                                 
      le#:= 0 ;                                           
    Else                             
      le#:=LENGTH(bu#);                                  
    End If  ;                                                             
                                              
    If (Not le# Is Null) And (le#>5) Then             
      OID#:=SUBSTR(bu#,6);
      If IDX$.Exists(OID#) Then
        bu#:=IDX$(OID#);                                       
                                             
        OBJECTS$(ii$)(ParamName$):=SP.TVALUE(Sp.G.TSymRel, bu#);     
      End If;
    Else                                                
      OBJECTS$(ii$).Delete(ParamName$);                     
    End If;                                         
  End If;
Exception When OTHERS Then                                    
  E#M:='::'||CHR(13)||CHR(10)||SQLERRM;
  D( E#M,'ERROR In SP.E3#TJ.ChangeRefOID');
  raise_application_error(-20033,'ERROR In SP.E3#TJ.ChangeRefOID: '||E#M );   
  
End;
--==============================================================================
-- � OBJECTS$(ii$) ������ ��� ��������� NameFrom$ �� NameTo$ 
-- ����� ������� � ��������
Function ChangeObjParName(OBJECTS$ In Out NoCopy SP.G.TOBJECTS,
ii$ in Number, NameFrom$ in Varchar2, NameTo$ In Varchar2)
Return Boolean
Is
Begin
  If OBJECTS$(ii$).Exists(NameFrom$) Then 
          --������ PART_NUMBER �� ����������
          OBJECTS$(ii$)(NameTo$):=OBJECTS$(ii$)(NameFrom$);
          OBJECTS$(ii$).Delete(NameFrom$); 
    Return True;
  End If;
  Return False;
End;
--==============================================================================
--��������� ���������� ������� �������������� ����������� ������� �� ��������� 
--������. ���� ������ � ������ ���, �� ����� ��������� ������� ������. 
Function ImageID2ID_IDX_Init(IMAGE_FOLDER_ID$ In Number) 
Return AA_ShortStr2ShortStr
Is
  rv# AA_ShortStr2ShortStr;
  IMAGE_SINGLE_ID# Number;
Begin
  IMAGE_SINGLE_ID#:= SP.TJ_WORK.GetObjectID(IMAGE_ID_SINGLE_NAME);
  
  For r In (
    Select ID, MOD_OBJ_NAME
    From SP.MODEL_OBJECTS
    Where PARENT_MOD_OBJ_ID=IMAGE_FOLDER_ID$
    And OBJ_ID=IMAGE_SINGLE_ID#
  )Loop
    rv#(r.MOD_OBJ_NAME):=r.ID;
  End Loop;
  
  Return rv#;
End;
--==============================================================================
-- ������� ������� ���� "������������� �����������" � ����� IMAGE_FOLDER_ID$
-- ��������� ������ ImageID2ID_IDX$ ���������� ID ��������� ��������������� 
-- �����������
Procedure CreateIMAGE_IDs(
IMAGE_FOLDER_ID$ In Number
, ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr)
As
  idx#  Varchar2(128);
  IP# SP.G.TMACRO_PARS;
  ID# Number;
  IMAGE_SINGLE_ID# Number;
Begin
  E#M:='';
  IMAGE_SINGLE_ID#:= SP.TJ_WORK.GetObjectID(IMAGE_ID_SINGLE_NAME);

  idx#:=ImageID2ID_IDX$.First;
  While Not idx# Is Null Loop
    If NVL(ImageID2ID_IDX$(idx#),'NONE')='NONE' Then
      IP#('PID'):=ID_(IMAGE_FOLDER_ID$);  
      IP#('SOURCE_SAPR'):=S_(SP.E3#TJ.SOURCE_SAPR);           
      IP#('SP3DTYPE'):=V_('IType','UnSupported');
      IP#('NAME'):=S_(idx#);
      E#M:=CreateOrUpdate
          (UsedObjectID$ => IMAGE_SINGLE_ID#, IP$ => IP#, ModObjID$ => ID#);
      Exit When Not E#M Is Null;
      ImageID2ID_IDX$(idx#):=ID#;
    End If;
    idx#:=ImageID2ID_IDX$.Next(idx#);
  End Loop;
  
  If Not E#M Is Null Then
    E#M:='������ �������� �������������� ����������� ['||idx#||']:'
    ||CHR(13)||CHR(10)||E#M;
    D(E#M,'Error In SP.E3#TJ.CreateIMAGE_IDs');
    raise_application_error(-20033,'Error In SP.E3#TJ.CreateIMAGE_IDs: '||E#M );   
  End If;
  
End CreateIMAGE_IDs;
--==============================================================================
--���������� ���������� ���������. ����� 1.
--������������ ����������� OID2OID_Device_IDX$ OID ���������� � HP_OID
--DEVICES$ - ���������� � ������ (����) ���������
--OID2OID_Device_IDX$ - ����������� OID ���������� � HP_OID
Procedure PrepareDevices1(DEVICES$ In Out NoCopy SP.G.TOBJECTS
, boIncludeTerminal$ In Boolean
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
, OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
, ImageID2ID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
)
As
  Type T_OIDS_AA Is Table Of Number Index By SP.V_MODEL_OBJECTS.OID%TYPE;
  Deleted_device_OIDs  T_OIDS_AA;              
  ii Binary_Integer;
  ImID# Varchar2(128); 
  E3SUBTYPE# Varchar2(128);             
  E3TYPE# Varchar2(128);              
  bo# Boolean;                                          
Begin                                                   
  ii:=DEVICES$.First;                                                     
  While ii is Not Null Loop
    E3SUBTYPE#:=DEVICES$(ii)('E3SUBTYPE').AsString;                      
    E3TYPE#:=DEVICES$(ii)('E3TYPE').AsString;                      
    If Not boIncludeTerminal$
       And E3SUBTYPE# In ('Terminal','TerminalBlock') Then
      --dprn(E3SUBTYPE#||' ['||DEVICES$(ii)('NAME').AsString||'] ��������.');
      Deleted_device_OIDs(DEVICES$(ii)('OID').AsString):=1;            
      DEVICES$.Delete(ii);
    ElsIf  E3TYPE# In ('Cable','WireOrCore') Then
      DEVICES$.Delete(ii);           
    Else                                  
      bo#:=ChangeObjParName(DEVICES$,ii,'PART_NUMBER','����������');     
      If E3TYPE# = 'Device' Then
        If DEVICES$(ii).Exists('HP_OID') Then                            
          OID2OID_Device_IDX$(DEVICES$(ii)('OID').AsString)
              :=DEVICES$(ii)('HP_OID').AsString;
        Else
          OID2OID_Device_IDX$(DEVICES$(ii)('OID').AsString)
              :=DEVICES$(ii)('OID').AsString;
        End If;                       
        If ChangeObjParName(DEVICES$, ii,'CABLE_END_LOCATION','�����') Then
          ChangeRefOID(DEVICES$, ii, '�����', OID2OID_IDX$);        
        End If;                                                      
        ChangeRefOID(DEVICES$,ii, '�������', OID2OID_IDX$);              
        If DEVICES$(ii).Exists('HP_Image_ID') Then        
          ImID#:=DEVICES$(ii)('HP_Image_ID').AsString;
          If Not ImID# Is Null And Not ImageID2ID_IDX$.Exists(ImID#) Then
            ImageID2ID_IDX$(ImID#):='NONE';    
          End If;                            
        End If;                               
      ElsIf E3TYPE# ='DevicePin' Then  
        If Deleted_device_OIDs.Exists(DEVICES$(ii)('POID').AsString) Then
          --������� ���� ������������ �������� 
          --dprn(E3TYPE#||' ['||DEVICES$(ii)('NAME').AsString||'] ��������.');    
          DEVICES$.Delete(ii);         
        End If;
      End If;                
    End If;                    
    ii:=DEVICES$.Next(ii);  
  End Loop;
End PrepareDevices1;
--==============================================================================
--� ������� OBJECTS$(ii) ���������-�-�������, ���� ����, �������� HP_OID  
Procedure Apply_HP_OID(OBJECTS$ In Out NoCopy SP.G.TOBJECTS, ii$ in Number)
As
  vstr# SP.V_MODEL_OBJECTS.OID%TYPE;
Begin
  --���� �������� HP_OID �����������, �� ������ �� ������                
  If Not OBJECTS$(ii$).Exists('HP_OID') Then Return;  End If;
                                       
  vstr#:=OBJECTS$(ii$)('HP_OID').AsString;
  
  --�������� HP_OID ������ �������, �.�. �� �����������          
  OBJECTS$(ii$).Delete('HP_OID'); 
                                       
  If  vstr# Is Null Then              
    Return;                               
  End If;                      
  --������ OID �� HP_OID             
  OBJECTS$(ii$)('OID'):=SP.TVALUE(SP.G.TOID, vstr#);          
         
End; 
--==============================================================================
--���������� DEVICE_FOLDER_ID ��� ���������� � ����������� �� �������
Function GetDeviceFolderID(Obj$ In Out NoCopy SP.G.TMACRO_PARS
,KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
,NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
) Return Number
As 
  ass# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;     
  kks# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;     
  rv# Number;
  em# Varchar2(4000);
Begin                                                             
    ass#:=Obj$('ASSIGNMENT').AsString;                      
    kks#:=SP.KKS.GetKKSIndex(ass#);               
    If KKS_2FOLDER_AA$.Exists(kks#) Then 
      rv#:=KKS_2FOLDER_AA$(kks#).DEVICE_FOLDER_ID;          
      If rv# Is Null Then             
        em#:='��� ������� ['||ass#||'] �� ������ ��������� �������������� ['
        ||SP.E3#TJ.DEVICE_SECTION_NAME
        ||']. ��������� ������� ��������� ���������.';
        D(em#,'Error In SP.E3#TJ.GetDeviceFolderID');
        rv#:=NO_KKS_2FOLDER$.DEVICE_FOLDER_ID;                             
        End If;                                       
    Else                                       
      D('������: ��� ���������� � ASSIGNMENT ['||ass#
      ||'] ������ �������������������� kks ['
      ||kks#||'] .','Warning In SP.E3#TJ.GetDeviceFolderID');
      rv#:=NO_KKS_2FOLDER$.DEVICE_FOLDER_ID;                                          
    End If;                                    
  Return rv#;                                 
End;
--==============================================================================
-- ������ Rel �� BRCM ImageID
Procedure ImID2Rel(Obj$ In Out NoCopy SP.G.TMACRO_PARS
, ImageID2ID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr)
Is                    
ImID# Varchar2(128); 
                              
Begin    
  If Obj$.Exists('HP_Image_ID') Then               
    ImID#:= Obj$('HP_Image_ID').AsString; 
    If Not ImID# Is Null Then
       Obj$('�� �����������'):=Rel_(ImageID2ID_IDX$(ImID#));
    End If;
  End If;
Exception When OTHERS Then
  E#M:='������ �������������� �������� ['||ImID#
  ||'] � ��� TRel ��� ���������� ��������� "�� �����������" ������� ['
  ||Obj$('NAME').AsString||']: '||CHR(13)||CHR(10)||SQLERRM;
  D(E#M,'Error In SP.E3#TJ.ImID2Rel');
  raise_application_error(-20033,'Error In SP.E3#TJ.ImID2Rel: '||E#M );   
End ImID2Rel;                    

--==============================================================================
--���������� ���������� ���������. ����� 2.
Procedure PrepareDevices2(OBJECTS$ In Out NoCopy SP.G.TOBJECTS
,KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
,NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
,ImageID2ID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_DevicePin_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
)
As
  ii Binary_Integer;
  E3Type# VARCHAR2(128);
  HP_OIDs# AA_ShortStr2Int;  
  boContinue Boolean;
  DEV_FOLDER_ID# Number; 
  s#  VARCHAR2(4000);
  E3RP_DevicePin# SP.G.TMACRO_PARS;  
Begin
  E3RP_DevicePin#:=E3RP_DevicePin;
ii:=OBJECTS$.First;                                                    
While ii is Not Null Loop                         
  If OBJECTS$(ii).Exists('PARENT') Then              
    OBJECTS$(ii).Delete('PARENT');            
  End If;                   
  E3Type#:=OBJECTS$(ii)('E3TYPE').AsString;
  
  If E3Type#='Device' Then   
  
    Apply_HP_OID(OBJECTS$,ii); --��������� HP_OID               
     DEV_FOLDER_ID#:=GetDeviceFolderID
      (OBJECTS$(ii), KKS_2FOLDER_AA$, NO_KKS_2FOLDER$);
                              
    DeleteE3Device(PID$ => DEV_FOLDER_ID#                      
      , DeviceName$ => OBJECTS$(ii)('NAME').AsString                 
      , DeviceOID$ => OBJECTS$(ii)('OID').AsString );    
                                       
    --Exit When Not EM Is Null;         
                                           
    OBJECTS$(ii)('SOURCE_SAPR'):=S_(SOURCE_SAPR);  
    
    If OBJECTS$(ii)('IsTerminal').AsBoolean Then    
      If OBJECTS$(ii)('IsTerminalBlock').AsBoolean Then
        OBJECTS$(ii)('PID'):= ID_(DEV_FOLDER_ID#);
        OBJECTS$(ii).Delete('POID');        
      Else                                  
        null;   --������ ��������� ��� ����        
      End If;
    Else
       OBJECTS$(ii)('PID'):= ID_(DEV_FOLDER_ID#);
       OBJECTS$(ii).Delete('POID');        
    End If;
    
    ImID2Rel(OBJECTS$(ii),ImageID2ID_IDX$);--��������� �������� '�� �����������'

  ElsIf  E3Type# In ('Cable','WireOrCore','Unknown') Then
    OBJECTS$.Delete(ii);      
  Else  --device Pin                
    boContinue:=true;   
    If OBJECTS$(ii).Exists('HP_OID') Then 
      s#:=OBJECTS$(ii)('HP_OID').AsString;                                 
      OID2OID_DevicePin_IDX$(OBJECTS$(ii)('OID').AsString):=s#;
      If  HP_OIDs#.Exists(s#) Then
        boContinue:=false;           
        OBJECTS$.Delete(ii);      
      Else              
        HP_OIDs#(s#):=1;
      End If;            
    Else                                    
      OID2OID_DevicePin_IDX$(OBJECTS$(ii)('OID').AsString)
          :=OBJECTS$(ii)('OID').AsString;           
    End If;  
    If boContinue=true Then
      Apply_HP_OID(OBJECTS$, ii);  --��������� HP_OID 
      s#:=OID2OID_Device_IDX$(OBJECTS$(ii)('POID').AsString);                   
      OBJECTS$(ii)('POID'):= SP.TVALUE(SP.G.TOID,s#);                           
      s#:=OBJECTS$(ii).First;                         
      while s# is not null Loop                   
        If Not E3RP_DevicePin#.Exists(s#) Then
          --��������� ��������� ������ �� ������ Tiny
          OBJECTS$(ii).Delete(s#);   
        End If;
        s#:=OBJECTS$(ii).Next(s#);
      End Loop;                                  
    End If;                                    
  End If;
  ii:=OBJECTS$.Next(ii);             
End Loop;
Exception When Others Then  
  E#M:='������ �������� ������ '||ii||' E3Type['||E3Type#
  ||'] � ��������� ���������� ������ TJ:'||chr(13)||chr(10)||SQLERRM ;   
  d(E#M,'Error In SP.E3#TJ.PrepareDevices2') ; 
  d(SP.TO_.STR(OBJECTS$(ii)),'Error In SP.E3#TJ.PrepareDevices2') ;   
End PrepareDevices2;
--==============================================================================
--���������� ���������� �������. 
Procedure PrepareCables(CABLES$ In Out NoCopy SP.G.TOBJECTS
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
, OID2OID_DevicePin_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
, KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
, NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
)
As
  ii# Binary_Integer;      
  kks# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  ass# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  CAB_FOLDER_ID# Number; 
  E3Type# VARCHAR2(128);                      
  s#  VARCHAR2(4000);
  OID2OID_Cable_IDX# SP.E3#TJ.AA_ShortStr2ShortStr;
  --����� ����������, ����������� � ������ TJ ��� ������� Cable
  TJP_Cable#  SP.G.TMACRO_PARS;
  --����� ����������, ����������� � ������ TJ ��� ������� Cable Wire
  TJP_CableWire# SP.G.TMACRO_PARS; 
Begin                        

--���������� OID2OID_Cable_IDX#
  ii#:=CABLES$.First;
  While Not ii# Is Null Loop
    If CABLES$(ii#)('E3TYPE').AsString='Cable' Then
      If CABLES$(ii#).Exists('HP_OID') Then
        OID2OID_Cable_IDX#(CABLES$(ii#)('OID').AsString)
                :=CABLES$(ii#)('HP_OID').AsString;
      Else 
        OID2OID_Cable_IDX#(CABLES$(ii#)('OID').AsString)
                :=CABLES$(ii#)('OID').AsString;
      End If;
    End If;
    ii#:=CABLES$.Next(ii#);
  End Loop;  

  TJP_CableWire#:=E3RP_CableWire;
  
  GetE3AllEditableParamForSingle
    ( ObjFullName$ => SP.TJ_WORK.SINAME_CABLE, Params$ => TJP_Cable#);
  TJP_Cable#('OID'):=SP.TVALUE(SP.G.TOID, '');
  TJP_Cable#('PID'):=SP.TVALUE(SP.G.TID, '');
  TJP_Cable#('E3TYPE'):=S_('');        
  TJP_Cable#('DOT_NET_TYPE'):=S_('');                       

  ii#:=CABLES$.First;                            
  While ii# is Not Null Loop                                
    E3Type#:=CABLES$(ii#)('E3TYPE').AsString;                                             
    If E3Type#='Cable' Then 
      Apply_HP_OID(CABLES$, ii#);  --��������� HP_OID   
      ass#:=CABLES$(ii#)('ASSIGNMENT').AsString;                      
      kks#:=SP.KKS.GetKKSIndex(ass#);            
      If KKS_2FOLDER_AA$.Exists(kks#) Then        
        CAB_FOLDER_ID#:=KKS_2FOLDER_AA$(kks#).CABLE_FOLDER_ID;
        If CAB_FOLDER_ID# Is Null Then
          CAB_FOLDER_ID#:=NO_KKS_2FOLDER$.CABLE_FOLDER_ID;                                          
          D('������: ��� ASSIGNMENT ['||ass#                
          ||'] ����������� ��������� ��������������['
          ||SP.E3#TJ.CABLE_SECTION_NAME||'] .'
          ,'Error In SP.E3#TJ.PrepareCables');
        End If;
      Else                                       
        D('������: ��� ASSIGNMENT ['||ass#
        ||'] ������ �������������������� kks ['
        ||kks#||'] .','Warning In SP.E3#TJ.PrepareCables');
        CAB_FOLDER_ID#:=NO_KKS_2FOLDER$.CABLE_FOLDER_ID;                                          
      End If;

      s#:=CABLES$(ii#).First;                       
      while s# is not null Loop                       
        If not TJP_Cable#.Exists(s#) Then
          CABLES$(ii#).Delete(s#);                  
        End If;  
        SP.E3#TJ.ChangeRefOID(CABLES$, ii#, '�������', OID2OID_IDX$);              
        s#:=CABLES$(ii#).Next(s#);     
      End Loop;                                              
      CABLES$(ii#)('SOURCE_SAPR'):=S_(SOURCE_SAPR); 
      CABLES$(ii#)('PID'):= ID_(CAB_FOLDER_ID#);
    ElsIf E3Type#='Unknown' Then 
      CABLES$.Delete(ii#);   
    Else --Cable Wires                              
      Apply_HP_OID(CABLES$,ii#);  --��������� HP_OID
      
      SP.E3#TJ.ChangeRefOID
          (CABLES$, ii#, 'REF_PIN_FIRST', OID2OID_DevicePin_IDX$);
      SP.E3#TJ.ChangeRefOID
          (CABLES$, ii#, 'REF_PIN_SECOND', OID2OID_DevicePin_IDX$); 
          
      s#:=OID2OID_Cable_IDX#(CABLES$(ii#)('POID').AsString);               
      CABLES$(ii#)('POID'):=SP.TVALUE(SP.G.TOID,s#);              
      s#:=CABLES$(ii#).First;                                              
      while s# is not null Loop
        If not TJP_CableWire#.Exists(s#) Then
          CABLES$(ii#).Delete(s#);
        End If;
        s#:=CABLES$(ii#).Next(s#);                     
      End Loop;                                        
    End If;                                     
    ii#:=CABLES$.Next(ii#);                                 
  End Loop;                                                                                
Exception When Others Then     
  E#M:=SQLERRM;
  d(E#M   ,'ERROR In SP.E3#TJ.PrepareCables') ;
  d(SP.TO_.STR(CABLES$(ii#)),'ERROR In SP.E3#TJ.PrepareCables') ; 
End;
--==============================================================================
-- ����������� ������ �������������� ������.
-- ���� �� ��� ������� �������� � �������������, �� 
-- ���������� ��������� �� ������.
-- � ��������� ������, ����� �� ������, ���������� Null.
Function VerifyFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
, KKS_2FOLDER_AA$ In T_KKS_2FOLDERS
) Return Varchar2
Is
  IP# SP.G.TMACRO_PARS;
  MOD_OBJ_NAME# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_agregate# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;                
  kks_system# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_subsystem# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  kks_code# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  ii# BINARY_INTEGER;
  esys# CLOB;   
  bo# Boolean;
  EM# Varchar2(4000);
begin
  EM#:='������� ';
  E#M:='';                                              
  ii#:=FUNC_SYSTEMS$.First;                                                       
  While Not ii# Is Null                                       
  Loop                                                 
  IP#:=FUNC_SYSTEMS$(ii#);                      
    MOD_OBJ_NAME#:=IP#('NAME').AsString;                       
  
    bo# := SP.KKS.SplitLongKKS(kks$ =>MOD_OBJ_NAME# , sys_num$ => kks_agregate#      
    , sys_code$ => kks_system#, subsys_num$ => kks_subsystem#);
                                                                    
    kks_code#:=kks_agregate#||kks_system#||kks_subsystem#;               
                                                             
    If Not KKS_2FOLDER_AA$.Exists(kks_code#) Then        
      If esys# Is Null Then                                  
        esys#:=kks_code#;
        D_Long(E#M,EM#||kks_code#,'Info SP.E3#TJ.VerifyFuncSystems');
      Else            
        DBMS_LOB.WRITEAPPEND(esys#,2, ', ');      
        DBMS_LOB.WRITEAPPEND(esys#, length(kks_code#), kks_code#);
        D_Long(E#M,', '||kks_code#,'Info SP.E3#TJ.VerifyFuncSystems');
      End If; 
    End If;  
    
    ii#:=FUNC_SYSTEMS$.Next(ii#);                      
  End Loop; 
                                
  If Not esys# Is Null Then         
   IF length(esys#) > 3500 Then                    
     EM#:=SUBSTR(esys#,1,3500)||'... ' ;             
   Else                            
     EM#:=esys#;                                
   End If;                                              
   
   EM#:='������� '||EM#
   ||' �� ���������������� � KKS-�������������� ��� ������ [%1].'; 
   
   D_Long(E#M,' �� ���������������� � KKS-��������������.'
   ,'Info SP.E3#TJ.VerifyFuncSystems');
   D(E#M,'Error In SP.E3#TJ.VerifyFuncSystems');
  End If;                                                        
 return E#M;               
End VerifyFuncSystems; 
--==============================================================================
-- ��������/�������������� �������������� ������.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdateFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
,SYSTEM_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
) Return Varchar2
Is
  FUNC_SYSTEM_SINGLE_ID# Number;
  IP# SP.G.TMACRO_PARS;
  ID# Number;                             
  OID# SP.V_MODEL_OBJECTS.OID%TYPE;                   
  OLD_OID# SP.V_MODEL_OBJECTS.OID%TYPE;                        
  MOD_OBJ_NAME# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  ii# BINARY_INTEGER;                                
  SystemEtalonPars# SP.G.TMACRO_PARS;                  
      
Begin 
  E#M:='';
  FUNC_SYSTEM_SINGLE_ID#:=
          SP.TJ_WORK.GetObjectID(SP.TJ_WORK.SINAME_FUNCTIONAL_SYSTEM);
  SystemEtalonPars#:=SP.E3#TJ.Get_SystemSingleParams;
  SystemEtalonPars#('OID'):=SP.TVALUE(SP.G.TOID,'');
  SystemEtalonPars#.Delete('PARENT');   
                                              
  ii#:=FUNC_SYSTEMS$.First;                     
  While Not ii# Is Null                
  Loop                                                 
    IP#:=FUNC_SYSTEMS$(ii#); 
    SP.E3#TJ.REMOVE_MACRO_PARS(Etalon$ => SystemEtalonPars#, From$ => IP#); 
  
    Begin                                       
      OID#:=IP#('OID').AsString;                                             
      MOD_OBJ_NAME#:=IP#('NAME').AsString; 
                                                         
      SELECT vo2.ID, vo2.OID  Into ID#, OLD_OID#
      FROM SP.V_MODEL_OBJECTS vo2
      WHERE vo2.PARENT_MOD_OBJ_ID=SYSTEM_FOLDER_ID$                 
      AND vo2.MOD_OBJ_NAME=MOD_OBJ_NAME#                 
      ;                                                        
                                                               
      If Not OLD_OID# Is Null Then                       
                                                     
        OID2OID_IDX$(OID#):=OLD_OID#;
        
        SP.E3#TJ.UnMarkToDelete(ModObjID$ => ID#);  
    
        GOTO GoNext;        
      Else                          
        OID2OID_IDX$(OID#):=OID#;                
      End If;
      
    Exception When NO_DATA_FOUND Then                           
        OID2OID_IDX$(OID#):=OID#;           
    End;                                   
     
    IP#('PID'):=ID_(SYSTEM_FOLDER_ID$);  
    IP#('SOURCE_SAPR'):=S_(SP.E3#TJ.SOURCE_SAPR);           
    IP#('SP3DTYPE'):=V_('IType','UnSupported');
    E#M:=SP.E3#TJ.CreateOrUpdate(IP#,FUNC_SYSTEM_SINGLE_ID#);  
    Exit When Not E#M Is Null;      
    <<GoNext>>                                    
    ii#:=FUNC_SYSTEMS$.Next(ii#);     
  End Loop;
  Return E#M;
End CreateOrUpdateFuncSystems; 
--==============================================================================
-- ��������/�������������� ����.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdateLocations(LOCATIONS$ In Out NoCopy SP.G.TOBJECTS
,LOCATION_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
) Return Varchar2 
Is
  IP# SP.G.TMACRO_PARS;
  LOCATION_SINGLE_ID# Number;
  ID# Number;                             
  OID# SP.V_MODEL_OBJECTS.OID%TYPE;                   
  OLD_OID# SP.V_MODEL_OBJECTS.OID%TYPE;                        
  MOD_OBJ_NAME# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  ii# BINARY_INTEGER;
  LocationEtalonPars# SP.G.TMACRO_PARS;                  
begin         
  E#M:='';
  LOCATION_SINGLE_ID#:=SP.TJ_WORK.GetObjectID('TJ.singles.�����');
  LocationEtalonPars#:=SP.E3#TJ.Get_Locati�nSingleParams;
  LocationEtalonPars#('OID'):=SP.TVALUE(SP.G.TOID,'');
  LocationEtalonPars#.Delete('PARENT');   
          
ii#:=LOCATIONS$.First;                   
While Not ii# Is Null                  
Loop                                                 
IP#:=LOCATIONS$(ii#);   
SP.E3#TJ.REMOVE_MACRO_PARS(Etalon$ => LocationEtalonPars#, From$ => IP#); 
                    
Begin                                             
  OID#:=IP#('OID').AsString;                                             
  MOD_OBJ_NAME#:=IP#('NAME').AsString; 
                                                     
  SELECT vo2.ID, vo2.OID  Into ID#, OLD_OID#
  FROM SP.V_MODEL_OBJECTS vo2
  WHERE vo2.PARENT_MOD_OBJ_ID=LOCATION_FOLDER_ID$      
  AND vo2.MOD_OBJ_NAME=MOD_OBJ_NAME#                 
  ;                                                        
                                                           
  If Not OLD_OID# Is Null Then                       
    
    OID2OID_IDX$(OID#):=OLD_OID#;
    
    SP.E3#TJ.UnMarkToDelete(ModObjID$ => ID#);

    GOTO GoNext;        
  Else                          
    OID2OID_IDX$(OID#):=OID#;                
  End If;                                     
  
Exception When NO_DATA_FOUND Then                           
    OID2OID_IDX$(OID#):=OID#;           
End;                              
                   
  IP#('PID'):=ID_(LOCATION_FOLDER_ID$);  
  IP#('SOURCE_SAPR'):=S_(SP.E3#TJ.SOURCE_SAPR);        
  IP#('SP3DTYPE'):=V_('IType','UnSupported');   
  E#M:=SP.E3#TJ.CreateOrUpdate(IP#,LOCATION_SINGLE_ID#);  
  Exit When Not E#M Is Null;      
  <<GoNext>>                    
  ii#:=LOCATIONS$.Next(ii#);     
End Loop; 
  Return E#M;
End CreateOrUpdateLocations; 
--==============================================================================
-- ��������� ��� �������� ���������� PROPS ���� �������� ������ ���� 
-- TJ.singles.�����, ���������� ������ WorkID$
Procedure UpdLocationProps(WorkID$ In Number)
As
  SysName# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  
  --������������� ������: ����� �������������� ������������ � �� ID.
  DEVs# SP.TJ_WORK.AA_ObjName2ID;
  pars# SP.G.TMACRO_PARS;
Begin

  --������ ���� ���������: ��� -> ID
  DEVs#:=SP.TJ_WORK.Get#DEVICES(WorkID$);

  for Lo1 in
  (
    SELECT mo.ID as LOCATION_ID, mo.MOD_OBJ_NAME As LOCATION_NAME
    --, mo.MODEL_ID, mo.OBJ_ID
    --, mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    --, mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
    FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC( RootModObjID$ => WorkID$
    , ObjectID$ => SP.TJ_WORK.Get_LOCATION_OBJECT_ID )) mo  
  )
  Loop
    --������� ��� ������� � ����������� ������� '='
    SysName#:='='||REPLACE(Lo1.LOCATION_NAME,'+');
    If DEVs#.Exists(SysName#) Then
      pars#('PROPS'):=REL_(ID =>DEVs#(SysName#));
      SP.MO.UPDATE_OBJECT_PARS(pars#, Lo1.LOCATION_ID);
    End If;
  End Loop;  --Locations
End UpdLocationProps;
--==============================================================================
-- ��������/�������������� ��������������� �����������.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdate_IMAGE_IDs(
ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr
,IMAGE_FOLDER_ID$ Number
)Return Varchar2
Is
  ImageIdx# Varchar2(128); 
  IP# SP.G.TMACRO_PARS;
  IMAGE_SINGLE_ID# Number;
  ID# Number;
  cnt# BINARY_INTEGER;
Begin
  E#M:='';
  IMAGE_SINGLE_ID#:=
      SP.TJ_WORK.GetObjectID('TJ.singles.������������� �����������');

  IP#('Connector'):= S_(''); 
  IP#('������'):= V_('NullInteger', '');
  IP#('�������'):= V_('NullInteger', '');
  IP#('��������'):= S_('');
  IP#('����������'):= S_('');   
  IP#('PID'):=ID_(IMAGE_FOLDER_ID$);
  IP#('SOURCE_SAPR'):=S_(SP.E3#TJ.SOURCE_SAPR);  

  ImageIdx#:=ImageID2ID_IDX$.First;
  cnt#:=0;
  While Not ImageIdx# Is Null
  Loop
    IP#('NAME'):= S_(ImageIdx#);
    
    E#M:=CreateOrUpdate(IMAGE_SINGLE_ID#,IP#,ID#);  
    Exit When Not E#M Is Null;      

    ImageID2ID_IDX$(ImageIdx#):=to_char(ID#);
    cnt#:=cnt#+1;
    ImageIdx#:=ImageID2ID_IDX$.Next(ImageIdx#);   
  End Loop;

  D('���������� ��������������� ����������� '||to_char(cnt#)||'.'
  , 'Info SP.E3#TJ.CreateOrUpdate_IMAGE_IDs');
  
  Return E#M;
End CreateOrUpdate_IMAGE_IDs;
--==============================================================================
--##############################################################################
--==============================================================================
--���������� ID ������� ���� ��������, ��������������� �������� Zuken e3.series,
-- ��� �� ����������, ������, ������������ ����������, ����������� � �����.
-- ������������� (2020-07-29) ����� �������� ������ ������ � ����������.
Function GetAllDeviceObjIDs Return T_ObjectIDs pipelined
Is
  re R_ObjectID;
Begin
  re.OBJECT_ID:=SP.TJ_WORK.Get_DEVICE_OBJECT_ID;
  Pipe row (re);

  re.OBJECT_ID:=SP.TJ_WORK.Get_CABLE_OBJECT_ID;
  Pipe row (re);
End;
--==============================================================================
BEGIN
  null;
END E3#TJ;
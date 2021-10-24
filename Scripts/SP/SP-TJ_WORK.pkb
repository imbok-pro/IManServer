CREATE OR REPLACE PACKAGE BODY SP.TJ_WORK
as
-- Процедуры общего назначения для работы с объектом "РАБОТА" и подчинёнными
-- ему объектами
-- File: SP-TJ_WORK.pkb
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-16
-- update 2019-09-17 2019-10-23:2019-10-30 2020-07-03 2020-12-16 
--        2021-02-12:2021-02-17

-- Текущий узел типа РАБОТА.
CUR$WORK SP.MODEL_OBJECTS%ROWTYPE;
E#M VARCHAR2(4000);

--ID сингла, обозначающего кабель в модели TJ
CABLE_OBJECT_ID Number;
--ID сингла, обозначающего элемент отношения CableSegment в модели TJ
CABLE_SEGMENT_OBJECT_ID NUMBER;
CABLE_WIRE_OBJECT_ID Number;
--ID сингла, обозначающего участок кабельной трассы в модели TJ
CWS_OBJECT_ID NUMBER;
--ID сингла, обозначающего устройство в модели TJ
DEVICE_OBJECT_ID Number;
GENERYC_SYSTEM_OBJECT_ID Number;
--ID сингла, обозначающего место в модели TJ
LOCATION_OBJECT_ID Number;
--ID сингла, обозначающего лоток в модели TJ
TRAY_OBJECT_ID NUMBER;

--ID параметра 'ORDINAL' объекта CABLE_SEGMENT
PARID_CABLE_SEGMENT_ORDINAL_ Number;
--ID параметра 'ZMIN_ZMAX_LENGTH' объекта CABLE_SEGMENT
PARID_CABLE_SEGMENT_ZMM_LEN_ Number;
--ID параметра 'REF_SHELF' объекта CABLE_SEGMENT
PARID_CABLE_SEGMENT_SHELF_ Number;
--ID параметра 'REF_CABLE' объекта CABLE_SEGMENT
PARID_CABLE_SEGMENT_CABLE_ Number;
--==============================================================================
--Лог длинных строк
--Если строки короткие, то  делает их конкатенацию
--Если строки длинные, то записывает в лог начало (mess1$)
--а затем заменяет начало хвостом (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 )
As
Begin
  If NVL(LENGTH(mess1$),0)+NVL(LENGTH(mess2$),0) < 4000 Then
    mess1$:=mess1$||mess2$;
    Return;
  End If;
  
  D(mess1$,Tag$);
  mess1$:='[Продолжение...]'||CHR(10)||CHR(13)||mess2$;
  
  Return;
End;
--==============================================================================
--Возвращает ID объекта "РАБОТА"
Function WorkID Return Number
As
Begin
  Return CUR$WORK.ID;
End WorkID;
--==============================================================================
--Возвращает ID объекта каталога по его полному имени
Function GetObjectID(ObjFullName$ In Varchar2) Return Number
Is
  rv# Number;
Begin
  
  Select ob.ID Into rv#  
    From SP.V_OBJECTS ob               
    Where ob.FULL_NAME=ObjFullName$
    ;

  return rv#;
Exception When NO_DATA_FOUND Then
  raise_application_error(-20033
  , 'Объект каталога ['||ObjFullName$||'] не найден.');    
End GetObjectID;

--==============================================================================
--Возвращает ID объекта модели 
Function GetModelObjectID(
MODEL_ID$ In Number  --ID модели
, OBJ_ID$ In Number  --ID объекта каталога
, ModObjName$ In Varchar2  -- Имя объекта модели
) 
Return Number
Is
  rv# Number;
Begin
  
  SELECT ID Into rv#
  From SP.MODEL_OBJECTS
  Where MODEL_ID=MODEL_ID$
  And MOD_OBJ_NAME=ModObjName$
  And OBJ_ID=OBJ_ID$
  ;
  return rv#;
Exception When NO_DATA_FOUND Then
  Return Null;    
End GetModelObjectID;

--==============================================================================
--Возвращает ID устройства модели по его имени (KKS) или Null
Function GetDeviceID(
MODEL_ID$ In Number  --ID модели
, DeviceName$ In Varchar2  -- Имя (KKS) устройства
) 
Return Number
Is
Begin
  Return GetModelObjectID(MODEL_ID$, Get_DEVICE_OBJECT_ID, DeviceName$);  
End GetDeviceID;
--==============================================================================
--Возвращает ID параметра объекта каталога по ID объекта каталога и 
--его (параметра) имени.
Function GetObjectParID(ObjectID$ In Number, ParName$ In Varchar2)
Return Number
As
  rv# Number;
Begin
  
  Select ID Into rv#
  From SP.OBJECT_PAR_S
  Where OBJ_ID=ObjectID$
  And NAME=ParName$
  ;
  
  Return rv#;
End GetObjectParID;

--==============================================================================
--Возвращает ID параметра объекта каталога по полному имени объекта каталога и 
--его (параметра) имени.
Function GetObjectParID(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return Number
As
Begin
  Return GetObjectParID(ObjectID$ => GetObjectID(ObjFullName$ => ObjFullName$)
  , ParName$ => ParName$);
End GetObjectParID;

--==============================================================================
--Возвращает ключевую информацию о параметре объекта каталога 
--(i.e. ID объекта каталога и ID параметра объекта каталога) 
--по полному имени объекта каталога и его (параметра) имени.
Function GetObjParKey(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return R_ObjParKey
As
  rv# R_ObjParKey;
Begin
  rv#.OBJ_ID := GetObjectID(ObjFullName$ => ObjFullName$);
  rv#.OBJ_PAR_ID := GetObjectParID
    (ObjectID$ => rv#.OBJ_ID , ParName$ => ParName$);
  Return rv#;
End GetObjParKey;

--==============================================================================
-- Быстро возвращает GENERYC_SYSTEM_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_GENERYC_SYSTEM_OBJECT_ID Return Number
As
Begin
  If GENERYC_SYSTEM_OBJECT_ID Is Null Then
    GENERYC_SYSTEM_OBJECT_ID:=GetObjectID(SINAME_GENERYC_SYSTEM);
  End If;
  Return GENERYC_SYSTEM_OBJECT_ID;
End;
--==============================================================================
--Быстро возвращает ID параметра 'ZMIN_ZMAX_LENGTH' объекта CABLE_SEGMENT 
Function Get_PARID_ZMINMAX_LENGTH Return Number
Is
Begin
  If PARID_CABLE_SEGMENT_ZMM_LEN_ Is Null Then
    PARID_CABLE_SEGMENT_ZMM_LEN_:= 
                GetObjectParID( ObjectID$ => Get_CABLE_SEGMENT_OBJECT_ID
                                , ParName$ => 'ZMIN_ZMAX_LENGTH');
  End If;
  Return PARID_CABLE_SEGMENT_ZMM_LEN_;
End Get_PARID_ZMINMAX_LENGTH;  
--==============================================================================
--Быстро возвращает ID параметра 'ORDINAL' объекта CABLE_SEGMENT 
Function Get_PARID_ORDINAL Return Number
Is
Begin
  If PARID_CABLE_SEGMENT_ORDINAL_ Is Null Then
    PARID_CABLE_SEGMENT_ORDINAL_:= 
                GetObjectParID( ObjectID$ => Get_CABLE_SEGMENT_OBJECT_ID
                                , ParName$ => 'ORDINAL');
  End If;
  Return PARID_CABLE_SEGMENT_ORDINAL_;
End Get_PARID_ORDINAL;  
--==============================================================================
--Быстро возвращает ID параметра 'REF_CABLE' объекта CABLE_SEGMENT 
Function Get_PARID_REF_CABLE Return Number
Is
Begin
  If PARID_CABLE_SEGMENT_CABLE_ Is Null Then
    PARID_CABLE_SEGMENT_CABLE_:= 
                GetObjectParID( ObjectID$ => Get_CABLE_SEGMENT_OBJECT_ID
                                , ParName$ => 'REF_CABLE');
  End If;
  Return PARID_CABLE_SEGMENT_CABLE_;
End Get_PARID_REF_CABLE;  
--==============================================================================
--Быстро возвращает ID параметра 'REF_SHELF' объекта CABLE_SEGMENT 
Function Get_PARID_REF_SHELF Return Number
Is
Begin
  If PARID_CABLE_SEGMENT_SHELF_ Is Null Then
    PARID_CABLE_SEGMENT_SHELF_:= 
                GetObjectParID( ObjectID$ => Get_CABLE_SEGMENT_OBJECT_ID
                                , ParName$ => 'REF_SHELF');
  End If;
  Return PARID_CABLE_SEGMENT_SHELF_;
End Get_PARID_REF_SHELF;  
--==============================================================================
-- Быстро возвращает CABLE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_OBJECT_ID Return Number
As
Begin
  If CABLE_OBJECT_ID Is Null Then
    CABLE_OBJECT_ID:=GetObjectID(SINAME_CABLE);
  End If;
  Return CABLE_OBJECT_ID;
End;
--==============================================================================
-- Быстро возвращает CABLE_WIRE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_WIRE_OBJECT_ID Return Number
As
Begin
  If CABLE_WIRE_OBJECT_ID Is Null Then
    CABLE_WIRE_OBJECT_ID:=GetObjectID(SINAME_CABLE_WIRE);
  End If;
  Return CABLE_WIRE_OBJECT_ID;
End Get_CABLE_WIRE_OBJECT_ID;

--==============================================================================
-- Быстро возвращает DEVICE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_DEVICE_OBJECT_ID Return Number
As
Begin
  If DEVICE_OBJECT_ID Is Null Then
    DEVICE_OBJECT_ID:=GetObjectID(SINAME_DEVICE);
  End If;
  Return DEVICE_OBJECT_ID;
End;
--==============================================================================
-- Быстро возвращает LOCATION_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_LOCATION_OBJECT_ID Return Number
As
Begin
  If LOCATION_OBJECT_ID Is Null Then
    LOCATION_OBJECT_ID:=GetObjectID(SINAME_LOCATION);
  End If;
  Return LOCATION_OBJECT_ID;
End;

--==============================================================================
-- Быстро возвращает TRAY_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_TRAY_OBJECT_ID Return Number
As
Begin
  If TRAY_OBJECT_ID Is Null Then
    TRAY_OBJECT_ID:=GetObjectID(SINAME_TRAY);
  End If;
  Return TRAY_OBJECT_ID;
End;

--==============================================================================
-- Быстро возвращает CWS_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CWS_OBJECT_ID Return Number
As
Begin
  If CWS_OBJECT_ID Is Null Then
    CWS_OBJECT_ID:=GetObjectID(SINAME_CWS);
  End If;
  Return CWS_OBJECT_ID;
End;

--==============================================================================
-- Быстро возвращает CABLE_SEGMENT_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_SEGMENT_OBJECT_ID Return Number
As
Begin
  If CABLE_SEGMENT_OBJECT_ID Is Null Then
    CABLE_SEGMENT_OBJECT_ID:=GetObjectID(SINAME_CABLE_SEGMENT);
  End If;
  Return CABLE_SEGMENT_OBJECT_ID;
End;

--==============================================================================
--очистка переменных пакета
Procedure ClearPackage
As
Begin
  Null;
End;
--==============================================================================
--Устанавливает Текущую работу.
--Если WorkID$ не есть объект типа работа, то возникает прерывание.
Procedure SetCurWork(WorkID$ In Number)
As
  ro# SP.MODEL_OBJECTS%ROWTYPE;
Begin
  
  If CUR$WORK.ID=WorkID$ Then Return; End If;
  
  SELECT * Into ro#
  FROM SP.MODEL_OBJECTS
  Where ID=WorkID$
  ;
  
  If NVL(ro#.OBJ_ID,-1) <> GetObjectID(SINAME_WORK) Then
    E#M:='Значение парамтера WorkID$ ['||to_char(WorkID$)
    ||'] Name ['||ro#.MOD_OBJ_NAME||'] не есть объект типа ['
    ||SINAME_WORK||']';
    raise_application_error(-20033, E#M);    
  End If;
  
  CUR$WORK:=ro#;
  ClearPackage;
  Return;
  
Exception 
  When NO_DATA_FOUND Then
    E#M:='Значение парамтера WorkID$ ['||to_char(WorkID$)
    ||'] не найден в модели и не есть ID какого-либо объекта';
    raise_application_error(-20033, E#M);
  
  When OTHERS Then
    raise;
End SetCurWork;
--==============================================================================
--Возвращает ID дочернего объекта или Null
Function GetChildByName(ParentID$ In Number, ChildName$ In Varchar2)
Return Number
Is
  rv# Number;
Begin
  
  SELECT ID Into rv# From SP.MODEL_OBJECTS
  Where PARENT_MOD_OBJ_ID=ParentID$
  And MOD_OBJ_NAME=ChildName$
  ;
  
  Return rv#;
Exception When No_data_Found Then
  Return rv#;
End GetChildByName;
--==============================================================================
--Возвращает ID дочернего объекта или Null
Function GetChildByOID(ParentID$ In Number, ChildOID$ In Varchar2)
Return Number
Is
  rv# Number;
Begin
  
  SELECT ID Into rv# From SP.MODEL_OBJECTS
  Where PARENT_MOD_OBJ_ID=ParentID$
  And OID=ChildOID$
  ;
  
  Return rv#;
Exception When No_data_Found Then
  Return rv#;
End GetChildByOID;

--==============================================================================
--Достаёт всех потомков объекта RootModObjID$, имеющих OBJ_ID = ObjectID$
Function V_MODEL_OBJECTS_DESC(RootModObjID$ In Number, ObjectID$ In Number) 
Return T_MODEL_OBJECTS Pipelined
As
Begin
  For r In (
    Select * 
    From SP.MODEL_OBJECTS mo 

    Where mo.OBJ_ID=ObjectID$
    Start With mo.ID=RootModObjID$  
    Connect by Prior mo.ID=mo.PARENT_MOD_OBJ_ID
  )Loop
    pipe row(r);
  End Loop;
End;
--==============================================================================
-- Достаёт все псевдообъекты, подчинённые работе WorkID$
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
Function V_#PDO(WorkID$ In Number) Return T_MODEL_OBJECTS Pipelined
As
Begin
  For r In (
      SELECT mo.*
    -- mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
    -- , mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    -- , mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
      FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(RootModObjID$ => WorkID$
      , ObjectID$ => SP.TJ_WORK.Get_DEVICE_OBJECT_ID )) mo
  )Loop
    --Параметр POSITION содержит подстроку '#PDO'
    If INSTR(SP.GETMPAR_S(r.ID,'POSITION'),'#PDO')> 0 Then
      pipe row(r);
    End If;
  End Loop;
End;
--==============================================================================
-- Возвращает ассоциативный массив всех псевдообъектов (Имена и ID), 
-- подчинённых работе WorkID$. 
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
Function Get#PDOs(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID
As
  Type AA_ObjNameCount Is Table Of BINARY_INTEGER 
    Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  errm# AA_ObjNameCount; 
  idx# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  rv AA_ObjName2ID;
  EM# Varchar2(400);
Begin
  For pdo In (
      SELECT mo.ID  As PDO_ID , mo.MOD_OBJ_NAME as PDO_NAME
    -- mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
    -- , mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    -- , mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
      FROM TABLE(SP.TJ_WORK.V_#PDO(WorkID$)) mo
  )Loop
    If Not rv.Exists(pdo.PDO_NAME) Then
      rv(pdo.PDO_NAME):=pdo.PDO_ID;
    ElsIf errm#.Exists(pdo.PDO_NAME) Then
      errm#(pdo.PDO_NAME):=errm#(pdo.PDO_NAME)+1;
    Else  
      errm#(pdo.PDO_NAME):=2;
    End If;
  End Loop;
  
  If errm#.Count > 0 Then
    -- Выкидываем из rv повторяющиеся объекты. Печатаем сообщения о найденных
    -- повторяющихся псевдообъектах в ЛОГ.
    E#M:='';
    EM#:='Имеются псевдообъекты в идентичными именами:'||CHR(13)||CHR(10);
    D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#PDO');  
    idx#:=errm#.First;
    While Not idx# Is Null Loop
      EM#:=idx#||' - '||to_char(errm#(idx#))||'шт. ;'||CHR(13)||CHR(10);
      D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#PDO');
      rv.Delete(idx#);
      idx#:=errm#.Next(idx#);
    End Loop;
    EM#:='В проекте Zuken e3.series следует избавиться от повторяющихся '
      ||'псевдообъектов и синхронизоваться повторно.';
      D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#PDO');
    D(E#M, 'Error In SP.TJ_WORK.Get#PDO');
  End If;
  return rv;
End Get#PDOs;
--==============================================================================
-- Возвращает ассоциативный массив всех устройств (Имена и ID), 
-- подчинённых работе WorkID$. 
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
Function Get#DEVICES(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID
As
  Type AA_ObjNameCount Is Table Of BINARY_INTEGER 
    Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  errm# AA_ObjNameCount; 
  idx# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  rv AA_ObjName2ID;
  EM# Varchar2(400);
Begin
  For dev In (
      SELECT mo.ID  As DEVICE_ID , mo.MOD_OBJ_NAME as DEVICE_NAME
    -- mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
    -- , mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    -- , mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
      FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(RootModObjID$ => WorkID$
      , ObjectID$ => SP.TJ_WORK.Get_DEVICE_OBJECT_ID )) mo
  )Loop
    If Not rv.Exists(dev.DEVICE_NAME) Then
      rv(dev.DEVICE_NAME):=dev.DEVICE_ID;
    ElsIf errm#.Exists(dev.DEVICE_NAME) Then
      errm#(dev.DEVICE_NAME):=errm#(dev.DEVICE_NAME)+1;
    Else  
      errm#(dev.DEVICE_NAME):=2;
    End If;
  End Loop;
  
  If errm#.Count > 0 Then
    -- Выкидываем из rv повторяющиеся объекты. Печатаем сообщения о найденных
    -- повторяющихся псевдообъектах в ЛОГ.
    E#M:='';
    EM#:='Имеются устройства в идентичными именами:'||CHR(13)||CHR(10);
    D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#DEVICES');  
    idx#:=errm#.First;
    While Not idx# Is Null Loop
      EM#:=idx#||' - '||to_char(errm#(idx#))||'шт. ;'||CHR(13)||CHR(10);
      D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#DEVICES');
      rv.Delete(idx#);
      idx#:=errm#.Next(idx#);
    End Loop;
    EM#:='В проекте Zuken e3.series следует избавиться от устройств с '
      ||'повторяющимися именами (KKS) и синхронизоваться повторно.';
      D_Long(E#M,EM#,'Error In SP.TJ_WORK.Get#DEVICES');
    D(E#M, 'Error In SP.TJ_WORK.Get#DEVICES');
  End If;
  return rv;
End Get#DEVICES;
--==============================================================================
-- Заполняет индекс 'MOD_OBJ_NAME'->'RID' объектов-потомков RootModObjID$,
-- тип которых есть ObjectID$ 
Procedure Get_MODEL_OBJECT_IDX(RootModObjID$ In Number, ObjectID$ In Number,
  idx$ In Out Nocopy AA_ObjName2ID) 
As
Begin
  For r In (Select * 
    From Table(V_MODEL_OBJECTS_DESC(RootModObjID$, ObjectID$))
  )Loop
    idx$(r.MOD_OBJ_NAME):=r.ID;
  End Loop;
End;
--==============================================================================
-- Очищает разделы 'REFERENCES' и подразделы 'ЛОТКИ' и 'ТРУБЫ' 
-- раздела 'КАБЕЛЬНЫЕ КОНСТРУКЦИИ', относящихся к работе WORK_ID$.
Procedure Cable_Constructions_Clear(WORK_ID$ In Number)
Is
  WORK_OBJECT_ID# Number;
  REFERENCES_MOD_OBJ_ID# Number;
  CABLE_CONSTR_MOD_OBJ_ID# Number;
  TRAYS_MOD_OBJ_ID# Number;
  TUBES_MOD_OBJ_ID# Number;
  
Begin

  Begin
    Select OBJ_ID Into WORK_OBJECT_ID#
    From SP.MODEL_OBJECTS
    Where ID=WORK_ID$
    ;
    If NVL(WORK_OBJECT_ID#, -1) <> GetObjectID(SINAME_WORK) Then
      E#M:='Объект модели с ID ['||to_char(WORK_ID$)||'] не есть работа.';
      raise_application_error(-20033, E#M);    
    End If;
  Exception When NO_DATA_FOUND Then
    E#M:='Объект модели с ID ['||to_char(WORK_ID$)||'] не существует.';
    raise_application_error(-20033, E#M);    
  End;  

  --References
  Begin
    Select ID Into REFERENCES_MOD_OBJ_ID#
    From SP.MODEL_OBJECTS
    Where PARENT_MOD_OBJ_ID=WORK_ID$
    And MOD_OBJ_NAME=REFERENCES_NAME
    ;

    Delete From SP.MODEL_OBJECTS
    Where PARENT_MOD_OBJ_ID=REFERENCES_MOD_OBJ_ID#
    ;
    
  Exception When NO_DATA_FOUND Then
    Null;
  End;  

  --Cable Constructions
  Begin
    Select ID Into CABLE_CONSTR_MOD_OBJ_ID#
    From SP.MODEL_OBJECTS
    Where PARENT_MOD_OBJ_ID=WORK_ID$
    And MOD_OBJ_NAME=CABLE_CONSTRUCTIONS_NAME
    ;
    
    --Trays
    Begin
      Select ID Into TRAYS_MOD_OBJ_ID#
      From SP.MODEL_OBJECTS
      Where PARENT_MOD_OBJ_ID=CABLE_CONSTR_MOD_OBJ_ID#
      And MOD_OBJ_NAME=TRAYS_NAME
      ;
      
      Delete From SP.MODEL_OBJECTS
      Where PARENT_MOD_OBJ_ID=TRAYS_MOD_OBJ_ID#
      ;
    Exception When NO_DATA_FOUND Then
      Null;
    End;

    --Tubes
    Begin
      Select ID Into TUBES_MOD_OBJ_ID#
      From SP.MODEL_OBJECTS
      Where PARENT_MOD_OBJ_ID=CABLE_CONSTR_MOD_OBJ_ID#
      And MOD_OBJ_NAME=TUBES_NAME
      ;
      
      Delete From SP.MODEL_OBJECTS
      Where PARENT_MOD_OBJ_ID=TUBES_MOD_OBJ_ID#
      ;
    Exception When NO_DATA_FOUND Then
      Null;
    End;

  Exception When NO_DATA_FOUND Then
    Null;
  End;  

End Cable_Constructions_Clear;
--==============================================================================
--Для работы возвращает все сегменты кабельных трасс
Function V_CABLE_WAYS(WORK_ID$ In Number) Return T_CABLE_WAYS Pipelined
Is
  rv# R_CABLE_WAY_SEGMENT;
  CWS_NAME# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  CWS_PARENT_NAME# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  CWS_PARENT_OBJ_ID# SP.MODEL_OBJECTS.OBJ_ID%TYPE;
Begin
  For d1 In (
    SELECT mop1.N As ORDINAL 
    , mo.MOD_OBJ_NAME As CABLE_NAME
    , mop2.N As LENGTH, mop2.X as Z_MIN, mop2.Y as Z_MAX
    , mop3.N As CABLE_ID
    , mop4.N As CWS_ID  --CABLE_WAY Segment ID
    --mo.ID
    --, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
    --, mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
    --, mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
    FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(
    RootModObjID$ => WORK_ID$
    , ObjectID$ => SP.TJ_WORK.Get_CABLE_SEGMENT_OBJECT_ID )) mo
    
    Left Join SP.MODEL_OBJECT_PAR_S mop1
    ON mop1.MOD_OBJ_ID=mo.ID
    AND mop1.OBJ_PAR_ID=Get_PARID_ORDINAL
    
    Left Join SP.MODEL_OBJECT_PAR_S mop2
    ON mop2.MOD_OBJ_ID=mo.ID
    AND mop2.OBJ_PAR_ID=Get_PARID_ZMINMAX_LENGTH

    Left Join SP.MODEL_OBJECT_PAR_S mop3
    ON mop3.MOD_OBJ_ID=mo.ID
    AND mop3.OBJ_PAR_ID=Get_PARID_REF_CABLE

    Left Join SP.MODEL_OBJECT_PAR_S mop4
    ON mop4.MOD_OBJ_ID=mo.ID
    AND mop4.OBJ_PAR_ID=Get_PARID_REF_SHELF
  )Loop
    rv#.CABLE_NAME:=d1.CABLE_NAME;
    rv#.ORDINAL:=d1.ORDINAL;
    rv#.LENGTH:=d1.LENGTH;
    rv#.Z_MIN:=d1.Z_MIN;
    rv#.Z_MAX:=d1.Z_MAX;
    rv#.CABLE_ID:=d1.CABLE_ID;
    
    begin
      --CABLE_NAME
      SELECT MOD_OBJ_NAME Into rv#.CABLE_NAME
      FROM SP.MODEL_OBJECTS
      WHERE ID=rv#.CABLE_ID
      ;
    Exception When NO_DATA_FOUND Then
      rv#.CABLE_NAME:=null;
      
      D('Для CABLE_ID = '||to_char(rv#.CABLE_ID)
      ||' в таблице SP.MODEL_OBJECTS не найден объект.'
      ,'Error In SP.TJ_WORK.V_CABLE_WAYS');
    End;
    
    begin
      --SEGMENT_NAME
      SELECT mo.MOD_OBJ_NAME, mopa.MOD_OBJ_NAME, mopa.OBJ_ID
      Into CWS_NAME#, CWS_PARENT_NAME#, CWS_PARENT_OBJ_ID#
      FROM SP.MODEL_OBJECTS mo
      Inner Join SP.MODEL_OBJECTS mopa
      ON mopa.ID=mo.PARENT_MOD_OBJ_ID
      WHERE mo.ID=d1.CWS_ID
      ;
      
      If CWS_PARENT_OBJ_ID#=Get_TRAY_OBJECT_ID Then
        --полки лотков
        rv#.SEGMENT_NAME:=CWS_PARENT_NAME#||'/'||CWS_NAME#;
        rv#.CABLE_CONSTRUCTUIN_TYPENAME:=TRAYS_NAME;
      Else
        rv#.SEGMENT_NAME:=CWS_NAME#;
        If CWS_NAME#=AIRGAPS_NAME Then
          rv#.CABLE_CONSTRUCTUIN_TYPENAME:=AIRGAPS_NAME;
        Else
          rv#.CABLE_CONSTRUCTUIN_TYPENAME:=CWS_PARENT_NAME#;
        End If;
      End If;
      
    Exception When NO_DATA_FOUND Then
      rv#.CABLE_NAME:=null;
      
      D('Для CABLE_WAY_SEGMENT_ID = '||to_char(d1.CWS_ID)
      ||' в таблице SP.MODEL_OBJECTS не найден объект.'
      ,'Error In SP.TJ_WORK.V_CABLE_WAYS');
    When OTHERS  Then
      D('Для CABLE_WAY_SEGMENT_ID = '||to_char(d1.CWS_ID)
      ||' CWS_NAME# ['||CWS_NAME#||'], CWS_PARENT_NAME# ['||CWS_PARENT_NAME#
      ||'] получили исключение:'||CHR(13)||CHR(10)||SQLERRM
      ,'Error In SP.TJ_WORK.V_CABLE_WAYS');
      Raise;
    End;

    pipe row(rv#);
  End Loop;
End V_CABLE_WAYS;
--==============================================================================
-- Перебирает все жилы кабеля до тех пор, пока не найдет первую попавшуюся жилу, 
-- у которой значение выбранного параметра (REF_PIN_FIRST или REF_PIN_SECOND) 
-- не есть Null и возвращает ID, соответствующий этому значению.
-- В случае провала возвращает Null.
-- Значение параметра ParamName$ может быть либо 'REF_PIN_FIRST' 
-- либо 'REF_PIN_SECOND'.
Function Get_CableRefPinID(CableID$ In Number, ParamName$ In Varchar2) 
Return Number
Is
  Par TMPAR;
Begin
  for rw in
  (
    --выборка проводов кабеля CableID$
    -- функция SP.TJ_WORK.V_MODEL_OBJECTS_DESC выбирает все объекты модели типа 
    -- ObjectID$, подчинённые объекту RootModObjID$
    SELECT mo.ID as CABLE_WIRE_ID 
    FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(
    RootModObjID$ => CableID$
    , ObjectID$ => SP.TJ_WORK.Get_CABLE_WIRE_OBJECT_ID )) mo 
  ) Loop
  
    Begin
      Par:=TMPAR(rw.CABLE_WIRE_ID,ParamName$);
    Exception When Others Then
      Par:=null;
    End;

    If (Not Par Is Null) 
      And (Not Par.Val Is Null) 
      And (Par.Val.T = SP.G.TRel) 
    Then
      Return Par.Val.N;
    End If;
  End Loop;
  Return null;
End Get_CableRefPinID;
--==============================================================================
--Возвращает значение булева параметра ParamName$ для объекта модели ModObjID$
--Если параметр отсутствует или он не булев, то возвращает null;
Function GetParamBoolean(ModObjID$ In Number,ParamName$ In Varchar2) 
Return Boolean
Is
 Par TMPAR;
Begin
  Par:=TMPAR(ModObjID$,ParamName$);
  If Par.Val.T = SP.G.TBoolean Then
    Return Par.Val.AsBoolean;
  Else
    Return null;
  End If;
End GetParamBoolean;
--==============================================================================
-- В таблице SP.MODEL_OBJECTS заменяет все значения OID модели MidelID$, 
-- имеющиеся в ключе ассоциативного массива Oid_AA$ на соответствующие значения 
-- того же ассоциативного массива.
Procedure UpdateOIDs
(Oid_AA$ In Out NoCopy SP.TJ_WORK.AA_ModObjOID2OID, ModelID$ In Number)
As
  oid# SP.MODEL_OBJECTS.OID%TYPE;
  ForceOID# Boolean;  --memo ForceOID
Begin
  ForceOID# := SP.TG.ForceOID;
  SP.TG.ForceOID := True;
  
  oid#:=Oid_AA$.First;
  While Not oid# Is Null 
  Loop
  
    UPDATE SP.MODEL_OBJECTS SET OID=Oid_AA$(oid#)
    WHERE MODEL_ID = ModelID$
    AND OID=oid#
    ;
  
    oid#:=Oid_AA$.Next(oid#);
  End Loop;

  SP.TG.ForceOID := ForceOID#;

End UpdateOIDs;
--==============================================================================
BEGIN
  null;
END TJ_WORK;
CREATE OR REPLACE PACKAGE BODY SP.TJ#ELECTRO
-- TJ Отчеты по электрической части
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-07
-- update 2020-12-08:2020-12-15:2020-12-15:2020-12-28
AS
--==============================================================================
--Очистка записи R_CAB_JOURNAL
Procedure Clear(r$ In Out NoCopy R_CAB_JOURNAL)
As
Begin
  r$.CABLE_ID := Null;
  r$.CABLE_NAME := Null;
  r$.FROM_DEVICE_ID := Null;
  r$.FROM_DEVICE_NAME := Null;
  r$.FROM_LOCATION_ID := Null;
  r$.FROM_LOCATION_NAME := Null;
  r$.FROM_LOCPROP_ID := Null;
  r$.TO_DEVICE_ID := Null;
  r$.TO_DEVICE_NAME := Null;
  r$.TO_LOCATION_ID := Null;
  r$.TO_LOCATION_NAME := Null;
  r$.TO_LOCPROP_ID := Null;
End Clear;
--==============================================================================
--Возвращает истину, если запись соотвествует устройству, т.е.
-- OBJ_ID=SP.TJ_WORK.Get_DEVICE_OBJECT_ID
Function IsDevice(ModObjRec$ In SP.MODEL_OBJECTS%ROWTYPE) Return Boolean
Is
Begin
  Return (ModObjRec$.OBJ_ID=SP.TJ_WORK.Get_DEVICE_OBJECT_ID);
End IsDevice;
--==============================================================================
--Возвращает значение параметра IsTerminalBlock для устройства DeviceID$
--Если параметр отсутсвует, то возвращает null;
Function IsTerminalBlock(DeviceID$ In Number) Return Boolean
Is
 Par TMPAR;
Begin
  Return SP.TJ_WORK.GetParamBoolean(DeviceID$,'IsTerminalBlock');
End IsTerminalBlock;
--==============================================================================
--Возвращает значение параметра IsTerminal для устройства DeviceID$
--Если параметр отсутсвует, то возвращает null;
Function IsTerminal(DeviceID$ In Number) Return Boolean
Is
 Par TMPAR;
Begin
  Return SP.TJ_WORK.GetParamBoolean(DeviceID$,'IsTerminal');
End IsTerminal;
--==============================================================================
-- Для Pin'а устройства, находит первое родительское устройство которое либо 
-- есть терминал и терминальный блок, либо не есть терминал.  
Function GetTopDevice(DevPinID$ In Number) Return SP.MODEL_OBJECTS%ROWTYPE
Is
  rv1 SP.MODEL_OBJECTS%ROWTYPE;
  rv2 SP.MODEL_OBJECTS%ROWTYPE;
  IsIt# Boolean;
Begin
  Select mop.* Into rv1
  From SP.MODEL_OBJECTS moc
  Inner Join SP.MODEL_OBJECTS mop
  On mop.ID=moc.PARENT_MOD_OBJ_ID
  Where moc.ID=DevPinID$
  ;

  If Not IsDevice(rv1) Then
    raise_application_error(-20033, 'Объект-предок пина ['
    ||rv1.MOD_OBJ_NAME||'] не является устройством.');
  End If;
  
  IsIt#:=IsTerminal(rv1.ID);
  If IsIt# Is Null Then
    raise_application_error(-20033, 'Устройство ['
    ||rv1.MOD_OBJ_NAME||'] не содержит обязательного параметра IsTerminal.');
  End If;

  If IsIt# = False Then
    --Нетерминальное устройство: выходим.
    Return rv1;
  End If;

  IsIt#:=IsTerminalBlock(rv1.ID);
  If IsIt# Is Null Then
    raise_application_error(-20033, 'Устройство ['||rv1.MOD_OBJ_NAME
    ||'] не содержит обязательного параметра IsTerminalBlock.');
  End If;
  
  If IsIt# = True Then
    --Терминальный блок: выходим.
    Return rv1;
  End If;

    Select mop.* Into rv2
  From SP.MODEL_OBJECTS moc
  Inner Join SP.MODEL_OBJECTS mop
  On mop.ID=moc.PARENT_MOD_OBJ_ID
  Where moc.ID=rv1.PARENT_MOD_OBJ_ID
  ;

  If Not IsDevice(rv2) Then
    D('Объект-предок ['||rv2.MOD_OBJ_NAME||'] терминального устройства ['
    ||rv1.MOD_OBJ_NAME||'] ID='||rv1.ID||' не является устройством.',
    'Error In SP.TJ#ELECTRO.GetTopDevice');
    return rv1;
  End If;

  IsIt#:=IsTerminalBlock(rv2.ID);
  If IsIt# Is Null Then
    raise_application_error(-20033, 'Предполагаемое устройство ['
    ||rv2.MOD_OBJ_NAME
    ||'] не содержит обязательного параметра IsTerminalBlock.');
  End If;

  If IsIt# = True Then
    --Нормальный выход через терминальный блок pin->клемма->терминальный блок.
    Return rv2;
  End If;

  raise_application_error(-20033, 'Устройство-предок предка пина ['
   ||rv2.MOD_OBJ_NAME
   ||'] не является терминальным блоком.');
End GetTopDevice;
--==============================================================================
--Главное предствление кабельного журнала
--Для работы WorkID$ возвращает таблицу кабельного журнала
--Замечания:
--Вместо ID работы может стоять ID любого другого объекта, потомком которого в 
--иерархии является кабель 
Function V_CAB_JOURNAL(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL Pipelined
Is
  rv R_CAB_JOURNAL;
  PinID# Number;
  Par TMPAR;
  ModObjRec# SP.MODEL_OBJECTS%ROWTYPE;

Begin
  if WorkID$ is null then
--    rv.CABLE_ID:= '';
--    rv.CABLE_NAME:= '';
--    pipe row (rv);
    return;
  end if;
  for rc in
  (
    --выборка кабелей, подчинённых работе WorkID$
    -- функция SP.TJ_WORK.V_MODEL_OBJECTS_DESC выбирает все объекты модели типа 
    -- ObjectID$, подчинённые объекту RootModObjID$
    SELECT mo.ID as CABLE_ID, mo.MOD_OBJ_NAME as CABLE_NAME 
    FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(
    RootModObjID$ => WorkID$, ObjectID$ => SP.TJ_WORK.Get_CABLE_OBJECT_ID )) mo 
  ) 
  Loop
    Clear(rv);
    rv.CABLE_ID:=rc.CABLE_ID;
    rv.CABLE_NAME:=rc.CABLE_NAME;
    
    ------------------------------------------------------------------
    PinID# := SP.TJ_WORK.Get_CableRefPinID
      (CableID$ => rc.CABLE_ID, ParamName$ => 'REF_PIN_FIRST');
    
    If Not PinID# Is Null Then
      ModObjRec#:=GetTopDevice(PinID#);
      rv.FROM_DEVICE_ID := ModObjRec#.ID;
      rv.FROM_DEVICE_NAME := ModObjRec#.MOD_OBJ_NAME;
      Par:=TMPAR(rv.FROM_DEVICE_ID,'Место');
      If Par.Val.T=SP.G.TRel Then
        rv.FROM_LOCATION_ID := Par.Val.N;
        If Not rv.FROM_LOCATION_ID Is Null Then
          Par:=TMPAR(rv.FROM_LOCATION_ID,'NAME');
          rv.FROM_LOCATION_NAME := Par.Val.AsString;
          Par:=TMPAR(rv.FROM_LOCATION_ID,'PROPS');
          If Par.Val.T=SP.G.TRel Then
            rv.FROM_LOCPROP_ID := Par.Val.N;
          End If;
        End If;
      End if;
    End If;    
    
    ------------------------------------------------------------------
    PinID# := SP.TJ_WORK.Get_CableRefPinID
      (CableID$ => rc.CABLE_ID, ParamName$ => 'REF_PIN_SECOND');
    
    If Not PinID# Is Null Then
      ModObjRec#:=GetTopDevice(PinID#);
      rv.TO_DEVICE_ID := ModObjRec#.ID;
      rv.TO_DEVICE_NAME := ModObjRec#.MOD_OBJ_NAME;
      Par:=TMPAR(rv.TO_DEVICE_ID,'Место');
      If Par.Val.T=SP.G.TRel Then
        rv.TO_LOCATION_ID := Par.Val.N;
        If Not rv.TO_LOCATION_ID Is Null Then
          Par:=TMPAR(rv.TO_LOCATION_ID,'NAME');
          rv.TO_LOCATION_NAME := Par.Val.AsString;
          Par:=TMPAR(rv.TO_LOCATION_ID,'PROPS');
          If Par.Val.T=SP.G.TRel Then
            rv.TO_LOCPROP_ID := Par.Val.N;
          End If;
        End If;
      End if;
    End If;
    
    pipe row (rv);
  End Loop;
End V_CAB_JOURNAL;

procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in VARCHAR2)
is
begin
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 1,
                  US => PNAME,
                  USHEET => sheet,
                  UBOOK => book);
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 2,
                  US => PVALUE,
                  USHEET => sheet,
                  UBOOK => book);
  curRowNum := curRowNum +1;                
end add_Property2sheet; 
               
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in NUMBER)                
is
begin
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 1,
                  US => PNAME,
                  USHEET => sheet,
                  UBOOK => book);
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 2,
                  UN => PVALUE,
                  USHEET => sheet,
                  UBOOK => book);
  curRowNum := curRowNum +1;                
end add_Property2sheet; 
               
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in DATE)                
is
begin
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 1,
                  US => PNAME,
                  USHEET => sheet,
                  UBOOK => book);
  KOCEL.SAVE_CELL(UR => curRowNum, UC => 2,
                  UD => PVALUE,
                  USHEET => sheet,
                  UBOOK => book);
  curRowNum := curRowNum +1;                
end add_Property2sheet;                

End TJ#ELECTRO;
/

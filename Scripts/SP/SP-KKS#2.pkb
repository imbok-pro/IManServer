CREATE OR REPLACE PACKAGE BODY SP.KKS#2
AS
-- Работа с кодами KKS в двухбуквенной начальной иерархии
-- см. документ 
-- PM01.TJ. Ввод данных проектных позиций электротехнической части.docx
-- в папке ...\vm-polinom\Scripts\Data\Hydro\TJ\00.Docs\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-06-22
-- update 2021-06-23:2021-06-27

--  ID узла "Проектные позиции"
KKS#ROOT#ID Number := null;

--  Допустимые символы в позиции ряда KOCEL (см. функцию GetKKS(...))
KKSAllowedSymbols#AA SP.KKS.AA_KKSAllowedSymbols;
--==============================================================================
--Устанавливает KKS#ROOT#ID := Null 
Procedure ClearKKS_RootID
Is
Begin
  KKS#ROOT#ID:=Null;
End ClearKKS_RootID;
--==============================================================================
--Возвращает ID объекта с именем 'Проектные позиции' текущей модели
Function GetKKS_RootID Return Number
As
Begin
  If KKS#ROOT#ID Is Null Then
    SELECT ID Into KKS#ROOT#ID 
    From SP.MODEL_OBJECTS
    Where MODEL_ID=GET_MODEL_ID()
    And Upper(MOD_OBJ_NAME)='ПРОЕКТНЫЕ ПОЗИЦИИ'
    ;
  End If;
  Return KKS#ROOT#ID;
Exception When NO_DATA_FOUND Then
  raise_application_error(-20033
  , 'В модели ID ['||GET_MODEL_ID()
  ||'] не найден объект с именем "ПРОЕКТНЫЕ ПОЗИЦИИ".');    
  When TOO_MANY_ROWS Then
  raise_application_error(-20033
  , 'В модели ID ['||GET_MODEL_ID()
  ||'] содержится более одного объекта с именем "ПРОЕКТНЫЕ ПОЗИЦИИ".');    
End GetKKS_RootID;
--==============================================================================
--Возвращает имена и ID таксонов первого и второго уровня классификатора 
-- проектных позиций текущей локальной модели.
--В случае их отсутсвия, возвращаются пустые ассоциативные массивы.
--Tax1_AA$ ассоциативный массив однобуквенных таксонов
--Tax2_AA$ ассоциативный массив двухбуквенных таксонов
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
--Возвращает имена и ID систем и подсистем классификатора 
-- проектных позиций текущей локальной модели.
--В случае их отсутсвия, возвращется пустой ассоциативный массив.
--SubSys_AA$ ассоциативный массив систем и подсистем
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
--  Выделяет KKS-код из диапазона ячеек ряда KOCEL
--
--  Длина диапазона - это IColMax$-IColMin$+1, 
--  т.е. количество символов в коде KKS
--  В настоящее время функция обрабатывает только диапазоны длиной 7, и 12
--  При обработке диапазанов длиной 7 функция возвращает в переменную KKSFull$
--  только коды систем и подстистем длиной 7 (ex: 00SAS03).
--  При обработке диапазона длиной 12 функция возвращает  в переменную KKSFull$ 
--  коды систем и подсистем длиной 7 (ex: 00SBB03), 
--  либо коды устройств длиной 12 (ex: 00SBB03BR005).
--  При других длинах диапазона функция возбуждает исключение.
Function GetKKS(
kRow$ In KOCEL.CELL.TRow      --вх: анализируемый ряд листа книги KOCEL
, IColMin$ In BINARY_INTEGER  --вх: начало диапазона номеров колонок KKS
, IColMax$ In BINARY_INTEGER  --вх: конец диапазона номеров колонок KKS
, BuffLog$ In Out NOCopy DEBUG_LOG.TBUFF_LOG  -- буфер вывода ошибок вх.данных
, SysNum$ In Out varchar2     --вых: номер системы (2)
, SysCode$ In Out Varchar2    --вых: код системы (3)
, SubSysNum$ In Out varchar2  --вых: номер подсистемы (2)
, UnitCode$ In Out Varchar2   --вых: код устройства в составе системы (5)
, KKSFull$  In Out Varchar2   --вых: полный код KKS (7 или 12)
) Return Boolean
Is
  EmptyColCount# BINARY_INTEGER;
  EmtyColMax# BINARY_INTEGER;
  Mes# Varchar2(4000);
  ts# Varchar2(4000);
  kks_system_part_len# BINARY_INTEGER; -- длина системной части кода KKS
  iRow## BINARY_INTEGER; --отладочная переменная, убрать после отладки
  
  
  --Преобразует значение KOCEL.CELL.TCellValue в строку из одного символа, при
  -- этом результат сохраняет в переменную ts#.
  -- Если артгумент не есть число или строка, то возвращает false.
  -- Если полученная строка длинннее одного символа, то возвращает false 
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
  
  --  Возвращает истину и заполняет ts# значением, если ячейка с номером iC 
  --  существует, непуста и содержит число или строку
  Function NotEmptyCell(iC$ In BINARY_INTEGER) Return Boolean
  Is
  Begin
    If kRow$.Exists(iC$) then
      If TOChar1(kRow$(iC$)) Then
        If Not ts# Is Null Then
          Return true;
        End If;
      Else
        Mes#:='Ряд '||kRow$(kRow$.First).R||' колонка '||iC$
        ||' содержит неправильный символ ['||ts#||'] кода KKS.';
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
        --  Пропускаем строку, поскольку системная часть кода KKS 
        --  (первые 5 символов) пустая
        Return false;
      End If;
    Elsif iCol = IColMin$+EmtyColMax#+SP.KKS.kks_SubSystem_Len Then
      If iRow##=148 Then
         D('3. For iRow ='||iRow##||' Not Exists iCol = '||iCol,'DEBUG SP.KKS#2.GetKKS');
      End If;
      --  Выходим из цикла, поскольку системная часть кода (первые 7 символов) 
      --  считаны и первый символ кода устройства не найден (пустой)
      Exit;
    Else
      If iRow##=148 Then
         D('4. For iRow ='||iRow##||' Not Exists iCol = '||iCol,'DEBUG SP.KKS#2.GetKKS');
      End If;
      -- ошибка в части кода устройства
      Mes#:='Ряд '||kRow$(kRow$.First).R||' содержит неправильный код KKS ['
      ||KKSFull$||'] в части кода устройства.';
      BuffLog$.AppendLine(Mes#);
      Return false;
    End If;
  End Loop;
  
  If Not SP.KKS.SplitLongKKS(KKSFull$, SysNum$,SysCode$, SubSysNum$) Then
     Mes#:= 'Ряд '||kRow$(kRow$.First).R||' содержит неправильный код KKS ['||  
     SP.KKS.DetectDeprecatedSymbols(KKSFull$)||'].';
    KKSFull$:=SP.KKS.Cyr2Lat(KKSFull$);
    If SP.KKS.SplitLongKKS(KKSFull$, SysNum$, SysCode$, SubSysNum$) Then
      BuffLog$.AppendLine(Mes#); 
    Else                                                
      Mes#:='Ряд '||kRow$(kRow$.First).R
      ||' содержит неправильный код KKS ['||KKSFull$||']';
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
--Возвращает ID объекта по ID его непосредственного предка
-- или Null
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
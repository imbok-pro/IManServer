create or replace PACKAGE BODY SP.BRCM#DUMP 
AS
-- Работа исключительно с дампом модели BRCM 
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-03-21
-- update 2019-07-15 2019-09-26 2019-10-24:2019-11-21

--==============================================================================
--Имя и ID модели, в которой содержится дамп данных BRCM.
DumpModel$Name SP.MODELS.NAME%TYPE;
DumpModel$ID SP.MODELS.ID%TYPE;
E$M Varchar2(4000);
--==============================================================================

ZeroVector#Eps Number := 2.0; --с точностью до миллиметра (в строительстве)
Parallel#Eps Number := 0.0001;  -- 1 мм. на 10 метров

Max$Number Constant Number := 999999999999999999999999999999999999999999999;
Min$Number Constant Number := -999999999999999999999999999999999999999999999;

Type R_RID_NAME Is Record
(
  RID NUMBER,  --RECORD_ID
  RNAME Varchar2(128)  --RECOR_NAME
);

TYPE AA_ModObjName2RID_NAME Is Table Of R_RID_NAME 
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

--Классы элементов кабельных трасс RACEWAY Classes '
RacewayClasses_AA AA_ModObjName2Name;

--------------------------------------------------------------------------------
--Возвращает версию дампа BRCM ('10','08') или возбуждает ошибку
Function Get_BRCM_DUMP_VERSION Return Varchar2
As
  rv# Varchar2(40);
  cntt# BINARY_INTEGER;
  cntp# BINARY_INTEGER;
  
Begin
  Select Count(*) Into cntt#  
  From SP.MODEL_OBJECTS 
  Where MODEL_ID=DumpModel$ID
  And PARENT_MOD_OBJ_ID Is Null
  ;
  
  
  Select Count(*) Into cntp#  
  From SP.MODEL_OBJECTS 
  Where MODEL_ID=DumpModel$ID
  And PARENT_MOD_OBJ_ID Is Null
  And MOD_OBJ_NAME LIKE 'PRJCE_INT%'
  ;
  
  If cntt#=cntp# Then
    Return '10';
  End If;
  
  If cntp#>0 Then
    E$M:='Общее число деревьев '||cntt#||'не совпадает с шаблоном '
    ||to_char(cntp#)||'. Некоррекные данные в модели '||DumpModel$ID||'.';
    D(E$M, 'ERROR In SP.BRCM#DUMP.Get_BRCM_DUMP_VERSION');
    raise_application_error(-20033, E$M);  
  End If;
  
  Select Count(*) Into cntp#  
  From SP.MODEL_OBJECTS 
  Where MODEL_ID=DumpModel$ID
  And PARENT_MOD_OBJ_ID Is Null
  And MOD_OBJ_NAME LIKE 'Project_INT%'
  ;

  If cntt#=cntp# Then
    Return '08';
  End If;
  
  If cntp#>0 Then
    E$M:='Общее число деревьев '||cntt#||'не совпадает с шаблоном '
    ||to_char(cntp#)||'. Некоррекные данные в модели '||DumpModel$ID||'.';
    D(E$M, 'ERROR In SP.BRCM#DUMP.Get_BRCM_DUMP_VERSION');
    raise_application_error(-20033, E$M);  
  End If;

    E$M:='Mодель ID = '||DumpModel$ID
      ||' не содержит данных дампа известных версий BRCM.';
    D(E$M, 'ERROR In SP.BRCM#DUMP.Get_BRCM_DUMP_VERSION');
    raise_application_error(-20033, E$M);  

  Return null;
End;
--------------------------------------------------------------------------------
--Обнуляет все переменные и массивы пакета, кроме DumpModel_Name и DumpModel_ID,
--а также все временные очищает таблицы
Procedure ClearPackage
Is
Begin
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_CFC';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_CABLE';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_AREP';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_EQP';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_ADJ';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_RLINE';
  Execute Immediate 'TRUNCATE TABLE SP.BRCM_RACEWAY';
  
End ClearPackage;
--------------------------------------------------------------------------------
Procedure Init08
As
Begin
  Prj$AREP := 'Project_INT_CM_AREP';
  Prj$CABLES := 'Project_INT_CM_CABLES';
  Prj$CFC := 'Project_INT_CM_CFC';
  Prj$EQP := 'Project_INT_EQP';
  Prj$RLINES := 'Project_INT_RLINES';
  Prj$RACEWAY := 'Project_INT_RACEWAY';

  PrjF$AREP_BIN_DATA := 'CM_AREP_BIN_DATA';  
  PrjF$CABLES_DATA := 'CM_CABLES_DATA';  
  PrjF$RACEWAY_BIN_DATA := 'RACEWAY_BIN_DATA';
End;
--------------------------------------------------------------------------------
Procedure Init10
As
Begin
  Prj$AREP := 'PRJCE_INT_CM_AREP';
  Prj$CABLES := 'PRJCE_INT_CM_CABLES';
  Prj$CFC := 'PRJCE_INT_CM_CFC';
  Prj$EQP := 'PRJCE_INT_EQP';
  Prj$RLINES := 'PRJCE_INT_RLINES';
  Prj$RACEWAY := 'PRJCE_INT_RACEWAY';
  
  PrjF$AREP_BIN_DATA := '_AREP_BIN_DATA';  
  PrjF$CABLES_DATA := '_CABLES_DATA';  
  PrjF$RACEWAY_BIN_DATA := 'CEWAY_BIN_DATA';

End;
--------------------------------------------------------------------------------
Procedure Init
Is
  ve# Varchar2(20);
Begin
  ve#:=Get_BRCM_DUMP_VERSION;
  If ve#='10' Then
    Init10;
  ElsIf ve#='08' Then
    Init08;
  End If;
  ClearPackage;
End;
--------------------------------------------------------------------------------
--Возвращает имя модели, в которой содержится дамп данных BRCM.
Function DumpModelName Return SP.MODELS.NAME%TYPE
Is
Begin
    Return DumpModel$Name;
End;
--------------------------------------------------------------------------------
--Возвращает ID модели, в которой содержится дамп данных BRCM.
Function DumpModelID Return SP.MODELS.ID%TYPE
Is
Begin
    Return DumpModel$ID;
End;
--------------------------------------------------------------------------------
--Устанавливает имя и ID модели с дампом BRCM 
Procedure SetDumpModelName(DumpModelName$ In Varchar2)
Is
Begin
  ClearPackage;
  
  Select ID Into DumpModel$ID
  FROM SP.MODELS WHERE NAME=DumpModelName$;
  
  DumpModel$Name:=DumpModelName$;
  
  Init;
  
End;
--==============================================================================
--Лог длинных строк
--Если строки короткие, то  делает их конкатенацию
--Если строки длинные, то записывает в лог начало (mess1$)
--а затем заменяет начало хвостом (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 )
As
Begin
  If LENGTH(mess1$)+LENGTH(mess2$) < 4000 Then
    mess1$:=mess1$||mess2$;
    Return;
  End If;
  
  D(mess1$,Tag$);
  mess1$:='[Продолжение...]'||CHR(10)||CHR(13)||mess2$;
  
  Return;
End;
--==============================================================================
Function V_TabooCableNames Return SP.TSHORTSTRINGS Pipelined
Is
Begin
  for r in ( select (column_value).getstringval() as "CableNo"
    from xmltable('"=00BFA60BFA60 1001f","=00BFA70BFA70 1002f"
      ,"=00BFA60BFA60 1002f","=00BFA60BFA60 1003f","=00BFA60BFA60 1004f"
      ,"=00BFA70BFA70 1001f"
    ')    
    )
  Loop
    pipe row(r."CableNo");
  End Loop;
End;
--==============================================================================
--строку вида "125700.0000000,6650.0000000,3840.0000000"
--превращает в три числа XYZ
Procedure Str2XYZ(Str$ In Varchar2, Sepa$ In Varchar2
, X$ In Out Nocopy Number, Y$ In Out Nocopy Number, Z$ In Out Nocopy Number)
As
i# BINARY_INTEGER;
tmpS VARCHAR2(90);
Begin
  i#:=INSTR(Str$,Sepa$);
  X$:=to_number(substr(Str$,1,i#-1));
  tmpS := substr(Str$,i#+1);
  i#:=instr(tmpS,Sepa$);
  Y$:=to_number(substr(tmpS,1,i#-1));
  Z$:=to_number(substr(tmpS,i#+1));
exception
  when others then     
    raise_application_error(-20033,'Wrong XYZ: ['||Str$||'], Separator ['
    ||Sepa$||'] '||SQLERRM);
End Str2XYZ;

--==============================================================================
--Возвращает 1, если точка (x1,y1) покоординатно приближает точку (x1,y2) с 
--абсолютной погрешностью, меньшей, чем EPS_Coord=0.0001.
--В противном случае возвращает 0.
Function EQ_PointsXY(x1$ In Number, y1$ In Number, x2$ In Number, y2$ In Number
, Eps$ In Number:=null) 
Return BINARY_INTEGER
Is
rv# BINARY_INTEGER :=0;
Eps# Number;
Begin
    If Eps$ Is Null Then
      Eps#:=EPS_Coord;
    Else
      Eps#:=Eps$;
    End If;
    If ABS(x1$-x2$)< Eps#  And ABS(y1$-y2$)< Eps# Then
      Return 1;
    End If;
      
    Return rv#;
End EQ_PointsXY;

--==============================================================================
--Возвращает квадрат расстояния между точками A и B
Function Dist2(AX$ In Number, AY$ In Number, AZ$ In Number
, BX$ In Number, BY$ In Number, BZ$ In Number) Return Number
Is
dx# Number;
dy# Number;
dz# Number;
Begin
  dx#:=AX$-BX$;
  dy#:=AY$-BY$;
  dz#:=AZ$-BZ$;
  Return dx#*dx# + dy#*dy# + dz#*dz#;
End Dist2;

--==============================================================================
--Возвращает 1, если точка (x1,y1,z1) покоординатно приближает точку (x1,y2,z2) 
--с абсолютной погрешностью, меньшей, чем EPS_Coord=0.0001.
--В противном случае возвращает 0.
Function EQ_PointsXYZ(x1$ In Number, y1$ In Number, z1$ In Number
, x2$ In Number, y2$ In Number, z2$ In Number, Eps$ In Number:=null) 
Return BINARY_INTEGER
Is
rv# BINARY_INTEGER :=0;
Eps# Number;
Begin
  If Eps$ Is Null Then
    Eps#:=EPS_Coord;
  Else
    Eps#:=Eps$;
  End If;

    If ABS(x1$-x2$)< Eps#  
      And ABS(y1$-y2$)< Eps# And ABS(z1$-z2$)< Eps# 
    Then
      Return 1;
    End If;
      
    Return rv#;
End EQ_PointsXYZ;
--==============================================================================
--Возвращает ненулевое значение, если отрезки соединены в цепь.
--Возвращает 1, если S1B=S2A с абсолютной погрешностью EPS_Coord=0.0001.
--Возвращает 2, если S2B=S1A с абсолютной погрешностью EPS_Coord=0.0001.
--Возвращает -1, если S1A=S2A с абсолютной погрешностью EPS_Coord=0.0001.
--Возвращает -2, если S1B=S2B с абсолютной погрешностью EPS_Coord=0.0001.
--В противном случае возвращает 0.
Function IsSegments_Adjacent(
  S1AX$ In Number --Координата X левого конца сегмента 1
, S1AY$ In Number --Координата Y левого конца сегмента 1
, S1AZ$ In Number --Координата Z левого конца сегмента 1
, S1BX$ In Number --Координата X правого конца сегмента 1
, S1BY$ In Number --Координата Y правого конца сегмента 1
, S1BZ$ In Number --Координата Z правого конца сегмента 1
, S2AX$ In Number --Координата X левого конца сегмента 2
, S2AY$ In Number --Координата Y левого конца сегмента 2
, S2AZ$ In Number --Координата Z левого конца сегмента 2
, S2BX$ In Number --Координата X правого конца сегмента 2
, S2BY$ In Number --Координата Y правого конца сегмента 2
, S2BZ$ In Number --Координата Z правого конца сегмента 2
) 
Return BINARY_INTEGER
Is
rv# BINARY_INTEGER :=0;
Begin
  If EQ_PointsXYZ(S1BX$, S1BY$, S1BZ$, S2AX$, S2AY$, S2AZ$)=1 Then 
    rv#:=1;
  ElsIf EQ_PointsXYZ(S2BX$, S2BY$, S2BZ$, S1AX$, S1AY$, S1AZ$)=1  Then
    rv#:=2;
  ElsIf EQ_PointsXYZ(S1AX$, S1AY$, S1AZ$, S2AX$, S2AY$, S2AZ$)=1  Then
    rv#:=-1;
  ElsIf EQ_PointsXYZ(S2BX$, S2BY$, S2BZ$, S1BX$, S1BY$, S1BZ$)=1  Then
    rv#:=-2;
  End If;

  Return rv#;
End IsSegments_Adjacent;
--==============================================================================
--  Возвращает координаты точки смежности первого отрезка, 
--  если отрезки соединены в цепь.
--Если отрезки не смежны, то возвращаемый вектор имеет 0 координат.
Function GetAdjacencePoint(
  S1AX$ In Number --Координата X левого конца сегмента 1
, S1AY$ In Number --Координата Y левого конца сегмента 1
, S1AZ$ In Number --Координата Z левого конца сегмента 1
, S1BX$ In Number --Координата X правого конца сегмента 1
, S1BY$ In Number --Координата Y правого конца сегмента 1
, S1BZ$ In Number --Координата Z правого конца сегмента 1
, S2AX$ In Number --Координата X левого конца сегмента 2
, S2AY$ In Number --Координата Y левого конца сегмента 2
, S2AZ$ In Number --Координата Z левого конца сегмента 2
, S2BX$ In Number --Координата X правого конца сегмента 2
, S2BY$ In Number --Координата Y правого конца сегмента 2
, S2BZ$ In Number --Координата Z правого конца сегмента 2
) 
Return SP.VEC.AA_Vector
Is
rv# SP.VEC.AA_Vector;
Begin
  If EQ_PointsXYZ(S1BX$, S1BY$, S1BZ$, S2AX$, S2AY$, S2AZ$)=1 Then 
    Return SP.VEC.CreateV3(S1BX$, S1BY$, S1BZ$);
  ElsIf EQ_PointsXYZ(S2BX$, S2BY$, S2BZ$, S1AX$, S1AY$, S1AZ$)=1  Then
    Return SP.VEC.CreateV3(S1AX$, S1AY$, S1AZ$);
  ElsIf EQ_PointsXYZ(S1AX$, S1AY$, S1AZ$, S2AX$, S2AY$, S2AZ$)=1  Then
    Return SP.VEC.CreateV3(S1AX$, S1AY$, S1AZ$);
  ElsIf EQ_PointsXYZ(S2BX$, S2BY$, S2BZ$, S1BX$, S1BY$, S1BZ$)=1  Then
    Return SP.VEC.CreateV3(S1BX$, S1BY$, S1BZ$);
  End If;

  Return rv#;
End GetAdjacencePoint;
--==============================================================================
--Возвращает ненулевое значение, если два RLINE_ITEMS смежны.
--Возвращает 1, если S1B=S2A с абсолютной погрешностью EPS_Coord=1.
--Возвращает 2, если S2B=S1A с абсолютной погрешностью EPS_Coord=1.
--Возвращает -1, если S1A=S2A с абсолютной погрешностью EPS_Coord=1.
--Возвращает -2, если S1B=S2B с абсолютной погрешностью EPS_Coord=1.
--В противном случае возвращает 0.
Function IsRLINE_ITEMS_Adjacent(
  r1$ In BRCM_RLINE%ROWTYPE
, r2$ In BRCM_RLINE%ROWTYPE
) 
Return BINARY_INTEGER
Is
Begin
  Return IsSegments_Adjacent(
      S1AX$ => r1$.X1
    , S1AY$ => r1$.Y1
    , S1AZ$ => r1$.Z1
    , S1BX$ => r1$.X2
    , S1BY$ => r1$.Y2
    , S1BZ$ => r1$.Z2
    , S2AX$ => r2$.X1
    , S2AY$ => r2$.Y1
    , S2AZ$ => r2$.Z1
    , S2BX$ => r2$.X2
    , S2BY$ => r2$.Y2
    , S2BZ$ => r2$.Z2
    ); 
End IsRLINE_ITEMS_Adjacent;
--==============================================================================
--  Возвращает координаты точки смежности первого RLINE, 
--  если RLINEs соединены в цепь.
--  Если RLINEs не смежны, то возвращаемый вектор имеет 0 координат.
Function GetAdjacencePoint(
  r1$ In BRCM_RLINE%ROWTYPE
, r2$ In BRCM_RLINE%ROWTYPE
) 
Return SP.VEC.AA_Vector
Is
Begin
  Return GetAdjacencePoint(
      S1AX$ => r1$.X1
    , S1AY$ => r1$.Y1
    , S1AZ$ => r1$.Z1
    , S1BX$ => r1$.X2
    , S1BY$ => r1$.Y2
    , S1BZ$ => r1$.Z2
    , S2AX$ => r2$.X1
    , S2AY$ => r2$.Y1
    , S2AZ$ => r2$.Z1
    , S2BX$ => r2$.X2
    , S2BY$ => r2$.Y2
    , S2BZ$ => r2$.Z2
    ); 
End GetAdjacencePoint;
--==============================================================================
-- Возвращает истну, если соответствующие RLINEs смежные, 
-- в противном случае возвращает ложь.
Function IsAdjacent(RL_RID1$ In Number, RL_RID2$ In Number) Return Boolean
Is
  qq# SP.BRCM_ADJ.PARALLEL%TYPE;
Begin
  Select PARALLEL Into qq#
  From BRCM_ADJ
  Where RL_RID1 = RL_RID1$
  And RL_RID2 = RL_RID2$
  ;
  
  Return True;
Exception When NO_DATA_FOUND Then  
  Return False;
End IsAdjacent;
--==============================================================================
--Возвращает координаты концов сегмента в виде A(X:Y:Z),B(X:Y:Z)
Function SegmentToStr(r$ In BRCM_RLINE%ROWTYPE) Return String
As
  rv# Varchar2(256 BYTE);
Begin
  rv#:='A('||r$.X1||':'||r$.Y1||':'||r$.Z1
  ||'),B('||r$.X2||':'||r$.Y2||':'||r$.Z2||')';
  return rv#;
End;
--==============================================================================
--ПО RLINE_ELEMENT_ID возвращает соответствующий RACEWAY_ELEMENT_ID
-- например, 12E37_0 -> 12E37
Function RLine2RacewayEID(RLineEID$ Varchar2) Return Varchar2
As
  i# BINARY_INTEGER;
Begin
  i#:=INSTR(RLineEID$,'_');

  If i#>1 Then
    Return SUBSTR(RLineEID$, 1, i#-1);
  End If;

  Return RLineEID$;
End;
--==============================================================================
--Возвращает 1, если rli$.RW_CLASS соотвествует тройнику (разветвителю).
--В противном случае возвращает 0.
Function IsTee(RW_CLASS$ In Varchar2) Return Number
Is
Begin
  If UPPER(RW_CLASS$) LIKE '%TEE%' Then
    Return 1;
  End If;
  Return 0;  
End;
--==============================================================================
--Возвращает 1, если rli$.RW_CLASS соотвествует тройнику (разветвителю).
--В противном случае возвращает 0.
Function IsTee(rli$ In SP.BRCM_RLINE%ROWTYPE) Return Number
Is
  RW_CLASS# SP.BRCM_RACEWAY.RW_CLASS%TYPE;
Begin

  SELECT RW_CLASS Into RW_CLASS#
  FROM SP.BRCM_RACEWAY
  WHERE RW_RID=rli$.RW_RID
  ;
  
  Return IsTee(RW_CLASS$ => RW_CLASS#);
Exception When NO_DATA_FOUND Then
  Return 0;
End;

--==============================================================================
--Возвращает ID объекта с именем похожим на LikeModObjName$, находящегося 
--не выше объекта, задаваемого RootModObjID$.
--Если объект не найден возвращает Null
--Если найдено несколько объектов, возникает исключение
Function GetModObj1(RootModObjID$ In Number, LikeModObjName$ In varchar2) 
Return Number
Is
  rv# Number;
Begin

  SELECT mo.ID Into rv# 
  FROM SP.MODEL_OBJECTS mo
  WHERE mo.MOD_OBJ_NAME Like LikeModObjName$
  start with mo.ID=RootModObjID$
  connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
  ;

  Return rv#;
Exception When NO_DATA_FOUND Then
  Return Null;
End GetModObj1;

--==============================================================================
--Возвращает поле S параметра с менем ParName$ объекта с ID ModObjID$
Function GetModObjParamValS(ModObjID$ In Number, ParName$ In varchar2)
Return Varchar2
Is
  rv# SP.MODEL_OBJECT_PAR_S.S%TYPE;
Begin
  Select S Into rv#
  From SP.MODEL_OBJECT_PAR_S
  Where MOD_OBJ_ID=ModObjID$
  And NAME=ParName$
  ;
  
  Return rv#;
Exception When NO_DATA_FOUND Then
  Return Null;
End;

--==============================================================================
--Возвращает значения параметра с именем ParamName$ объекта
--с именем похожим на LikeModObjName$, находящегося в 
--не выше объекта, задаваемого RootModObjID$.
--Если ParamName => null, то возвращает все параметры.
Function GetModObjParam(RootModObjID$ In Number
, LikeModObjName$ In varchar2, ParamName$ In varchar2:=null) 
Return T_MOD_OBJ_PARS pipelined
Is
Begin
  For r In (
    WITH MOREC As(
    SELECT * FROM SP.MODEL_OBJECTS mo
    start with mo.ID=RootModObjID$
    connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID 
    )
    SELECT  
        mop.ID As PARAM_ID,
        mop.MOD_OBJ_ID,
        mo.MOD_OBJ_NAME, 
        mop.NAME As PARAM_NAME,
        mop.R_ONLY,
        mop.TYPE_ID,
        mop.E_VAL,
        mop.N,
        mop.D,
        mop.S,
        mop.X,
        mop.Y
    FROM MOREC mo
    INNER JOIN SP.MODEL_OBJECT_PAR_S mop
    ON mop.MOD_OBJ_ID=mo.ID
    AND mop.NAME =  NVL(ParamName$,mop.NAME) 
    WHERE mo.MOD_OBJ_NAME LIKE LikeModObjName$
  )Loop
    pipe row(r);
  End Loop;
End GetModObjParam;

--==============================================================================
--Возвращает Записи (Records) класса с именем ClassName$ дамапа BRCM
Function GetClassRecords(ClassName$ In Varchar2) 
Return T_MODEL_OBJECTS pipelined
Is
Begin
  For r In (
    SELECT mo2.* 
    FROM SP.MODEL_OBJECTS mo1
    INNER JOIN SP.MODEL_OBJECTS mo2
    ON mo2.PARENT_MOD_OBJ_ID=mo1.ID
    WHERE mo1.MOD_OBJ_NAME=ClassName$
    AND mo1.MODEL_ID=DumpModelID
  )
  Loop
    pipe row(r);
  End Loop;
End GetClassRecords;

--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_EQP
Procedure BRCM_EQP_PREPARE
Is
  
  cnt# BINARY_INTEGER;
  r# SP.BRCM_EQP%ROWTYPE;
  GeomID# SP.MODEL_OBJECTS.ID%TYPE;
  vs# Varchar2(4000);
  
  --Имена устройств для отслеживания уникальности и постановки диагнозов
  item# R_RID_NAME;
  Names# AA_ModObjName2RID_NAME;
Begin
  Select Count(*) Into cnt#
  From SP.BRCM_EQP;
  
  If cnt#>0 Then Return; End If;
  
  For r In (
    Select  cr.ID As EQP_RID
    , cr.MOD_OBJ_NAME As EQP_RNAME
    ,mop.S As EQP_EID
    , mop1.S As EQP_NAME
    , mop2.S As EQP_DESIGN_FILE
    FROM TABLE(GetClassRecords(Prj$EQP)) cr
    INNER JOIN SP.MODEL_OBJECT_PAR_S mop
    ON mop.MOD_OBJ_ID=cr.ID
    AND mop.NAME='HP_ELEMENT_ID'
    LEFT JOIN TABLE(GetModObjParam(cr.ID, 'ID_%', 'HP_name') ) mop1
    ON Not mop1.S Is Null
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop2
    ON mop2.MOD_OBJ_ID=cr.ID
    AND mop2.NAME='HP_DESIGN_FILE'
  )Loop
  
    r#.EQP_RID := r.EQP_RID;
    r#.EQP_RNAME := r.EQP_RNAME;
    r#.EQP_EID := r.EQP_EID;
    r#.EQP_NAME := r.EQP_NAME;
    r#.EQP_DESIGN_FILE := r.EQP_DESIGN_FILE;
    
    GeomID#:=GetModObj1(
      RootModObjID$ => r.EQP_RID
      , LikeModObjName$ => 'Geometry_%');
      
   vs#:=GetModObjParamValS
      (ModObjID$ => GeomID#, ParName$ => 'HP_trans_vec:[df]');

    Str2XYZ(Str$=>vs#, Sepa$ => ','
    , X$ => r#.TV_X, Y$ => r#.TV_Y, Z$ => r#.TV_Z);

    vs#:=GetModObjParamValS
      (ModObjID$ => GeomID#, ParName$ => 'HP_unit_vec_x');

    Str2XYZ(Str$=>vs#, Sepa$ => ','
    , X$ => r#.UX_X, Y$ => r#.UX_Y, Z$ => r#.UX_Z);

    vs#:=GetModObjParamValS
      (ModObjID$ => GeomID#, ParName$ => 'HP_unit_vec_y');


    Str2XYZ(Str$=>vs#, Sepa$ => ','
    , X$ => r#.UY_X, Y$ => r#.UY_Y, Z$ => r#.UY_Z);

    vs#:=GetModObjParamValS
      (ModObjID$ => GeomID#, ParName$ => 'HP_unit_vec_z');
    SP.BRCM#DUMP.Str2XYZ(Str$=>vs#, Sepa$ => ','
    , X$ => r#.UZ_X, Y$ => r#.UZ_Y, Z$ => r#.UZ_Z);
    
    If Names#.Exists(r#.EQP_NAME) Then
      E$M:='Для устройства с именем ['||r#.EQP_NAME
      ||'], RNAME ['||r#.EQP_RNAME||'], RID = '||to_char(r#.EQP_RID)
      ||' уже имеется одноимённое устройство с RNAME ['||item#.RNAME
      ||'] и RID = '||to_char(item#.RID)||'.';
      D(E$M, 'Error In SP.BRCM#DUMP.BRCM_EQP_PREPARE');
      --r#.EQP_NAME:=r#.EQP_NAME||':ERROR:'||r#.EQP_EID;
    Else
      item#.RID:=r#.EQP_RID;
      item#.RNAME:=r.EQP_RNAME;
      Names#(r#.EQP_NAME):=item#;
    End If;
    
    Insert Into SP.BRCM_EQP Values r#; 

  End Loop;

End BRCM_EQP_PREPARE;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_AREP
Procedure BRCM_AREP_PREPARE
Is
  cnt# BINARY_INTEGER;
  r# SP.BRCM_AREP%ROWTYPE;
  s# SP.MODEL_OBJECT_PAR_S.S%TYPE;
Begin
  Select Count(*) Into cnt#
  From SP.BRCM_AREP;
  
  If cnt#>0 Then Return; End If;
  BRCM_EQP_PREPARE;

  For r In (
    Select  cr.ID As AREP_RID
    , cr.MOD_OBJ_NAME As AREP_RNAME
    , mop11.S As EQP_EID
    , mop12.S As EQP_DESIGN_FILE
    , mo1.ID As AREP_BIN_DATA_ID
    FROM TABLE(GetClassRecords(Prj$AREP)) cr
    
    Inner Join SP.MODEL_OBJECTS mo1
    ON mo1.PARENT_MOD_OBJ_ID=cr.ID
    AND mo1.MOD_OBJ_NAME=PrjF$AREP_BIN_DATA
  
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop11
    ON mop11.MOD_OBJ_ID=cr.ID
    AND mop11.NAME='HP_ELEMENT_ID'
    
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop12
    ON mop12.MOD_OBJ_ID=cr.ID
    AND mop12.NAME='HP_DESIGN_FILE'
  )Loop
    
    r#.AREP_RID := r.AREP_RID;
    r#.AREP_RNAME := r.AREP_RNAME;
    If r.EQP_EID Is Null Then
      r#.EQP_RID := Null;
      r#.EQP_MAX_DIST := Null;
      r#.EQP_FROM_X := Null;
      r#.EQP_FROM_Y := Null;
      r#.EQP_FROM_Z := Null;
    Else
      
      Begin
      SELECT EQP_RID Into r#.EQP_RID
      FROM SP.BRCM_EQP
      WHERE EQP_EID=r.EQP_EID
      AND EQP_DESIGN_FILE=r.EQP_DESIGN_FILE
      ;
      Exception When NO_DATA_FOUND Then
        E$M:='Для AREP_RID = '||r.AREP_RID||', AREP_RNAME ['||r.AREP_RNAME
        ||'],  EQP_EID ['||r.EQP_EID||'], EQP_DESIGN_FILE ['||r.EQP_DESIGN_FILE
        ||'] не найдена единица оборудования в таблице SP.BRCM_EQP.';  

        D(E$M,'Error In SP.BRCM#DUMP.BRCM_AREP_PREPARE');
        --raise_application_error(-20033, E$M);
        
        r#.EQP_RID:=null;
      End;
      
      r#.EQP_MAX_DIST := GetModObjParamValS
      (ModObjID$ => r.AREP_BIN_DATA_ID, ParName$ => 'HP_MaxDistance');
      
      s#:=GetModObjParamValS
      (ModObjID$ => r.AREP_BIN_DATA_ID, ParName$ => 'HP_ObjectFromCoord1');
      
      Str2XYZ(Str$=>s#, Sepa$ => ','
      , X$ => r#.EQP_FROM_X, Y$ => r#.EQP_FROM_Y, Z$ => r#.EQP_FROM_Z);
      
    End If;
    
    Insert Into SP.BRCM_AREP Values r#;   
    
  End Loop;
  
End BRCM_AREP_PREPARE;
--==============================================================================
--Подготавливает словарь RacewayClasses_AA классов кабелепроводных элементов 
--TODO 1. Устроить проверку входных данных на наличие элементов в словаре, т.е.
--любое имя класса кабельной конструкции должно находится среди ключей
--ассоциативного массива RacewayClasses_AA.
--TODO 2. Переписать настоящую процедуру, чтобы она заполняла 
--АА RacewayClasses_AA из схемы KOCEL. В свою очередь, схема  KOCEL должна 
--получать данные из Excel.
Procedure RacewayClassesPrepare
As
Begin
  If RacewayClasses_AA.Count>0 Then
    Return;
  End If;
 
  RacewayClasses_AA('CABLE_CONDUIT_BEND'):=SC_Tube;
  RacewayClasses_AA('CABLE_CONDUIT_STRAIGHT'):=SC_Tube;
  RacewayClasses_AA('CABLE_LADDER_BEND_90_DEG'):=SC_Tray;
  RacewayClasses_AA('CABLE_LADDER_STRAIGHT'):=SC_Tray;
  RacewayClasses_AA('CABLE_LADDER_TEE'):=SC_Tray;
  RacewayClasses_AA('CABLE_ROUTE'):=SC_AirGap;
  RacewayClasses_AA('CABLE_TRAY_BEND_90_DEG'):=SC_Tray;
  RacewayClasses_AA('CABLE_TRAY_STRAIGHT'):=SC_Tray;
  RacewayClasses_AA('CABLE_TRAY_TEE'):=SC_Tray;
  RacewayClasses_AA('RACEWAY_ITEM'):=SC_NotDef;

End RacewayClassesPrepare;

--==============================================================================
--Возвращает класс для элемента кабелепровода 
--т.е. значение параметра /Project_INT_RACEWAY/Record???
--/RACEWAY_BIN_DATA/R5XDATA_???/Export_???/ECDATA_???/Class_???.HP_name
--или null
Function GetRacewayClassRaw(RacewayRecordID$ In Number) Return Varchar2
Is
  i# BINARY_INTEGER:=1;
  a# AA_ModObjName2Number;
Begin
  for r In 
  (
  Select DISTINCT mop5.S 
  From SP.MODEL_OBJECTS mo
  
  Inner Join SP.MODEL_OBJECTS mo1
  ON mo1.PARENT_MOD_OBJ_ID=mo.ID
  AND mo1.MOD_OBJ_NAME=PrjF$RACEWAY_BIN_DATA
  
  Inner Join SP.MODEL_OBJECTS mo2
  ON mo2.PARENT_MOD_OBJ_ID=mo1.ID
  AND mo2.MOD_OBJ_NAME LIKE 'R5XDATA_%'

  Inner Join SP.MODEL_OBJECTS mo3
  ON mo3.PARENT_MOD_OBJ_ID=mo2.ID
  AND mo3.MOD_OBJ_NAME LIKE 'Export_%'

  Inner Join SP.MODEL_OBJECTS mo4
  ON mo4.PARENT_MOD_OBJ_ID=mo3.ID
  AND mo4.MOD_OBJ_NAME LIKE 'ECDATA_%'

  Inner Join SP.MODEL_OBJECTS mo5
  ON mo5.PARENT_MOD_OBJ_ID=mo4.ID
  AND mo5.MOD_OBJ_NAME LIKE 'Class_%'

  Inner Join SP.MODEL_OBJECT_PAR_S mop5
  ON mop5.MOD_OBJ_ID=mo5.ID
  AND mop5.NAME LIKE 'HP_name'

  Where mo.ID=RacewayRecordID$
  ) Loop
    a#(r.S):=i#;    
    i#:=i#+1;
  End Loop;
  If a#.Count=1 Then
    Return a#.First;
  Elsif a#.Count=0 Then
    Return Null;
  Else
    E$M:='Для RACEWAY_RECORD_ID = '||to_char(RacewayRecordID$)
    ||' количество классов '||a#.Count||'. Классы '||a#.First
    ||', '||a#.Next(a#.First)||'.';    
    D(E$M,'ERROR In SP.BRCM#DUMP.GetRacewayClass');
    Return null;
  End If;
End GetRacewayClassRaw;

--==============================================================================
--Возвращает класс сметы для прокладки кабеля вдоль элемента кабелепровода 
--или null или error
Function GetRacewaySmetaClassRaw(RW_RID$ In Number) Return Varchar2
Is
  sc# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  
Begin
  sc#:=GetRacewayClassRaw(RacewayRecordID$ => RW_RID$);
  
  If sc# Is Null Then Return Null; End If;
  
  If RacewayClasses_AA.Exists(sc#) Then
    Return RacewayClasses_AA(sc#);
  End if;
  
  E$M:='Класс '||sc#||'элемента кабелепровода RACEWAY_RECORD_ID ['
    ||to_char(RW_RID$)||'] отсутствует в словаре RacewayClasses_AA.'
    || ' Дополнить документ RacewaySmetaClasses.xls и загрузить его в систему.';
  D(E$M, 'ERROR In SP.BRCM#DUMP.GetRacewaySmetaClass');
  raise_application_error(-20033, E$M);
End GetRacewaySmetaClassRaw;
--==============================================================================
--Возвращает класс сметы для прокладки кабеля вдоль элемента кабелепровода
--или error
Function GetSmetaClass(RW_CLASS$ In varchar2) Return Varchar2
As
Begin
  Return RacewayClasses_AA(RW_CLASS$);
Exception When NO_DATA_FOUND Then
  E$M:='Класс по смете для класса RW_CLASS ['||RW_CLASS$||'] не найден.';
  D(E$M,'Error In SP.BRCM#DUMP.GetSmetaClass');
  raise_application_error(-20033, E$M);
End;
--==============================================================================
-- Возвращает SP.BRCM_RACEWAY.RW_CLASS для соотвествующего RLINE 
Function GetRW_CLASS(RL_RID$ In SP.BRCM_RLINE.RL_RID%TYPE) 
Return SP.BRCM_RACEWAY.RW_CLASS%TYPE
Is
  rv# SP.BRCM_RACEWAY.RW_CLASS%TYPE;
Begin
  Select rw.RW_CLASS Into rv#
  From SP.BRCM_RLINE rl
  Inner Join SP.BRCM_RACEWAY rw
  On rw.RW_RID=rl.RW_RID
  Where rl.RL_RID=RL_RID$
  ;
  Return rv#;  
Exception When OTHERS Then
  Return null;
End GetRW_CLASS;
--==============================================================================
--Возвращает информацию RACEWAY_ITEM по ID записи
Function GetRACEWAY_ITEM_RAW(RW_RID$ In Number)
Return SP.BRCM_RACEWAY%ROWTYPE
Is
  rv# SP.BRCM_RACEWAY%ROWTYPE;
Begin
  SELECT mo.ID as RW_RID,
          mo.MOD_OBJ_NAME as RW_RNAME , 
          mop11.S as RW_EID,
          mop12.S as RW_DESIGN_FILE,
          mop5.S as RW_CLASS
  Into rv#
  FROM SP.MODEL_OBJECTS mo

  LEFT JOIN SP.MODEL_OBJECT_PAR_S mop11
  ON mop11.MOD_OBJ_ID=mo.ID
  AND mop11.NAME='HP_ELEMENT_ID'

  LEFT JOIN SP.MODEL_OBJECT_PAR_S mop12
  ON mop12.MOD_OBJ_ID=mo.ID
  AND mop12.NAME='HP_DESIGN_FILE'

  ------------------------------
  --RW_CLASS
  Left Join SP.MODEL_OBJECTS mo1
  ON mo1.PARENT_MOD_OBJ_ID=mo.ID
  AND mo1.MOD_OBJ_NAME=PrjF$RACEWAY_BIN_DATA
  
  Left Join SP.MODEL_OBJECTS mo2
  ON mo2.PARENT_MOD_OBJ_ID=mo1.ID
  AND mo2.MOD_OBJ_NAME LIKE 'R5XDATA_%'

  Inner Join SP.MODEL_OBJECTS mo3
  ON mo3.PARENT_MOD_OBJ_ID=mo2.ID
  AND mo3.MOD_OBJ_NAME LIKE 'Export_%'

  Inner Join SP.MODEL_OBJECTS mo4
  ON mo4.PARENT_MOD_OBJ_ID=mo3.ID
  AND mo4.MOD_OBJ_NAME LIKE 'ECDATA_%'

  Inner Join SP.MODEL_OBJECTS mo5
  ON mo5.PARENT_MOD_OBJ_ID=mo4.ID
  AND mo5.MOD_OBJ_NAME LIKE 'Class_%'

  Inner Join SP.MODEL_OBJECT_PAR_S mop5
  ON mop5.MOD_OBJ_ID=mo5.ID
  AND mop5.NAME LIKE 'HP_name'
  --RW_CLASS
  ------------------------------

  Where mo.ID=RW_RID$
  ;
  Return rv#;
End;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_RACEWAY
Procedure BRCM_RACEWAY_PREPARE
As
  cnt# BINARY_INTEGER;
  r# SP.BRCM_RACEWAY%ROWTYPE;
  --idx# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
  
  Select Count(*) Into cnt#
  From SP.BRCM_RACEWAY;
  
  If cnt#>0 Then
    Return;
  End If;

  RacewayClassesPrepare;
  
  For r In
  (
    SELECT mo2.ID As RACEWAY_RECORD_ID
    FROM SP.MODEL_OBJECTS mo1

    INNER JOIN SP.MODEL_OBJECTS mo2  --Records
    ON mo2.PARENT_MOD_OBJ_ID=mo1.ID

    WHERE mo1.MOD_OBJ_NAME=Prj$RACEWAY
    AND mo1.MODEL_ID=DumpModelID
  ) Loop

    r#:=GetRACEWAY_ITEM_RAW(RW_RID$ => r.RACEWAY_RECORD_ID );

    Insert Into SP.BRCM_RACEWAY Values r#; 
    cnt#:=cnt#+1;
    
  End Loop;

  D('В таблицу SP.BRCM_RACEWAY добавлено '||cnt#||' записей. Prj$RACEWAY ['
  ||Prj$RACEWAY||'], DumpModelID = '||to_char(DumpModelID)||'.'
  ,'Info From SP.BRCM#DUMP.BRCM_RACEWAY_PREPARE');
  
End BRCM_RACEWAY_PREPARE;

--==============================================================================
-- Возвращает информацию об элементе Routing Line по RLINE_DATA_ID 
-- поле RW_CLASS не определено (null)
-- Рабочая лошадка
Function GetRLINE_ITEM(RLineDataID$ In Number, RecordName$ In Varchar2)
Return SP.BRCM_RLINE%ROWTYPE
Is
rv# SP.BRCM_RLINE%ROWTYPE;
XYZ1# SP.MODEL_OBJECT_PAR_S.S%TYPE;
XYZ2# SP.MODEL_OBJECT_PAR_S.S%TYPE;
Begin

    Select mo1.PARENT_MOD_OBJ_ID as RL_RID 
    , RecordName$ As RL_RNAME
      ,mop.S As RL_EID
      , mop12.S As RL_DESIGN_FILE
      , mop1.S As "HP_catalog", mop2.S As "HP_system", mop3.S As "HP_variant"
      , mop4.S As XYZ1
      , mop5.S As XYZ2
      , mop4a.S As "HP_BendAngle", mop5a.S As "HP_BendRadius"
      , mop6.S As HP_RWID, mop7.S As "HP_RWCategory", mop7a.S As "HP_RWCategory2"
      , mop8.S As "HP_description", mop9.S As "HP_ec:GUID"
      , mop10.S As "HP_fitting"
      Into
        rv#.RL_RID
      , rv#.RL_RNAME
      , rv#.RL_EID
      , rv#.RL_DESIGN_FILE
      , rv#."HP_catalog", rv#."HP_system", rv#."HP_variant"
      , XYZ1#, XYZ2#
      , rv#."HP_BendAngle", rv#."HP_BendRadius"
      , rv#.HP_RWID, rv#."HP_RWCategory", rv#."HP_RWCategory2"
      , rv#."HP_description", rv#."HP_ec:GUID", rv#."HP_fitting"

      FROM SP.MODEL_OBJECTS mo1
      
      INNER JOIN SP.MODEL_OBJECT_PAR_S mop
      ON mop.MOD_OBJ_ID=mo1.PARENT_MOD_OBJ_ID
      AND mop.NAME='HP_ELEMENT_ID'
      
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop12
      ON mop12.MOD_OBJ_ID=mo1.PARENT_MOD_OBJ_ID
      AND mop12.NAME='HP_DESIGN_FILE'

      INNER JOIN SP.MODEL_OBJECT_PAR_S mop1
      ON mop1.MOD_OBJ_ID=mo1.ID
      AND mop1.NAME='HP_catalog'
      INNER JOIN SP.MODEL_OBJECT_PAR_S mop2
      ON mop2.MOD_OBJ_ID=mo1.ID
      AND mop2.NAME='HP_system'
      INNER JOIN SP.MODEL_OBJECT_PAR_S mop3
      ON mop3.MOD_OBJ_ID=mo1.ID
      AND mop3.NAME='HP_variant'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop4
      ON mop4.MOD_OBJ_ID=mo1.ID
      AND mop4.NAME='HP_Coord1'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop5
      ON mop5.MOD_OBJ_ID=mo1.ID
      AND mop5.NAME='HP_Coord2'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop4a
      ON mop4a.MOD_OBJ_ID=mo1.ID
      AND mop4a.NAME='HP_BendAngle'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop5a
      ON mop5a.MOD_OBJ_ID=mo1.ID
      AND mop5a.NAME='HP_BendRadius'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop6
      ON mop6.MOD_OBJ_ID=mo1.ID
      AND mop6.NAME='HP_RWID'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop7
      ON mop7.MOD_OBJ_ID=mo1.ID
      AND mop7.NAME='HP_RWCategory'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop7a
      ON mop7a.MOD_OBJ_ID=mo1.ID
      AND mop7a.NAME='HP_RWCategory2'
    
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop8
      ON mop8.MOD_OBJ_ID=mo1.ID
      AND mop8.NAME='HP_description'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop9
      ON mop9.MOD_OBJ_ID=mo1.ID
      AND mop9.NAME='HP_ec:GUID'
      LEFT JOIN SP.MODEL_OBJECT_PAR_S mop10
      ON mop10.MOD_OBJ_ID=mo1.ID
      AND mop10.NAME='HP_fitting'  
      
      WHERE mo1.ID=RLineDataID$;

    Str2XYZ(Str$ => XYZ1#, Sepa$ => ','
    , X$ => rv#."X1", Y$ => rv#."Y1", Z$ => rv#."Z1");
    Str2XYZ(Str$ => XYZ2#, Sepa$ => ','
    , X$ => rv#."X2", Y$ => rv#."Y2", Z$ => rv#."Z2");

    rv#.LENGTH:=SQRT(Dist2(rv#.X1, rv#.Y1, rv#.Z1, rv#.X2, rv#.Y2, rv#.Z2));
    
    
  Return rv#;
End GetRLINE_ITEM;
--==============================================================================
/*
--Определение значения поля COURSE_NAME для RLine Items
Procedure RLINE_COURSE_NAME_DEFINE_obso
As
  Cursor cRLU 
  Is
  Select rl.RL_RID, rl.RW_RID, rw.RW_CLASS, rl.HP_RWID, rl.COURSE_NAME
    From BRCM_RLINE rl
    Inner Join BRCM_RACEWAY rw
    ON rw.RW_RID=rl.RW_RID
    For Update Of rl.COURSE_NAME
    ;
    
  RL_RID# SP.BRCM_RLINE.RL_RID%TYPE;
  RW_CLASS# SP.BRCM_RACEWAY.RW_CLASS%TYPE;
  HP_RWID# SP.BRCM_RLINE.HP_RWID%TYPE;
  COURSE_NAME# SP.BRCM_RLINE.COURSE_NAME%TYPE;
  
  smezh#  AA_ModObjName2Name;
  idx# Varchar2(128);
Begin
  --Шаг 1. Переименование COURCE_NAME для TEEs
  --Для каждого элемента 1 тройника находим смежное ребро другого элемента 2,
  -- не являющегося элементом тройника, и для него (элемента 1) задаём новое 
  -- значение поля COURSE_NAME
  
  For r0 In cRLU Loop
  
    If IsTee(RW_CLASS$ => r0.RW_CLASS)=1 Then
      smezh#.Delete;
      For r2 In (
        Select rl.RL_RID, rl.HP_RWID
        From SP.BRCM_ADJ re
        Inner Join SP.BRCM_RLINE rl
        ON rl.RL_RID=re.RL_RID2
        And rl.RW_RID<>r0.RW_RID 
        Where re.RL_RID1=r0.RL_RID
      ) Loop
        smezh#(r2.RL_RID):=r2.HP_RWID;
        COURSE_NAME#:=r2.HP_RWID;
      End Loop;

      If smezh#.Count= 1 Then
        If Not COURSE_NAME# Is Null Then
          If COURSE_NAME# In ('Air Gap') Then
            --Если Tee граничит c Air Gap, то его COURSE_NAME не меняется
            COURSE_NAME#:=Null;
          Else
            D('Задано новое COURSE_NAME ['||COURSE_NAME#||']'
            ||' элемента тройника RL_RID = '
            ||to_char(r0.RL_RID)||'] вместо старого ['||r0.HP_RWID||'].'
            , 'Info for SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
          End If;
        End If;
      ElsIf Smezh#.Count = 0 Then
        D('Не найден смежный элемент к элементу тройника RL_RID = '
        ||to_char(r0.RL_RID)||'.'
        ,'Error In SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
        COURSE_NAME#:=Null;
      Else
        E$M:='К элементу тройника RL_RID '||to_char(r0.RL_RID)
        ||' найдено смежных элементов в количестве '||smezh#.Count
        ||'шт. RL_RID найденных смежных элементов: ';
        idx#:= smezh#.First;
        While Not idx# Is Null Loop
          If idx#=smezh#.First Then
            E$M:=E$M||idx#;
          Else
            E$M:=E$M||', '||idx#;
          End If;
          idx#:=smezh#.Next(idx#);
        End Loop;
        E$M:=E$M||'.';
        D(E$M, 'Error In SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
        COURSE_NAME#:=Null;
      End If;
    Else
      COURSE_NAME#:=r0.HP_RWID;
    End If;
    
    If Not COURSE_NAME# Is Null Then
      
      Update SP.BRCM_RLINE Set COURSE_NAME=COURSE_NAME#
      Where Current Of cRLU
      ;
    End If;    
  End Loop;
End RLINE_COURSE_NAME_DEFINE_obso;
*/
--==============================================================================
Function to_str(r$ In SP.BRCM_RLINE%ROWTYPE) Return Varchar2
Is
Begin
  Return 'RL_RID = '||to_char(r$.RL_RID)||', RL_RNAME ['||r$.RL_RNAME
  ||'], RL_EID ['||r$.RL_EID||'], RL_DESIGN_FILE '||r$.RL_DESIGN_FILE
  ||', HP_RWID ['||r$.HP_RWID||'], HP_description ['||r$."HP_description"
  ||']';
End;
--==============================================================================
-- Определение значения поля COURSE_NAME для RLine Items
-- Именно:
-- выбираем все RLine, соответствующие лоткам, у которых COURSE_NAME Is Null
-- для них назначаем COURSE_NAME := HP_RWID, если Not HP_RWID is Null
Procedure RLINE_COURSE_NAME_DEFINE_
As
  --здемент кластера
  Type R_CLUSTER_ELEMENT Is Record
  (
    RL_RID Number,
    COURSE_NAME SP.BRCM_RLINE.COURSE_NAME%TYPE,
    PARALLEL SP.BRCM_ADJ.PARALLEL%TYPE
  );
  
  Type AA_CLUSTER_ELEMENTS Is Table Of R_CLUSTER_ELEMENT
          Index By BINARY_INTEGER;
  
  --Кластер
  Type R_CLUSTER Is Record
  (
    pt SP.VEC.AA_Vector, --центр кластера
    elems AA_CLUSTER_ELEMENTS --массив элементов кластера 
  );

  
  Type AA_CLUSTERS Is Table Of R_CLUSTER Index By BINARY_INTEGER;
  
  -- Список кластеров, смежных RLINEs к текущему RLINE.
  -- Кластеры соответствуют концам текущей безымянной (COURSE_NAME Is Null) 
  -- RLINE, поэтому у RLINE может быть ноль, один или два смежных кластера,
  -- причем точки кластеров лежат в эпсилон-окрестности концов RLINE.
  clusters_aa# AA_CLUSTERS;  
  
  Cursor cRLU 
  Is
  Select rl.RL_RID, rl.RW_RID
        , rw.RW_CLASS, rl.HP_RWID, rl.COURSE_NAME, rl.RL_RNAME
    From BRCM_RLINE rl
    Inner Join BRCM_RACEWAY rw
    ON rw.RW_RID=rl.RW_RID
    For Update Of rl.COURSE_NAME
    ;
    
  COURSE_NAME# SP.BRCM_RLINE.COURSE_NAME%TYPE;
  rline# SP.BRCM_RLINE%ROWTYPE;  
  
  --RL_RID->RW_CLASS, у которых COURSE_NAME is Null;
  no_name_aa# AA_ModObjName2Name;
  --индекс массива no_name_aa#
  nn_rid# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  no_name_cnt# BINARY_INTEGER;
  ii# BINARY_INTEGER;
  ee# BINARY_INTEGER;
  smeta_class# Varchar2(20);
  
  --Добавляет к кластерам очередной элемент
  Procedure AddClusterElement(clstrs$ In Out NoCopy AA_CLUSTERS
    , pt$ In SP.VEC.AA_Vector
    , RL_RID$ In Number, COURSE_NAME$ In Varchar2, PARALLEL$ Number)
  As
    idx# BINARY_INTEGER;
    ce# R_CLUSTER_ELEMENT;
    ci# R_CLUSTER;
  Begin
    ce#.RL_RID:=RL_RID$;
    ce#.COURSE_NAME := COURSE_NAME$;
    ce#.PARALLEL := PARALLEL$;
    idx#:=clstrs$.First;
    While Not idx# Is Null Loop
      If SP.VEC.EQ2_Vectors(clstrs$(idx#).pt,pt$,ZeroVector#Eps) Then
        clstrs$(idx#).elems(clstrs$(idx#).elems.Count+1):=ce#;
        Return;
      End If;
      idx#:=clstrs$.Next(idx#);
    End Loop;
    ci#.pt:=pt$;
    ci#.elems(1):=ce#;
    clstrs$(clstrs$.Count+1):=ci#;
  End;
Begin
  --  Шаг 1. Если RLine не есть элемент разветвителя (тройника) и имеет непустое 
  --  HP_RWID, то COURSE_NAME := HP_RWID
  --  Остальные элементы типа SC_Tray заносятся в рабочий массив no_name_aa#
  For r0 In cRLU Loop
    smeta_class# := RacewayClasses_AA(r0.RW_CLASS);
    If smeta_class# = SC_Tray Then
      
      If IsTee(RW_CLASS$ => r0.RW_CLASS)=1 Then
        no_name_aa#(r0.RL_RID):=r0.RW_CLASS;
        goto Continue_r0;
      End If;
      
      If r0.HP_RWID Is Null Then
        no_name_aa#(r0.RL_RID):=r0.RW_CLASS;
        goto Continue_r0;
      Else
        Update SP.BRCM_RLINE Set COURSE_NAME=r0.HP_RWID
        Where Current Of cRLU
        ;
      End If;
    ElsIf smeta_class# = SC_AirGap then
      --Если RLINE есть Air Gap, то COURSE_NAME := HP_RWID
      If Not r0.HP_RWID Is Null Then
        Update SP.BRCM_RLINE Set COURSE_NAME=r0.HP_RWID
        Where Current Of cRLU
        ;
      End If;
    End If;
    <<Continue_r0>> null;
  End Loop;  
  
  no_name_cnt#:=no_name_aa#.Count+1;
  If no_name_cnt# < 2 Then Return; End If;
  
  --  Шаг 2. Если RLINE имеет по крайней мере один смежный с ним другой RLINE
  While no_name_cnt# > no_name_aa#.Count Loop
    no_name_cnt# := no_name_aa#.Count;
    
    --цикл формирования кластеров 
    nn_rid#:=no_name_aa#.First;
    While Not nn_rid# Is Null Loop
      clusters_aa#.Delete;
      COURSE_NAME#:=Null;
      
      For r2 In (
        Select RL.RL_RID, RL.COURSE_NAME
        , re.X, re.Y, re.Z, re.PARALLEL
        , rw.RW_CLASS
        From SP.BRCM_ADJ re
        Inner Join SP.BRCM_RLINE RL
        ON RL.RL_RID=re.RL_RID2
        Inner Join SP.BRCM_RACEWAY rw
        On rw.RW_RID=RL.RW_RID
        Where re.RL_RID1=nn_rid#
      ) Loop

        If RacewayClasses_AA(r2.RW_CLASS) = SC_Tray Then
          AddClusterElement(clusters_aa#, SP.VEC.CreateV3(r2.X,r2.Y,r2.Z)
            , r2.RL_RID, r2.COURSE_NAME, r2.PARALLEL);
        End If;

      End Loop;

      If clusters_aa#.Count<1 Then
        Select * Into rline# 
        From SP.BRCM_RLINE
        Where RL_RID=nn_rid#
        ;
        
        D('Элемент RL_RID ['||to_char(nn_rid#)||'], RL_RNAME ['
        ||rline#.RL_RNAME||'], RW_CLASS ['||no_name_aa#(nn_rid#)
        ||'] не имеет смежных. COURSE_NAME ему не присваивается.'
        , 'Info for SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
        
        no_name_aa#.Delete(nn_rid#);
        goto Continue_cls;
      End If;

      If clusters_aa#.Count>2 Then
        Select * Into rline# 
        From SP.BRCM_RLINE
        Where RL_RID=nn_rid#
        ;
        
        D('У элемента RL_RID ['||to_char(nn_rid#)||'], RL_RNAME ['
        ||rline#.RL_RNAME||'], RW_CLASS ['||no_name_aa#(nn_rid#)
        ||'] обнаружено '||clusters_aa#.Count
        ||' кластеров смежных элементов. COURSE_NAME ему не присваивается.'
        , 'Error In SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
        
        no_name_aa#.Delete(nn_rid#);
        goto Continue_cls;
      End If;
      
      ii#:=clusters_aa#.First;
      While Not ii# Is Null Loop
        If clusters_aa#(ii#).elems.Count =1 Then
          -- смежный элемент единственный, разветвлений нет, 
          -- берём его имя, если оно непустое
          COURSE_NAME#:=clusters_aa#(ii#).elems(1).COURSE_NAME;
          If Not COURSE_NAME# Is Null Then
            Update SP.BRCM_RLINE Set COURSE_NAME=COURSE_NAME#
            Where RL_RID=nn_rid#
            ;
            no_name_aa#.Delete(nn_rid#);
            goto Continue_cls;
          End If;
          goto Continue_ele;
        End If;
        
        -- смежных элементов несколько, выбираем паралельный и 
        -- берём его имя, если оно непустое
        ee#:=clusters_aa#(ii#).elems.First;
        COURSE_NAME#:=Null;
        While Not ee# Is Null Loop
          If clusters_aa#(ii#).elems(ee#).PARALLEL = 1 Then
            COURSE_NAME#:=clusters_aa#(ii#).elems(ee#).COURSE_NAME;
            Exit When True;
          End If;
          ee#:=clusters_aa#(ii#).elems.Next(ee#);
        End Loop;
        If Not COURSE_NAME# Is Null Then
          Update SP.BRCM_RLINE Set COURSE_NAME=COURSE_NAME#
          Where RL_RID=nn_rid#
          ;
          no_name_aa#.Delete(nn_rid#);
        End If;

        <<Continue_ele>>
        ii#:=clusters_aa#.Next(ii#);

      End Loop;
      
      <<Continue_cls>>
      nn_rid#:=no_name_aa#.Next(nn_rid#);
    End Loop;
    
    
  End Loop;

  If no_name_aa#.Count>0 Then
    -- Отчет о безымянных RLINEs типа лоток, которых в идеале не должно быть
    E$M:='RLINEs, у которых COURSE_NAME Is Null:'||CHR(13)||CHR(10);
    nn_rid#:=no_name_aa#.First;
    While Not nn_rid# Is Null Loop

      Select * Into rline# 
      From SP.BRCM_RLINE
      Where RL_RID=nn_rid#
      ;
      
      D_Long(E$M,to_str(rline#)||CHR(13)||CHR(10)
      ,'Report From SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');

      nn_rid#:=no_name_aa#.Next(nn_rid#);
    End Loop;
    D(E$M,'Report From SP.BRCM#DUMP.RLINE_COURSE_NAME_DEFINE');
  End If;

End RLINE_COURSE_NAME_DEFINE_;
--==============================================================================
-- Определение значения поля SHELF_NUM для RLine Items
-- Именно:
Procedure RLINE_SHELF_NUM_DEFINE_
As
  SubType T_RID Is Varchar2(60);

  --Минимальная иформация об RLINEs
  Type R_RLINE_E Is Record
  (
    RL_RID Number,
    X1 Number,
    Y1 Number,
    Z1 Number,
    X2 Number,
    Y2 Number,
    Z2 Number,
    DIRECTION_TYPE Varchar2(1)
  );
  
  Type AA_RL_RIDs Is Table Of R_RLINE_E Index By T_RID;
  
  --кластер направления
  --В кластере направления содержатся цепочки смежных RLINEs.
  --количество таких цепочек определяет количество кластеров
  Type R_COURSE_CLUSTER Is Record
  (
    --элементы кластера
    RL_RID_AA AA_RL_RIDs,
    --номер кластера, он же номер полки
    CLSTR_NUM SP.BRCM_RLINE.SHELF_NUM%TYPE
    
  );
  
  
  Type AA_COURSE_CLUSTERS Is Table Of R_COURSE_CLUSTER 
  Index By BINARY_INTEGER;
  
  --Напраление
  --Вертикальный - все RLINEs кластера вертикальные
  --Горизонтальный - все RLINEs кластера горизонтальные
  --Другой - не попадает ни в одну из предшествующих категорий.
  Type R_COURSE Is Record
  (
    --Тип направления 'V',            'H',              'D',      'Z': 
    --                'Вертикальный', 'Горизонтальный', 'Другой', 'Нулевой'
    COURSE_TYPE Varchar2(1), 
    --массив кластеров, в нулевом элементе массива поначалу содержатся все 
    --элементы направления, которые затем распределяются по кластерам.
    clst_aa AA_COURSE_CLUSTERS  
  );

  --массив кластеров, индексированный значениями COURSE_NAME
  Type AA_COURSES Is Table Of R_COURSE 
  Index By SP.BRCM_RLINE.COURSE_NAME%TYPE;

  course_aa# AA_COURSES;
  --индекс для массива cour_aa#
  course_name# SP.BRCM_RLINE.COURSE_NAME%TYPE;
  course# R_COURSE;
  
  vEZ SP.VEC.AA_Vector;--Единичный вертикальный вектор (направлен вверх)
  
  --добавляет информацию о направлении в массив cour_aa#
  --  в массивах cour_aa#(...).clst_aa(0).RL_RID_AA в качестве значений индексов
  --  содержится множество всех значений RL_RIDs. которые требуется распределить
  --  по кластерам
  Procedure AddCourse(r$ In SP.BRCM_RLINE%ROWTYPE)
  As
    cour# R_COURSE;
    cc# R_COURSE_CLUSTER;
    --Direction type {горизонтальны. вертикальный, нулевой, другой}
    dt# Varchar2(1);
    re# R_RLINE_E;
  Begin
    re#.RL_RID:=r$.RL_RID;
    re#.X1:=r$.X1;
    re#.Y1:=r$.Y1;
    re#.Z1:=r$.Z1;
    re#.X2:=r$.X2;
    re#.Y2:=r$.Y2;
    re#.Z2:=r$.Z2;
    
    re#.DIRECTION_TYPE := SP.VEC.GetDirectionType(
        SP.VEC.CreateV3(r$.X2-r$.X1,r$.Y2-r$.Y1,r$.Z2-r$.Z1)
        , ZeroVector#Eps, Parallel#Eps );
        
    If course_aa#.Exists(r$.COURSE_NAME) Then
      course_aa#(r$.COURSE_NAME).clst_aa(0).RL_RID_AA(r$.RL_RID):=re#; 
    Else
      cc#.CLSTR_NUM:=Null;
      cc#.RL_RID_AA(r$.RL_RID):=re#;

      cour#.COURSE_TYPE:=Null;
      cour#.clst_aa(0):=cc#;

      course_aa#(r$.COURSE_NAME):=cour#;
    End If;
  End AddCourse;
  
  --  Стирает последний элемент стека rid_aa# и возвращает его
  --  Если стек пуст, то возвращает Null
  Function pop(rid_aa# In Out NoCopy AA_RL_RIDs) Return R_RLINE_E
  Is
    idx# T_RID;
    rv_p# R_RLINE_E; 
  Begin 
    idx#:=rid_aa#.Last;
    
    If idx# Is Null Then Return rv_p#; End If;
    
    rv_p#:=rid_aa#(idx#);
    rid_aa#.Delete(idx#);
    
    Return rv_p#;
  End pop;
  
  --возвращает DIRECTION TYPE направления
  --на вход подаётся отображение RL_RID -> DIRECTTION_TYPE направления 
  Function GetDirectionType(rid_aa$ In AA_RL_RIDs) Return Varchar2
  Is
    Type AA_DirTypes Is Table Of BINARY_INTEGER Index By Varchar2(1);
    --массив типов направлений
    dir_types_aa# AA_DirTypes;
    rv_dt# varchar2(1); 
    rid# T_RID;
    re# R_RLINE_E;
  Begin
    rv_dt#:='D';
    rid#:=rid_aa$.First;
    While Not rid# Is Null Loop
      re#:=rid_aa$(rid#);
      If dir_types_aa#.Exists(re#.DIRECTION_TYPE) then
        dir_types_aa#(re#.DIRECTION_TYPE):=dir_types_aa#(re#.DIRECTION_TYPE)+1;
      Else
        dir_types_aa#(re#.DIRECTION_TYPE):=1;
      End If;
      rid#:=rid_aa$.Next(rid#);
    End Loop;
    
    
    If dir_types_aa#.Count= 1 Then
      --выявлен один тип направлений
      rv_dt#:=dir_types_aa#.First;
      If rv_dt# = 'Z' Then
        rv_dt#:='D';
      End If;
      Return rv_dt#;
    End If;
    
    If dir_types_aa#.Count= 2 Then
      --выявлено два типа направлений
      If dir_types_aa#.Exists('Z') Then
        --исключаем нулевые направления, остаётся один тип
        dir_types_aa#.Delete('Z');
        rv_dt#:=dir_types_aa#.First;
        Return rv_dt#;
      End If;
    End If;
    -- более двух типов направлений -> неопределённость 'D'
    Return rv_dt#;
  End GetDirectionType;
  
  --разбивает направление на кластеры
  Function SplitToClusters(rc$ In R_COURSE) 
  Return R_COURSE
  Is
    rvc# R_COURSE;
    rid_aa# AA_RL_RIDs;
    clst_num# BINARY_INTEGER;
    clst_idx# BINARY_INTEGER;
    rid# T_RID;
    direction_type# varchar2(1);
    re# R_RLINE_E;
  Begin
    rid_aa#:=rc$.clst_aa(0).RL_RID_AA;
    
    rvc#.COURSE_TYPE:=GetDirectionType(rid_aa$ => rid_aa#);
    re#:=pop(rid_aa#);
    rvc#.clst_aa(1).RL_RID_AA(re#.RL_RID):=re#;
    
    re#:=pop(rid_aa#);
    
    While Not re#.RL_RID Is Null Loop
      clst_num#:=Null;
      --цикл поиска смежных элементов с rl_rid# среди кластеров
      clst_idx#:=rvc#.clst_aa.First;
      While Not clst_idx# Is Null Loop
        rid#:=rvc#.clst_aa(clst_idx#).RL_RID_AA.First;
        While Not rid# Is Null Loop
          If IsAdjacent(re#.RL_RID, rid#) Then
            --смежный найден
            If clst_num# Is Null Then
              --смежный найден впервые
              clst_num#:=clst_idx#;
              --запись ребра rl_rid# в кластер к rid#
              rvc#.clst_aa(clst_idx#).RL_RID_AA(re#.RL_RID):=re#;
            Else
              -- копирование элементов кластера clst_idx# в кластер clst_num#
              rid#:=rvc#.clst_aa(clst_idx#).RL_RID_AA.First;
              While Not rid# Is Null Loop
                rvc#.clst_aa(clst_num#).RL_RID_AA(rid#):=
                          rvc#.clst_aa(clst_idx#).RL_RID_AA(rid#);
                rid#:=rvc#.clst_aa(clst_idx#).RL_RID_AA.Next(rid#);
              End Loop;              
              -- удаляем скопированный кусочек кластера
              rvc#.clst_aa.Delete(clst_idx#);
            End If;
            Exit When true;  --выход из цикла по rid#
          End If;
          rid#:=rvc#.clst_aa(clst_idx#).RL_RID_AA.Next(rid#);
        End Loop;
        
        clst_idx#:=rvc#.clst_aa.Next(clst_idx#);
      End Loop;

      If clst_num# Is Null Then
        rvc#.clst_aa(rvc#.clst_aa.Last+1).RL_RID_AA(re#.RL_RID):=re#;
      End If;
        
      re#:=pop(rid_aa#);
    End Loop;

    Return rvc#;
  End SplitToClusters;
  
  --Определение номеров полок горизонтальных стеллажей.
  Procedure DefineHorizontalShelfNums(clst_aa$ In Out NoCopy AA_COURSE_CLUSTERS)
  As
    Type R_ZSEGMENT Is Record
    (
      Z_MIN Number,
      Z_MAX Number,
      ORDINAL BINARY_INTEGER
    );

    Type AA_ZSEGMENTS Is Table Of R_ZSEGMENT Index By BINARY_INTEGER;
    
    idx# BINARY_INTEGER;
    idy# BINARY_INTEGER;
    rid# T_RID;
    re# R_RLINE_E;
    zs# R_ZSEGMENT;
    zsy# R_ZSEGMENT;
    zsegment_aa# AA_ZSEGMENTS;
    zsegment_aa_memo# AA_ZSEGMENTS;
    TZMIN# SP.TNUMBERS;
    TZMIN_ORDERED# SP.TNUMBERS;
    zmin_ordered_aa# AA_ModObjName2Number;
  Begin
    If clst_aa$.Count<2 Then
      Return;
    End If;
    
    idx#:=clst_aa$.First;
    While Not idx# Is Null Loop
      rid#:=clst_aa$(idx#).RL_RID_AA.First;
      zs#.Z_MIN:=Max$Number;
      zs#.Z_MAX:=Min$Number;
      
      While Not rid# Is Null Loop
        re#:=clst_aa$(idx#).RL_RID_AA(rid#);
        
        If zs#.Z_MIN > re#.Z1 Then
          zs#.Z_MIN:=re#.Z1;
        End If;
        
        If zs#.Z_MIN > re#.Z2 Then
          zs#.Z_MIN:=re#.Z2;
        End If;
        
        If zs#.Z_MAX < re#.Z1 Then
          zs#.Z_MAX:=re#.Z1;
        End If;

        If zs#.Z_MAX < re#.Z2 Then
          zs#.Z_MAX:=re#.Z2;
        End If;

        rid#:=clst_aa$(idx#).RL_RID_AA.Next(rid#);
      End Loop;
      
      zsegment_aa#(idx#):=zs#;
      
      idx#:=clst_aa$.Next(idx#);
    End Loop;
    
    zsegment_aa_memo#:=zsegment_aa#;
    
    --объединяем все пересекающиеся интервалы в один
    idx#:=zsegment_aa#.First;
    While Not idx# Is Null Loop
      zs#:=zsegment_aa#(idx#);
      idy#:=zsegment_aa#.Next(idx#);
      While Not idy# Is Null Loop
        zsy#:=zsegment_aa#(idy#);
        
        If zs#.Z_MIN>zsy#.Z_MAX Then
          Null;
        ElsIf zs#.Z_MAX<zsy#.Z_MIN Then
          Null;
        Else
          If zs#.Z_MAX<zsy#.Z_MAX Then
            zs#.Z_MAX:=zsy#.Z_MAX;
          End If;

          If zs#.Z_MIN>zsy#.Z_MIN Then
            zs#.Z_MIN:=zsy#.Z_MIN;
          End If;
          
          zsegment_aa#(idx#):=zs#;
          zsegment_aa#.Delete(idy#);
        End If;
        
        idy#:=zsegment_aa#.Next(idy#);
      End Loop;
      idx#:=zsegment_aa#.Next(idx#);
    End Loop;

    TZMIN# := SP.TNUMBERS();
    idx#:=zsegment_aa#.First;
    While Not idx# Is Null Loop
      TZMIN#.Extend;
      TZMIN#(TZMIN#.Last):=zsegment_aa#(idx#).Z_MIN;
      idx#:=zsegment_aa#.Next(idx#);
    End Loop;
    
    Select * 
    BULK COLLECT INTO TZMIN_ORDERED#
    FROM TABLE(TZMIN#)
    ORDER BY 1 DESC;
    
    For k in 1..TZMIN_ORDERED#.Count Loop
      zmin_ordered_aa#(TZMIN_ORDERED#(k)):=k;
    End Loop;
    
    idx#:=zsegment_aa#.First;
    While Not idx# Is Null Loop
      zsegment_aa#(idx#).ORDINAL:=zmin_ordered_aa#(zsegment_aa#(idx#).Z_MIN);
      idx#:=zsegment_aa#.Next(idx#);
    End Loop;
    
    idx#:=zsegment_aa_memo#.First;
    While Not idx# Is Null Loop
      if zsegment_aa#.Exists(idx#) Then
        --zsegment_aa_memo#(idx#).ORDINAL:=zsegment_aa#(idx#).ORDINAL;
        clst_aa$(idx#).CLSTR_NUM:=zsegment_aa#(idx#).ORDINAL;
        
      Else
        zs#:=zsegment_aa_memo#(idx#);
        idy#:=zsegment_aa#.First;
        While Not idy# Is Null Loop
          zsy#:=zsegment_aa#(idy#);
          if zsy#.Z_MIN <= zs#.Z_MIN and zsy#.Z_MAX <= zs#.Z_MAX then
--            zs#.ORDINAL:=zsy#.ORDINAL;
--            zsegment_aa_memo#(idx#):=zs#;
            clst_aa$(idy#).CLSTR_NUM:=zsy#.ORDINAL;
            Exit When True;  --выход из цикла по idy#
          End If;
          idy#:=zsegment_aa#.Next(idy#);
        End Loop;
      End If;
      idx#:=zsegment_aa_memo#.Next(idx#);
    End Loop;
    
  End DefineHorizontalShelfNums;
  
  --  Задаёт значения SP.BRCM_RLINE.SHELF_NUM для RLINEs, 
  --  входящих в кластеры из clst_aa$
  Procedure UpdateShelfNums(clst_aa$ In AA_COURSE_CLUSTERS)
  As
    idx# BINARY_INTEGER;
    SHELF_NUM# SP.BRCM_RLINE.SHELF_NUM%TYPE;
    rid# T_RID;
  Begin
    idx#:=clst_aa$.First;
    While Not idx# Is Null Loop
      SHELF_NUM#:=clst_aa$(idx#).CLSTR_NUM;
      If Not SHELF_NUM# Is Null Then
        rid#:=clst_aa$(idx#).RL_RID_AA.First;
        While Not rid# Is Null Loop
          
          Update SP.BRCM_RLINE Set SHELF_NUM=SHELF_NUM#
          Where RL_RID=rid#
          ;
  
          rid#:=clst_aa$(idx#).RL_RID_AA.Next(rid#);
        End Loop;
      End If;
      idx#:=clst_aa$.Next(idx#);
    End Loop;
  End UpdateShelfNums;
Begin
  vEZ:=SP.VEC.CreateV3(0.0,0.0,1.0);
  
  --цикл инициализации массива направлений
  --все RL_RIDs, относящиеся к конкретному направлению, записаны в clst_aa(0) 
  For r In(
    Select * From SP.BRCM_RLINE
    Where Not COURSE_NAME Is Null
    And COURSE_NAME <> 'Air Gap'
  )Loop
  
    AddCourse(r);

  End Loop;
  
  D('Всего направлений '||to_char(course_aa#.Count)||'.'
    ,'Info From SP.BRCM#DUMP.RLINE_SHELF_NUM_DEFINE');

  If course_aa#.Count < 1 Then Return; End If;
  
  course_name#:=course_aa#.First;
  While Not course_name# Is Null Loop
    course#:=SplitToClusters(course_aa#(course_name#));

    If course#.COURSE_TYPE='H' then
      D('Направление ['||course_name#||'] состоит из '
      ||to_char(course#.clst_aa.Count)||' горизонтальных кластеров. '
      ,'DEBUG RLINE_SHELF_NUM_DEFINE_');
      DefineHorizontalShelfNums(course#.clst_aa);
      UpdateShelfNums(course#.clst_aa);
    ElsIf course#.COURSE_TYPE='V' Then
      D('Направление ['||course_name#||'] состоит из '
      ||to_char(course#.clst_aa.Count)||' вертикальных кластеров. '
      ,'DEBUG RLINE_SHELF_NUM_DEFINE_');
    Else
      D('Направление ['||course_name#||'] состоит из '
      ||to_char(course#.clst_aa.Count)||' кластеров нетипичных. '
      ,'DEBUG RLINE_SHELF_NUM_DEFINE_');
    End if;
    
    course_aa#(course_name#):= course#;
      
    course_name#:=course_aa#.Next(course_name#);
  End Loop;
  
End RLINE_SHELF_NUM_DEFINE_;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_RLINE
Procedure BRCM_RLINE_PREPARE
As
  cnt# BINARY_INTEGER;
  r# SP.BRCM_RLINE%ROWTYPE;
  ap# SP.VEC.AA_Vector;
  v1# SP.VEC.AA_Vector;
  v2# SP.VEC.AA_Vector;
  para# SP.BRCM_ADJ.PARALLEL%TYPE;
  --Готовит матрицу смежности элементов RLine
  Procedure RLINE_ADJACENCY_PREPARE
  As
    cnt# BINARY_INTEGER;
  Begin
    Select Count(*) Into cnt#
    From SP.BRCM_ADJ;
    
    If cnt#>0 Then
      Return;
    End If;
  
    cnt#:=0;
    For r1 In (
      Select * 
      From SP.BRCM_RLINE
      Order by RL_RID
    )Loop
      
      For r2 In (
        Select * 
        From SP.BRCM_RLINE
        Where RL_RID>r1.RL_RID
        Order by RL_RID
      )Loop
        
        ap#:=GetAdjacencePoint(r1,r2);
        If ap#.Count = 3 Then
          
          --начало вычисления признака параллельности
          v1#:=SP.VEC.CreateV3(r1.X2-r1.X1, r1.Y2-r1.Y1, r1.Z2-r1.Z1);
          v2#:=SP.VEC.CreateV3(r2.X2-r2.X1, r2.Y2-r2.Y1, r2.Z2-r2.Z1);
          
--          D('v1 ['||SP.VEC.to_str(v1#)||'], v2 ['||SP.VEC.to_str(v2#)||'].'
--            , 'DEBUG In BRCM_RLINE_PREPARE');
            
          If SP.VEC.IsParallel(v1#, v2#
            , ZeroVectorEps$=> ZeroVector#Eps --с точностью до миллиметра (в строительстве)
            , ParallelEps$ => Parallel#Eps  -- 1 мм. на 10 метров
          )Then
            para#:=1;
          Else
            para#:=0;
          End If;
          --конец вычисления признака параллельности
          
          Insert Into SP.BRCM_ADJ Values
          (r1.RL_RID, r2.RL_RID, ap#(1), ap#(2), ap#(3), para# );
          Insert Into SP.BRCM_ADJ Values
          (r2.RL_RID, r1.RL_RID, ap#(1), ap#(2), ap#(3), para#);
          cnt#:=cnt#+2;
        End If;
        
      End Loop;
    End Loop;
    D('В таблицу SP.BRCM_ADJ добавлено '||cnt#||' записей.'
    ,'Info From SP.BRCM#DUMP.RLINE_ADJACENCY_PREPARE');
  End RLINE_ADJACENCY_PREPARE;
Begin

  
  Select Count(*) Into cnt#
  From SP.BRCM_RLINE;
  
  If cnt#>0 Then
    Return;
  End If;

  BRCM_RACEWAY_PREPARE;

  cnt#:=0;
  For r In (
    SELECT mo2.MOD_OBJ_NAME as RL_RNAME
    , mop2.S As RLINE_ELEMENT_ID
    , mo3.ID As RL_DATA_ID 
    , mo3.PARENT_MOD_OBJ_ID As RECORD_ID
    FROM SP.MODEL_OBJECTS mo1

    INNER JOIN SP.MODEL_OBJECTS mo2  --Records
    ON mo2.PARENT_MOD_OBJ_ID=mo1.ID

    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop2
    ON mop2.MOD_OBJ_ID=mo2.ID
    AND mop2.NAME='HP_ELEMENT_ID'
    
    INNER JOIN SP.MODEL_OBJECTS mo3  --RLINES_DATA
    ON mo3.PARENT_MOD_OBJ_ID=mo2.ID
    

    WHERE mo1.MOD_OBJ_NAME=Prj$RLINES
    AND mo1.MODEL_ID=DumpModelID
   )
   Loop
    r#:=GetRLINE_ITEM(RLineDataID$ => r.RL_DATA_ID, RecordName$=> r.RL_RNAME); 
    
    --сопоставление 'RLine Item' -> 'RACEWAY Item'
    Begin
      SELECT RW_RID Into r#.RW_RID
      FROM SP.BRCM_RACEWAY
      WHERE RW_DESIGN_FILE=r#.RL_DESIGN_FILE
      AND RW_EID = RLine2RacewayEID(r#.RL_EID)
      ;
    Exception When NO_DATA_FOUND Then
      r#.RW_RID:=null;
    End;
    
    Insert Into SP.BRCM_RLINE Values r#; 
    cnt#:=cnt#+1;
   End Loop;

    D('В таблицу SP.BRCM_RLINE добавлено '||cnt#||' записей.'
    ,'Info From SP.BRCM#DUMP.BRCM_RLINE_PREPARE');
   
   RLINE_ADJACENCY_PREPARE;
   --Определение значения поля COURCE_NAME для RLine Items
   RLINE_COURSE_NAME_DEFINE_;
   
   --Определение значения поля SHELF_NUM для RLine Items
   RLINE_SHELF_NUM_DEFINE_;
End BRCM_RLINE_PREPARE;

--==============================================================================
--Возвращат запись таблицы SP.BRCM_RLINE
Function Get_BRCM_RLINE(RL_RID$ In SP.BRCM_RLINE.RL_RID%TYPE) 
Return SP.BRCM_RLINE%ROWTYPE
As
  rv# SP.BRCM_RLINE%ROWTYPE;
Begin
  Select * Into rv#
  From SP.BRCM_RLINE
  Where RL_RID=RL_RID$
  ;
  
  Return rv#;
End;
--==============================================================================
-- Для заданного EQP_RID$ извлекает из таблицы SP.BRCM_AREP информацию о точке 
-- привязки r$.
-- Возвращает одно из двух сообщений (NO_DATA_FOUND_MESS$, TOO_MANY_ROWS_MESS$) 
-- об ошибке или null.
Function GetAREP(EQP_RID$ In Number, r$ In Out SP.BRCM_AREP%ROWTYPE
, NO_DATA_FOUND_MESS$ In Varchar2
, TOO_MANY_ROWS_MESS$ In varchar2) 
Return Varchar2
Is
Begin
  Select * Into r$
  From SP.BRCM_AREP
  Where EQP_RID=EQP_RID$
  ;
  Return Null;

Exception 
  When NO_DATA_FOUND Then
    Return NO_DATA_FOUND_MESS$;
  
  When TOO_MANY_ROWS Then
    Return TOO_MANY_ROWS_MESS$;
End;
--==============================================================================
-- Кэширование данных о кабелях во временную таблицу SP.BRCM_CABLE
Procedure BRCM_CABLE_PREPARE
As
  cnt# BINARY_INTEGER;
  RL_DESIGN_FILE# SP.BRCM_RLINE.RL_DESIGN_FILE%TYPE;
  RL_EID# SP.BRCM_RLINE.RL_EID%TYPE;
  START_RL_RID# Number;
  EQP_FROM_RID# Number;
  EQP_TO_RID# Number;
  em# Varchar2(4000);
  em_arep# Varchar2(400);
  r_arep#  SP.BRCM_AREP%ROWTYPE;
  IS_VALID# SP.BRCM_CABLE.IS_VALID%TYPE;
  
  Cursor CBL_CURSOR# Is
    Select * 
    From SP.BRCM_CABLE cbl
    Order By cbl."HP_CableNo"
    For Update Of IS_VALID
    ;

  --Из строки вида 
  -- {F771ED4E-28D8-4337-8EFE-2A8345AEBF01}_17763_0+LV+Single Layer
  --вынимает два занчения:
  --RL_DESIGN_FILE$ <- {F771ED4E-28D8-4337-8EFE-2A8345AEBF01}
  --RL_EID$ <-17763_0
  Procedure RWObjectSplit(StrVal$ In Varchar2
    , RL_DESIGN_FILE$ In Out NoCopy Varchar2, RL_EID$ In Out NoCopy Varchar2)
  As
    i1# BINARY_INTEGER;
    i2# BINARY_INTEGER;
  Begin
    i1#:=INSTR(StrVal$,'}_');
    RL_DESIGN_FILE$:=SUBSTR(StrVal$,1,i1#);
    i1#:=i1#+2;
    i2#:=INSTR(StrVal$,'+');
    RL_EID$:=SUBSTR(StrVal$,i1#,i2#-i1#);
  End;
  
  Function Get_EQP_RID(StrVal$ In Varchar2) Return Number
  Is
    EQP_EID# SP.BRCM_EQP.EQP_EID%TYPE;
    EQP_DESIGN_FILE# SP.BRCM_EQP.EQP_DESIGN_FILE%TYPE;
    i1# BINARY_INTEGER;
    rv# Number;
  Begin
    i1#:=INSTR(StrVal$,'}_');
    EQP_DESIGN_FILE#:=SUBSTR(StrVal$,1,i1#);
    EQP_EID#:=SUBSTR(StrVal$,i1#+2);
    Select EQP_RID Into rv#
    From SP.BRCM_EQP
    Where EQP_EID=EQP_EID#
    And EQP_DESIGN_FILE=EQP_DESIGN_FILE#
    ;
    Return rv#;
  Exception When NO_DATA_FOUND Then
    Return Null;
  End;
Begin

  Select Count(*) Into cnt#
  From SP.BRCM_CABLE;
  
  If cnt#>0 Then
    Return;
  End If;
  
  BRCM_RLINE_PREPARE;
  BRCM_AREP_PREPARE;
  
  For r In(
    WITH C_OPT as (
      Select  cr.ID As CBL_RID
          , cr.MOD_OBJ_NAME As CBL_RNAME
          ,mop1.S As HP_CONNECTION 
          ,mop2.S As HP_ID 
          ,mop11.S as "HP_RWObject"
      FROM TABLE(SP.BRCM#DUMP.GetClassRecords(Prj$CABLES)) cr
      Left Join SP.MODEL_OBJECT_PAR_S mop1
      On mop1.MOD_OBJ_ID=cr.ID
      And mop1.NAME='HP_CONNECTION'
      
      Left Join SP.MODEL_OBJECT_PAR_S mop2
      On mop2.MOD_OBJ_ID=cr.ID
      And mop2.NAME='HP_ID'
      
      Inner Join SP.MODEL_OBJECTS mo1 
      ON mo1.PARENT_MOD_OBJ_ID = cr.ID
      AND mo1.MOD_OBJ_NAME = PrjF$CABLES_DATA
      
      Inner Join SP.MODEL_OBJECT_PAR_S mop11
      On mop11.MOD_OBJ_ID=mo1.ID
      And mop11.NAME='HP_RWObject'
      
      Order by HP_CONNECTION, HP_ID
    )
    Select  cr.ID As CBL_RID
    , cr.MOD_OBJ_NAME As CBL_RNAME
    ,mop1.S As HP_CONNECTION 
    ,mop2.S As HP_ID 
    ,mop11.S as "HP_CableNo"
    ,mop12.S as "HP_ObjectFrom"
    ,mop13.S as "HP_ObjectTo"    
    ,mop14.S as "HP_VoltageLevel"
    ,mop15.S as "HP_CableLength"
    ,co."HP_RWObject"
    FROM TABLE(SP.BRCM#DUMP.GetClassRecords(Prj$CABLES)) cr
    Left Join SP.MODEL_OBJECT_PAR_S mop1
    On mop1.MOD_OBJ_ID=cr.ID
    And mop1.NAME='HP_CONNECTION'
    
    Left Join SP.MODEL_OBJECT_PAR_S mop2
    On mop2.MOD_OBJ_ID=cr.ID
    And mop2.NAME='HP_ID'
    
    Inner Join SP.MODEL_OBJECTS mo1 
    ON mo1.PARENT_MOD_OBJ_ID=cr.ID
    AND mo1.MOD_OBJ_NAME = PrjF$CABLES_DATA
    
    Inner Join SP.MODEL_OBJECT_PAR_S mop11
    On mop11.MOD_OBJ_ID=mo1.ID
    And mop11.NAME='HP_CableNo'
    
    Left Join SP.MODEL_OBJECT_PAR_S mop12
    On mop12.MOD_OBJ_ID=mo1.ID
    And mop12.NAME='HP_ObjectFrom'
    
    Left Join SP.MODEL_OBJECT_PAR_S mop13
    On mop13.MOD_OBJ_ID=mo1.ID
    And mop13.NAME='HP_ObjectTo'
    
    Left Join SP.MODEL_OBJECT_PAR_S mop14
    On mop14.MOD_OBJ_ID=mo1.ID
    And mop14.NAME='HP_VoltageLevel'
    
    Left Join SP.MODEL_OBJECT_PAR_S mop15
    On mop15.MOD_OBJ_ID=mo1.ID
    And mop15.NAME='HP_CableLength'

    Left Join C_OPT co
    On co.HP_CONNECTION=mop1.S
    And co.HP_ID Like  mop2.S||'.%'
  )Loop
    
    IS_VALID#:=1;
    
    If r."HP_RWObject" Is Null Then
      RL_DESIGN_FILE# := Null;
      RL_EID# := Null;
      START_RL_RID#:=null;
      IS_VALID#:=0;
    Else
      RWObjectSplit(StrVal$ => r."HP_RWObject"
      , RL_DESIGN_FILE$ => RL_DESIGN_FILE#, RL_EID$ => RL_EID#);
      
      Begin
        Select RL_RID Into START_RL_RID#
        From SP.BRCM_RLINE
        Where RL_EID=RL_EID#
        And RL_DESIGN_FILE=RL_DESIGN_FILE#
        ;
        
      Exception When NO_DATA_FOUND Then
        START_RL_RID#:=null;
        
        E$M:='Routing Line c параметрами RL_EID ['||RL_EID#
        ||'], RL_DESIGN_FILE '||RL_DESIGN_FILE#
        ||' не найден в таблице SP.BRCM_RLINE';
        
        D(E$M, 'Warning In SP.BRCM#DUMP.BRCM_CABLE_PREPARE');
        IS_VALID#:=0;
      End;
    End If;
    
    EQP_FROM_RID# := Get_EQP_RID(StrVal$ => r."HP_ObjectFrom");
    
    If EQP_FROM_RID# Is Null Then
      E$M:='Для кабеля "HP_CableNo" ['||r."HP_CableNo"||'], CBL_RID ='
      ||r.CBL_RID||', CBL_RNAME ['||r.CBL_RNAME||'] по ссылке "HP_ObjectFrom" ['
      ||r."HP_ObjectFrom"||'] не найдена единица оборудования.';
      D(E$M, 'Data Inconsistency Error In SP.BRCM#DUMP.BRCM_CABLE_PREPARE');
      IS_VALID#:=0;
  End If;
    
    EQP_TO_RID# := Get_EQP_RID(StrVal$ => r."HP_ObjectTo");
    
    If EQP_TO_RID# Is Null Then
      E$M:='Для кабеля "HP_CableNo" ['||r."HP_CableNo"||'], CBL_RID ='
      ||r.CBL_RID||', CBL_RNAME ['||r.CBL_RNAME||'] по ссылке "HP_ObjectTo" ['
      ||r."HP_ObjectTo"||'] не найдена единица оборудования.';
      D(E$M, 'Data Inconsistency Error In SP.BRCM#DUMP.BRCM_CABLE_PREPARE');
      IS_VALID#:=0;
    End If;
    
    Insert Into SP.BRCM_CABLE Values
    (r.CBL_RID,r.CBL_RNAME,r."HP_CableNo", EQP_FROM_RID#, EQP_TO_RID#
    , START_RL_RID#, r."HP_VoltageLevel", r."HP_CableLength", IS_VALID#);
    
  End Loop;
  
  cnt#:=0; -- количество кабелей недоработанных
  E$M:='Кабели недоработанные:'||CHR(13)||CHR(10);
  For r In CBL_CURSOR# Loop
    em#:='';

    If r.START_RL_RID Is Null Then
      em#:='Cсылка на начальный RLINE не определена (START_RL_RID Is Null); ';
    End If;

    If r.EQP_FROM_RID Is Null Then
      em#:=em#||'Cсылка на начальную единицу оборудования не определена '
      ||'(EQP_FROM_RID Is Null); ';
    Else
      --проверка наличия единственной reference point
      em_arep#:=GetAREP(EQP_RID$ => r.EQP_FROM_RID, r$ => r_arep#
      , NO_DATA_FOUND_MESS$ => 'У начальной единицы оборудования EQP_FROM_RID= '
      ||r.EQP_FROM_RID||' отсутсвует точка привязки (табл. SP.BRCM_AREP); '
      , TOO_MANY_ROWS_MESS$ => 'У начальной единицы оборудования EQP_FROM_RID= '
      ||r.EQP_FROM_RID
      ||' обнаружено более одной точки привязки (табл. SP.BRCM_AREP); ');
      If Not em_arep# Is Null Then
        em#:=em#||em_arep#;
      End If;
    End If;

    If r.EQP_TO_RID Is Null Then
      em#:=em#||'Cсылка на конечную единицу оборудования не определена '
      ||'(EQP_TO_RID Is Null); ';
    Else
      --проверка наличия единственной reference point
      em_arep#:=GetAREP(EQP_RID$ => r.EQP_TO_RID, r$ => r_arep#
      , NO_DATA_FOUND_MESS$ => 'У конечной единицы оборудования EQP_TO_RID = '
      ||r.EQP_TO_RID||' отсутсвует точка привязки (табл. SP.BRCM_AREP); '
      , TOO_MANY_ROWS_MESS$ => 'У конечной единицы оборудования EQP_TO_RID = '
      ||r.EQP_TO_RID
      ||' обнаружено более одной точки привязки (табл. SP.BRCM_AREP); ');
      If Not em_arep# Is Null Then
        em#:=em#||em_arep#;
      End If;
    End If;
    
    If not em# Is Null Then
      D_Long(E$M,'CBL_RID = '||r.CBL_RID||', CBL_RNAME ['||r.CBL_RNAME
      ||'], CableNo ['||r."HP_CableNo"||']: '||em#||CHR(13)||CHR(10)
      ,'Кабели недоработанные');
      cnt#:=cnt#+1;
      
      Update SP.BRCM_CABLE Set IS_VALID=0
      Where Current Of CBL_CURSOR#
      ;
      
    End If;
  End Loop;
  If cnt#>0 Then
    D_Long(E$M,'---------------------'||CHR(13)||CHR(10)
    ||'Итого кабелей недоработанных: '||to_char(cnt#)||CHR(13)||CHR(10)
    ||'===================='||CHR(13)||CHR(10)
    ||'Report From SP.BRCM#DUMP.BRCM_CABLE_PREPARE'
    ,'Кабели недоработанные');
    D(E$M,'Кабели недоработанные');
  End If;
  
End BRCM_CABLE_PREPARE;
--==============================================================================
--Упорядочить записи BRCM_CFC (вычислить значения поля ORDINAL всех записей)
--Начальное состояние: Для каждого CBL_RID имеется одна запись со значением
--ORDINAL=1, остальные записи имеют ORDINAL=0;
Procedure BRCM_CFC_PUT_IN_ORDER
As
  ORDINAL# SP.BRCM_CFC.ORDINAL%TYPE;
  boFound# Boolean;
  cnt# BINARY_INTEGER;
  CBL#RID# Number;  --входной параметр курсора cup2#
  Cursor cup2# Is
    Select CFC_RID, RL_RID
    From SP.BRCM_CFC
    Where CBL_RID=CBL#RID#
    And ORDINAL=0
    For Update Of ORDINAL
    ;
Begin
  ORDINAL#:=1;
  boFound#:=true;
  While boFound# Loop
    boFound#:=false;
    For r1 In (
      Select CBL_RID, RL_RID
      From SP.BRCM_CFC
      Where ORDINAL=ORDINAL#
    )Loop
      CBL#RID#:=r1.CBL_RID; 
      For r2 In cup2# Loop
        
        SELECT Count(*) Into cnt#
        From SP.BRCM_ADJ
        Where RL_RID1=r1.RL_RID
        And RL_RID2=r2.RL_RID
        ;
        
        If cnt#>0 Then
          boFound#:=True;
          Update SP.BRCM_CFC Set ORDINAL=ORDINAL#+1
          Where Current Of cup2#          
          ;
           Exit When True;
        End If;
      End Loop; --r2
    End Loop;  --r1
    ORDINAL#:=ORDINAL#+1;
  End Loop; --ORDINAL
End;
--==============================================================================
-- Кэширование данных о кабелях во временную таблицу SP.BRCM_CFC
Procedure BRCM_CFC_PREPARE
As
  cnt# BINARY_INTEGER;
  r# SP.BRCM_CFC%ROWTYPE;
  START_RL_RID# SP.BRCM_CABLE.START_RL_RID%TYPE;
  
  Cursor CBL_CURSOR# Is
    Select cbl.CBL_RID, cbl.CBL_RNAME, cbl."HP_CableNo" 
    From SP.BRCM_CABLE cbl
    Where Exists( Select * From SP.BRCM_CFC cfc
                  Where cfc.CBL_RID=cbl.CBL_RID
                  And cfc.ORDINAL=0)
   Order By cbl."HP_CableNo"               
   For Update Of IS_VALID
   ;
  
Begin
  Select Count(*) Into cnt#
  From SP.BRCM_CFC;
  
  If cnt#>0 Then
    Return;
  End If;
  
  BRCM_CABLE_PREPARE;

  For r In (
    Select  cr.ID As CFC_RID
    , cr.MOD_OBJ_NAME As CFC_RNAME
    , mop11.S As RL_EID
    , mop12.S As RL_DESIGN_FILE
    , mop13.S As HP_CNAME
    , mop14.S As HP_CID
    FROM TABLE(GetClassRecords(Prj$CFC)) cr
    
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop11
    ON mop11.MOD_OBJ_ID=cr.ID
    AND mop11.NAME='HP_ELEMENT_ID'
    
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop12
    ON mop12.MOD_OBJ_ID=cr.ID
    AND mop12.NAME='HP_DESIGN_FILE'

    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop13
    ON mop13.MOD_OBJ_ID=cr.ID
    AND mop13.NAME='HP_CNAME'
    
    LEFT JOIN SP.MODEL_OBJECT_PAR_S mop14
    ON mop14.MOD_OBJ_ID=cr.ID
    AND mop14.NAME='HP_CID'
    
  )Loop
    r#.CFC_RID := r.CFC_RID;
    r#.CFC_RNAME := r.CFC_RNAME;
    r#.HP_CID := r.HP_CID;
    r#.ORDINAL:=0;
    
    Select CBL_RID, START_RL_RID Into r#.CBL_RID, START_RL_RID#
    From SP.BRCM_CABLE
    Where "HP_CableNo" = r.HP_CNAME
    ;
    
    Begin
      Select RL_RID Into r#.RL_RID
      From SP.BRCM_RLINE
      Where RL_EID=r.RL_EID
      And RL_DESIGN_FILE= r.RL_DESIGN_FILE
      ;
    Exception When NO_DATA_FOUND Then
      r#.RL_RID:=Null;
      E$M:='Для записи r.CFC_RID = '||r.CFC_RID||', r.CFC_RNAME ['||r.CFC_RNAME
      ||'] в таблице SP.BRCM_RLINE не найден объект с параметрами RL_EID ['
      ||r.RL_EID||'], r.RL_DESIGN_FILE '||r.RL_DESIGN_FILE||'.';
      D(E$M,'Data Inconsistency Error In SP.BRCM#DUMP.BRCM_CFC_PREPARE');
    End;
    
    If r#.RL_RID=START_RL_RID# Then
      r#.ORDINAL := 1;
    Else
      r#.ORDINAL := 0;
    End If;
    
    Begin 
      
      Insert Into SP.BRCM_CFC Values r#;
      
    Exception When DUP_VAL_ON_INDEX Then
      
      E$M:='В таблице SP.BRCM_CFC уже имеется пара значений (CBL_RID = '
      ||r#.CBL_RID||', RL_RID ='||r#.RL_RID||') для кабеля ['||r.HP_CNAME
      ||']. Повторная вставка идентичной записи не производится.'
      ||CHR(13)||CHR(10)||'Перехваченная ошибка:'||CHR(13)||CHR(10)||SQLERRM;
      
      D(E$M,'Data Inconsistency Error In SP.BRCM#DUMP.BRCM_CFC_PREPARE');
    End;
  End Loop;    
  
  --Упорядочить записи BRCM_CFC (вычислить значения поля ORDINAL всех записей)
  BRCM_CFC_PUT_IN_ORDER;
  
  
  cnt#:=0;
  E$M:='Кабели с дефектами трассировки (имеются CFC c ORDINAL=0):'
      ||CHR(13)||CHR(10);
  For r In CBL_CURSOR# Loop
    D_Long(E$M,'CBL_RID = '||r.CBL_RID||', CBL_RNAME ['||r.CBL_RNAME
    ||'], CableNo ['||r."HP_CableNo"||']'||CHR(13)||CHR(10)
    ,'Кабели с дефектами трассировки');
    
    Update SP.BRCM_CABLE Set IS_VALID=0
    Where Current Of CBL_CURSOR#
    ;
    
    cnt#:=cnt#+1;
  End Loop;
  If cnt#>0 Then
    D_Long(E$M,'========================'||CHR(13)||CHR(10)
    ||'Report From SP.BRCM#DUMP.BRCM_CFC_PREPARE'
    ,'Кабели с дефектами трассировки');
    D(E$M,'Кабели с дефектами трассировки');
  End If;
End BRCM_CFC_PREPARE;
--==============================================================================
--Возвращает класс сметы для прокладки кабеля вдоль элемента кабелепровода 
--для элемента RLine
--или null или error
Function GetRacewaySmetaClass(RL_EID$ In Varchar2, RL_DESIGN_FILE$ In Varchar2) 
Return Varchar2
Is
  RW_RID# Number;
  RLINE_RECORD_ID# Number;
Begin

  BRCM_RLINE_PREPARE;
  
  Begin
    Select  RW_RID Into RW_RID# 
    From SP.BRCM_RLINE
    WHERE RL_DESIGN_FILE=RL_DESIGN_FILE$
    And RL_EID=RL_EID$
    ;
  Exception When NO_DATA_FOUND Then
      E$M:='Для RL_EID ['||RL_EID$||'] и RL_DESIGN_FILE ['
      ||RL_DESIGN_FILE$||'] не найден RLINE_RECORD_ID.';
      D(E$M, 'ERROR In SP.BRCM#DUMP.GetRacewaySmetaClass');
     
      raise_application_error
      (-20033, 'ERROR In SP.BRCM#DUMP.GetRacewaySmetaClass: '||E$M);
  End;

  If RW_RID# Is Null Then Return Null; End If;  
  
  Return GetRacewaySmetaClassRaw(RW_RID$ => RW_RID#);
End GetRacewaySmetaClass;

BEGIN
 DumpModel$Name:='BRCM||DUMP 21-06-2019';
  Begin
    Select ID Into DumpModel$ID
    FROM SP.MODELS WHERE NAME=DumpModel$Name;
  EXCEPTION
        WHEN no_data_found THEN
        DumpModel$Name:=Null;
        DumpModel$ID:=Null;
  End;

  Begin
    Init;
  EXCEPTION WHEN OTHERS THEN
      DumpModel$Name:=Null;
      DumpModel$ID:=Null;
  End;

END BRCM#DUMP;
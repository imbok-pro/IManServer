create or replace PACKAGE SP.BRCM#DUMP
As
-- Работа исключительно с дампом модели BRCM 
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-03-21
-- update 2019-07-15 2019-09-26 2019-10-30

--==============================================================================
--тип данных для хранения GUID-ов в строковом представлении 
SubType T$GUID_STR Is Varchar2(40);

-- тип данных для хранения значений полей RLINE_ELEMEN_ID, 
-- RACEWAY_ELEMENT_ID etc.
SubType T$ELEMENT_ID Is Varchar2(40);

--тип данных для строкового предствления типа Number, необходим для 
--индексации ассоцоативных массивов 
SubType T$STR_NUMBER Is Varchar2(40);
--------------------------------------------------------------------------------
Type AA_ModObjName2Name Is Table Of SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

TYPE AA_ModObjName2Number Is Table Of Number 
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

--------------------------------------------------------------------------------
Type T_MODEL_OBJECTS Is table Of SP.MODEL_OBJECTS%ROWTYPE;
Type T_BRCM_RLINE Is Table Of SP.BRCM_RLINE%ROWTYPE; 

--------------------------------------------------------------------------------
Type R_MOD_OBJ_PAR Is Record
(
    PARAM_ID	SP.V_MODEL_OBJECT_PARS.ID%TYPE,
    MOD_OBJ_ID	SP.MODEL_OBJECTS.ID%TYPE,
    MOD_OBJ_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE, 
    PARAM_NAME	SP.MODEL_OBJECT_PAR_S.NAME%TYPE,
    R_ONLY	SP.MODEL_OBJECT_PAR_S.R_ONLY%TYPE,
    TYPE_ID	SP.V_MODEL_OBJECT_PARS.TYPE_ID%TYPE,
    E_VAL	SP.V_MODEL_OBJECT_PARS.E_VAL%TYPE,
    N	SP.V_MODEL_OBJECT_PARS.N%TYPE,
    D	SP.V_MODEL_OBJECT_PARS.D%TYPE,
    S	SP.MODEL_OBJECT_PAR_S.S%TYPE,
    X	SP.V_MODEL_OBJECT_PARS.X%TYPE,
    Y	SP.V_MODEL_OBJECT_PARS.Y%TYPE
);
Type T_MOD_OBJ_PARS Is table Of R_MOD_OBJ_PAR;

--==============================================================================
--Относительная погрешность измерения координат.
--Координаты считаются одинаковыми, 
--если их абсолютная погрешность меньше EPS_Coord;
--См. функции EQ_Coord, EQ_PointsXY, EQ_PointsXYZ.
EPS_Coord CONSTANT Number := 10.00;  -- := 0.001;
--==============================================================================
--Классы по сметной ведомости прокладки кабеля
--
-- не определено 
-- неопределённых классов быть не должно, данное значение включено в пакет
-- в целях отладки
SC_NotDef Constant Varchar2(20):='NotDef';
-- прокладка по лоткам
SC_Tray Constant Varchar2(20):='в лотках';
-- прокладка по трубам
SC_Tube Constant Varchar2(20):='в трубах';
-- прокладка по воздуху
SC_AirGap Constant Varchar2(20):='по воздуху';
--==============================================================================
--инициализация раборты с дампом
Prj$AREP Varchar2(32):= 'PRJCE_INT_CM_AREP';
Prj$CABLES Varchar2(32):='PRJCE_INT_CM_CABLES';
Prj$CFC Varchar2(32):='PRJCE_INT_CM_CFC';
Prj$EQP Varchar2(32):= 'PRJCE_INT_EQP';
Prj$RLINES Varchar2(32):='PRJCE_INT_RLINES';
Prj$RACEWAY Varchar2(32):= 'PRJCE_INT_RACEWAY';

PrjF$AREP_BIN_DATA Varchar2(32):= '_AREP_BIN_DATA';
PrjF$CABLES_DATA Varchar2(32):= '_CABLES_DATA';
PrjF$RACEWAY_BIN_DATA Varchar2(32):= 'CEWAY_BIN_DATA';
--==============================================================================
--Возвращает имя модели, в которой содержится дамп данных BRCM.
Function DumpModelName Return SP.MODELS.NAME%TYPE;
--------------------------------------------------------------------------------
--Возвращает ID модели, в которой содержится дамп данных BRCM.
Function DumpModelID Return SP.MODELS.ID%TYPE;
--------------------------------------------------------------------------------
--Устанавливает имя и ID модели с дампом BRCM по его имени 
Procedure SetDumpModelName(DumpModelName$ In Varchar2);
/*
--Implementation pattern
Begin
  SP.BRCM#DUMP.SetDumpModelName(DumpModelName$ => 'BRCM||DUMP 30-04-2019');
End;
*/

--------------------------------------------------------------------------------
--Обнуляет все переменные и массивы пакета, кроме DumpModel_Name и DumpModel_ID,
--а также все временные очищает таблицы
Procedure ClearPackage;
--==============================================================================
--Лог длинных строк
--Если строки короткие, то  делает их конкатенацию
--Если строки длинные, то записывает в лог начало (mess1$)
--а затем заменяет начало хвостом (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 );

--==============================================================================
Function V_TabooCableNames Return SP.TSHORTSTRINGS Pipelined;
/*  
--Implementation pattern
Select COLUMN_VALUE as "CableNo" FROM TABLE(SP.BRCM.V_TabooCableNames) tcn
ORDER BY "CableNo"
;
*/
--==============================================================================
--строку вида "125700.0000000,6650.0000000,3840.0000000"
--превращает в три числа XYZ
Procedure Str2XYZ(Str$ In Varchar2, Sepa$ In Varchar2
, X$ In Out Nocopy Number, Y$ In Out Nocopy Number, Z$ In Out Nocopy Number);

--==============================================================================
--Возвращает квадрат расстояния между точками A и B
Function Dist2(AX$ In Number, AY$ In Number, AZ$ In Number
, BX$ In Number, BY$ In Number, BZ$ In Number) Return Number;
--==============================================================================
--Возвращает 1, если точка (x1,y1) покоординатно приближает точку (x1,y2) с 
--абсолютной погрешностью, меньшей, чем EPS_Coord=0.0001.
--В противном случае возвращает 0.
Function EQ_PointsXY(x1$ In Number, y1$ In Number, x2$ In Number, y2$ In Number
, Eps$ In Number:=null) 
Return BINARY_INTEGER;

--==============================================================================
--Возвращает 1, если точка (x1,y1,z1) покоординатно приближает точку (x1,y2,z2) 
--с абсолютной погрешностью, меньшей, чем EPS_Coord=0.0001.
--В противном случае возвращает 0.
Function EQ_PointsXYZ(x1$ In Number, y1$ In Number, z1$ In Number
, x2$ In Number, y2$ In Number, z2$ In Number, Eps$ In Number:=null) 
Return BINARY_INTEGER;
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
Return BINARY_INTEGER;

--==============================================================================
--Возвращает координаты концов сегмента в виде A(X:Y:Z),B(X:Y:Z)
Function SegmentToStr(r$ In BRCM_RLINE%ROWTYPE) Return String;
--==============================================================================
--ПО RLINE_ELEMENT_ID возвращает соответствующий RACEWAY_ELEMENT_ID
-- например, 12E37_0 -> 12E37
Function RLine2RacewayEID(RLineEID$ Varchar2) Return Varchar2;

--==============================================================================
--Возвращает 1, если rli$.RW_CLASS соотвествует тройнику (разветвителю).
--В противном случае возвращает 0.
Function IsTee(rli$ In SP.BRCM_RLINE%ROWTYPE) Return Number;
--==============================================================================
--Возвращает ID объекта с именем похожим на LikeModObjName$, находящегося 
--не выше объекта, задаваемого RootModObjID$.
--Если объект не найден возвращает Null
--Если найдено несколько объектов, возникает исключение
Function GetModObj1(RootModObjID$ In Number, LikeModObjName$ In varchar2) 
Return Number;
/*  
--Implementation pattern
SELECT 
SP.BRCM.GetModObj1(RootModObjID$ => 943540400, LikeModObjName$ => 'Geometry_%')
As ID1 From Dual
;
*/

--==============================================================================
--Возвращает поле S параметра с менем ParName$ объекта с ID ModObjID$
Function GetModObjParamValS(ModObjID$ In Number, ParName$ In varchar2)
Return Varchar2;

--==============================================================================
--Возвращает значения параметра с именем ParamName$ объекта
--с именем похожим на LikeModObjName$, находящегося в 
--не выше объекта, задаваемого RootModObjID$.
--Если ParamName => null, то возвращает все параметры.
Function GetModObjParam(RootModObjID$ In Number
, LikeModObjName$ In varchar2, ParamName$ In varchar2:=null) 
Return T_MOD_OBJ_PARS pipelined;
/*  
--Implementation pattern
SELECT mop.PARAM_ID, mop.MOD_OBJ_ID, mop.MOD_OBJ_NAME, mop.PARAM_NAME,
mop.TYPE_ID, mop.E_VAL, mop.N, mop.D, mop.S, mop.X, mop.Y
FROM TABLE(SP.BRCM.GetModObjParam(943540400
,LikeModObjName$ => 'Geometry_%',ParamName$ => null) ) mop  
ORDER BY MOD_OBJ_ID
;
*/

--==============================================================================
--Возвращает Записи (Records) класса с именем ClassName$ дамапа BRCM
Function GetClassRecords(ClassName$ In Varchar2) 
Return T_MODEL_OBJECTS pipelined;
/*  
--Implementation pattern
SELECT cr.ID, cr.MODEL_ID, cr.MOD_OBJ_NAME, cr.OID, cr.OBJ_ID
, cr.PARENT_MOD_OBJ_ID, cr.COMPOSIT_ID, cr.START_COMPOSIT_ID, cr.MODIFIED
, cr.USING_ROLE, cr.EDIT_ROLE, cr.M_DATE, cr.M_USER, cr.TO_DEL 
FROM TABLE(SP.BRCM.GetClassRecords('Project_INT_CM_CFC')) cr
ORDER BY cr.ID
;
*/
--==============================================================================
--Возвращает RACEWAY-класс для элемента кабелепровода 
--т.е. значение параметра /Project_INT_RACEWAY/Record???
--/RACEWAY_BIN_DATA/R5XDATA_???/Export_???/ECDATA_???/Class_???.HP_name
--или null
Function GetRacewayClassRaw(RacewayRecordID$ In Number) Return Varchar2;
/*
--Implementation pattern

Select SP.BRCM#DUMP.GetRacewayClassRaw
        (RacewayRecordID$ => 1135464300) as ttt From Dual;

*/

--==============================================================================
--Возвращает класс сметы для прокладки кабеля вдоль элемента кабелепровода 
--или null или error
Function GetRacewaySmetaClassRaw(RW_RID$ In Number) Return Varchar2;

--==============================================================================
--Возвращает класс сметы для прокладки кабеля вдоль элемента кабелепровода
--или error
Function GetSmetaClass(RW_CLASS$ In varchar2) Return Varchar2;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_EQP
Procedure BRCM_EQP_PREPARE;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_AREP
Procedure BRCM_AREP_PREPARE;
--==============================================================================
-- Кэширование данных во временную таблицу SP.BRCM_RLINE
Procedure BRCM_RLINE_PREPARE;
--==============================================================================
--Возвращат запись таблицы SP.BRCM_RLINE
Function Get_BRCM_RLINE(RL_RID$ In SP.BRCM_RLINE.RL_RID%TYPE) 
Return SP.BRCM_RLINE%ROWTYPE;
--==============================================================================
-- Возвращает SP.BRCM_RACEWAY.RW_CLASS для соотвествующего RLINE 
Function GetRW_CLASS(RL_RID$ In SP.BRCM_RLINE.RL_RID%TYPE)
Return SP.BRCM_RACEWAY.RW_CLASS%TYPE;
--==============================================================================
-- Кэширование данных о кабелях во временную таблицу SP.BRCM_CABLE
Procedure BRCM_CABLE_PREPARE;

--==============================================================================
-- Кэширование данных о кабелях во временную таблицу SP.BRCM_CFC
Procedure BRCM_CFC_PREPARE;
/*
--Implementation pattern

Begin
--TEST_001 
--Проверка корректности заполнения таблиц SP.BRCM_RACEWAY и SP.BRCM_RLINE

  SP.BRCM#TJ.ClearPackage;
  SP.BRCM#DUMP.SetDumpModelName(DumpModelName$ => 'BRCM||DUMP EBCEEB 2019-10-15');
  
  SP.BRCM#DUMP.BRCM_CFC_PREPARE;
  SP.BRCM#TJ.BRCM_DUMP_2_TJ(WorkID$ => 2705480400);                                                  


End;

Select * From SP.BRCM_EQP;

Select * From SP.BRCM_AREP;

Select * From SP.BRCM_RACEWAY;

Select * From SP.BRCM_RLINE;

Select * From SP.BRCM_REL;

Select * From SP.BRCM_CABLE;

Select * From SP.BRCM_CFC;

*/
--==============================================================================


End BRCM#DUMP;
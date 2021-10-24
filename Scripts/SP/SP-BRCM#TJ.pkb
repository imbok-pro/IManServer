create or replace PACKAGE BODY SP.BRCM#TJ 
AS
-- Процедуры передачи данных из структуры дампа BRCM в структуру модели TJ 
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-03-21
-- update 2019-07-15 2019-09-26 2019-11-21 2020-07-02:2020-07-03

--==============================================================================
Type AA_ModObjName2OID Is Table Of SP.MODEL_OBJECTS.OID%TYPE
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
--==============================================================================
--словарь перевода имен параметро из BRCM в TJ
BRCM2TJ#EQP#PARAM AA_ParamName2Name;

-- Возвращает имя параметра оборудования модели TJ, соответствующее имени 
-- параметра оборудования, возвращаемого из модели Pln.BRCM.Server или null
Function TJ_EQP_ParamNull(BRCM_ParamName$ Varchar2) Return varchar2
As
  rv# SP.MODEL_OBJECT_PAR_S.NAME%TYPE;
Begin
  If BRCM2TJ#EQP#PARAM.Count < 1 Then
    BRCM2TJ#EQP#PARAM('KKS_ID') := 'NAME';
    BRCM2TJ#EQP#PARAM('Origin') := 'XYZабс';
  End If;
  
  Begin
    rv# := BRCM2TJ#EQP#PARAM(BRCM_ParamName$);
  Exception When OTHERS Then
    rv# := null;
  End;
  
  Return rv#; 
End;
--..............................................................................
-- Возвращает имя параметра оборудования модели TJ, соответствующее имени 
-- параметра оборудования, возвращаемого из модели Pln.BRCM.Server.
-- Если соответствия не неайдено, возвращает исходное имя.
Function TJ_EQP_Param(BRCM_ParamName$ Varchar2) Return varchar2
As
  rv# SP.MODEL_OBJECT_PAR_S.NAME%TYPE;
Begin
  rv# := TJ_EQP_ParamNull(BRCM_ParamName$);
  If rv# Is Null Then
    rv# := BRCM_ParamName$;
  End If;
  Return rv#; 
End;
--==============================================================================
--Обнуляет все переменные и массивы пакета
Procedure ClearPackage
Is
Begin
  
  SP.BRCM#DUMP.ClearPackage;
  
End ClearPackage;

--==============================================================================
--Из строки создает 40-символьную строку, используя алгоритм перемешивания SHA1
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION SHA1(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
RETURN LOWER(TO_CHAR(RAWTOHEX(SYS.DBMS_CRYPTO.HASH
    (UTL_RAW.CAST_TO_RAW(STRING_TO_ENCRIPT), SYS.DBMS_CRYPTO.HASH_SH1)
    )));
END SHA1;
--==============================================================================
--Из строки создает 32-символьную строку, используя алгоритм перемешивания MD5
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION MD5(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
RETURN LOWER(TO_CHAR(RAWTOHEX(SYS.DBMS_CRYPTO.HASH
    (UTL_RAW.CAST_TO_RAW(STRING_TO_ENCRIPT), SYS.DBMS_CRYPTO.HASH_MD5)
    )));
END MD5;
--==============================================================================
--Позволяет переупорядочить имена в соответствии с номерами
Function PipelineNames( tab$ In T_IndexedNames) 
Return T_IndexedNames Pipelined
Is
Begin
  For i in tab$.First..tab$.Last Loop
    pipe row(tab$(i));
  End Loop;
End PipelineNames;
--==============================================================================
--Возвращает имя, полученное путем округления координат до целых значений вида
-- "X1:Y1:Z1:X2:Y2:Z2"
Function GetNameFrom6Coordinates(CableWaySegment$ in R_CABLE_WAY_SEGMENT) 
Return Varchar2
Is
  rv# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
  rv#:=to_char(ROUND(CableWaySegment$.X1)) ||':'
  ||to_char(ROUND(CableWaySegment$.Y1)) ||':'
  ||to_char(ROUND(CableWaySegment$.Z1)) ||':'
  ||to_char(ROUND(CableWaySegment$.X2)) ||':'
  ||to_char(ROUND(CableWaySegment$.Y2)) ||':'
  ||to_char(ROUND(CableWaySegment$.Z2))
  ;
  Return rv#;
End GetNameFrom6Coordinates;
--==============================================================================
--инициализация переменной типа R_CABLE_WAY_SEGMENT данными об элементе RLine
Function CABLE_WAY_SEGMENT_Init(r$ In SP.BRCM_RLINE%ROWTYPE) 
Return R_CABLE_WAY_SEGMENT
As
  rv# R_CABLE_WAY_SEGMENT;
Begin
    rv#.ORDINAL:=0;
    --ссылка на RL_RID входящих в состав элементов RLINE
    rv#.RL_RID_S(1):= r$.RL_RID; 
    rv#.X1 := r$.X1; 
    rv#.Y1 := r$.Y1;
    rv#.Z1 := r$.Z1;
    rv#.X2 := r$.X2; 
    rv#.Y2 := r$.Y2;
    rv#.Z2 := r$.Z2;
    rv#.LENGTH := r$.LENGTH;
    rv#.HP_RWID :=r$.HP_RWID;
    rv#.COURSE_NAME := r$.COURSE_NAME;
    rv#.SHELF_NUM := r$.SHELF_NUM;
    rv#.ORIENTATION :=0;
    rv#.IS_PART:=0;
  Return rv#;
End CABLE_WAY_SEGMENT_Init;

--==============================================================================
--Инициализация переменной типа R_CABLE_WAY_SEGMENT данными об элементе RLine
Function CABLE_WAY_SEGMENT_Init(RL_RID$ In SP.BRCM_RLINE.RL_RID%TYPE) 
Return R_CABLE_WAY_SEGMENT
As
  r# SP.BRCM_RLINE%ROWTYPE;
Begin
  Select * Into r#
  From SP.BRCM_RLINE
  WHERE RL_RID=RL_RID$
  ;
  Return CABLE_WAY_SEGMENT_Init(r$ => r#);
End CABLE_WAY_SEGMENT_Init;
--==============================================================================
--Экспорт информации об изделиях из BRCM DUMP в TJ
Procedure DevicesEXP
As
  DeviceID# SP.MODEL_OBJECTS.ID%TYPE; 
  Par# SP.TMPAR;
  --Соответствие DEVICE_NAME -> RID, индекс. 
  de_idx# SP.TJ_WORK.AA_ObjName2ID;
Begin
-- Кэширование данных во временную таблицу SP.BRCM_EQP
  SP.BRCM#DUMP.BRCM_EQP_PREPARE;

  --заполняем индекс имён устройств
  SP.TJ_WORK.Get_MODEL_OBJECT_IDX(RootModObjID$=>SP.TJ_WORK.WorkID
  , ObjectID$ => SP.TJ_WORK.Get_DEVICE_OBJECT_ID, idx$ => de_idx#);
  
  For r In (
    SELECT eqp.EQP_RID, eqp.EQP_RNAME, eqp.EQP_EID
      , eqp.EQP_NAME, eqp.EQP_DESIGN_FILE
      , eqp.TV_X, eqp.TV_Y, eqp.TV_Z
      , eqp.UX_X, eqp.UX_Y, eqp.UX_Z
      , eqp.UY_X, eqp.UY_Y, eqp.UY_Z
      , eqp.UZ_X, eqp.UZ_Y, eqp.UZ_Z
      FROM SP.BRCM_EQP eqp
      ORDER BY eqp.EQP_EID
  )Loop
    If de_idx#.Exists(r.EQP_NAME) Then
      DeviceID#:= de_idx#(r.EQP_NAME); 
      --сохранение координат устройства
      Par#:=SP.TMPAR(ModelObjID => DeviceID#, Par=>'XYZабс');
      Par#.Save(P3_(r.TV_X, r.TV_Y, r.TV_Z));
    Else
      D('Устройство дампа ['||r.EQP_NAME||'] '||r.EQP_RNAME
      ||' не найдено в модели TJ.','Warning In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
    End If;
  End Loop;
End DevicesEXP;
--==============================================================================
--Возвращает OID стеллажа по полке или исключение NO_DATA_FOUND
--возвращает MD5(RackName$) 
Function GetRackOID(RackName$ In Varchar2)
Return Varchar2
Is
Begin
  Return MD5(RackName$);
End GetRackOID;
--==============================================================================
-- Возвращает последовательность RLINEs, вдоль которых лежит кабель, 
-- элементы которой занумерованы индексом ORDINAL, начиная с 1. 
-----------------------------------------------------------------<>--------------------------не используется----------------------------!!!!!
Function GetRLineChain(CableRecodrdID$ In Number
, CableNo$ In Varchar2 , RlineStartElementID$ In Varchar2
,CTP_X$ In Number,CTP_Y$ In Number,CTP_Z$ In Number )
Return AA_CABLE_WAY_SEGMENT_CHAIN
Is
  rv# R_CABLE_WAY_SEGMENT;  ---<===================================================R_CABLE_RLINE_CHAIN_MEMBER
  cab_chain1# AA_CABLE_WAY_SEGMENT_CHAIN;
  cab_chain2# AA_CABLE_WAY_SEGMENT_CHAIN; ---<======================================AA_CABLE_RLINE_CHAIN;
  cab_chain_probe# AA_CABLE_WAY_SEGMENT_CHAIN;
  r_current# R_CABLE_WAY_SEGMENT;
  r_next# R_CABLE_WAY_SEGMENT;
  r_tmp1# R_CABLE_WAY_SEGMENT;
  r_tmp2# R_CABLE_WAY_SEGMENT;
  BoNextRecordFound Boolean;
  
  i1# BINARY_INTEGER;
  i1_arg_min# BINARY_INTEGER;
  i2# BINARY_INTEGER;
  d2# Number;
  d2_min# Number;
  e1# Varchar2(4000);
  e2# Varchar2(4000);
  
  --Возвращает ориентацию первого элемента {-2; 0; 2}
  Function FirstElementOrientation(r$ In R_CABLE_WAY_SEGMENT)
  Return Number
  Is
    di1# Number;
    di2# Number;
  Begin
    di1#:=SP.BRCM#DUMP.Dist2(CTP_X$, CTP_Y$, CTP_Z$, r$.X1, r$.Y1, r$.Z1);
    di2#:=SP.BRCM#DUMP.Dist2(CTP_X$, CTP_Y$, CTP_Z$, r$.X2, r$.Y2, r$.Z2);
    If ABS(di1#-di2#) <= SP.BRCM#DUMP.EPS_Coord*SP.BRCM#DUMP.EPS_Coord Then
      Return 0;
    ElsIf di1# < di2# Then
      Return 2;
    Else
      Return -2;
    End if;
  End;
  
  --Возвращает истину, если текуший отредок [AB] пересекает холя бы один из
  --отрезков списка cab_chain$
  Function Intersect1(cab_chain$ In AA_CABLE_WAY_SEGMENT_CHAIN) Return Boolean
  Is
    j# BINARY_INTEGER;
    rj# R_CABLE_WAY_SEGMENT;
  Begin
    j#:=cab_chain$.First;
    While Not j# Is Null 
    Loop
      rj#:=cab_chain$(j#);
      SP.VEC#SEGMENT.SetCD(rj#.X1,rj#.Y1,rj#.Z1,rj#.X2,rj#.Y2,rj#.Z2);
      SP.VEC#SEGMENT.CalcSegmentIntersection;
      If SP.VEC#SEGMENT.Intersected Then
        Return true;
      End If;
      j#:=cab_chain$.Next(j#);
    End Loop;

    Return false;
  End;
Begin

  SP.VEC#SEGMENT.SetEps(Eps0$ => 3.0, ParallelEps$=> 0.00001);

  --rv#."HP_CableNo":=CableNo$;------------------<=========================================Изъято

  For sh in (
      Select rl.*
      FROM SP.BRCM_CABLE crr
      INNER JOIN SP.BRCM_RLINE rl
      ON rl.RL_RID=crr.START_RL_RID
      WHERE crr.CBL_RID=CableRecodrdID$
      ORDER BY RL_RID
  )Loop
  
    rv#:=CABLE_WAY_SEGMENT_Init(r$ => sh );
--    rv#.CBL_RID:=CableRecodrdID$;
--    rv#.ORDINAL:=0;
--    rv#.RL_RID:=sh.RL_RID;
--    rv#.X1:=sh.X1;
--    rv#.Y1:=sh.Y1;
--    rv#.Z1:=sh.Z1;
--    rv#.X2:=sh.X2;
--    rv#.Y2:=sh.Y2;
--    rv#.Z2:=sh.Z2;
--    rv#.LENGTH:=sh.LENGTH;
--    rv#.HP_RWID:=sh.HP_RWID;
--    rv#.COURSE_NAME:=sh.COURSE_NAME;
    rv#.SHELF_NUM:=sh.SHELF_NUM;
--    rv#.ORIENTATION:=0;
--    rv#.IS_PART:=0;

    If rv#.RL_RID_S(rv#.RL_RID_S.First)=RlineStartElementID$ Then
      --первый элемент сразу пишем в начало 
      rv#.ORIENTATION:=FirstElementOrientation(rv#);
      rv#.ORDINAL:=cab_chain2#.Count+1;
      cab_chain2#(cab_chain2#.Count+1):=rv#;
      D('Цепь ['||CableNo$||'] CABLE_RECORD_ID ['||CableRecodrdID$
      ||'] начинается с RLINE_ELEMENT_ID ['||RlineStartElementID$
      ||'], X1='||rv#.X1||', Y1='||rv#.Y1||', Z1='||rv#.Z1
      ||', X2='||rv#.X2||', Y2='||rv#.Y2||', Z2='||rv#.Z2
      ||', Length = '||rv#.LENGTH||'.'
      ,'Info In SP.BRCM#TJ.GetRLineChain');
    Else
      cab_chain1#(cab_chain1#.Count+1):=rv#;
    End If;
  End Loop;
  
  If cab_chain2#.Count!=1 Then
    If cab_chain2#.Count<1 Then
      D('Цепь ['||CableNo$||'] CABLE_RECORD_ID ['||CableRecodrdID$||
      '] ссылается на RLINE_ELEMENT_ID ['||RlineStartElementID$||
      '], который отсутствует в V_CableRLineRecordRelations.'
      ,'ERROR In SP.BRCM#TJ.GetRLineChain');
    Else
      D('Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
      '] ссылается на RLINE_ELEMENT_ID ['||RlineStartElementID$||
      '], который присутсвует в V_CableRLineRecordRelations '||
      cab_chain2#.Count||
      ' раз, тем самым нарушая однозначность соответствия.'
      ,'ERROR In SP.BRCM#TJ.GetRLineChain');
    End If;
  Else
    --------------------------------------------------------------------------
    -- Упорядочивание элементов из cab_chain1 
    -- и переписывание их в конец cab_chain2
    While cab_chain1#.Count>0
    Loop
      r_current#:=cab_chain2#(cab_chain2#.Last);
      SP.VEC#SEGMENT.SetAB
      (r_current#.X1,r_current#.Y1,r_current#.Z1
      ,r_current#.X2,r_current#.Y2,r_current#.Z2);
      
      
      i1#:=cab_chain1#.First;
      BoNextRecordFound:=false;
      While Not i1# Is Null 
      Loop
        r_next#:=cab_chain1#(i1#);
        SP.VEC#SEGMENT.SetCD
        (r_next#.X1,r_next#.Y1,r_next#.Z1,r_next#.X2,r_next#.Y2,r_next#.Z2);
        
        SP.VEC#SEGMENT.CalcSegmentIntersection;
        If SP.VEC#SEGMENT.Intersected
        Then
          If r_current#.ORIENTATION=0 And SP.VEC#SEGMENT.OrientationAB != 0
          Then
            r_current#.ORIENTATION := SP.VEC#SEGMENT.OrientationAB;
            cab_chain2#(cab_chain2#.Last):=r_current#;
          ElsIf ABS(r_current#.ORIENTATION)=2 
                            And SP.VEC#SEGMENT.OrientationAB != 0
          Then
            If r_current#.ORIENTATION * SP.VEC#SEGMENT.OrientationAB <0 Then
              --сюда попадать не должны при правильном пректировании 
              --программного комплекса Bentley
              D('1. Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
              '] имеет звено № '||cab_chain2#.Count||
              ', RLINE_ELEMENT_ID['
              ||r_current#.RL_RID_S(r_current#.RL_RID_S.First)
              ||'], HP_RWID ['||r_current#."HP_RWID"
              ||'], X1='||r_current#.X1||', Y1='||r_current#.Y1||', Z1='
              ||r_current#.Z1||', X2='||r_current#.X2||', Y2='||r_current#.Y2
              ||', Z2='||r_current#.Z2||', ориентация котрого противоречива.'
              ,'Warning In SP.BRCM#TJ.GetRLineChain');
            End If;
            r_current#.ORIENTATION := SP.VEC#SEGMENT.OrientationAB;
            cab_chain2#(cab_chain2#.Last):=r_current#;
          ElsIf SP.VEC#SEGMENT.OrientationAB != 0
          Then
            If r_current#.ORIENTATION <> SP.VEC#SEGMENT.OrientationAB Then
              --сюда попадать не должны при правильном пректировании 
              --программного комплекса Bentley
              D('2. Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
              '] имеет звено № '||cab_chain2#.Count||', RLINE_ELEMENT_ID['
              ||r_current#.RL_RID_S(r_current#.RL_RID_S.First)
              ||'], HP_RWID ['||r_current#."HP_RWID"
              ||'], X1='||r_current#.X1||', Y1='||r_current#.Y1||', Z1='
              ||r_current#.Z1||', X2='||r_current#.X2||', Y2='||r_current#.Y2
              ||', Z2='||r_current#.Z2||', ориентация котрого противоречива.'
              ,'Warning In SP.BRCM#TJ.GetRLineChain');
            End If;
          End If;
          
          If SP.VEC#SEGMENT.Is_AB_Fragmented Then
            r_current#.IS_PART:=1;
            --Замена последней записи из cab_chain2#
            --на другую, с другими концами и длиной
            If r_current#.ORIENTATION >= 1 Then
              r_current#.X2:=SP.VEC#SEGMENT.PT(1);
              r_current#.Y2:=SP.VEC#SEGMENT.PT(2);
              r_current#.Z2:=SP.VEC#SEGMENT.PT(3);
              r_current#.LENGTH:=
              SQRT(SP.BRCM#DUMP.Dist2(r_current#.X1,r_current#.Y1,r_current#.Z1
                        ,r_current#.X2,r_current#.Y2,r_current#.Z2));

            ElsIf r_current#.ORIENTATION <= -1 Then
              r_current#.X1:=SP.VEC#SEGMENT.PT(1);
              r_current#.Y1:=SP.VEC#SEGMENT.PT(2);
              r_current#.Z1:=SP.VEC#SEGMENT.PT(3);
              r_current#.LENGTH:=
              SQRT(SP.BRCM#DUMP.Dist2(r_current#.X1,r_current#.Y1,r_current#.Z1
                        ,r_current#.X2,r_current#.Y2,r_current#.Z2));

            Else
              --не знаем, какой конец выбрать, поэтому оставляем отрезок 
              --без изменений и пишем предупреждение
              D('Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
              '] имеет неориентированное звено № '||cab_chain2#.Count||
              ', RLINE_ELEMENT_ID['
              ||r_current#.RL_RID_S(r_current#.RL_RID_S.First)
              ||'], HP_RWID ['||r_current#."HP_RWID"
              ||'], X1='||r_current#.X1||', Y1='||r_current#.Y1||', Z1='
              ||r_current#.Z1||', X2='||r_current#.X2||', Y2='||r_current#.Y2
              ||', Z2='||r_current#.Z2
              ||', которое подлежит разбиению в точке ('
              ||SP.VEC#SEGMENT.PT(1)||'; '||SP.VEC#SEGMENT.PT(2)||'; '
              ||SP.VEC#SEGMENT.PT(3)||'). Звено оставлено не разбитым.'
              ,'Warning In SP.BRCM#TJ.GetRLineChain');
            End If;
--        D('Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
--        '] имеет фрагментированное звено № '||cab_chain2#.Count||
--        ', RLINE_ELEMENT_ID['||r_current#.RL_RID_S(r_current#.RL_RID_S.First)
--        ||'], HP_RWID ['||r_current#."HP_RWID"
--        ||'], X1='||r_current#.X1||', Y1='||r_current#.Y1||', Z1='
--        ||r_current#.Z1||', X2='||r_current#.X2||', Y2='||r_current#.Y2
--        ||', Z2='||r_current#.Z2
--        ||', которое подлежит разбиению в точке ('
--        ||SP.VEC#SEGMENT.PT(1)||'; '||SP.VEC#SEGMENT.PT(2)||'; '
--        ||SP.VEC#SEGMENT.PT(3)||').'
--        ,'DEBUG In SP.BRCM#TJ.GetRLineChain');

            cab_chain2#(cab_chain2#.Last):=r_current#;
          End If; --Is_AB_Fragmented

        --Если RLines смежные, то записываем найденную (r_next) RLine в 
        --cab_chain2 и удаляем ее из cab_chain1.
          If SP.VEC#SEGMENT.Is_CD_Fragmented Then
            --вычислениe концов отрезка r_next# и его длины
            r_tmp1#:=r_next#;
            r_tmp1#.X1:=SP.VEC#SEGMENT.PS(1);
            r_tmp1#.Y1:=SP.VEC#SEGMENT.PS(2);
            r_tmp1#.Z1:=SP.VEC#SEGMENT.PS(3);
            r_tmp1#.ORIENTATION:=1;
            r_tmp1#.IS_PART:=1;

            r_tmp2#:=r_next#;
            r_tmp2#.X2:=SP.VEC#SEGMENT.PS(1);
            r_tmp2#.Y2:=SP.VEC#SEGMENT.PS(2);
            r_tmp2#.Z2:=SP.VEC#SEGMENT.PS(3);
            r_tmp2#.ORIENTATION:=-1;
            r_tmp2#.IS_PART:=1;
            
            cab_chain_probe#.Delete;
            cab_chain_probe#:=cab_chain1#;
            cab_chain_probe#.Delete(i1#);

            SP.VEC#SEGMENT.SetAB
              (r_tmp1#.X1,r_tmp1#.Y1,r_tmp1#.Z1
                    ,r_tmp1#.X2,r_tmp1#.Y2,r_tmp1#.Z2);            
            
            If Intersect1(cab_chain_probe#) Then
              r_next#:=r_tmp1#;
            Else
              SP.VEC#SEGMENT.SetAB
                (r_tmp2#.X1,r_tmp2#.Y1,r_tmp2#.Z1
                      ,r_tmp2#.X2,r_tmp2#.Y2,r_tmp2#.Z2);            

              If Intersect1(cab_chain_probe#) Then
                r_next#:=r_tmp1#;
              Else
                --оставляем неориентированный целый сегмент 
                --пишем предупреждение в лог
                --такое может случиться, если предпоследний отрезок входит во
                --внутрь последнего отрезка (и это тупиковая ситуация)
                D('Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
                '] имеет фрагментированное звено № '||(cab_chain2#.Count+1)||
                ', RLINE_ELEMENT_ID['||r_next#.RL_RID_S(r_next#.RL_RID_S.First)
                ||'], HP_RWID ['||r_next#."HP_RWID"
                ||'], X1='||r_next#.X1||', Y1='||r_next#.Y1||', Z1='
                ||r_next#.Z1||', X2='||r_next#.X2||', Y2='||r_next#.Y2
                ||', Z2='||r_next#.Z2
                ||', которое подлежит разбиению в точке ('
                ||r_tmp1#.X1||'; '||r_tmp1#.Z1||'; '||r_tmp1#.Z1||').'
                ||' Однако данное разбиение осуществить не удалось, поскольку'
                ||' неизвестно какую часть требуется оставить (с точкой '
                ||'(X1:Y1:Z1) или с точкой (X2:Y2:Z2)).'
                ,'Warning In SP.BRCM#TJ.GetRLineChain');
              End If;
            End If;
            
            -- возвращаем всё как было в начале цикла (хотя это и не нужно, 
            -- т.к. будем переходить к следующему шагу)
            SP.VEC#SEGMENT.SetAB
              (r_current#.X1,r_current#.Y1,r_current#.Z1
                    ,r_current#.X2,r_current#.Y2,r_current#.Z2);
            
            If r_next#.IS_PART=1 Then
              r_next#.LENGTH:=SQRT(SP.BRCM#DUMP.Dist2
                              (r_next#.X1,r_next#.Y1,r_next#.Z1
                              ,r_next#.X2,r_next#.Y2,r_next#.Z2));
            End If;
            r_next#.ORDINAL :=cab_chain2#.Last+1;
            cab_chain2#(r_next#.ORDINAL):=r_next#;
          Else
            r_next#.ORIENTATION := SP.VEC#SEGMENT.OrientationCD;
            r_next#.ORDINAL :=cab_chain2#.Last + 1;
            cab_chain2#(r_next#.ORDINAL) := r_next#;
          End If;

          BoNextRecordFound:=true;
          cab_chain1#.Delete(i1#);
          Exit When true;
        End If;
        i1#:=cab_chain1#.Next(i1#);
      End Loop;
      
      Exit When Not BoNextRecordFound;
    End Loop;
    
    If cab_chain1#.Count>0
    Then
      r_current#:=cab_chain2#(cab_chain2#.Last);
      D('Цепь ['||CableNo$||'] RECORD_ID ['||CableRecodrdID$||
      '] претерпела разрыв на '||cab_chain2#.Count||
      '-м элементе RLINE_ELEMENT_ID['
      ||r_current#.RL_RID_S(r_current#.RL_RID_S.First)
      ||'], HP_RWID ['||r_current#."HP_RWID"
      ||'], X1='||r_current#.X1||', Y1='||r_current#.Y1||', Z1='
      ||r_current#.Z1||', X2='||r_current#.X2||', Y2='||r_current#.Y2
      ||', Z2='||r_current#.Z2||'. Остались оторванными '
      || cab_chain1#.Count ||' элементов.'
      ,'Warning In SP.BRCM#TJ.GetRLineChain');
      ------------------------------------------------------------------------
      i2#:=cab_chain2#.First;
      rv#:=cab_chain2#(i2#);
      e1#:='Начальные элементы цепи ['||CableNo$||']:';
      While Not i2# Is Null 
      Loop
        rv#:=cab_chain2#(i2#);
        e2#:=CHR(10)||CHR(13)||rv#.ORDINAL||'. RL_RID ['
        ||rv#.RL_RID_S(rv#.RL_RID_S.First)||'],'||CHR(10)||CHR(13)
        ||' X1='||rv#.X1||', Y1='||rv#.Y1||', Z1='||rv#.Z1
        ||','||CHR(10)||CHR(13)||
        ' X2='||rv#.X2||', Y2='||rv#.Y2||', Z2='||rv#.Z2||'.'
        ;
        SP.BRCM#DUMP.D_Long(e1#,e2#,'Warning In SP.BRCM#TJ.GetRLineChain');
        i2#:=cab_chain2#.Next(i2#);
      End Loop;
      
      D(e1#,'Warning In SP.BRCM#TJ.GetRLineChain');
      ------------------------------------------------------------------------
      i1#:=cab_chain1#.First;
      rv#:=cab_chain1#(i1#);
      e1#:='Неучтенные элементы цепи ['||CableNo$||']:';
      While Not i1# Is Null 
      Loop
        rv#:=cab_chain1#(i1#);
        e2#:=CHR(10)||CHR(13)||'RL_RID ['||rv#.RL_RID_S(rv#.RL_RID_S.First)
        ||'],'||CHR(10)||CHR(13)
        ||' X1='||rv#.X1||', Y1='||rv#.Y1||', Z1='||rv#.Z1
        ||','||CHR(10)||CHR(13)||
        ' X2='||rv#.X2||', Y2='||rv#.Y2||', Z2='||rv#.Z2||'.'
        ;
        SP.BRCM#DUMP.D_Long(e1#,e2#,'Warning In SP.BRCM#TJ.GetRLineChain');
        i1#:=cab_chain1#.Next(i1#);
      End Loop;
      
      D(e1#,'Warning In SP.BRCM#TJ.GetRLineChain');
      
    End If;
  End If;
  Return cab_chain2#;
End GetRLineChain;

--==============================================================================
--Добавляет содержимое массива b$ в конец массива a$
Procedure Append(a$ In Out AA_Numbers, b$ In AA_Numbers)
As
  i# BINARY_INTEGER;
Begin
  i#:=b$.First;
  While Not i# Is Null Loop
    If a$.Count>0 Then
      a$(a$.Last+1):=b$(i#);
    Else
      a$(1):=b$(i#);
    End If;
    i#:=b$.Next(i#);
  End Loop;
End;
--==============================================================================
--Возвращает истну, если номера полок эквивалентны.
--Пустые номера полок считаются эквивалентными.
Function EQ_ShelfNum(ShelfNum1$ In varchar2, ShelfNum2$ In Varchar2) 
Return Boolean
Is
Begin
  If ShelfNum1$ Is Null And ShelfNum2$ Is Null Then
    Return True;
  End If;
  Return (ShelfNum1$ = ShelfNum2$);
End;
--==============================================================================
-- Возвращает последовательности участков, вдоль которых лежат кабели.
-- Каждому кабелю соответствует ровно одна последовательность участков, 
-- занумерованная индексом ORDINAL, начиная с 1.  
Function Get_CABLE_WAY_SEGMENT_CHAIN(CBL_RID$ In SP.BRCM_CABLE.CBL_RID%TYPE)  --================<=====бывшая SP.BRCM.V_1CABLE_WAY_SEGMENT_CHAINS
Return AA_CABLE_WAY_SEGMENT_CHAIN
Is
  r# R_CABLE_WAY_SEGMENT;
  -- rv#.CBL_RID  ----<===============================================================CableNo# rv#."HP_CableNo"%TYPE;
  cab_chain# AA_CABLE_WAY_SEGMENT_CHAIN;
  i# BINARY_INTEGER;
  
  --Склеивает две записи R_CABLE_SHELF_CHAIN_MEMBER, 
  --если их координаты это позволяют
  Function Glue2Items(
  r1$ In R_CABLE_WAY_SEGMENT
  , r2$ In R_CABLE_WAY_SEGMENT
  , rr$ Out NoCopy R_CABLE_WAY_SEGMENT  ) Return Boolean
  As
  Begin
    If SP.BRCM#DUMP.EQ_PointsXYZ(r1$.X1,r1$.Y1,r1$.Z1,r2$.X1,r2$.Y1,r2$.Z1)=1 
    Then
      rr$:=r1$;
      rr$.LENGTH:=r1$.LENGTH+r2$.LENGTH;
      rr$.X1:=r2$.X2;
      rr$.Y1:=r2$.Y2;
      rr$.Z1:=r2$.Z2;
      Append(rr$.RL_RID_S,r2$.RL_RID_S);
      Return True;
    End If;

    If SP.BRCM#DUMP.EQ_PointsXYZ(r1$.X1,r1$.Y1,r1$.Z1,r2$.X2,r2$.Y2,r2$.Z2)=1 
    Then
      rr$:=r1$;
      rr$.LENGTH:=r1$.LENGTH+r2$.LENGTH;
      rr$.X1:=r2$.X1;
      rr$.Y1:=r2$.Y1;
      rr$.Z1:=r2$.Z1;
      Append(rr$.RL_RID_S,r2$.RL_RID_S);
      Return True;
    End If;

    If SP.BRCM#DUMP.EQ_PointsXYZ(r1$.X2,r1$.Y2,r1$.Z2,r2$.X2,r2$.Y2,r2$.Z2)=1 
    Then
      rr$:=r1$;
      rr$.LENGTH:=r1$.LENGTH+r2$.LENGTH;
      rr$.X2:=r2$.X1;
      rr$.Y2:=r2$.Y1;
      rr$.Z2:=r2$.Z1;
      Append(rr$.RL_RID_S,r2$.RL_RID_S);
      Return True;
    End If;
    
    If SP.BRCM#DUMP.EQ_PointsXYZ(r1$.X2,r1$.Y2,r1$.Z2,r2$.X1,r2$.Y1,r2$.Z1)=1 
    Then
      rr$:=r1$;
      rr$.LENGTH:=r1$.LENGTH+r2$.LENGTH;
      rr$.X2:=r2$.X2;
      rr$.Y2:=r2$.Y2;
      rr$.Z2:=r2$.Z2;
      Append(rr$.RL_RID_S,r2$.RL_RID_S);
      Return True;
    End If;

    return False;
  End Glue2Items;
  
  -- склеивает последовательные элементы цепочек, если у них одинаковые
  -- значения поля COURSE_NAME
  Procedure Glue(cab_cha$ In Out AA_CABLE_WAY_SEGMENT_CHAIN)
  Is
--    RL_RIS_S# AA_Numbers;
    
    NewEID# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
    idx# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
    
    i_cur# BINARY_INTEGER;
    i_next# BINARY_INTEGER;
    ord# BINARY_INTEGER;
    rc# R_CABLE_WAY_SEGMENT;  -- current record 
    rn# R_CABLE_WAY_SEGMENT;  --next record
    rr# R_CABLE_WAY_SEGMENT;  --result record
  Begin
    i_cur#:=cab_cha$.First;
    While Not i_cur# Is Null
    Loop
      rc#:=cab_cha$(i_cur#);
      <<gugu>>
      i_next#:=cab_cha$.Next(i_cur#);
      While Not i_next# Is Null 
      Loop
        rn#:=cab_cha$(i_next#);
        
        If rc#.COURSE_NAME=rn#.COURSE_NAME And 
          EQ_ShelfNum(rc#.SHELF_NUM, rn#.SHELF_NUM) And
          Glue2Items(rc#,rn#,rr#)Then

--          RL_RIS_S#(rc#.RL_RID):=1;
--          RL_RIS_S#(rn#.RL_RID):=2;

          rc#:=rr#;
          cab_cha$(i_cur#):=rr#;
          cab_cha$.Delete(i_next#);
          goto gugu;
        End If;
        i_next#:=cab_cha$.Next(i_next#);
      End Loop;  --i_next#
      
--      If EIDs#.Count>1 Then
--        idx#:=EIDs#.First;
--        NewEID#:=idx#;
--        While Not idx# Is Null
--        Loop
--          idx#:=EIDs#.Next(idx#);
--          If Not idx# Is Null And idx# < NewEID# Then
--            NewEID#:=idx#;
--          End If;
--        End Loop;
--        EIDs#.Delete;
        --cab_cha$(i_cur#).RLINE_ELEMENT_ID:=NewEID#;
--      End If;
      i_cur#:=cab_cha$.Next(i_cur#);
    End Loop;
    
    --пересчёт ординалов и OID
    
    i_cur#:=cab_cha$.First;
    ord#:=1;
    While Not i_cur# Is Null
    Loop
      rc#:=cab_cha$(i_cur#);
      rc#.ORDINAL:=ord#;
      --rc#.OID:=SHA1(rc#.COURSE_NAME||rc#.RLINE_ELEMENT_ID);
      cab_cha$(i_cur#):=rc#;
      ord#:=ord#+1;
      i_cur#:=cab_cha$.Next(i_cur#);
    End Loop; 
    
  End Glue;
Begin

  --ЭТАП 1 Добыча полок для кабеля
  --сначала добываем кабели (SP.BRCM.V_Cables) и начальную 
  --полку(V_Cables.RLINE_ELEMENT_ID).
  For r in (
    SELECT *
    FROM SP.BRCM_CFC 
    WHERE CBL_RID=CBL_RID$
    ORDER BY ORDINAL ASC 
  )Loop

    r#:=CABLE_WAY_SEGMENT_Init(RL_RID$ => r.RL_RID);
    --порядковый номер сегмента в последовательности
    r#.ORDINAL:= r.ORDINAL;
    cab_chain#(cab_chain#.Count+1):=r#;
  End Loop; 
  Glue(cab_chain#);
  Return cab_chain#;
End Get_CABLE_WAY_SEGMENT_CHAIN;
--==============================================================================
-- Устанавливает текущую модель в ту, 
-- к которой относится объект MODEL_OBJECT_ID$
-- либо возбуждает исключение
Procedure Set_CurModel_By_MODEL_OBJECT(MODEL_OBJECT_ID$ In Number)
As
  MODEL_NAME# SP.MODELS.NAME%TYPE;
  EM# Varchar2(4000);
Begin
  Select md.NAME Into MODEL_NAME#
  From SP.MODEL_OBJECTS mo
  Inner Join SP.MODELS md
  On md.ID=mo.MODEL_ID
  Where mo.ID=MODEL_OBJECT_ID$
  ;
  SET_CurModel(MODEL_NAME#);
Exception When NO_DATA_FOUND Then 
  EM#:='MODEL_OBJECT_ID = '||MODEL_OBJECT_ID$
  ||' не есть ID какого-либо объекта какой-либо модели.';
   D(EM#, 'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
   
   raise_application_error(-20033, EM#);
  
End;
--==============================================================================
--Копирует данные кабельного журнала из BRCM||DUMP в структуру работы модели TJ.
Procedure BRCM_DUMP_2_TJ(WorkID$ In Number)
As
EM# Varchar2(4000);

--ID папки с изделиями
--DEVICES_ID# Number;
--ID папки с кабелями
--CABLES_ID# Number;
--ID папки с кабельными конструкциями
CABLE_CONSTRUCTIONS_ID# Number;
--ID папки со стеллажами  (локами)
RACKS_ID# Number;
--ID папки с трубами
TUBES_ID# Number;
--ID папки с воздушными прёмами
AIRGAPS_ID# Number;
--ID папки отношений многие ко многим
REFERENCES_ID# Number;

SINGLE_ID# Number;

SMETA_CLASS# Varchar2(20);
RACEWAY_CLASS# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

--Количество безымянных направлений кабелепроводов 
UndefinedCourseNameCount# BINARY_INTEGER:=0;

 --Экспорт информации о кабельнях трассах, лотках, кабелях из 
 --BRCM DUMP в TJ
 Procedure CableTracesEXP
 As
    --Длина кабеля
    CWS_Chain# AA_CABLE_WAY_SEGMENT_CHAIN;
    i# BINARY_INTEGER;
    cab_ord# BINARY_INTEGER;  --счётчик кабелей
    r# R_CABLE_WAY_SEGMENT;
    Par# SP.TMPAR;
    cab_idx# SP.TJ_WORK.AA_ObjName2ID;
    CableID# Number;
    rLine# SP.BRCM_RLINE%ROWTYPE;
    RL_RID# SP.BRCM_RLINE.RL_RID%TYPE;
    CableSegmentID# Number;
    CableSegmentName# Varchar2(4000);
    TubeOID# SP.MODEL_OBJECTS.OID%TYPE;
    CableWaySegmentID# Number;
    RackOID# SP.MODEL_OBJECTS.OID%TYPE;
    RackID# Number;

     --Создаёт объект модели типа стеллаж
    Function CreateRackObject1(RackOID$ In Varchar2, RackName$ In Varchar2)
     Return Number
     Is
       IP# SP.G.TMACRO_PARS;
       rv# Number;
     Begin
       IP#('NAME'):=S_(RackName$);
       IP#('PARENT'):=S_('');
       IP#('Примечание'):=
         S_('выгружен из Bentley RCM методом SP.BRCM#TJ.BRCM_DUMP_2_TJ.');
       IP#('OID'):=SP.TVALUE('OID',RackOID$);
       IP#('PID'):=SP.TVALUE('ID',RACKS_ID#);
       EM#:=SP.M.TEST_PARAMS(IP#, SP.TJ_WORK.Get_TRAY_OBJECT_ID);
       If Not EM# Is Null Then
         EM#:='Ошибка создания объекта "СТЕЛЛАЖ". '
         ||CHR(13)||CHR(10)||EM#;
         D(EM#, 'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         
         raise_application_error(-20033, EM#);
       End If;
       
       
       rv#:=SP.MO.MERGE_OBJECT(IP#,SP.TJ_WORK.Get_TRAY_OBJECT_ID); 
       
       Return rv#;
     Exception When OTHERS Then
         EM#:='Ошибка создания объекта "СТЕЛЛАЖ". NAME['||RackName$
         ||'], OID ['||RackOID$||']:'
         ||CHR(13)||CHR(10)||SQLERRM;
         D(EM#, 'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
       raise;
     End CreateRackObject1;
     
     --Создаёт объект модели типа полка многополочного стеллажа
     --TODO 
    Function CreateRackShelfObject
     (TrayID$ In Number, r$ In R_CABLE_WAY_SEGMENT)
     Return Number
     Is
       IP# SP.G.TMACRO_PARS;
       rv# Number;
     Begin
       IP#('NAME'):=S_(r$.SHELF_NUM);
       IP#('PARENT'):=S_('');
       IP#('Примечание'):=
         S_('Выгружен из Bentley RCM методом SP.BRCM#TJ.BRCM_DUMP_2_TJ.');
       IP#('OID'):=SP.TVALUE('OID',r$.OID);
       IP#('PID'):=SP.TVALUE('ID',TrayID$);
       EM#:=SP.M.TEST_PARAMS(IP#, SP.TJ_WORK.Get_CWS_OBJECT_ID);
       If Not EM# Is Null Then
         EM#:='Ошибка создания объекта "ПОЛКА СТЕЛЛАЖА". '
         ||CHR(13)||CHR(10)||EM#;
         D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         raise_application_error(-20033,EM#);
       End If;
        
       Begin       
       rv#:=SP.MO.MERGE_OBJECT(IP#,SP.TJ_WORK.Get_CWS_OBJECT_ID); 
       
       Return rv#;
       Exception When OTHERS Then
         EM#:='Ошибка SP.MO.MERGE_OBJECT:'||CHR(13)||CHR(10)||SQLERRM;
         D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         raise_application_error(-20033,EM#);
       End;
     Exception When OTHERS Then
       EM#:='Неустановленная ошибка:'||CHR(13)||CHR(10)||SQLERRM;
       D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
       Raise;
     End CreateRackShelfObject;

     --Создаёт объект модели типа CABLE_WAY_SEGMENT
    Function CreateCWSObject
     (TraysID$ In Number, r$ In R_CABLE_WAY_SEGMENT)
     Return Number
     Is
       IP# SP.G.TMACRO_PARS;
       rv# Number;
     Begin
       IP#('NAME'):=S_(r$.COURSE_NAME);
       IP#('PARENT'):=S_('');
       IP#('Примечание'):=
         S_('выгружен из Bentley RCM методом SP.BRCM#TJ.BRCM_DUMP_2_TJ.');
       IP#('OID'):=SP.TVALUE('OID',r$.OID);
       IP#('PID'):=SP.TVALUE('ID',TraysID$);
       EM#:=SP.M.TEST_PARAMS(IP#, SP.TJ_WORK.Get_CWS_OBJECT_ID);
       If Not EM# Is Null Then
         EM#:='Ошибка создания объекта "СТЕЛЛАЖ ОДНОПОЛОЧНЫЙ".'
         ||CHR(13)||CHR(10)||EM#;
         D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         raise_application_error(-20033,EM#);
       End If;
        
       Begin       
       rv#:=SP.MO.MERGE_OBJECT(IP#,SP.TJ_WORK.Get_CWS_OBJECT_ID); 
       
       Return rv#;
       Exception When OTHERS Then
         EM#:='Ошибка SP.MO.MERGE_OBJECT:'||CHR(13)||CHR(10)||SQLERRM;
         D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         raise_application_error(-20033,EM#);
       End;
     Exception When OTHERS Then
       EM#:='Неустановленная ошибка:'||CHR(13)||CHR(10)||SQLERRM;
       D(EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
       Raise;
     End CreateCWSObject;
        
    --создает объект модели CableSegment
    Function CreateCableSegmentObject1
     (CableID$ In Number, ShelfID$ In Number, CableSegmentName$ In Varchar2
     , r$ In R_CABLE_WAY_SEGMENT)
    Return Number
    Is
       IP# SP.G.TMACRO_PARS;
       rv# Number;
       z_min# Number;
       z_max# Number;
    Begin
       IP#('NAME'):=S_(CableSegmentName$);
       IP#('PARENT'):=S_('');
       IP#('PID'):=SP.TVALUE('ID',REFERENCES_ID#);
       IP#('ORDINAL'):=I_(to_char(r$.ORDINAL));
       IP#('REF_CABLE'):=REL_(ID=>CableID$);
       IP#('REF_SHELF'):=REL_(ID=>ShelfID$);
       
       --IP#('LENGTH'):=N_(r$.LENGTH);---------------------------------------------------<>2019-11-21------
       If r$.Z1<r$.Z2 Then
         z_min#:=r$.Z1;
         z_max#:=r$.Z2;
       Else
         z_min#:=r$.Z2;
         z_max#:=r$.Z1;
       End If;
       
       IP#('ZMIN_ZMAX_LENGTH'):=P3_(X => z_min#, Y => z_max#, Z => r$.LENGTH);
       --end-----------------------------------------------------------------------------<>2019-11-21------
       
       EM#:=SP.M.TEST_PARAMS(IP#, SP.TJ_WORK.Get_CABLE_SEGMENT_OBJECT_ID);
       If Not EM# Is Null Then
         D('Ошибка создания объекта-отношения "CableSegment". '
         ||CHR(13)||CHR(10)||EM#,'ERROR In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
         
         raise_application_error(-20033,
         'Ошибка создания объекта-отношения "CableSegment". '
         ||CHR(13)||CHR(10)||EM#);
       End If;
       
       rv#:=SP.MO.MERGE_OBJECT(IP#,SP.TJ_WORK.Get_CABLE_SEGMENT_OBJECT_ID); 
       
      Return rv#;
    End CreateCableSegmentObject1;

    --Возвращает ID стеллажа или Null
    Function GetRackID(RackOID$ In Varchar2) Return Number
    Is
    Begin
      Return SP.TJ_WORK.GetChildByOID(RACKS_ID#, RackOID$);
    End GetRackID;

    --Возвращает ID полки лотка или Null
    Function GetCableWaySegmentID
    (ObjParentID$ In Number, CableWaySegmentOID$ In Varchar2) Return Number
    Is
    Begin
      Return SP.TJ_WORK.GetChildByOID(ObjParentID$, CableWaySegmentOID$);
    End GetCableWaySegmentID;
     
  Begin
    
    SP.BRCM#DUMP.BRCM_CFC_PREPARE;
    --заполняем индекс имён кабелей
    SP.TJ_WORK.Get_MODEL_OBJECT_IDX(RootModObjID$=>SP.TJ_WORK.WorkID
    , ObjectID$ => SP.TJ_WORK.Get_CABLE_OBJECT_ID, idx$ => cab_idx#);

    cab_ord#:=0;
    For r_cab In (Select * From SP.BRCM_CABLE Where IS_VALID=1)
    Loop
      
      If cab_idx#.Exists(r_cab."HP_CableNo") Then
        CableID#:= cab_idx#(r_cab."HP_CableNo"); 
        --сохранение длины кабеля
        If Not r_cab."HP_CableLength" Is Null Then
          --Сохранение длины кабеля
          Par#:=SP.TMPAR(ModelObjID => CableID#, Par=>'Длина BRCM');
          Par#.Save(N_(TO_.STR(r_cab."HP_CableLength")));
        End If;
      Else
        D('Кабель дампа ['||r_cab."HP_CableNo"||'] '||r_cab.CBL_RNAME
        ||' не найден в модели TJ.','Warning In SP.BRCM#TJ.BRCM_DUMP_2_TJ');
        goto next_r_cab;
      End If;
      
      cab_ord#:=cab_ord#+1;
      -- Извлекаем участки (укрупнённые) кабельной трассы в виде AA,
      -- упорядоченного по ординалу 
    D(to_char(cab_ord#)||'. Начало обработки трассы кабеля CableNo ['
    ||r_cab."HP_CableNo"||'], CBL_RID = '||r_cab.CBL_RID||'.'
    ,'Info SP.BRCM#TJ.BRCM_DUMP_2_TJ.CableTracesEXP');
      
      CWS_Chain#:=Get_CABLE_WAY_SEGMENT_CHAIN(CBL_RID$ => r_cab.CBL_RID);
      i#:=CWS_Chain#.First;
      While Not i# Is Null Loop
        r#:=CWS_Chain#(i#);
        
        RL_RID#:=r#.RL_RID_S(r#.RL_RID_S.First);
        
        RACEWAY_CLASS#:= 
          SP.BRCM#DUMP.GetRW_CLASS(RL_RID$ => RL_RID#);
        
        SMETA_CLASS#:=SP.BRCM#DUMP.GetSmetaClass(RACEWAY_CLASS#);
        If SMETA_CLASS# = SP.BRCM#DUMP.SC_Tray Then
          If r#.COURSE_NAME Is Null Then
            rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
            UndefinedCourseNameCount#:=UndefinedCourseNameCount#+1;
            r#.COURSE_NAME:='U'||to_char(UndefinedCourseNameCount#);
            EM#:='Для кабеля ['||r_cab."HP_CableNo"
            ||'] не определен параметр COURSE_NAME объекта RLine :'
            ||' RLINE_ELEMENT_ID ['||rLine#.RL_EID||'], SHELF_NUM ['
            ||r#.SHELF_NUM||'], SHELF_OID ['||r#.OID||'], Ordinal ['
            ||r#.Ordinal||'], RACEWAY_CLASS ['||RACEWAY_CLASS#
            ||']. Программа присвоила ему имя ['||r#.COURSE_NAME||'].';
            D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
          Else
            Begin
              RackOID#:=GetRackOID(RackName$ => r#.COURSE_NAME );
            Exception When NO_DATA_FOUND Then
              rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
              EM#:='Кабель ['||r_cab."HP_CableNo"||'], RLINE_ELEMENT_ID ['
              ||rLine#.RL_EID||'], SHELF_NUM ['||r#.SHELF_NUM
              ||']. Для стеллажа COURSE_NAME ['||r#.COURSE_NAME
              ||'], SMETA_CLASS ['||SMETA_CLASS#||'], RACEWAY_CLASS ['
              ||RACEWAY_CLASS#||'] не найден OID лотка.';
    
              D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
    
              raise_application_error
                (-20033,'SP.BRCM#TJ.CableTracesEXP. '||EM#);
              
            End;
          End If;

          If Not r#.SHELF_NUM Is Null Then
            --многополочные стеллажи
            RackID#:=GetRackID(RackOID#);
            If RackID# Is Null Then
                --Многополочные стеллажи
                RackID#:=CreateRackObject1(
                  RackOID$ => RackOID#
                  , RackName$ => r#.COURSE_NAME);
            End If;
            CableWaySegmentID#:=GetCableWaySegmentID
            (ObjParentID$ => RackID#, CableWaySegmentOID$=> r#.OID);
            If CableWaySegmentID# Is Null Then
            Begin
              CableWaySegmentID#:=CreateRackShelfObject
              (TrayID$ => RackID#, r$ => r#);
            Exception When OTHERS Then
              rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
            
              EM#:='Ошибка создания объекта "ПОЛКА СТЕЛЛАЖА":'
              ||'Кабель '||r_cab."HP_CableNo"||', RLINE_ELEMENT_ID ['
              ||rLine#.RL_EID||'], SHELF_NUM ['||r#.SHELF_NUM
              ||'], SHELF_OID ['||r#.OID||'], сегмент кабелепровода ['
              ||r#.COURSE_NAME||'].'||CHR(13)||CHR(10)||SQLERRM;
              D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
              Raise;
            End;
            End If;
            
            CableSegmentName#:=
              r_cab."HP_CableNo"||'#'||LPAD(to_char(r#.ORDINAL),5,'0');
              
            CableSegmentID#:= 
              SP.TJ_WORK.GetChildByName(REFERENCES_ID#, CableSegmentName#);
            If CableSegmentID# Is Null Then
              CableSegmentID#:=CreateCableSegmentObject1(
                CableID$ => CableID#
                , ShelfID$ => CableWaySegmentID#
                , CableSegmentName$ => CableSegmentName#
                , r$ => r#);
            End If;
            
          Else
            CableWaySegmentID#:=GetCableWaySegmentID
            (ObjParentID$ => RACKS_ID#, CableWaySegmentOID$ => r#.OID);
            If CableWaySegmentID# Is Null Then
            Begin
              CableWaySegmentID#:=CreateCWSObject
              (TraysID$ => RACKS_ID#, r$ => r#);
            Exception When OTHERS Then
              rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
              EM#:='Ошибка создания объекта "СТЕЛЛАЖ ОДНОПОЛОЧНЫЙ":'
              ||'Кабель '||r_cab."HP_CableNo"||', RLINE_ELEMENT_ID ['
              ||rLine#.RL_EID||'], SHELF_NUM ['||r#.SHELF_NUM
              ||'], SHELF_OID ['||r#.OID||'], сегмент кабелепровода ['
              ||r#.COURSE_NAME||'].'||CHR(13)||CHR(10)||SQLERRM;
              D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
              Raise;
            End;
            End If;
            CableSegmentName#:=
              r_cab."HP_CableNo"||'#'||LPAD(to_char(r#.ORDINAL),5,'0');
              
            CableSegmentID#:= 
              SP.TJ_WORK.GetChildByName(REFERENCES_ID#, CableSegmentName#);
            If CableSegmentID# Is Null Then
              CableSegmentID#:=CreateCableSegmentObject1(
                CableID$ => CableID#
                , ShelfID$ => CableWaySegmentID#
                , CableSegmentName$ => CableSegmentName#
                , r$ => r#);
            End If;
          End If;
          
        Elsif SMETA_CLASS# = SP.BRCM#DUMP.SC_Tube Then
         
          If r#.COURSE_NAME Is Null Then
            rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
          
            r#.COURSE_NAME:='Tube#'||GetNameFrom6Coordinates(r#);
            EM#:='Для кабеля ['||r_cab."HP_CableNo"
            ||'] не определен параметр COURSE_NAME объекта RLine :'
            ||' RLINE_ELEMENT_ID ['||rLine#.RL_EID||'], SHELF_NUM ['
            ||r#.SHELF_NUM||'], SHELF_OID ['||r#.OID||'], Ordinal ['
            ||r#.Ordinal||'], RACEWAY_CLASS ['||RACEWAY_CLASS#
            ||']. Программа присвоила ему имя ['||r#.COURSE_NAME||'].';
            D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
            
          End If;
          TubeOID#:=MD5('Tube'||r#.COURSE_NAME)||'|Tube';
          CableWaySegmentID#:=GetCableWaySegmentID
          (ObjParentID$ => TUBES_ID#, CableWaySegmentOID$=> TubeOID#);
          If CableWaySegmentID# Is Null Then
          Begin
            r#.OID:=TubeOID#;
            CableWaySegmentID#:=CreateCWSObject
            (TraysID$ => TUBES_ID#, r$ => r#);
          Exception When OTHERS Then
            rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
            EM#:='Ошибка создания объекта "ТРУБА":'
            ||'Кабель '||r_cab."HP_CableNo"||', RLINE_ELEMENT_ID ['
            ||rLine#.RL_EID||'], SHELF_NUM ['||r#.SHELF_NUM
            ||'], SHELF_OID ['||r#.OID||'], сегмент кабелепровода ['
            ||r#.COURSE_NAME||'].'||CHR(13)||CHR(10)||SQLERRM;
            D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
            Raise;
          End;
          End If;
          CableSegmentName#:=
            r_cab."HP_CableNo"||'#'||LPAD(to_char(r#.ORDINAL),5,'0');
          
          CableSegmentID#:= 
            SP.TJ_WORK.GetChildByName(REFERENCES_ID#, CableSegmentName#);
          If CableSegmentID# Is Null Then
            CableSegmentID#:=CreateCableSegmentObject1(
              CableID$ => CableID#
              , ShelfID$ => CableWaySegmentID#
              , CableSegmentName$ => CableSegmentName#
              , r$ => r#);
          End If;

        Elsif SMETA_CLASS# = SP.BRCM#DUMP.SC_AirGap Then
        
          --все воздушные участки непосредственно ссылаются на один AIRGAPS_ID#
          CableSegmentName#:=
            r_cab."HP_CableNo"||'#'||LPAD(to_char(r#.ORDINAL),5,'0');
          CableSegmentID#:= 
            SP.TJ_WORK.GetChildByName(REFERENCES_ID#, CableSegmentName#);
          If CableSegmentID# Is Null Then
            CableSegmentID#:=CreateCableSegmentObject1(
              CableID$ => CableID#
              , ShelfID$ =>  AIRGAPS_ID#
              , CableSegmentName$ => CableSegmentName#
              , r$ => r#);
          End If;
          
        Else
          rLine#:=SP.BRCM#DUMP.Get_BRCM_RLINE(RL_RID$ => RL_RID#);
            EM#:='Непредусмотренное значение SMETA_CLASS ['||SMETA_CLASS#
            ||']: '||'Кабель '||r_cab."HP_CableNo"||', RL_EID ['
            ||rLine#.RL_EID||'], SHELF_NUM ['||r#.SHELF_NUM
            ||'], SHELF_OID ['||r#.OID||'], cтеллаж ['||r#.COURSE_NAME||'].';
            
            D(EM#,'Error In SP.BRCM#TJ.CableTracesEXP');
            raise_application_error
            (-20033,'Error In SP.BRCM#TJ.CableTracesEXP. '||EM#);
        End If;

        i#:=CWS_Chain#.Next(i#);
      End Loop;
     
      <<next_r_cab>> null;
    End Loop;  --r_cab: кабели
    
  End CableTracesEXP;
Begin
  SP.TJ_WORK.SetCurWork(WorkID$);
  Set_CurModel_By_MODEL_OBJECT(MODEL_OBJECT_ID$ => WorkID$)  ;
  
  CABLE_CONSTRUCTIONS_ID# := 
    SP.TJ_WORK.GetChildByName(WorkID$, SP.TJ_WORK.CABLE_CONSTRUCTIONS_NAME);
  If CABLE_CONSTRUCTIONS_ID# Is Null Then
    raise_application_error(-20033,
    'SP.BRCM#TJ.BRCM_DUMP_2_TJ. Не найлен объект '
    ||SP.TJ_WORK.CABLE_CONSTRUCTIONS_NAME
    ||', дочерний к ['||to_char(WorkID$)||'].');
  End If;

  RACKS_ID#:=
    SP.TJ_WORK.GetChildByName(CABLE_CONSTRUCTIONS_ID#, SP.TJ_WORK.TRAYS_NAME);
  If RACKS_ID# Is Null Then
    raise_application_error(-20033,
    'SP.BRCM#TJ.BRCM_DUMP_2_TJ. Не найлен объект '||SP.TJ_WORK.TRAYS_NAME
    ||', дочерний к ['||to_char(CABLE_CONSTRUCTIONS_ID#)||'].');
  Else
    D('папка '||SP.TJ_WORK.TRAYS_NAME||', дочерняя к папке '
    ||SP.TJ_WORK.CABLE_CONSTRUCTIONS_NAME
    ||', имет ID = '||to_char(RACKS_ID#),'Info SP.BRCM#TJ.BRCM_DUMP_2_TJ');
  End If;

  TUBES_ID#:=
    SP.TJ_WORK.GetChildByName(CABLE_CONSTRUCTIONS_ID#, SP.TJ_WORK.TUBES_NAME);
  If TUBES_ID# Is Null Then
    raise_application_error(-20033,
    'SP.BRCM#TJ.BRCM_DUMP_2_TJ. Не найлен объект '||SP.TJ_WORK.TUBES_NAME
    ||', дочерний к ['||to_char(CABLE_CONSTRUCTIONS_ID#)||'].');
  Else
    D('папка '||SP.TJ_WORK.TUBES_NAME||', дочерняя к папке '
    ||SP.TJ_WORK.CABLE_CONSTRUCTIONS_NAME
    ||', имет ID = '||to_char(TUBES_ID#),'Info SP.BRCM#TJ.BRCM_DUMP_2_TJ');
  End If;

  AIRGAPS_ID#:=
  SP.TJ_WORK.GetChildByName(CABLE_CONSTRUCTIONS_ID#, SP.TJ_WORK.AIRGAPS_NAME);
  If AIRGAPS_ID# Is Null Then
    raise_application_error(-20033,
    'SP.BRCM#TJ.BRCM_DUMP_2_TJ. Не найлен объект '||SP.TJ_WORK.AIRGAPS_NAME
    ||', дочерний к ['||to_char(CABLE_CONSTRUCTIONS_ID#)||'].');
  Else
    D('папка '||SP.TJ_WORK.AIRGAPS_NAME||', дочерняя к папке '
    ||SP.TJ_WORK.CABLE_CONSTRUCTIONS_NAME
    ||', имет ID = '||to_char(AIRGAPS_ID#),'Info SP.BRCM#TJ.BRCM_DUMP_2_TJ');
  End If;

  REFERENCES_ID#:=
    SP.TJ_WORK.GetChildByName(WorkID$, SP.TJ_WORK.REFERENCES_NAME);
  If REFERENCES_ID# Is Null Then
    raise_application_error(-20033,
    'SP.BRCM#TJ.BRCM_DUMP_2_TJ. Не найлен объект '||SP.TJ_WORK.REFERENCES_NAME
    ||', дочерний к ['||to_char(WorkID$)||'].');
  End If;
  
  --Экспорт информации об изделиях из BRCM DUMP в TJ
  DevicesEXP;
  
  --Экспорт информации о кабельнях трассах, лотках, кабелях из 
  --BRCM DUMP в TJ
  CableTracesEXP;
  
End BRCM_DUMP_2_TJ;
--==============================================================================

END BRCM#TJ;
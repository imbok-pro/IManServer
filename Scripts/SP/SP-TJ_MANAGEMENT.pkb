CREATE OR REPLACE PACKAGE BODY SP.TJ_MANAGEMENT
-- SP.TJ_MANAGEMENT package body
-- пакет для работы с моделью TJ
-- by Azarov SP-TJ_MANAGEMENT.pkb 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.02.18
-- update 30.03.19 31.05.19 24.07.2019 26.07.19 31.07.19 05.08.19 23.12.19

AS


"Место не задано" CONSTANT VARCHAR2(50):= 'Место не задано';
                                          --  '';
"Нет соединения"  CONSTANT VARCHAR2(50):= 'Нет соединения';
                                          --  '';
-------------------------------------------------------------------------------                                            
-- заполняет коллекцию selectedSystemIds
FUNCTION set_selectedSystemIds(Ids SP.TNUMBERS) return NUMBER
is
BEGIN
 --d(Ids.count,'TEST set_selectedSystemIds');
 --selectedSystemIds.Delete;
 selectedSystemIds := Ids;
 return selectedSystemIds.Count;
END;
-------------------------------------------------------------------------------                                            
-- возвращает коллекцию selectedSystemIds
FUNCTION get_selectedSystemIds return SP.TNUMBERS pipelined
is
BEGIN
 --d(Ids.count,'TEST get_selectedSystemIds');
for rec in
  (
   select column_value from table(selectedSystemIds) 
  )
  LOOP
   pipe row(rec.column_value);
  END LOOP;
END;
-------------------------------------------------------------------------------                                            

PROCEDURE setConstants
is
BEGIN
--Идентификаторы веток модели
select id into CurModelId from SP.MODELS where NAME = SP.TGpar('CurModel').Val.S;
d('Текущая модель ='||SP.TGpar('CurModel').Val.S||'  id = '|| CurModelId, 'setConstants');

select id into "TJ.singles.КАБЕЛЬ" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.КАБЕЛЬ';

select id into "TJ.singles.ИЗДЕЛИЕ" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.ИЗДЕЛИЕ';

select id into "TJ.singles.МЕСТО" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.МЕСТО';

select id into "TJ.singles.МАРКА КАБЕЛЯ" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.МАРКА КАБЕЛЯ';

/*
select id into "КАБЕЛИ" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'КАБЕЛИ';

select id into "ИЗДЕЛИЯ" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'ИЗДЕЛИЯ';
*/
select id into "МЕСТА" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'МЕСТА';

select id into "СИСТЕМЫ" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'СИСТЕМЫ';

select id into "ИДЕНТИФИКАТОРЫ ИЗОБРАЖЕНИЙ" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'ИДЕНТИФИКАТОРЫ ИЗОБРАЖЕНИЙ';

begin
select id into "МАРКИ КАБЕЛЯ" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = 'МАРКИ КАБЕЛЯ';
exception
when no_data_found then
d('Отсутствует узел "МАРКИ КАБЕЛЯ"','WORNING: SP.TJ_MANAGEMENT.setConstants');
end;

-- Каталожные ID-ы избранных параметров для объекта "TJ.singles.ИЗДЕЛИЕ"
select id into "HP_Primary_divace"
        from SP.OBJECT_PAR_S
        where NAME = 'HP_Primary_divace' and OBJ_ID = "TJ.singles.ИЗДЕЛИЕ";
select id into "ИД Изображения"
        from SP.OBJECT_PAR_S
        where NAME = 'ИД Изображения' and OBJ_ID = "TJ.singles.ИЗДЕЛИЕ";
select id into "Система"
        from SP.OBJECT_PAR_S
        where NAME = 'Система' and OBJ_ID = "TJ.singles.ИЗДЕЛИЕ";
select id into "HP_Image_layer"
        from SP.OBJECT_PAR_S
        where NAME = 'HP_Image_layer' and OBJ_ID = "TJ.singles.ИЗДЕЛИЕ";

-- Каталожные ID-ы избранных параметров для объекта "TJ.singles.МАРКА КАБЕЛЯ"
select id into "Диаметр"
        from SP.OBJECT_PAR_S
        where NAME = 'Диаметр' and OBJ_ID = "TJ.singles.МАРКА КАБЕЛЯ";
select id into "Масса ед"
        from SP.OBJECT_PAR_S
        where NAME = 'Масса ед' and OBJ_ID = "TJ.singles.МАРКА КАБЕЛЯ";

-- Заполним кэш-словарь марок кабеля
--d('TEST','SP.TJ_MANAGEMENT."ХАРАКТЕРИСТИКИ КАБЕЛЯ"');
for r in
(
select o.MOD_OBJ_NAME, pd.N d, pm.N m
from SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S pm
where o.OBJ_ID = "TJ.singles.МАРКА КАБЕЛЯ"
and o.PARENT_MOD_OBJ_ID = "МАРКИ КАБЕЛЯ"
      and pd.OBJ_PAR_ID = "Диаметр"
      and pd.MOD_OBJ_ID = o.id 
      and pm.OBJ_PAR_ID = "Масса ед"
      and pm.MOD_OBJ_ID = o.id 
)
LOOP 
--d(r.d||' '||r.d,'SP.TJ_MANAGEMENT."ХАРАКТЕРИСТИКИ КАБЕЛЯ"');
 "ХАРАКТЕРИСТИКИ КАБЕЛЯ"(r.MOD_OBJ_NAME).Diameter := r.d;
 "ХАРАКТЕРИСТИКИ КАБЕЛЯ"(r.MOD_OBJ_NAME).Weight := r.m;
END LOOP;
--d('Переменные пакета проинициализированы','WORNING: SP.TJ_MANAGEMENT.setConstants');
END;
                                            
-------------------------------------------------------------------------------
PROCEDURE setCurTJWorkId(Work_ID in NUMBER)
is
BEGIN
begin
if Work_ID is NULL then
 d('Пустой аргумент у функции','ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
 return;
end if;

select FULL_NAME into TJ_WORK_PATH from SP.V_MODEL_OBJECTS where ID = Work_ID;
TJ_WORK_ID := Work_ID;
exception
when no_data_found then
d('Данные о работе Id='|| Work_ID || ' не найдены '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
end;
setConstants;
--d('Переменные пакета заполнены','OK SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
END setCurTJWorkId;
-------------------------------------------------------------------------------
PROCEDURE setCurTJWorkId(Work_Path VARCHAR2)
is
BEGIN
if Work_Path is NULL then
 d('Пустой аргумент у функции','ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_Path VARCHAR2)');
 return;
end if;
TJ_WORK_PATH := RTRIM(Work_Path,'/'); -- и без этого работает, но медленнее
begin
TJ_WORK_ID := SP.MO.MOD_OBJ_ID_BY_FULL_NAME(TJ_WORK_PATH);
--select FULL_NAME from SP.V_MODEL_OBJECTS where ID = TJ_WORK_ID;
-- следующий селект ищет id значительно дольше
-- select id into TJ_WORK_ID from SP.V_CUR_MODEL_OBJECTS where CATALOG_NAME='РАБОТА' and FULL_NAME = TJ_WORK_PATH;
exception
when no_data_found then
d('Данные о работе "'|| Work_Path || '" не найдены '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(TJ_WORK_PATH VARCHAR2)');
return;
end;
setConstants;
--d('Переменные пакета заполнены','OK SP.TJ_MANAGEMENT.setCurTJWorkId(TJ_WORK_PATH)');
END setCurTJWorkId;

--------------------------------------------------------------------------------
-- Возвращает Id узла объектов с именем rootName
FUNCTION getRoot(rootName VARCHAR2) RETURN NUMBER
is
id number;
BEGIN
 CASE rootName
   WHEN 'CurModelId' THEN return CurModelId;
   WHEN 'TJ_WORK_ID' THEN return "TJ_WORK_ID";
   WHEN 'TJ_WORK_PATH' THEN return "TJ_WORK_PATH";
  -- WHEN 'КАБЕЛИ' THEN return "КАБЕЛИ";
  -- WHEN 'ИЗДЕЛИЯ' THEN return "ИЗДЕЛИЯ";
   WHEN 'МЕСТА' THEN return "МЕСТА";
   WHEN 'СИСТЕМЫ' THEN return "СИСТЕМЫ";
   WHEN 'ИДЕНТИФИКАТОРЫ ИЗОБРАЖЕНИЙ' THEN return "ИДЕНТИФИКАТОРЫ ИЗОБРАЖЕНИЙ";
   WHEN 'МАРКИ КАБЕЛЯ' THEN return "МАРКИ КАБЕЛЯ";
   WHEN 'ПОМЕЩЕНИЯ' THEN return "ПОМЕЩЕНИЯ";
   --WHEN '' THEN return "";
   ELSE return null;
 END CASE;  
END;
--------------------------------------------------------------------------------
-- замена кириллических букв на визуально похожие латинские буквы

function replaceCurToLat(str varchar2) return varchar2
 as      
 begin                                            
 return translate(str,
          'АВСЕНКМОРТХасеоху', -- кириллическиe буквы которые выглядят как английскиe
          'ABCEHKMOPTXaceoxy'  -- английскиe буквы которые выглядят как кириллическиe
         );        
 end;          
 
--------------------------------------------------------------------------------
-- замена латинских букв на визуально похожие кириллическиие буквы
function replaceLatToCur(str varchar2) return varchar2
 as      
 begin                                            
 return translate(str,
          'ABCEHKMOPTXaceoxy',  -- английскиe буквы которые выглядят как кириллическиe
          'АВСЕНКМОРТХасеоху' -- кириллическиe буквы которые выглядят как английскиe
         );        
 end;          
 
-------------------------------------------------------------------------------- 
-- возвращает идентификаторы всех КАБЕЛЕЙ текущей модели
FUNCTION get_Cables return SP.TNUMBERS pipelined
is
begin 
 for rec in
 (
 select id
    from SP.V_MODEL_OBJECTS where   
    MODEL_ID = CurModelId and
    OBJ_ID = "TJ.singles.КАБЕЛЬ"
 )
 loop
  pipe row(rec.id);
 end loop;
end;
 
-------------------------------------------------------------------------------- 
-- возвращает идентификаторы и параметры всех ИЗДЕЛИЙ текущей модели
FUNCTION get_Devices return Device_TABLE pipelined
is
begin 
 for rec in
 (
 select id, MOD_OBJ_NAME "NAME", 
        SP.GETMPAR_S(ID,'Примечание') "COMMENT",
        SP.TMPAR(ID,'Помещение').Val.N "ID_Помещения",
        SP.Val_to_Str(SP.TMPAR(ID,'XYZ').Val) "XYZ",
        SP.TMPAR(ID,'Место').Val.N "ID_Места", 
        SP.TMPAR(ID,'Система').Val.N "ID_Системы", 
        SP.Val_to_Str(SP.TMPAR(ID,'Габариты изделия').Val) "Габариты",
        SP.TMPAR(ID,'ИД Изображения').Val.N "ID_Изображения",
        SP.TMPAR(ID,'Дополнительно').Val.S "Дополнительно",
        M_DATE
    from SP.V_MODEL_OBJECTS k where   
    MODEL_ID = CurModelId and
    OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
 )
 loop
  pipe row(rec);
 end loop;
end;

-------------------------------------------------------------------------------- 
-- возвращает наименования всех слоев для изделий текущей модели
FUNCTION get_LayerName return SP.TSTRINGS pipelined
is
begin 
 for rec in
 (
/* 
 select DISTINCT nvl(TMPAR(id,'HP_Image_layer').Val.S,'TMP_Layer') layerName 
    from MODEL_OBJECTS where   
    OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
    and MODEL_ID = CurModelId
    order by layerName
*/    
-- более скоростной запрос
select DISTINCT pd.S  layerName
    from MODEL_OBJECTS o, MODEL_OBJECT_PAR_S pd 
    where   
    o.MODEL_ID = CurModelId and
    o.OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
    and 
      pd.OBJ_PAR_ID = "HP_Image_layer"
      and pd.MOD_OBJ_ID = o.id
UNION
    select 'TMP_Layer' as layerName from dual          
order by layerName
 )
 loop
  pipe row(rec.layerName);
 end loop;
end; 
--------------------------------------------------------------------------------
-- поиск изделия с именем, "максимально" (в смысле правил упрощения ККС)
-- соответствующего заданному имени.
-- Назначение функции: по заданному имени ККС места получить ККС изделия 
-- (первичного изделия, кот. физически является местом для вторичных изделий).
-- При кодировании места могут опускаться начальные нули; например первичное 
-- изделие =00BJK00 порождает место +BJK00 
 FUNCTION getDevice(placeName VARCHAR2) RETURN NUMBER
is
 devid number;
 name varchar2(100);
 begin                                            
-- идеальный случай - это когда ККС изделия == ККС места 
-- (с точностью до 1-го символа (+ или =), и все начальные нули сохранены)
 name := LTRIM(placeName,'+');
 select id into devid from SP.V_MODEL_OBJECTS where MOD_OBJ_NAME =
                                     '=' || name
                                     --and PARENT_MOD_OBJ_ID = "ИЗДЕЛИЯ"
                                     and --CATALOG_NAME = 'ИЗДЕЛИЕ'
                                           OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
                                     and MODEL_ID = CurModelId;
 return devid; 
 exception
 when NO_DATA_FOUND then 
 -- случай, когда отброшены начальные нули 
   begin
   select id into devid from SP.V_MODEL_OBJECTS where MOD_OBJ_NAME =
                                     '=00' || name 
                                     --and PARENT_MOD_OBJ_ID = "ИЗДЕЛИЯ"
                                     and --CATALOG_NAME = 'ИЗДЕЛИЕ'
                                           OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
                                     and MODEL_ID = CurModelId;
   return devid;
   exception
    when NO_DATA_FOUND then 
     -- можно попробовать найти вариант с одним откинутым нулем 
     -- (пока не будем, т.к. такое сокращение нарушает правила)
       d('Не найдено соответствующее псевдоизделие для места '||placeName
       --||' ASCIISTR()='||ASCIISTR(placeName)
       , 'WARNING in SP.TJ_MANAGEMENT.getdevice');
       return null;

     when TOO_MANY_ROWS then raise;  
   end;
 when TOO_MANY_ROWS then raise;  
 when others then
    d('Ошибка '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
      'ERROR in SP.TJ_MANAGEMENT.getdevice');
    raise;     
 end;      

-------------------------------------------------------------------------------
-- deprecated procedure
-- Процедура обновляет данные, соответствующие текущей работе, в кэш-таблице TJ_CABLES. 
-- В случае, когда свойство "Система" у кабеля определяет принадлежность 
-- кабеля к ситеме. 
/*
PROCEDURE updateTJ_CABLES_OLD
is
 KID number := 0;
 rowcount int := 0;
 Primary_divaceId1 number;
 "Место1" varchar2(500);
 Primary_divaceId2 number;
 "Место2" varchar2(500);
 mp TMPAR;
BEGIN
for r in 
(
select 
kID, kName, device1Id, device2Id, 
TMPAR(kID,'Система').Val.N systemId, -- система КАБЕЛЯ
TMPAR(kID,'№').Val.N      "№"
from
    (
       -- выборка по жилам    
      select 
      k.id kID, k.MOD_OBJ_NAME kName, 
      ( select PARENT_MOD_OBJ_ID from SP.V_MODEL_OBJECTS where 
                  id = GETMPAR_N(j.id,'REF_PIN_FIRST'))  device1Id, 
      ( select PARENT_MOD_OBJ_ID from SP.V_MODEL_OBJECTS where 
                   id = GETMPAR_N(j.id,'REF_PIN_SECOND')) device2Id 
      from SP.V_MODEL_OBJECTS k, SP.V_MODEL_OBJECTS j
      where 
             k.CATALOG_NAME = 'КАБЕЛЬ'
             and j.PARENT_MOD_OBJ_id = k.ID
             and j.CATALOG_NAME = 'ЖИЛА КАБЕЛЯ'
             and k.PARENT_MOD_OBJ_ID = "КАБЕЛИ"           
    )
order by KID    
) 
loop
-- вставляем в таблицу только если кабель с данным r.KID еще не добавлен 
if r.KID != KID 
-- и на концах не null
and r.device1Id is not null and r.device2Id is not null 
then
  begin 
    KID :=r.KID;
    begin
--    o('add cable id= '||r.KID);  
    if r.device1Id is not null then 
      -- у псевдоизделия наличие параметра HP_Primary_divace не гарантировано
        mp := TMPAR(r.device1Id,'HP_Primary_divace');  
      -- определим, является ли устройство первичным
      -- вообще-то плевать: подойдет устройство любого типа
      if mp.Val.N = 1 then 
         Primary_divaceId1 := r.device1Id;
      else 
        if GETMPAR_N(r.device1Id,'Место') is not null then         
          "Место1" := GETMPAR_S(GETMPAR_N(r.device1Id,'Место'),'NAME');
          Primary_divaceId1 := getdevice("Место1");
        else 
          "Место1" := "Место не задано";
          Primary_divaceId1 := null;
          d('Кабель '||KID||' не имеет соединения на левом конце!!!',
          'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
        end if;
      end if;  
    else
      Primary_divaceId1 := null;
      d('Кабель '||KID||' не имеет соединения на левом конце!!!',
        'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    EXCEPTION
      WHEN OTHERS THEN
        d(''||KID||'  Ошибка '||SQLERRM,
        'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end;
      
    if r.device2Id is not null then 
      mp := TMPAR(r.device2Id,'HP_Primary_divace');     
      if mp.Val.N = 1 
      then 
         Primary_divaceId2 := r.device2Id;
       else 
         if GETMPAR_N(r.device2Id,'Место') is not null then         
             "Место2" := GETMPAR_S(GETMPAR_N(r.device2Id,'Место'),'NAME');
             Primary_divaceId2 := getdevice("Место2");
         else 
             "Место2" := "Место не задано";
             Primary_divaceId2 := null;
             d('Кабель '||r.KName||' id='||KID||' не имеет соединения на правом конце!!!',
             'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
         end if;
       end if;
    else   
      Primary_divaceId2 := null;
      d('Кабель '||KID||' не имеет соединения на правом конце!!!',
      'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    
    -- d('try add cable id= '|| r.KID,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
    insert into "SP"."TJ_CABLES"(CID, CNAME, DEVICE1ID, DEVICE2ID, 
                                DEVICE1, DEVICE2, PLACE1,  PLACE2, 
                                SYSTEMID, SYSTEM, "№")    
    values (r.KID, r.KName, Primary_divaceId1, Primary_divaceId2, 
              CASE 
              when Primary_divaceId1 is null then ''
              else GETMPAR_S(Primary_divaceId1,'NAME')
              end,                 
              CASE 
              when Primary_divaceId2 is null then ''
              else GETMPAR_S(Primary_divaceId2,'NAME')
              end,        
              "Место1", "Место2", r.systemId, 
              CASE 
              when r.systemId is null then 'Не указана система!'
              else GETMPAR_S(r.systemId,'NAME')
              end,                 
              r."№"              
    );
    --rowcount := rowcount + 1;
    --d('rowcount= '|| rowcount,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
  EXCEPTION
    WHEN OTHERS THEN
      d(''||KID||'  Ошибка '||SQLERRM,
      'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
--      o(rowcount||'  '||KID||'Ошибка пакета SP.TJ_MANAGEMENT '||SQLERRM);
  end;
end if; -- r.KID != KID 
end loop;
--d('В SP.TJ_CABLES вставлено строк '||rowcount,'OK SP.TJ_MANAGEMENT.updateTJ_CABLES');
--ROLLBACK;
--RAISE;
END updateTJ_CABLES_OLD;
*/
--------------------------------------------------------------------------------
-- Выборка всех кабелей и запись во временную таблицу
PROCEDURE updateTJ_CABLES
is
 KID number;
 KPID number;
 rowcount int;
 Primary_divaceId1 number;
 "Место1" varchar2(500);
 Primary_divaceId2 number;
 "Место2" varchar2(500);
 mp TMPAR;
BEGIN
--d('start updateTJ_CABLES','updateTJ_CABLES');
--delete from SP.TJ_CABLES;
--d(CurModelId,CurModelId);

for cable in 
(
    -- выборка по КАБЕЛЯМ    
    select 
    id cableID, MOD_OBJ_NAME cableName, 
    TMPAR(id,'Система').Val.N cableSystemId, -- система КАБЕЛЯ
    TMPAR(id,'№').Val.N       cableNumber
    from MODEL_OBJECTS --V_MODEL_OBJECTS
    where 
        --CATALOG_NAME = 'КАБЕЛЬ'
        OBJ_ID = "TJ.singles.КАБЕЛЬ" 
        and MODEL_ID = CurModelId
        --and PARENT_MOD_OBJ_ID = "КАБЕЛИ"       
)      
LOOP
-- выборка по жилам кабеля
  for cablePin in 
  (
    select 
    id pinID, 
    GETMPAR_N(id,'REF_PIN_FIRST')  pinId1,
    GETMPAR_N(id,'REF_PIN_SECOND') pinId2,
    ROWNUM 
    from V_MODEL_OBJECTS
    where 
        PARENT_MOD_OBJ_id = cable.cableID and 
        CATALOG_NAME = 'ЖИЛА КАБЕЛЯ'
        order by 
        pinId1 nulls last, pinId2 nulls last, ROWNUM           
  )
  loop
  /*
  -- отладочная печать избранныхкабелей
    if cable.cableName = '=03BUB0003BUB00-1001' or 
       cable.cableName = '=03BUB0003BUB00-1002' or
       cable.cableName = '=03BUB0003BUB00-1038' or
       cable.cableName = '=00BFA60BFA60 1001'
    then
       d('Кабель ROWNUM='||cablePin.ROWNUM||'  '||cable.cableName||
         ' cablePin.pinId1 = '||cablePin.pinId1 ||
         ' cablePin.pinId2 = '||cablePin.pinId2,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    */  
    if cablePin.pinId1 is not null then
     --select PARENT_MOD_OBJ_ID into Primary_divaceId1 
     --from SP.V_MODEL_OBJECTS 
     --where id = cablePin.pinId1;
        KPID:= GETMPAR_N(cablePin.pinId1,'PID');
        KID := GETMPAR_N(KPID,'Место');
            if KID is null then
                Primary_divaceId1 := null;
                d('Для левого изделия '||GETMPAR_S(KPID,'NAME')||' id='||KPID||
                  ' не задано место!!!',
                  'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            else
                "Место1" := GETMPAR_S(KID,'NAME');
                Primary_divaceId1 := getdevice("Место1");
                -- у псевдоизделия наличие параметра HP_Primary_divace не гарантировано
                -- mp := TMPAR(Primary_divaceId1,'HP_Primary_divace');  
                -- определим, является ли устройство первичным
                -- ПОКА нет необходимости такой проверки      
            end if;           
    else
          d('Кабель '||cable.cableName||' id='||cable.cableID||
            ' не имеет соединения на левом конце! cablePin.pinId1='||
            cablePin.pinId1,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            "Место1" := null;
            Primary_divaceId1 := null;
    end if;   

   --o('2'); 
    if cablePin.pinId2 is not null then
        KPID:= GETMPAR_N(cablePin.pinId2,'PID');
        KID := GETMPAR_N(KPID,'Место');
        if KID is null then
            Primary_divaceId2 := null;
            d('Для правого изделия '||GETMPAR_S(KPID,'NAME')||' id='||KPID||
              ' не задано место!!!',
              'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
        else
            "Место2" := GETMPAR_S(KID,'NAME');
            Primary_divaceId2 := getdevice("Место2");
        end if;           
    else
            d('Кабель '||cable.cableName||' id='||cable.cableID||
            ' не имеет соединения на правом конце! cablePin.pinId2='||
            cablePin.pinId2,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            "Место2" := null;
            Primary_divaceId2 := null;
    end if;   
-- выходим после первой же иттерации по жилам кабеля
  exit;  --when cablePin.ROWNUM > 1; так не работает!!!
  end loop;
  
-- вставляем в таблицу кабель 
  BEGIN
    insert into "SP"."TJ_CABLES"(CID, CNAME, DEVICE1ID, DEVICE2ID, 
                                DEVICE1, DEVICE2, PLACE1,  PLACE2, 
                                SYSTEMID, "SYSTEM", "№")    
    values (cable.cableID, cable.cableName, 
            Primary_divaceId1, Primary_divaceId2, 
              CASE 
              when Primary_divaceId1 is null then ''
              else GETMPAR_S(Primary_divaceId1,'NAME')
              end,                 
              CASE 
              when Primary_divaceId2 is null then ''
              else GETMPAR_S(Primary_divaceId2,'NAME')
              end,        
              "Место1", "Место2", cable.cableSystemId, 
              CASE 
              when cable.cableSystemId is null then 'Не указана система!'
              else GETMPAR_S(cable.cableSystemId,'NAME')
              end,                 
              cable.cableNumber              
    );
    --rowcount := rowcount + 1;
    --d('rowcount= '|| rowcount,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
  EXCEPTION
    WHEN OTHERS THEN
      d('Кабель id='||cable.cableID||'  Ошибка '||SQLERRM,
      'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
--      o(rowcount||'  '||KID||'Ошибка пакета SP.TJ_MANAGEMENT '||SQLERRM);
  END;
  
END LOOP;      
      
--d('В SP.TJ_CABLES вставлено строк '||rowcount,'OK SP.TJ_MANAGEMENT.updateTJ_CABLES');
--ROLLBACK;
--RAISE;
END updateTJ_CABLES;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- возвращает строку значений избранных параметров изделия 
-- (сргуппированных в строки по оговоренному принципу) 
-- для записи доп.информации об изделии в кабельный журнал
FUNCTION getDeviceParameters(deviceId IN NUMBER) RETURN VARCHAR2
is
tmpid NUMBER;
tvN NUMBER;
s varchar2(3000) := null;
sname varchar2(3000);
"Отметка" varchar2(3000);
begin
 if deviceId is null then return '';
 else 

-- Примечание
  if GETMPAR_S(deviceId, 'Примечание') is not null
  then  s := s ||'\n'||GETMPAR_S(deviceId, 'Примечание'); end if; 
  
-- if GETMPAR_S(deviceId, 'HP_Room_number_and_name') is not null
-- then  s := s || '\n'||GETMPAR_S(deviceId, 'HP_Room_number_and_name'); end if;

-- Отметка
-- приоритет - у числового поля, затем - ссылка
  if GETMPAR_N(deviceId, 'HP_Elevation') is not null
  then  "Отметка" :=  TO_CHAR( GETMPAR_N(deviceId, 'HP_Elevation')/1000, 
                              'Sfm99990.0000'); 
  -- деление на 1000 обусловлено тем, что в E3 координаты задаются в мм
  else 
       if TMPAR(deviceId, 'Отметка').Val.N is not null then
            "Отметка" := GETMPAR_S(GETMPAR_N(deviceId, 'Отметка'), 'NAME'); 
            -- нечисловые отметки отсекаем
            if REGEXP_INSTR("Отметка",'^-?[0-9]*\.?[0-9]*$') = 0 
            then -- имя не соответствует числу
                "Отметка" := null; 
            end if;
       else "Отметка" := null;      
       end if;
  end if;
  if "Отметка" is not null then 
        s := s || '\nОтм. ' ||
        case when SUBSTR("Отметка",1,1) != '+' and SUBSTR("Отметка",1,1) != '-'
        then '+' end            
        || "Отметка";
  end if;
  
-- Помещение
  tmpid := TMPAR(deviceId,'Помещение').Val.N;  
  if tmpid is not null then
    s := s || '\nПом. '||
             TRIM(GETMPAR_S(tmpid, 'NAME')||' '||GETMPAR_S(tmpid,'Наименование')
             ||' '|| TMPAR(deviceId,'Наименование помещения').Val.S);                     
  end if; 
  
-- Система координат
tvN := TMPAR(deviceId, 'Система координат').Val.N;
if tvN is not null
then
  sname := GETMPAR_S(tvN, 'Наименование');
  if sname is not null then 
    s := s ||'\n'||sname; 
  else
    s := s ||'\n'||GETMPAR_S(tvN, 'NAME'); 
  end if;
end if;  
/*
  if TMPAR(deviceId, 'HP_Coordinate_system').Val.S is not null
  then
  s := s ||'\n'||GETMPAR_S(deviceId, 'HP_Coordinate_system'); end if; 
*/  
  RETURN TRIM(s);
  
 end if;
end;

-------------------------------------------------------------------------------- 
-- Универсальный запрос для КЖ данных, загруженных из таблицы связей Excel 
-- или полученных макрой из E3.
-- Во первом случае устройства не имеют клем и пинов, 
-- и соединены друг с другом кабелями непосредственно. Это первичные устройства.
-- Во втором случае первичные устройства в модели E3 могут быть соединены опосредованно, 
-- через терминальные устройства (пины, клемы), которые находятся в местах 
-- первичных устройств (физически - на этих первичных устройствах). Например, 
-- шкаф как первичное устройство порождает (физически - является) одноименное 
-- место, в котором находятся терминальные устройства 
-- (и к которым подходят жиля кабелей). 
-- Одноименность шкафа как места и как устройства понимается в смысле ККС: 
-- префиксы "=" и "+" обозначают роль (место/устройство), в ККС устройства 
-- допустимо удаление начальных нулей.  
-- LengthParamName - имя параметра, из которого берется длина кабеля

FUNCTION get_CableTable(SYSID in NUMBER, LengthParamName VARCHAR2) 
return TJ_TABLE pipelined
is
begin
 for rec in
 (
 select * from
  (
    select  
    CID "ID",
    TMPAR(CID,'№').Val.N "Номер_порядковый", 
    --cname   "Марка",  
    
    -- название системы    
    (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CID,'Система')) "Система",
    
    -- вместо имени выводим значение параметра
    -- GETMPAR_S(CID,'POSITION') "Марка", 
    TMPAR(CID,'POSITION').Val.S "Марка", 
    
    CASE WHEN Device1 is null THEN "Место не задано" ELSE 
     Device1
    END "Откуда",

    CASE WHEN Device1 is null THEN '' ELSE 
     getDeviceParameters(Device1Id)
    END "Откуда_Подробно",

    CASE WHEN Device2 is null THEN "Место не задано" ELSE 
     Device2
    END "Куда",
 
    CASE WHEN Device2 is null THEN '' ELSE 
     getDeviceParameters(Device2Id)
    END "Куда_Подробно",

    GETMPAR_S(CID,'Тип') "Заводская_марка",
    GETMPAR_S(CID,'Число жил и сечение') "Число_жил_и_сечение",
    GETMPAR_N(CID,'Напряжение') Напряжение,
    to_.STR(TMPAR(CID,'Класс цепи').Val)  "Класс_цепи",
    -- длина кабеля, расчитанная как сумма длин участков кабеля
    --GETMPAR_N(CID,'Длина') "Длина", 
    -- длина кабеля, расчитанная скриптом E3
    --CEIL(nvl(TMPAR(CID,'HP_Cable_length').Val.N,0)) "Длина", 
    
    CEIL(nvl(TMPAR(CID,LengthParamName).Val.N,0)) "Длина", 
    
    GETMPAR_N(CID,'покабконстр') "покабконстр",
    GETMPAR_N(CID,'втрубе') "втрубе",
    GETMPAR_N(CID,'влотках') "влотках",
    GETMPAR_N(CID,'вкоробах') "вкоробах",
    GETMPAR_N(CID,'поперфпроф') "поперфпроф",
    GETMPAR_N(CID,'наскобах') "наскобах",
    GETMPAR_N(CID,'покабконстрвысота5м') "покабконстрвысота5м",
    GETMPAR_N(CID,'втрубевысота5м') "втрубевысота5м",
    GETMPAR_N(CID,'влоткахвысота5м') "влоткахвысота5м",
    GETMPAR_N(CID,'вкоробахвысота5м') "вкоробахвысота5м",
    GETMPAR_N(CID,'поперфпрофвысота5м') "поперфпрофвысота5м",
    GETMPAR_N(CID,'наскобахвысота5м') "наскобахвысота5м",
    GETMPAR_N(CID,'натросе') "натросе",
    GETMPAR_N(CID,'вкабканале') "вкабканале",
    GETMPAR_N(CID,'вземле') "вземле"
    from SP.TJ_CABLES 
    where 
-- если задана одна конкретная система
SYSTEMID = SYSID and SYSID > 0 
-- если все системы
or 
 1 =
  CASE
   WHEN SYSID is null THEN 1
   ELSE  0
  END
 or
-- если задан массив систем
 SYSID = 0 and SYSTEMID in 
   (select column_value from table(TJ_MANAGEMENT.get_selectedSystemIds) )
  )
  order by 
  "Номер_порядковый" --сортировка по умолчанию
 )
 loop  
    pipe row(rec);
 end loop;        
end;

-------------------------------------------------------------------------------- 
-- аналогичная функция получения КЖ запросом к объектам, полученным в результате
-- парсинга дампа BRCM
-- для всех систем работы с заданным идентификатором WORK_ID
FUNCTION get_CableTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined
is
begin
for rec in
(
    SELECT 
    CABLE_ID, 
    SP.TMPAR(CABLE_ID, '№').Val.N Номер_порядковый, 
 -- название системы    
   (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CABLE_ID,'Система')) "Система",    
    --SP.TMPAR(CABLE_ID, 'POSITION').Val.S "Марка", 
    CABLE_NAME "Марка", 

    nvl((select  Device1 from SP.TJ_CABLES where CID = CABLE_ID),"Место не задано") "Откуда",
    getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID)) "Откуда_Подробно",
    nvl((select  Device2 from SP.TJ_CABLES where CID = CABLE_ID),"Место не задано") "Куда",
    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) "Куда_Подробно", 
    
    GETMPAR_S(CABLE_ID, 'Тип') "Заводская_марка",
    GETMPAR_S(CABLE_ID, 'Число жил и сечение') "Число_жил_и_сечение",
    GETMPAR_N(CABLE_ID, 'Напряжение') "Напряжение",
    to_.STR(SP.TMPAR(CABLE_ID, 'Класс цепи').Val) "Класс_цепи",
    nvl("ВОЗДУХ",0) + nvl("ТРУБЫ",0) + nvl("ЛОТКИ",0) "Длина",  
--    nvl("ВОЗДУХ",0) "покабконстр", nvl("ТРУБЫ",0) "втрубе", nvl("ЛОТКИ",0) "влотках",
--    nvl("ВОЗДУХ",0) "ВОЗДУХ", nvl("ТРУБЫ",0) "ТРУБЫ", nvl("ЛОТКИ",0) "ЛОТКИ",
    nvl("ВОЗДУХ",0) , nvl("ТРУБЫ",0) , nvl("ЛОТКИ",0) ,
    -- остальные варианты участков в данном случае никогда не встечаются
    0 вкоробах111,0 поперфпроф,0 наскобах,0 покабконстрвысота5м, 
    0 втрубевысота5м,0 влоткахвысота5м,0 вкоробахвысота5м,0 поперфпрофвысота5м,
    0 наскобахвысота5м, 0 натросе,0 вкабканале,0 вземле
    from
    (
    select 
    CABLE_ID, CABLE_NAME, CABLE_CONSTRUCTUIN_TYPENAME, CEIL(sum(LENGTH)) ss
    FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID))
    GROUP BY CABLE_ID, CABLE_NAME, CABLE_CONSTRUCTUIN_TYPENAME
    ORDER BY CABLE_NAME
    )
    pivot 
    (
       sum(ss)
       for CABLE_CONSTRUCTUIN_TYPENAME in 
       ('ВОЗДУХ' as "ВОЗДУХ",'ТРУБЫ' as "ТРУБЫ",'ЛОТКИ' as "ЛОТКИ")
    )
)
 loop  
  pipe row(rec);
  null;
 end loop;        
end;

-------------------------------------------------------------------------------- 
/*
FUNCTION get_CableSUMMTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined
is
begin
for rec in
(
*/

-- показывает, как кабель идет по кабельным конструкциям 
-------------------------------------------------------------------------------- 
FUNCTION get_TrayTableBRCM(WORK_ID in NUMBER) 
return Tray_TABLE pipelined
is
--i int :=0 ;
begin
--d('start get_TrayTableBRCM','get_TrayTableBRCM');
for rec in
(
    SELECT 
--    CABLE_ID "ID", 
    SP.TMPAR(CABLE_ID, '№').Val.N "Номер_порядковый", 
-- название системы    
--   (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CABLE_ID,'Система')) "Система",    
    --SP.TMPAR(CABLE_ID, 'POSITION').Val.S "Марка", 
    CABLE_NAME "Марка", 
    nvl((select  Device1 from SP.TJ_CABLES where CID = CABLE_ID),"Место не задано") ||
    getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID))
    "Откуда",
    --getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID)) "Откуда_Подробно",
    nvl((select  Device2 from SP.TJ_CABLES where CID = CABLE_ID),"Место не задано") ||
    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) 
    "Куда",
--    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) "Куда_Подробно",     
    trays "Маршрут",
    SEGMENT_LENGTH "Длины",
    to_.STR(SP.TMPAR(CABLE_ID, 'Класс цепи').Val) "Класс_цепи",   
    TO_CHAR(GETMPAR_N(CABLE_ID, 'Напряжение')) "Напряжение",   
    GETMPAR_S(CABLE_ID, 'Тип') "Заводская_марка",
    GETMPAR_S(CABLE_ID, 'Число жил и сечение') "Число_жил_и_сечение",
    '' "Резерв",
    LENGTH "Длина",
    0 "Общий_вес",
    0 "Общая_длина"
    from
    (
    SELECT CABLE_ID, CABLE_NAME,      
      LISTAGG(
          (
          -- имя трубы сокращаем, иначе оно огромно
          CASE WHEN INSTR(SEGMENT_NAME,'Tube#') = 1 
          THEN SUBSTR(SEGMENT_NAME,1,INSTR(SEGMENT_NAME,':')-1) 
          ELSE SEGMENT_NAME
          END), '\n') WITHIN GROUP (order by ORDINAL) trays, 
      LISTAGG(CEIL(LENGTH),'\n') WITHIN GROUP (order by ORDINAL) SEGMENT_LENGTH,
      sum(CEIL(LENGTH)) "LENGTH"
    FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID)) 
    GROUP BY CABLE_ID, CABLE_NAME
    ORDER BY CABLE_NAME 
    )
)
 loop  
--  d('i='||i,'get_TrayTableBRCM');
  pipe row(rec);
--  i:=i+1;
 end loop;        
-- d('stop i='||i,'get_TrayTableBRCM');
  EXCEPTION
    WHEN OTHERS THEN
      d('  Ошибка '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.get_TrayTableBRCM'); 
end;


-------------------------------------------------------------------------------- 
FUNCTION get_CableWeight(cablename varchar2) return number
is
begin
if "ХАРАКТЕРИСТИКИ КАБЕЛЯ".EXISTS(cablename)
then return nvl("ХАРАКТЕРИСТИКИ КАБЕЛЯ"(cablename).Weight,0);
else return 0;
end if;
end;

FUNCTION get_CableDiameter(cablename varchar2) return number
is
begin
if "ХАРАКТЕРИСТИКИ КАБЕЛЯ".EXISTS(cablename)
then return nvl("ХАРАКТЕРИСТИКИ КАБЕЛЯ"(cablename).Diameter,0);
else return 0;
end if;
end;

-------------------------------------------------------------------------------- 
-- таблица наполнения лотков/полок лотков кабелями 
-- (какими кабелями заполнены лотки и полки лотка)
FUNCTION get_RouteTableBRCM(WORK_ID in NUMBER) 
return Tray_TABLE pipelined
is
 r Tray_REC;
 i int := 1;
begin
for rec in
(
   with T1 as ( 
             SELECT SEGMENT_NAME, CABLE_NAME, CEIL(LENGTH) leng, ORDINAL, 
                  SP.GETMPAR_S(CABLE_ID,'HP_Cable_type') HP_Cable_type,
                  SP.GETMPAR_N(CABLE_ID,'HP_Number_cable_cores')||'x'||
                     SP.GETMPAR_N(CABLE_ID,'HP_Cable_cross_section') Prop,
                  to_.str(SP.TMPAR(CABLE_ID,'Класс цепи').VAL) "Класс_цепи",
                  GETMPAR_N(CABLE_ID, 'Напряжение') "Напряжение"
                  FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID))
                  where CABLE_CONSTRUCTUIN_TYPENAME = 'ЛОТКИ'
                  
              )                  
                SELECT SEGMENT_NAME,
                  LISTAGG(CABLE_NAME,'\n')  WITHIN GROUP (order by ORDINAL) "Участки", 
                  LISTAGG(leng,'\n')  WITHIN GROUP (order by ORDINAL) "Длины",
-- можно такдже выдавать Класс цепи и Напряжение (для контроля совместимости в одном лотке)
                  LISTAGG("Класс_цепи",'\n')  WITHIN GROUP (order by ORDINAL) "Класс_цепи",
                  LISTAGG("Напряжение", '\n')  WITHIN GROUP (order by ORDINAL) "Напряжение",
-- тип кабеля                  
                  LISTAGG(HP_Cable_type,'\n')  WITHIN GROUP (order by ORDINAL) "Заводская_марка",
                  LISTAGG(Prop,'\n')  WITHIN GROUP (order by ORDINAL) "Число_жил_и_сечение",
-- key                  
                  LISTAGG(get_CableDiameter(HP_Cable_type||' '||Prop),'\n') WITHIN GROUP (order by ORDINAL) "Полное_имя",
-- values
                  sum(leng) "Длина",
                  sum(leng * get_CableWeight(HP_Cable_type||' '||Prop)) "Общий_вес",
                  sum(get_CableDiameter(HP_Cable_type||' '||Prop)) "Сумма_диаметров"                  
                FROM T1
                GROUP BY SEGMENT_NAME
                ORDER BY SEGMENT_NAME
)
 loop  
  r."Номер_порядковый" := i;
  r."Марка" := rec.SEGMENT_NAME;
  r."Маршрут" := rec."Участки";
  r."Длины" := rec."Длины";
  r."Класс_цепи" := rec."Класс_цепи";
  r."Напряжение" := rec."Напряжение";
  r."Заводская_марка" := rec."Заводская_марка";
  r."Число_жил_и_сечение" := rec."Число_жил_и_сечение";
--  r."Резерв" := rec."Полное_имя";
  r."Длина" := rec."Длина";
  r."Общий_вес" := rec."Общий_вес";
  r."Сумма_диаметров" := rec."Сумма_диаметров";
  pipe row(r);
  i := i + 1;
 end loop;        
  EXCEPTION
    WHEN OTHERS THEN
      d('  Ошибка '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.get_RouteTableBRCM'); 
end;

-------------------------------------------------------------------------------- 

/*
-- deprecated procedure variant
-- возвращает ИЗДЕЛИЯ, находящиеся в узле "ИЗДЕЛИЯ",
-- принадлежащие системе и имеющие заданный ИД изображения.
-- Оперирует устаревшей структура модели 
-- (когде ИЗДЕЛИЯ находятся в узле "ИЗДЕЛИЯ")
FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER) 
return Equipment_TABLE pipelined
is
begin
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", ViewId,
"SystemName", SystemId
from
(
select ID, KOD, NAME,
nvl(TMPAR(id,'XYZабс').Val.X,0) x,
nvl(TMPAR(id,'XYZабс').Val.Y,0) y,
nvl(TMPAR(id,'XYZабс').Val.N /*- :ZCorrect* /,0) z,
ViewId,

CASE WHEN ViewId is null THEN 'NULL_ViewId' 
ELSE GETMPAR_S(ViewId,'NAME')
END "View",           

TRIM
( LEADING '+' FROM  
  case when PlaceId is NULL then ''
  else GETMPAR_S(PlaceId,'NAME') 
  end
) "Place",

CASE WHEN SystemId is null THEN 'NULL_SystemId' 
ELSE  TMPAR(SystemId,'NAME').Val.S 
END "SystemName",           
SystemId
from 
   (
    select id, MOD_OBJ_NAME KOD, GETMPAR_S(id,'Примечание') NAME,
    GETMPAR_N(id,'ИД Изображения') ViewId,
    GETMPAR_N(id,'Система') SystemId,
    GETMPAR_N(id,'Место') PlaceId,
    GETMPAR_N(id,'HP_Primary_divace') HP_Primary_divace
    from V_MODEL_OBJECTS 
    where  PARENT_MOD_OBJ_ID = "ИЗДЕЛИЯ" and CATALOG_NAME = 'ИЗДЕЛИЕ'
   )
   where 
   -- только "Primary-изделия" (не пины, не контакты, ...)
   HP_Primary_divace = 1 
   and  
   ViewId = VIEW_ID
   and 
    ( 
     SystemId = SYSID
     or
     1 =
     CASE WHEN SYSID is null THEN 1
      ELSE  0
     END
    )
 )                
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('Ошибка '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '|| 'SYSID='||SYSID||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_Equipment');
    raise;     
end;
*/
-------------------------------------------------------------------------------- 
-- заполняет массив идентификаторами изделий
-- Отдельная кеширующая процедура
-------------------------------------------------------------------------------- 
/*
Такая функция не нужна: по системам не выгружаем
-- возвращает ИЗДЕЛИЯ, находящиеся где угодно (в пределах заданной модели),
-- принадлежащие системе SYSID и имеющие заданный ИД изображения (VIEW_ID).
-- Для генерации перечней оборудования программой ReportGenerator
-- (формирователь транспортных форм для BRCM)
FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER)  
return Equipment_TABLE pipelined
is
id NUMBER;
ids TNUMBERS;
rec Equipment_REC;
selectrdSystemName varchar2(256);
begin
--*********************************************************************************
-- каждый раз заполняем массив id-ов изделий либо всех систем, 
-- либо изделий только заданной системы,
-- при этом отбираем только "Primary-изделия" (не пины, не контакты, ...).
-- 1. id-ы изделий любых систем
if SYSID is null then 
select o.id BULK COLLECT into ids 
from SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S ii
where o.OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
      and o.MODEL_ID = CurModelId
      and pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N = 1
      
      and ii.OBJ_PAR_ID = "ИД Изображения"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID;
      
      --and GETMPAR_N(o.id,'HP_Primary_divace') = 1 
      --and GETMPAR_N(o.id,'ИД Изображения') = VIEW_ID;
      
-- имя системы не задано
selectrdSystemName := null;      
else
-- 2. id-ы изделий, принадлежащих системе с заданным Id = SYSID
select o.id BULK COLLECT into ids from 
SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S ii,
SP.V_MODEL_OBJECT_PAR_S si
where MODEL_ID = CurModelId
      and o.OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"

      and pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N = 1
      
      and ii.OBJ_PAR_ID = "ИД Изображения"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID
      
      and si.OBJ_PAR_ID = "Система"
      and si.MOD_OBJ_ID = o.id 
      and si.N = SYSID;
      
-- запомним имя заданной системы
select MOD_OBJ_NAME into selectrdSystemName from 
SP.V_MODEL_OBJECTS where id = SYSID;
end if; 


--*********************************************************************************
if ids.COUNT =0 then 
d('Нет изделий с изображением '||VIEW_ID,'get_Equipment');
return;
else d('Количество изделий с изображением '||ids.COUNT,'get_Equipment');
end if;

FOR i IN ids.FIRST..ids.LAST
 loop  
    id := ids(i);
    rec.ID := id; 
    
    rec."ViewId" := GETMPAR_N(id,'Место');
    if rec."ViewId" is null then
     rec."Place" := ''; 
    else
     rec."Place" := GETMPAR_S(rec."ViewId",'NAME');
    end if;
    
    rec."KOD" :=  GETMPAR_S(id,'NAME'); 
    rec."NAME":=  GETMPAR_S(id,'Примечание');
    
    rec.X := nvl(TMPAR(id,'XYZабс').Val.X,0);
    rec.Y := nvl(TMPAR(id,'XYZабс').Val.Y,0);
    rec.Z := nvl(TMPAR(id,'XYZабс').Val.N /*- :ZCorrect* /,0);
    rec."Reserve" := 1500;
    
    rec."ViewId" := GETMPAR_N(id,'Система');
    if rec."ViewId" is null then
     rec."View" := 'NULL_ViewId'; 
    else
     rec."View" := GETMPAR_S(rec."ViewId",'NAME');
    end if;
    
    if SYSID is null then 
        rec."SystemId" := GETMPAR_N(id,'Система');
        rec."SystemName" := GETMPAR_S(rec."SystemId",'NAME');
    else
        rec."SystemId"  := SYSID;
        rec."SystemName" := selectrdSystemName;
    end if;    
    
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('Ошибка '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '|| 'SYSID='||SYSID||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_Equipment');
    raise;     
end;
*/
--------------------------------------------------------------------------------
/*
FUNCTION get_AllSystemsEquipment(VIEW_ID in NUMBER) 
return Equipment_TABLE pipelined
is
id NUMBER;
deviceId NUMBER;
rec Equipment_REC;
systemName varchar2(256);
begin
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", ViewId,
"SystemName", SystemId
from
(
select ID, KOD, NAME,
nvl(TMPAR(id,'XYZабс').Val.X,0) x,
nvl(TMPAR(id,'XYZабс').Val.Y,0) y,
nvl(TMPAR(id,'XYZабс').Val.N /*- :ZCorrect* /,0) z,
ViewId,

CASE WHEN ViewId is null THEN 'NULL_ViewId' 
ELSE GETMPAR_S(ViewId,'NAME')
END "View",           

TRIM
( LEADING '+' FROM  
  case when PlaceId is NULL then ''
  else GETMPAR_S(PlaceId,'NAME') 
  end
) "Place",

TMPAR(SystemId,'NAME').Val.S "SystemName",           
SystemId
from 
   (
    select id, MOD_OBJ_NAME KOD, GETMPAR_S(id,'Примечание') NAME,
    GETMPAR_N(id,'ИД Изображения') ViewId,
    GETMPAR_N(id,'Система') SystemId,
    GETMPAR_N(id,'Место') PlaceId,
    GETMPAR_N(id,'HP_Primary_divace') HP_Primary_divace
    from V_MODEL_OBJECTS 
    where -- PARENT_MOD_OBJ_ID = "ИЗДЕЛИЯ" and CATALOG_NAME = 'ИЗДЕЛИЕ'
    OBJ_ID = deviceId and MODEL_ID = CurModelId    
   )
   where 
   -- только "Primary-изделия" (не пины, не контакты, ...)
   HP_Primary_divace = 1 
   and  
   ViewId = VIEW_ID
 )                
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('Ошибка '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_AllSystemsEquipment');
    raise;     
end;
-------------------------------------------------------------------------------- 
*/

-------------------------------------------------------------------------------- 

-- возвращает ИЗДЕЛИЯ, принадлежащие слою и имеющие заданный ИД изображение
FUNCTION get_Equipment(LAYER in VARCHAR, VIEW_ID in NUMBER) return Equipment_TABLE pipelined
is
begin
--d('Выгружаем ИЗДЕЛИЯ id=' || "ИЗДЕЛИЯ",'AZAROV get_Equipment');
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", VIEW_ID,
"Layer", 0
from
  (
    select ID, KOD, NAME,
    nvl(TMPAR(id,'XYZабс').Val.X,0) x,
    nvl(TMPAR(id,'XYZабс').Val.Y,0) y,
    nvl(TMPAR(id,'XYZабс').Val.N /*- :ZCorrect*/,0) z,
    VIEW_ID,
    case when VIEW_ID is null then 'NULL_ViewId' 
    else GETMPAR_S(VIEW_ID,'NAME') end "View", 
    TRIM
    ( LEADING '+' FROM  
      case when PlaceId is NULL then ''
      else GETMPAR_S(PlaceId,'NAME') 
      end
    ) "Place",
    "Layer"
    from
       (
        select o.id, o.MOD_OBJ_NAME KOD, GETMPAR_S(o.id,'Примечание') NAME,
        --GETMPAR_S(id,'HP_Image_layer') "Layer", 
        -- у некоторых отсутствует параметр HP_Image_layer, поэтому TMPAR
        nvl(TMPAR(o.id,'HP_Image_layer').Val.S,'TMP_Layer') "Layer",
        GETMPAR_N(o.id,'Место') PlaceId
        from 
          SP.MODEL_OBJECTS o, 
          SP.MODEL_OBJECT_PAR_S pd, 
          SP.MODEL_OBJECT_PAR_S ii
          where o.OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
          and o.MODEL_ID = CurModelId
          and 
              pd.OBJ_PAR_ID = "HP_Primary_divace"
          and pd.MOD_OBJ_ID = o.id 
          and pd.N=1
          and
              ii.OBJ_PAR_ID = "ИД Изображения"
          and ii.MOD_OBJ_ID = o.id 
          and ii.N = VIEW_ID
       )
       where 
       "Layer" = LAYER
  )     
/*
 select o.id, o.MOD_OBJ_NAME KOD, GETMPAR_S(o.id,'Примечание') NAME,
      ii.N, 
      SP.GETMPAR_S(ii.N,'NAME'), LAYER 
      from 
      SP.MODEL_OBJECTS o, 
      SP.MODEL_OBJECT_PAR_S pd, 
      SP.MODEL_OBJECT_PAR_S ii,
      SP.MODEL_OBJECT_PAR_S la
      where o.OBJ_ID = "TJ.singles.ИЗДЕЛИЕ"
      and o.MODEL_ID = CurModelId
      and 
          pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N=1
      and
          ii.OBJ_PAR_ID = "ИД Изображения"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID
      and
          la.OBJ_PAR_ID = "HP_Image_layer"
      and la.MOD_OBJ_ID = o.id 
      and la.S = LAYER
      order by name
*/                 
            
)
loop  
    pipe row(rec);
 end loop;        
end;
-------------------------------------------------------------------------------- 

-- формирует перечень изделий, 
-- относящихся к заданной идентификаторм системе,
-- с параметрами, требуемыми для кабельного журнала.
-- если идентификатор не задан, то бертся изделия всех систем
FUNCTION get_EquipmentOfSystem(SYSID NUMBER, LengthParamName varchar2) return TJ_TABLE pipelined
is
begin
for rec in
(
select 
cid id,
--nvl(TMPAR(CID,'№').Val.N, RowNum) 
TMPAR(CID,'№').Val.N "Номер_порядковый", 
'' "Система",
cname "Марка",
DEVICE1 "Откуда", 
'' "Откуда_Подробно", 
DEVICE2 "Куда", 
'' "Куда_Подробно",
GETMPAR_S(CID,'Тип') "Заводская_марка",
GETMPAR_S(CID,'Число жил и сечение') "Число_жил_и_сечение",
GETMPAR_N(CID,'Напряжение') "Напряжение",
to_.STR(TMPAR(CID,'Класс цепи').Val)  "Класс_цепи",

-- длина кабеля, расчитанная как сумма длин участков
--GETMPAR_N(CID,'Длина') "Длина", 
-- длина кабеля, расчитанная скриптом E3
--CEIL(nvl(TMPAR(CID,'HP_Cable_length').Val.N,0)) "Длина", 

-- длина кабеля, полученная из параметра :LengthParamName
CEIL(nvl(TMPAR(CID, LengthParamName).Val.N,0)) "Длина", 

GETMPAR_N(CID,'покабконстр') "покабконстр",
GETMPAR_N(CID,'втрубе') "втрубе",
GETMPAR_N(CID,'влотках') "влотках",
GETMPAR_N(CID,'вкоробах') "вкоробах",
GETMPAR_N(CID,'поперфпроф') "поперфпроф",
GETMPAR_N(CID,'наскобах') "наскобах",
GETMPAR_N(CID,'покабконстрвысота5м') "покабконстрвысота5м",
GETMPAR_N(CID,'втрубевысота5м') "втрубевысота5м",
GETMPAR_N(CID,'влоткахвысота5м') "влоткахвысота5м",
GETMPAR_N(CID,'вкоробахвысота5м') "вкоробахвысота5м",
GETMPAR_N(CID,'поперфпрофвысота5м') "поперфпрофвысота5м",
GETMPAR_N(CID,'наскобахвысота5м') "наскобахвысота5м",
GETMPAR_N(CID,'натросе') "натросе",
GETMPAR_N(CID,'вкабканале') "вкабканале",
GETMPAR_N(CID,'вземле') "вземле"
from SP.TJ_CABLES 
where 
-- если выбираются все системы
 1 =
  CASE
   WHEN SYSID is null THEN 1
   ELSE  0
  END 
or 
-- если задана конкретная система
 SYSTEMID = SYSID 
ORDER BY "Номер_порядковый"
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('Ошибка '||SQLERRM||
      'Error SP.TJ_MANAGEMENT.get_EquipmentOfSystem');
    raise;     
end;

-------------------------------------------------------------------------------- 
-- формирует перечень изделий, относящихся к любой из заданных систем 
-- идентификаторы систем находятся в коллекции selectedSystemIds
FUNCTION get_EquipmentOfSystemArray(LengthParamName varchar2) return TJ_TABLE pipelined
is 
begin
if selectedSystemIds.First is null then
  for rec in
  (
   select * from table(get_EquipmentOfSystem(null, LengthParamName))
  )
  LOOP
   pipe row(rec);
  END LOOP; 
else
for indx in selectedSystemIds.FIRST .. selectedSystemIds.LAST
loop 
  for rec in
  (
   select * from table(get_EquipmentOfSystem(selectedSystemIds(indx), LengthParamName))
  )
  LOOP
   pipe row(rec);
  END LOOP;
end loop;  
end if; 
 exception
 when OTHERS then 
  d('Ошибка '||SQLERRM||'Error SP.TJ_MANAGEMENT.get_EquipmentOfSystemArray');
  raise;     
end;

-------------------------------------------------------------------------------- 
--Пытается удалить всех детей объекта ModelObjectPID$, помеченных параметром 
--DELETED. Если попытка удаления очередного объекта-потомка не удаётся, 
--то сообщает об этом в лог и продолжает работу дальше.
--Возвращает количество неудаленных объектов.
Function TryDeleteDeletedObjects(ModelObjectPID$ In Number) 
Return BINARY_INTEGER
Is
  rv# BINARY_INTEGER;  
Begin
  rv#:=0;
  for r In (
    SELECT mo.ID As MOD_OBJ_ID, mo.MOD_OBJ_NAME 
    FROM SP.MODEL_OBJECTS mo
    WHERE mo.PARENT_MOD_OBJ_ID=ModelObjectPID$
    AND EXISTS (SELECT * FROM SP.MODEL_OBJECT_PAR_S mop
                WHERE mop.MOD_OBJ_ID=mo.ID
                AND mop.NAME='DELETED'
                AND mop.N=1
                AND mop.TYPE_ID=5 --Boolean
                )
  )Loop
    Begin
      
      DELETE FROM SP.MODEL_OBJECTS
      WHERE ID=r.MOD_OBJ_ID;
      
    Exception When OTHERS Then
      rv#:=rv#+1;
      D('Ошибка удаления объекта ['||r.MOD_OBJ_NAME||'], ID='
      ||to_char(r.MOD_OBJ_ID)||': '||CHR(13)||CHR(10)||SQLERRM
      ,'ERROR In SP.TJ_MANAGEMENT.TryDeleteDeletedObjects');
    
    End;
  End Loop;
  
  Return rv#;
End TryDeleteDeletedObjects;
--==============================================================================


-- заготовка для функции
FUNCTION get_CableTrack(SYSID in NUMBER) return TJ_TABLE pipelined
is
rec TJ_REC;
begin
 pipe row(rec);
end;
 
BEGIN
 null;
END TJ_MANAGEMENT;


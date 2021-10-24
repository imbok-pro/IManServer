CREATE OR REPLACE PACKAGE BODY SP.MO
-- Models package body
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 27.10.2010
-- update 19.11.2010 23.11.2010 16.12.2010 24.11.2011 09.12.2011 29.12.2011
--        12.01.2012 17.01.2012 30.01.2012
-- by Nikolay Krasilnikov
--        07.02.2012 23.03.2012 26.04.2012 11.04.2012 23.08.2013 26.08.2013
--        29.08.2013 12.09.2013 17.09.2013 16.01.2014 13.02.2014 14.02.2014
--        27.05.2014 14.06.2014 22.06.2014 24.06.2014 03.07.2014 15.07.2014
--        26.10.2014 01.11.2014-04.11.2014 10.11.2014 13.11.2014 15.07.2014
--        25.11.2014 20.02.2015 31.03.2015 01.04.2015 17.05.2015 21.05.2015 
--        25.05.2015 23.06.2015 04.09.2015 21.09.2015 05.11.2015 22.02.2016
--        25.02.2016 05.07.2016 09.08.2016 15.08.2016 18.09.2016 12.10.2016
--        13.10.2016 17.10.2016 27.10.2016 08.11.2016 22.11.2016 01.02.2017
--        22.03.2017 10.04.2017 17.04.2017 18.04.2017 03.05.2017 05.05.2017
--        03.07.2017-04.07.2017 16.11.2017 20.11.2017 22.11.2017 01.12.2017
--        03.12.2017 13.12.2017 18.12.2017 28.12.2017 11.01.2018 16.01.2018
--        27.03.2018 08.05.2018 25.01.2019 04.03.2019 18.05.2019 05.06.2019
--        23.06.2019-24.07.2019 29.07.2019 29.08.2019 10.10.2020 12.10.2020
--        11.11.2020 13.11.2020-14.11.2020 17.11.2020 26.12.2020 18.01.2021
--        31.01.2021 06.02.2021 09.04.2021 12.06.2021 28.06.2021 30.07.2021
--        31.07.2021 01.08.2021 08.09.2021 15.09.2021
AS

-------------------------------------------------------------------------------
FUNCTION FULL_NAME(ModObjID in NUMBER, ModelID out NUMBER) return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
result SP.COMMANDS.COMMENTS%type;
begin
  if (ModObjID = 1) or (ModObjID = -1) then
   return '/'; 
  end if;
  begin
    -- Сначала используем кэш. 
    select MOD_OBJ_PATH, MODEL_ID into tmpVar, ModelID
      from SP.MODEL_OBJECT_PATHS 
        where ID = ModObjID
          and INVALID =0;
    return tmpVar;  
  exception
    when no_data_found then
      begin
        select SYS_CONNECT_BY_PATH(MOD_OBJ_NAME, '/'), MODEL_ID 
          into tmpVar, ModelID
          from SP.MODEL_OBJECTS
          where PARENT_MOD_OBJ_ID is null
          start with ID=ModObjID
          connect by prior PARENT_MOD_OBJ_ID=ID;
        -- Полученный путь выворачиваем наизнанку.
        result:=null;
        for n in (select column_value s from 
                    table (SP.SET_FROM_STRING(tmpVar,'/')))
        loop
          result:=case when result is null then n.s else n.s||'/'||result end;
        end loop;
        return '/'||result;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.MO.Full_Name. '||
            'Не найден узел с ID '||nvl(to_char(ModObjID),'null')||' !');
      end;      
  end;  
end FULL_NAME;
-------------------------------------------------------------------------------
FUNCTION FULL_NAME(ModObjID in NUMBER) return VARCHAR2
is
MODEL_ID NUMBER;
begin
--  D('ModObjID '||ModObjID,'SP.MO.FULL_NAME(ModObjID)');
  if ModObjID is null then return '/'; end if; 
  return FULL_NAME(ModObjID, MODEL_ID);
end FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION FULL_NAME(OID in VARCHAR2, ModelID in NUMBER) 
return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
result SP.COMMANDS.COMMENTS%type;
p_OID VARCHAR2(40);
begin
  p_OID:=OID;
  select SYS_CONNECT_BY_PATH(MOD_OBJ_NAME, '/') into tmpVar
    from SP.MODEL_OBJECTS
    where PARENT_MOD_OBJ_ID is null
      and MODEL_ID = ModelID
    start with OID=p_OID
    connect by prior PARENT_MOD_OBJ_ID=ID;
  -- Полученный путь выворачиваем наизнанку.
  result:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(tmpVar,'/')))
  loop
    result:=case when result is null then n.s else n.s||'/'||result end;
  end loop;
  return '/'||result;
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.MO.FullName. '||
      'Не найден узел с OID '||nvl(OID,'null')||' !');
end FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION FULL_NAME(OID in VARCHAR2)
return VARCHAR2
is
begin
  return FULL_NAME(OID, SP.TG.Cur_MODEL_ID); 
end FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION REL_NAME(ModObjID in NUMBER) return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
result SP.COMMANDS.COMMENTS%type;
modelName SP.MODELS.NAME%type;
mID number;
begin
  if ModObjID is null then return ''; end if;
  case
    when ModObjID <= 1 then 
      begin
        select NAME into modelName from SP.MODELS 
        where ID = - ModObjID
          and (( USING_ROLE is null)
                or (SP.S_isUserAdmin=1)
                or (USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
              );       
        return modelName||'=>/';
      exception
        when no_data_found then 
          RAISE_APPLICATION_ERROR(-20033,'SP.MO.Rel_Name. '||
            'Не найдена модель с ID '||nvl(to_char(ModObjID),'null')||' !');
      end;  
    when ModObjID > 1 then
      tmpVar := FULL_NAME(ModObjID, mID);
		  select NAME into modelName from MODELS where ID = mID;  
		  return modelName||'=>'||tmpVar;
  end case;
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.MO.Rel_Name. '||
      'Не найден объект с ID '||nvl(to_char(ModObjID),'null')||' !');
end REL_NAME;

-------------------------------------------------------------------------------
PROCEDURE S2R(S in VARCHAR2, V in out NOCOPY SP.TVALUE)
is
tmpVar NUMBER;
strings SP.TSTRINGS;
begin
  if V.T != SP.G.TRel then
    raise_application_error(-20033,'SP.MO.S2R. '||
      'Тип значения не "Rel" !');
  end if;
  if (trim(S) is null) or (upper(trim(S)) = 'NULL') then
    V.N:=null;
	  V.S:=null;
    return;
  end if;
  tmpVar:=null;
  if instr(S,'=OID>') = 0 then
    strings := SP.STRINGS_FROM_STRING(S,'=>');
    case
      when strings.count = 2 then
        --D(strings(1)||',  '||strings(2),'SP.MO.S2R');
        begin
          if upper(strings(1)) = 'CURRENT' then
            tmpVar := SP.GET_MODEL_ID;
          else  
            select ID into tmpVAR from SP.MODELS 
            where NAME=strings(1)
          and (( USING_ROLE is null)
                or (SP.S_isUserAdmin=1)
                or (USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
              );       
          end if;
        exception
          when no_data_found then
            raise_application_error(-20033,'SP.MO.S2R. '||
              'Модель '||S||' не найдена!');
        end;    
        --D('MODEL ID '||tmpVar,'SP.MO.S2R');
        -- Если ссылка на корень иерархии, то возвращаем идентификатор модели.
        if strings(2) = '/' then
          V.S := null;
          V.N := -tmpVar;
          return;
        end if;  
        --D('Объект '||strings(2)||'_','SP.MO.S2R');
        V.N := MOD_OBJ_ID_BY_FULL_NAME(tmpVar, strings(2));
        if V.N is null then
          raise_application_error(-20033,'SP.MO.S2R. '||
            'Объект '||S||' не найден!');
        end if; 
      when strings.count = 1 then
        --D('strings(1)'||strings(1)||'_','SP.MO.S2R');
        tmpVar := SP.GET_MODEL_ID;
        if upper(strings(1)) = 'CURRENT' then
          V.S := null;
          V.N := -tmpVar;
          return;
        end if;
        V.N := MOD_OBJ_ID_BY_FULL_NAME(tmpVar, strings(1));
        if V.N is null then
          raise_application_error(-20033,'SP.MO.S2R. '||
            'Объект '||S||' не найден!');
        end if; 
      else
        raise_application_error(-20033,'SP.MO.S2R. '||
          'Неправильно задана ссылка на объект '||S||'!!');
    end case; 
  else   
    strings := SP.STRINGS_FROM_STRING(S,'=OID>');
    case
      when strings.count = 2 then
        --D(strings(1)||',  '||strings(2),'SP.MO.S2R');
        begin
          if upper(strings(1)) = 'CURRENT' then
            tmpVar := SP.GET_MODEL_ID;
          else  
            select ID into tmpVAR from SP.MODELS 
              where NAME=strings(1)
                and (( USING_ROLE is null)
                      or (SP.S_isUserAdmin=1)
                      or (USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
                    );       

          end if;
        exception
          when no_data_found then
            raise_application_error(-20033,'SP.MO.S2R. '||
              'Модель '||S||' не найдена!');
        end;    
        --D('MODEL ID '||tmpVar,'SP.MO.S2R');
        --D('Объект '||strings(2)||'_','SP.MO.S2R');
        V.N := MOD_OBJ_ID_BY_OID(tmpVar, strings(2));
        if V.N is null then
          raise_application_error(-20033,'SP.MO.S2R. '||
            'Объект '||S||' не найден!');
        end if; 
      when strings.count = 1 then
        --D('strings(1)'||strings(1)||'_','SP.MO.S2R');
        V.N := MOD_OBJ_ID_BY_OID(strings(1));
        if V.N is null then
          raise_application_error(-20033,'SP.MO.S2R. '||
            'Объект '||S||' не найден!');
        end if; 
      else
        raise_application_error(-20033,'SP.MO.S2R. '||
          'Неправильно задана ссылка на объект '||S||'!!');
    end case; 
  end if;   
end S2R;

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID_BY_FULL_NAME(
  ModelName in VARCHAR2,
  FullName in VARCHAR2)
return NUMBER
as
tmpVar NUMBER;
begin
  select ID into tmpVar from SP.MODELS 
    where NAME = ModelName
      and (( USING_ROLE is null)
             or (SP.S_isUserAdmin=1)
             or (USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
          );       
  return MOD_OBJ_ID_BY_FULL_NAME(tmpVar, FullName);
exception
  when no_data_found then
     raise_application_error(-20033,'SP.MO.MOD_OBJ_ID_BY_FULL_NAME. '||
                                    'Модель '||FullName||' не найдена!');  
end MOD_OBJ_ID_BY_FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID_BY_FULL_NAME(
  ModelID in NUMBER,
  FullName in VARCHAR2)
return NUMBER
as
Obj NUMBER;
FName VARCHAR2(4000);
begin
  if trim(FullName)='/' then return 1; end if;
  if FullName is null then return null; end if;
  FName := SP.Paths.Name(SP.getROOT_NAME,FullName);
  -- Сначала используем кэш. 
  begin
    select ID into Obj
      from SP.MODEL_OBJECT_PATHS 
      where upper(MOD_OBJ_PATH) = upper(FullName)
      and MODEL_ID=ModelID
      and INVALID =0;
    return Obj;  
  exception
    when no_data_found then
      begin
        select ID into Obj from SP.V_MODEL_OBJECTS
          where upper(FULL_NAME)=upper(FName)
            and MODEL_ID=ModelID;
        return Obj;
      exception
        when others then
          return null;
      end;
  end;        
end MOD_OBJ_ID_BY_FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID_BY_OID(
  ModelID in NUMBER,
  OID in VARCHAR2)
return NUMBER
as
tmpVar NUMBER;
p_OID VARCHAR2(40);
begin
  if OID is null then return null; end if;
  p_OID:=OID;
  select ID into tmpVar from SP.MODEL_OBJECTS
    where OID=p_OID
      and MODEL_ID=ModelID
      and (( USING_ROLE is null)
            or (SP.S_isUserAdmin=1)
            or (USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
          );       
  return tmpVar;
exception
  when others then
    return null;
end MOD_OBJ_ID_BY_OID;

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID_BY_FULL_NAME(FullName in VARCHAR2)
return NUMBER
as
begin
  return MOD_OBJ_ID_BY_FULL_NAME(SP.TG.Cur_MODEL_ID, FullName);
end MOD_OBJ_ID_BY_FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID_BY_OID(OID in VARCHAR2)
return NUMBER
as
begin
  return MOD_OBJ_ID_BY_OID(SP.TG.Cur_MODEL_ID, OID);
end MOD_OBJ_ID_BY_OID;

PROCEDURE NORM_PATH(ModelObject in out SP.G.TMacro_Pars)
as
tmpS VARCHAR2(4000);
begin
  -- Если у параметра есть параметры "ID", то выход.
  if ModelObject.exists('ID') then
    if ModelObject('ID').N is not null then
      return;
    end if;  
  end if;  
  -- Если у параметра нет параметра "NAME", то выход.
  --!! Возможно необходимо выдавать ошибку!
  if not ModelObject.exists('NAME') then
    return;
  end if;  
  -- Вычисляем полный путь.
  if ModelObject.exists('PARENT') then
    tmpS := SP.PATHS.NAME(SP.IM.GET_ROOT_FULL_NAME,ModelObject('PARENT').S);
  else
    tmpS := SP.IM.GET_ROOT_FULL_NAME;
  end if; 
  tmpS:= SP.PATHS.NAME(tmpS,ModelObject('NAME').S);
  -- Переправляем параметры.
  ModelObject('NAME').S := SP.PATHS.SHORTNAME(tmpS);
  if not ModelObject.exists('PARENT') then
    ModelObject('PARENT') := S_(SP.PATHS.PATH(tmpS));
  else
    ModelObject('PARENT').S := SP.PATHS.PATH(tmpS);
  end if;
end NORM_PATH; 

-------------------------------------------------------------------------------
FUNCTION MOD_OBJ_ID(ModelObject in SP.G.TMacro_Pars, ObjectOID out VARCHAR2)
return NUMBER
as
tmpVar NUMBER;
findOID BOOLEAN := false;
s SP.COMMANDS.COMMENTS%type;
tmpPID NUMBER;
begin
  case
    -- Если определён идентификатор объекта.
    when ModelObject.exists('ID') then
      tmpVar:=ModelObject('ID').N;
    -- Если определён сторонний идентификатор объекта, то по нему определяем
    -- идентификатор объекта.
    when ModelObject.exists('OID') then
      ObjectOID:=ModelObject('OID').S;
      if ObjectOID is not null then
        if tmpVar is null then
          tmpVar:=MOD_OBJ_ID_BY_OID(ObjectOID);
        end if;
        findOID:= true;
      end if;
  else
    null;     
  end case;
  -- Не нашли объект, продолжаем искать...
  if tmpVar is null then
    case
      -- Если определён параметр "PID", то ищем по короткому имени.
      when ModelObject.exists('PID') then
        tmpPID:=ModelObject('PID').N;
        if tmpPID is not null then
          if ModelObject.exists('OLD_NAME') then
            s:=SP.PATHS.ShortName(ModelObject('OLD_NAME').S);
          else
            if ModelObject.exists('NAME') then
              s:=SP.PATHS.ShortName(ModelObject('NAME').S);
            else
              RAISE_APPLICATION_ERROR(-20033,'SP.MO.MOD_OBJ_ID.'||
              ' У запрашиваемого объекта отсутствует параметр "NAME"!');
            end if;
          end if;
          --d('tmpPID '||tmpPID||' s '||s,'SP.MO.MOD_OBJ_ID');
          begin
            -- В таблице нет объекта, типа корень иерархии,
            -- заменяем "1" на нулл при поиске.
            if tmpPID = 1 then
              select ID into tmpVar from SP.MODEL_OBJECTS 
                where PARENT_MOD_OBJ_ID is null 
                  and upper(MOD_OBJ_NAME) = upper(s);
            else 
              select ID into tmpVar from SP.MODEL_OBJECTS 
                where PARENT_MOD_OBJ_ID = tmpPID 
                  and upper(MOD_OBJ_NAME) = upper(s);
            end if;
          exception 
            when no_data_found then 
              null; 
          end;
        end if;  
      -- Если определён параметр "POID", то ищем по короткому имени.
      when ModelObject.exists('POID') then    
        if ModelObject('POID').S is not null then
          tmpPID:=MOD_OBJ_ID_BY_OID(ModelObject('POID').S);
          if ModelObject.exists('OLD_NAME') then
            s:=SP.PATHS.ShortName(ModelObject('OLD_NAME').S);
          else
            if ModelObject.exists('NAME') then
              s:=SP.PATHS.ShortName(ModelObject('NAME').S);
            else
              RAISE_APPLICATION_ERROR(-20033,'SP.MO.MOD_OBJ_ID.'||
              ' У обновляемого объекта отсутствует параметр "NAME"!' );
            end if;
          end if;
          --d('tmpPID '||tmpPID||' s '||s,'SP.MO.MOD_OBJ_ID');
          begin
            -- В таблице нет объекта, типа корень иерархии,
            -- заменяем "1" на нулл при поиске.
            if tmpPID = 1 then
              select ID into tmpVar from SP.MODEL_OBJECTS 
                where PARENT_MOD_OBJ_ID is null 
                  and upper(MOD_OBJ_NAME) = upper(s);
            else 
              select ID into tmpVar from SP.MODEL_OBJECTS 
                where PARENT_MOD_OBJ_ID = tmpPID 
                  and upper(MOD_OBJ_NAME) = upper(s);
            end if;
          exception 
            when no_data_found then 
              null; 
          end;
        end if;
    else
      null;     
    end case;
  end if;  
  -- Если объект не найден, то ищем по полному имени
  if tmpVar is null then
    if ModelObject.exists('OLD_NAME') then
      if ModelObject.exists('PARENT') then
	      s := SP.PATHS.NAME(
	                    SP.PATHS.NAME(SP.getROOT_NAME,
	                                  ModelObject('PARENT').S),
	                                  ModelObject('OLD_NAME').S
	                         );
      else
	      s := SP.PATHS.NAME(SP.getROOT_NAME,
      	                   ModelObject('OLD_NAME').S
	                         );
      end if;                     
    elsif not ModelObject.exists('NAME') then
      RAISE_APPLICATION_ERROR(-20033,'SP.MO.MOD_OBJ_ID.'||
        ' У обновляемого объекта отсутствует параметр "NAME"!' );
    elsif not ModelObject.exists('PARENT') then
      s :=  SP.PATHS.NAME(SP.getROOT_NAME,
                          ModelObject('NAME').S);
    else
      s :=  SP.PATHS.NAME(
	                        SP.PATHS.NAME(SP.getROOT_NAME,
	                                      ModelObject('PARENT').S),
	                        ModelObject('NAME').S
	                        );
    end if;
    tmpVar:=MOD_OBJ_ID_BY_FULL_NAME(s);
    --d(s||'=>'||tmpVar,'SP.MO.MOD_OBJ_ID');
  end if;
  -- Если необходимо и возможно(OID не найден, найден ID и он не корень),
  -- то ищем OID.
  if not findOID and not (tmpVar is null) and (tmpVar != 1) then
    select OID into ObjectOID from SP.MODEL_OBJECTS
      where ID = tmpVar;
  end if;
  return tmpVar;
exception
  when others then
  d(SQLERRM,' ERROR IN SP.MO.MOD_OBJ_ID');
  raise;  
end MOD_OBJ_ID;

-------------------------------------------------------------------------------
FUNCTION PARENT_OBJ_ID(ModelObject in SP.G.TMacro_Pars,
                       ObjectPath out VARCHAR2,
                       NewParent in BOOLEAN default false)
return NUMBER
as
tmpParent NUMBER;
begin
  if NewParent then
    -- Находим родительский объект, по значению параметра "NEW_PID".
    if ModelObject.exists('NEW_PID') then
      tmpParent:=ModelObject('NEW_PID').N;
      ObjectPath:=null;
      --d('NEW_PID '||tmpParent,'PARENT_OBJ_ID');
      if tmpParent is null then
        RAISE_APPLICATION_ERROR(-20033,'SP.MO.PARENT_OBJ_ID.'||
        ' У переименуемого объекта параметр "NEW_PID" равен null!');
      end if;
	    return tmpParent;
	  end if;
    -- Находим родительский объект, по значению параметра "NEW_POID".
    if ModelObject.exists('NEW_POID') then
      tmpParent:=MOD_OBJ_ID_BY_OID(SP.VAL_TO_STR(ModelObject('NEW_POID')));
      ObjectPath:=null;
      --d('tmpParent '||tmpParent,'PARENT_OBJ_ID');
      -- Если нашли родителя, то возвращаем его,
      -- иначе используем символьное значение пути.
	    if tmpParent is not null then
	      return tmpParent;
	    end if;
	  end if;  
    if ModelObject.exists('NEW_PARENT') then
      ObjectPath:= SP.PATHS.NAME(SP.getROOT_NAME,
                                 SP.VAL_TO_STR(ModelObject('NEW_PARENT')));
      tmpParent:= MOD_OBJ_ID_BY_FULL_NAME(ObjectPath);
      -- Если объект найден, то присваиваем пути "НУЛЛ".
      if tmpParent is not null then 
        ObjectPath:= null; 
      end if;
    else
      RAISE_APPLICATION_ERROR(-20033,'SP.MO.PARENT_OBJ_ID.'||
        ' У переименуемого объекта отсутствует параметры "NEW_PARENT",'||
        ' NEW_PID и NEW_POID!' );
    end if;
    return tmpParent;
  end if;
  -- Находим родительский объект, по значению параметра "PID".
  if ModelObject.exists('PID') then
    tmpParent:=ModelObject('PID').N;
    ObjectPath:=null;
    --d('PID '||tmpParent,'PARENT_OBJ_ID');
    if tmpParent is not null then
      return tmpParent;
    end if;
  end if;
  -- Находим родительский объект, по значению параметра "POID".
  if ModelObject.exists('POID') then
    if ModelObject('POID').S is not null then
      tmpParent:=MOD_OBJ_ID_BY_OID(ModelObject('POID').S);
      --d('tmpParent '||tmpParent,'PARENT_OBJ_ID');
      --d('POID '||SP.VAL_TO_STR(ModelObject('POID')),'PARENT_OBJ_ID');
      ObjectPath:=null;
      -- Если нашли родителя, то возвращаем его,
      -- иначе используем символьное значение пути.
      if tmpParent is not null then
        return tmpParent;
      end if;
    end if;
  end if;
  if not ModelObject.exists('NAME') then
    RAISE_APPLICATION_ERROR(-20033,'SP.MO.PARENT_OBJ_ID.'||
      ' У обновляемого объекта отсутствует параметр "NAME"!' );
  end if;  
  -- Вычисляем полный путь.
  if ModelObject.exists('PARENT') then
    ObjectPath := SP.PATHS.NAME(SP.IM.GET_ROOT_FULL_NAME, 
                                ModelObject('PARENT').S);
  else
    ObjectPath := SP.IM.GET_ROOT_FULL_NAME;
  end if;
  -- Отрезаем короткое имя от полного имени объекта. 
  ObjectPath:= SP.PATHS.PATH(SP.PATHS.NAME(ObjectPath,
                                           ModelObject('NAME').S));
                             
  tmpParent:= MOD_OBJ_ID_BY_FULL_NAME(ObjectPath);
  if tmpParent is not null then 
    ObjectPath:= null; 
  end if;
  return tmpParent;
end PARENT_OBJ_ID;

-------------------------------------------------------------------------------
PROCEDURE UPDATE_OBJECT_PARS(ModelObject in SP.G.TMacro_Pars,
                             ModelObjectID in NUMBER default null)
is
MP SP.TMPAR;
PName SP.COMMANDS.COMMENTS%type;
MObjectID NUMBER;
MOid SP.MODEL_OBJECTS.OID%type;
EM# VARCHAR2(4000);
begin
  -- Сбрасываем признак обновления OID, который был возможно установлен в 
  -- Функции MERGE
  SP.TG.ForceOID := false;
  --d('ModelObjectID '||ModelObjectID,'UPDATE_OBJECT_PARS');
  if ModelObjectID is null then
    MObjectID := MOD_OBJ_ID(ModelObject, MOid);
  else
    MObjectID := ModelObjectID;
  end if;
  C.addObject(MObjectID,'MO.UPDATE_OBJECT_PARS');
  -- Если присутствует параметр "DELETE" и его знчение true,
  -- то удаляем параметры или переопределённые значеня, отсутствующие
  -- во входном массиве.
  if ModelObject.exists('DELETE') then
    if ModelObject('DELETE').asBoolean then
      for par in 
      (
        select * from SP.MOD_OBJ_PARS_CACHE 
          where SET_KEY = 'MO.UPDATE_OBJECT_PARS'
            and ID is not null
      )
      loop
        if not ModelObject.exists(par.NAME) then 
          delete from SP.MODEL_OBJECT_PAR_S where ID = par.ID;
        end if;  
      end loop;
    end if;
  end if;
  -- Для всех параметров входного массива, кроме "NAME", "OLD_NAME", "PARENT",
  -- "NEW_PARENT", "OID", "POID", "NEW_POID", "ID", "PID", "NEW_PID", "DELETE"
  -- "FORCE_OID".
  -- Вышеприведенные параметры соответствуют положению объекта в дереве 
  -- объектов модели и изменяются другими механизмами (команды Rename 
  --  и ChangeParent) или являются неизменными уникальными идентификаторами.
  PName :=ModelObject.First;
  while PName is not null
  loop
--    d('параметр '||PNAME,'UPDATE_OBJECT_PARS');
    case 
      when upper(trim(PName)) 
        in ('NAME', 'OLD_NAME', 'PARENT', 'NEW_PARENT',
            'OID', 'POID', 'NEW_POID', 'ID', 'PID', 'NEW_PID',
            'DELETE', 'FORCE_OID') then 
            null;
      when upper(trim(PName)) = 'USING_ROLE' then 
        update SP.MODEL_OBJECTS set
          USING_ROLE = ModelObject(PName).N,
          M_DATE = null,
          M_USER = null
          where ID = MObjectID;
      when upper(trim(PName)) = 'EDIT_ROLE' then 
        update SP.MODEL_OBJECTS set
          EDIT_ROLE = ModelObject(PName).N,
          M_DATE = null,
          M_USER = null
          where ID = MObjectID;
    else
      MP:=C.getMPAR(PName, MObjectID, 'MO.UPDATE_OBJECT_PARS');
      -- Если значение параметра обновлено, то обновляем в базе.
--      d('MObjectID '||MObjectID||to_.str()||
--        'PName '||PName||to_.str()||
--        ' e '||ModelObject(PName).e||to_.str()||
--        ' n '||ModelObject(PName).N||to_.str()||
--        ' d '||ModelObject(PName).d||to_.str()||
--        ' s '||ModelObject(PName).s||to_.str()||
--        ' x '||ModelObject(PName).x||to_.str()||
--        ' y '||ModelObject(PName).y||to_.str()||
--        to_.str()||
--        ' e '||MP.VAL.e||to_.str()||
--        ' n '||MP.VAL.n||to_.str()||
--        ' d '||MP.VAL.d||to_.str()||
--        ' s '||MP.VAL.s||to_.str()||
--        ' x '||MP.VAL.x||to_.str()||
--        ' y '||MP.VAL.y||to_.str()
--      
--      ,'UPDATE_OBJECT_PARS');
        begin
          MP.save(ModelObject(PName));
        exception 
          when others then
            EM#:='ERROR in SP.TMPAR.save. Name ['
            ||PName||'], val ['||TO_.STR(MP.VAL)
            ||'].  '||SQLERRM;
            d(EM#,' ERROR in SP.MO.UPDATE_OBJECT_PARS');
            RAISE_APPLICATION_ERROR(-20033,EM#); 
        end;
    end case;
    PName:=ModelObject.next(PName);
  end loop;
end UPDATE_OBJECT_PARS;

-------------------------------------------------------------------------------
FUNCTION MERGE_OBJECT(ModelObject in SP.G.TMacro_Pars, CatalogID in NUMBER)
return NUMBER
as
tmpVar NUMBER;
tmpParent NUMBER;
tmpPath SP.COMMANDS.COMMENTS%type;
ShortName SP.MODEL_OBJECTS.MOD_OBJ_NAME%type;
ObjectOID VARCHAR2(40);
ObjectPOID VARCHAR2(40);
Parent_Found boolean;
tmpID NUMBER;
EM VARCHAR2(4000);
begin
  -- Если есть ID, то уходим на обновление объекта
  if ModelObject.exists('ID') then
    tmpVar := ModelObject('ID').N;
    if tmpVar is not null then
      tmpVar := UPDATE_OBJECT(ModelObject => ModelObject,
                              CatalogID => CatalogID,
                              ModelObjectID => tmpVar);
      if tmpVar is null then
        RAISE_APPLICATION_ERROR(-20033,'SP.MO.MERGE_OBJECT.'||
        ' Задан недействительный параметр ID ' || ModelObject('ID').N );
      else
        return tmpVar;
      end if;  
    end if;
  end if;  
  -- Находим родительский объект.
  tmpParent:= PARENT_OBJ_ID(ModelObject, tmpPath);
  Parent_Found := tmpParent is not null;
  -- Если родитель - корень иерархии, то присваиваем ему значение нулл,
  -- указывающее, что объект расположен в корне дерева объектов.
  if tmpParent = 1 then
    tmpParent := null;
  end if;
  -- находим Имя
  if not ModelObject.exists('NAME') then
    RAISE_APPLICATION_ERROR(-20033,'SP.MO.MERGE_OBJECT.'||
      ' У обновляемого объекта отсутствует параметр "NAME"!' );
  end if;
  ShortName:= SP.Paths.ShortName(ModelObject('NAME').S);
  if ModelObject.exists('OID') then
    ObjectOid := ModelObject('OID').S;
  end if;
  -- Если нашли идентификатор родительского объекта,
  -- то предполагаем, что объект новый.
  if Parent_Found then
    -- Пытаемся вставить объект.
    begin
      insert into SP.MODEL_OBJECTS
        values (null,
                SP.TG.Cur_MODEL_ID,
                ShortName,
                ObjectOid,
                CatalogID,
                tmpParent,
                null,
                null,
                null,
                null,
                0
                )
        returning ID into tmpVar;
      -- Обновляем параметры объекта.
      UPDATE_OBJECT_PARS(ModelObject,tmpVar);
      return tmpVar;
    exception
      -- а если это не получилось, то ищем и обновляем.
      when others then 
--        d('Объект не добавлен, ищем и обновляем. '||SQLERRM,'MERGE_OBJECT');
        EM := SQLERRM;
    end;
  else 
    if ModelObject.exists('POID') then
      ObjectPOID := ModelObject('POID').S;
    end if;
    if ObjectPOID is not null then
      insert into SP.V_MODEL_OBJECTS
        (
         MODEL_ID,
         MOD_OBJ_NAME,
         OID,
         POID,
         OBJ_ID,
         PATH
        )
      values
        (
        SP.TG.Cur_MODEL_ID,
        ShortName,
        ObjectOid,
        ObjectPOID,
        CatalogID,
        tmpPath
        );
    else
      insert into SP.V_MODEL_OBJECTS
        (
         MODEL_ID,
         MOD_OBJ_NAME,
         OID,
         OBJ_ID,
         PATH
        )
      values
        (
        SP.TG.Cur_MODEL_ID,
        ShortName,
        ObjectOid,
        CatalogID,
        tmpPath
        );
    end if;    
    -- Returning здесь не работает.
    tmpVar:=MOD_OBJ_ID_BY_FULL_NAME(SP.PATHS.NAME(tmpPath,ShortName));
    -- Обновляем параметры объекта.
    UPDATE_OBJECT_PARS(ModelObject,tmpVar);
    return tmpVar;
  end if;
  -- Находим объект.
  tmpVar:=MOD_OBJ_ID(ModelObject, ObjectOid);
  --d('tmpParent:'||nvl(to_char(tmpParent), 'null')||
  --  '; tmpPath:"'||nvl(tmpPath, 'null')||
  --  '"; tmpVar(объект)'||nvl(to_char(tmpVar), 'null'),'SP.MO.MERGE_OBJECT');
  -- Если не нашли объект, то ошибка.
  if tmpVar is  null then
    RAISE_APPLICATION_ERROR(-20033,'ERROR in SP.MO.MERGE_OBJECT. '||
      'Объект не добавлен и не найден => MODEL_ID = '||to_char(SP.TG.Cur_MODEL_ID)
      ||', MOD_OBJ_NAME ['||ShortName||'], OID ['||ObjectOid||'], OBJ_ID='
      ||to_char(CatalogID)||', PARENT_MOD_OBJ_ID = '||to_char(tmpParent)
      ||' PARENT '||tmpPath ||' EM '|| EM);
  end if;
  tmpVar := UPDATE_OBJECT(ModelObject => ModelObject,
                          CatalogID => CatalogID,
                          ModelObjectID => tmpVar);
  if tmpVar is  null then
    RAISE_APPLICATION_ERROR(-20033,'ERROR in SP.MO.MERGE_OBJECT. '||
      'update Failed => MODEL_ID = '||to_char(SP.TG.Cur_MODEL_ID)
      ||', MOD_OBJ_NAME ['||ShortName||'], OID ['||ObjectOid||'], OBJ_ID='
      ||to_char(CatalogID)||', PARENT_MOD_OBJ_ID = '||to_char(tmpParent)
      ||' PARENT '||tmpPath ||' EM '|| EM);
  end if;
  return tmpVar;
end MERGE_OBJECT;

-------------------------------------------------------------------------------
FUNCTION UPDATE_OBJECT(ModelObject in SP.G.TMacro_Pars,CatalogID in NUMBER,
                       ModelObjectID in NUMBER default null)
return NUMBER
is
tmpVar NUMBER;
tmpParent NUMBER;
tmpPath SP.COMMANDS.COMMENTS%type;
ObjectOID VARCHAR2(40);
ObjectPOID VARCHAR2(40);
--ShortName SP.MODEL_OBJECTS.MOD_OBJ_NAME%type;
begin
--d('START','UPDATE_OBJECT');
  tmpVar:=ModelObjectID;
  if tmpVar is null then
    if ModelObject.exists('ID') then
      tmpVar := ModelObject('ID').N;
    end if;
  end if;
  if ModelObject.exists('FORCE_OID') then
    if ModelObject('FORCE_OID').N = 1 then
      SP.TG.ForceOID := true;
    end if;  
  end if;
  if tmpVar is null then
    -- Находим сам объект.
    tmpVar:=MOD_OBJ_ID(ModelObject, ObjectOid);
  end if;
  if tmpVar is null then
    return null;
  end if;
  -- Проверяем и если необходимо, то изменяем класс объекта.
  CHANGE_OBJECT_CLASS(tmpVar, CatalogID);
  -- Обновляем объект. 
  update SP.MODEL_OBJECTS set
    OID = ObjectOid,
    OBJ_ID = CatalogID,
    M_DATE = null,
    M_USER = null
    where ID=tmpVar;
  -- Обновляем параметры объекта.
  UPDATE_OBJECT_PARS(ModelObject,tmpVar);
  return tmpVar;
end UPDATE_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE UPDATE_NOTES(ModelObject in SP.G.TMACRO_PARS)
is
MP SP.TMPAR;
PName SP.COMMANDS.COMMENTS%type;
tmpVar NUMBER;
ObjectOID VARCHAR2(40);
begin
  tmpVar:= MOD_OBJ_ID(ModelObject, ObjectOID);
  -- Если не нашли объект, то выход.
  if tmpVar is null then return; end if;
  -- Если необходимо, то удаляем все комментарии.
  if ModelObject.exists('DELETE') then
    if ModelObject('DELETE').asBoolean then
      delete from SP.MODEL_OBJECT_PAR_S
        where TYPE_ID = G.TNOTE and MOD_OBJ_ID=tmpVar;
    end if;
  end if;
  -- Для всех параметров входного массива типа "Note".
  PName :=ModelObject.First;
  while PName is not null
  loop
    --d('параметр '||p.PARAM_NAME,'UPDATE_NOTES');
    if ModelObject(PName).T = G.TNOTE then
      MP:=TMPAR(tmpVar,PName);
      -- Если значение параметра обновлено, то обновляем в базе.
      if not G.EQ(ModelObject,PName,MP.VAL) then
        MP.VAL:=ModelObject(PName);
        MP.save;
      end if;
    end if;
    PName:=ModelObject.next(PName);
  end loop;
end UPDATE_NOTES;

-------------------------------------------------------------------------------
PROCEDURE RENAME_OBJECT_BY_OLD_NAME(OldFullName in VARCHAR2,
                                    FinalFullName in VARCHAR2)
is
tmpVar NUMBER;
begin
  tmpVar:= MOD_OBJ_ID_BY_FULL_NAME(OldFullName);
  if tmpVar is null or tmpVar = 1 then return; end if;
  update SP.V_MODEL_OBJECTS set
    FULL_NAME = FinalFullName,
    M_DATE = null,
    M_USER = null
    where ID = tmpVar;
end RENAME_OBJECT_BY_OLD_NAME;

-------------------------------------------------------------------------------
PROCEDURE RENAME_OBJECT_BY_OID(OID in VARCHAR2, ShortName in VARCHAR2)
is
p_OID VARCHAR2(40);
begin
  update SP.MODEL_OBJECTS set
    MOD_OBJ_NAME = ShortName,
    M_DATE = null,
    M_USER = null
    where OID = p_OID
      and MODEL_ID = SP.TG.Cur_MODEL_ID;
end RENAME_OBJECT_BY_OID;

-------------------------------------------------------------------------------
PROCEDURE RENAME_OBJECT(ModelObject in SP.G.TMACRO_PARS)
is
tmpVar NUMBER;
p_OID VARCHAR2(40);
begin
  tmpVar:= MOD_OBJ_ID(ModelObject, p_OID);
  if tmpVar is null or tmpVar = 1 then return; end if;
  if not ModelObject.exists('NEW_NAME') then
    RAISE_APPLICATION_ERROR(-20033,'SP.MO.RENAME_OBJECT.'||
      ' У изменяемого объекта отсутствует параметр "NEW_NAME"!' );
  end if;
  update SP.MODEL_OBJECTS set
    MOD_OBJ_NAME = ModelObject('NEW_NAME').S,
    M_DATE = null,
    M_USER = null
    where ID = tmpVar;
end RENAME_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE CHANGE_PARENT(OID in VARCHAR2, POID in VARCHAR2)
is
p_OID VARCHAR2(40);
tmpVar NUMBER;
begin
  p_OID := OID;
  tmpVar := MOD_OBJ_ID_BY_OID(POID);
  if tmpVar is null or tmpVar = 1 then return; end if;
  update SP.MODEL_OBJECTS set
    PARENT_MOD_OBJ_ID = tmpVar,
    M_DATE = null,
    M_USER = null
    where OID = p_OID
      and MODEL_ID = SP.TG.Cur_MODEL_ID;
end CHANGE_PARENT;

-------------------------------------------------------------------------------
PROCEDURE CHANGE_PARENT(ModelObject in SP.G.TMACRO_PARS)
is
tmpVar NUMBER;
tmpParent NUMBER;
tmpPath SP.COMMANDS.COMMENTS%type;
ObjectOID VARCHAR2(40);
begin
  -- Находим родительский объект.
  tmpParent:= PARENT_OBJ_ID(ModelObject, tmpPath, true);
  -- Находим объект.
  tmpVar:=MOD_OBJ_ID(ModelObject, ObjectOid);
  -- Если не нашли объект, то выход.
  if tmpVar is null then return; end if;
  -- Eсли есть родитель, то напрямую, иначе через представление.
  if tmpParent is not null or tmpPath is null then
    update SP.MODEL_OBJECTS set
      PARENT_MOD_OBJ_ID = tmpParent,
      M_DATE = null,
      M_USER = null
    where ID=tmpVar;
  else
    update SP.V_MODEL_OBJECTS set
      PATH = tmpPath,
      M_DATE = null,
      M_USER = null
    where ID=tmpVar;
  end if;
end CHANGE_PARENT;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECT_BY_NAME(FullName in VARCHAR2)
is
tmpVar NUMBER;
begin
  tmpVar := MOD_OBJ_ID_BY_FULL_NAME(FullName);
  delete from SP.MODEL_OBJECTS where ID=tmpVar;
end DELETE_OBJECT_BY_NAME;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECT_BY_OID(OID in VARCHAR2)
is
p_OID VARCHAR2(40);
begin
  p_OID := OID;
  delete from SP.MODEL_OBJECTS 
    where OID = p_OID 
      and MODEL_ID = SP.TG.Cur_MODEL_ID;
end DELETE_OBJECT_BY_OID;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECT(ModelObject in SP.G.TMACRO_PARS)
is
tmpVar NUMBER;
tmp NUMBER;
p_OID VARCHAR2(40);
begin
  tmpVar:= MOD_OBJ_ID(ModelObject, p_OID);
  delete from SP.MODEL_OBJECTS 
    where ID=tmpVar 
       and MODEL_ID = SP.TG.Cur_MODEL_ID;
exception
  when others then 
    SP.IM.EM := 'Ошибка удаления объекта '|| SQLERRM;  
end DELETE_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECTS(FullNames in SP.G.TNAMES)
is
S SP.TSTRINGS;
begin
  S:=SP.STRINGS_FROM_NAMES(FullNames);
  DELETE_OBJECTS(S);
end DELETE_OBJECTS;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECTS(FullNames in SP.TSTRINGS)
is
begin
  for n in (select * from table(FullNames))
  loop
    DELETE_OBJECT_BY_NAME(n.column_value);
  end loop;
end DELETE_OBJECTS;

-------------------------------------------------------------------------------
PROCEDURE DELETE_OBJECTS(OIDs in SP.TSHORTSTRINGS)
is
begin
  for n in (select * from table(OIDs))
  loop
    DELETE_OBJECT_BY_OID(n.column_value);
  end loop;
end DELETE_OBJECTS;

-------------------------------------------------------------------------------
FUNCTION CUR_MODEL_OBJECTS(withRoot in NUMBER default 1) 
return SP.TMODEL_OBJECTS pipelined
is
o SP.TMODEL_OBJECT_RECORD;
ro SP.MODEL_OBJECTS%rowtype;
rootName VARCHAR2(4000);
with_Root boolean;
begin
  with_Root :=  withRoot != 0;
  rootName :='';
  -- Создаем объект и заносим в него значения параметров текущего опорного
  -- объекта.
	o := SP.TMODEL_OBJECT_RECORD
       (null,null,null,null,null,null,null,null,null,null,null,null,null);
	o.ID := SP.M.ROOT('ID').N;
	o.MODEL_ID := SP.TG.Get_CurModel();
	o.MOD_OBJ_NAME := SP.M.ROOT('NAME').S;
	o.OID := SP.M.ROOT('OID').S;
	o.OBJ_ID := 2;
	o.PARENT_MOD_OBJ_ID := SP.M.ROOT('PID').N;
	o.COMPOSIT_ID := null; 
	o.START_COMPOSIT_ID := null;
	o.MODIFIED := 0;
	o.M_DATE := null;
	o.M_USER := null;
	o.OBJ_LEVEL := 0;
  o.FULL_NAME := FULL_NAME(o.ID);
  -- Если опорный объект находится за пределами внутренней модели,
  -- то возвращаем только этот объект.
  -- Ничего не возвращаем, если входной параметр функции - false.
  if SP.M.ROOT('ID').N = -1 then
    if with_Root then
      pipe row(o);
    end if;
    return;
  end if;
  -- Если опорный объект есть корень иерархии.   
  if SP.M.ROOT('ID').N = 1 then
    if with_Root then
      pipe row(o);
    end if;
    for os in (
               with mod_objects as
               (select * from SP.MODEL_OBJECTS m
                  where (m.MODEL_ID = SP.TG.Get_CurModel())
                    and ((m.USING_ROLE is null)
                         or (SP.S_isUserAdmin = 1)
                         or (m.USING_ROLE in 
                                            (select ROLE_ID from SP.USER_ROLES))
                         )
                )

               select level OBJ_LEVEL,
                       SYS_CONNECT_BY_PATH(m.MOD_OBJ_NAME, '/') FULL_NAME,
                       m.*  
               from mod_objects m
                 start with PARENT_MOD_OBJ_ID is null
                 connect by  PARENT_MOD_OBJ_ID = prior ID
                 order siblings by MOD_OBJ_NAME
               )
    loop
			o.ID := os.ID;
			o.MODEL_ID := os.MODEL_ID;
			o.MOD_OBJ_NAME := os.MOD_OBJ_NAME;
			o.OID := os.OID;
			o.OBJ_ID := os.OBJ_ID;
			o.PARENT_MOD_OBJ_ID := nvl(os.PARENT_MOD_OBJ_ID,1);
			o.M_DATE := os.M_DATE;
			o.M_USER := os.M_USER;
			o.OBJ_LEVEL := os.OBJ_LEVEL;
      o.FULL_NAME := os.FULL_NAME;
      pipe row(o);
    end loop;           
  else
    select * into ro from SP.MODEL_OBJECTS m
      where m.MODEL_ID = SP.TG.Get_CurModel()
        and ID = SP.GetRoot_ID();
    o.ID := ro.ID;
    o.MODEL_ID := ro.MODEL_ID;
    o.MOD_OBJ_NAME := ro.MOD_OBJ_NAME;
    o.OID := ro.OID;
    o.OBJ_ID := ro.OBJ_ID;
    o.PARENT_MOD_OBJ_ID := nvl(ro.PARENT_MOD_OBJ_ID,1);
    o.M_DATE := ro.M_DATE;
    o.M_USER := ro.M_USER;
    o.OBJ_LEVEL := 0;
    o.FULL_NAME := FULL_NAME(o.ID);
    rootName := o.FULL_NAME;
    if with_Root then
      pipe row(o);
    end if;
    for os in (
               with mod_objects as
               (select * from SP.MODEL_OBJECTS m
                  where (m.MODEL_ID = SP.TG.Get_CurModel())
                    and ((m.USING_ROLE is null)
                         or (SP.S_isUserAdmin = 1)
                         or (m.USING_ROLE in 
                                            (select ROLE_ID from SP.USER_ROLES))
                         )
                )
   
               select level OBJ_LEVEL,
                       SYS_CONNECT_BY_PATH(m.MOD_OBJ_NAME, '/') FULL_NAME,
                       m.*  
               from mod_objects m
                 start with PARENT_MOD_OBJ_ID = SP.GetRoot_ID
                 connect by  PARENT_MOD_OBJ_ID = prior ID
                 order siblings by MOD_OBJ_NAME
               )
    loop
			o.ID := os.ID;
			o.MODEL_ID := os.MODEL_ID;
			o.MOD_OBJ_NAME := os.MOD_OBJ_NAME;
			o.OID := os.OID;
			o.OBJ_ID := os.OBJ_ID;
			o.PARENT_MOD_OBJ_ID := os.PARENT_MOD_OBJ_ID;
			o.M_DATE := os.M_DATE;
			o.M_USER := os.M_USER;
			o.OBJ_LEVEL := os.OBJ_LEVEL;
      o.FULL_NAME := rootName||os.FULL_NAME;
      pipe row(o);
    end loop;           
  end if;
  return;
exception
  when no_data_needed then 
    null;
  when others then
  d(SQLERRM,'ERROR IN SP.MO.CUR_MODEL_OBJECTS');
  d('BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
    'ERROR IN SP.MO.CUR_MODEL_OBJECTS');
end CUR_MODEL_OBJECTS;

-------------------------------------------------------------------------------
FUNCTION REL_S return SP.TS_VALUES_COMMENTS pipelined
is 
s SP.TS_VALUE_COMMENTS;
modelName SP.MODELS.NAME%type;
modelID NUMBER;
tmpVar NUMBER;
parentID NUMBER;
parentName SP.COMMANDS.COMMENTS%type;
currentName SP.COMMANDS.COMMENTS%type;
begin
  s :=SP.TS_VALUE_COMMENTS(null,null,null);
  -- Если объект не определён, то предоставляем перечень моделей.
  if SP.TG.CurValue.N is null then
    s.S_VALUE :='CURRENT=>/';
    pipe row (s);
	  for n in (select NAME, COMMENTS from SP.MODELS
                where SP.S_HasUserRoleID(USING_ROLE) = 1
                order by NAME)
	  loop
	    s.S_VALUE :=n.NAME||'=>/';
      s.COMMENTS := n.COMMENTS;
	    pipe row(s);
	  end loop;
	  return;
  end if;
  case
    -- Если узел меньше или равен корню,
    -- то предоставляем список объектов верхнего уровня.
    when SP.TG.CurValue.N <= 1 then
      s.S_VALUE :='null';
      s.COMMENTS := ' перейти к списку моделей ';
	    pipe row (s);
      begin
        select NAME into modelName from SP.MODELS where ID = -SP.TG.CurValue.N;
			exception
			  when no_data_found then
			    raise_application_error(-20033,'SP.MO.RELS. '||
			      'Отсутствует модель с идентификатором '
            ||nvl(to_char(SP.TG.CurValue.N),'null')||' !');
      end;
      s.S_VALUE :=modelName||'=>/';
      s.COMMENTS := './(current object)';
      pipe row (s);
		  for n in (select MOD_OBJ_NAME, CATALOG_NAME from SP.V_MODEL_OBJECTS 
		              where PARENT_MOD_OBJ_ID is null 
                    and MODEL_ID = -SP.TG.CurValue.N
		              order by MOD_OBJ_NAME)
		  loop
		    s.S_VALUE := modelName||'=>/'||n.MOD_OBJ_NAME;
        s.COMMENTS := n.CATALOG_NAME;
		    pipe row(s);
		  end loop;
    -- Если узел не корень и положителен, то предоставляем детей объекта,
    -- а если их нет, то соседей.  
    when SP.TG.CurValue.N > 1 then
      -- Проверяем есть ли объект и находим имя модели.
      begin
        select MODEL_ID, MODEL_NAME into modelID, modelName 
          from SP.V_MODEL_OBJECTS 
          where ID =SP.TG.CurValue.N;
			exception
			  when no_data_found then
			    raise_application_error(-20033,'SP.MO.RELS. '||
			      'Отсутствует модель с идентификатором '
            ||nvl(to_char(SP.TG.CurValue.N),'null')||' !');
      end;
      -- находим родителя и себя
--      D('ModObjID '||SP.TG.CurValue.N,'SP.MO.Rel_s');
      tmpVar := SP.TG.CurValue.N; 
      currentName := FULL_NAME(tmpVar);
--      D('currentName '||currentName,'SP.MO.Rel_s');
      begin
        select PARENT_MOD_OBJ_ID into parentID from SP.MODEL_OBJECTS
          where ID = SP.TG.CurValue.N;
        parentName := FULL_NAME(parentID);
      exception
        -- родитель корень
        when no_data_found then 
          parentID := null;
          parentName :='/';
      end;    
--      D('parentName '||parentName,'SP.MO.Rel_s');
      s.S_VALUE :='null';
      s.COMMENTS := ' перейти к списку моделей ';
      pipe row (s);
      s.S_VALUE :=modelName||'=>'||currentName;
      s.COMMENTS := './(current object)';
      pipe row (s);
      s.S_VALUE :=modelName||'=>'||parentName;
      s.COMMENTS := '../(parent object)';
      pipe row (s);
      -- Проверяем есть ли дети.
      select count(*) into tmpVar from SP.MODEL_OBJECTS 
        where PARENT_MOD_OBJ_ID = SP.TG.CurValue.N;
      if tmpVar = 0 then
        -- Если не нашли детей, то выводим список соседей.
        if parentID  is null then        
          -- родитель корень
--          d(modelID,'SP.MO.Rel_s');
 				  for n in (select MOD_OBJ_NAME, CATALOG_NAME 
                      from SP.V_MODEL_OBJECTS 
				              where PARENT_MOD_OBJ_ID is null
				                and MODEL_ID = modelID
				              order by MOD_OBJ_NAME)
				  loop
				    s.S_VALUE := modelName||'=>/'||n.MOD_OBJ_NAME;
            s.COMMENTS := n.CATALOG_NAME;
				    pipe row(s);
				  end loop;
          -- выход!
          return;
        end if;  
			  for n in (select FULL_NAME, CATALOG_NAME, MOD_OBJ_NAME
                    from SP.V_MODEL_OBJECTS 
			              where PARENT_MOD_OBJ_ID = parentID
			              order by FULL_NAME)
			  loop
			    s.S_VALUE := modelName||'=>'||n.FULL_NAME;
          s.COMMENTS :=n.MOD_OBJ_NAME||'('|| n.CATALOG_NAME||')';
          pipe row(s);
			  end loop;
         -- выход!
         return;
      end if;  
      -- выводим список детей.  
		  for n in (select FULL_NAME, CATALOG_NAME, MOD_OBJ_NAME
                  from SP.V_MODEL_OBJECTS 
		              where PARENT_MOD_OBJ_ID = SP.TG.CurValue.N
		              order by FULL_NAME)
		  loop
				s.S_VALUE := modelName||'=>'||n.FULL_NAME;
        s.COMMENTS := n.MOD_OBJ_NAME||'('|| n.CATALOG_NAME||')';
				pipe row(s);
		  end loop;
  end case;
  return;
exception
  when no_data_needed then 
    null;
  when others then
  d(SQLERRM,'ERROR IN SP.MO.REL_S');
end REL_S;  

-------------------------------------------------------------------------------
FUNCTION GET_MODEL_OBJECT(ObjectID in NUMBER) 
return SP.G.TMACRO_PARS
is
  result SP.G.TMACRO_PARS;
begin
  GET_MODEL_OBJECT(result, ObjectID, false);
  return result;
end GET_MODEL_OBJECT; 
 
-------------------------------------------------------------------------------
FUNCTION GET_MODEL_OBJECT(ObjectID in NUMBER, TINY in BOOLEAN) 
return SP.G.TMACRO_PARS
is
  result SP.G.TMACRO_PARS;
begin
  GET_MODEL_OBJECT(result, ObjectID, TINY);
  return result;
end GET_MODEL_OBJECT;  

-------------------------------------------------------------------------------
PROCEDURE GET_MODEL_OBJECT(PARS in out nocopy  SP.G.TMACRO_PARS, 
                           ObjectID in NUMBER,
                           TINY in BOOLEAN)
is
  pTiny boolean;                           
  ObjectOID VARCHAR2(40);
  ObjID NUMBER;
  p SP.TMPAR;
  names SP.TSTRINGS;
  i number;
  s VARCHAR2(4000);
begin
  -- Если это корневой объект, то заполняем его св-ва и выход.
  --!! Доделать корневой объект до полного, через с-ва модели.
  ObjID := ObjectID;
  if ObjID = 1 then
    PARS:=CurModelHRootObject;
    return;
  end if;
  pTiny := TINY;
  if pTiny is null then
    if PARS.exists('IS_TINY') then
      pTiny := PARS('IS_TINY').asBoolean; 
    else
      pTiny := true;
      PARS('IS_TINY') := B_(true);
    end if; 
  else
    PARS('IS_TINY') := B_(pTiny);  
  end if;
  if ObjID is null then
    ObjID := MOD_OBJ_ID(PARS, ObjectOID);  
  end if;
  if ObjID = 1 then
    PARS:=CurModelHRootObject;
    return;
  end if;
  if pTINY then
    if PARS.count != 0 then
      names := SP.TSTRINGS();
      names.EXTEND(PARS.count);
      s := PARS.first;
      i := 1;
      while s is not null
      loop
        names(i) := s;
        s := PARS.next(s);
        i := i + 1;
      end loop;
    end if;
    for p in (select * from table(GET_MODEL_OBJECT_PARS(ObjID, names)))
	  loop 
	    PARS(p.NAME):= p.VAL;                                 
	  end loop;
  else
    for p in (select * from table(GET_MODEL_OBJECT_PARS(ObjID)) )
    loop 
      PARS(p.NAME):= p.VAL;
    end loop;
  end if;
  -- Всегда добавляем параметр ID
  PARS('ID') := ID_(ObjID);
end GET_MODEL_OBJECT;

-------------------------------------------------------------------------------
FUNCTION GET_MODEL_HROOT return SP.G.TMACRO_PARS
is
 result SP.G.TMACRO_PARS;
begin
 result := CurModelHRootObject;
 return result;
end GET_MODEL_HROOT;

-------------------------------------------------------------------------------
PROCEDURE CHANGE_OBJECT_CLASS(ModelObjectID in NUMBER, NewCatalogID in NUMBER)
is
tmpVar NUMBER;
begin
  begin
    -- Если класс не изменился, то ничего не делаем.
    select OBJ_ID into tmpVar from SP.MODEL_OBJECTS where ID = ModelObjectID;
  --  d('Проверяем класс объекта:'||ModelObjectID
  --    || 'Старый класс: '||tmpVar||'Класс объекта :'||NewCatalogID 
  --  ,'SP.MO.CHANGE_OBJECT_CLASS'); 
  exception
    when no_data_found then
      d('Объект с '||to_char(ModelObjectID)||' не найжен!',
        'ERROR in SP.MO.CHANGE_OBJECT_CLASS');
      raise_application_error(-20033,'ERROR in SP.MO.CHANGE_OBJECT_CLASS '||
      'Объект с '||to_char(ModelObjectID)||' не найжен!');
  end;
  if tmpVar = NewCatalogID then
    return;
  end if; 
--  d('Обновляем класс объекта:'||ModelObjectID,'SP.MO.CHANGE_OBJECT_CLASS'); 
  -- Обновляем класс объекта.
  update SP.MODEL_OBJECTS set
    OBJ_ID = NewCatalogID
    where ID = ModelObjectID;
  -- Для всех переопределённых параметров объекта, принадлежащих старому классу
  for par in ( 
    select mp.ID, op.NAME, op.TYPE_ID, op.ID OLD_OBJ_PAR_ID  
      from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S op
      where mp.OBJ_PAR_ID = op.ID
        and mp.MOD_OBJ_ID = ModelObjectID
             )
  loop              
    -- Находим в новом классе параметр с таким же именем и типом
    begin
    select ID into tmpVar from SP.OBJECT_PAR_S op 
      where op.NAME = par.NAME and OP.TYPE_ID = par.TYPE_ID
        and OP.OBJ_ID = NewCatalogID;
    -- Если нашли, то заменяем ссылку на параметр в параметре модели, 
    -- а так же в истории параметра.
    update SP.MODEL_OBJECT_PAR_S set
      OBJ_PAR_ID = tmpVar
      where ID = par.ID;
    update SP.MODEL_OBJECT_PAR_STORIES set
      OBJ_PAR_ID = tmpVar
      where MOD_OBJ_ID = ModelObjectID 
        and OBJ_PAR_ID = par.OLD_OBJ_PAR_ID;
    exception
      when no_data_found then 
        --Если не нашли, то удаляем параметр и его историю.
        SP.TG.ModObjParDeleting := true; 
        delete from SP.MODEL_OBJECT_PAR_S where ID = par.ID;
        delete from SP.MODEL_OBJECT_PAR_STORIES 
          where MOD_OBJ_ID = ModelObjectID 
            and OBJ_PAR_ID = par.OLD_OBJ_PAR_ID;
        SP.TG.ModObjParDeleting := false; 
    end; 
  end loop;
  -- Для всех внекаталожных параметров, имеющих имена совпадающие с каталогом,
  -- проставляем ссылку на каталожный параметр и стираем имя.
  for par in ( 
    select mp.ID, op.ID CID, op.NAME, op.TYPE_ID, MP.TYPE_ID OLD_TYPE, OP.R_ONLY 
      from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S op
      where mp.OBJ_PAR_ID is null
        and mp.MOD_OBJ_ID = ModelObjectID
        and op.OBJ_ID = NewCatalogID
        and OP.NAME = MP.NAME
             )
  loop        
    -- Проверяем совпадение типов параметров и возможность записи.
    if par.TYPE_ID != par.OLD_TYPE then
      raise_application_error(-20033,'ERROR in SP.MO.CHANGE_OBJECT_CLASS '||
      'Тип внекаталожного параметра '||par.Name||' не совпадает с каталогом!');
    end if;    
    if par.R_ONLY = G.ReadOnly then
      raise_application_error(-20033,'ERROR in SP.MO.CHANGE_OBJECT_CLASS '||
      'Параметр '||par.Name||' доступен только на чтение в каталоге!');
    end if; 
    update SP.MODEL_OBJECT_PAR_S mp set
      Name = null,
      OBJ_PAR_ID = par.CID
    where ID = par.ID;  
  end loop; 
exception
  when others then
    SP.TG.ModObjParDeleting := false; 
    d(SQLERRM||' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
      'ERROR in SP.MO.CHANGE_OBJECT_CLASS');
    raise;
end CHANGE_OBJECT_CLASS;

-------------------------------------------------------------------------------
FUNCTION GET_CATALOG_OBJECT(Used_Object in VARCHAR2) return NUMBER
is 
s VARCHAR2(4000);
p pls_integer;
tmpVar NUMBER;
begin
  if Used_Object is null then return null; end if;
  s := Used_Object;
  p := instr(s,'.',-1);
  -- Если в строке присутствует ".", 
  if p > 0 then
    -- то это полное имя,
    select ID into tmpVar from SP.V_OBJECTS where FULL_NAME = s;
  else
  -- иначе "OID".
    select ID into tmpVar from SP.V_OBJECTS where OID = s;
  end if;
  return tmpVar;
exception
  when no_data_found then
    return null;  
end GET_CATALOG_OBJECT;

-------------------------------------------------------------------------------
FUNCTION GET_CATALOG_OBJECT(Used_Object in TVALUE) return NUMBER
is 
begin
  if Used_Object.T != G.TUsed_Object then
    raise_application_error(-20033,'SP.MO.GET_CATALOG_OBJECT. '||
      'Неверный тип параметра!');
  end if;
  return GET_CATALOG_OBJECT(Used_Object.S);
exception
  when no_data_found then
    return null;  
end GET_CATALOG_OBJECT;

FUNCTION GET_MODEL_OBJECT_PARS(Object_ID in NUMBER,
                               Names in SP.TSTRINGS default null) 
return TPars pipelined
is
par TParRec;
obj SP.MODEL_OBJECTS%rowtype;
poid VARCHAR2(128);
begin
for rec in
(
  select 
    NAME,
    TYPE_ID,
    E_VAL,
    N,
    D,
    S,
    X,
    Y
  from 
  (
     WITH mod_objects
          AS (SELECT ID, OBJ_ID
                FROM SP.MODEL_OBJECTS m
               WHERE  (ID = Object_ID)
--                  AND(   
--                        (m.USING_ROLE IS NULL)
--                     OR (SP.S_isUserAdmin = 1)
--                     OR (m.USING_ROLE IN (SELECT ROLE_ID FROM SP.USER_ROLES)))
             ),
          obj_pars
          AS (SELECT ID, OBJ_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y
                FROM SP.OBJECT_PAR_S cp
                where  UPPER (cp.NAME) NOT IN ('NAME',
                                               'PARENT',
                                               'POID',
                                               'OID',
                                               'ID',
                                               'PID',
                                               'USING_ROLE',
                                               'EDIT_ROLE')
                                              ),            
         mod_obj_pars
         AS (SELECT ID, MOD_OBJ_ID,OBJ_PAR_ID, TYPE_ID, E_VAL, NAME,
                    N, D, S, X, Y
                FROM SP.MODEL_OBJECT_PAR_S mp
                where  mp.MOD_OBJ_ID = Object_ID)
     SELECT mp.ID ID,
            NVL (mp.NAME, cp.NAME) NAME,
            NVL2 (mp.ID, mp.TYPE_ID, cp.TYPE_ID) TYPE_ID,
            NVL2 (mp.ID, mp.E_VAL, cp.E_VAL) E_VAL,
            NVL2 (mp.ID, mp.N, cp.N) N,
            NVL2 (mp.ID, mp.D, cp.D) D,
            NVL2 (mp.ID, mp.S, cp.S) S,
            NVL2 (mp.ID, mp.X, cp.X) X,
            NVL2 (mp.ID, mp.Y, cp.Y) Y
       FROM mod_objects mo
            INNER JOIN obj_pars cp
               ON     cp.OBJ_ID = mo.OBJ_ID
            FULL JOIN mod_obj_pars mp
               ON mp.MOD_OBJ_ID = mo.ID AND mp.OBJ_PAR_ID = cp.ID
  )
)
loop
  if names is null or rec.NAME member of names then
    par.NAME := rec.NAME;
    par.VAL := SP.TVALUE(rec.TYPE_ID, null, 0,
                         rec.E_VAL, rec.N, rec.D, rec.S, rec.X, rec.Y);
    pipe row(par);
  end if;
end loop;
  
  SELECT * into obj FROM SP.MODEL_OBJECTS m WHERE  (ID = Object_ID);
  if names is null or 'NAME' member of names then
    par.NAME := 'NAME';
    par.VAL := SP.TVALUE(g.TStr4000, null, 0,
                         null, null, null, obj.MOD_OBJ_NAME, null, null);
    pipe row(par);
  end if; 
  if names is null or 'PARENT' member of names then
    par.NAME := 'PARENT';
    par.VAL := SP.TVALUE(g.TStr4000, null, 0,
                         null, null, null,
                         FULL_NAME( obj.PARENT_MOD_OBJ_ID), null, null);
    pipe row(par);
  end if; 
  if names is null or 'POID' member of names then
    par.NAME := 'POID';
    if obj.PARENT_MOD_OBJ_ID is null then
      poid := null;
    else  
    select OID into poid from SP.MODEL_OBJECTS 
      where (ID = obj.PARENT_MOD_OBJ_ID);
    end if;  
    par.VAL := SP.TVALUE(g.TOID, null, 0,
                         null, null, null, poid, null, null);
    pipe row(par);
  end if; 
  if names is null or 'OID' member of names then
    par.NAME := 'OID';
    par.VAL := SP.TVALUE(g.TOID, null, 0,
                         null, null, null, obj.OID, null, null);
    pipe row(par);
  end if; 
  if names is null or 'PID' member of names then
    par.NAME := 'PID';
    par.VAL := SP.TVALUE(g.TID, null, 0,
                         null, obj.PARENT_MOD_OBJ_ID, null, null, null, null);
    pipe row(par);
  end if; 
  if names is null or 'ID' member of names then
    par.NAME := 'ID';
    par.VAL := SP.TVALUE(g.TID, null, 0,
                         null, Object_ID, null, null, null, null);
    pipe row(par);
  end if; 
  if names is null or 'USING_ROLE' member of names then
    par.NAME := 'USING_ROLE';
    par.VAL := SP.TVALUE(g.TRole, null, 0,
                         null, obj.USING_ROLE, null, null, null, null);
    pipe row(par);
  end if; 
  if names is null or 'EDIT_ROLE' member of names then
    par.NAME := 'EDIT_ROLE';    
    par.VAL := SP.TVALUE(g.TRole, null, 0,
                         null, obj.EDIT_ROLE, null, null, null, null);
    pipe row(par);
  end if; 
return;
end GET_MODEL_OBJECT_PARS;

FUNCTION GET_V_MODEL_OBJECT_PARS(Object_ID in NUMBER) 
return TObjectPars pipelined
is
outRec TViewParRec;
obj SP.MODEL_OBJECTS%rowtype;
poid VARCHAR2(128);
begin
  -- Если корень дерева, то выход без выполнения.
  --! Доделать чтение свойств корня дерева моделей
  if Object_ID < 10 then return; end if;
  for rec in (  select 
    ID,
    CP_ID,
    NAME,
    TYPE_ID,
    D_VAL,
    E_VAL,
    N,
    D,
    S,
    X,
    Y,
    R_ONLY_ID,
    M_DATE,
    M_USER
  from 
  (
     WITH mod_objects
          AS (SELECT ID, OBJ_ID
                FROM SP.MODEL_OBJECTS m
               WHERE  (ID = Object_ID)
             ),
          obj_pars
          AS (SELECT ID, OBJ_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y
                FROM SP.OBJECT_PAR_S cp
                where  UPPER (cp.NAME) NOT IN ('NAME',
                                               'PARENT',
                                               'POID',
                                               'OID',
                                               'ID',
                                               'PID',
                                               'USING_ROLE',
                                               'EDIT_ROLE')
                                              ),            
         mod_obj_pars
         AS (SELECT ID, MOD_OBJ_ID,OBJ_PAR_ID, TYPE_ID, E_VAL, NAME,
                    N, D, S, X, Y, M_DATE, M_USER, R_ONLY
                FROM SP.MODEL_OBJECT_PAR_S mp
                where  mp.MOD_OBJ_ID = Object_ID)
     SELECT mp.ID ID,
            NVL (mp.NAME, cp.NAME) NAME,
            cp.ID CP_ID,
            SP.Val_to_str (SP.TVALUE (nvl(cp.TYPE_ID, 15),
                                      NULL,
                                      0,
                                      cp.E_VAL,
                                      cp.N,
                                      cp.D,
                                      cp.S,
                                      cp.X,
                                      cp.Y))
            D_VAL,
            NVL2 (mp.ID, mp.TYPE_ID, cp.TYPE_ID) TYPE_ID,
            NVL2 (mp.ID, mp.E_VAL, cp.E_VAL) E_VAL,
            NVL2 (mp.ID, mp.N, cp.N) N,
            NVL2 (mp.ID, mp.D, cp.D) D,
            NVL2 (mp.ID, mp.S, cp.S) S,
            NVL2 (mp.ID, mp.X, cp.X) X,
            NVL2 (mp.ID, mp.Y, cp.Y) Y,
            nvl2 (mp.ID, mp.R_ONLY, cp.R_ONLY) R_ONLY_ID,
            mp.M_DATE,
            mp.M_USER
       FROM mod_objects mo
            INNER JOIN obj_pars cp
               ON     cp.OBJ_ID = mo.OBJ_ID
            FULL JOIN mod_obj_pars mp
               ON mp.MOD_OBJ_ID = mo.ID AND mp.OBJ_PAR_ID = cp.ID
  )
)

  loop
     -- Идентификатор параметра
     outRec.ID := rec.ID;
     -- Имя параметра
     outRec.PARAM_NAME := rec.NAME;
     -- Идентификатор прообраза параметра в каталоге или нулл,
     -- если параметр отсутствует у объекта прообраза.
     outRec.OBJ_PAR_ID := rec.CP_ID;
     -- Идентификатор типа параметра
     outRec.TYPE_ID := rec.TYPE_ID;
     -- Имя типа параметра
     outRec.TYPE_NAME := SP.to_strTYPE (rec.TYPE_ID);
     -- Идентификатор модификатора параметра 
     outRec.R_ONLY := SP.to_strR_ONLY (rec.R_ONLY_ID);
     -- Модификатор параметра
     outRec.R_ONLY_ID := rec.R_ONLY_ID;
     -- Признак наличия у типа набора значений 
     outRec.SET_OF_VALUES := SP.S_TYPE_HAS_SET_OF_VALUES (rec.TYPE_ID);
     -- Значение параметра, используемое по умолчанию 
     outRec.D_VAL := rec.D_VAL; 
     -- Текущее значение параметра
     outRec.VAL := SP.Val_to_str (SP.TVALUE ( nvl(rec.TYPE_ID, 15),
                                              NULL,
                                              0,
                                              rec.E_VAL,
                                              rec.N,
                                              rec.D,
                                              rec.S,
                                              rec.X,
                                              rec.Y));

     -- Имя значения 
     outRec.E_VAL := rec.E_VAL;
     -- Поля значения
     outRec.N := rec.N;
     outRec.D := rec.D;
     outRec.S := rec.S;
     outRec.X := rec.X;
     outRec.Y := rec.Y;
     -- Группа параметра
     outRec.GROUP_NAME := SP.Get_ObjParGroupName(rec.CP_ID, outrec.GROUP_ID);
     -- Дата изменения и пользователь
     outRec.M_DATE := rec.M_DATE; 
     outRec.M_USER := rec.M_USER;
     pipe row (outRec);
  end loop;
  select * into obj from SP.MODEL_OBJECTS m where (ID = Object_ID);
  if obj.PARENT_MOD_OBJ_ID is null then
    poid := null;
  else  
    select OID into poid from SP.MODEL_OBJECTS 
      where ID = obj.PARENT_MOD_OBJ_ID;
  end if;    
  --  
  outRec.PARAM_NAME := 'NAME';
  outRec.VAL := obj.MOD_OBJ_NAME;
  outRec.ID := null;
  outRec.OBJ_PAR_ID := null;
  outRec.TYPE_ID := g.TStr4000;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TStr4000);
  outRec.R_ONLY := SP.to_strR_ONLY (1);
  outRec.R_ONLY_ID := 1;
  outRec.SET_OF_VALUES := 0;
  outRec.D_VAL := null; 
  outRec.E_VAL := null;
  outRec.N := null;
  outRec.D := null;
  outRec.S := obj.MOD_OBJ_NAME;
  outRec.X := null;
  outRec.Y := null;
  outRec.Group_ID := 12;
  outRec.GROUP_NAME := 'System';
  outRec.M_DATE := obj.M_DATE; 
  outRec.M_USER := obj.M_USER;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'PARENT';
  outRec.VAL := FULL_NAME(obj.PARENT_MOD_OBJ_ID);
  outRec.S := outRec.VAL;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'POID';
  outRec.VAL := poid;
  outRec.TYPE_ID := g.TOID;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TOID);
  outRec.S := poid;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'OID';
  outRec.VAL := obj.oid;
  outRec.TYPE_ID := g.TOID;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TOID);
  outRec.S := obj.oid;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'ID';
  outRec.VAL := to_char(obj.ID);
  outRec.TYPE_ID := g.TID;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TID);
  outRec.N := obj.ID;
  outRec.S := null;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'PID';
  outRec.VAL := to_char(obj.PARENT_MOD_OBJ_ID);
  outRec.TYPE_ID := g.TID;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TID);
  outRec.N := obj.PARENT_MOD_OBJ_ID;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'USING_ROLE';
  outRec.VAL := Sp.Val_to_STR(SP.TVALUE(g.TRole, null, 0,
                       null, obj.USING_ROLE, null, null, null, null));
  outRec.TYPE_ID := g.TRole;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TRole);
  outRec.N := obj.USING_ROLE;
  pipe row(outRec);
  --
  outRec.PARAM_NAME := 'EDIT_ROLE';
  outRec.VAL := Sp.Val_to_STR(SP.TVALUE(g.TRole, null, 0,
                       null, obj.EDIT_ROLE, null, null, null, null));
  outRec.TYPE_ID := g.TRole;
  outRec.TYPE_NAME := SP.to_strTYPE (g.TRole);
  outRec.N := obj.EDIT_ROLE;
  pipe row(outRec);
  --
  return;
exception
  when no_data_needed then 
    d('No data NEEDED!!! BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
      'ERROR in SP.MO.GET_V_MODEL_OBJECT_PARS');
  when others then
    d('Object_ID '||nvl(to_char(Object_ID), 'null')||'  '||SQLERRM,
      'ERROR in SP.MO.GET_V_MODEL_OBJECT_PARS');
    d('BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
      'ERROR in SP.MO.GET_V_MODEL_OBJECT_PARS');
    raise;  
end GET_V_MODEL_OBJECT_PARS;


FUNCTION GET_CATALOG_OBJECT(ObjectID in NUMBER) return SP.G.TMACRO_PARS
is
  PARS SP.G.TMACRO_PARS;
  p SP.TMPAR;
begin
  if ObjectID is null then
    raise_application_error(-20033,'SP.MO.GET_CATALOG_OBJECT. '||
      'Отсутствует идентификатор объекта!');
  end if;
  for p in (select * from SP.V_OBJECT_PAR_S where OBJECT_ID = ObjectID)
  loop 
    PARS(p.NAME):= SP.TVALUE(T=> p.TYPE_ID, COMMENTS => p.COMMENTS,
      R_ONLY=> p.R_ONLY_ID,
      E => p.E, N => p.N, D => p.D, S => p.S, X => p.X, Y => p.Y);                            
  end loop;
  return PARS;
end GET_CATALOG_OBJECT;

-------------------------------------------------------------------------------
begin
  CurModelHRootObject('NAME'):= S_('/');
  CurModelHRootObject('PARENT'):= S_('');
  CurModelHRootObject('SP3DTYPE'):=  SP.TVALUE(SP.G.TIType, 'HierarchiesRoot');
  CurModelHRootObject('IS_SYSTEM'):=B_(true); 
  CurModelHRootObject('IS_TINY'):=B_(true); 
  CurModelHRootObject('OID'):=S_('-1'); 
  CurModelHRootObject('POID'):=S_(''); 
  CurModelHRootObject('HIERARCHY_ROOT_NAME'):=S_(''); 
  CurModelHRootObject('ID'):= SP.TVALUE(SP.G.TID, 1);
  -- Устанавливаем PID в нулл.
  CurModelHRootObject('PID'):= SP.TVALUE(SP.G.TID, -1);
  --!!! просто нулл не получается
  CurModelHRootObject('PID').N :=null;
End MO;
/

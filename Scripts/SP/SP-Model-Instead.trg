-- Tригеры для представления моделей.
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 13.10.2010 28.10.2010 24.11.2010 16.12.2010 12.01.2010 03.03.2011
-- 		    20.04.2011 24.11.2011 09.12.2011 15.12.2011 29.12.2011 23.03.2012
-- by Nikolay Krasilnikov
--        21.08.2013 26.08.2013 14.02.2014 27.05.2014 14.06.2014 09.10.2014
--        11.11.2014 26.11.2014 28.11.2014 31.03.2015 01.04.2015 28.10.2016
--        29.10.2016 06.03.2017 10.04.2017 09.06.2017 19.01.2018 11.11.2020
--        11.04.2021 08.07.2021 04.09.2021 08.09.2021
-- Модели.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_ii
instead of insert on SP.V_MODELS
--SP-Model-Instead.trg
declare
  URole NUMBER;
begin
  if :NEW.USING_ROLE_NAME is not null then
    select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
  else
    URole := :NEW.USING_ROLE_ID;      
  end if;
  insert into SP.MODELS(NAME,COMMENTS,PERSISTENT,LOCAL, USING_ROLE)
  values(:NEW.MODEL_NAME,:NEW.MODEL_COMMENTS, :NEW.PERSISTENT, :NEW.LOCAL,
         URole);
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODELS_ii'||
      'Не найдена роль с именем '||:NEW.USING_ROLE_NAME||'!');             
end;
/	
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_iu
instead of update on SP.V_MODELS
--SP-Model-Instead.trg
declare
  URole NUMBER;
begin
  if :NEW.USING_ROLE_NAME is not null then
    select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
  else
    URole := :NEW.USING_ROLE_ID;      
  end if;
   update SP.MODELS 
   set NAME = :NEW.MODEL_NAME,
       COMMENTS = :NEW.MODEL_COMMENTS,
       PERSISTENT = :NEW.PERSISTENT,
       LOCAL = :NEW.LOCAL,
       USING_ROLE = UROLE
   where ID = :OLD.ID; 
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODELS_iu'||
      'Не найдена роль с именем '||:NEW.USING_ROLE_NAME||'!');             
end;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_id
instead of delete on SP.V_MODELS
--SP-Model-Instead.trg
begin
  delete from SP.MODELS where ID = :OLD.ID;
end;
/	
--*****************************************************************************
-- Объекты Моделей.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_ii
instead of insert on SP.V_MODEL_OBJECTS
-- (SP-Model-Instead.trg)
declare
CatalogObjID NUMBER;
tmpN NUMBER;
FullName SP.COMMANDS.COMMENTS%type;
ShortName SP.MODEL_OBJECTS.MOD_OBJ_NAME%type;
URole NUMBER;
ERole NUMBER;
begin
  if SP.TG.Get_CurModel is null then
    d('Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ',
      'ERROR SP.V_MODEL_OBJECTS_ii');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
      'Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ');
  end if;
  -- Если задано имя прообраза объекта в каталоге, то находим иденитификатор,
  -- иначе используем идентификатор прообраза объекта.
  if :NEW.CATALOG_NAME is not null then
    begin
      if :NEW.CATALOG_GROUP_NAME is null then
        select ID into CatalogObjID from SP.OBJECTS
          where upper(NAME) = upper(:NEW.CATALOG_NAME);
      else
        select o.ID into CatalogObjID from SP.OBJECTS o, SP.GROUPS g
          where upper(o.NAME) = upper(:NEW.CATALOG_NAME)
            and upper(g.NAME) = upper(:NEW.CATALOG_GROUP_NAME);
      end if;    
    exception
        when NO_DATA_FOUND then
    	    d('Имя каталожного прообраза объекта модели задано не корректно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            'Имя каталожного прообраза объекта модели задано не корректно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
        when too_many_rows then
    	    d('Имя каталожного прообраза объекта модели задано не однозначно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            'Имя каталожного прообраза объекта модели задано не однозначно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
    end;
  else
    CatalogObjID := :NEW.OBJ_ID;
    if :NEW.OBJ_ID is null then
      d('Не выбран прообраз объекта модели из каталога ',
        'ERROR SP.V_MODEL_OBJECTS_ii');
      RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
      'Не выбран прообраз объекта модели из каталога!');
    end if;
  end if;
 
  tmpN :=null;
  -- Если определён POID или PARENT_MOD_OBJ_ID,
  -- то имя извлекаем из MOD_OBJ_NAME.
  ShortName:=SP.PATHS.SHORTNAME(:New.MOD_OBJ_NAME);
  
  -- Если задан PARENT_MOD_OBJ_ID, то родитель определён.
  IF :NEW.PARENT_MOD_OBJ_ID is not null THEN
    tmpN := :NEW.PARENT_MOD_OBJ_ID;
  END IF;
  -- Если задан OID родителя и идентификатор родителя ещё не определён, 
  IF (:NEW.POID is not null)  and (tmpN is null) THEN
    -- то находим делаем попытку найти ID родителя.
    begin
      select ID into tmpN from SP.MODEL_OBJECTS
        where :NEW.POID = OID
          and MODEL_ID = SP.TG.Cur_MODEL_ID;
    exception when NO_DATA_FOUND then
      null;
    end;
  END IF;
  -- Если идентификатор родителя не найден, 
  IF tmpN is null THEN
    -- то переходим к поиску идентификатора родителя по имени.
	  if :NEW.FULL_NAME is not null then
	    FullName:=:New.FULL_NAME;
	    ShortName:=SP.PATHS.SHORTNAME(:New.FULL_NAME);
	  elsif :NEW.PATH is not null then  
	    FullName:= SP.PATHS.NAME(:NEW.PATH,:NEW.MOD_OBJ_NAME);
	    ShortName:=SP.PATHS.SHORTNAME(:New.MOD_OBJ_NAME);
	  else 
	    -- Родитель отсутствует, объект располагаем в корне иерархии. 
	    tmpN := null;
      FullName := null;
	  end if;
    -- Если объект не к корне иерархии,
    if FullName is not null then
		  -- то ищем родителя объекта по полному имени.
		  tmpN:= SP.MO.MOD_OBJ_ID_BY_FULL_NAME(FullName);
		  if tmpN is null then
			  -- Если родитель отсутствует,
	      -- то проходим последовательно весь полный путь
			  -- объекта, достраивая недостающие объекты.
			  -- Разворачиваем полный путь объекта в таблицу последовательных
        -- значений, используя символ '/' как признак новой строки.
			  for c1 in (select COLUMN_VALUE s,ROWNUM rn
			     from table (SP.SET_FROM_STRING(SP.PATHS.PATH(FullName),'/')))
			  loop
			    begin
			      -- ищем ID родительского объекта из имеющихся в базе
			      select ID into tmpN from SP.MODEL_OBJECTS
			        where UPPER(MOD_OBJ_NAME)=UPPER(c1.s)
			          and NVL(PARENT_MOD_OBJ_ID,-1) = NVL(tmpN,-1)
			          and MODEL_ID = SP.TG.Cur_MODEL_ID;
			    exception when NO_DATA_FOUND then
			      -- если ID не найдено, родительский объект считаем 
			      -- объектом построенным в Интеграфе не средствами IMan
			      -- #Native Object
			      insert into SP.MODEL_OBJECTS 
			        values (null, SP.TG.Cur_MODEL_ID, c1.s, null, 1, tmpN, 
                      null,null,
                      null, null, 0)
			        returning  ID into tmpN;
			    end;
			  end loop;
		  end if;
    end if;--FullName is not null  
  END IF;
  -- Находим идентификаторы ролей доступа.
  URole := :NEW.USING_ROLE_ID;
  if :NEW.USING_ROLE_NAME is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            'Роль '||:NEW.USING_ROLE_NAME||' не найдена!');
    end;  
  end if;
  ERole := :NEW.EDIT_ROLE_ID;
  if :NEW.EDIT_ROLE_NAME is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.EDIT_ROLE_NAME;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            'Роль '||:NEW.EDIT_ROLE_NAME||' не найдена!');
    end;  
  end if;
  --!! Добавить проверку, что уникальный идентификатор родителя объекта,
  -- вставляемого в корень,
  -- совпадает с уникальным идентификатором корневого объекта.
  -- Добавляем объект.
  insert into SP.MODEL_OBJECTS
    values (null, SP.TG.Cur_MODEL_ID, ShortName, :NEW.OID,
            CatalogObjID, tmpN, 
            URole, ERole,
            :NEW.M_DATE, :NEW.M_USER, 0);
  -- Обновляем OID родителя, если таковой стал доступен.
  if :NEW.POID is not null then
	  update SP.MODEL_OBJECTS set
	    OID = :NEW.POID
	    where ID=tmpN;
  end if;
end;
/
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_iu
instead of update on SP.V_MODEL_OBJECTS
-- Данные модели и данные объекта каталога тригер не меняет.
-- При обновлении записи, можно изменять имена и иерархию объектов,
-- их уникальные идентификаторы, ссылку на композит и стартовый композит,
-- а также прообраз объекта,
-- в последнем случае все данные о свойствах объекта будут удалены.
-- (SP-Model-Instead.trg)
declare
ParentID NUMBER;
CatObj NUMBER;
NewPath SP.COMMANDS.COMMENTS%type;
NewName SP.COMMANDS.COMMENTS%type;
URole NUMBER;
ERole NUMBER;
begin
  -- 1. Проверяем, установлена ли текущая модель
  if sp.tg.Cur_MODEL_ID is null then
    d('Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ',
      'ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
      'Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ');
  end if;
	if  sp.tg.Cur_MODEL_ID != :OLD.MODEL_ID then
	   RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
		   'Текущая модель не соответствует модели редактируемой записи!');
	end if;
  -- 2. Находим имя объекта.
  -- Если изменено имя объекта, а его полное имя нет, то берём изменённое имя,
  -- иначе отрезаем имя от полного имени.
  if    SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.notEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME) then
    NewName := :NEW.MOD_OBJ_NAME;
  else  
    NewName := SP.Paths.ShortName(:NEW.FULL_NAME);
  end if;  
  if NewName is null then
    d('Не задано имя объекта модели','ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
                                   ' Не задано имя объекта модели!');
  end if;
  if INSTR(NewName,'/') > 0 then
    d('Имя объекта модели '||:NEW.MOD_OBJ_NAME||
     	' задано не корректно!','ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
      ' Имя объекта модели '||:NEW.MOD_OBJ_NAME||' задано не корректно!');
  end if;
  -- 3. Находим родителя объекта.
  -- Если изменён путь к объекту, а полное имя и идентификатор родителя 
  -- объекта неизменен, то находим идентификатор родителя по путю к объекту.
  if    SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.EQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) 
    and SP.G.notEQ(:NEW.PATH, :OLD.PATH) 
  then
    ParentID:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(:NEW.PATH);
    NewPath:=:NEW.PATH;
  -- Если изменена ссылка на идентификатор родителя, то берём его за основу,
  -- в остальных случаях выделяем путь из полного имени. 
  elsif SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) 
  then
    ParentID:= :NEW.PARENT_MOD_OBJ_ID;
    NewPath:=null;
  else
    NewPath := SP.Paths.Path(:NEW.FULL_NAME);
    -- Отрезаем последний символ.
    NewPath := SUBSTR(NewPath,1,LENGTH(NewPath)-1);
    ParentID:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(NewPath);
  end if;
  -- Если так и не удалось найти родителя, то проходим последовательно весь 
  -- полный путь объекта, достраивая недостающие объекты.
  -- Разворачиваем полный путь объекта в таблицу последовательных значений, 
  -- используя символ '/' как признак новой строки
  if ParentID is null and NewPath is not null then 
    for c1 in (select COLUMN_VALUE s 
               from table (SP.SET_FROM_STRING(NewPath,'/')))
    loop
      begin
        -- ищем ID родительского объекта из имеющихся в базе
        select ID into ParentID from SP.MODEL_OBJECTS
          where UPPER(MOD_OBJ_NAME)=UPPER(c1.s)
            and NVL(PARENT_MOD_OBJ_ID,-1) = NVL(ParentID,-1)
            and MODEL_ID = SP.TG.Cur_MODEL_ID;
      exception when NO_DATA_FOUND then
        -- если ID не найдено, родительский объект считаем 
        -- объектом построенным в Интеграфе не средствами IMan
        -- #Native Object
        insert into SP.MODEL_OBJECTS 
          values (null, SP.TG.Cur_MODEL_ID, c1.s, null, 1, ParentID, 
                  null, null,
                  null, null, 0)
          returning  ID into ParentID;
      end;
    end loop; 
  end if;  
  -- 4. Находим прообраз объекта. 
  if :NEW.CATALOG_NAME is null and :NEW.OBJ_ID is null then
    d('Не задано имя каталожного прообраза объекта модели !!',
    'ERROR V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu '||
      'Не задано имя каталожного прообраза объекта модели !');
  end if;
  CatObj := :NEW.OBJ_ID;
  if   SP.G.notUpEQ(:NEW.CATALOG_NAME,:OLD.CATALOG_NAME) 
    or SP.G.notUpEQ(:NEW.CATALOG_GROUP_NAME,:OLD.CATALOG_GROUP_NAME) 
  THEN
    begin
      select o.ID into CatObj from SP.OBJECTS o, SP.GROUPS g
        where upper(o.NAME) = upper(:NEW.CATALOG_NAME)
          and upper(g.NAME) = upper(:NEW.CATALOG_GROUP_NAME);
    exception
        when NO_DATA_FOUND then
    	    d('Имя каталожного прообраза объекта модели задано не корректно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_iu');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
            'Имя каталожного прообраза объекта модели задано не корректно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
        when too_many_rows then
    	    d('Имя каталожного прообраза объекта модели задано не однозначно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_iu');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
            'Имя каталожного прообраза объекта модели задано не однозначно: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
    end;
    -- Удаляем все параметры объекта при изменении ссылки на объект каталога.
    delete from SP.MODEL_OBJECT_PAR_S where MOD_OBJ_ID = :OLD.ID; 
  end if;
  if SP.G.notEQ(:NEW.OBJ_ID,:OLD.OBJ_ID)THEN
    -- Удаляем все параметры объекта при изменении ссылки на объект каталога.
    delete from SP.MODEL_OBJECT_PAR_S where MOD_OBJ_ID = :OLD.ID; 
  end if;
  -- 5. Находим идентификаторы ролей доступа.
  URole := :NEW.USING_ROLE_ID;
  if G.notUpEQ(:OLD.USING_ROLE_NAME,:NEW.USING_ROLE_NAME)then
    if :NEW.USING_ROLE_NAME is null then
      URole := null;
    else
      begin
        select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
              'Роль '||:NEW.USING_ROLE_NAME||' не найдена!');
      end;
    end if;  
  end if;
  ERole := :NEW.EDIT_ROLE_ID;
  if G.notUpEQ(:OLD.EDIT_ROLE_NAME,:NEW.EDIT_ROLE_NAME)then
    if :NEW.EDIT_ROLE_NAME is null then
      ERole := null;
    else
      begin
        select ID into ERole from SP.SP_ROLES where NAME = :NEW.EDIT_ROLE_NAME;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
              'Роль '||:NEW.EDIT_ROLE_NAME||' не найдена!');
      end;
    end if;  
  end if;

  -- 6. Заносим новые данные в таблицу.
  update SP.MODEL_OBJECTS set 
    MOD_OBJ_NAME = NewName,
    PARENT_MOD_OBJ_ID = ParentID,
    OBJ_ID = CatObj,
    OID = :NEW.OID,
    USING_ROLE = URole,
    EDIT_ROLE = ERole,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER,
    TO_DEL = 0     
    where ID = :OLD.ID;
  -- 7. Обновляем OID родителя, если таковой стал доступен
  -- и операция редактирования не меняет родителя.
  if (:NEW.POID is not null) 
    and (:OLD.POID is null) 
    and G.notEQ(ParentID, :OLD.PARENT_MOD_OBJ_ID)  
  then
	  update SP.MODEL_OBJECTS set
	    OID = :NEW.POID
	    where ID = ParentID;
  end if;
end;
/
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_id
instead of delete on SP.V_MODEL_OBJECTS
-- (SP-Model-Instead.trg)
begin
  if SP.TG.Get_CurModel is null then
    d('Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ',
      'ERROR SP.V_MODEL_OBJECTS_id');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_id'||
      'Не задана текущая модель! '||
      'Необходимо установить соответствующий глобальный параметр! ');
  end if;    
  if G.notEQ(SP.TG.Get_CurModel, :OLD.MODEL_ID) then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_id'||
      'Нельзя удалять объекты не принадлежащие текущей модели, используя '||
      'данное представление! ');
  end if;    
  --d(:OLD.ID,'SP.V_MODEL_OBJECTS_id');
  delete from SP.MODEL_OBJECTS where ID = :OLD.ID;
  --d('end','SP.V_MODEL_OBJECTS_id');
end;
/	
--*****************************************************************************
-- 
-- Параметры объектов модели.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_ii
instead of insert on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
declare
  p SP.TMPAR;
  V SP.TVALUE;
begin
-- ID, OBJ_ID, PARAM_NAME, OBJ_PAR_ID, MOD_OBJ_ID, 
-- TYPE_ID, TYPE_NAME, R_ONLY_ID, R_ONLY, VALUE_ENUM, 
-- SET_OF_VALUES, D_VAL, VAL, E_VAL, N, 
-- D, S, X, Y, ISREDEFINE, 
-- M_DATE, M_USER

-- Для добавления параметра необходимо задать объект и имя параметра.
if :NEW.PARAM_NAME is null or :NEW.MOD_OBJ_ID is null then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_ii'||
    'Для добавления параметра необходимо задать объект и имя параметра!');
end if;
p:=TMPAR(:NEW.MOD_OBJ_ID, :NEW.PARAM_NAME);
if p.MP_ID is not null or p.CP_ID is not null then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_ii'||
    'Параметр '||:NEW.PARAM_NAME||' существует у объекта с идентификатором '||
    :NEW.MOD_OBJ_ID||'!');
end if;
-- Если определено значение в виде строки, то используем его иначе создаём из 
-- отдельных полей.
if :NEW.VAL is not null then
  if :NEW.TYPE_NAME is not null then
    --d('1','SP.V_MODEL_OBJECT_PARS_ii');
    V := SP.TVALUE(:NEW.TYPE_NAME,:NEW.VAL);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,:NEW.VAL);
  end if; 
-- всё значение нулл  
elsif  :NEW.E_VAL is null and :NEW.N is null and :NEW.D is null and
         :NEW.S is null and :NEW.X is null and :NEW.Y is null 
then
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME);
  else
    V := SP.TVALUE(:NEW.TYPE_ID);
  end if;  
else
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  end if; 
end if;
-- Присваиваем значение и добавляем параметр.
p.VAL:=V;
p.Save;
end;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_iu
instead of update on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
declare 
V SP.TVALUE;  -- переопределенное значение параметра
p SP.TMPAR;
begin
-- ID, OBJ_ID, PARAM_NAME, OBJ_PAR_ID, MOD_OBJ_ID, 
-- TYPE_ID, TYPE_NAME, R_ONLY_ID, R_ONLY, VALUE_ENUM, 
-- SET_OF_VALUES, D_VAL, VAL, E_VAL, N, 
-- D, S, X, Y, ISREDEFINE, 
-- M_DATE, M_USER
if :OLD.ID is not null then
  p:=TMPAR(:OLD.ID);
else
  p:=TMPAR(:OLD.MOD_OBJ_ID, :OLD.PARAM_NAME);

end if;  
-- Переименовать можно только параметр, определённый в сторонней модели.
if G.notUpEQ(:NEW.PARAM_NAME, :OLD.PARAM_NAME) then
  if :OLD.OBJ_PAR_ID is not null then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_iu'||
      'Переименовать можно только параметр, определённый в сторонней модели!');
  end if;
  p.NAME := :NEW.PARAM_NAME;
  p.Save;    
end if;
-- Изменить тип можно только для параметра, определённого в сторонней модели.
if (   G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) 
    or G.notEQ(:NEW.TYPE_ID, :OLD.TYPE_ID))
 and :OLD.OBJ_ID is not null 
then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_iu'||
  'Изменить тип можно только у параметра, определённого в сторонней модели.!');
end if;
-- Если определено значение в виде строки, то используем его иначе создаём из 
-- отдельных полей.
if SP.G.notEQ(:NEW.VAL, :OLD.VAL) then
  if SP.G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) then
    V := SP.TVALUE(:NEW.TYPE_NAME, :NEW.VAL);
  else
    V := SP.TVALUE(:NEW.TYPE_ID, :NEW.VAL);
  end if; 
-- всё значение нулл  
elsif  :NEW.E_VAL is null and :NEW.N is null and :NEW.D is null and
         :NEW.S is null and :NEW.X is null and :NEW.Y is null 
then
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME);
  else
    V := SP.TVALUE(:NEW.TYPE_ID);
  end if;  
else
  if SP.G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) then
    V := SP.TVALUE(:NEW.TYPE_NAME,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  end if; 
end if;
-- Изменяем значение.
p.Save(V);
end;
/	
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_id
instead of delete on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
begin
  delete from SP.MODEL_OBJECT_PAR_S where ID = :OLD.ID;
end;
/
--
-- История параметров модели.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_ii
instead of insert on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
declare 
V SP.TVALUE; 
ROnly NUMBER;
CoROLE NUMBER;
MoROLE NUMBER;
ObjParID NUMBER;
TypeID NUMBER;
begin
  -- Если определено имя параметра, то находим его идентификатор.
  begin
    if :NEW.PAR_NAME is not null then
      select CO.EDIT_ROLE, cp.ID, CP.R_ONLY, CP.TYPE_ID, MO.EDIT_ROLE  
        into CoROLE, ObjParID, ROnly, TypeID, MoROLE  
        from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
        where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
          and MO.ID = :NEW.MOD_OBJ_ID
          and upper(CP.NAME) = :NEW.PAR_NAME;
    else
      select CO.EDIT_ROLE, cp.ID, CP.R_ONLY, CP.TYPE_ID, MO.EDIT_ROLE  
        into CoROLE, ObjParID, ROnly, TypeID, MoROLE  
        from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
        where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
          and MO.ID = :NEW.MOD_OBJ_ID
          and CP.ID = :NEW.OBJ_PAR_ID;
    end if; 
  exception
    when no_data_found then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        'Не найден объет модели '||:NEW.MOD_OBJ_ID||
        ' или параметр '||:NEW.PAR_NAME||'('||:NEW.MOD_OBJ_ID||')!');
  end;      
  -- Проверяем, что параметр должен сохранять историю.
  if ROnly not in(0,-1) then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
      'Параметр '||:NEW.PAR_NAME||'('||:NEW.MOD_OBJ_ID||
      ') у объета модели '||:NEW.MOD_OBJ_ID||' не должен сохранять историю!');
  end if;  
  -- Проверяем,что пользователь обладает правами администратора или
  -- он имеет права на редактирования объекта модели
  -- и объекта каталога - прообраза данного объекта модели.
  if not (TG.SP_Admin or  (    SP.HasUserEditRoleID(CoROLE) 
                           and (   SP.HasUserEditRoleID(MoROLE) 
                                or MoROLE is null )  )) 
  then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
      'Недостаточно привилегий для редактирования истории объета модели '||
      :NEW.MOD_OBJ_ID||'!');
  end if;
  -- Если определено универсальное значение, то используем его,
  -- иначе создаём из отдельных полей.
  if :NEW.VAL is null then
    begin
      V := SP.TVALUE(TypeID,
                    :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
    exception
      when others then
        d('('||:NEW.E_VAL||', '||:NEW.N||', '||:NEW.D||', '||:NEW.S||
          ', '||:NEW.X||', '||:NEW.Y||') '||SQLERRM,
           'SP.V_MODEL_OBJECT_PAR_STORIES_ii'); 
        raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
          'Ошибка ЗНАЧЕНИЯ'||SQLERRM||'!');                  
    end;     
  else
    -- Проверяем тип значения.
    if G.notEQ(TypeID, :NEW.Val.T) then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        'Тип Значения '||:NEW.Val.T||
        ' не совпадает с типом параметра '||TypeID||'!');                  
    end if; 
    V := :NEW.VAL;
  end if; 

  -- Добавляем историю параметру объекта.  
  insert into SP.MODEL_OBJECT_PAR_STORIES
  (
  MOD_OBJ_ID,
  OBJ_PAR_ID,
  TYPE_ID,
  E_VAL,
  N,
  D,
  S,
  X,
  Y,
  M_DATE,
  M_USER
  )
  values(
  :NEW.MOD_OBJ_ID,
  ObjParID,
  TypeID,
  V.E,
  V.N,
  V.D,
  V.S,
  V.X,
  V.Y,
  nvl(:NEW.M_DATE, sysdate),
  TG.UserName
  );
end;
/  
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_iu
instead of update on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
declare 
V SP.TVALUE;  
CoROLE NUMBER;
MoROLE NUMBER;
begin
  -- Если пользователь не администратор, то находим и проверяем Роли.
  if not TG.SP_Admin then
    select CO.EDIT_ROLE, MO.EDIT_ROLE  
      into CoROLE, MoROLE  
      from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
      where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
        and MO.ID = :OLD.MOD_OBJ_ID
        and CP.ID = :OLD.OBJ_PAR_ID;
    -- Проверяем, что пользователь обладает правами редактирования объекта
    -- модели и объекта каталога - прообраза данного объекта модели.
    if not  (    SP.HasUserEditRoleID(CoROLE) 
             and (   SP.HasUserEditRoleID(MoROLE) 
                  or MoROLE is null )  )  
    then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_iu'||
        'Недостаточно привилегий для редактирования истории объета модели '||
        :OLD.MOD_OBJ_ID||'!');
    end if;
  end if;    
  -- Если изменено универсальное значение, то используем его,
  -- иначе создаём из отдельных полей.
  if g.EQ(:NEW.VAL, :OLD.VAL) then
    begin
      V := SP.TVALUE(:OLD.Val.T,
                    :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
    exception
      when others then
        d('('||:NEW.E_VAL||', '||:NEW.N||', '||:NEW.D||', '||:NEW.S||
          ', '||:NEW.X||', '||:NEW.Y||') '||SQLERRM,
           'SP.V_MODEL_OBJECT_PAR_STORIES_ii'); 
        raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_iu'||
          'Ошибка ЗНАЧЕНИЯ'||SQLERRM||'!');                  
    end;     
  else
    -- Проверяем тип значения.
    if G.notEQ(:OLD.Val.T, :NEW.Val.T) then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        'Тип Значения '||:NEW.Val.T||
        ' не совпадает с типом параметра '||:OLD.Val.T||'!');                  
    end if; 
    V := :NEW.VAL;
  end if; 
  update SP.MODEL_OBJECT_PAR_STORIES set 
    E_VAL = V.E,
    N = V.N,
    D = V.D,
    S = V.S,
    X = V.X,
    Y = V.Y,
    M_DATE = nvl(:NEW.M_DATE, sysdate),
    M_USER = TG.UserName
    where ID = :OLD.ID; 
end;
/  

--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_id
instead of delete on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
begin
  delete from SP.MODEL_OBJECT_PAR_STORIES where ID = :OLD.ID;
--  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_id'||
--        'Удаление истории не предусмотрено!');                  
end;
/  

--*****************************************************************************
  
-- end of File 

-- SP GROUPS triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013  
-- update 07.06.2013 02.10.2013 11.10.2013 24.10.2013 14.06.2014 24.08.2014
--        25.08.2014 26.08.2014 08.09.2014
--*****************************************************************************


-- Группы. 
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.UPDATED_GROUPS_bi
BEFORE INSERT ON SP.UPDATED_GROUPS
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_GROUPS;
  IF tmpVar=0 AND SP.TG.AfterUpdateGroups THEN
    SP.TG.AfterUpdateGroups:= FALSE;
    d('SP.TG.AfterUpdateGroups:= false;','ERROR UPDATED_GROUPS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_GROUPS_bi
BEFORE INSERT ON SP.DELETED_GROUPS
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_GROUPS;
  IF tmpVar=0 AND SP.TG.AfterDeleteGroups THEN
    SP.TG.AfterDeleteGroups:= FALSE;
    d('SP.TG.AfterDeleteGroups:= false;','ERROR DELETED_GROUPS_bi');
  END IF;
END;
/
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_bir
BEFORE INSERT ON SP.GROUPS
FOR EACH ROW
--(SP-GROUPS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  -- Только администратор может присвоить роль, которую не имеет сам.
  if not TG.SP_Admin then
    if not SP.HasUserRoleID(:NEW.EDIT_ROLE) then
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bir.'||
        ' Отсутствует или недоступна роль!');
    end if;
    -- Если новая роль нулл, то устанавливаем роль пользователя SP.
    if :NEW.EDIT_ROLE is null then
      :NEW.EDIT_ROLE:= G.USER_ROLE;
    end if;
  end if;  
  SELECT SP.GROUP_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  :NEW.NAME := utrim(:NEW.NAME);
  if :NEW.M_DATE is null then :NEW.M_DATE := sysdate; end if;
  if :NEW.M_USER is null then :NEW.M_USER := tg.UserName; end if;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_ai
AFTER INSERT ON SP.GROUPS
--(SP-GROUPS.trg)
BEGIN 
  SP.GRAPH2TREE.Reset; 
END;
/
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_bur
BEFORE UPDATE ON SP.GROUPS
FOR EACH ROW
--(SP-GROUPS.trg)
BEGIN
  IF ReplSession THEN return; END IF;
  :NEW.ID := :OLD.ID;
  :NEW.NAME := utrim(:NEW.NAME);
  -- Нельзя редактировать, если нет роли редактирования группы.
  -- Только администратор может присвоить роль, которую не имеет сам.
  if not TG.SP_Admin then
    if   not SP.HasUserRoleID(:OLD.EDIT_ROLE)
      or not SP.HasUserRoleID(:NEW.EDIT_ROLE)
      or (:NEW.EDIT_ROLE is null)
      or (:OLD.EDIT_ROLE is null)
    then
      TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bur.'||
        ' Отсутствует или недоступна роль!');
    end if;
  end if;  
  if (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) then 
    :NEW.M_DATE := sysdate; 
  end if;
  if (:NEW.M_USER is null) or (:NEW.M_USER = :OLD.M_USER) then 
    :NEW.M_USER := tg.UserName;
  end if;
  -- Нельзя добавить прозвище группе у которой есть состав.
  IF :NEW.ALIAS is not null THEN
	  -- Проверку производим в табличном триггере.
	  insert into SP.UPDATED_GROUPS values 
	    (:NEW.ID, :NEW.IM_ID, :NEW.NAME, :NEW.COMMENTS, :NEW.ALIAS,
       :NEW.EDIT_ROLE, :NEW.M_DATE, :NEW.M_USER,
	     :OLD.ID, :OLD.IM_ID, :OLD.NAME, :OLD.COMMENTS, :OLD.ALIAS,
       :OLD.EDIT_ROLE, :OLD.M_DATE, :OLD.M_USER);
  END IF;   
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_au
AFTER UPDATE ON SP.GROUPS
--(SP-GROUPS.trg)
DECLARE
tmpVar NUMBER;
Name SP.COMMANDS.COMMENTS%TYPE;
rec SP.UPDATED_GROUPS%ROWTYPE;
BEGIN
  IF ReplSession THEN return; END IF;
  IF TG.AfterUpdateGroups THEN return; END IF;
  TG.AfterUpdateGroups:= TRUE;
  --d('table тригер','Groups_au');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_GROUPS WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'Groups_au');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','Groups_au');
        EXIT;
    END;
    BEGIN
      -- Если у группы есть прозвище, то не может быть детей.
      select count(*) into tmpVar from SP.REL_S 
        where GR = rec.OLD_ID;
      if tmpVar >0 then
        -- Находим имя объекта модели и вызываем ошибку.
        select o.FULL_NAME into Name 
          from SP.V_MODEL_OBJECTS o
          where o.ID = rec.NEW_ALIAS;
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_au.'||
           ' Группа '||Name||' является прозвищем объекта'
           ||' и не может иметь состав!');
      end if;    
	  END;  
    -- Удаляем обработанную запись.
    --d('delete current','Groups_aг');
    DELETE FROM SP.UPDATED_GROUPS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  TG.AfterUpdateGroups := FALSE;
  SP.GRAPH2TREE.Reset; 
END;
/
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_bdr
BEFORE DELETE ON SP.GROUPS
FOR EACH ROW
--(SP-GROUPS.trg)
BEGIN
  IF ReplSession THEN return; END IF;
  -- Нельзя удалять группы, если идентификаторы меньше "100".
  IF (:OLD.ID < 100)then
	  SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bdr. Данные заблокированы!'
	    || :OLD.NAME);
  END IF;
  -- Нельзя удалить группу, если нет её роли.
  if not TG.SP_Admin then
    if not SP.HasUserRoleID(:OLD.EDIT_ROLE) or (:OLD.EDIT_ROLE is null) then
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bdr.'||
        ' Недостаточно привилегий');
    end if;
  end if;  
  -- В табличном триггере проверяем и запрещаем удаление группы,
  -- используемой свойством объекта типа ссылка на группу.
  insert into SP.DELETED_GROUPS values 
    (:OLD.ID, :OLD.IM_ID, :OLD.NAME, :OLD.COMMENTS, :OLD.ALIAS, :OLD.EDIT_ROLE,
     :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_DELETE----------------------------------------------------------------
--
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GROUPS_ad
AFTER DELETE ON SP.GROUPS
--(SP-GROUPS.trg)
DECLARE
tmpVar NUMBER;
Name SP.COMMANDS.COMMENTS%TYPE;
rec SP.DELETED_GROUPS%ROWTYPE;
BEGIN
  IF ReplSession THEN return; END IF;
  IF TG.AfterDeleteGroups THEN return; END IF;
  TG.AfterDeleteGroups:= TRUE;
  --d('table тригер','Groups_ad');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_GROUPS WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'Groups_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','Groups_ad');
        EXIT;
    END;
    BEGIN
      -- Нельзя удалять группу, если на неё есть ссылка.
      -- 1 - для объекта каталога.
      select count(*) into tmpVar from SP.OBJECT_PAR_S 
        where TYPE_ID = G.TGROUP
          and N = rec.OLD_ID;
      if tmpVar >0 then
        -- Находим имя католожного объекта и вызываем ошибку.
        select g.Name||'.'||o.Name into Name 
          from SP.OBJECT_PAR_S p, SP.OBJECTS o, SP.GROUPS g
	        where p.TYPE_ID = G.TGROUP
	          and p.N = rec.OLD_ID
	          and p.OBJ_ID = o.ID
	          and g.ID = o.GROUP_ID;
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_ad.'||
          ' Невозможно удалить группу, ссылка на которую является свойством'
          ||' по умолчанию для объекта каталога '||Name||' !');
      end if;    
      -- 2 - для объекта Модели.
      select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
        where TYPE_ID = G.TGROUP
          and N = rec.OLD_ID;
      if tmpVar >0 then
        -- Находим имя полное имя объекта модели и вызываем ошибку.
        select MODEL_NAME||'=>'||FULL_NAME into Name 
          from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S p
         where p.TYPE_ID = G.TGROUP
          and p.N = rec.OLD_ID
          and p.MOD_OBJ_ID = o.ID;
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_ad.'||
           ' Невозможно удалить группу, ссылка на которую является свойством'
           ||' объекта модели '||Name||' !');
      end if;    
	  END;  
    -- Удаляем обработанную запись.
    --d('delete current','Groups_ad');
    DELETE FROM SP.DELETED_GROUPS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  TG.AfterDeleteGroups := FALSE;
  SP.GRAPH2TREE.Reset; 
END;
/

--*****************************************************************************

-- Связи.

--BEFORE_INSERT_TABLE----------------------------------------------------------
--
-- CREATE OR REPLACE TRIGGER SP.INSERTED_REL_S_bi
-- BEFORE INSERT ON SP.INSERTED_REL_S
-- --(SP-GROUPS.trg)
-- DECLARE
--   tmpVar NUMBER;
-- BEGIN
--   IF ReplSession THEN RETURN; END IF;
--   SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_REL_S;
--   IF tmpVar=0 AND SP.TG.AfterInsertRel_s THEN
--     SP.TG.AfterInsertRel_s:= FALSE;
--     d('SP.TG.AfterInsertRel_s:= false;','ERROR INSERTED_REL_S_bi');
--   END IF;
-- END;
-- /
--
CREATE OR REPLACE TRIGGER SP.UPDATED_REL_S_bi
BEFORE INSERT ON SP.UPDATED_REL_S
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_REL_S;
  IF tmpVar=0 AND SP.TG.AfterUpdateRel_s THEN
    SP.TG.AfterUpdateRel_s:= FALSE;
    d('SP.TG.AfterUpdateRel_s:= false;','ERROR UPDATED_REL_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_REL_S_bi
BEFORE INSERT ON SP.DELETED_REL_S
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_REL_S;
  IF tmpVar=0 AND SP.TG.AfterDeleteRel_s THEN
    SP.TG.AfterDeleteRel_s:= FALSE;
    d('SP.TG.AfterDeleteRel_s:= false;','ERROR DELETED_REL_S_bi');
  END IF;
END;
/
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_bir
BEFORE INSERT ON SP.REL_S
FOR EACH ROW
--(SP-GROUPS.trg)
DECLARE
tmpVar NUMBER;
AliasRef NUMBER;
NewState NUMBER;
GName SP.GROUPS.NAME%type;
BEGIN
  IF ReplSession THEN return; END IF;
  begin
    select EDIT_ROLE, ALIAS, NAME into tmpVar, AliasRef, GName from SP.GROUPS 
      where ID=:NEW.GR;
  exception
    when no_data_found then
     SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bir.'||
      ' Отсутствует группа '||:NEW.GR||'!');
  end;
  -- Если у группы присутствует прозвище, то вызываем ошибку.
  if AliasRef is not null then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bir.'||
      ' Группа '||GName||
      ' является прозвищем объекта и не может иметь состав!');
  end if;
  -- Если пользователь не администратор,
  -- то пользователь должен иметь роль редактирования группы,
  -- получающей потомка.
  if not TG.SP_Admin then
    if not SP.HasUserRoleID(tmpVar) or (tmpVar is null) then
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.GROUPS_bir.'||
        ' Недостаточно привилегий для расширения состава группы '||
        GName||'!');
    end if;
  end if;  
  SELECT SP.GROUP_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
    IF :NEW.PREV_ID IS NULL THEN
    -- Если у группы отсутствует ссылка на предыдущую группу, имеющую того же
    -- родителя, то вставляем группу в конец ветки, присваивая ей ссылку на
    -- последнюю группу, имеющую того же родителя.
    BEGIN
	    SELECT ID INTO :NEW.PREV_ID FROM SP.REL_S 
           WHERE GR=:NEW.GR
             AND CONNECT_BY_ISLEAF=1
	         START WITH PREV_ID IS NULL
	         CONNECT BY PREV_ID = PRIOR ID;
    EXCEPTION
      -- Если ничего не нашли - значит это единственная дочка у 
      -- своего родителя.
      WHEN NO_DATA_FOUND THEN NULL;
    END; 
  ELSE   
	  -- Проверяем, что предыдущая группа принадлежит тому же родителю что и 
    -- добавляемая.
    SELECT GR INTO tmpVar FROM SP.REL_S 
        WHERE ID = :NEW.PREV_ID;
    IF tmpVar != :NEW.GR THEN
		  SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.REL_S_bir.'||
      ' Ссылка на предыдущую группу того же родителя,'||
      ' принадлежащую другому родителю!');
    END IF;    
  END IF;
  if :NEW.M_DATE is null then 
    :NEW.M_DATE := sysdate; 
  end if;
  if :NEW.M_USER is null then 
    :NEW.M_USER := tg.UserName;
  end if;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_ai
AFTER INSERT ON SP.REL_S
--(SP-GROUPS.trg)
BEGIN 
  SP.GRAPH2TREE.Reset; 
END;
/
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_bur
BEFORE UPDATE ON SP.REL_S
FOR EACH ROW
--(SP-GROUPS.trg)
BEGIN
  IF ReplSession THEN return; END IF;
  :NEW.ID:=:OLD.ID;
  if :NEW.GR != :OLD.GR then 
	  -- нельзя редактировать направление связи.
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
	    'REL_S_bur. Нельзя редактировать направление связи,'||
	    ' можно только удалить или вставить!');
  end if;    
  -- В табличном триггере выполняем следующее.
  -- Проверяем, что только администратор или пользователь,
  -- имеющий права редактирования группы имеет право изменять группу.
  if (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) then 
    :NEW.M_DATE := sysdate; 
  end if;
  if (:NEW.M_USER is null) or (:NEW.M_USER = :OLD.M_USER) then 
    :NEW.M_USER := tg.UserName;
  end if;
  INSERT INTO SP.UPDATED_REL_S 
    VALUES(:NEW.ID, :NEW.GR, :NEW.INC, :NEW.PREV_ID, :NEW.R_TYPE,
           :NEW.M_DATE, :NEW.M_USER,
           :OLD.ID, :OLD.GR, :OLD.INC, :OLD.PREV_ID, :OLD.R_TYPE,
           :OLD.M_DATE,:OLD.M_USER);
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_au
AFTER UPDATE ON SP.REL_S
--(SP-GROUPS.trg)
DECLARE
	rec SP.UPDATED_REL_S%ROWTYPE;
  GName SP.GROUPS.NAME%TYPE;
  EditRole NUMBER;
  tmpVar NUMBER;
  err BOOLEAN;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateRel_s
  THEN
    --d('table тригер => return ','REL_S_au');
    RETURN;
  END IF;
  SP.TG.AfterUpdateRel_s:= TRUE;
  --d('table тригер!!!','REL_S_au');
  LOOP
    BEGIN
      SELECT * INTO rec
        FROM (SELECT * FROM SP.UPDATED_REL_S) WHERE ROWNUM=1;
      --d('execute','REL_S_au');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        --d('exit','REL_S_au');
        EXIT;
    END;
    --d('select NAME','REL_S_au');
    -- Если не производится операция удаления группы, то проверяем, 
    -- что имеем право на изменение порядка следования групп в списке родителя.
    begin
      SELECT NAME, EDIT_ROLE INTO GName, EditRole FROM SP.GROUPS
		  WHERE ID=rec.OLD_GR;
		  -- Редактировать имет право администратор.
		  -- Если роль редактирования объекта не нулл, то редактировать объект
		  -- может пользователь, имеющий роль редактирования объекта.
			IF NOT SP.HasUserEditRoleID(EditRole) THEN
				SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,'SP.REL_S_au.'||
	        ' Недостаточно привелегий для изменения группы: '||GName||'!');
	    END IF;
		  -- Если изменёна ссылка на предыдущую группу в списке одного родителя,
      -- то проверяем, что предыдущая группа принадлежит тому же родителю,
      -- что и текущая.
	    IF     G.notEQ(rec.NEW_PREV_ID,rec.OLD_PREV_ID) 
	      AND (rec.NEW_PREV_ID IS NOT NULL)
	    THEN
	      --d('select GR','REL_S_au');
		    SELECT GR INTO tmpVar FROM SP.REL_S  WHERE ID = rec.NEW_PREV_ID;
	      IF tmpVar != rec.NEW_GR THEN
				  SP.TG.ResetFlags;
	        RAISE_APPLICATION_ERROR(-20033,'SP.REL_S_au.'||
	          ' Группа на которую установлена ссылка, как на предыдущую '||
            'группу в списке одного родителя, имеет другого родителя!');
	      END IF;
	    END IF;
    exception
      when no_data_found then null;  
    end;
    -- Удаляем обработанную запись.
    --d('Удаляем обработанную запись','REL_S_au');
    DELETE FROM SP.UPDATED_REL_S WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateRel_s := FALSE;
  --d('end','REL_S_au');
 END;
/
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_bdr
BEFORE DELETE ON SP.REL_S
FOR EACH ROW
--(SP-GROUPS.trg)
BEGIN
  IF ReplSession THEN return; END IF;
	-- Нельзя удалить связь, если её идентификатор меньше "100".
	if  :OLD.ID < 100 then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.REL_S_bdr. '||
     'Group with ID: '||to_char(:OLD.ID)||' blocked!' );
	end if;
END;
/

--AFTER_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_adr
AFTER DELETE ON SP.REL_S
FOR EACH ROW
--(SP-GROUPS.trg)
BEGIN
  IF ReplSession THEN return; END IF;
  -- Если удаляется связь между группами, то проверяем имеет ли пользователь
  -- соответствующие права в табличном триггере.
  IF :OLD.INC is not null THEN
    insert into SP.DELETED_REL_S values 
      (:OLD.ID, :OLD.GR, :OLD.INC, :OLD.PREV_ID, :OLD.R_TYPE,
       :OLD.M_DATE, :OLD.M_USER);
  END IF;  
END;
/

--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.REL_S_ad
AFTER DELETE ON SP.REL_S
--(SP-GROUPS.trg)
DECLARE
rec SP.DELETED_REL_S%ROWTYPE;
ERole NUMBER;
Cycle_ERR EXCEPTION;
pragma exception_init(Cycle_ERR,-01436);
BEGIN
  IF ReplSession THEN return; END IF;
  IF TG.AfterDeleteRel_s THEN return; END IF;
  TG.AfterDeleteRel_s:= TRUE;
  --d('table тригер','REL_S_ad');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_REL_S WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'REL_S_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','REL_S_ad');
        EXIT;
    END;
    BEGIN
	    select EDIT_ROLE into ERole from SP.GROUPS
	      where ID=rec.OLD_GR;
	    -- Нельзя удалить связь между группами, если нет роли редактирования
      -- родительской группы.
	    if not TG.SP_Admin then
	      if not SP.HasUserRoleID(ERole) or (ERole is null) then
		      begin
			      raise Cycle_ERR; --!!! это лишнее проверить
			    exception
		        when Cycle_ERR THEN
		          SP.TG.ResetFlags;
	            d('Отсутствует или недоступна роль '||to_char(ERole)||
	              ' для группы '||to_char(rec.OLD_GR)||'!','ERROR SP.REL_S_ad');
	            raise_application_error (-20033, 'SP.GROUPS_ad.'||
	             ' Недостаточно привилегий для удаления связи!');
			    end;
	      end if;
	    end if; 
    END;  
    -- Удаляем обработанную запись.
    --d('delete current','REL_S_ad');
    DELETE FROM SP.DELETED_REL_S WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.GRAPH2TREE.Reset; 
  TG.AfterDeleteRel_s := FALSE;
END;
/

--*****************************************************************************

-- SP Model tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 24.08.2010
-- update 30.08.2010 23.09.2010 15.10.2010 17.11.2010 11.01.2011 05.04.2011
--        11.11.2011 03.04.2013 14.05.2013 25.08.2013 16.01.2014 13.02.2014
--        14.02.2014 14.06.2014 16.06.2014 24.08.2014-26.08.2014 11.11.2014
--        15.11.2014 25.11.2014 17.03.2015 31.03.2015 01.04.2015 10.07.2015
--        24.08.2015 09.11.2015 25.02.2016 28.03.2016 30.03.2016 05.07.2016
--        06.07.2016 22.07.2016 19.09.2016-20.09.2016 07.10.2016 12.10.2016
--        09.11.2016 22.11.2016 28.02.2017 07.03.2017 13.03.2017 02.04.2017
--        10.04.2017 17.04.2017 25.04.2017 02.05.2017 09.06.2017 29.08.2017
--        12.09.2017 19.09.2017 28.12.2017 06.04.2018 29.06.2018 28.01.2019
--        05.06.2019 01.12.2020 26.12.2020 24.01.2021 14.03.2021 07.04.202
--        08.04.2021 11.04.2021 21.04.2021 07.07.2021-08.07.2021 15.07.2021
--        04.09.2021  

--*****************************************************************************

-- Модели.
--BEFORE_INSERT_TABLE---------------------------------------------------------
--BEFORE_INSERT----------------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.MODELS_bir
BEFORE INSERT ON SP.MODELS
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.MODEL_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  :NEW.NAME := trim(:NEW.NAME);
  if instr(:NEW.NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bir. Сочетание "=>" не допустимо в имени модели, так как оно используется для разделения имени модели и имени объекта!');
  end if;
  IF (NOT SP.TG.SP_Admin) and (:NEW.PERSISTENT = 0) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bir.'||
      ' Только администратор может добавить сохраняемую модель!');
  END IF;          
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODELS_bur
BEFORE UPDATE ON SP.MODELS
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  :NEW.ID := :OLD.ID;
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bur. Нельзя редактировать предопределенные модели!');
  END IF;
  IF NOT SP.TG.SP_Admin THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bur.'||
      ' Только администратор может редактировать модели!');
  END IF;          
  :NEW.NAME := trim(:NEW.NAME);
  if instr(:NEW.NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bur. Сочетание "=>" не допустимо в имени модели, так как оно используется для разделения имени модели и имени объекта!');
  end if;    
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODELS_bdr
BEFORE DELETE ON SP.MODELS
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bdr. Нельзя удалять предопределенные модели!');
  END IF;
  IF NOT SP.TG.SP_Admin THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bdr.'||
      ' Только администратор может удалять модели!');
  END IF;          
  -- Запрещакм удалять модель, если у параметров объектов каталога,
  -- есть ссылки на модель.
  select count(*) into tmpVar from SP.OBJECT_PAR_S 
    where TYPE_ID = G.TRel
      and N = - :OLD.ID;
  IF tmpVar > 0 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bdr. Нельзя удалять модель,'||
      ' на которую есть ссылки у параметров объектов каталога!');
  END IF;
  -- Устанавливаем признак удаления модели
  SP.TG.ModelDeleting := :OLD.ID;
	-- Разрешаем каскадное удаление параметров объектов.
  SP.TG.ModObjParDeleting := TRUE;
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODELS_ad
AFTER DELETE ON SP.MODELS
--(SP-MODEL.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SP.TG.ModObjParDeleting :=FALSE;
  SP.TG.ModelDeleting := null;
END;
/
--*****************************************************************************
-- Созданные объекты.
-- BEFORE_INSERT_TABLE----------------------------------------
CREATE OR REPLACE TRIGGER SP.INSERTED_MOD_OBJECTS_bi
BEFORE INSERT ON SP.INSERTED_MOD_OBJECTS
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_MOD_OBJECTS;
  IF tmpVar=0 AND SP.TG.AfterInsertModObjects THEN 
    SP.TG.AfterInsertModObjects:= FALSE;
    d('SP.TG.AfterInsertCRObjects:= false;','ERROR INSERTED_MOD_OBJECTS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_MOD_OBJECTS_bi
BEFORE INSERT ON SP.UPDATED_MOD_OBJECTS
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_MOD_OBJECTS;
  IF tmpVar=0 AND SP.TG.AfterUpdateModObjects THEN 
    SP.TG.AfterUpdateModObjects:= FALSE;
    d('SP.TG.AfterUpdateModObjects:= false;','ERROR UPDATED_MOD_OBJECTS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_MOD_OBJECTS_bi
BEFORE INSERT ON SP.DELETED_MOD_OBJECTS
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_MOD_OBJECTS;
  IF tmpVar=0 AND SP.TG.AfterDeleteModObjects THEN 
    SP.TG.AfterDeleteModObjects:= FALSE;
    d('SP.TG.AfterDeleteModObjects:= false;','ERROR DELETED_MOD_OBJECTS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_bir
BEFORE INSERT ON SP.MODEL_OBJECTS
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.MOD_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- Добавлять объект без ссылки на объект можно только в режиме импорта.
  -- Эта ссылка может стать нулл только при удалении объекта из каталога.
  IF (:NEW.OBJ_ID IS NULL) AND NOT SP.TG.ImportDATA THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bir.'||
      ' Нельзя добавлять объект '||:NEW.MOD_OBJ_NAME||
      ' без ссылки на объект каталога!');
  END IF;
  -- 
  if instr(:NEW.MOD_OBJ_NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bir. Сочетание "=>" не допустимо в имени объекта модели, так как оно используется для разделения имени модели и имени объекта!');
  end if;    
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- Для локальных моделей, присваиваем OID, если он не определён.
  IF SP.TG.CurModel_LOCAL and (:NEW.OID is null) THEN 
    :NEW.OID := SYS_GUID; 
  END IF;
  -- Пользователь, должен иметь роли, которые назначает.
  IF  not SP.HasUserRoleID(:NEW.USING_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bir.'||
      ' недоступна роль '||:NEW.USING_ROLE||' при создании объекта:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- Пользователь, должен иметь роли, которые назначает.
  IF  not SP.HasUserRoleID(:NEW.EDIT_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bir.'||
      ' недоступна роль '||:NEW.EDIT_ROLE||' при создании объекта:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF; 
  -- Обрезаем пробелы и концы строк в имени объекта. 
  :NEW.MOD_OBJ_NAME := trim(:NEW.MOD_OBJ_NAME);
  :NEW.MOD_OBJ_NAME := replace(:NEW.MOD_OBJ_NAME, chr(10));
  -- Если разрешена проверка и у объекта есть родитель,
  -- то передаём данные в табличный триггер для проверки,
  -- что объект и его родитель принадлежат одной модели.
  -- Зацикливание по иерархии невозможно,
  -- поскольку на вновь добавленный объект ещё нет ссылок.
  IF SP.TG.Check_ValEnabled THEN
	  INSERT INTO SP.INSERTED_MOD_OBJECTS
	  VALUES(:NEW.ID, :NEW.MODEL_ID, :NEW.MOD_OBJ_NAME, :NEW.OID,
		       :NEW.OBJ_ID,:NEW.PARENT_MOD_OBJ_ID,
           :NEW.USING_ROLE, :NEW.EDIT_ROLE,
           :NEW.M_DATE, :NEW.M_USER, :NEW.TO_DEL);
  END IF;
END;
/

--AFTER_INSERT-----------------------------------------------------------------

--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_ai
AFTER INSERT ON SP.MODEL_OBJECTS
--(SP-MODEL.trg)
DECLARE
	rec SP.INSERTED_MOD_OBJECTS%ROWTYPE;
  tmpVar NUMBER;
  ObjName SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE; 
  ModelName SP.MODELS.NAME%TYPE;
  ModelID NUMBER; 
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertModObjects THEN RETURN; END IF;
  SP.TG.AfterInsertModObjects:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_MOD_OBJECTS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    if rec.NEW_PARENT_MOD_OBJ_ID is not null then
  	  -- Находим имя и модель объекта родителя.
      SELECT o.MOD_OBJ_NAME, m.NAME, o.MODEL_ID 
        INTO ObjName, ModelName, ModelID 
        FROM SP.MODEL_OBJECTS o, SP.MODELS m
        WHERE o.ID=rec.NEW_PARENT_MOD_OBJ_ID
          AND m.ID=o.MODEL_ID;
  	  -- Проверяем, что модели совпадают.
      IF g.notEQ(ModelID, rec.NEW_MODEL_ID) THEN
        SP.TG.ResetFlags;
  	    RAISE_APPLICATION_ERROR(-20033,
  	      'SP.MODEL_OBJECT_S_ai.'||
  	      ' Родительский объект '||ObjName||
  	      ' принадлежит другой модели '||ModelName||'!');
      END IF;
	end if;
		-- Проверяем типы объектов. 
		SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS WHERE ID = rec.NEW_OBJ_ID;
		IF tmpVar != 0 THEN
		  RAISE_APPLICATION_ERROR(-20033,
	      'SP.MODEL_OBJECT_S_ai.'||' Объект должен быть простого типа!');
		END IF;
		--
    -- Добавляем или изменяем
    DELETE FROM SP.INSERTED_MOD_OBJECTS up WHERE up.NEW_ID=rec.NEW_ID;
	END LOOP;
  SP.TG.AfterInsertModObjects:= FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_bur
BEFORE UPDATE ON SP.MODEL_OBJECTS
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  Modified BOOLEAN;
  em# VARCHAR2(4000);
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  IF :OLD.OID IS NOT NULL and :NEW.OID is null THEN 
    :NEW.OID := :OLD.OID;  
  END IF;
  -- Если не установлен флаг насильственного изменения OID,
  -- то Объекту модели можно добавить OID, если он отсутствовал,
  -- но нельзя его изменять.
  IF not SP.TG.ForceOID THEN
    IF :OLD.OID IS NOT NULL and G.notEQ(:NEW.OID,:OLD.OID) THEN 
      em#:='Попытка произвести подмену OID у объекта '
         ||' ID='||:OLD.ID||' [old => new] OID: '||:OLD.OID||' => '||:NEW.OID
         ||', MOD_OBJ_NAME: '||:OLD.MOD_OBJ_NAME||' => '||:NEW.MOD_OBJ_NAME
         ||', OBJ_ID: '||:OLD.OBJ_ID||' => '||:NEW.OBJ_ID
         ||', PARENT_MOD_OBJ_ID: '||:OLD.PARENT_MOD_OBJ_ID
                                          ||' => '||:NEW.PARENT_MOD_OBJ_ID
         ||' !';

      d(em#,'SP.MODEL_OBJECT_S_bur.');
      RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECT_S_bur. '||em#);
    --  :NEW.OID := :OLD.OID;
    END IF;
  END IF;
  :NEW.MODEL_ID := :OLD.MODEL_ID;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- Для локальных моделей, присваиваем OID, если он не определён.
  IF SP.TG.CurModel_LOCAL and (:OLD.OID is null)THEN 
    :NEW.OID := SYS_GUID; 
  END IF;
  -- Обрезаем пробелы и концы строк в имени объекта. 
  :NEW.MOD_OBJ_NAME := trim(:NEW.MOD_OBJ_NAME);
  :NEW.MOD_OBJ_NAME := replace(:NEW.MOD_OBJ_NAME, chr(10));
  if instr(:NEW.MOD_OBJ_NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur. Сочетание "=>" не допустимо в имени объекта модели, так как оно используется для разделения имени модели и имени объекта!');
  end if;    
  -- Если  исключительно изменён только признак изменения, то выход.
  IF g.upEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME)
    AND g.EQ(:NEW.OBJ_ID, :OLD.OBJ_ID)
    AND g.EQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID)
  THEN
    RETURN;
  END IF;      
  Modified := FALSE;
  -- Редактировать имет право администратор или,
  -- если его роль редактирования нулл.
  -- Если роль редактирования объекта не нулл, то редактировать объект
  -- может пользователь, имеющий такую роль.
  IF NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
    THEN
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur. '||
     'Недостаточно привелегий для изменения объекта: '||:OLD.MOD_OBJ_NAME||'!');
  END IF;
  -- Пользователь, должен иметь роли, которые назначает.
  IF  not SP.HasUserRoleID(:NEW.USING_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur.'||
      ' недоступна роль '||:NEW.USING_ROLE||' при создании объекта:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- Пользователь, должен иметь роли, которые назначает.
  IF  not SP.HasUserRoleID(:NEW.EDIT_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur.'||
      ' недоступна роль '||:NEW.EDIT_ROLE||' при создании объекта:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- Только администратор может убрать роли доступа к модели.
  IF NOT SP.TG.SP_Admin 
    AND (  (:NEW.USING_ROLE is null and :OLD.USING_ROLE is not null) 
         or(:NEW.EDIT_ROLE is null and :OLD.EDIT_ROLE is not null)
        ) 
  THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur.'||
  ' Только администратор может снять все ораничения доступа к объекту модели!');
  END IF;          
  -- Только администратор может изменять принадлежность к модели.
  IF NOT SP.TG.SP_Admin AND (:NEW.MODEL_ID !=:OLD.MODEL_ID) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur.'||
      ' Только администратор может изменить принадлежность объекта к модели!');
  END IF;          
  -- Нельзя удалить ссылку на объект,
  -- и одновременно изменить родителя объекта.
  -- Если пропала ссылка на объект, и у объекта отсутствует родитель,
  -- то устанавливаем признак изменено и выходим из триггера,
  -- иначе устанавливаем флаг изменения.
  IF :NEW.OBJ_ID IS NULL AND :OLD.OBJ_ID IS NOT NULL
  THEN
    IF g.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.MODEL_OBJECT_S_bur.'||
        ' Нельзя удалить ссылку на объект,'||
        ' и одновременно изменить родителя объекта.!');
    END IF;
  END IF;    
  -- При изменении родителя, модели или имени объекта сбрасываем КЭШ 
  -- для пути объекта и его дочерних объектов.
  IF   g.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID)
    or (:NEW.MODEL_ID != :OLD.MODEL_ID)
    or g.notEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME)
  THEN
    update SP.MODEL_OBJECT_PATHS set invalid = 1 
      where ID in
      (
        SELECT ID FROM SP.MODEL_OBJECT_PATHS
                   START WITH ID = :OLD.ID
                   CONNECT BY  PARENT_MOD_OBJ_ID = PRIOR ID
       );
  END IF;
  -- Если установлен флаг изменения, а также если изменился родитель объекта,
  -- то передаём данные в табличный триггер.
  -- При изменении родителя имени или модели сбрасываем КЭШ для пути объекта и
  -- его детей.
  -- При изменении родителя объекта проверяем не произошло ли зацикливание по
  -- иерархии объектов, а так же, что объект и его родитель принадлежат одной
  -- модели.
  -- При исчезновении ссылки на команду или объект каталога устанавливаем
  -- признак изменения самого старшего родителя данного объекта.
  IF Modified OR (g.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID))
  THEN
	  INSERT INTO SP.UPDATED_MOD_OBJECTS
	    VALUES(:NEW.ID, :NEW.MODEL_ID, :NEW.MOD_OBJ_NAME, :NEW.OID,
             :NEW.OBJ_ID, :NEW.PARENT_MOD_OBJ_ID, 
             :NEW.USING_ROLE,:NEW.EDIT_ROLE,
             :NEW.M_DATE, :NEW.M_USER, :NEW.TO_DEL,
		         :OLD.ID, :OLD.MODEL_ID, :OLD.MOD_OBJ_NAME, :OLD.OID,
             :OLD.OBJ_ID, :OLD.PARENT_MOD_OBJ_ID, 
             :OLD.USING_ROLE,:OLD.EDIT_ROLE,
             :OLD.M_DATE, :OLD.M_USER, :NEW.TO_DEL);      
  END IF;
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_aur
AFTER UPDATE ON SP.MODEL_OBJECTS
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  IF SP.TG.ImportDATA THEN RETURN; END IF;
  
  -- Добавляем значения псевдопараметров в историю свойств параметров объекта.
  
--  d('MOD_OBJ_ID: '||:NEW.OBJ_ID||
--    ' :NEW.MOD_OBJ_NAME :'||:NEW.MOD_OBJ_NAME,
--          'SP.MODEL_OBJECT_PAR_S_ai');


-- NAME
  IF G.notUpEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME) THEN
    INSERT INTO SP.MODEL_OBJECT_PAR_STORIES
    (
    MOD_OBJ_ID, OBJ_PAR_ID,
    TYPE_ID,
    S,
    M_DATE, M_USER
    )
    VALUES
    (
    :OLD.ID, -1,
    G.TSTR4000,
    :OLD.MOD_OBJ_NAME, 
    :OLD.M_DATE,:OLD.M_USER
    );
  END IF;
  --PARENT 
  IF G.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) THEN
    INSERT INTO SP.MODEL_OBJECT_PAR_STORIES
    (
    MOD_OBJ_ID, OBJ_PAR_ID,
    TYPE_ID,
    N,
    M_DATE, M_USER
    )
    VALUES
    (
    :OLD.ID, -2,
    G.TREL,
    :OLD.PARENT_MOD_OBJ_ID,
    :OLD.M_DATE,:OLD.M_USER
    );
  END IF;
  --USING_ROLE 
  IF G.notEQ(:NEW.USING_ROLE, :OLD.USING_ROLE) THEN
    INSERT INTO SP.MODEL_OBJECT_PAR_STORIES
    (
    MOD_OBJ_ID, OBJ_PAR_ID,
    TYPE_ID,
    N,
    M_DATE, M_USER
    )
    VALUES
    (
    :OLD.ID, -3,
    G.TROLE,
    :OLD.USING_ROLE,
    :OLD.M_DATE,:OLD.M_USER
    ); 
  END IF;
  --USING_ROLE 
  IF G.notEQ(:NEW.EDIT_ROLE, :OLD.EDIT_ROLE) THEN
    INSERT INTO SP.MODEL_OBJECT_PAR_STORIES
    (
    MOD_OBJ_ID, OBJ_PAR_ID,
    TYPE_ID,
    N,
    M_DATE, M_USER
    )
    VALUES
    (
    :OLD.ID, -4,
    G.TROLE,
    :OLD.EDIT_ROLE,
    :OLD.M_DATE,:OLD.M_USER
    ); 
  END IF;
END;
/

--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_au
AFTER UPDATE ON SP.MODEL_OBJECTS
--(SP-MODEL.trg)
 DECLARE
 	rec SP.UPDATED_MOD_OBJECTS%ROWTYPE;
  tmpVar NUMBER;
  ObjName SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE; 
  ModelName SP.MODELS.NAME%TYPE; 
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateModObjects THEN RETURN; END IF;
  SP.TG.AfterUpdateModObjects:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_MOD_OBJECTS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    --
 	  IF g.notEQ(rec.NEW_PARENT_MOD_OBJ_ID, rec.OLD_PARENT_MOD_OBJ_ID) 
    		AND rec.NEW_PARENT_MOD_OBJ_ID IS NOT NULL THEN
 	    -- Находим имя и модель объекта родителя.
 	    SELECT o.MOD_OBJ_NAME, m.NAME
         INTO ObjName, ModelName
         FROM SP.MODEL_OBJECTS o, SP.MODELS m
 	      WHERE sp.g.S_EQ(o.ID,rec.NEW_PARENT_MOD_OBJ_ID) = 1
           AND o.MODEL_ID=m.ID;
	    -- Проверяем нет ли в потомках объекта его родителя.
	    SELECT COUNT(*) INTO tmpVar FROM 
	      (SELECT ID FROM SP.MODEL_OBJECTS
	                 START WITH PARENT_MOD_OBJ_ID=rec.OLD_ID
	                 CONNECT BY  PARENT_MOD_OBJ_ID= PRIOR ID)
	    WHERE rec.NEW_PARENT_MOD_OBJ_ID=ID;
	    IF tmpVar != 0 THEN             
	      SP.TG.ResetFlags;
		    RAISE_APPLICATION_ERROR(-20033,
		      'SP.MODEL_OBJECT_S_au.'||
		      ' Родительский объект '||ObjName||
		      ' является дочерним для '||rec.OLD_MOD_OBJ_NAME||'!');
	    END IF;
    END IF;
		-- Проверяем вид объекта. 
		SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS WHERE ID = rec.NEW_OBJ_ID;
		IF tmpVar != 0 THEN
		  RAISE_APPLICATION_ERROR(-20033,
	      'SP.MODEL_OBJECT_S_au.'||' Объект должен быть простого типа!');
		END IF;
 
    -- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_MOD_OBJECTS up WHERE up.NEW_ID=rec.NEW_ID;
 	END LOOP;
  SP.TG.AfterUpdateModObjects:= FALSE;
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_bdr
BEFORE DELETE ON SP.MODEL_OBJECTS
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECTS_bdr. Нельзя удалять предопределенные объекты модели!');
  END IF;
  -- Редактировать имет право администратор или,
  -- если его роль редактирования нулл.
  -- Если роль редактирования объекта не нулл, то редактировать объект
  -- может пользователь, имеющий такую роль.
  IF NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
    THEN
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bdr. '||
     'Недостаточно привелегий для удаления объекта: '||:OLD.MOD_OBJ_NAME||'!');
  END IF;
  -- Если не удаление всей модели, 
  if SP.TG.ModelDeleting is null then
    -- то при удалении объекта модели сбрасываем КЭШ для пути объекта.
    -- Дочерние объекты удаляются каскадно и их пути при этом так же сбросятся.
    update SP.MODEL_OBJECT_PATHS set invalid = 1 
      where ID = :OLD.ID;
  end if;    
  -- Разрешаем каскадное удаление параметров объектов.
  SP.TG.ModObjParDeleting:=TRUE;
  -- В табличном триггере проверяем и запрещаем:
  -- 1. Удаление объекта, на который ссылается параметр другого объекта.
  -- 2. Удаление объекта, ссылающегося на транзакцию.
	INSERT INTO SP.DELETED_MOD_OBJECTS
	  VALUES(:OLD.ID, :OLD.MODEL_ID, :OLD.MOD_OBJ_NAME, :OLD.OID,
           :OLD.OBJ_ID, :OLD.PARENT_MOD_OBJ_ID,
           :OLD.USING_ROLE,:OLD.EDIT_ROLE,
           :OLD.M_DATE, :OLD.M_USER, :NEW.TO_DEL);      
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECTS_ad
AFTER DELETE ON SP.MODEL_OBJECTS
--(SP-MODEL.trg)
DECLARE
tmpVar NUMBER;
Name SP.COMMANDS.COMMENTS%TYPE;
rec SP.DELETED_MOD_OBJECTS%ROWTYPE;
BEGIN
  IF ReplSession THEN return; END IF;
  IF TG.AfterDeleteModObjects THEN return; END IF;
  TG.AfterDeleteModObjects:= TRUE;
  --d('table тригер','ModObjects_ad');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_MOD_OBJECTS WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'ModObjects_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','ModObjects_ad');
        EXIT;
    END;
    BEGIN
      -- Нельзя удалить объект, если на него есть ссылка.
      -- 1 - для объекта каталога.
     select count(*) into tmpVar from SP.OBJECT_PAR_S 
        where TYPE_ID = G.TREL
          and N = rec.OLD_ID;
      if tmpVar >0 then
        -- Находим имя католожного объекта и вызываем ошибку.
        select g.Name||'.'||o.Name into Name 
          from SP.OBJECT_PAR_S p, SP.OBJECTS o, SP.GROUPS g
         where p.TYPE_ID = G.TREL
          and p.N = rec.OLD_ID
          and p.OBJ_ID = o.ID
          and g.ID = o.GROUP_ID
          and rownum < 2;
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' Невозможно удалить объект модели, ссылка на который есть свойство'
           ||' по умолчанию для объекта каталога '||Name||
           ' ! Всего ссылок '||tmpVar);
      end if;    
      -- 2 - для объекта Модели.
      -- Если удаляем модель, то проверяем, что нет ссылок из других моделей!!!
      -- иначе из всех.
      if SP.TG.ModelDeleting is not null then
        select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
          where TYPE_ID = G.TREL
            and N = rec.OLD_ID
            and MOD_OBJ_ID not in
            (
              select ID from SP.MODEL_OBJECTS oo 
                where OO.MODEL_ID = SP.TG.ModelDeleting
            );  
      else
        select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
          where TYPE_ID = G.TREL
            and N = rec.OLD_ID;
      end if;      
      --d('имеются ссылки!!! '||tmpVar,'ModObjects_ad');    
      if tmpVar >0 then
        -- Находим имя полное имя объекта модели и вызываем ошибку.
        select MODEL_NAME||'=>'||FULL_NAME into Name 
          from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S p
         where p.TYPE_ID = G.TREL
          and p.N = rec.OLD_ID
          and p.MOD_OBJ_ID = o.ID
          and rownum < 2;
         SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' Невозможно удалить объект модели('||rec.OLD_ID||'),'||
           ' ссылка на который есть свойство'||
           ' другого объекта модели '||Name||
           ' ! Всего ссылок '||tmpVar);
      end if;
      -- 3 - из истории свойств объекта Модели.
      -- Если удаляем модель, то проверяем, что нет ссылок из истории параметров
      -- других моделей
      if SP.TG.ModelDeleting is not null then
        select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES 
          where TYPE_ID = G.TREL
            and N = rec.OLD_ID
            and MOD_OBJ_ID not in
            (
              select ID from SP.MODEL_OBJECTS oo 
                where OO.MODEL_ID = SP.TG.ModelDeleting
            );  
      else
        --     за исключением ссылок из истории его бывших дочерних объектов,
        -- которые мы предварительно удаляем.
        --
        delete from SP.MODEL_OBJECT_PAR_STORIES 
          where TYPE_ID = SP.G.TRel
            and OBJ_PAR_ID = -2 
            and N = rec.OLD_ID; 
        select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES 
          where TYPE_ID = G.TREL
            and N = rec.OLD_ID;
      end if;    
      --d('имеются ссылки!!! '||tmpVar,'ModObjects_ad');    
      if tmpVar > 0 then
        -- !!Находим имя полное имя объекта модели и вызываем ошибку.
--        select MODEL_NAME||'=>'||FULL_NAME into Name 
--          from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_STORIES p
--         where p.TYPE_ID = G.TREL
--          and p.N = rec.OLD_ID
--          and p.MOD_OBJ_ID = o.ID
--          and rownum < 2;
         SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' Невозможно удалить объект модели('||rec.OLD_ID||'),'||
           ' ссылка на который присутствует в истории значений свойств'||
           ' другого объекта модели! Всего ссылок: '||tmpVar);
      end if;
      -- Нельзя удалить объект,
      -- если среди его свойств есть действительная ссылка на транзакцию.
      select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
        where TYPE_ID = G.TTRANS
          and N is not null 
          and MOD_OBJ_ID = rec.OLD_ID;
      if tmpVar >0 then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
          ' Невозможно удалить объект модели, ссылылающийся на транзакцию!');
      end if;
	  END;  
    -- Удаляем обработанную запись.
    --d('delete current','ModObjects_ad');
    DELETE FROM SP.DELETED_MOD_OBJECTS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  TG.AfterDeleteModObjects := FALSE;
  SP.TG.ModObjParDeleting:=FALSE;
END;
/
--*****************************************************************************

-- Параметры созданных в модели объектов.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.INSERTED_MOD_OBJ_PAR_S_bi
BEFORE INSERT ON SP.INSERTED_MOD_OBJ_PAR_S
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_MOD_OBJ_PAR_S;
  IF tmpVar=0 AND SP.TG.AfterInsertModObjPars THEN 
    SP.TG.AfterInsertModObjPars:= FALSE;
    d('SP.TG.AfterInsertModObjPars:= false;',
      'ERROR INSERTED_MOD_OBJ_PAR_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_MOD_OBJ_PAR_S_bi
BEFORE INSERT ON SP.UPDATED_MOD_OBJ_PAR_S
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_MOD_OBJ_PAR_S;
  IF tmpVar=0 AND SP.TG.AfterUpdateModObjPars THEN 
    SP.TG.AfterUpdateModObjPars:= FALSE;
    d('SP.TG.AfterUpdateModObjPars:= false;','ERROR UPDATED_MOD_OBJ_PAR_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_MOD_OBJ_PAR_S_bi
BEFORE INSERT ON SP.DELETED_MOD_OBJ_PAR_S
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  select count(*) into tmpVar from SP.DELETED_MOD_OBJ_PAR_S;
  IF tmpVar=0 and SP.TG.AfterDeleteModObjPars THEN 
    SP.TG.AfterDeleteModObjPars:= false;
    d('SP.TG.AfterDeleteModObjPars:= false;','ERROR DELETED_MOD_OBJ_PAR_S_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_bir
BEFORE INSERT ON SP.MODEL_OBJECT_PAR_S
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
	tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.MOD_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- Проверяем, что мы не добавляем параметры, имена которых совпадают
  -- с именами виртуальных параметров:
  -- "NAME", "OLD_NAME", "PARENT", "NEW_PARENT", "OID", "POID", "NEW_POID",
  -- "ID", "PID", "NEW_PID", "DELETE","USING_ROLE","EDIT_ROLE".
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  IF :NEW.NAME 
    IN ('NAME','OLD_NAME','PARENT','NEW_PARENT',
        'OID','POID','NEW_POID','ID','PID','NEW_PID','DELETE',
        'USING_ROLE','EDIT_ROLE', 'FORCE_OID') 
  THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_PAR_S_bir.'||
    ' Имя добавляемого параметра зарезервировано для виртуального параметра!');
 END IF;          
  -- Табличный триггер выполняет следующие действия.
  -- 1. Проверка, наличия у пользователя роли редектирования данного объекта.
  -- 2. Проверка значения параметра, если процедура проверки значения
  -- определена.
  -- 3. Для параметров имеющих прообраз в каталоге дополнительно:
  -- 3.1. Принадлежность родителя параметра в каталоге,
  -- родителю объекта в каталоге(для параметров, имеющих прообраз в каталоге).
  -- 3.2. Если параметр только для чтения, то его значение должно совпадать с
  -- каталогом. Следовательно для параметров, имеющих прообраз в каталоге, 
  -- его нет смысла добавлять!
  -- 3.3. Проверяем совпадение типа параметра и его прообраза в каталоге.
  --      Исключение: тип Rel можно подменить на SymRel.
  -- 3.4. Проверяем Значение режима чтения на совпадение с каталогом.
  INSERT INTO SP.INSERTED_MOD_OBJ_PAR_S
    VALUES(:NEW.ID,:NEW.MOD_OBJ_ID, :NEW.NAME, :NEW.OBJ_PAR_ID,
           :NEW.R_ONLY, :NEW.TYPE_ID,
           :NEW.E_VAL,:NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y,
           :NEW.M_DATE,:NEW.M_USER);      
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_ai
AFTER INSERT ON SP.MODEL_OBJECT_PAR_S
--(SP-MODEL.trg)
DECLARE
	rec SP.INSERTED_MOD_OBJ_PAR_S%ROWTYPE;
  pType NUMBER;
  tmpVar NUMBER;
  CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
  V SP.TVALUE;
  CatName SP.OBJECTS.NAME%TYPE;
  ParName SP.OBJECT_PAR_S.NAME%TYPE;
  ObjName SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  ROnly NUMBER(1);
  CatObj NUMBER;
  ObjId NUMBER;
--  URole NUMBER;
  ERole NUMBER;
  BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertModObjPars THEN RETURN; END IF;
  SP.TG.AfterInsertModObjPars:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_MOD_OBJ_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    BEGIN
      SELECT MOD_OBJ_NAME, OBJ_ID, EDIT_ROLE 
        INTO ObjName, ObjID, ERole FROM SP.MODEL_OBJECTS
        WHERE ID=rec.NEW_MOD_OBJ_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' Объект с идентификатором '||rec.NEW_MOD_OBJ_ID||
          ' не найден!');
    END;
--  1.Проверка, наличия у пользователя роли редектирования данного объекта.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_ai. '||
          'Недостаточно привелегий для изменения объекта: '||ObjName||'!');
    END IF;
    IF rec.NEW_OBJ_PAR_ID is not null then  
      BEGIN
        SELECT pt.CHECK_VAL, pt.ID, p.NAME, p.R_ONLY, p.OBJ_ID
          INTO CheckVal, pType, ParName, ROnly, CatObj
          FROM SP.PAR_TYPES pt, SP.OBJECT_PAR_S p 
            WHERE pt.ID=p.TYPE_ID
              AND p.ID=rec.NEW_OBJ_PAR_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN 
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_ai.'||
            ' Параметр с идентификатором '||rec.NEW_OBJ_PAR_ID||
            ' не найден!');
      END;
    ELSE
      pType := rec.NEW_TYPE_ID;
      ParName := rec.NEW_NAME;
      -- ROnly := rec.
      -- CatObj
      IF TG.Check_ValEnabled THEN
        BEGIN
          SELECT pt.CHECK_VAL INTO CheckVal 
            FROM SP.PAR_TYPES pt 
            WHERE pt.ID=pType;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN 
            SP.TG.ResetFlags;
            RAISE_APPLICATION_ERROR(-20033,
              'SP.MODEL_OBJECT_PAR_S_ai.'||
              ' Тип с идентификатором '||nvl(to_char(pType), 'null')||
              ' не найден!');
        END;
      END IF;   
    END IF;  																			 
	  -- 2. Проверка значения параметра, если процедура проверки значения
	  -- определена и проверка разрешена.
    IF TG.Check_ValEnabled THEN
		  IF CheckVal IS NOT NULL THEN 
				V:=SP.TVALUE(pType,null,0,rec.NEW_E_VAL,rec.NEW_N,rec.NEW_D,rec.NEW_S,
	                   rec.NEW_X, rec.NEW_Y);
	      BEGIN
		      SP.CheckVal(CheckVal,V);
	      EXCEPTION
	        WHEN OTHERS THEN 
	          SP.TG.ResetFlags;
		        RAISE_APPLICATION_ERROR(-20033,
		          'SP.MODEL_OBJECT_PAR_S_ai.'||
	            ' Ошибка проверки значения параметра '||ParName||
	            ' объекта '||ObjName||' : '||SQLERRM||'!');
	      END;   
      ELSE    
	  	  SELECT count(*) INTO tmpVar FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID = pType 
             AND (G.S_UpEQ(e.E_VAL, rec.NEW_E_VAL)
               + G.S_EQ(e.N, rec.NEW_N)
               + G.S_EQ(e.D, rec.NEW_D)
               + G.S_UpEQ(e.S, rec.NEW_S)
               + G.S_EQ(e.X, rec.NEW_X)
               + G.S_EQ(e.Y, rec.NEW_Y)=6);
		 		IF tmpVar =0 THEN	
		  		  SP.TG.ResetFlags;	 
				    RAISE_APPLICATION_ERROR(-20033,
				      'SP.MODEL_OBJECT_PAR_S_ai. Именованное значение: '||
              rec.NEW_E_VAL||
		          ' не найдено у параметра '||ParName||' объекта '||ObjName||
		          '!');
        END IF;      	 
		  END IF;
    END IF;
    -- 3. для параметров, имеющих прообраз в каталоге.
    IF rec.NEW_OBJ_PAR_ID is not null then  
      -- 3.1 Принадлежность родителя параметра в каталоге,
      -- родителю объекта в каталоге.
      IF G.notEQ(ObjId,CatObj) THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' Параметр каталога, на который ссылается параметр модели '||ParName||
          ' принадлежит другому объекту каталога, чем объект модели!');
      END IF;
      -- 3.2. Если параметр только для чтения, то его добавление бессмысленно.
      IF ROnly = SP.G.ReadOnly THEN        
        SP.TG.ResetFlags;
        SELECT NAME INTO CatName FROM SP.OBJECTS WHERE ID=CatObj;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' Параметр '||ParName||' объекта '||ObjName||
          ' (каталожное имя '||CatName||')'||
          ' имеет признак только для чтения!');
      END IF;
      -- 3.3. Проверяем совпадение типов параметра и его прообраза в каталоге.
      IF pType != rec.NEW_TYPE_ID then
        if (pType != G.TRel) and (rec.NEW_TYPE_ID != G.TSymRel) then
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_ai.'||
            ' Тип '||pType||' параметра в каталоге '||ParName||
            ' не совпадает с типом '||rec.NEW_TYPE_ID||
            ' добавляемого параметра!');
        end if;    
      END IF;
      -- 3.4. Проверяем Значение режима чтения на совпадение с каталогом.
      --!! IF RONLY != rec.NEW_R_ONLY then продумать и исправить глюк!!!!
      IF (RONLY > 0) and (rec.NEW_R_ONLY <= 0) then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' модификатор '||rec.NEW_R_ONLY||' добавляемого параметра '||ParName||
          ' не совпадает с типом '||RONLY||' параметра в каталоге!');
      END IF;
    END IF;
    -- Удаляем обработанную запись.
    DELETE FROM SP.INSERTED_MOD_OBJ_PAR_S up WHERE up.NEW_ID=rec.NEW_ID;
	END LOOP;
  SP.TG.AfterInsertModObjPars:= FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_bur
BEFORE UPDATE ON SP.MODEL_OBJECT_PAR_S
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  :NEW.MOD_OBJ_ID:=:OLD.MOD_OBJ_ID;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
   
  -- Если это корректировка именованного значения, то выход.
  IF SP.TG.AfterUpdateEnum THEN return; END IF;
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- Проверяем совпадение имени параметра с именами виртуальных параметров.
  IF :NEW.NAME 
    IN ('NAME','OLD_NAME','PARENT','NEW_PARENT',
        'OID','POID','NEW_POID','ID','PID','NEW_PID','DELETE',  
        'USING_ROLE','EDIT_ROLE') 
  THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_PAR_S_bur.'||
  ' Имя добавляемого параметра зарезервировано для виртуального параметра!');
  END IF;
  -- Табличный триггер выполняет следующие действия.
  -- 1. Проверка, наличия у пользователя роли редектирования данного объекта.
  -- 2. Проверка значения параметра, если процедура проверки значения
  -- определена и проверка разрешена.
  -- 3. Для параметров, имеющих прообразы в каталоге проверяем:
  -- 3.1. Принадлежность родителя параметра в каталоге,
  -- родителю объекта в каталоге.
  -- 3.2. Если параметр только для чтения, то его значение должно совпадать с
  -- каталогом. 
  -- Следовательно такой параметр не может присутствовать в таблице параметров 
  -- модели.
  -- 3.3 Проверяем совпадение типов параметра и его прообраза в каталоге.
  --     При этом тип Rel можно заменить на SymRel.
  -- 3.4. Проверяем Значение режима чтения на совпадение с каталогом,
  -- а также, если необходимо, то добавляем старое значение параметра
  -- в историю. Не добавляем старое значение, если старый тип SymRel.
  INSERT INTO SP.UPDATED_MOD_OBJ_PAR_S
    VALUES(:NEW.ID, :NEW.MOD_OBJ_ID, :NEW.NAME, :NEW.OBJ_PAR_ID,
           :NEW.R_ONLY, :NEW.TYPE_ID,
           :NEW.E_VAL, :NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y,
           :NEW.M_DATE,:NEW.M_USER,
           :OLD.ID, :OLD.MOD_OBJ_ID, :OLD.NAME, :OLD.OBJ_PAR_ID,
           :OLD.R_ONLY, :OLD.TYPE_ID,
           :OLD.E_VAL, :OLD.N,:OLD.D,:OLD.S,:OLD.X,:OLD.Y,
           :OLD.M_DATE, :OLD.M_USER);      
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_au
AFTER UPDATE ON SP.MODEL_OBJECT_PAR_S
--(SP-MODEL.trg)
DECLARE
	CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
	V SP.TVALUE;
	rec SP.UPDATED_MOD_OBJ_PAR_S%ROWTYPE;
  tmpVar NUMBER;
  pType NUMBER;
  ParName SP.OBJECT_PAR_S.NAME%TYPE;
  ObjName SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  CatName SP.OBJECTS.NAME%TYPE;
  ROnly NUMBER(1);
  CatObj NUMBER;
  ObjId NUMBER;
  ERole NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateModObjPars 
  THEN 
    --d('table тригер => return ','MODEL_OBJECT_PAR_S_au');
    RETURN; 
  END IF;
  SP.TG.AfterUpdateModObjPars:= TRUE;
  d('table тригер','MODEL_OBJECT_PAR_S_au');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_MOD_OBJ_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    --
    BEGIN
      SELECT MOD_OBJ_NAME, OBJ_ID, EDIT_ROLE 
        INTO ObjName, ObjID, ERole FROM SP.MODEL_OBJECTS
        WHERE ID=rec.OLD_MOD_OBJ_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' Объект с идентификатором '||rec.OLD_MOD_OBJ_ID||
          ' не найден!');
    END;
--  1.Проверка, наличия у пользователя роли редектирования данного объекта.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_au. '||
          'Недостаточно привелегий для изменения объекта: '||ObjName||
          '('||rec.OLD_MOD_OBJ_ID||')!');
    END IF;
    -- 
--    d(' PAR ID '||rec.NEW_OBJ_PAR_ID||
--      ' NEW TYPE '||rec.NEW_TYPE_ID||' OLD '||rec.OLD_TYPE_ID,
--      'MODEL_OBJECT_PAR_S_au');
    IF rec.NEW_OBJ_PAR_ID is not null then  
      BEGIN
        SELECT pt.CHECK_VAL, pt.ID, p.NAME, p.R_ONLY, p.OBJ_ID
          INTO CheckVal, pType, ParName, ROnly, CatObj
          FROM SP.PAR_TYPES pt, SP.OBJECT_PAR_S p 
            WHERE pt.ID=p.TYPE_ID
              AND p.ID=rec.NEW_OBJ_PAR_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_au.'||
            ' Параметр с идентификатором '||rec.NEW_OBJ_PAR_ID||
            ' не найден!');
      END;
    ELSE
      pType := rec.NEW_TYPE_ID;
      ParName := rec.NEW_NAME;
      -- ROnly := rec.
      -- CatObj
      IF TG.Check_ValEnabled THEN
        BEGIN
          SELECT pt.CHECK_VAL INTO CheckVal 
            FROM SP.PAR_TYPES pt 
            WHERE pt.ID=pType;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
            SP.TG.ResetFlags;
            RAISE_APPLICATION_ERROR(-20033,
              'SP.MODEL_OBJECT_PAR_S_au.'||
              ' Тип с идентификатором '||nvl(pType, 'null')||
              ' не найден!');
        END;
      END IF;  
    END IF;  
    -- 2. Проверка значения параметра, если процедура проверки значения
	  -- определена и проверка разрешена.
    IF TG.Check_ValEnabled THEN
  	  IF CheckVal IS NOT NULL THEN 
  			V:=SP.TVALUE(pType,null,0,rec.NEW_E_VAL,rec.NEW_N,rec.NEW_D,rec.NEW_S,
                     rec.NEW_X, rec.NEW_Y);
        BEGIN
  	      SP.CheckVal(CheckVal,V);
        EXCEPTION
          WHEN OTHERS THEN 
            SP.TG.ResetFlags;
  	        RAISE_APPLICATION_ERROR(-20033,
  	          'SP.MODEL_OBJECT_PAR_S_au.'||
              ' Ошибка проверки значения параметра '||ParName||
              ' объекта '||ObjName||'('||rec.OLD_MOD_OBJ_ID||'): '||
              SQLERRM||'!');
        END; 
      ELSE    
	  	  SELECT count(*) INTO tmpVar FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID = pTYpe 
             AND (G.S_UpEQ(e.E_VAL, rec.NEW_E_VAL)
               + G.S_EQ(e.N, rec.NEW_N)
               + G.S_EQ(e.D, rec.NEW_D)
               + G.S_UpEQ(e.S, rec.NEW_S)
               + G.S_EQ(e.X, rec.NEW_X)
               + G.S_EQ(e.Y, rec.NEW_Y)=6);
		 		IF tmpVar =0 THEN	
		  		  SP.TG.ResetFlags;	 
				    RAISE_APPLICATION_ERROR(-20033,
				      'SP.MODEL_OBJECT_PAR_S_au. Именованное значение: '||
              rec.NEW_E_VAL||
		          ' не найдено у параметра '||ParName||' объекта '||ObjName||
		          '('||rec.OLD_MOD_OBJ_ID||')!');
        END IF;      	 
  	  END IF;
		END IF;
    -- 3. для параметров, имеющих прообраз в каталоге.
    IF rec.NEW_OBJ_PAR_ID is not null then  
      -- 3.1 Принадлежность родителя параметра в каталоге,
      -- родителю объекта в каталоге.
      IF G.notEQ(ObjId,CatObj) THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' Параметр каталога, на который ссылается параметр модели '||ParName||
          ' принадлежит другому объекту каталога, чем объект модели!');
      END IF;
      -- 3.2. Если параметр только для чтения, то его добавление бессмысленно.
      IF ROnly = SP.G.ReadOnly THEN        
        SP.TG.ResetFlags;
        SELECT NAME INTO CatName FROM SP.OBJECTS WHERE ID=CatObj;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' Параметр '||ParName||' объекта '||ObjName||
          ' (каталожное имя '||CatName||')'||
          ' имеет признак только для чтения!');
      END IF;
      -- 3.3. Проверяем совпадение типов параметра и его прообраза в каталоге.
      --      Тип Rel можно заменить на SymRel.
      IF pType != rec.NEW_TYPE_ID then
        if (pType != G.TRel) and (rec.NEW_TYPE_ID != G.TSymRel) then
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_au.'||
            ' Новый Тип изменяемого параметра не совпадает'||
            ' с типом параметра в каталоге!');
        end if;    
      END IF;
      -- 3.4. Проверяем Значение режима чтения на совпадение с каталогом,
      --!! IF RONLY != rec.NEW_R_ONLY then продумать и исправить глюк!!!!
      IF (RONLY > 0) and (rec.NEW_R_ONLY <= 0) then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' Новый модификатор '||rec.NEW_R_ONLY||
          ' изменяемого параметра '||ParName||
          ' не совпадает с типом '||RONLY||' параметра в каталоге!');
      END IF;
      -- а также, если необходимо, то добавляем старое значение параметра
      -- в историю.
      IF    (not SP.TG.ImportDATA) 
        and (RONLY between -1 and 0) 
        and (rec.OLD_TYPE_ID != G.TSymRel)
        and (rec.NEW_M_DATE - rec.OLD_M_DATE > INTERVAL '0 0:0:1' DAY TO SECOND)
      THEN
        d('Добавляем историю MOD_OBJ_ID: '||rec.OLD_MOD_OBJ_ID||
          ' MOD_OBJ_PAR_ID:'||rec.OLD_ID||
          ' New M_DATE:'||rec.NEW_M_DATE||
          ' Old_M_DATE:'||rec.OLD_M_DATE,
          'SP.MODEL_OBJECT_PAR_S_au');
        INSERT INTO SP.MODEL_OBJECT_PAR_STORIES
        (
          MOD_OBJ_ID, OBJ_PAR_ID,
          TYPE_ID,
          E_VAL,
          N,
          D,
          S,
          X,
          Y,
          M_DATE, M_USER
        )
        VALUES
        (
          rec.OLD_MOD_OBJ_ID, rec.OLD_OBJ_PAR_ID,
          rec.OLD_TYPE_ID,
          rec.OLD_E_VAL,
          rec.OLD_N,
          rec.OLD_D,
          rec.OLD_S,
          rec.OLD_X,
          rec.OLD_Y,
          rec.OLD_M_DATE,rec.OLD_M_USER
        ); 
      END IF;
    END IF;
    -- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_MOD_OBJ_PAR_S up WHERE up.NEW_ID=rec.NEW_ID;  
	END LOOP;
  SP.TG.AfterUpdateModObjPars := FALSE;
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_bdr
BEFORE DELETE ON SP.MODEL_OBJECT_PAR_S
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_PAR_S_bdr.'||
      ' Нельзя удалять предопределенные параметры объектов модели!');
  END IF;
  -- Удалять параметр объекта модели можно, если удалён сам объект,
  -- или у объекта каталога отсутствует соответствующий параметр.
  -- Этот флаг так же применяется при изменении класса объекта.
  IF SP.TG.ModObjParDeleting THEN
    RETURN; -- удалён объект
  END IF;
--  IF :OLD.OBJ_PAR_ID IS not NULL THEN
--    SP.TG.ResetFlags;       
--    RAISE_APPLICATION_ERROR(-20033,
--      'SP.MODEL_OBJECT_PAR_S_bdr.'||
--      ' Нельзя удалить отдельно взятый параметр объекта модели.'||
--      ' Можно удалить все параметры объекта вместе с объектом,'||
--      ' или можно удалить параметр объекта модели,'||
--      ' если у него отсутствует ссылка на соответствующий объект каталога!');
--  END IF;
  -- В табличном триггере проверяем, что пользователь имеет роль редактирования
  -- объекта.
  insert into SP.DELETED_MOD_OBJ_PAR_S values
     (:OLD.ID, :OLD.MOD_OBJ_ID, :OLD.NAME, :OLD.OBJ_PAR_ID, 
      :OLD.R_ONLY, :OLD.TYPE_ID,
      :OLD.E_VAL, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y,
      :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_S_ad
AFTER DELETE ON SP.MODEL_OBJECT_PAR_S
--(SP-MODEL.trg)
DECLARE
  rec SP.DELETED_MOD_OBJ_PAR_S%rowtype;
  tmpVar NUMBER;
  ObjName SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
--  CatName SP.OBJECTS.NAME%TYPE;
--  ROnly NUMBER;
--  CatObj NUMBER;
--  ObjId NUMBER;
  ERole NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  IF SP.TG.AfterDeleteModObjPars THEN return; END IF;
  SP.TG.AfterDeleteModObjPars:= true;
  LOOP
    begin
      select * into rec from SP.DELETED_MOD_OBJ_PAR_S where rownum=1;
    exception
      when no_data_found then exit;
    end;
   
    BEGIN
      SELECT MOD_OBJ_NAME, EDIT_ROLE 
        INTO ObjName, ERole FROM SP.MODEL_OBJECTS
        WHERE ID=rec.OLD_MOD_OBJ_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ad.'||
          ' Объект с идентификатором '||rec.OLD_MOD_OBJ_ID||
          ' не найден!');
    END;
--  1.Проверка, наличия у пользователя роли редектирования данного объекта.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_ad. '||
          'Недостаточно привелегий для изменения объекта: '||ObjName||'!');
    END IF;
    -- 
    -- Удаляем обработанную запись.
    delete from SP.DELETED_MOD_OBJ_PAR_S up where up.OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteModObjPars:= false;
END;
/

-- История свойств объектов модели
-- BEFORE_INSERT_TABLE---------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.DELETED_M_OBJ_PAR_STOPIES_bi
BEFORE INSERT ON SP.DELETED_M_OBJ_PAR_STOPIES
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  select count(*) into tmpVar from SP.DELETED_M_OBJ_PAR_STOPIES;
  IF tmpVar=0 and SP.TG.AfterDeleteMOParStories THEN 
    SP.TG.AfterDeleteMOParStories:= false;
    d('SP.TG.AfterDeleteMOParStories:= false;',
      'ERROR DELETED_M_OBJ_PAR_STOPIES_bi');
  END IF;
END;
/
-- BEFORE_INSERT----------------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_STORIES_bir
BEFORE INSERT ON SP.MODEL_OBJECT_PAR_STORIES
FOR EACH ROW
--(SP-MODEL.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.STORY_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  --!! Проверка что параметр принадлежит объекту.
  if :NEW.OBJ_PAR_ID = 2 then
    SP.TG.ResetFlags;
    d(  'MOD_OBJ_ID '|| :NEW.MOD_OBJ_ID||', '||
        'OBJ_PAR_ID '|| :NEW.OBJ_PAR_ID||', '||
        'TYPE_ID '|| :NEW.TYPE_ID||', '||
        'N '||:NEW.N,'Error in SP.MODEL_OBJECT_PAR_STORIES_bir.'
     );    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_STORIES_bir. '||
      'Ошибка алгоритма ! сообшить Красильникову');
  end if;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
 END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_STORIES_bur
BEFORE UPDATE ON SP.MODEL_OBJECT_PAR_STORIES
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  :NEW.ID := :OLD.ID;
  :NEW.MOD_OBJ_ID := :OLD.MOD_OBJ_ID;
  :NEW.OBJ_PAR_ID := :OLD.OBJ_PAR_ID;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
 END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_STORIES_bdr
BEFORE DELETE ON SP.MODEL_OBJECT_PAR_STORIES
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- Удалять историю значения параметра объекта модели можно,
  -- если удалён сам объект.
  IF SP.TG.ModObjParDeleting THEN
    RETURN; -- удалён объект
  END IF;
  -- Удалять историю значения параметра объекта модели может 
  -- только администратор.
  IF SP.TG.SP_Admin THEN
    RETURN; 
  END IF;
  -- Проверку что у параметра не установлен признак сохранения истории
  -- производим в табличном триггере.
  insert into SP.DELETED_M_OBJ_PAR_STOPIES values
  ( :OLD.ID, :OLD.MOD_OBJ_ID, :OLD.OBJ_PAR_ID, 
    :OLD.TYPE_ID, :OLD.E_VAL, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y,
    :OLD.M_DATE, :OLD.M_USER);
--  SP.TG.ResetFlags;
--  RAISE_APPLICATION_ERROR(-20033,
--    'SP.MODEL_OBJECT_PAR_STORIES_bdr. Нельзя удалять историю!');
END;
/

--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_STORIES_ad
AFTER DELETE ON SP.MODEL_OBJECT_PAR_STORIES
--(SP-MODEL.trg)
DECLARE
  rec SP.DELETED_M_OBJ_PAR_STOPIES%rowtype;
  tmpVar NUMBER;
  ParName SP.OBJECT_PAR_S.NAME%TYPE;
  ObjName SP.COMMANDS.COMMENTS%TYPE;
BEGIN
  IF ReplSession THEN return; END IF;
  IF SP.TG.AfterDeleteMOParStories THEN return; END IF;
  SP.TG.AfterDeleteMOParStories:= true;
  LOOP
    begin
      select * into rec from SP.DELETED_M_OBJ_PAR_STOPIES where rownum=1;
    exception
      when no_data_found then exit;
    end;
   
  -- Проверяем отсутствие признака сохранения истории у параметра.
    select P.R_ONLY, P.NAME into tmpVar, ParName from SP.OBJECT_PAR_S p 
      where P.ID = rec.OLD_OBJ_PAR_ID;
    IF tmpVar in(G.READWRITE, G.REQUIRED) THEN
      select o.FULL_NAME into ObjName from SP.V_MODEL_OBJECTS o 
        where O.ID = rec.OLD_MOD_OBJ_ID;
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_STORIES_ad '||
          'Для параметра '||ParName||' объекта '||ObjName||
          ' удалять историю может только администратор!');
    END IF;
    -- 
    -- Удаляем обработанную запись.
    delete from SP.DELETED_M_OBJ_PAR_STOPIES up where up.OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteMOParStories:= false;
END;
/
--*****************************************************************************


-- end of file

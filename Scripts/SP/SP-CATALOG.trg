-- SP Catalog tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 23.08.2010
-- update 01.09.2010 23.09.2010 12.10.2010 17.11.2010 16.12.2010 27.12.2010
--				13.01.2010 15.03.2011 29.03.2011 11.11.2011 15.03.2012 13.04.2012
--        03.04.2013 11.06.2013 19.07.2013 22.08.2013 25.04.2014 13.06.2014
--        14.06.2014 26.08.2014 30.08.2014 10.11.2014 06.01.2015 31.03.2015
--        30.04.2015 08.06.2015 08.07.2015 20.08.2015 06.11.2015 09.06.2016
--        08.07.2016 11.07.2015 19.09.2016 08.10.2016 10.10.2016 23.10.2016
--        04.12.2016 12.02.2017 12.04.2017 25.04.2017 30.06.2017 04.07.2017
--        25.07.2017 29.08.2017 16.11.2017 12.02.2018 29.06.2018 28.08.2020
--        11.04.2021
--*****************************************************************************

-- Роли.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DELETED_SP_ROLES_bi
BEFORE INSERT ON SP.DELETED_SP_ROLES
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_SP_ROLES;
  IF tmpVar=0 AND SP.TG.AfterDeleteSpRoles THEN 
    SP.TG.AfterDeleteSpRoles:= FALSE;
    d('SP.TG.AfterDeleteSpRoles:= false;','ERROR DELETED_SP_ROLES_bi');
  END IF;
END;
/
CREATE OR REPLACE TRIGGER SP.UPDATED_SP_ROLES_bi
BEFORE INSERT ON SP.UPDATED_SP_ROLES
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_SP_ROLES;
  IF tmpVar=0 AND SP.TG.AfterUpdateSpRoles THEN 
    SP.TG.AfterUpdateSpRoles:= FALSE;
    d('SP.TG.AfterUpdatepRoles:= false;','ERROR UPDATED_SP_ROLES_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_bir
BEFORE INSERT ON SP.SP_ROLES
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF :NEW.ORA is NULL THEN
    :NEW.ORA := 0;
  END IF;
 :NEW.NAME := trim(:NEW.NAME);
  -- Если установлен признак системной роли, то добавляем её в систему.
  IF :NEW.ORA = 1 THEN
    SP.NEW_ROLE(:NEW.NAME);
  ELSE
    SP.DROP_ROLE(:NEW.NAME);  
  END IF;  
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_bur
BEFORE UPDATE ON SP.SP_ROLES
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF not ReplSession THEN 
    :NEW.ID := :OLD.ID;
    -- Нельзя редактировать встроенные роли.
    IF :OLD.ID < 100 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_bur. Нельзя редактировать встроенные роли!');
    END IF;
    :NEW.NAME := trim(:NEW.NAME);
    -- Редактировать имя можно только у не системной роли.
    IF (:OLD.ORA = 1) and not (:NEW.NAME = :OLD.NAME) THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_bur. Нельзя изменить имя системной роли!');
    END IF;
  END IF;
  -- Если у роли изменилась принадлежность к системе, то удаляем её из системы
  -- или добавляем в систему.
  IF :NEW.ORA = 1 and :OLD.ORA = 0 THEN
    SP.NEW_ROLE(:OLD.NAME);
    -- Если роль стала системной, то возможно среди ролей, которым она
    -- предоставила привилегии или от которых она получала привилегии,
    -- есть системные роли.
    -- Добавление грантов производим в табличном триггере.
    INSERT INTO SP.UPDATED_SP_ROLES 
      VALUES (:NEW.ID, :NEW.NAME, :NEW.COMMENTS, :NEW.ORA,
              :OLD.ID, :OLD.NAME, :OLD.COMMENTS, :OLD.ORA);
  END IF;
  IF :NEW.ORA = 0 and :OLD.ORA = 1 THEN
    -- Проверяем, что роль не используется пользователем SP.
    select count(*) into tmpVar from
      (
        select distinct GRANTED_ROLE from DBA_ROLE_PRIVS D
          where D.GRANTEE in
          (
            select distinct SP_USER  from SP.USERS_GLOBALS
          )
      )
    where GRANTED_ROLE = :OLD.NAME;
    if tmpVar = 0 then  
      SP.DROP_ROLE(:OLD.NAME);
    else
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_bur.'||
        ' Нельзя вывести из системы роль, которая дана пользователю,'||
        ' как первичная роль!');
    end if;  
  END IF;
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_au
AFTER UPDATE ON SP.SP_ROLES
--(SP-CATALOG.trg)
DECLARE
  rec SP.UPDATED_SP_ROLES%ROWTYPE;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  --d('table тригер','SP_ROLES_au');
   IF SP.TG.AfterUpdateSpRoles THEN RETURN; END IF;
  SP.TG.AfterUpdateSpRoles:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_SP_ROLES WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Добавляем Гранты всем родителям.
    for rr in(
              select r.ID R_ID, g.ID PARENT
                from SP.SP_ROLES r, SP.SP_ROLES g, SP.SP_ROLES_RELS rr
                where rr.ROLE_ID = g.ID
                  and rr.GRANTED_ID = r.ID
                  and r.ID = rec.OLD_ID
             )
    loop
      SP.GRANT_ROLE(rr.R_ID, rr.PARENT);
    end loop;   
    -- Получаем Гранты от детей.
    for rr in(
              select r.ID R_ID, g.ID PARENT
                from SP.SP_ROLES r, SP.SP_ROLES g, SP.SP_ROLES_RELS rr
                where rr.ROLE_ID = g.ID
                  and rr.GRANTED_ID = r.ID
                  and g.ID = rec.OLD_ID
             )
    loop
      SP.GRANT_ROLE(rr.R_ID, rr.PARENT);
    end loop;   
    -- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_SP_ROLES WHERE OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterUpdateSpRoles:= FALSE;
END;
/

--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_bdr
BEFORE DELETE ON SP.SP_ROLES
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN 
    SP.DROP_ROLE(:OLD.NAME);
    RETURN; 
  END IF;
  -- Нельзя удалять Роли с идентификаторами меньше 100.
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.ROLES_bdr. Нельзя удалять встроенные роли!');
  END IF;
  -- Разрешаем каскадное удаление иерархии ролей.
  SP.TG.RolesDeleting:=TRUE;
  -- Проверки на не-возможность удаления роли ввиду существующих ссылок
  -- выполняем в табличном триггере.
  INSERT INTO SP.DELETED_SP_ROLES 
    VALUES (:OLD.ID, :OLD.NAME, :OLD.COMMENTS, :OLD.ORA);
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_ad
AFTER DELETE ON SP.SP_ROLES
--(SP-CATALOG.trg)
DECLARE
  rec SP.DELETED_SP_ROLES%ROWTYPE;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  --d('table тригер','SP_ROLES_ad');
   IF SP.TG.AfterDeleteSpRoles THEN RETURN; END IF;
  SP.TG.AfterDeleteSpRoles:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_SP_ROLES WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Нельзя удалить роль, 
    -- если на неё есть ссылка в параметрах объекта каталога,
    -- или в параметрах объекта модели 
    -- или в истории значений параметров модели.
    select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        'Нельзя удалить роль, используемую в параметрах объекта модели!');
    END IF;    
    select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        'Нельзя удалить роль, используемую в истории параметров объекта модели!');
    END IF;    
    select count(*) into tmpVar from SP.OBJECT_PAR_S p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        'Нельзя удалить роль, используемую в параметрах объекта каталога!');
    END IF; 
    -- Удаляем роль из системы, если она системная.
    IF rec.OLD_ORA = 1 THEN   
      SP.DROP_ROLE(rec.OLD_NAME);
    END IF;  
    -- Удаляем обработанную запись.
    DELETE FROM SP.DELETED_SP_ROLES WHERE OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteSpRoles:= FALSE;
  SP.TG.RolesDeleting:=TRUE;
END;
/

-- Иерархия ролей.
--
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.INSERTED_SP_ROLES_RELS_bi
BEFORE INSERT ON SP.INSERTED_SP_ROLES_RELS
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_SP_ROLES_RELS;
  IF tmpVar=0 AND SP.TG.AfterInsertSpRolesRels THEN 
    SP.TG.AfterInsertSpRolesRels:= FALSE;
    d('SP.TG.AfterInsertSpRolesRels:= false;',
      'ERROR INSERTED_SP_ROLES_RELS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_SP_ROLES_RELS_bi
BEFORE INSERT ON SP.DELETED_SP_ROLES_RELS
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_SP_ROLES_RELS;
  IF tmpVar=0 AND SP.TG.AfterDeleteSpRolesRels THEN 
    SP.TG.AfterDeleteSpRolesRels:= FALSE;
    d('SP.TG.AfterDeleteSpRolesRels:= false;','ERROR DELETED_SP_ROLES_RELS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_RELS_bir
BEFORE INSERT ON SP.SP_ROLES_RELS
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.SP_ROLES_RELS_bir. Привилегий недостаточно!');
  END IF;
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- Проверки на зациклевание иерархии и необходимость добавления связи ролей в
  -- систему выполняем в табличном триггере.
  INSERT INTO SP.INSERTED_SP_ROLES_RELS 
    VALUES (:NEW.ID, :NEW.ROLE_ID, :NEW.GRANTED_ID);
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_RELS_ai
AFTER INSERT ON SP.SP_ROLES_RELS
--(SP-CATALOG.trg)
DECLARE
  rec SP.INSERTED_SP_ROLES_RELS%ROWTYPE;
  tmpVar NUMBER;
  tmpRole NUMBER;
  tmpGranted NUMBER;
  hy_loop exception;
  pragma exception_init(hy_loop, -01436);
BEGIN
  IF ReplSession THEN RETURN; END IF;
  --d('table тригер','SP_ROLES_RELS_ai');
   IF SP.TG.AfterInsertSpRolesRels THEN RETURN; END IF;
  SP.TG.AfterInsertSpRolesRels:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_SP_ROLES_RELS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Проверяем, что роль получившая грант не предоствляла грант кому либо из
    -- предоставивших грант роли, предоставляющей грант в настоящее время.
    begin
      select count(*) into tmpVar from 
        (select * from SP.SP_ROLES_RELS rr
        start with RR.GRANTED_ID = rec.NEW_GRANTED_ID
        connect by  ROLE_ID = prior GRANTED_ID) rr
        where rr.GRANTED_ID = rec.NEW_ROLE_ID;
    exception 
      when hy_loop then tmpVar := 1; 
    end;   
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.SP_ROLES_RELS_ai. '||
        'Добавление связи приводит к зацикливанию ролей!');
    END IF; 
    -- Если установлена связь между системными ролями,
    -- то добавляем связь в систему.
    select r.ORA, G.ORA into tmpRole, tmpGranted 
      from SP.SP_ROLES r, SP.SP_ROLES g 
      where r.ID = rec.NEW_ROLE_ID and g.ID = rec.NEW_GRANTED_ID;
    IF (tmpRole = 1) and (tmpGranted = 1) THEN   
      SP.GRANT_ROLE(rec.NEW_GRANTED_ID, rec.NEW_ROLE_ID);
    END IF;  
    -- Удаляем обработанную запись.
    DELETE FROM SP.INSERTED_SP_ROLES_RELS WHERE NEW_ID=rec.NEW_ID;
  END LOOP;
  SP.TG.AfterInsertSpRolesRels:= FALSE;
END;
/

--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_RELS_bur
BEFORE UPDATE ON SP.SP_ROLES_RELS
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SP.TG.ResetFlags;
  RAISE_APPLICATION_ERROR(-20033,
    'SP.SP_ROLES_RELS_bur. Нельзя редактировать иерархию ролей!');
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_RELS_bdr
BEFORE DELETE ON SP.SP_ROLES_RELS
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  -- Не участвуем в каскадном удалении ролей.
  IF ReplSession or SP.TG.RolesDeleting THEN RETURN; END IF;
  -- Нельзя удалять Встроенные связи с идентификаторами меньше 100.
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.ROLES_REL_bdr. Нельзя удалять встроенную иерархию ролей!');
  END IF;
  -- Удаление системных грантов выполняем в табличном триггере.
  INSERT INTO SP.DELETED_SP_ROLES_RELS
    VALUES (:OLD.ID, :OLD.ROLE_ID, :OLD.GRANTED_ID);
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.SP_ROLES_RELS_ad
AFTER DELETE ON SP.SP_ROLES_RELS
--(SP-CATALOG.trg)
DECLARE
  rec SP.DELETED_SP_ROLES_RELS%ROWTYPE;
  tmpRole NUMBER;
  tmpGranted NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  --d('table тригер','SP_ROLES_RELS_ad');
   IF SP.TG.AfterDeleteSpRolesRels THEN RETURN; END IF;
  SP.TG.AfterDeleteSpRolesRels:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_SP_ROLES_RELS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Если разорвана связь между системными ролями,
    -- то отнимаем грант в системе.
    select r.ORA, G.ORA into tmpRole, tmpGranted 
      from SP.SP_ROLES r, SP.SP_ROLES g 
      where r.ID = rec.OLD_ROLE_ID and g.ID = rec.OLD_GRANTED_ID;
    IF (tmpRole = 1) and (tmpGranted = 1) THEN   
      SP.REVOKE_ROLE(rec.OLD_ROLE_ID, rec.OLD_GRANTED_ID );
    END IF;  
    -- Удаляем обработанную запись.
    DELETE FROM SP.DELETED_SP_ROLES_RELS WHERE OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteSpRolesRels:= FALSE;
END;
/

-- Дерево каталога.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.UPDATED_CATALOG_TREE_bi
BEFORE INSERT ON SP.UPDATED_CATALOG_TREE
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_CATALOG_TREE;
  IF tmpVar=0 AND SP.TG.AfterUpdateCatalogTree THEN 
    SP.TG.AfterUpdateCatalogTree:= FALSE;
    d('SP.TG.AfterUpdateCatalogTree:= false;','ERROR UPDATED_CATALOG_TREE_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.CATALOG_TREE_bir
BEFORE INSERT ON SP.CATALOG_TREE
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.OBJ_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- Только администратор может редактировать дерево каталога.
	IF    NOT SP.TG.SP_ADMIN	THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bir.'||
      ' Недостаточно привелегий для добавления узла!');
	END IF;	
  -- Защита от невероятной ошибки. 
  IF :NEW.ID=:NEW.PARENT_ID THEN :NEW.PARENT_ID:=NULL; END IF;
  -- Есле не задана группа, то присваиваем значение по умолчанию.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF;
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.CATALOG_TREE_bur
BEFORE UPDATE ON SP.CATALOG_TREE
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
	-- Редактировать имет право только администратор.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bur. '||
      'Недостаточно привелегий для изменения узлов!');
  END IF;
  -- Если не заданы или не изменены дата изменения или пользователь,
  -- то изменяем на текущие.
  IF (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) THEN
    :NEW.M_DATE := sysdate;
  END IF;
  IF (:NEW.M_DATE is null) or (:NEW.M_USER = :OLD.M_USER) THEN
    :NEW.M_USER := TG.UserName;
  END IF;
  -- Есле не задана группа, то присваиваем значение по умолчанию.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- Проверяем отсутствие зацикливания по новму родителю в табличном триггере.
  INSERT INTO SP.UPDATED_CATALOG_TREE 
    VALUES (:NEW.ID, :NEW.IM_ID, :NEW.NAME, :NEW.COMMENTS,
            :NEW.PARENT_ID, :NEW.GROUP_ID, :NEW.M_DATE, :NEW.M_USER,
            :OLD.ID, :OLD.IM_ID, :OLD.NAME, :OLD.COMMENTS,
            :OLD.PARENT_ID, :OLD.GROUP_ID, :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_APDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.CATALOG_TREE_au
AFTER UPDATE ON SP.CATALOG_TREE
--(SP-CATALOG.trg)
DECLARE
	rec SP.UPDATED_CATALOG_TREE%ROWTYPE;
  tmpVar NUMBER;
  Cycle_ERR EXCEPTION;
  PRAGMA EXCEPTION_INIT(Cycle_ERR,-01436);
BEGIN
  IF ReplSession THEN RETURN; END IF;
--  d('BEGIN','SP.CATALOG_TREE_au'); 
  IF SP.TG.AfterUpdateCatalogTree THEN RETURN; END IF;
  SP.TG.AfterUpdateCatalogTree:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_CATALOG_TREE WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Проверяем отсутствие зацикливания по новму родителю.
    -- Новый родитель не должен состоять среди детей текущего узла.
	if rec.NEW_PARENT_ID is not null then
	  SELECT COUNT(*) INTO tmpVar 
      FROM (SELECT ID FROM SP.CATALOG_TREE
              START WITH PARENT_ID=rec.OLD_ID
              CONNECT BY PRIOR ID= PARENT_ID)
      WHERE ID=rec.NEW_PARENT_ID;
--     d('rec.OLD_ID=>'||rec.OLD_ID||'rec.NEW_PARENT_ID'||rec.NEW_PARENT_ID,
--       'SP.CATALOG_TREE_au');  
	  IF (tmpVar>0) OR (rec.OLD_ID=rec.NEW_PARENT_ID) THEN 
      RAISE Cycle_ERR;
	  END IF;
    end if;
	-- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_CATALOG_TREE WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateCatalogTree:= FALSE;
EXCEPTION
  WHEN Cycle_ERR THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033, 'SP.CATALOG_TREE_au.  '||
	    'Изменение родителя узла '||rec.OLD_NAME||' приводит к зацикливанию.');
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.CATALOG_TREE_bdr
BEFORE DELETE ON SP.CATALOG_TREE
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- Проверяем, что данный элемент дерева каталога не используется как ссылка в параметрах TTreeNode
  select count(*) into tmpVar from SP.OBJECT_PAR_S where TYPE_ID = SP.G.TTreeNode and N = :OLD.ID;
  if tmpVar > 0 then
     RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bdr. '||
      'Элемент дерева каталога используется как ссылка в параметрах TTreeNode!');
  end if;
  -- Удалить объект может только администратор.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bdr. '||
      'Недостаточно привелегий для удаления узлов!');
  END IF;
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
--
--*****************************************************************************


-- Объекты.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DELETED_OBJECTS_bi
BEFORE INSERT ON SP.DELETED_OBJECTS
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_OBJECTS;
  IF tmpVar=0 AND SP.TG.AfterDeleteObjects THEN 
    SP.TG.AfterDeleteObjects:= FALSE;
    d('SP.TG.AfterDeleteObjects:= false;','ERROR DELETED_OBJECTS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECTS_bir
BEFORE INSERT ON SP.OBJECTS
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.OBJ_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  IF :NEW.MODIFIED is null THEN :NEW.MODIFIED:=sysdate; END IF;
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
  IF :NEW.OID is null THEN 
    :NEW.OID := SYS_GUID; 
  END IF;
--  -- Пользователь, имеющий роль программиста может добавить макру.
--  d();
--	IF    NOT SP.TG.SP_ADMIN
--    AND :NEW.OBJECT_KIND != SP.G.SINGLE_OBJ
--	THEN
--		SP.TG.ResetFlags;	  
--    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bir.'||
--      ' Недостаточно привелегий для добавления объекта каталога!');
--	END IF;	 
	-- Если роль редактирования неопределена и пользователь не администратор,
  -- то вставляем роль пользователя.
	IF (:NEW.EDIT_ROLE IS NULL) AND (NOT SP.TG.SP_ADMIN) THEN
	   :NEW.EDIT_ROLE:=SP.G.USER_ROLE;
	END IF;
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- Имя объекта не должно содержать ".".
  IF instr(:NEW.NAME,'.')>0 THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bir.'||
      ' Имя объекта каталога '||:NEW.NAME||' не может содержать "."!');
  END IF;	
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECTS_bur
BEFORE UPDATE ON SP.OBJECTS
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  IF :NEW.MODIFIED is null THEN :NEW.MODIFIED:=sysdate; END IF;
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
	-- Редактировать имет право администратор.
  -- Если роль редактирования объекта не нулл, то редактировать объект
  -- может пользователь, имеющий роль редактирования объекта.
  IF NOT SP.TG.SP_ADMIN THEN
		IF   (:OLD.EDIT_ROLE IS NULL)
		  OR NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
		THEN
			SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bur. '||
        'Недостаточно привелегий для изменения объекта: '||:OLD.NAME||'!');
		END IF;
  END IF;
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- Имя объекта не должно содержать ".".
  IF instr(:NEW.NAME,'.')>0 THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bur.'||
      ' Имя объекта каталога '||:NEW.NAME||' не может содержать "."!');
  END IF;	
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_APDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECTS_bdr
BEFORE DELETE ON SP.OBJECTS
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
	IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.OBJECTS_bdr. Нельзя удалять предопределенные объекты!');
	END IF;
  --d('тригер','OBJECTS_bdr');
	-- Удалить объект может только администратор.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bdr. '||
    'Недостаточно привелегий для удаления объекта: '||:OLD.NAME||'!');
  END IF;
	-- Разрешаем каскадное удаление параметров объектов.
  -- и макроопределений.
  SP.TG.ObjectParDeleting:=TRUE;
  --SP.TG.ModObjParDeleting:=true;
  -- Записываем имя объекта.
  -- Имя объекта используется при диагностике ошибок, связанных с удалением
  -- объекта, использующегося в макроопределениях другого объекта каталога.
  SP.TG.DeletingObject := :OLD.NAME;
  INSERT INTO SP.DELETED_OBJECTS 
    VALUES (:OLD.ID, :OLD.OID, :OLD.IM_ID, :OLD.NAME, :OLD.COMMENTS,
            :OLD.OBJECT_KIND,:OLD.GROUP_ID, 
            :OLD.USING_ROLE, :OLD.EDIT_ROLE, :OLD.MODIFIED, :OLD.M_USER);
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECTS_ad
AFTER DELETE ON SP.OBJECTS
--(SP-CATALOG.trg)
DECLARE
	rec SP.DELETED_OBJECTS%ROWTYPE;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  --d('table тригер','OBJECTS_ad');
  SP.TG.ObjectParDeleting:=FALSE;
   IF SP.TG.AfterDeleteObjects THEN RETURN; END IF;
  SP.TG.AfterDeleteObjects:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_OBJECTS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
	  -- Нельзя удалить объект, если он используется в построенных объектах,
    -- которые имеют родителя.
	  SELECT COUNT(*) INTO tmpVar FROM DUAL 
	    WHERE EXISTS (SELECT * FROM SP.MODEL_OBJECTS co 
                      WHERE co.OBJ_ID=rec.OLD_ID
                        AND co.PARENT_MOD_OBJ_ID IS NOT NULL);
	  IF tmpVar>0 THEN 
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033, 'SP.OBJECTS_ad.  '||
	    'Нельзя удалить объект '||rec.OLD_NAME||
      ', используемый в построенных объектах, которые имеют родителя.');
	  END IF;
	  -- Нельзя удалить объект, если он используется в макрокомандах других
    -- объектов каталога.
	  SELECT COUNT(*) INTO tmpVar FROM DUAL 
	    WHERE EXISTS (SELECT * FROM SP.MACROS m 
                      WHERE m.USED_OBJ_ID = rec.OLD_ID);
	  IF tmpVar>0 THEN 
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033, 'SP.OBJECTS_ad.  '||
	    'Нельзя удалить объект '||rec.OLD_NAME||
      ', используемый в марокомандах других объектов каталога.');
	  END IF;
    -- Удаляем обработанную запись.
    DELETE FROM SP.DELETED_OBJECTS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterDeleteObjects:= FALSE;
END;
/

--*****************************************************************************

-- Параметры объектов.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.INSERTED_OBJECT_PAR_S_bi
BEFORE INSERT ON SP.INSERTED_OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_OBJECT_PAR_S;
  IF tmpVar=0 AND SP.TG.AfterInsertObjectPars THEN 
    SP.TG.AfterInsertObjectPars:= FALSE;
    d('SP.TG.AfterInsertObjectPars:= false;','ERROR INSERTED_OBJECT_PAR_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_OBJECT_PAR_S_bi
BEFORE INSERT ON SP.UPDATED_OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_OBJECT_PAR_S;
  IF tmpVar=0 AND SP.TG.AfterUpdateObjectPars THEN 
    SP.TG.AfterUpdateObjectPars:= FALSE;
    d('SP.TG.AfterUpdateObjectPars:= false;','ERROR UPDATED_OBJECT_PAR_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_OBJECT_PAR_S_bi
BEFORE INSERT ON SP.DELETED_OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_OBJECT_PAR_S;
  IF tmpVar=0 AND SP.TG.AfterDeleteObjectPars THEN 
    SP.TG.AfterDeleteObjectPars:= FALSE;
    d('SP.TG.AfterDeleteObjectPars:= false;','ERROR DELETED_OBJECT_PAR_S_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_bir
BEFORE INSERT ON SP.OBJECT_PAR_S
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
	tmpVar NUMBER;
	CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
	TYPE TNDSXY IS RECORD(
	N NUMBER,
	D DATE,
	S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER
	);
	NDSXY TNDSXY;
	NEW_TYPE_ID NUMBER(9);
	NEW_E_VAL SP.ENUM_VAL_S.E_VAL%TYPE;
	V SP.TVALUE;
	ObjName SP.OBJECTS.NAME%TYPE;
  UsingRole NUMBER;
  EditRole NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.OBJ_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  SELECT NAME, USING_ROLE, EDIT_ROLE INTO ObjName, UsingRole, EditRole
    FROM SP.OBJECTS WHERE ID=:NEW.OBJ_ID;
  -- Добавить параметр может администратор или пользователь,
  -- имеющий роль редактирования объекта.
  IF NOT SP.HasUserEditRoleID(EditRole)THEN
	  SP.TG.ResetFlags;	  
	  RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_bir. '||
      'Недостаточно привелегий для изменения объекта: '||ObjName||'!');
  END IF;
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- Проверяем имя добавленного параметра на допустимость.
  IF REGEXP_INSTR(REGEXP_REPLACE(:NEW.NAME,'->','',1,1),
	                '[^[:alnum:]_\$\# ]')>0 
  THEN
	  SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,
     'SP.OBJECT_PAR_S_bir. Параметр имеет недопустимое имя'||
      :NEW.NAME||'!');
  END IF;
	-- Если параметр именованный, то заполняем его значение.
	IF :NEW.E_VAL IS NOT NULL THEN
    NEW_TYPE_ID:=:NEW.TYPE_ID;
  	NEW_E_VAL:=:NEW.E_VAL;
		BEGIN
  	  SELECT e.N,e.D,e.S,e.X,e.Y INTO NDSXY FROM SP.ENUM_VAL_S e
  	    WHERE e.TYPE_ID=NEW_TYPE_ID AND UPPER(e.E_VAL)=UPPER(NEW_E_VAL);
 		EXCEPTION
		  WHEN no_data_found THEN	
  		  SP.TG.ResetFlags;	 
		    RAISE_APPLICATION_ERROR(-20033,
		      'SP.OBJECT_PAR_S_bir. Именованное значение: '||NEW_E_VAL||
          ' не найдено у параметра '||:NEW.NAME||' объекта '||ObjName||
          '!');	 
		END;	 
    :NEW.N := NDSXY.N;
    :NEW.D := NDSXY.D; 
    :NEW.S := NDSXY.S; 
  	:NEW.X := NDSXY.X;
  	:NEW.Y := NDSXY.Y;
	END IF;	  
	-- Если процедура проверки значения определена, то проверяем значение
  -- параметра. 
	BEGIN
    SELECT pt.CHECK_VAL INTO CheckVal FROM SP.PAR_TYPES pt 
      WHERE pt.ID=NEW_TYPE_ID;
  EXCEPTION
	  WHEN no_data_found THEN NULL;
	END;																			 
  IF CheckVal IS NOT NULL THEN 
		V:=SP.TVALUE(:NEW.TYPE_ID,null, 0,
                 :NEW.E_VAL,:NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y);
    SP.CheckVal(CheckVal,V); 
  END IF;
  -- Есле не задана группа, то присваиваем значение по умолчанию.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF;
  IF :NEW.M_USER is null THEN
    if TG.UserName is null then
      RAISE_APPLICATION_ERROR(-20033,
        'SP.OBJECT_PAR_S_bir. Потеря переменных пакета,' ||
        ' необходимо осуществить вход заново!');
    end if;    
    :NEW.M_USER := TG.UserName; 
  END IF;
  INSERT INTO SP.INSERTED_OBJECT_PAR_S 
    VALUES(:NEW.ID,:NEW.NAME,:NEW.COMMENTS,:NEW.TYPE_ID,:NEW.E_VAL,
           :NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y,:NEW.R_ONLY,
           :NEW.OBJ_ID, :NEW.GROUP_ID,
           :NEW.M_DATE, :NEW.M_USER);
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_ai
AFTER INSERT ON SP.OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
	rec SP.INSERTED_OBJECT_PAR_S%ROWTYPE;
  tmpVar NUMBER;
  MType NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertObjectPars THEN RETURN; END IF;
  SP.TG.AfterInsertObjectPars:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_OBJECT_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- Выясняем, существует ли у объекта одноимённый параметр и
    -- если таковой существует, то его тип.     
      select count(*), min(TYPE_ID) into tmpVar, MType
        from SP.MODEL_OBJECTS mo, SP.MODEL_OBJECT_PAR_S mp 
        where UPPER(MP.NAME) = UPPER(rec.NEW_NAME)
          and MO.ID = MP.MOD_OBJ_ID
          and MO.OBJ_ID = rec.NEW_OBJ_ID;
    -- Если параметр только для чтения и у объектов модели существуют
    -- переопределённые значения, то возбуждаем ошибку. 
    if rec.NEW_R_ONLY = SP.G.READONLY 
    then
      if tmpVar > 0 then 
        SP.TG.ResetFlags;   
        RAISE_APPLICATION_ERROR(-20033,
          'SP.OBJECT_PAR_S_ai. Добавляемый параметр '||rec.NEW_NAME||
          ' определён только для чтения, однако '||
           tmpVar||' экземпляр(ов) данного объекта уже содержат '||
           'переопределённые значения.'||
           ' Удалите эти значения или переименуйте параметр!');   
      end if;
    end if;     
    -- Если у объектов модели существуют переопределённые значения,
    -- а тип не совпадает, то возбуждаем ошибку. 
    if (tmpVar > 0) and (rec.NEW_TYPE_ID != MType) 
    then
      SP.TG.ResetFlags;   
      RAISE_APPLICATION_ERROR(-20033,
        'SP.OBJECT_PAR_S_ai. Тип добавляемого параметра '||rec.NEW_NAME||
        ' не совпадает с уже содержащимися у '||
         tmpVar||' экземпляр(ов) данного объекта значениями.'||
         ' Удалите эти значения или переименуйте параметр!');   
    end if;     
    -- Добавляем идентификатор параметра в уже существующие параметры объектов
    -- и имеющие совпадающие с ним имя и тип.
    UPDATE SP.MODEL_OBJECT_PAR_S mp
      set OBJ_PAR_ID = rec.NEW_ID,
          NAME = null,
          TYPE_ID = rec.NEW_TYPE_ID,
          R_ONLY = rec.NEW_R_ONLY
      WHERE (mp.MOD_OBJ_ID IN (SELECT ID 
                             FROM SP.MODEL_OBJECTS mo 
                             WHERE mo.OBJ_ID = rec.NEW_OBJ_ID))
        AND (mp.NAME = rec.NEW_NAME)
    ;
    -- Удаляем обработанную запись.
    DELETE FROM SP.INSERTED_OBJECT_PAR_S up WHERE up.NEW_ID=rec.NEW_ID;
	END LOOP;
  SP.TG.AfterInsertObjectPars:= FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_bur
BEFORE UPDATE ON SP.OBJECT_PAR_S
FOR EACH ROW
--(SP-CATALOG.trg)
DECLARE
	tmpVar NUMBER;
	TYPE TNDSXY IS RECORD(
	N NUMBER,
	D DATE,
	S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER
	);
	NDSXY TNDSXY;
	NEW_E_VAL SP.ENUM_VAL_S.E_VAL%TYPE;
BEGIN
  --d('тригер','SP.OBJECT_PAR_S_bur');
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  :NEW.OBJ_ID:=:OLD.OBJ_ID;
  -- Обрезаем пробелы и переводы строк.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- Если изменено имя, то проверяем его на допустимость.
	IF SP.G.notUpEQ(:NEW.NAME,:OLD.NAME) THEN
		IF REGEXP_INSTR(REGEXP_REPLACE(:NEW.NAME,'->','',1,1),
		                '[^[:alnum:]_\$\# ]')>0 
		THEN
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033,
	     'SP.OBJECT_PAR_S_bur. Параметр имеет недопустимое имя'||
	      :NEW.NAME||'!');
    END IF;    
  END IF;
  -- Есле не задана группа, то присваиваем значение по умолчанию.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- Если параметр именованный, то поле "E_VAL" не нулл.
   -- Проверяем поле "E_VAL" по новому значению,
   -- чтобы предоставить возможность изменить изменить тип.
   -- Если изменено имя значения, то заполняем значение.
   -- Если изменилось значение, а имя осталось старым, то изменяем имя. 
	CASE
		-- Если изменено поле "E_VAL", то заполняем значение параметра
     -- в соответствии с именем значения.
	  WHEN  SP.G.notUpEQ(:OLD.E_VAL,:NEW.E_VAL) 
			AND	(:NEW.E_VAL IS NOT NULL)
		THEN
			BEGIN
	  	  SELECT e.N,e.D,e.S,e.X,e.Y INTO NDSXY FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID=:NEW.TYPE_ID AND UPPER(e.E_VAL)=UPPER(:NEW.E_VAL);
			EXCEPTION
			  WHEN no_data_found THEN	
		      SP.TG.ResetFlags;	  
				  RAISE_APPLICATION_ERROR(-20033,
		        'SP.FRAME_PAR_S_bur. Именованное значение '||:NEW.E_VAL||
				    ' не найдено, для параметра '||:NEW.NAME||'!');
			END;	 
	    :NEW.N := NDSXY.N;
	    :NEW.D := NDSXY.D; 
	    :NEW.S := NDSXY.S; 
	  	:NEW.X := NDSXY.X;
	  	:NEW.Y := NDSXY.Y;
		-- Если поле "E_VAL" не нулл, а значене изменено,
     -- то находим имя параметра.
		WHEN  :NEW.E_VAL IS NOT NULL
       AND (SP.G.S_EQ(:OLD.N,:NEW.N)
					*SP.G.S_EQ(:OLD.D,:NEW.D)
					*SP.G.S_EQ(:OLD.S,:NEW.S)
					*SP.G.S_EQ(:OLD.X,:NEW.X)
          *SP.G.S_EQ(:OLD.Y,:NEW.Y)=0)
		THEN
			BEGIN
	  	  SELECT e.E_VAL INTO NEW_E_VAL FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID=:NEW.TYPE_ID 
					  AND (SP.G.S_EQ(e.N,:NEW.N)+
					       SP.G.S_EQ(e.D,:NEW.D)+
					       SP.G.S_EQ(e.S,:NEW.S)+
					       SP.G.S_EQ(e.X,:NEW.X)+
					       SP.G.S_EQ(e.Y,:NEW.Y)
					       =5);
				:NEW.E_VAL:=NEW_E_VAL;				 
			EXCEPTION
			  WHEN no_data_found THEN	
		      SP.TG.ResetFlags;	  
				  RAISE_APPLICATION_ERROR(-20033,
		        'SP.OBJECT_PAR_S_bur. Именованное значение '||:NEW.E_VAL||
				    ' не найдено, для параметра '||:NEW.NAME||'!');
			END;	 
	ELSE
	  -- Значение не именованное. 
    NULL;
	END CASE;
  -- Протоколируем дату изменения и пользователя, изменившего запись,
  -- если это не импорт данных
  if not Tg.ImportDATA then
    :NEW.M_DATE := sysdate;
    :NEW.M_USER := TG.UserName; 
  end if;  
  -- Если изменено значение параметра и это объект каталога,
  -- а не имя мароопределения,
  -- или изменён тип параметра или признак R_ONLY,
  -- то устанавливаем признак изменения во всех построенных объектах,
  -- которые основаны на этом объекте.
  INSERT INTO SP.UPDATED_OBJECT_PAR_S 
    VALUES(:NEW.ID,:NEW.NAME,:NEW.COMMENTS,:NEW.TYPE_ID,:NEW.E_VAL,
	         :NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y,:NEW.R_ONLY,
           :NEW.OBJ_ID, :NEW.GROUP_ID,
           :NEW.M_DATE, :NEW.M_USER,
	         :OLD.ID,:OLD.NAME,:OLD.COMMENTS,:OLD.TYPE_ID,:OLD.E_VAL,
	         :OLD.N,:OLD.D,:OLD.S,:OLD.X,:OLD.Y,:OLD.R_ONLY,
           :OLD.OBJ_ID, :OLD.GROUP_ID,
           :OLD.M_DATE, :OLD.M_USER);      
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_au
AFTER UPDATE ON SP.OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
	CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
	V SP.TVALUE;
	rec SP.UPDATED_OBJECT_PAR_S%ROWTYPE;
  ObjName SP.OBJECTS.NAME%TYPE;
  ObjType SP.OBJECTS.OBJECT_KIND%TYPE;
  EditRole NUMBER;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateObjectPars 
  THEN 
    --d('table тригер => return ','OBJECT_PAR_S_au');
    RETURN; 
  END IF;
  SP.TG.AfterUpdateObjectPars:= TRUE;
  --d('table тригер','OBJECT_PAR_S_au');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_OBJECT_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    SELECT NAME, OBJECT_KIND, EDIT_ROLE INTO ObjName, ObjType, EditRole 
      FROM SP.OBJECTS
		  WHERE ID=rec.OLD_OBJ_ID;
	  -- Редактировать имет право администратор.
	  -- Если роль редактирования объекта не нулл, то редактировать объект
	  -- может пользователь, имеющий роль редактирования объекта.
		IF NOT SP.HasUserEditRoleID(EditRole) THEN		
			SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_au.'||
        ' Недостаточно привелегий для изменения объекта: '||ObjName||'!');
    END IF;
		-- Если процедура проверки значения определена, то проверяем значение на
    -- соответствия его типу. 
		SELECT CHECK_VAL INTO CheckVal FROM SP.PAR_TYPES
			WHERE ID=rec.NEW_TYPE_ID;
    IF CheckVal IS NOT NULL THEN 
  		V:=SP.TVALUE(rec.NEW_TYPE_ID, null, 0, rec.NEW_E_VAL,
                   rec.NEW_N, rec.NEW_D, rec.NEW_S, rec.NEW_X, rec.NEW_Y);
      SP.CheckVal(CheckVal,V); 
    ELSE
      BEGIN
    		SELECT N,D,S,X,Y 
      	INTO rec.NEW_N, rec.NEW_D, rec.NEW_S, rec.NEW_X, rec.NEW_Y 
          FROM SP.ENUM_VAL_S e
		  	    WHERE e.TYPE_ID=rec.NEW_TYPE_ID 
						  AND e.E_VAL=rec.NEW_E_VAL;
			EXCEPTION
			  WHEN no_data_found THEN	
		      SP.TG.ResetFlags;	  
				  RAISE_APPLICATION_ERROR(-20033,
		      'SP.OBJECT_PAR_S_au. Именованное значение '||rec.NEW_E_VAL||
				  ' не найдено, для параметра '||rec.NEW_NAME||'!');
       END;    
    END IF;
    -- Если изменено значение параметра и это объект каталога,
    -- а не имя мароопределения,
    -- или изменён тип параметра или признак R_ONLY,
    -- то устанавливаем признак изменения во всех построенных объектах,
    -- которые основаны на этом объекте.
    IF   (rec.NEW_TYPE_ID != rec.OLD_TYPE_ID)
      OR (rec.NEW_R_ONLY != rec.OLD_R_ONLY)
      OR (	(SP.G.notUpEQ(rec.NEW_E_VAL,rec.OLD_E_VAL)
               OR SP.G.notEQ(rec.NEW_N,rec.OLD_N)
               OR SP.G.notEQ(rec.NEW_D,rec.OLD_D)
               OR SP.G.notEQ(rec.NEW_S,rec.OLD_S)
               OR SP.G.notEQ(rec.NEW_X,rec.OLD_X)
  		         OR SP.G.notEQ(rec.NEW_Y,rec.OLD_Y))
          AND (ObjType=G.SINGLE_OBJ)
         )      
  	THEN
      -- Добавляем идентификатор параметра в параметры объектов, созданных на
      -- основании данного и имеющих совпадающее имя.
      -- Объекты могли уже содержать параметр с аналогичным именем.
      UPDATE SP.MODEL_OBJECT_PAR_S mp
        set OBJ_PAR_ID = rec.NEW_ID,
            NAME = null
        WHERE (mp.MOD_OBJ_ID IN (SELECT ID 
                               FROM SP.MODEL_OBJECTS mo 
                               WHERE mo.OBJ_ID = rec.OLD_OBJ_ID))
          AND (mp.NAME = rec.NEW_NAME)
      ;
      -- Если изменён тип параметра,
      -- то удаляем все переопределённные значения параметра и его историю.
      IF rec.NEW_TYPE_ID != rec.OLD_TYPE_ID THEN
--        UPDATE SP.MODEL_OBJECT_PAR_S set TYPE_ID = rec.NEW_TYPE_ID
--          WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=TRUE;
          DELETE FROM SP.MODEL_OBJECT_PAR_S WHERE OBJ_PAR_ID = rec.OLD_ID;
          DELETE FROM SP.MODEL_OBJECT_PAR_STORIES WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=FALSE;
      END IF;
      -- Если параметр стал R_Only, то удаляем все параметры объектов модели,
      -- со ссылками на этот параметр? а также его историю.
      IF rec.NEW_R_ONLY = G.ReadOnly THEN
        SP.TG.ModObjParDeleting :=TRUE;
          DELETE FROM SP.MODEL_OBJECT_PAR_S WHERE OBJ_PAR_ID = rec.OLD_ID;
          DELETE FROM SP.MODEL_OBJECT_PAR_STORIES WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=FALSE;
      END IF;
    END IF;
    -- Если параметр только для чтения и у объекта каталога изменено имя, 
    -- а у объектов модели существуют переопределённые значения,
    -- то возбуждаем ошибку. 
    if rec.NEW_R_ONLY = SP.G.READONLY
      and UPPER(rec.NEW_NAME) != UPPER(rec.NEW_NAME)
    then
      select count(*) into tmpVar
        from SP.MODEL_OBJECTS mo, SP.MODEL_OBJECT_PAR_S mp 
        where UPPER(MP.NAME) = UPPER(rec.NEW_NAME)
          and MO.ID = MP.MOD_OBJ_ID
          and MO.OBJ_ID = rec.NEW_OBJ_ID;
      if tmpVar > 0 then 
        SP.TG.ResetFlags;   
        RAISE_APPLICATION_ERROR(-20033,
          'SP.OBJECT_PAR_S_au. Добавляемый параметр '||rec.NEW_NAME||
          ' определён только для чтения, однако '||
           tmpVar||' экземпляр(ов) данного объекта уже содержат '||
           'переопределённые значения.'||
           ' Удалите эти значения или не используйте это имя для параметра!');   
      end if;
    end if; 
    -- Если изменён модификатор чтения параметров, то изменяем его у всех
    -- переопределённых параметров.
    if rec.NEW_R_ONLY != rec.OLD_R_ONLY then
      UPDATE SP.MODEL_OBJECT_PAR_S set R_ONLY = rec.NEW_R_ONLY
        WHERE OBJ_PAR_ID = rec.OLD_ID;
    end if;
    -- Если новое значение R_ONLY не предполагает сохранение истории,
    -- а старое предполагало,
    -- то удаляем историю для всех объектов модели.
    if    (rec.NEW_R_ONLY = SP.G.STORYLESS)
      and (rec.OLD_R_ONLY != SP.G.READONLY)
    then
      -- Устанавливаем флаг для триггера удаления истории, 
      -- чтобы он не создавал временную таблицу.
      SP.TG.ModObjParDeleting := true;
      begin
        delete from SP.MODEL_OBJECT_PAR_STORIES s
          where S.OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting := false;
      exception
        when others then
          SP.TG.ResetFlags;
          raise;  
      end;  
    end if;
    -- 
    -- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_OBJECT_PAR_S up WHERE up.NEW_ID=rec.NEW_ID;  
	END LOOP;
  SP.TG.AfterUpdateObjectPars := FALSE;
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_bdr
BEFORE DELETE ON SP.OBJECT_PAR_S
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  --d('тригер','SP.OBJECT_PAR_S_bdr');
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.OBJECTS_bdr. Нельзя удалять предопределенные параметры объектов!');
  END IF;
  -- Разрешаем удалять  параметры построенных компонентов,
  -- наследнующие этот параметр.
  SP.TG.ModObjParDeleting :=TRUE;
  -- Если это каскадное удаление параметров после удаления объекта, то выход.
  IF SP.TG.ObjectParDeleting THEN RETURN; END IF;
  -- Проверку привилегий пользователя и установку признаков изменения у
  -- созданных объектов производим в табличном триггере.
  INSERT INTO SP.DELETED_OBJECT_PAR_S VALUES
    (:OLD.ID, :OLD.NAME, :OLD.COMMENTS, :OLD.TYPE_ID,
     :OLD.E_VAL, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y, :OLD.R_ONLY,
     :OLD.OBJ_ID, :OLD.GROUP_ID,
     :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.OBJECT_PAR_S_ad
AFTER DELETE ON SP.OBJECT_PAR_S
--(SP-CATALOG.trg)
DECLARE
	Cycle_ERR EXCEPTION;
	PRAGMA EXCEPTION_INIT(Cycle_ERR,-01436);
	rec SP.DELETED_OBJECT_PAR_S%ROWTYPE;
  ObjName SP.OBJECT_PAR_S.NAME%TYPE;
  EditRole NUMBER;
  tmpVar NUMBER;
BEGIN
  --d('table тригер','OBJECT_PAR_S_ad');
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterDeleteObjectPars THEN RETURN; END IF;
  SP.TG.AfterDeleteObjectPars:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_OBJECT_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
	  BEGIN
	    SELECT NAME, EDIT_ROLE INTO ObjName,  EditRole
	      FROM SP.OBJECTS WHERE ID=rec.OLD_OBJ_ID;
		EXCEPTION
 			-- Каскадное удаление параметров после удаления фрейма.
	  	WHEN no_data_found THEN GOTO NEXT_RECORD;
  	END;
	  -- Удалить параметр может администратор или пользователь, имеющий роль
    -- редактирования объекта.
	  IF NOT SP.HasUserEditRoleID(EditRole)	THEN
			BEGIN
		 		RAISE Cycle_ERR;
		 	EXCEPTION
		   	WHEN Cycle_ERR THEN
					SP.TG.ResetFlags;	  
			    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_ad. '||
		        'Недостаточно привелегий для изменения объекта: '||
		        ObjName||'!');
      END;    
	  END IF;
	  -- Удаляем обработанную запись.
    DELETE FROM SP.DELETED_OBJECT_PAR_S WHERE OLD_ID=rec.OLD_ID; 
    <<NEXT_RECORD>> NULL;
	END LOOP;	  
  SP.TG.AfterDeleteObjectPars:= FALSE;
  SP.TG.ModObjParDeleting :=FALSE;
END;
/

-- end of file


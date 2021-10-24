-- SP DOCS tables triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.10.2013
-- update 10.10.2013 14.06.2014
--*****************************************************************************


-- SP.DOCS
-------------------------------------------------------------------------------
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.INSERTED_DOCS_bi
BEFORE INSERT ON SP.INSERTED_DOCS
--(SP-DOCS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_DOCS;
  IF tmpVar=0 AND SP.TG.AfterInsertDOCs THEN 
    SP.TG.AfterInsertDOCs:= FALSE;
    d('SP.TG.AfterInsertDOCs:= false;','ERROR INSERTED_DOCS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_DOCS_bi
BEFORE INSERT ON SP.UPDATED_DOCS
--(SP-DOCS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_DOCS;
  IF tmpVar=0 AND SP.TG.AfterUpdateDOCs THEN 
    SP.TG.AfterUpdateDOCs:= FALSE;
    d('SP.TG.AfterUpdateDOCs:= false;','ERROR UPDATED_DOCS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_DOCS_bi
BEFORE INSERT ON SP.DELETED_DOCS
--(SP-DOCS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_DOCS;
  IF tmpVar=0 AND SP.TG.AfterDeleteDOCs THEN 
    SP.TG.AfterDeleteDOCs:= FALSE;
    d('SP.TG.AfterDeleteDOCs:= false;','ERROR DELETED_DOCS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_bir
BEFORE INSERT ON SP.DOCS 
FOR EACH ROW
--(SP-DOCS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.DOC_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  IF :NEW.PREV_ID IS NULL THEN
    -- Если у параграфа ссылка на предыдущий параграф отсутствует,
    -- то вставляем параграф в конец, присваивая
    -- ему ссылку на последний параграф.
    BEGIN
	    SELECT ID INTO :NEW.PREV_ID FROM SP.DOCS 
           WHERE GROUP_ID=:NEW.GROUP_ID
             AND CONNECT_BY_ISLEAF=1
	         START WITH PREV_ID IS NULL
	         CONNECT BY PREV_ID = PRIOR ID;
    EXCEPTION
      -- Если ничего не нашли - значит это первый параграф группы документа.
      WHEN NO_DATA_FOUND THEN NULL;
    END; 
  ELSE   
	  -- Проверяем, что предыдущий параграф принадлежит той же группе, что и 
    -- добавляемый.
    SELECT GROUP_ID INTO tmpVar FROM SP.DOCS 
        WHERE ID = :NEW.PREV_ID;
    IF tmpVar != :NEW.GROUP_ID THEN
		  SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_bir.'||
        ' Ссылка на предыдущий параграф, принадлежащий другой группе!');
    END IF;    
  END IF;
  -- Инициируем ошибку, если ссылка на предыдущий параграф ссылается на себя.
  IF :NEW.ID=:NEW.PREV_ID THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_bir. Ссылка на себя!');
  END IF;
  -- Инициируем ошибку, если длинна параграфа, с учётом удвоения при экспорте
  -- содержащихся в нём кавычек, превзойдёт 4000.
  IF length(Q_QQ(:NEW.PARAGRAPH)) >=4000 THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_bir. Превышен размер блока!');
  END IF;
  if :NEW.M_DATE is null then :NEW.M_DATE := sysdate; end if;
  if :NEW.M_USER is null then :NEW.M_USER := tg.UserName; end if;
  -- Редактировать имет право администратор.
  -- Добавить параграф может пользователь, имеющий роль редактирования группы,
  -- в которую он собирается его добавить.
  INSERT INTO SP.INSERTED_DOCS 
    VALUES(:NEW.ID,	:NEW.PREV_ID, :NEW.PARAGRAPH, :NEW.IMAGE_ID,
           :NEW.FORMAT_ID, :NEW.GROUP_ID, :NEW.USING_ROLE,
           :NEW.M_DATE, :NEW.M_USER);
EXCEPTION 
  WHEN OTHERS THEN 
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_bir. '||SQLERRM||'!');
END;
/
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_ai
AFTER INSERT ON SP.DOCS
--(SP-DOCS.trg)
DECLARE
	rec SP.INSERTED_DOCS%ROWTYPE;
  GName SP.GROUPS.NAME%type;
  EditRole NUMBER;
  tmpVar NUMBER;
  err BOOLEAN;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertDOCs 
  THEN 
    --d('table тригер => return ','DOCS_ai');
    RETURN; 
  END IF;
  SP.TG.AfterInsertDOCs:= TRUE;
  --d('table тригер','DOCS_ai');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_DOCS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
	  -- Редактировать параграф имет право администратор.
	  -- Если роль редактирования группы не нулл, то редактировать параграф
	  -- может пользователь, имеющий роль редактирования группы.
    SELECT NAME, EDIT_ROLE INTO GName, EditRole FROM SP.GROUPS
	  WHERE ID=rec.NEW_GROUP_ID;
		IF NOT SP.HasUserEditRoleID(EditRole) THEN
			SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_au.'||
        ' Недостаточно привелегий для изменения параграфа: '||GName||'!');
    END IF;
    -- Удаляем обработанную запись.
    DELETE FROM SP.INSERTED_DOCS WHERE NEW_ID=rec.NEW_ID;  
	END LOOP;
  SP.TG.AfterInsertDOCs := FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_bur
BEFORE UPDATE ON SP.DOCS 
FOR EACH ROW
--(SP-DOCS.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID:=:OLD.ID;
  -- Инициируем ошибку, если длинна параграфа, с учётом удвоения при экспорте
  -- содержащихся в нём кавычек, превзойдёт 4000.
  IF length(Q_QQ(:NEW.PARAGRAPH)) >=4000 THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_bur. Превышен размер блока!');
  END IF;
  if (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) then 
    :NEW.M_DATE := sysdate; 
  end if;
  if (:NEW.M_USER is null) or (:NEW.M_USER = :OLD.M_USER) then 
    :NEW.M_USER := tg.UserName;
  end if;
  -- В табличном триггере выполняем следующее.
  -- Проверяем, что только администратор или пользователь,
  -- имеющий права редактирования группы параграфа, имеет право изменять сам
  -- параграф.
  -- Два последовательных параграфа могут принадлежать только одной группе.
  INSERT INTO SP.UPDATED_DOCS 
    VALUES(:NEW.ID,	:NEW.PREV_ID, :NEW.PARAGRAPH, :NEW.IMAGE_ID,
           :NEW.FORMAT_ID, :NEW.GROUP_ID, :NEW.USING_ROLE,
           :NEW.M_DATE, :NEW.M_USER,
           :OLD.ID,	:OLD.PREV_ID, :OLD.PARAGRAPH, :OLD.IMAGE_ID,
           :OLD.FORMAT_ID, :OLD.GROUP_ID, :OLD.USING_ROLE,
           :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_au
AFTER UPDATE ON SP.DOCS
--(SP-DOCS.trg)
DECLARE
	rec SP.UPDATED_DOCS%ROWTYPE;
  GName SP.GROUPS.NAME%type;
  EditRole NUMBER;
  tmpVar NUMBER;
  err BOOLEAN;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateDOCs
  THEN
    --d('table тригер => return ','DOCS_au');
    RETURN;
  END IF;
  SP.TG.AfterUpdateDOCs:= TRUE;
  --d('table тригер!!!','DOCS_au');
  LOOP
    BEGIN
      SELECT * INTO rec
        FROM (SELECT * FROM SP.UPDATED_DOCs) WHERE ROWNUM=1;
      --d('execute','DOCS_au');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        --d('exit','DOCS_au');
        EXIT;
    END;
    --d('select NAME','DOCS_au');
    SELECT NAME, EDIT_ROLE INTO GName, EditRole FROM SP.GROUPS
		  WHERE ID=rec.OLD_GROUP_ID;
	  -- Проверяем, что только администратор или пользователь,
	  -- имеющий права редактирования группы параграфа, имеет право изменять сам
	  -- параграф.
		IF NOT SP.HasUserEditRoleID(EditRole) THEN
			SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_au.'||
        ' Недостаточно привелегий для изменения параграфа: '||GName||'!');
    END IF;
	  -- Если изменёна ссылка на предыдущую строку, то проверяем,
    -- что предыдущая строка принадлежит той же группе, что и текущая.
    IF     G.notEQ(rec.NEW_PREV_ID,rec.OLD_PREV_ID) 
      AND (rec.NEW_PREV_ID IS NOT NULL)
    THEN
      --d('select GR','DOCS_au');
	    SELECT GROUP_ID INTO tmpVar FROM SP.DOCS
        WHERE ID = rec.NEW_PREV_ID;
      IF tmpVar != rec.NEW_GROUP_ID THEN
			  SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_au.'||
          ' Ссылка на предыдущий параграф, принадлежащий другой группе!');
      END IF;
    END IF;
    -- Удаляем обработанную запись.
    --d('Удаляем обработанную запись','DOCS_au');
    DELETE FROM SP.UPDATED_DOCS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateDOCs := FALSE;
  --d('end','DOCS_au');
 END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_bdr
BEFORE DELETE ON SP.DOCS FOR EACH ROW
--(SP-DOCS.trg)
BEGIN
  --d(TO_CHAR(:OLD.ID),'DOCS_bdr');
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.DOCS_bdr. Нельзя удалять предопределенные строки!');
  END IF;
  -- !Если это каскадное удаление праграфов после удаления группы,
  -- то выход.
  --IF SP.TG.ObjectParDeleting! THEN 
    --d('return','DOCS_bdr'); 
  --  RETURN;
  --END IF;
  -- Табличный триггер.
  -- Проверяем, что только администратор или пользователь,
	-- имеющий права редактирования группы параграфа, имеет право удалить сам
	-- параграф.
  --d('insert','DOCS_bdr'); 
  INSERT INTO SP.DELETED_DOCS 
    VALUES(:OLD.ID,	:OLD.PREV_ID, :OLD.PARAGRAPH, :OLD.IMAGE_ID,
           :OLD.FORMAT_ID, :OLD.GROUP_ID, :OLD.USING_ROLE,
           :OLD.M_DATE, :OLD.M_USER);
  --d('end','DOCS_bdr'); 
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.DOCS_ad
AFTER DELETE ON SP.DOCS
--(SP-DOCS.trg)
DECLARE
	rec SP.DELETED_DOCS%ROWTYPE;
  tmpVar NUMBER;
  GName SP.GROUPS.NAME%TYPE;
  EditRole NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterDeleteDOCs 
  THEN 
    --d('table тригер => return ','DOCS_ad');
    RETURN; 
  END IF;
  SP.TG.AfterDeleteDOCs:= TRUE;
  --d('table тригер','DOCS_ad');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_DOCs WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'DOCS_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','DOCS_ad');
        EXIT;
    END;
    BEGIN
	    SELECT NAME, EDIT_ROLE INTO GName, EditRole 
	      FROM SP.GROUPS
			  WHERE ID=rec.OLD_GROUP_ID;
      -- Проверяем, что только администратор или пользователь,
	    -- имеющий права редактирования группы параграфа, имеет право удалить сам
	    -- параграф.
			IF NOT SP.HasUserEditRoleID(EditRole) THEN		
				SP.TG.ResetFlags;	  
	      RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_ad.'||
	        ' Недостаточно привелегий для удаления параграфа: '||GName||'!');
	    END IF;
    EXCEPTION
      -- Если нет группы, то нет и проблемм.
      WHEN NO_DATA_FOUND THEN 
        d('NO_DATA_FOUND','DOCS_ad');
	      RAISE_APPLICATION_ERROR(-20033,'SP.DOCS_ad.'||
	        ' Непредусмотренное каскадное удаление?');
    END;      
    -- Удаляем обработанную запись.
    --d('delete current','DOCS_ad');
    DELETE FROM SP.DELETED_DOCS WHERE OLD_ID=rec.OLD_ID;  
	END LOOP;
  SP.TG.AfterDeleteDOCs := FALSE;
END;
/


-- end of file

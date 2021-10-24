-- SP Trans tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 15.09.2014
-- update 25.09.2014
--*****************************************************************************

-- BEFORE_INSERT_TABLE----------------------------------------
CREATE OR REPLACE TRIGGER SP.INSERTED_TRANS_bi
BEFORE INSERT ON SP.INSERTED_TRANS
--(SP-TRANS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_TRANS;
  IF tmpVar=0 AND SP.TG.AfterInsertTrans THEN 
    SP.TG.AfterInsertTrans:= FALSE;
    d('SP.TG.AfterInsertTrans:= false;','ERROR INSERTED_TRANS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_TRANS_bi
BEFORE INSERT ON SP.UPDATED_TRANS
--(SP-TRANS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_TRANS;
  IF tmpVar=0 AND SP.TG.AfterUpdateTrans THEN 
    SP.TG.AfterUpdateTrans:= FALSE;
    d('SP.TG.AfterUpdateTrans:= false;','ERROR UPDATED_TRANS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_TRANS_bi
BEFORE INSERT ON SP.DELETED_TRANS
--(SP-TRANS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_TRANS;
  IF tmpVar=0 AND SP.TG.AfterDeleteTRANS THEN 
    SP.TG.AfterDeleteTRANS:= FALSE;
    d('SP.TG.AfterDeleteTRANS:= false;','ERROR DELETED_TRANS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_bir
BEFORE INSERT ON SP.TRANS
FOR EACH ROW
--(SP-TRANS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.TRANS_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  INSERT INTO SP.INSERTED_TRANS
	  VALUES(:NEW.ID, :NEW.D, :NEW.BLOCK_ID, :NEW.BUH_ID, :NEW.S, :NEW.N,
           :NEW.A_DEBET, :NEW.C_DEBET,  :NEW.A_CREDIT,  :NEW.C_CREDIT,
           :NEW.MACRO, :NEW.COMMENTS, :NEW.VALIDATED, 
           :NEW.M_DATE,:NEW.M_USER);
END;
/

--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_ai
AFTER INSERT ON SP.TRANS
--(SP-TRANS.trg)
DECLARE
	rec SP.INSERTED_TRANS%ROWTYPE;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertTrans THEN RETURN; END IF;
  SP.TG.AfterInsertTrans:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_TRANS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
-- 		-- Проверяем типы объектов. 
-- 		SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS WHERE ID = rec.NEW_OBJ_ID;
-- 		IF tmpVar != 0 THEN
-- 		  RAISE_APPLICATION_ERROR(-20033,
-- 	      'SP.MODEL_OBJECT_S_ai.'||' Объект должен быть простого типа!');
-- 		END IF;
    -- Добавляем или изменяем
    DELETE FROM SP.INSERTED_TRANS it WHERE it.NEW_ID=rec.NEW_ID;
	END LOOP;
  SP.TG.AfterInsertTrans:= FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_bur
BEFORE UPDATE ON SP.TRANS
FOR EACH ROW
--(SP-TRANS.trg)
DECLARE
  Modified BOOLEAN;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  INSERT INTO SP.UPDATED_TRANS
	    VALUES(:NEW.ID, :NEW.D, :NEW.BLOCK_ID, :NEW.BUH_ID, :NEW.S, :NEW.N,
           :NEW.A_DEBET, :NEW.C_DEBET,  :NEW.A_CREDIT,  :NEW.C_CREDIT,
           :NEW.MACRO, :NEW.COMMENTS, :NEW.VALIDATED, 
           :NEW.M_DATE,:NEW.M_USER,
	         :OLD.ID, :OLD.D, :OLD.BLOCK_ID, :OLD.BUH_ID, :OLD.S, :OLD.N,
           :OLD.A_DEBET, :OLD.C_DEBET,  :OLD.A_CREDIT,  :OLD.C_CREDIT,
           :OLD.MACRO, :OLD.COMMENTS, :OLD.VALIDATED, 
           :OLD.M_DATE,:OLD.M_USER);      
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_au
AFTER UPDATE ON SP.TRANS
--(SP-TRANS.trg)
 DECLARE
 	rec SP.UPDATED_TRANS%ROWTYPE;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateTrans THEN RETURN; END IF;
  SP.TG.AfterUpdateTrans:= TRUE;
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_TRANS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    -- Удаляем обработанную запись.
    DELETE FROM SP.UPDATED_TRANS ut WHERE ut.NEW_ID=rec.NEW_ID;
 	END LOOP;
  SP.TG.AfterUpdateTrans:= FALSE;
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_bdr
BEFORE DELETE ON SP.TRANS
FOR EACH ROW
--(SP-TRANS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
	INSERT INTO SP.DELETED_TRANS
	  VALUES(:OLD.ID, :OLD.D, :OLD.BLOCK_ID, :OLD.BUH_ID, :OLD.S, :OLD.N,
           :OLD.A_DEBET, :OLD.C_DEBET,  :OLD.A_CREDIT,  :OLD.C_CREDIT,
           :OLD.MACRO, :OLD.COMMENTS, :OLD.VALIDATED, 
           :OLD.M_DATE,:OLD.M_USER);      
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.TRANS_ad
AFTER DELETE ON SP.TRANS
--(SP-TRANS.trg)
DECLARE
tmpVar NUMBER;
Name SP.COMMANDS.COMMENTS%TYPE;
rec SP.DELETED_TRANS%ROWTYPE;
BEGIN
  IF ReplSession THEN return; END IF;
  IF TG.AfterDeleteTrans THEN return; END IF;
  TG.AfterDeleteTrans:= TRUE;
  --d('table тригер','TRANS_ad');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_TRANS WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'TRANS_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','TRANS_ad');
        EXIT;
    END;
    -- Удаляем обработанную запись.
    --d('delete current','TRANS_ad');
    DELETE FROM SP.DELETED_TRANS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  TG.AfterDeleteTrans := FALSE;
END;
/
-- end of file

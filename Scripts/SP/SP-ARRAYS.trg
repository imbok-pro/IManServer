-- SP ARRAYS tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.01.2018
-- update 19.01.2018 25.12.2019

--*****************************************************************************

-- ћассивы.
-- BEFORE_INSERT_TABLE---------------------------------------------------------
--BEFORE_INSERT----------------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.ARRAYS_bir
BEFORE INSERT ON SP.ARRAYS
FOR EACH ROW
--(SP-ARRAYS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.ARRAYS_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  :NEW.NAME := trim(:NEW.NAME);
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := 10; END IF; 
  IF :NEW.IND_X is null and :NEW.IND_Y is null and :NEW.IND_Z is null 
     and :NEW.IND_S is null and :NEW.IND_D  is null 
  THEN 
    :NEW.IND_X := tmpVar; 
  END IF; 
  -- ≈сли не задана дата изменени€ или пользователь, то добавл€ем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ARRAYS_bur
BEFORE UPDATE ON SP.ARRAYS
FOR EACH ROW
--(SP-ARRAYS.trg)
BEGIN
  :NEW.ID := :OLD.ID;
  :NEW.NAME := :OLD.NAME; 
  :NEW.GROUP_ID := :OLD.GROUP_ID; 
  :NEW.IND_X := :OLD.IND_X; 
  :NEW.IND_Y := :OLD.IND_Y; 
  :NEW.IND_Z := :OLD.IND_Z; 
  :NEW.IND_S := :OLD.IND_S; 
  :NEW.IND_D := :OLD.IND_D; 
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ARRAYS_bdr
BEFORE DELETE ON SP.ARRAYS
FOR EACH ROW
--(SP-ARRAYS.trg)
BEGIN
 null;
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
--*****************************************************************************
--*****************************************************************************


-- end of file

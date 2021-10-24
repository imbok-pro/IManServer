-- WForms triggers
-- by Irina Gracheva 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 30.09.2010  
-- update 22.11.2010 09.11.2017 14.01.2021

-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER WForms.FORM_SIGN_S_bir
BEFORE INSERT ON WForms.FORM_SIGN_S
FOR EACH ROW
--(WForms.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  IF :NEW.ID IS NULL THEN
    SELECT WForms.SIGSEQ.NEXTVAL INTO tmpVar FROM DUAL;
    :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  END IF;
  if :NEW.USER_NAME is null then
    :NEW.USER_NAME := S_USER;
  end if;
  if :NEW.M_DATE is null then
    :NEW.M_DATE := sysdate;
  end if;
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER WForms.FORM_PARAMS_bir
BEFORE INSERT ON WForms.FORM_PARAMS
FOR EACH ROW
--(WForms.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN return; END IF;
  IF :NEW.ID IS NULL THEN
    SELECT WForms.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
    :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  END IF;
  if :NEW.M_DATE is null then
    :NEW.M_DATE := sysdate;
  end if;
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER WForms.FORM_PARAMS_bur
BEFORE UPDATE ON WForms.FORM_PARAMS
FOR EACH ROW
--(WForms.trg)
BEGIN
  :NEW.M_DATE := sysdate;
END;
/

-- end of file
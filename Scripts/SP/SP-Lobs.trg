-- SP Lobs tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.03.2021
-- update 08.03.2021 08.07.2021
--*****************************************************************************

-- BEFORE_INSERT_TABLE----------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.Lobs_bir
BEFORE INSERT ON SP.Lob_s
FOR EACH ROW
--(SP-Lobs.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.Lobs_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
  -- ������� ����� GUID, ���� �� �����.
  IF :NEW.GUID is null THEN 
    :NEW.GUID := SYS_GUID; 
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
CREATE OR REPLACE TRIGGER SP.Lobs_bur
BEFORE UPDATE ON SP.Lob_s
FOR EACH ROW
--(SP-Lobs.trg)
BEGIN
  :NEW.ID := :OLD.ID;
  :NEW.GUID := :OLD.GUID;
  :NEW.F_CLOB := :OLD.F_CLOB;
  :NEW.F_BLOB := :OLD.F_BLOB;
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
END;
/

--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.Lobs_bdr
BEFORE DELETE ON SP.Lob_s
FOR EACH ROW
--(SP-Lobs.trg)
DECLARE
  Name SP.MODEL_OBJECTS.MOD_OBJ_Name%type;
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- ������ ������� ����, ���� �� ���� ���� ������.
  -- 1 - ��� ������� ��������.
  select count(*) into tmpVar from SP.OBJECT_PAR_S 
    where TYPE_ID in (G.TCLob, G.TBLob)
      and N = :OLD.ID;
  if tmpVar > 0 then
    -- ������� ��� ����������� ������� � �������� ������.
    select g.Name||'.'||o.Name into Name 
      from SP.OBJECT_PAR_S p, SP.OBJECTS o, SP.GROUPS g
     where p.TYPE_ID in (G.TCLob, G.TBLob)
      and p.N = :OLD.ID
      and p.OBJ_ID = o.ID
      and g.ID = o.GROUP_ID
      and rownum < 2;
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.Lobs_bdr.'||
       ' ���������� ������� ����, ������ �� ������� ���� ��������'
       ||' �� ��������� ��� ������� �������� '||Name||
       ' ! ����� ������ '||tmpVar);
  end if;    
  -- 2 - ��� ������� ������.
  select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
    where TYPE_ID in (G.TCLob, G.TBLob)
      and N = :OLD.ID;
  --d('������� ������!!! '||tmpVar,'Lobs_bdr');    
  if tmpVar >0 then
    -- ������� ��� ������ ��� ������� ������ � �������� ������.
    select MODEL_NAME||'=>'||FULL_NAME into Name 
      from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S p
     where p.TYPE_ID in (G.TCLob, G.TBLob)
      and p.N = :OLD.ID
      and p.MOD_OBJ_ID = o.ID
      and rownum < 2;
     SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.Lobs_bdr.'||
       ' ���������� ������� ����('||:OLD.ID||'),'||
       ' ������ �� ������� ���� ��������'||
       ' ������� ������ '||Name||
       ' ! ����� ������ '||tmpVar);
  end if;
  -- 3 - �� ������� ������� ������� ������.
  select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES 
    where TYPE_ID in (G.TCLob, G.TBLob)
      and N = :OLD.ID;
  --d('������� ������!!! '||tmpVar,'Lobs_bdr');    
  if tmpVar > 0 then
     SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033, 'SP.Lobs_bdr.'||
       ' ���������� ������� ����('||:OLD.ID||'),'||
       ' ������ �� ������� ������������ � ������� �������� �������'||
       ' ������� ������! ����� ������: '||tmpVar);
  end if;

--	INSERT INTO SP.DELETED_Lobs
--	  VALUES(:OLD.ID, :OLD.D, :OLD.BLOCK_ID, :OLD.BUH_ID, :OLD.S, :OLD.N,
--           :OLD.A_DEBET, :OLD.C_DEBET,  :OLD.A_CREDIT,  :OLD.C_CREDIT,
--           :OLD.MACRO, :OLD.COMMENTS, :OLD.VALIDATED, 
--           :OLD.M_DATE,:OLD.M_USER);      
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
--CREATE OR REPLACE TRIGGER SP.Lobs_ad
--AFTER DELETE ON SP.Lobs
----(SP-Lobs.trg)
--DECLARE
--tmpVar NUMBER;
--Name SP.COMMANDS.COMMENTS%TYPE;
--rec SP.DELETED_TRANS%ROWTYPE;
--BEGIN
--  IF ReplSession THEN return; END IF;
--  IF TG.AfterDeleteTrans THEN return; END IF;
--  TG.AfterDeleteTrans:= TRUE;
--  --d('table ������','TRANS_ad');
--  LOOP
--    BEGIN
--      SELECT * INTO rec FROM SP.DELETED_TRANS WHERE ROWNUM=1;
--      --d('execute'||rec.OLD_ID,'TRANS_ad');
--    EXCEPTION
--      WHEN NO_DATA_FOUND THEN
--        --d('exit','TRANS_ad');
--        EXIT;
--    END;
--    -- ������� ������������ ������.
--    --d('delete current','TRANS_ad');
--    DELETE FROM SP.DELETED_TRANS WHERE OLD_ID=rec.OLD_ID;
--	END LOOP;
--  TG.AfterDeleteTrans := FALSE;
--END;
--/
-- end of file

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

-- ������.
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
      'SP.MODELS_bir. ��������� "=>" �� ��������� � ����� ������, ��� ��� ��� ������������ ��� ���������� ����� ������ � ����� �������!');
  end if;
  IF (NOT SP.TG.SP_Admin) and (:NEW.PERSISTENT = 0) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bir.'||
      ' ������ ������������� ����� �������� ����������� ������!');
  END IF;          
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
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
      'SP.MODELS_bur. ������ ������������� ���������������� ������!');
  END IF;
  IF NOT SP.TG.SP_Admin THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bur.'||
      ' ������ ������������� ����� ������������� ������!');
  END IF;          
  :NEW.NAME := trim(:NEW.NAME);
  if instr(:NEW.NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bur. ��������� "=>" �� ��������� � ����� ������, ��� ��� ��� ������������ ��� ���������� ����� ������ � ����� �������!');
  end if;    
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
      'SP.MODELS_bdr. ������ ������� ���������������� ������!');
  END IF;
  IF NOT SP.TG.SP_Admin THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bdr.'||
      ' ������ ������������� ����� ������� ������!');
  END IF;          
  -- ��������� ������� ������, ���� � ���������� �������� ��������,
  -- ���� ������ �� ������.
  select count(*) into tmpVar from SP.OBJECT_PAR_S 
    where TYPE_ID = G.TRel
      and N = - :OLD.ID;
  IF tmpVar > 0 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODELS_bdr. ������ ������� ������,'||
      ' �� ������� ���� ������ � ���������� �������� ��������!');
  END IF;
  -- ������������� ������� �������� ������
  SP.TG.ModelDeleting := :OLD.ID;
	-- ��������� ��������� �������� ���������� ��������.
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
-- ��������� �������.
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
  -- ��������� ������ ��� ������ �� ������ ����� ������ � ������ �������.
  -- ��� ������ ����� ����� ���� ������ ��� �������� ������� �� ��������.
  IF (:NEW.OBJ_ID IS NULL) AND NOT SP.TG.ImportDATA THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bir.'||
      ' ������ ��������� ������ '||:NEW.MOD_OBJ_NAME||
      ' ��� ������ �� ������ ��������!');
  END IF;
  -- 
  if instr(:NEW.MOD_OBJ_NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bir. ��������� "=>" �� ��������� � ����� ������� ������, ��� ��� ��� ������������ ��� ���������� ����� ������ � ����� �������!');
  end if;    
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- ��� ��������� �������, ����������� OID, ���� �� �� ��������.
  IF SP.TG.CurModel_LOCAL and (:NEW.OID is null) THEN 
    :NEW.OID := SYS_GUID; 
  END IF;
  -- ������������, ������ ����� ����, ������� ���������.
  IF  not SP.HasUserRoleID(:NEW.USING_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bir.'||
      ' ���������� ���� '||:NEW.USING_ROLE||' ��� �������� �������:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- ������������, ������ ����� ����, ������� ���������.
  IF  not SP.HasUserRoleID(:NEW.EDIT_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bir.'||
      ' ���������� ���� '||:NEW.EDIT_ROLE||' ��� �������� �������:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF; 
  -- �������� ������� � ����� ����� � ����� �������. 
  :NEW.MOD_OBJ_NAME := trim(:NEW.MOD_OBJ_NAME);
  :NEW.MOD_OBJ_NAME := replace(:NEW.MOD_OBJ_NAME, chr(10));
  -- ���� ��������� �������� � � ������� ���� ��������,
  -- �� ������� ������ � ��������� ������� ��� ��������,
  -- ��� ������ � ��� �������� ����������� ����� ������.
  -- ������������ �� �������� ����������,
  -- ��������� �� ����� ����������� ������ ��� ��� ������.
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
  	  -- ������� ��� � ������ ������� ��������.
      SELECT o.MOD_OBJ_NAME, m.NAME, o.MODEL_ID 
        INTO ObjName, ModelName, ModelID 
        FROM SP.MODEL_OBJECTS o, SP.MODELS m
        WHERE o.ID=rec.NEW_PARENT_MOD_OBJ_ID
          AND m.ID=o.MODEL_ID;
  	  -- ���������, ��� ������ ���������.
      IF g.notEQ(ModelID, rec.NEW_MODEL_ID) THEN
        SP.TG.ResetFlags;
  	    RAISE_APPLICATION_ERROR(-20033,
  	      'SP.MODEL_OBJECT_S_ai.'||
  	      ' ������������ ������ '||ObjName||
  	      ' ����������� ������ ������ '||ModelName||'!');
      END IF;
	end if;
		-- ��������� ���� ��������. 
		SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS WHERE ID = rec.NEW_OBJ_ID;
		IF tmpVar != 0 THEN
		  RAISE_APPLICATION_ERROR(-20033,
	      'SP.MODEL_OBJECT_S_ai.'||' ������ ������ ���� �������� ����!');
		END IF;
		--
    -- ��������� ��� ��������
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
  -- ���� �� ���������� ���� ��������������� ��������� OID,
  -- �� ������� ������ ����� �������� OID, ���� �� ������������,
  -- �� ������ ��� ��������.
  IF not SP.TG.ForceOID THEN
    IF :OLD.OID IS NOT NULL and G.notEQ(:NEW.OID,:OLD.OID) THEN 
      em#:='������� ���������� ������� OID � ������� '
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
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- ��� ��������� �������, ����������� OID, ���� �� �� ��������.
  IF SP.TG.CurModel_LOCAL and (:OLD.OID is null)THEN 
    :NEW.OID := SYS_GUID; 
  END IF;
  -- �������� ������� � ����� ����� � ����� �������. 
  :NEW.MOD_OBJ_NAME := trim(:NEW.MOD_OBJ_NAME);
  :NEW.MOD_OBJ_NAME := replace(:NEW.MOD_OBJ_NAME, chr(10));
  if instr(:NEW.MOD_OBJ_NAME,'=>') > 0 then
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur. ��������� "=>" �� ��������� � ����� ������� ������, ��� ��� ��� ������������ ��� ���������� ����� ������ � ����� �������!');
  end if;    
  -- ����  ������������� ������ ������ ������� ���������, �� �����.
  IF g.upEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME)
    AND g.EQ(:NEW.OBJ_ID, :OLD.OBJ_ID)
    AND g.EQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID)
  THEN
    RETURN;
  END IF;      
  Modified := FALSE;
  -- ������������� ���� ����� ������������� ���,
  -- ���� ��� ���� �������������� ����.
  -- ���� ���� �������������� ������� �� ����, �� ������������� ������
  -- ����� ������������, ������� ����� ����.
  IF NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
    THEN
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur. '||
     '������������ ���������� ��� ��������� �������: '||:OLD.MOD_OBJ_NAME||'!');
  END IF;
  -- ������������, ������ ����� ����, ������� ���������.
  IF  not SP.HasUserRoleID(:NEW.USING_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur.'||
      ' ���������� ���� '||:NEW.USING_ROLE||' ��� �������� �������:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- ������������, ������ ����� ����, ������� ���������.
  IF  not SP.HasUserRoleID(:NEW.EDIT_ROLE) THEN
    SP.TG.ResetFlags;    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bur.'||
      ' ���������� ���� '||:NEW.EDIT_ROLE||' ��� �������� �������:'
      ||:NEW.MOD_OBJ_NAME||'!');
  END IF;   
  -- ������ ������������� ����� ������ ���� ������� � ������.
  IF NOT SP.TG.SP_Admin 
    AND (  (:NEW.USING_ROLE is null and :OLD.USING_ROLE is not null) 
         or(:NEW.EDIT_ROLE is null and :OLD.EDIT_ROLE is not null)
        ) 
  THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur.'||
  ' ������ ������������� ����� ����� ��� ���������� ������� � ������� ������!');
  END IF;          
  -- ������ ������������� ����� �������� �������������� � ������.
  IF NOT SP.TG.SP_Admin AND (:NEW.MODEL_ID !=:OLD.MODEL_ID) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_S_bur.'||
      ' ������ ������������� ����� �������� �������������� ������� � ������!');
  END IF;          
  -- ������ ������� ������ �� ������,
  -- � ������������ �������� �������� �������.
  -- ���� ������� ������ �� ������, � � ������� ����������� ��������,
  -- �� ������������� ������� �������� � ������� �� ��������,
  -- ����� ������������� ���� ���������.
  IF :NEW.OBJ_ID IS NULL AND :OLD.OBJ_ID IS NOT NULL
  THEN
    IF g.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.MODEL_OBJECT_S_bur.'||
        ' ������ ������� ������ �� ������,'||
        ' � ������������ �������� �������� �������.!');
    END IF;
  END IF;    
  -- ��� ��������� ��������, ������ ��� ����� ������� ���������� ��� 
  -- ��� ���� ������� � ��� �������� ��������.
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
  -- ���� ���������� ���� ���������, � ����� ���� ��������� �������� �������,
  -- �� ������� ������ � ��������� �������.
  -- ��� ��������� �������� ����� ��� ������ ���������� ��� ��� ���� ������� �
  -- ��� �����.
  -- ��� ��������� �������� ������� ��������� �� ��������� �� ������������ ��
  -- �������� ��������, � ��� ��, ��� ������ � ��� �������� ����������� �����
  -- ������.
  -- ��� ������������ ������ �� ������� ��� ������ �������� �������������
  -- ������� ��������� ������ �������� �������� ������� �������.
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
  
  -- ��������� �������� ���������������� � ������� ������� ���������� �������.
  
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
 	    -- ������� ��� � ������ ������� ��������.
 	    SELECT o.MOD_OBJ_NAME, m.NAME
         INTO ObjName, ModelName
         FROM SP.MODEL_OBJECTS o, SP.MODELS m
 	      WHERE sp.g.S_EQ(o.ID,rec.NEW_PARENT_MOD_OBJ_ID) = 1
           AND o.MODEL_ID=m.ID;
	    -- ��������� ��� �� � �������� ������� ��� ��������.
	    SELECT COUNT(*) INTO tmpVar FROM 
	      (SELECT ID FROM SP.MODEL_OBJECTS
	                 START WITH PARENT_MOD_OBJ_ID=rec.OLD_ID
	                 CONNECT BY  PARENT_MOD_OBJ_ID= PRIOR ID)
	    WHERE rec.NEW_PARENT_MOD_OBJ_ID=ID;
	    IF tmpVar != 0 THEN             
	      SP.TG.ResetFlags;
		    RAISE_APPLICATION_ERROR(-20033,
		      'SP.MODEL_OBJECT_S_au.'||
		      ' ������������ ������ '||ObjName||
		      ' �������� �������� ��� '||rec.OLD_MOD_OBJ_NAME||'!');
	    END IF;
    END IF;
		-- ��������� ��� �������. 
		SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS WHERE ID = rec.NEW_OBJ_ID;
		IF tmpVar != 0 THEN
		  RAISE_APPLICATION_ERROR(-20033,
	      'SP.MODEL_OBJECT_S_au.'||' ������ ������ ���� �������� ����!');
		END IF;
 
    -- ������� ������������ ������.
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
      'SP.MODEL_OBJECTS_bdr. ������ ������� ���������������� ������� ������!');
  END IF;
  -- ������������� ���� ����� ������������� ���,
  -- ���� ��� ���� �������������� ����.
  -- ���� ���� �������������� ������� �� ����, �� ������������� ������
  -- ����� ������������, ������� ����� ����.
  IF NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
    THEN
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECTS_bdr. '||
     '������������ ���������� ��� �������� �������: '||:OLD.MOD_OBJ_NAME||'!');
  END IF;
  -- ���� �� �������� ���� ������, 
  if SP.TG.ModelDeleting is null then
    -- �� ��� �������� ������� ������ ���������� ��� ��� ���� �������.
    -- �������� ������� ��������� �������� � �� ���� ��� ���� ��� �� ���������.
    update SP.MODEL_OBJECT_PATHS set invalid = 1 
      where ID = :OLD.ID;
  end if;    
  -- ��������� ��������� �������� ���������� ��������.
  SP.TG.ModObjParDeleting:=TRUE;
  -- � ��������� �������� ��������� � ���������:
  -- 1. �������� �������, �� ������� ��������� �������� ������� �������.
  -- 2. �������� �������, ������������ �� ����������.
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
  --d('table ������','ModObjects_ad');
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
      -- ������ ������� ������, ���� �� ���� ���� ������.
      -- 1 - ��� ������� ��������.
     select count(*) into tmpVar from SP.OBJECT_PAR_S 
        where TYPE_ID = G.TREL
          and N = rec.OLD_ID;
      if tmpVar >0 then
        -- ������� ��� ����������� ������� � �������� ������.
        select g.Name||'.'||o.Name into Name 
          from SP.OBJECT_PAR_S p, SP.OBJECTS o, SP.GROUPS g
         where p.TYPE_ID = G.TREL
          and p.N = rec.OLD_ID
          and p.OBJ_ID = o.ID
          and g.ID = o.GROUP_ID
          and rownum < 2;
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' ���������� ������� ������ ������, ������ �� ������� ���� ��������'
           ||' �� ��������� ��� ������� �������� '||Name||
           ' ! ����� ������ '||tmpVar);
      end if;    
      -- 2 - ��� ������� ������.
      -- ���� ������� ������, �� ���������, ��� ��� ������ �� ������ �������!!!
      -- ����� �� ����.
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
      --d('������� ������!!! '||tmpVar,'ModObjects_ad');    
      if tmpVar >0 then
        -- ������� ��� ������ ��� ������� ������ � �������� ������.
        select MODEL_NAME||'=>'||FULL_NAME into Name 
          from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S p
         where p.TYPE_ID = G.TREL
          and p.N = rec.OLD_ID
          and p.MOD_OBJ_ID = o.ID
          and rownum < 2;
         SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' ���������� ������� ������ ������('||rec.OLD_ID||'),'||
           ' ������ �� ������� ���� ��������'||
           ' ������� ������� ������ '||Name||
           ' ! ����� ������ '||tmpVar);
      end if;
      -- 3 - �� ������� ������� ������� ������.
      -- ���� ������� ������, �� ���������, ��� ��� ������ �� ������� ����������
      -- ������ �������
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
        --     �� ����������� ������ �� ������� ��� ������ �������� ��������,
        -- ������� �� �������������� �������.
        --
        delete from SP.MODEL_OBJECT_PAR_STORIES 
          where TYPE_ID = SP.G.TRel
            and OBJ_PAR_ID = -2 
            and N = rec.OLD_ID; 
        select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES 
          where TYPE_ID = G.TREL
            and N = rec.OLD_ID;
      end if;    
      --d('������� ������!!! '||tmpVar,'ModObjects_ad');    
      if tmpVar > 0 then
        -- !!������� ��� ������ ��� ������� ������ � �������� ������.
--        select MODEL_NAME||'=>'||FULL_NAME into Name 
--          from SP.V_MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_STORIES p
--         where p.TYPE_ID = G.TREL
--          and p.N = rec.OLD_ID
--          and p.MOD_OBJ_ID = o.ID
--          and rownum < 2;
         SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
           ' ���������� ������� ������ ������('||rec.OLD_ID||'),'||
           ' ������ �� ������� ������������ � ������� �������� �������'||
           ' ������� ������� ������! ����� ������: '||tmpVar);
      end if;
      -- ������ ������� ������,
      -- ���� ����� ��� ������� ���� �������������� ������ �� ����������.
      select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S 
        where TYPE_ID = G.TTRANS
          and N is not null 
          and MOD_OBJ_ID = rec.OLD_ID;
      if tmpVar >0 then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.MODEL_OBJECTS_ad.'||
          ' ���������� ������� ������ ������, ������������� �� ����������!');
      end if;
	  END;  
    -- ������� ������������ ������.
    --d('delete current','ModObjects_ad');
    DELETE FROM SP.DELETED_MOD_OBJECTS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  TG.AfterDeleteModObjects := FALSE;
  SP.TG.ModObjParDeleting:=FALSE;
END;
/
--*****************************************************************************

-- ��������� ��������� � ������ ��������.
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
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- ���������, ��� �� �� ��������� ���������, ����� ������� ���������
  -- � ������� ����������� ����������:
  -- "NAME", "OLD_NAME", "PARENT", "NEW_PARENT", "OID", "POID", "NEW_POID",
  -- "ID", "PID", "NEW_PID", "DELETE","USING_ROLE","EDIT_ROLE".
  -- �������� ������� � �������� �����.
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
    ' ��� ������������ ��������� ��������������� ��� ������������ ���������!');
 END IF;          
  -- ��������� ������� ��������� ��������� ��������.
  -- 1. ��������, ������� � ������������ ���� �������������� ������� �������.
  -- 2. �������� �������� ���������, ���� ��������� �������� ��������
  -- ����������.
  -- 3. ��� ���������� ������� �������� � �������� �������������:
  -- 3.1. �������������� �������� ��������� � ��������,
  -- �������� ������� � ��������(��� ����������, ������� �������� � ��������).
  -- 3.2. ���� �������� ������ ��� ������, �� ��� �������� ������ ��������� �
  -- ���������. ������������� ��� ����������, ������� �������� � ��������, 
  -- ��� ��� ������ ���������!
  -- 3.3. ��������� ���������� ���� ��������� � ��� ��������� � ��������.
  --      ����������: ��� Rel ����� ��������� �� SymRel.
  -- 3.4. ��������� �������� ������ ������ �� ���������� � ���������.
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
          ' ������ � ��������������� '||rec.NEW_MOD_OBJ_ID||
          ' �� ������!');
    END;
--  1.��������, ������� � ������������ ���� �������������� ������� �������.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_ai. '||
          '������������ ���������� ��� ��������� �������: '||ObjName||'!');
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
            ' �������� � ��������������� '||rec.NEW_OBJ_PAR_ID||
            ' �� ������!');
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
              ' ��� � ��������������� '||nvl(to_char(pType), 'null')||
              ' �� ������!');
        END;
      END IF;   
    END IF;  																			 
	  -- 2. �������� �������� ���������, ���� ��������� �������� ��������
	  -- ���������� � �������� ���������.
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
	            ' ������ �������� �������� ��������� '||ParName||
	            ' ������� '||ObjName||' : '||SQLERRM||'!');
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
				      'SP.MODEL_OBJECT_PAR_S_ai. ����������� ��������: '||
              rec.NEW_E_VAL||
		          ' �� ������� � ��������� '||ParName||' ������� '||ObjName||
		          '!');
        END IF;      	 
		  END IF;
    END IF;
    -- 3. ��� ����������, ������� �������� � ��������.
    IF rec.NEW_OBJ_PAR_ID is not null then  
      -- 3.1 �������������� �������� ��������� � ��������,
      -- �������� ������� � ��������.
      IF G.notEQ(ObjId,CatObj) THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' �������� ��������, �� ������� ��������� �������� ������ '||ParName||
          ' ����������� ������� ������� ��������, ��� ������ ������!');
      END IF;
      -- 3.2. ���� �������� ������ ��� ������, �� ��� ���������� ������������.
      IF ROnly = SP.G.ReadOnly THEN        
        SP.TG.ResetFlags;
        SELECT NAME INTO CatName FROM SP.OBJECTS WHERE ID=CatObj;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' �������� '||ParName||' ������� '||ObjName||
          ' (���������� ��� '||CatName||')'||
          ' ����� ������� ������ ��� ������!');
      END IF;
      -- 3.3. ��������� ���������� ����� ��������� � ��� ��������� � ��������.
      IF pType != rec.NEW_TYPE_ID then
        if (pType != G.TRel) and (rec.NEW_TYPE_ID != G.TSymRel) then
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_ai.'||
            ' ��� '||pType||' ��������� � �������� '||ParName||
            ' �� ��������� � ����� '||rec.NEW_TYPE_ID||
            ' ������������ ���������!');
        end if;    
      END IF;
      -- 3.4. ��������� �������� ������ ������ �� ���������� � ���������.
      --!! IF RONLY != rec.NEW_R_ONLY then ��������� � ��������� ����!!!!
      IF (RONLY > 0) and (rec.NEW_R_ONLY <= 0) then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_ai.'||
          ' ����������� '||rec.NEW_R_ONLY||' ������������ ��������� '||ParName||
          ' �� ��������� � ����� '||RONLY||' ��������� � ��������!');
      END IF;
    END IF;
    -- ������� ������������ ������.
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
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF;
   
  -- ���� ��� ������������� ������������ ��������, �� �����.
  IF SP.TG.AfterUpdateEnum THEN return; END IF;
  -- �������� ������� � �������� �����.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- ��������� ���������� ����� ��������� � ������� ����������� ����������.
  IF :NEW.NAME 
    IN ('NAME','OLD_NAME','PARENT','NEW_PARENT',
        'OID','POID','NEW_POID','ID','PID','NEW_PID','DELETE',  
        'USING_ROLE','EDIT_ROLE') 
  THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.MODEL_OBJECT_PAR_S_bur.'||
  ' ��� ������������ ��������� ��������������� ��� ������������ ���������!');
  END IF;
  -- ��������� ������� ��������� ��������� ��������.
  -- 1. ��������, ������� � ������������ ���� �������������� ������� �������.
  -- 2. �������� �������� ���������, ���� ��������� �������� ��������
  -- ���������� � �������� ���������.
  -- 3. ��� ����������, ������� ��������� � �������� ���������:
  -- 3.1. �������������� �������� ��������� � ��������,
  -- �������� ������� � ��������.
  -- 3.2. ���� �������� ������ ��� ������, �� ��� �������� ������ ��������� �
  -- ���������. 
  -- ������������� ����� �������� �� ����� �������������� � ������� ���������� 
  -- ������.
  -- 3.3 ��������� ���������� ����� ��������� � ��� ��������� � ��������.
  --     ��� ���� ��� Rel ����� �������� �� SymRel.
  -- 3.4. ��������� �������� ������ ������ �� ���������� � ���������,
  -- � �����, ���� ����������, �� ��������� ������ �������� ���������
  -- � �������. �� ��������� ������ ��������, ���� ������ ��� SymRel.
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
    --d('table ������ => return ','MODEL_OBJECT_PAR_S_au');
    RETURN; 
  END IF;
  SP.TG.AfterUpdateModObjPars:= TRUE;
  d('table ������','MODEL_OBJECT_PAR_S_au');
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
          ' ������ � ��������������� '||rec.OLD_MOD_OBJ_ID||
          ' �� ������!');
    END;
--  1.��������, ������� � ������������ ���� �������������� ������� �������.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_au. '||
          '������������ ���������� ��� ��������� �������: '||ObjName||
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
            ' �������� � ��������������� '||rec.NEW_OBJ_PAR_ID||
            ' �� ������!');
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
              ' ��� � ��������������� '||nvl(pType, 'null')||
              ' �� ������!');
        END;
      END IF;  
    END IF;  
    -- 2. �������� �������� ���������, ���� ��������� �������� ��������
	  -- ���������� � �������� ���������.
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
              ' ������ �������� �������� ��������� '||ParName||
              ' ������� '||ObjName||'('||rec.OLD_MOD_OBJ_ID||'): '||
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
				      'SP.MODEL_OBJECT_PAR_S_au. ����������� ��������: '||
              rec.NEW_E_VAL||
		          ' �� ������� � ��������� '||ParName||' ������� '||ObjName||
		          '('||rec.OLD_MOD_OBJ_ID||')!');
        END IF;      	 
  	  END IF;
		END IF;
    -- 3. ��� ����������, ������� �������� � ��������.
    IF rec.NEW_OBJ_PAR_ID is not null then  
      -- 3.1 �������������� �������� ��������� � ��������,
      -- �������� ������� � ��������.
      IF G.notEQ(ObjId,CatObj) THEN
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' �������� ��������, �� ������� ��������� �������� ������ '||ParName||
          ' ����������� ������� ������� ��������, ��� ������ ������!');
      END IF;
      -- 3.2. ���� �������� ������ ��� ������, �� ��� ���������� ������������.
      IF ROnly = SP.G.ReadOnly THEN        
        SP.TG.ResetFlags;
        SELECT NAME INTO CatName FROM SP.OBJECTS WHERE ID=CatObj;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' �������� '||ParName||' ������� '||ObjName||
          ' (���������� ��� '||CatName||')'||
          ' ����� ������� ������ ��� ������!');
      END IF;
      -- 3.3. ��������� ���������� ����� ��������� � ��� ��������� � ��������.
      --      ��� Rel ����� �������� �� SymRel.
      IF pType != rec.NEW_TYPE_ID then
        if (pType != G.TRel) and (rec.NEW_TYPE_ID != G.TSymRel) then
          SP.TG.ResetFlags;
          RAISE_APPLICATION_ERROR(-20033,
            'SP.MODEL_OBJECT_PAR_S_au.'||
            ' ����� ��� ����������� ��������� �� ���������'||
            ' � ����� ��������� � ��������!');
        end if;    
      END IF;
      -- 3.4. ��������� �������� ������ ������ �� ���������� � ���������,
      --!! IF RONLY != rec.NEW_R_ONLY then ��������� � ��������� ����!!!!
      IF (RONLY > 0) and (rec.NEW_R_ONLY <= 0) then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.MODEL_OBJECT_PAR_S_au.'||
          ' ����� ����������� '||rec.NEW_R_ONLY||
          ' ����������� ��������� '||ParName||
          ' �� ��������� � ����� '||RONLY||' ��������� � ��������!');
      END IF;
      -- � �����, ���� ����������, �� ��������� ������ �������� ���������
      -- � �������.
      IF    (not SP.TG.ImportDATA) 
        and (RONLY between -1 and 0) 
        and (rec.OLD_TYPE_ID != G.TSymRel)
        and (rec.NEW_M_DATE - rec.OLD_M_DATE > INTERVAL '0 0:0:1' DAY TO SECOND)
      THEN
        d('��������� ������� MOD_OBJ_ID: '||rec.OLD_MOD_OBJ_ID||
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
    -- ������� ������������ ������.
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
      ' ������ ������� ���������������� ��������� �������� ������!');
  END IF;
  -- ������� �������� ������� ������ �����, ���� ����� ��� ������,
  -- ��� � ������� �������� ����������� ��������������� ��������.
  -- ���� ���� ��� �� ����������� ��� ��������� ������ �������.
  IF SP.TG.ModObjParDeleting THEN
    RETURN; -- ����� ������
  END IF;
--  IF :OLD.OBJ_PAR_ID IS not NULL THEN
--    SP.TG.ResetFlags;       
--    RAISE_APPLICATION_ERROR(-20033,
--      'SP.MODEL_OBJECT_PAR_S_bdr.'||
--      ' ������ ������� �������� ������ �������� ������� ������.'||
--      ' ����� ������� ��� ��������� ������� ������ � ��������,'||
--      ' ��� ����� ������� �������� ������� ������,'||
--      ' ���� � ���� ����������� ������ �� ��������������� ������ ��������!');
--  END IF;
  -- � ��������� �������� ���������, ��� ������������ ����� ���� ��������������
  -- �������.
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
          ' ������ � ��������������� '||rec.OLD_MOD_OBJ_ID||
          ' �� ������!');
    END;
--  1.��������, ������� � ������������ ���� �������������� ������� �������.
    IF NOT SP.HasUserRoleID(ERole)
      THEN
        SP.TG.ResetFlags;    
        RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_S_ad. '||
          '������������ ���������� ��� ��������� �������: '||ObjName||'!');
    END IF;
    -- 
    -- ������� ������������ ������.
    delete from SP.DELETED_MOD_OBJ_PAR_S up where up.OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteModObjPars:= false;
END;
/

-- ������� ������� �������� ������
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
  --!! �������� ��� �������� ����������� �������.
  if :NEW.OBJ_PAR_ID = 2 then
    SP.TG.ResetFlags;
    d(  'MOD_OBJ_ID '|| :NEW.MOD_OBJ_ID||', '||
        'OBJ_PAR_ID '|| :NEW.OBJ_PAR_ID||', '||
        'TYPE_ID '|| :NEW.TYPE_ID||', '||
        'N '||:NEW.N,'Error in SP.MODEL_OBJECT_PAR_STORIES_bir.'
     );    
    RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_STORIES_bir. '||
      '������ ��������� ! �������� �������������');
  end if;
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
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
CREATE OR REPLACE TRIGGER SP.MODEL_OBJECT_PAR_STORIES_bdr
BEFORE DELETE ON SP.MODEL_OBJECT_PAR_STORIES
FOR EACH ROW
--(SP-MODEL.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- ������� ������� �������� ��������� ������� ������ �����,
  -- ���� ����� ��� ������.
  IF SP.TG.ModObjParDeleting THEN
    RETURN; -- ����� ������
  END IF;
  -- ������� ������� �������� ��������� ������� ������ ����� 
  -- ������ �������������.
  IF SP.TG.SP_Admin THEN
    RETURN; 
  END IF;
  -- �������� ��� � ��������� �� ���������� ������� ���������� �������
  -- ���������� � ��������� ��������.
  insert into SP.DELETED_M_OBJ_PAR_STOPIES values
  ( :OLD.ID, :OLD.MOD_OBJ_ID, :OLD.OBJ_PAR_ID, 
    :OLD.TYPE_ID, :OLD.E_VAL, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y,
    :OLD.M_DATE, :OLD.M_USER);
--  SP.TG.ResetFlags;
--  RAISE_APPLICATION_ERROR(-20033,
--    'SP.MODEL_OBJECT_PAR_STORIES_bdr. ������ ������� �������!');
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
   
  -- ��������� ���������� �������� ���������� ������� � ���������.
    select P.R_ONLY, P.NAME into tmpVar, ParName from SP.OBJECT_PAR_S p 
      where P.ID = rec.OLD_OBJ_PAR_ID;
    IF tmpVar in(G.READWRITE, G.REQUIRED) THEN
      select o.FULL_NAME into ObjName from SP.V_MODEL_OBJECTS o 
        where O.ID = rec.OLD_MOD_OBJ_ID;
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.MODEL_OBJECT_PAR_STORIES_ad '||
          '��� ��������� '||ParName||' ������� '||ObjName||
          ' ������� ������� ����� ������ �������������!');
    END IF;
    -- 
    -- ������� ������������ ������.
    delete from SP.DELETED_M_OBJ_PAR_STOPIES up where up.OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteMOParStories:= false;
END;
/
--*****************************************************************************


-- end of file

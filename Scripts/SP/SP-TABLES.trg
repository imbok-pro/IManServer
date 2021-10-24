-- SP tables triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 23.08.2010
-- update 02.09.2010 22.09.2010 19.11.2010 21.12.2010 24.12.2010 09.03.2011
--  	    12.10.2011 11.11.2011 14.12.2011 03.04.2013 01.06.2013 13.06.2014
--        14.06.2014 30.08.2014 01.09.2014 23.10.2014 13.11.2014 08.07.2015
--        19.09.2017 18.12.2017
--*****************************************************************************

-- ���� ����������.
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.PAR_TYPES_bir
BEFORE INSERT ON SP.PAR_TYPES
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- �������� ��� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.PAR_TYPES_bir. ������������ ����������!');	 
  END IF;    	 
  -- !!! �� ������ ������� ��������� ����������� ��������� ���������� ����
  -- �� ����� ������������ "PROG"
  IF :NEW.ID BETWEEN 1 AND 999 THEN
    IF UPPER(S_USER)!='PROG' THEN
      SP.TG.ResetFlags;
	    RAISE_APPLICATION_ERROR(-20033,
        'SP.PAR_TYPES_bir. ������������ ����������!');
    END IF;    	 
  ELSE  
    SELECT SP.TYPE_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
    :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  END IF;
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
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
CREATE OR REPLACE TRIGGER SP.PAR_TYPES_bur
BEFORE UPDATE ON SP.PAR_TYPES
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- !!! �� ������ ������� ��������� ����������� ������������� ���������� ����
  -- �� ����� ������������ "PROG".
  IF :NEW.ID BETWEEN 1 AND 999 THEN
    IF UPPER(S_USER)!='PROG' THEN
      SP.TG.ResetFlags;
	    RAISE_APPLICATION_ERROR(-20033,
        'SP.PAR_TYPES_bir. ������������ ����������!');
    END IF;    	 
  ELSE  
    :NEW.ID := :OLD.ID;
  END IF;  
  -- ������������� ���� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.PAR_TYPES_bur. ������������ ����������!');	 
  END IF;    	 
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ���� �� ������ ��� �� �������� ���� ��������� ��� ������������,
  -- �� �������� �� �������.
  IF (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) THEN 
    :NEW.M_DATE := sysdate; 
  END IF; 
  IF (:NEW.M_USER is null) or (:NEW.M_USER = :OLD.M_USER) THEN 
    :NEW.M_USER := TG.UserName; 
  END IF; 
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.PAR_TYPES_bdr
BEFORE DELETE ON SP.PAR_TYPES
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- ������ ������� ���������� ����.
  IF :OLD.ID < 1000 THEN 
	  SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.PAR_TYPES_bdr. ������ ������������� ' || :OLD.NAME||'!');
  END IF;
  -- ������� ��� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.PAR_TYPES_bdr. ������������ ����������!');
  END IF;  
END;
/

--*****************************************************************************

-- �������� ������������� �����.
--BEFORE_INSERT_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.UPDATED_ENUM_VAL_S_bi
BEFORE INSERT ON SP.UPDATED_ENUM_VAL_S
--(SP-TABLES.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_ENUM_VAL_S;
  IF tmpVar=0 AND SP.TG.AfterUpdateEnum THEN 
    SP.TG.AfterUpdateEnum := FALSE;
    d('SP.TG.AfterUpdateEnum:= false;','ERROR UPDATED_ENUM_VAL_S_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_ENUM_VAL_S_bi
BEFORE INSERT ON SP.DELETED_ENUM_VAL_S
--(SP-TABLES.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_ENUM_VAL_S;
  IF tmpVar=0 AND SP.TG.AfterDeleteEnum THEN 
    SP.TG.AfterDeleteEnum := FALSE;
    d('SP.TG.AfterDeleteEnum:= false;','ERROR DELETED_ENUM_VAL_S_bi');
  END IF;
END;
/
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ENUM_VAL_S_bir
BEFORE INSERT ON SP.ENUM_VAL_S
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
tmpVar NUMBER;
NewState NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- �������� ��� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.ENUM_VAL_S_bir. ������������ ����������!');	 
  END IF;    	 
  IF :NEW.TYPE_ID BETWEEN 1 AND 999 THEN
  -- !!! �� ������ ������� ��������� ����������� ��������� ���������� ����
  -- �� ����� ������������ "PROG" �������� !!! 01.09.2014
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.ENUM_VAL_S_bir. ������ �������� �������� ��� ����������� ����!'||
      ' (���������� �������� ��� � script � ����������� ����.)');
--     IF :NEW.ID > 999 THEN
--       SP.TG.ResetFlags;
-- 	    RAISE_APPLICATION_ERROR(-20033,
--         'SP.ENUM_VAL_S_bir. ������������ ���������� �������������'||
--         TO_CHAR(:NEW.ID)||'!');
--     END IF;    	 
  ELSE  
    SELECT SP.TYPE_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
    :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  END IF;
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ENUM_VAL_S_bur
BEFORE UPDATE ON SP.ENUM_VAL_S
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.TYPE_ID < 1000 THEN 
     :NEW.ID       := :OLD.ID;
     :NEW.IM_ID    := :OLD.IM_ID;
     :NEW.TYPE_ID  := :OLD.TYPE_ID;
     :NEW.E_VAL    := :OLD.E_VAL;
     :NEW.COMMENTS := :OLD.COMMENTS;
     :NEW.N        := :OLD.N;
     :NEW.D        := :OLD.D;
     :NEW.S 	   := :OLD.S;
     :NEW.X 	   := :OLD.X;
     :NEW.Y 	   := :OLD.Y;
	 RETURN; 
  END IF;
  :NEW.ID := :OLD.ID;
  -- !!! �� ������ ������� ��������� ����������� ������������� ��������
  -- ���������� ����� �� ����� ������������ "PROG".
  IF :NEW.TYPE_ID BETWEEN 1 AND 999 THEN
    IF UPPER(S_USER)!='PROG' THEN
      SP.TG.ResetFlags;
	    RAISE_APPLICATION_ERROR(-20033,
        'SP.ENUM_VAL_S_bur. ������������ ����������!');
    END IF;    	 
  END IF;  
  :NEW.ID := :OLD.ID;
  :NEW.TYPE_ID := :OLD.TYPE_ID;
  -- ������ �������� ����� ��������.
  -- ����� �������� ��������� � ��� �� ���������!
  -- �������� �������� ����� ������ �������������.
  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--   IF g.notUpEQ(:OLD.E_VAL,:NEW.E_VAL) or not SP.TG.SP_Admin THEN 
-- 	  SP.TG.ResetFlags;
--     RAISE_APPLICATION_ERROR(-20033,
--       'SP.ENUM_VAL_S_bur. ������ ������������� ' || :OLD.E_VAL||'!');
--   END IF;
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  IF (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) THEN 
    :NEW.M_DATE := sysdate; 
  END IF; 
  IF (:NEW.M_USER is null) or (:NEW.M_USER = :OLD.M_USER) THEN 
    :NEW.M_USER := TG.UserName; 
  END IF; 
  -- ���� �������� ��������, �� ��� ���������� ��������� �� ���� ����
  -- (GLOBALS, OBJECT_PAR_S, MODEL_OBJECT_PAR_S).
  -- ���� �� ������ ��� �� �������� ���� ��������� ��� ������������,
  -- �� �������� �� �������.
  INSERT INTO UPDATED_ENUM_VAL_S 
    VALUES ( 
    :NEW.ID, :NEW.IM_ID, :NEW.TYPE_ID, :NEW.E_VAL,
    :NEW.COMMENTS, :NEW.N, :NEW.D, :NEW.S, :NEW.X, :NEW.Y,
    :NEW.GROUP_ID, :NEW.M_DATE,:NEW.M_USER, 
    :OLD.ID, :OLD.IM_ID, :OLD.TYPE_ID, :OLD.E_VAL, 
    :OLD.COMMENTS, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y,
    :OLD.GROUP_ID, :OLD.M_DATE, :OLD.M_USER 
           );
END;
/
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ENUM_VAL_S_au
AFTER UPDATE ON SP.ENUM_VAL_S
--(SP-TABLES.trg)
DECLARE
	rec SP.UPDATED_ENUM_VAL_S%ROWTYPE;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateEnum THEN
    d('table ������ => return ','ENUM_VAL_S_au');
    RETURN;
  END IF;
  SP.TG.AfterUpdateEnum:= TRUE;
  --d('table ������!!!','ENUM_VAL_S_au');
  LOOP
    BEGIN
      SELECT * INTO rec
        FROM (SELECT * FROM SP.UPDATED_ENUM_VAL_S) WHERE ROWNUM=1;
      --d('execute','ENUM_VAL_S_au');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','ENUM_VAL_S_au');
        EXIT;
    END;
    -- �������� ��������������� �������� � ��������, 
	-- ��� ����� �������������� ���������� ��������
	FOR c1 IN ( SELECT ID FROM sp.global_par_s 
                  WHERE TYPE_ID = rec.OLD_TYPE_ID)
    LOOP
      UPDATE sp.global_par_s SET
          E_VAL = rec.NEW_E_VAL,
          N = rec.NEW_N, D = rec.NEW_D, X = rec.NEW_X, Y = rec.NEW_Y
        WHERE ID = c1.ID AND UPPER(E_VAL) = UPPER(rec.OLD_E_VAL);
      UPDATE sp.users_globals SET
          E_VAL = rec.NEW_E_VAL,
          N = rec.NEW_N, D = rec.NEW_D, X = rec.NEW_X, Y = rec.NEW_Y
        WHERE  UPPER(E_VAL) = UPPER(rec.OLD_E_VAL) AND GL_PAR_ID IN 
         (SELECT ID FROM sp.global_par_s WHERE TYPE_ID = rec.OLD_TYPE_ID);
    END LOOP;   
    UPDATE sp.object_par_s SET
      E_VAL = rec.NEW_E_VAL,
      N = rec.NEW_N, D = rec.NEW_D, X = rec.NEW_X, Y = rec.NEW_Y
    WHERE type_ID = rec.OLD_TYPE_ID AND UPPER(E_VAL) = UPPER(rec.OLD_E_VAL);
    FOR c1 IN (SELECT ID FROM sp.object_par_s WHERE type_id = rec.OLD_TYPE_ID)
    LOOP
      UPDATE sp.model_object_par_s SET
        E_VAL = rec.NEW_E_VAL,
        N = rec.NEW_N, D = rec.NEW_D, X = rec.NEW_X, Y = rec.NEW_Y
       WHERE OBJ_PAR_ID = c1.ID AND UPPER(E_VAL) = UPPER(rec.OLD_E_VAL);
    END LOOP;
    -- ������� ������������ ������.
    DELETE FROM SP.UPDATED_ENUM_VAL_S WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateEnum := FALSE;
END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ENUM_VAL_S_bdr
BEFORE DELETE ON SP.ENUM_VAL_S
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
   -- ������ ������� �������� ���������� �����.
  IF :OLD.ID < 1000 THEN 
	  SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.ENUM_VAL_S_bdr. ������ ������������� ' || :OLD.E_VAL||'!');
  END IF;
  IF :OLD.TYPE_ID < 1000 THEN 
	   SP.TG.ResetFlags;
     RAISE_APPLICATION_ERROR(-20033,
      'SP.ENUM_VAL_S_bdr. ������ ������������� ' || :OLD.E_VAL||'!');
   END IF;
  -- ������� �������� ���� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.ENUM_VAL_S_bdr. ������������ ����������!');
  END IF;    
  -- � ��������� �������� ��������� �������� �� ������������� � ����������
  -- �������� � ���������� ����������. 
  INSERT INTO DELETED_ENUM_VAL_S 
    VALUES ( 
    :OLD.ID, :OLD.IM_ID, :OLD.TYPE_ID, :OLD.E_VAL, 
    :OLD.COMMENTS, :OLD.N, :OLD.D, :OLD.S, :OLD.X, :OLD.Y,
    :OLD.GROUP_ID, :OLD.M_DATE, :OLD.M_USER 
           );

END;
/
--
--AFTER_DELETE_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ENUM_VAL_S_ad
AFTER DELETE ON SP.ENUM_VAL_S
--(SP-TABLES.trg)
DECLARE
	rec SP.DELETED_ENUM_VAL_S%ROWTYPE;
  cnt NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterDeleteEnum THEN
    d('table ������ => return ','ENUM_VAL_S_ad');
    RETURN;
  END IF;
  SP.TG.AfterDeleteEnum:= TRUE;
  --d('table ������!!!','ENUM_VAL_S_ad');
  LOOP
    BEGIN
      SELECT * INTO rec
        FROM (SELECT * FROM SP.DELETED_ENUM_VAL_S) WHERE ROWNUM=1;
      --d('execute','ENUM_VAL_S_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','ENUM_VAL_S_ad');
        EXIT;
    END;
	  SELECT COUNT(*) INTO cnt
	    FROM sp.global_par_s g, sp.users_globals u
	      WHERE rec.OLD_TYPE_ID = g.TYPE_ID
	        AND u.GL_PAR_ID = g.ID
	        AND UPPER(rec.OLD_E_VAL) = UPPER(u.E_VAL);
	  IF cnt > 0 THEN
	    SP.TG.ResetFlags;
	    RAISE_APPLICATION_ERROR(-20033,'���������� �������� '||rec.OLD_E_VAL||
	     ' ������������ � ���������� ���������� ������������, ������� ������!');
	  END IF;
	  SELECT COUNT(*) INTO cnt 
	    FROM sp.object_par_s
	      WHERE TYPE_ID = rec.OLD_TYPE_ID
	      AND UPPER(rec.OLD_E_VAL) = UPPER(E_VAL);
	  IF cnt > 0 THEN
	    SP.TG.ResetFlags;
	    RAISE_APPLICATION_ERROR(-20033,'���������� �������� '||rec.OLD_E_VAL||
	     ' ������������ � ���������� �������, ������� ������!');
	  END IF;
    -- ������� ������������ ������.
    DELETE FROM SP.DELETED_ENUM_VAL_S WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterDeleteEnum := FALSE;
END;
/

-- ���������� ���������.
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GLOBAL_PAR_S_bir
BEFORE INSERT ON SP.GLOBAL_PAR_S
FOR EACH ROW
DECLARE
--(SP-TABLES.trg)
tmpVar NUMBER;
TYPE TNDSXY IS RECORD(
N NUMBER,
D DATE,
S VARCHAR2(4000),
X NUMBER,
Y NUMBER
);
NDSXY TNDSXY;
CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
NEW_TYPE_ID NUMBER(9);
NEW_E_VAL SP.ENUM_VAL_S.E_VAL%TYPE;
V SP.TVALUE;

BEGIN
  IF ReplSession THEN RETURN; END IF;
	-- ��������� ���������� ��������� ����� ������ �������������.
	IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.GLOBAL_PAR_S_bir. ������������ ����������!');	 
	END IF;
	SELECT SP.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
	-- ���������� �������� �� ����� ����� ������������� ����. 
-- 	IF :NEW.TYPE_ID IN 
-- 	  (SP.G.TXY,SP.G.TXYZ) 
-- 	THEN
--     SP.TG.ResetFlags;
-- 	  RAISE_APPLICATION_ERROR(-20033,
-- 		 'SP.GLOBAL_PAR_S_bir. ������������ ��� ��������� '||:NEW.NAME||'!');	
-- 	END IF;
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
	-- ���� �������� �����������, �� ��������� ��������.
  NEW_TYPE_ID:=:NEW.TYPE_ID;
	BEGIN
    SELECT pt.CHECK_VAL INTO CheckVal FROM SP.PAR_TYPES pt 
      WHERE pt.ID=NEW_TYPE_ID;
  EXCEPTION
	  WHEN NO_DATA_FOUND THEN NULL;
	END;	
  --d('CheckVal =>['||CheckVal||']','SP.GLOBAL_PAR_S_bir');																		 
	IF CheckVal IS NULL THEN
  	NEW_E_VAL:=:NEW.E_VAL;
		BEGIN
  	  SELECT e.N,e.D,e.S,e.X,e.Y INTO NDSXY FROM SP.ENUM_VAL_S e
  	    WHERE e.TYPE_ID=NEW_TYPE_ID AND g.S_UpEQ(e.E_VAL,NEW_E_VAL)=1;
		EXCEPTION
		  WHEN NO_DATA_FOUND THEN	
        SP.TG.ResetFlags;
		    RAISE_APPLICATION_ERROR(-20033,
		       'SP.GLOBAL_PAR_S_bir. ����������� ��������: '||
							NVL(NEW_E_VAL,'null')||' �� �������!');	 
		END;	
    :NEW.N := NDSXY.N;
    :NEW.D := NDSXY.D; 
    :NEW.S := NDSXY.S; 
  	:NEW.X := NDSXY.X;
  	:NEW.Y := NDSXY.Y;
	ELSE	  
    -- �������� �������� �� ������������ ����, ���� ��������� ����������. 
    CheckVal := 'begin ' ||
	               CheckVal||
	  					   ' exception when others then '||
							   '   RAISE_APPLICATION_ERROR(-20033,'||
                 '''SP.GLOBAL_PAR_S_bir. ������ CheckVal, '||
								 ' NAME= '||:NEW.NAME||'''||SQLERRM);'||							
							   'end;';
		V:=SP.TVALUE(:NEW.TYPE_ID,null,0,
                 :NEW.E_VAL,:NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y);
    BEGIN     
      SP.CheckVal(CheckVal,V);
    EXCEPTION
      WHEN OTHERS THEN SP.TG.ResetFlags; RAISE;
    END;   
  END IF;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GLOBAL_PAR_S_bur
BEFORE UPDATE ON SP.GLOBAL_PAR_S
FOR EACH ROW
DECLARE
--(SP-TABLES.trg)
tmpVar NUMBER;
TYPE TNDSXY IS RECORD(
N NUMBER,
D DATE,
S VARCHAR2(4000),
X NUMBER,
Y NUMBER
);
NDSXY TNDSXY;
CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
NEW_E_VAL SP.ENUM_VAL_S.E_VAL%TYPE;
V SP.TVALUE;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  -- ������ �������� ���������� ���������.
  IF    (:OLD.ID < 100) 
    and (:NEW.NAME != :OLD.NAME)
    and (:NEW.R_ONLY != :OLD.R_ONLY)
    and (:NEW.TYPE_ID != :OLD.TYPE_ID)
    and (:NEW.COMMENTS != :OLD.COMMENTS)
    and G.notEQ(:NEW.GROUP_ID, :OLD.GROUP_ID)
    and G.notEQ(:NEW.REACTION, :OLD.REACTION)
  THEN 
	  SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033, 'SP.GLOBAL_PAR_S_bur.'||
      ' ������ �������� ���������� ���������� ���������!');
  END IF;
	-- ������ ������������� ����� ������ ���������� ��������� 
  -- ��� �� �������� �� ���������.
	IF NOT REPLICATION.HasUserRole(S_User,'SP_ADMIN_ROLE')  THEN	
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR (-20033,'SP.GLOBAL_PAR_S_bur. '||
      '���������� ������������ ��� ��������� ���������� ����������'||
      ' ��� �� �������� �� ���������!');
	END IF;			 
	-- ������ ������ ������, ���� "R_Only = 2".
	IF   (:NEW.R_ONLY = :OLD.R_ONLY)
	 AND(:NEW.R_ONLY =2)
	THEN	
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR (-20033,'SP.GLOBAL_PAR_S_bur. '||
      '�������� ������ ��� ������!');
	END IF;	 
	-- ������ ������ REACTION, ���� "R_Only = -1".
	IF     SP.G.notEQ(:NEW.REACTION,:OLD.REACTION)
	  AND (:NEW.R_ONLY = -1)
	THEN	
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR (-20033,'SP.GLOBAL_PAR_S_bur. '||
      '�������� ������ ��� ������!');
	END IF;	 
  -- ������ ����������� "R_Only" "-1" � "2".
	IF    (:OLD.R_ONLY !=:NEW.R_ONLY) 
    AND (:NEW.R_ONLY = -1) OR (:NEW.R_ONLY = 2)
  THEN	
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR (-20033,'SP.GLOBAL_PAR_S_bur. '||
      '������������ �������� ������������ R_ONLY!');
	END IF;	
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ������� ��������� �������� ��������. 
	BEGIN
    SELECT pt.CHECK_VAL INTO CheckVal FROM SP.PAR_TYPES pt 
      WHERE pt.ID=:NEW.TYPE_ID;
  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
    	  SP.TG.ResetFlags;
			RAISE_APPLICATION_ERROR(-20033,
		    'SP.GLOBAL_PAR_S_bur. �� ������ ���: '||TO_CHAR(:NEW.TYPE_ID)||
				  ' ��� ���������� ���������: '||:NEW.NAME||'!');
	END;
	CASE
  -- ���� �������� �� �����������, �� �������� �������� �� ������������ ����,
  -- ���� �������� ��������� � ��������� ����������.
	  WHEN  CheckVal IS NOT NULL THEN
	    CheckVal := 
         'begin ' ||
		     CheckVal||
		    'exception when others then '||
				'  RAISE_APPLICATION_ERROR(-20033,'||
	      '''SP.GLOBAL_PAR_S_bur. ������ CheckVal'||
	      ' ��� ���������� ���������'||:NEW.NAME||'||SQLERRM'');'||
				'end;';
		  V:=SP.TVALUE(:NEW.TYPE_ID,null,0,
                  :NEW.E_VAL,:NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y);
      BEGIN
	      SP.CheckVal(CheckVal,V);
      EXCEPTION
        WHEN OTHERS THEN SP.TG.ResetFlags; RAISE;
      END;   
		-- ���� �������� E_VAL,
		-- �� ��������� �������� � ������������ � ���������.
	  WHEN  SP.G.notUpEQ(:OLD.E_VAL,:NEW.E_VAL) THEN
			BEGIN
	  	  SELECT e.N,e.D,e.S,e.X,e.Y INTO NDSXY FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID=:NEW.TYPE_ID AND g.S_UpEQ(e.E_VAL,:NEW.E_VAL)=1;
			EXCEPTION
			  WHEN NO_DATA_FOUND THEN	
	        SP.TG.ResetFlags;
 				  RAISE_APPLICATION_ERROR(-20033,
		      'SP.GLOBAL_PAR_S_bur. ����������� ��������:'||:NEW.E_VAL||
				  ' �� �������, ��� ���������: '||:NEW.NAME||'!');
			END;	 
	    :NEW.N := NDSXY.N;
	    :NEW.D := NDSXY.D; 
	    :NEW.S := NDSXY.S; 
	  	:NEW.X := NDSXY.X;
	  	:NEW.Y := NDSXY.Y;
		-- ���� E_VAL �� ���� � �� ��������, �� ������� E_VAL.
		WHEN  G.UpEQ(:OLD.E_VAL,:NEW.E_VAL) 
			AND	(:OLD.E_VAL IS NOT NULL)
		THEN
			BEGIN
	  	  SELECT e.E_VAL INTO NEW_E_VAL FROM SP.ENUM_VAL_S e
	  	    WHERE e.TYPE_ID=:NEW.TYPE_ID 
					  AND (G.S_EQ(e.N,:NEW.N)+
					       G.S_EQ(e.D,:NEW.D)+
					       G.S_EQ(e.S,:NEW.S)+
					       G.S_EQ(e.X,:NEW.X)+
					       G.S_EQ(e.Y,:NEW.Y)
					       =5);
				:NEW.E_VAL:=NEW_E_VAL;				 
			EXCEPTION
			  WHEN NO_DATA_FOUND THEN	
      	  SP.TG.ResetFlags;
				  RAISE_APPLICATION_ERROR(-20033,
		      'SP.GLOBAL_PAR_S_bur. �� ������� ����������� ��������'||
          ' �� ����� ���������: '||:NEW.NAME||'!');
			END;
	END CASE;
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.GLOBAL_PAR_S_bdr
BEFORE DELETE ON SP.GLOBAL_PAR_S
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
	-- ������ ������� ��������������� ���������.
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.GLOBAL_PAR_S_bdr.'||
    ' ������ ������� ��������������� ���������.!');
	END IF;	
END;
/
--AFTER_DELETE-----------------------------------------------------------------
--
--AFTER_DELETE_TABLE----------------------------------------------------------


-- �������� ���������� ����������, ��������������� � ���������� �������������.
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.USERS_GLOBALS_bir
BEFORE INSERT ON SP.USERS_GLOBALS
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
tmpVar NUMBER;
NewState NUMBER;
TmpType NUMBER;
TmpChVal VARCHAR2(4000);
TmpGlParName SP.GLOBAL_PAR_S.NAME%TYPE;
TmpEval SP.ENUM_VAL_S.E_VAL%TYPE;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  SELECT t.ID, T.CHECK_VAL, p.NAME INTO TmpType, TmpChVal, TmpGlParName 
    FROM SP.GLOBAL_PAR_S p, SP.PAR_TYPES t 
    WHERE t.ID = p.TYPE_ID 
      AND p.ID = :NEW.GL_PAR_ID;
  IF TmpChVal IS NOT NULL AND :NEW.E_VAL IS NOT NULL THEN
     d(NVL(TmpGlParName,'null')||
       ' �� ���������� ��������,  E_VAL='||:NEW.E_VAL,
       'ERROR SP.USERS_GLOBALS_bir');
     RAISE_APPLICATION_ERROR(-20033,NVL(TmpGlParName,'null')||
      ' �� ���������� ��������,  E_VAL='||:NEW.E_VAL||'!');
  END IF;
  -- �������� �������� ��� ���������� �������� �� ����� ������������ ��� � �������� ��������� ������� ���������� ���������� ��� ������� ������ ��� � ��������� �������������.
  IF TmpChVal IS NULL THEN
    SELECT COUNT(*) INTO tmpVar FROM sp.enum_val_s 
      WHERE TYPE_ID = TmpType AND :NEW.E_VAL = E_VAL;
    IF tmpVar = 0 THEN
      d('TYPE_ID='||TO_CHAR(TmpType),'ERROR SP.USERS_GLOBALS_bir');
      d(':NEW.E_VAL='||:NEW.E_VAL,'ERROR SP.USERS_GLOBALS_bir');
      d('�������� '||:NEW.E_VAL||' ��� � ������ ���������� ����������!',
        'ERROR SP.USERS_GLOBALS_bir');
      RAISE_APPLICATION_ERROR(-20033,'�������� '||:NEW.E_VAL||
        ' ��� � ������ ���������� ����������!');
    END IF;
  END IF;
  --SP.TG.CurIDUsersGlobals := tmpVar+REPLICATION.NODE_ID;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.USERS_GLOBALS_bur
BEFORE UPDATE ON SP.USERS_GLOBALS
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
TmpType NUMBER;
tmpVar NUMBER;
TmpChVal VARCHAR2(4000);
TmpGlParName SP.GLOBAL_PAR_S.NAME%TYPE;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- ������������ ������ ������������� � ������ ��� �������� ���������.
  :NEW.ID := :OLD.ID;
  :NEW.GL_PAR_ID := :OLD.GL_PAR_ID;
  :NEW.SP_USER := :OLD.SP_USER;
  -- �������� �������� ��� ���������� �������� �� ����� ������������ ��� � �������� ��������� ������� ���������� ���������� ��� ������� ������ ��� � ��������� �������������.
  IF :OLD.E_VAL IS NOT NULL THEN
    SELECT t.ID, T.CHECK_VAL, p.NAME INTO TmpType, TmpChVal, TmpGlParName 
      FROM SP.GLOBAL_PAR_S p, SP.PAR_TYPES t 
      WHERE t.ID = p.TYPE_ID 
        AND p.ID = :NEW.GL_PAR_ID;
    SELECT COUNT(*) INTO tmpVar FROM sp.enum_val_s 
      WHERE TYPE_ID = TmpType AND :NEW.E_VAL = E_VAL;
    IF tmpVar = 0 THEN
      d('TYPE_ID='||TO_CHAR(TmpType),'ERROR SP.USERS_GLOBALS_bir');
      d(':NEW.E_VAL='||:NEW.E_VAL,'ERROR SP.USERS_GLOBALS_bir');
      d('�������� '||:NEW.E_VAL||' ��� � ������ ���������� ����������!',
        'ERROR SP.USERS_GLOBALS_bir');
      RAISE_APPLICATION_ERROR(-20033,'�������� '||:NEW.E_VAL||
        ' ��� � ������ ���������� ����������!');
    END IF;
  END IF;
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.USERS_GLOBALS_bdr
BEFORE DELETE ON SP.USERS_GLOBALS
FOR EACH ROW
--(SP-TABLES.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  -- ������ ������� ��������� ��������� ������������.
  -- ��������� ���� �������� ���������� ������������ �� �������.
  IF not TG.SP_User_Deleting THEN
    SP.TG.ResetFlags;
    d('������� �������� ����������� ��������� '||:OLD.GL_PAR_ID||
      ' ������������ '||:OLD.SP_USER||' ���� '||
      DBMS_UTILITY.FORMAT_ERROR_STACK()||to_.str
      ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),'SP.USERS_GLOBALS_bdr.');
    RAISE_APPLICATION_ERROR(-20033,'SP.USERS_GLOBALS_bdr.'||
    ' ������ ������� ���������� ��������� ������������ ���������.!');
  END IF;  
END;
/
--AFTER_DELETE-----------------------------------------------------------------
--
--AFTER_DELETE_TABLE----------------------------------------------------------


-- ��������� ������� ���������� ���������� �������� ������������.
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.WORK_GLOBAL_PAR_S_bur
BEFORE UPDATE ON SP.WORK_GLOBAL_PAR_S
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
V SP.TVALUE;
TmpGlPar NUMBER;
BEGIN
  -- ����� �������� ������ �������� ����������.
  :NEW.UG_ID := :OLD.UG_ID;
  :NEW.NAME := :OLD.NAME;
  :NEW.TYPE_ID  := :OLD.TYPE_ID;
	:NEW.REACTION  := :OLD.REACTION;
	:NEW.R_ONLY:= :OLD.R_ONLY;
	IF :OLD.R_ONLY >0 THEN
	  RAISE_APPLICATION_ERROR(-20033,
		       'SP.WORK_GLOBAL_PAR_S �������� '||:NEW.NAME||
					 ' ������ ��� ������!');
  END IF;
  -- ���� ��� �� SYS, �� ��������� ��� �������� ��� ������� ������������.
  -- ��� ���������� � ��������� ������ ������������ ������� ��� ��������.
  IF S_User IS NOT NULL THEN
	  SELECT ID INTO TmpGlPar FROM SP.GLOBAL_PAR_S WHERE NAME  = :OLD.NAME;
	  UPDATE SP.USERS_GLOBALS SET 
	  	E_VAL=:NEW.E_VAL,N=:NEW.N, D=:NEW.D, S=:NEW.S, X=:NEW.X, Y=:NEW.Y
	    WHERE GL_PAR_ID = TmpGlPar
	      AND  SP_USER = S_User;  
	  IF SQL%rowcount=0 THEN
		  INSERT INTO SP.USERS_GLOBALS ( 
		      ID, GL_PAR_ID, SP_USER, 
		      E_VAL, N, D, S, X,Y ) 
		  VALUES ( 
			    NULL, TmpGlPar, S_User,  
		      :NEW.E_VAL, :NEW.N, :NEW.D, :NEW.S, :NEW.X, :NEW.Y)
	    RETURNING ID INTO :NEW.UG_ID; 
	  END IF;
  END IF;      
  -- ��������� �������� ���������, ���� ��������� ����������.
  IF :OLD.CHECK_VAL IS NOT NULL THEN
    SELECT CHECK_VAL INTO Checkval FROM SP.PAR_TYPES
      WHERE ROWID=:OLD.CHECK_VAL;
    V:=TVALUE;
    V.T:=:OLD.TYPE_ID;
    V.E:=:NEW.E_VAL;
    V.N:=:NEW.N;
    V.D:=:NEW.D;
    V.S:=:NEW.S;
    V.X:=:NEW.X;
    V.Y:=:NEW.Y;
    SP.CheckVal(CheckVal,V);
  END IF;
 
END;
/  

--AFTER_UPDATE-----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.WORK_GLOBAL_PAR_S_aur
AFTER UPDATE ON SP.WORK_GLOBAL_PAR_S
FOR EACH ROW
--(SP-TABLES.trg)
DECLARE
GP SP.TGPAR;
GL_PAR NUMBER;
BEGIN
	--d(:NEW.NAME||' E_VAL='||:NEW.E_VAL||', N='||:NEW.N||', D='||:NEW.D||
  --', S='||:NEW.S||', X='||:NEW.X||', Y='||:NEW.Y,'SP.WORK_GLOBAL_PAR_S_aur');
  -- ���� Temo=0, �� �������� ��������� � ���������� �������
	-- ���� ��������� REACTION 
	IF :NEW.REACTION IS NOT NULL THEN
	  BEGIN
  		GP:= SP.TGPAR(:NEW.NAME,
      SP.TVALUE(:NEW.TYPE_ID,null,0,
                :NEW.E_VAL,:NEW.N,:NEW.D,:NEW.S,:NEW.X,:NEW.Y));				 
	  	SP.GPAR_REACTION(:NEW.REACTION,GP); 
    EXCEPTION WHEN OTHERS THEN 
			RAISE_APPLICATION_ERROR(-20033,
        'SP.WORK_GLOBAL_PAR_S '||:NEW.NAME||'REACTION error => '||SQLERRM);							
		END;     
	END IF;
 END;
 /

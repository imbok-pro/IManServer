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

-- ����.
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
  -- ���� ���������� ������� ��������� ����, �� ��������� � � �������.
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
    -- ������ ������������� ���������� ����.
    IF :OLD.ID < 100 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_bur. ������ ������������� ���������� ����!');
    END IF;
    :NEW.NAME := trim(:NEW.NAME);
    -- ������������� ��� ����� ������ � �� ��������� ����.
    IF (:OLD.ORA = 1) and not (:NEW.NAME = :OLD.NAME) THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_bur. ������ �������� ��� ��������� ����!');
    END IF;
  END IF;
  -- ���� � ���� ���������� �������������� � �������, �� ������� � �� �������
  -- ��� ��������� � �������.
  IF :NEW.ORA = 1 and :OLD.ORA = 0 THEN
    SP.NEW_ROLE(:OLD.NAME);
    -- ���� ���� ����� ���������, �� �������� ����� �����, ������� ���
    -- ������������ ���������� ��� �� ������� ��� �������� ����������,
    -- ���� ��������� ����.
    -- ���������� ������� ���������� � ��������� ��������.
    INSERT INTO SP.UPDATED_SP_ROLES 
      VALUES (:NEW.ID, :NEW.NAME, :NEW.COMMENTS, :NEW.ORA,
              :OLD.ID, :OLD.NAME, :OLD.COMMENTS, :OLD.ORA);
  END IF;
  IF :NEW.ORA = 0 and :OLD.ORA = 1 THEN
    -- ���������, ��� ���� �� ������������ ������������� SP.
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
        ' ������ ������� �� ������� ����, ������� ���� ������������,'||
        ' ��� ��������� ����!');
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
  --d('table ������','SP_ROLES_au');
   IF SP.TG.AfterUpdateSpRoles THEN RETURN; END IF;
  SP.TG.AfterUpdateSpRoles:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_SP_ROLES WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- ��������� ������ ���� ���������.
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
    -- �������� ������ �� �����.
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
    -- ������� ������������ ������.
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
  -- ������ ������� ���� � ���������������� ������ 100.
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.ROLES_bdr. ������ ������� ���������� ����!');
  END IF;
  -- ��������� ��������� �������� �������� �����.
  SP.TG.RolesDeleting:=TRUE;
  -- �������� �� ��-����������� �������� ���� ����� ������������ ������
  -- ��������� � ��������� ��������.
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
  --d('table ������','SP_ROLES_ad');
   IF SP.TG.AfterDeleteSpRoles THEN RETURN; END IF;
  SP.TG.AfterDeleteSpRoles:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_SP_ROLES WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- ������ ������� ����, 
    -- ���� �� �� ���� ������ � ���������� ������� ��������,
    -- ��� � ���������� ������� ������ 
    -- ��� � ������� �������� ���������� ������.
    select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_S p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        '������ ������� ����, ������������ � ���������� ������� ������!');
    END IF;    
    select count(*) into tmpVar from SP.MODEL_OBJECT_PAR_STORIES p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        '������ ������� ����, ������������ � ������� ���������� ������� ������!');
    END IF;    
    select count(*) into tmpVar from SP.OBJECT_PAR_S p 
      where P.TYPE_ID = G.TROLE and N = rec.OLD_ID;
    IF tmpVar > 0 THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.ROLES_ad. '||
        '������ ������� ����, ������������ � ���������� ������� ��������!');
    END IF; 
    -- ������� ���� �� �������, ���� ��� ���������.
    IF rec.OLD_ORA = 1 THEN   
      SP.DROP_ROLE(rec.OLD_NAME);
    END IF;  
    -- ������� ������������ ������.
    DELETE FROM SP.DELETED_SP_ROLES WHERE OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteSpRoles:= FALSE;
  SP.TG.RolesDeleting:=TRUE;
END;
/

-- �������� �����.
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
    RAISE_APPLICATION_ERROR(-20033,'SP.SP_ROLES_RELS_bir. ���������� ������������!');
  END IF;
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  -- �������� �� ������������ �������� � ������������� ���������� ����� ����� �
  -- ������� ��������� � ��������� ��������.
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
  --d('table ������','SP_ROLES_RELS_ai');
   IF SP.TG.AfterInsertSpRolesRels THEN RETURN; END IF;
  SP.TG.AfterInsertSpRolesRels:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_SP_ROLES_RELS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- ���������, ��� ���� ���������� ����� �� ������������ ����� ���� ���� ��
    -- �������������� ����� ����, ��������������� ����� � ��������� �����.
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
        '���������� ����� �������� � ������������ �����!');
    END IF; 
    -- ���� ����������� ����� ����� ���������� ������,
    -- �� ��������� ����� � �������.
    select r.ORA, G.ORA into tmpRole, tmpGranted 
      from SP.SP_ROLES r, SP.SP_ROLES g 
      where r.ID = rec.NEW_ROLE_ID and g.ID = rec.NEW_GRANTED_ID;
    IF (tmpRole = 1) and (tmpGranted = 1) THEN   
      SP.GRANT_ROLE(rec.NEW_GRANTED_ID, rec.NEW_ROLE_ID);
    END IF;  
    -- ������� ������������ ������.
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
    'SP.SP_ROLES_RELS_bur. ������ ������������� �������� �����!');
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
  -- �� ��������� � ��������� �������� �����.
  IF ReplSession or SP.TG.RolesDeleting THEN RETURN; END IF;
  -- ������ ������� ���������� ����� � ���������������� ������ 100.
  IF :OLD.ID < 100 THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.ROLES_REL_bdr. ������ ������� ���������� �������� �����!');
  END IF;
  -- �������� ��������� ������� ��������� � ��������� ��������.
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
  --d('table ������','SP_ROLES_RELS_ad');
   IF SP.TG.AfterDeleteSpRolesRels THEN RETURN; END IF;
  SP.TG.AfterDeleteSpRolesRels:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_SP_ROLES_RELS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    -- ���� ��������� ����� ����� ���������� ������,
    -- �� �������� ����� � �������.
    select r.ORA, G.ORA into tmpRole, tmpGranted 
      from SP.SP_ROLES r, SP.SP_ROLES g 
      where r.ID = rec.OLD_ROLE_ID and g.ID = rec.OLD_GRANTED_ID;
    IF (tmpRole = 1) and (tmpGranted = 1) THEN   
      SP.REVOKE_ROLE(rec.OLD_ROLE_ID, rec.OLD_GRANTED_ID );
    END IF;  
    -- ������� ������������ ������.
    DELETE FROM SP.DELETED_SP_ROLES_RELS WHERE OLD_ID=rec.OLD_ID;
  END LOOP;
  SP.TG.AfterDeleteSpRolesRels:= FALSE;
END;
/

-- ������ ��������.
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
  -- ������ ������������� ����� ������������� ������ ��������.
	IF    NOT SP.TG.SP_ADMIN	THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bir.'||
      ' ������������ ���������� ��� ���������� ����!');
	END IF;	
  -- ������ �� ����������� ������. 
  IF :NEW.ID=:NEW.PARENT_ID THEN :NEW.PARENT_ID:=NULL; END IF;
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
CREATE OR REPLACE TRIGGER SP.CATALOG_TREE_bur
BEFORE UPDATE ON SP.CATALOG_TREE
FOR EACH ROW
--(SP-CATALOG.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
	-- ������������� ���� ����� ������ �������������.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bur. '||
      '������������ ���������� ��� ��������� �����!');
  END IF;
  -- ���� �� ������ ��� �� �������� ���� ��������� ��� ������������,
  -- �� �������� �� �������.
  IF (:NEW.M_DATE is null) or (:NEW.M_DATE = :OLD.M_DATE) THEN
    :NEW.M_DATE := sysdate;
  END IF;
  IF (:NEW.M_DATE is null) or (:NEW.M_USER = :OLD.M_USER) THEN
    :NEW.M_USER := TG.UserName;
  END IF;
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ��������� ���������� ������������ �� ����� �������� � ��������� ��������.
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
    -- ��������� ���������� ������������ �� ����� ��������.
    -- ����� �������� �� ������ �������� ����� ����� �������� ����.
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
	-- ������� ������������ ������.
    DELETE FROM SP.UPDATED_CATALOG_TREE WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateCatalogTree:= FALSE;
EXCEPTION
  WHEN Cycle_ERR THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033, 'SP.CATALOG_TREE_au.  '||
	    '��������� �������� ���� '||rec.OLD_NAME||' �������� � ������������.');
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
  -- ���������, ��� ������ ������� ������ �������� �� ������������ ��� ������ � ���������� TTreeNode
  select count(*) into tmpVar from SP.OBJECT_PAR_S where TYPE_ID = SP.G.TTreeNode and N = :OLD.ID;
  if tmpVar > 0 then
     RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bdr. '||
      '������� ������ �������� ������������ ��� ������ � ���������� TTreeNode!');
  end if;
  -- ������� ������ ����� ������ �������������.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.CATALOG_TREE_bdr. '||
      '������������ ���������� ��� �������� �����!');
  END IF;
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
--
--*****************************************************************************


-- �������.
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
--  -- ������������, ������� ���� ������������ ����� �������� �����.
--  d();
--	IF    NOT SP.TG.SP_ADMIN
--    AND :NEW.OBJECT_KIND != SP.G.SINGLE_OBJ
--	THEN
--		SP.TG.ResetFlags;	  
--    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bir.'||
--      ' ������������ ���������� ��� ���������� ������� ��������!');
--	END IF;	 
	-- ���� ���� �������������� ������������ � ������������ �� �������������,
  -- �� ��������� ���� ������������.
	IF (:NEW.EDIT_ROLE IS NULL) AND (NOT SP.TG.SP_ADMIN) THEN
	   :NEW.EDIT_ROLE:=SP.G.USER_ROLE;
	END IF;
  -- �������� ������� � �������� �����.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- ��� ������� �� ������ ��������� ".".
  IF instr(:NEW.NAME,'.')>0 THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bir.'||
      ' ��� ������� �������� '||:NEW.NAME||' �� ����� ��������� "."!');
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
	-- ������������� ���� ����� �������������.
  -- ���� ���� �������������� ������� �� ����, �� ������������� ������
  -- ����� ������������, ������� ���� �������������� �������.
  IF NOT SP.TG.SP_ADMIN THEN
		IF   (:OLD.EDIT_ROLE IS NULL)
		  OR NOT SP.HasUserRoleID(:OLD.EDIT_ROLE)
		THEN
			SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bur. '||
        '������������ ���������� ��� ��������� �������: '||:OLD.NAME||'!');
		END IF;
  END IF;
  -- �������� ������� � �������� �����.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- ��� ������� �� ������ ��������� ".".
  IF instr(:NEW.NAME,'.')>0 THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bur.'||
      ' ��� ������� �������� '||:NEW.NAME||' �� ����� ��������� "."!');
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
      'SP.OBJECTS_bdr. ������ ������� ���������������� �������!');
	END IF;
  --d('������','OBJECTS_bdr');
	-- ������� ������ ����� ������ �������������.
  IF NOT SP.TG.SP_ADMIN THEN
		SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECTS_bdr. '||
    '������������ ���������� ��� �������� �������: '||:OLD.NAME||'!');
  END IF;
	-- ��������� ��������� �������� ���������� ��������.
  -- � ����������������.
  SP.TG.ObjectParDeleting:=TRUE;
  --SP.TG.ModObjParDeleting:=true;
  -- ���������� ��� �������.
  -- ��� ������� ������������ ��� ����������� ������, ��������� � ���������
  -- �������, ��������������� � ����������������� ������� ������� ��������.
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
  --d('table ������','OBJECTS_ad');
  SP.TG.ObjectParDeleting:=FALSE;
   IF SP.TG.AfterDeleteObjects THEN RETURN; END IF;
  SP.TG.AfterDeleteObjects:= TRUE;
  LOOP                                                                          
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_OBJECTS WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
	  -- ������ ������� ������, ���� �� ������������ � ����������� ��������,
    -- ������� ����� ��������.
	  SELECT COUNT(*) INTO tmpVar FROM DUAL 
	    WHERE EXISTS (SELECT * FROM SP.MODEL_OBJECTS co 
                      WHERE co.OBJ_ID=rec.OLD_ID
                        AND co.PARENT_MOD_OBJ_ID IS NOT NULL);
	  IF tmpVar>0 THEN 
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033, 'SP.OBJECTS_ad.  '||
	    '������ ������� ������ '||rec.OLD_NAME||
      ', ������������ � ����������� ��������, ������� ����� ��������.');
	  END IF;
	  -- ������ ������� ������, ���� �� ������������ � ������������� ������
    -- �������� ��������.
	  SELECT COUNT(*) INTO tmpVar FROM DUAL 
	    WHERE EXISTS (SELECT * FROM SP.MACROS m 
                      WHERE m.USED_OBJ_ID = rec.OLD_ID);
	  IF tmpVar>0 THEN 
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033, 'SP.OBJECTS_ad.  '||
	    '������ ������� ������ '||rec.OLD_NAME||
      ', ������������ � ������������ ������ �������� ��������.');
	  END IF;
    -- ������� ������������ ������.
    DELETE FROM SP.DELETED_OBJECTS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterDeleteObjects:= FALSE;
END;
/

--*****************************************************************************

-- ��������� ��������.
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
  -- �������� �������� ����� ������������� ��� ������������,
  -- ������� ���� �������������� �������.
  IF NOT SP.HasUserEditRoleID(EditRole)THEN
	  SP.TG.ResetFlags;	  
	  RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_bir. '||
      '������������ ���������� ��� ��������� �������: '||ObjName||'!');
  END IF;
  -- �������� ������� � �������� �����.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- ��������� ��� ������������ ��������� �� ������������.
  IF REGEXP_INSTR(REGEXP_REPLACE(:NEW.NAME,'->','',1,1),
	                '[^[:alnum:]_\$\# ]')>0 
  THEN
	  SP.TG.ResetFlags;	  
    RAISE_APPLICATION_ERROR(-20033,
     'SP.OBJECT_PAR_S_bir. �������� ����� ������������ ���'||
      :NEW.NAME||'!');
  END IF;
	-- ���� �������� �����������, �� ��������� ��� ��������.
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
		      'SP.OBJECT_PAR_S_bir. ����������� ��������: '||NEW_E_VAL||
          ' �� ������� � ��������� '||:NEW.NAME||' ������� '||ObjName||
          '!');	 
		END;	 
    :NEW.N := NDSXY.N;
    :NEW.D := NDSXY.D; 
    :NEW.S := NDSXY.S; 
  	:NEW.X := NDSXY.X;
  	:NEW.Y := NDSXY.Y;
	END IF;	  
	-- ���� ��������� �������� �������� ����������, �� ��������� ��������
  -- ���������. 
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
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ���� �� ������ ���� ��������� ��� ������������, �� ��������� �������.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF;
  IF :NEW.M_USER is null THEN
    if TG.UserName is null then
      RAISE_APPLICATION_ERROR(-20033,
        'SP.OBJECT_PAR_S_bir. ������ ���������� ������,' ||
        ' ���������� ����������� ���� ������!');
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
    -- ��������, ���������� �� � ������� ���������� �������� �
    -- ���� ������� ����������, �� ��� ���.     
      select count(*), min(TYPE_ID) into tmpVar, MType
        from SP.MODEL_OBJECTS mo, SP.MODEL_OBJECT_PAR_S mp 
        where UPPER(MP.NAME) = UPPER(rec.NEW_NAME)
          and MO.ID = MP.MOD_OBJ_ID
          and MO.OBJ_ID = rec.NEW_OBJ_ID;
    -- ���� �������� ������ ��� ������ � � �������� ������ ����������
    -- ��������������� ��������, �� ���������� ������. 
    if rec.NEW_R_ONLY = SP.G.READONLY 
    then
      if tmpVar > 0 then 
        SP.TG.ResetFlags;   
        RAISE_APPLICATION_ERROR(-20033,
          'SP.OBJECT_PAR_S_ai. ����������� �������� '||rec.NEW_NAME||
          ' �������� ������ ��� ������, ������ '||
           tmpVar||' ���������(��) ������� ������� ��� �������� '||
           '��������������� ��������.'||
           ' ������� ��� �������� ��� ������������ ��������!');   
      end if;
    end if;     
    -- ���� � �������� ������ ���������� ��������������� ��������,
    -- � ��� �� ���������, �� ���������� ������. 
    if (tmpVar > 0) and (rec.NEW_TYPE_ID != MType) 
    then
      SP.TG.ResetFlags;   
      RAISE_APPLICATION_ERROR(-20033,
        'SP.OBJECT_PAR_S_ai. ��� ������������ ��������� '||rec.NEW_NAME||
        ' �� ��������� � ��� ������������� � '||
         tmpVar||' ���������(��) ������� ������� ����������.'||
         ' ������� ��� �������� ��� ������������ ��������!');   
    end if;     
    -- ��������� ������������� ��������� � ��� ������������ ��������� ��������
    -- � ������� ����������� � ��� ��� � ���.
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
    -- ������� ������������ ������.
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
  --d('������','SP.OBJECT_PAR_S_bur');
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID := :OLD.ID;
  :NEW.OBJ_ID:=:OLD.OBJ_ID;
  -- �������� ������� � �������� �����.
  :NEW.NAME := trim(:NEW.NAME);
  :NEW.NAME := replace(:NEW.NAME, chr(10));
  -- ���� �������� ���, �� ��������� ��� �� ������������.
	IF SP.G.notUpEQ(:NEW.NAME,:OLD.NAME) THEN
		IF REGEXP_INSTR(REGEXP_REPLACE(:NEW.NAME,'->','',1,1),
		                '[^[:alnum:]_\$\# ]')>0 
		THEN
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033,
	     'SP.OBJECT_PAR_S_bur. �������� ����� ������������ ���'||
	      :NEW.NAME||'!');
    END IF;    
  END IF;
  -- ���� �� ������ ������, �� ����������� �������� �� ���������.
  IF :NEW.GROUP_ID is null THEN :NEW.GROUP_ID := G.OTHER_GROUP; END IF; 
  -- ���� �������� �����������, �� ���� "E_VAL" �� ����.
   -- ��������� ���� "E_VAL" �� ������ ��������,
   -- ����� ������������ ����������� �������� �������� ���.
   -- ���� �������� ��� ��������, �� ��������� ��������.
   -- ���� ���������� ��������, � ��� �������� ������, �� �������� ���. 
	CASE
		-- ���� �������� ���� "E_VAL", �� ��������� �������� ���������
     -- � ������������ � ������ ��������.
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
		        'SP.FRAME_PAR_S_bur. ����������� �������� '||:NEW.E_VAL||
				    ' �� �������, ��� ��������� '||:NEW.NAME||'!');
			END;	 
	    :NEW.N := NDSXY.N;
	    :NEW.D := NDSXY.D; 
	    :NEW.S := NDSXY.S; 
	  	:NEW.X := NDSXY.X;
	  	:NEW.Y := NDSXY.Y;
		-- ���� ���� "E_VAL" �� ����, � ������� ��������,
     -- �� ������� ��� ���������.
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
		        'SP.OBJECT_PAR_S_bur. ����������� �������� '||:NEW.E_VAL||
				    ' �� �������, ��� ��������� '||:NEW.NAME||'!');
			END;	 
	ELSE
	  -- �������� �� �����������. 
    NULL;
	END CASE;
  -- ������������� ���� ��������� � ������������, ����������� ������,
  -- ���� ��� �� ������ ������
  if not Tg.ImportDATA then
    :NEW.M_DATE := sysdate;
    :NEW.M_USER := TG.UserName; 
  end if;  
  -- ���� �������� �������� ��������� � ��� ������ ��������,
  -- � �� ��� ���������������,
  -- ��� ������ ��� ��������� ��� ������� R_ONLY,
  -- �� ������������� ������� ��������� �� ���� ����������� ��������,
  -- ������� �������� �� ���� �������.
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
    --d('table ������ => return ','OBJECT_PAR_S_au');
    RETURN; 
  END IF;
  SP.TG.AfterUpdateObjectPars:= TRUE;
  --d('table ������','OBJECT_PAR_S_au');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.UPDATED_OBJECT_PAR_S WHERE ROWNUM=1;
    EXCEPTION
      WHEN no_data_found THEN EXIT;
    END;
    SELECT NAME, OBJECT_KIND, EDIT_ROLE INTO ObjName, ObjType, EditRole 
      FROM SP.OBJECTS
		  WHERE ID=rec.OLD_OBJ_ID;
	  -- ������������� ���� ����� �������������.
	  -- ���� ���� �������������� ������� �� ����, �� ������������� ������
	  -- ����� ������������, ������� ���� �������������� �������.
		IF NOT SP.HasUserEditRoleID(EditRole) THEN		
			SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_au.'||
        ' ������������ ���������� ��� ��������� �������: '||ObjName||'!');
    END IF;
		-- ���� ��������� �������� �������� ����������, �� ��������� �������� ��
    -- ������������ ��� ����. 
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
		      'SP.OBJECT_PAR_S_au. ����������� �������� '||rec.NEW_E_VAL||
				  ' �� �������, ��� ��������� '||rec.NEW_NAME||'!');
       END;    
    END IF;
    -- ���� �������� �������� ��������� � ��� ������ ��������,
    -- � �� ��� ���������������,
    -- ��� ������ ��� ��������� ��� ������� R_ONLY,
    -- �� ������������� ������� ��������� �� ���� ����������� ��������,
    -- ������� �������� �� ���� �������.
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
      -- ��������� ������������� ��������� � ��������� ��������, ��������� ��
      -- ��������� ������� � ������� ����������� ���.
      -- ������� ����� ��� ��������� �������� � ����������� ������.
      UPDATE SP.MODEL_OBJECT_PAR_S mp
        set OBJ_PAR_ID = rec.NEW_ID,
            NAME = null
        WHERE (mp.MOD_OBJ_ID IN (SELECT ID 
                               FROM SP.MODEL_OBJECTS mo 
                               WHERE mo.OBJ_ID = rec.OLD_OBJ_ID))
          AND (mp.NAME = rec.NEW_NAME)
      ;
      -- ���� ������ ��� ���������,
      -- �� ������� ��� ���������������� �������� ��������� � ��� �������.
      IF rec.NEW_TYPE_ID != rec.OLD_TYPE_ID THEN
--        UPDATE SP.MODEL_OBJECT_PAR_S set TYPE_ID = rec.NEW_TYPE_ID
--          WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=TRUE;
          DELETE FROM SP.MODEL_OBJECT_PAR_S WHERE OBJ_PAR_ID = rec.OLD_ID;
          DELETE FROM SP.MODEL_OBJECT_PAR_STORIES WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=FALSE;
      END IF;
      -- ���� �������� ���� R_Only, �� ������� ��� ��������� �������� ������,
      -- �� �������� �� ���� ��������? � ����� ��� �������.
      IF rec.NEW_R_ONLY = G.ReadOnly THEN
        SP.TG.ModObjParDeleting :=TRUE;
          DELETE FROM SP.MODEL_OBJECT_PAR_S WHERE OBJ_PAR_ID = rec.OLD_ID;
          DELETE FROM SP.MODEL_OBJECT_PAR_STORIES WHERE OBJ_PAR_ID = rec.OLD_ID;
        SP.TG.ModObjParDeleting :=FALSE;
      END IF;
    END IF;
    -- ���� �������� ������ ��� ������ � � ������� �������� �������� ���, 
    -- � � �������� ������ ���������� ��������������� ��������,
    -- �� ���������� ������. 
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
          'SP.OBJECT_PAR_S_au. ����������� �������� '||rec.NEW_NAME||
          ' �������� ������ ��� ������, ������ '||
           tmpVar||' ���������(��) ������� ������� ��� �������� '||
           '��������������� ��������.'||
           ' ������� ��� �������� ��� �� ����������� ��� ��� ��� ���������!');   
      end if;
    end if; 
    -- ���� ������ ����������� ������ ����������, �� �������� ��� � ����
    -- ��������������� ����������.
    if rec.NEW_R_ONLY != rec.OLD_R_ONLY then
      UPDATE SP.MODEL_OBJECT_PAR_S set R_ONLY = rec.NEW_R_ONLY
        WHERE OBJ_PAR_ID = rec.OLD_ID;
    end if;
    -- ���� ����� �������� R_ONLY �� ������������ ���������� �������,
    -- � ������ ������������,
    -- �� ������� ������� ��� ���� �������� ������.
    if    (rec.NEW_R_ONLY = SP.G.STORYLESS)
      and (rec.OLD_R_ONLY != SP.G.READONLY)
    then
      -- ������������� ���� ��� �������� �������� �������, 
      -- ����� �� �� �������� ��������� �������.
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
    -- ������� ������������ ������.
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
  --d('������','SP.OBJECT_PAR_S_bdr');
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.OBJECTS_bdr. ������ ������� ���������������� ��������� ��������!');
  END IF;
  -- ��������� �������  ��������� ����������� �����������,
  -- ������������ ���� ��������.
  SP.TG.ModObjParDeleting :=TRUE;
  -- ���� ��� ��������� �������� ���������� ����� �������� �������, �� �����.
  IF SP.TG.ObjectParDeleting THEN RETURN; END IF;
  -- �������� ���������� ������������ � ��������� ��������� ��������� �
  -- ��������� �������� ���������� � ��������� ��������.
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
  --d('table ������','OBJECT_PAR_S_ad');
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
 			-- ��������� �������� ���������� ����� �������� ������.
	  	WHEN no_data_found THEN GOTO NEXT_RECORD;
  	END;
	  -- ������� �������� ����� ������������� ��� ������������, ������� ����
    -- �������������� �������.
	  IF NOT SP.HasUserEditRoleID(EditRole)	THEN
			BEGIN
		 		RAISE Cycle_ERR;
		 	EXCEPTION
		   	WHEN Cycle_ERR THEN
					SP.TG.ResetFlags;	  
			    RAISE_APPLICATION_ERROR(-20033,'SP.OBJECT_PAR_S_ad. '||
		        '������������ ���������� ��� ��������� �������: '||
		        ObjName||'!');
      END;    
	  END IF;
	  -- ������� ������������ ������.
    DELETE FROM SP.DELETED_OBJECT_PAR_S WHERE OLD_ID=rec.OLD_ID; 
    <<NEXT_RECORD>> NULL;
	END LOOP;	  
  SP.TG.AfterDeleteObjectPars:= FALSE;
  SP.TG.ModObjParDeleting :=FALSE;
END;
/

-- end of file


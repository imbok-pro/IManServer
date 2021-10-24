-- GObjects views triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.06.2013
-- update 04.10.2013 17.06.2014 06.01.2015-07.01.2015 12.04.2017 24.12.2018
--
-- Объекты каталога.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_OBJECTS_ii
INSTEAD OF INSERT ON SP.VG_OBJECTS
-- (SP-GObjects-Instead.trg)
DECLARE
  KindID NUMBER(1);
  G_ID NUMBER;
  NewName SP.OBJECTS.NAME%type;
  pos NUMBER;
  NewGroup SP.GROUPS.NAME%type;
BEGIN
  -- Если задано полное имя объекта, то используем группу и имя объекта,
  -- определённые этим полным именем,
  -- иначе используем короткое имя и имя или идентификатор группы.
  IF :NEW.FULL_NAME is not null THEN
    -- Находим позицию последней точки.
    pos:=instr(:NEW.FULL_NAME,'.',-1);
    -- Находим короткое имя.
    NewName:=substr(:NEW.FULL_NAME,pos+1);
    -- Находим полное имя.
    NewGroup:=substr(:NEW.FULL_NAME,1,pos-1);
    begin
      select ID into G_ID from SP.GROUPS 
        where upper(NAME) = upper(NewGroup);
    exception
      when no_data_found then  
        RAISE_APPLICATION_ERROR(-20033,'SP.VG_OBJECTS_ii. '||
          'Группа '||nvl(NewGroup,'null')||' не найдена!');
    end;   
  ELSE
    NewName:=:NEW.SHORT_NAME;
	  IF :NEW.GROUP_NAME is not null THEN
	    begin
	      select ID into G_ID from SP.GROUPS 
	        where upper(NAME) = upper(:NEW.GROUP_NAME);
	    exception
	      when no_data_found then  
	        RAISE_APPLICATION_ERROR(-20033,'SP.VG_OBJECTS_ii. '||
	          'Группа '||:NEW.GROUP_NAME||' не найдена!');
	    end;   
	  ELSIF :NEW.GROUP_ID is null THEN
	    G_ID:= 2;
	  ELSE
	    --!! Можно записывать согласно глобальному параметру?
	    G_ID:=:NEW.GROUP_ID;
	  END IF;
  END IF;
  -- Если вид объекта задан в символьном виде, то находим идентификатор
  -- вида.
  KindID:=:NEW.KIND_ID;
  IF :NEW.KIND IS NOT NULL THEN 
    KindID:=SP.to_Obj_KIND(:NEW.KIND);
  END IF;
  IF (KindID IS NULL) OR (KindID NOT IN (0,1,2,3)) THEN 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.VG_OBJECTS_ii.Не корректно задан вид объекта !');
  END IF;
  UPDATE SP.OBJECTS SET 
    IM_ID = :NEW.IM_ID, 
    COMMENTS = :NEW.COMMENTS,
    OBJECT_KIND = KindID,
    USING_ROLE = :NEW.USING_ROLE_ID,
    EDIT_ROLE = :NEW.EDIT_ROLE_ID,
    MODIFIED = :NEW.MODIFIED 
  WHERE UPPER(NAME) = UPPER(NewName)
    AND GROUP_ID = G_ID;
  IF SQL%NOTFOUND THEN
    INSERT INTO SP.OBJECTS 
      (OID, IM_ID, NAME, COMMENTS, OBJECT_KIND, GROUP_ID,
       USING_ROLE, EDIT_ROLE, MODIFIED, M_USER)
      VALUES 
      (:NEW.OID, :NEW.IM_ID, NewName, :NEW.COMMENTS, KindID, G_ID,
       :NEW.USING_ROLE_ID, :NEW.EDIT_ROLE_ID, :NEW.MODIFIED, TG.UserName);
  END IF;
END;
/	
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_OBJECTS_iu
INSTEAD OF UPDATE ON SP.VG_OBJECTS
-- (SP-GObjects-Instead.trg)
DECLARE
  KindID NUMBER(1);
  URoleID NUMBER;
  ERoleID NUMBER; 
  G_ID NUMBER;
  NewName SP.OBJECTS.NAME%type;
  pos NUMBER;
  NewGroup SP.GROUPS.NAME%type;
BEGIN
  -- Если задано полное имя объекта, то используем группу и имя объекта,
  -- определённые этим полным именем,
  -- иначе используем короткое имя и имя или идентификатор группы.
  IF G.notUPEQ(:NEW.FULL_NAME, :OLD.FULL_NAME) THEN
    -- Находим позицию последней точки.
    pos:=instr(:NEW.FULL_NAME,'.',-1);
    -- Находим короткое имя.
    NewName:=substr(:NEW.FULL_NAME,pos+1);
    -- Находим полное имя.
    NewGroup:=substr(:NEW.FULL_NAME,1,pos-1);
    begin
      select ID into G_ID from SP.GROUPS 
        where upper(NAME) = upper(NewGroup);
    exception
      when no_data_found then  
        RAISE_APPLICATION_ERROR(-20033,'SP.VG_OBJECTS_iu. '||
          'Группа '||nvl(NewGroup,'null')||' не найдена!');
    end;   
  ELSE
    NewName:=:NEW.SHORT_NAME;
	  IF G.notUPEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) THEN
	    begin
	      select ID into G_ID from SP.GROUPS 
	        where upper(NAME) = upper(:NEW.GROUP_NAME);
	    exception
	      when no_data_found then  
	        RAISE_APPLICATION_ERROR(-20033,'SP.VG_OBJECTS_iu. '||
	          'Группа '||:NEW.GROUP_NAME||' не найдена!');
	    end;   
	  ELSE
	    G_ID:=:NEW.GROUP_ID;
	  END IF;
  END IF;
  --  
  KindID:=:NEW.KIND_ID;
  IF :NEW.KIND IS NOT NULL THEN 
    IF SP.G.notUpEQ(:NEW.KIND,:OLD.KIND) THEN 
      KindID:=SP.to_Obj_KIND(:NEW.KIND);
    END IF;  
  END IF;
  IF (KindID IS NULL) OR (KindID NOT IN (0,1,2,3)) THEN 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.VG_OBJECTS_iu.Не корректно задан вид объекта !');
  END IF;   
  ERoleID := :NEW.EDIT_ROLE_ID;
  IF SP.G.notUpEQ(:NEW.EDIT_ROLE,:OLD.EDIT_ROLE) THEN 
     IF :NEW.EDIT_ROLE IS NULL THEN
     ERoleID := NULL;
     ELSE
       BEGIN
         SELECT ID INTO ERoleID FROM sp.sp_roles WHERE NAME = :NEW.EDIT_ROLE;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20033,
          'SP.VG_OBJECTS_iu. Такой роли не существует !');
       END;
     END IF;
  END IF;
  --
  URoleID := :NEW.USING_ROLE_ID;
  IF SP.G.notUpEQ(:NEW.USING_ROLE,:OLD.USING_ROLE) THEN 
     IF :NEW.USING_ROLE IS NULL THEN
     URoleID := NULL;
     ELSE
       BEGIN
         SELECT ID INTO URoleID FROM sp.sp_roles WHERE NAME = :NEW.USING_ROLE;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20033,
          'SP.V_OBJECTS_iu. Такой роли не существует !');
       END;
     END IF;
  END IF;
  --
  UPDATE SP.OBJECTS SET 
    COMMENTS = :NEW.COMMENTS,
    NAME = NewName,
    OBJECT_KIND = KindID,
    USING_ROLE = URoleID,
    EDIT_ROLE = ERoleID,
    GROUP_ID = G_ID,
    MODIFIED = :NEW.MODIFIED,
    M_USER = TG.UserName 
  WHERE ID = :OLD.ID;
END;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_OBJECTS_id
INSTEAD OF DELETE ON SP.VG_OBJECTS
-- (SP-GObjects-Instead.trg)
BEGIN
  DELETE FROM SP.OBJECTS WHERE ID = :OLD.ID;
END;
/	
--*****************************************************************************

-- end of File 
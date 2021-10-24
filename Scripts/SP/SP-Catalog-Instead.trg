-- тригеры для catalog views
-- create 01.10.2010
-- by Irina Gracheva
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 13.10.2010 17.11.2010 24.11.2010 09.12.2010 20.12.2010 11.02.2011
-- by Nikolay Krasilnikov
--        19.01.2012 16.03.2012 13.06.2013 17.06.2013 25.08.2013 04.10.2013
--        13.06.2014 30.08.2014 06.01.2015-07.01.2015 31.03.2015 07.07.2016
--        01.11.2016 02.04.2017 12.04.2017
--
-- Дерево каталога.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_CATALOG_TREE_ii
INSTEAD OF INSERT ON SP.V_CATALOG_TREE
-- (SP-Catalog-Instead.trg)
DECLARE
  tmpVar NUMBER;
  tmpN NUMBER;
  TmpStr SP.COMMANDS.COMMENTS%type;
  G_ID NUMBER;
BEGIN
  IF :NEW.GROUP_NAME is not null THEN
    begin
      select ID into G_ID from SP.GROUPS 
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then  
        RAISE_APPLICATION_ERROR(-20033,'SP.V_CATALOG_TREE_ii. '||
          'Группа '||:NEW.GROUP_NAME||' не найдена!');
    end;   
  ELSIF :NEW.GROUP_ID is null THEN
    G_ID:= G.OTHER_GROUP;
  ELSE
    G_ID:=:NEW.GROUP_ID;
  END IF;
  TmpStr := :NEW.FULL_NAME;
  IF TmpStr IS NULL THEN
    TmpStr := :NEW.PARENT_NAME||'\'||:NEW.NAME;
    IF :NEW.PARENT_NAME IS NULL THEN
      UPDATE SP.CATALOG_TREE SET 
        IM_ID = :NEW.IM_ID, 
        COMMENTS = :NEW.COMMENTS,
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER 
         WHERE UPPER(NAME) = UPPER(:NEW.NAME)
           AND PARENT_ID = :NEW.PARENT_ID;
      RETURN;
 		  IF SQL%NOTFOUND THEN
        INSERT INTO SP.CATALOG_TREE
          VALUES (NULL, :NEW.IM_ID, :NEW.NAME, :NEW.COMMENTS,
                  :NEW.PARENT_ID, G_ID, :NEW.M_DATE, :NEW.M_USER);
        RETURN;
      END IF;
    END IF;
  END IF;
  IF TmpStr IS NOT NULL THEN
	  tmpN:=NULL;
	  FOR c1 IN (SELECT COLUMN_VALUE s 
	               FROM TABLE (SP.SET_FROM_STRING(TmpStr,'\\')))
	  LOOP
	    tmpVar := tmpN; 
	    BEGIN
	      SELECT ID INTO tmpN FROM SP.CATALOG_TREE
	        WHERE UPPER(NAME)=UPPER(c1.s)
	          AND NVL(PARENT_ID,-1) = NVL(tmpN,-1);
	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      INSERT INTO SP.CATALOG_TREE
	        VALUES 
          (NULL, :NEW.IM_ID, c1.s, :NEW.COMMENTS, tmpN, G_ID,
           :NEW.M_DATE, :NEW.M_USER)
	      RETURNING ID INTO tmpN;    
	    END;
	  END LOOP;
  END IF;
END;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_CATALOG_TREE_iu
INSTEAD OF UPDATE ON SP.V_CATALOG_TREE
-- (SP-Catalog-Instead.trg)
DECLARE
  tmpVar NUMBER;
  V SP.TVALUE;
  G_ID NUMBER;
BEGIN
  IF G.notUPEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) THEN
    begin
      select ID into G_ID from SP.GROUPS 
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then  
        RAISE_APPLICATION_ERROR(-20033,'SP.V_CATALOG_TREE_iu. '||
          'Группа '||:NEW.GROUP_NAME||' не найдена!');
    end;   
  ELSE
    G_ID:=:NEW.GROUP_ID;
  END IF;
  -- Если если изменено имя родителя, то находим его идентификатор,
  -- иначе используем идентификатор нового родителя.  
  CASE
    WHEN trim(:NEW.PARENT_NAME)='\' THEN
      tmpVar:=NULL;
    WHEN :NEW.PARENT_NAME IS NOT NULL THEN 
      V:=SP.TVALUE(SP.G.TTreeNode);
      BEGIN
        SP.TREE.S2V(:NEW.PARENT_NAME, V);
      EXCEPTION
        WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20033,'SP.V_CATALOG_TREE_iu. '||
          'Родительский узел '||:NEW.PARENT_NAME||' не найден!');
      END;
      tmpVar:=V.N;
  ELSE
    tmpVar:=:NEW.PARENT_ID;  
  END CASE;   
  UPDATE SP.CATALOG_TREE SET 
    NAME = :NEW.NAME, 
    IM_ID = :NEW.IM_ID, 
    COMMENTS = :NEW.COMMENTS, 
    PARENT_ID = tmpVar, 
    GROUP_ID = G_ID,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER
    WHERE ID = :OLD.ID;
END;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_CATALOG_TREE_id
INSTEAD OF DELETE ON SP.V_CATALOG_TREE
-- (SP-Catalog-Instead.trg)
BEGIN
  DELETE FROM SP.CATALOG_TREE WHERE ID = :OLD.ID;
END;
/	
--*****************************************************************************
-- 
-- Объекты каталога.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECTS_ii
INSTEAD OF INSERT ON SP.V_OBJECTS
-- (SP-Catalog-Instead.trg)
DECLARE
  KindID NUMBER(1);
  G_ID NUMBER;
  NewName SP.OBJECTS.NAME%type;
  pos NUMBER;
  NewGroup SP.GROUPS.NAME%type;
  URole NUMBER;
  ERole NUMBER;
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
        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_ii. '||
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
	        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_ii. '||
	          'Группа '||:NEW.GROUP_NAME||' не найдена!');
	    end;   
	  ELSIF :NEW.GROUP_ID is null THEN
	    G_ID:= 2;
	  ELSE
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
      'SP.V_OBJECTS_ii.Не корректно задан вид объекта !');
  END IF;
  -- Находим идентификаторы ролей доступа.
  URole := :NEW.USING_ROLE_ID;
  if :NEW.USING_ROLE is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_ii'||
            'Роль '||:NEW.USING_ROLE||' не найдена!');
    end;  
  end if;
  ERole := :NEW.EDIT_ROLE_ID;
  if :NEW.EDIT_ROLE is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.EDIT_ROLE;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_ii'||
            'Роль '||:NEW.EDIT_ROLE||' не найдена!');
    end;  
  end if;
  -- Если объект уже существует, то производим обновление его полей.
  UPDATE SP.OBJECTS SET 
    IM_ID = :NEW.IM_ID, 
    COMMENTS = :NEW.COMMENTS,
    OBJECT_KIND = KindID,
    USING_ROLE = URole,
    EDIT_ROLE = ERole,
    MODIFIED = :NEW.MODIFIED 
  WHERE UPPER(NAME) = UPPER(NewName)
    AND GROUP_ID = G_ID;
  IF SQL%NOTFOUND THEN
    INSERT INTO SP.OBJECTS 
      (OID, IM_ID, NAME, COMMENTS, OBJECT_KIND, GROUP_ID,
       USING_ROLE, EDIT_ROLE, MODIFIED)
      VALUES 
      (:NEW.OID, :NEW.IM_ID, NewName, :NEW.COMMENTS, KindID, G_ID,
       URole, ERole, :NEW.MODIFIED);
  END IF;
END;
/	
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECTS_iu
INSTEAD OF UPDATE ON SP.V_OBJECTS
-- (SP-Catalog-Instead.trg)
DECLARE
  KindID NUMBER(1);
  URoleID NUMBER;
  ERoleID NUMBER; 
  G_ID NUMBER;
  NewName SP.OBJECTS.NAME%type;
  pos NUMBER;
  NewGroup SP.GROUPS.NAME%type;
  tmpVar NUMBER;
BEGIN
  -- Если изменено полное имя объекта, то используем группу и имя объекта,
  -- определённые этим полным именем,
  -- иначе используем короткое имя и имя или идентификатор группы.
  IF G.notUPEQ(:NEW.FULL_NAME,:OLD.FULL_NAME) THEN
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
        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_iu. '||
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
	        RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_iu. '||
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
      'SP.V_OBJECTS_iu.Не корректно задан вид объекта !');
  END IF; 
  --
  -- Нельзя изменить вид объекта с макры, если есть макрокоманды.
  IF (KindID != 2) AND (:OLD.KIND_ID = 2) THEN 
    select count(*) into tmpVar from SP.MACROS m where M.OBJ_ID = :OLD.ID;
    if tmpVar > 0 then
    RAISE_APPLICATION_ERROR(-20033,
      'SP.V_OBJECTS_iu.Нельзя изменить вид объекта,
       если у макры есть макрокоманды!');
    end if;  
  END IF;
  --  
  URoleID := :NEW.USING_ROLE_ID;
  IF SP.G.notUpEQ(:NEW.USING_ROLE,:OLD.USING_ROLE) THEN 
     IF :NEW.USING_ROLE IS NULL THEN
       URoleID := NULL;
     ELSE
       BEGIN
         SELECT ID INTO URoleID FROM SP.SP_ROLES WHERE NAME = :NEW.USING_ROLE;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_iu'||
            'Роль '||:NEW.USING_ROLE||' не найдена!');
       END;
     END IF;
  END IF;
  ERoleID := :NEW.EDIT_ROLE_ID;
  IF SP.G.notUpEQ(:NEW.EDIT_ROLE,:OLD.EDIT_ROLE) THEN 
     IF :NEW.EDIT_ROLE IS NULL THEN
       ERoleID := NULL;
     ELSE
       BEGIN
         SELECT ID INTO ERoleID FROM SP.SP_ROLES WHERE NAME = :NEW.EDIT_ROLE;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECTS_iu'||
            'Роль '||:NEW.EDIT_ROLE||' не найдена!');
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
    MODIFIED = :NEW.MODIFIED 
  WHERE ID = :OLD.ID;
END;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECTS_id
INSTEAD OF DELETE ON SP.V_OBJECTS
-- (SP-Catalog-Instead.trg)
BEGIN
  DELETE FROM SP.OBJECTS WHERE ID = :OLD.ID;
END;
/	
--*****************************************************************************
-- 
-- Параметры объектов каталога.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECT_PAR_S_ii
INSTEAD OF INSERT ON SP.V_OBJECT_PAR_S
-- (SP-Catalog-Instead.trg)
DECLARE
  Val SP.TVALUE;
  TypeID NUMBER;
  ObjID NUMBER;
  roID NUMBER;
  new_group_id NUMBER;
BEGIN
  -- Если тип задан в символьном виде, то находим его идентификатор.
  TypeID := :NEW.TYPE_ID;
  IF :NEW.VALUE_TYPE IS NOT NULL THEN
    BEGIN
      SELECT ID INTO TypeID FROM SP.PAR_TYPES 
        WHERE UPPER(:NEW.VALUE_TYPE) = UPPER(NAME);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20033,
        'SP.V_OBJECT_PAR_S_ii. Не найден тип '||:NEW.VALUE_TYPE||'!');
    END;
  END IF;
  IF TypeID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.V_OBJECT_PAR_S_ii. Не задан тип параметра!');
  END IF;   
  -- Если признак "R/O" задан в символьном виде, то находим его идентификатор.
  roID := NVL(:NEW.R_ONLY_ID, 0);
  IF :NEW.R_ONLY IS NOT NULL THEN
    roID:=SP.to_R_ONLY(:NEW.R_ONLY);
  END IF;
  --
  ObjID := :NEW.OBJECT_ID;
--   IF :NEW.OBJECT_NAME IS NOT NULL THEN 
--     BEGIN
--       SELECT ID INTO ObjID FROM sp.objects 
--         WHERE UPPER(NAME) = UPPER(:NEW.OBJECT_NAME);
--     EXCEPTION 
--       WHEN NO_DATA_FOUND THEN
--         RAISE_APPLICATION_ERROR(-20033,
--           'SP.V_OBJECT_PAR_S_ii. Такого объекта нет!');
--     END;
--   END IF;
  IF ObjID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,'SP.V_OBJECT_PAR_S_ii. Не задан объект!');
  END IF; 
  -- Если имя группы задано в виде строки.
  if :NEW.GROUP_NAME is not null then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_OBJECT_PAR_S_ii '||
          ' Группа '||nvl(:NEW.GROUP_NAME, 'null')||' не найдена!');
    end;    
	else
    -- Если задан идентификатор группы.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  -- Если стоит признак обновления,
  -- то изменяем дату изменения объекта на текущую. 
  IF :NEW.MODIFIED > 0 THEN SP.SetObjModified(ObjID); END IF;
  IF :NEW.V IS NOT NULL THEN
    Val:=SP.TValue(TypeID);
    SP.Str_to_Val(:NEW.V,Val);
    UPDATE SP.OBJECT_PAR_S SET
  	  TYPE_ID=typeID,
  	  E_VAL=Val.E,
  	  N=Val.N,
  	  D=Val.D,
  	  S=Val.S,
  	  X=Val.X,
  	  Y=Val.Y,
      GROUP_ID = new_group_id,
  		R_ONLY=roID,
      COMMENTS = :NEW.COMMENTS
	  WHERE ID=ObjID 
      AND UPPER(NAME) = UPPER(:NEW.NAME); 
    IF SQL%NOTFOUND THEN
      INSERT INTO  SP.OBJECT_PAR_S 
            ( NAME, COMMENTS, TYPE_ID, 
      				E_VAL, N, D, S, X, Y, R_ONLY, OBJ_ID, GROUP_ID ) 
      VALUES ( 
  						:NEW.NAME, :NEW.COMMENTS, typeID, Val.E, Val.N,
              Val.D, Val.S, Val.X, Val.Y, roID, ObjID, new_group_id); 
    END IF;
  ELSE
    UPDATE SP.OBJECT_PAR_S SET
  	  TYPE_ID=typeID,
  	  E_VAL=NULL,
  	  N=:NEW.N,
  	  D=:NEW.D,
  	  S=:NEW.S,
  	  X=:NEW.X,
  	  Y=:NEW.Y,
  		R_ONLY=roID,
      COMMENTS = :NEW.COMMENTS,
      GROUP_ID = new_group_id
	  WHERE ID=ObjID 
      AND UPPER(NAME) = UPPER(:NEW.NAME); 
    IF SQL%NOTFOUND THEN
      INSERT INTO  SP.OBJECT_PAR_S 
             ( NAME, COMMENTS, TYPE_ID, 
      				E_VAL, N, D, S, X, Y, R_ONLY, OBJ_ID, GROUP_ID) 
      VALUES ( 
  						:NEW.NAME, :NEW.COMMENTS, typeID, NULL, :NEW.N, 
              :NEW.D, :NEW.S, :NEW.X, :NEW.Y, roID, ObjID, new_group_id); 
    END IF;
  END IF;          
END;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECT_PAR_S_iu
INSTEAD OF UPDATE ON SP.V_OBJECT_PAR_S
-- (SP-Catalog-Instead.trg)
DECLARE
  Val SP.TVALUE;
  TypeID NUMBER;
  roID NUMBER;
  new_group_id NUMBER;
  nvl22 NUMBER;
BEGIN
  -- Если изменено символьное значение типа, то находим его идентификатор.
  TypeID := :NEW.TYPE_ID;
  IF SP.G.notUpEQ(:NEW.VALUE_TYPE,:OLD.VALUE_TYPE) THEN
    BEGIN
      SELECT ID INTO TypeID FROM SP.PAR_TYPES 
        WHERE UPPER(:NEW.VALUE_TYPE) = UPPER(NAME);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20033,
        'SP.V_OBJECT_PAR_S_iu. Не найден тип '||:NEW.VALUE_TYPE||'!');
    END;
  END IF;
  IF TypeID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.V_OBJECT_PAR_S_iu. Тип параметра равен нулл!');
  END IF;   
  -- Если признак "R/O" изменён, то находим его идентификатор.
  roID := :NEW.R_ONLY_ID;
  IF SP.G.notUpEQ(:NEW.R_ONLY,:OLD.R_ONLY) THEN
    roID:=SP.to_R_ONLY(:NEW.R_ONLY);
  END IF;
  -- Если строковое значение не нулл, то присваиваем его.
	IF SP.G.notUpEQ(:NEW.V,:OLD.V) THEN
    Val:=SP.TVALUE(TypeID, :NEW.V);
  ELSE
    nvl22 := case when :NEW.D is null then 1 else 0 end;
    Val:=SP.TVALUE(TypeID,
                  :NEW.N, :NEW.D, nvl22,:NEW.S, :NEW.X, :NEW.Y);
  END IF;  
  -- Если имя группы задано в виде строки.
  if :NEW.GROUP_NAME is not null then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_OBJECT_PAR_S_iu '||
          ' Группа '||nvl(:NEW.GROUP_NAME, 'null')||' не найдена!');
    end;    
	else
    -- Если задан идентификатор группы.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  -- Если стоит признак обновления,
  -- то изменяем дату изменения объекта на текущую. 
  IF :NEW.MODIFIED > 0 THEN SP.SetObjModified(:OLD.OBJECT_ID); END IF;
  UPDATE SP.OBJECT_PAR_S SET
	  TYPE_ID=Val.T,
	  E_VAL=Val.E,
	  N=Val.N,
	  D=Val.D,
	  S=Val.S,
	  X=Val.X,
	  Y=Val.Y,
		R_ONLY=roID,
    NAME = :NEW.NAME, 
    COMMENTS = :NEW.COMMENTS,
    GROUP_ID = new_group_id
	WHERE
	  ID=:OLD.ID;
END;
/
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_OBJECT_PAR_S_id
INSTEAD OF DELETE ON SP.V_OBJECT_PAR_S
-- (SP-Catalog-Instead.trg)
BEGIN
 -- Сначала удаляем все параметры у параметров объектов моделей.
 DELETE FROM SP.MODEL_OBJECT_PAR_S WHERE OBJ_PAR_ID = :OLD.ID;
 DELETE FROM SP.OBJECT_PAR_S WHERE ID = :OLD.ID;
END;
/	

-- end of File 
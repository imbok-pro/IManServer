-- тригеры для Macros view 
-- by Irina Gracheva
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 13.10.2010 17.11.2010 24.11.2010 09.12.2010 20.12.2010 11.02.2011
-- by Nikolay Krasilnikov 
--        19.01.2012 16.03.2012 11.10.2013 24.02.2014 14.06.2014 28.11.2014
--        06.01.2015-07.01.2015  
--*****************************************************************************
-- 
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MACROS_ii
INSTEAD OF INSERT ON SP.V_MACROS
-- (SP-Catalog-Macros-Instead.trg)
DECLARE
  tmpVar NUMBER;
  ObjID NUMBER;
  UObjID NUMBER;
  CmdID NUMBER;
  NewID NUMBER;
  PrevID NUMBER;
  OLD_REFERANCER NUMBER;
  MDATE DATE;
  MUSER VARCHAR2(60);
  pos NUMBER;
  NewName SP.OBJECTS.NAME%type;
  NewGroup SP.GROUPS.NAME%type;
BEGIN
  ObjID:=:NEW.OBJECT_ID;
  -- Если определено новое полное имя объекта, 
  -- то используем его для нахождения идентификатора объекта.
	IF :NEW.OBJECT_FULL_NAME IS NOT NULL THEN
    -- Находим позицию последней точки.
    pos:=instr(:NEW.OBJECT_FULL_NAME,'.',-1);
    -- Находим короткое имя.
    NewName:=substr(:NEW.OBJECT_FULL_NAME,pos+1);
    -- Находим полное имя.
    NewGroup:=substr(:NEW.OBJECT_FULL_NAME,1,pos-1);
    --d('NewGroup=>'||NewGroup||'  NewName=>'||NewName,'SP.V_MACROS_II');
    begin
      select o.ID into ObjID from SP.OBJECTS o, SP.GROUPS g
	      where o.GROUP_ID = g.ID
          and upper(o.NAME) = upper(NewName)
          and upper(g.NAME) = upper(NewGroup);
    exception
        when NO_DATA_FOUND then
    	    d('Имя объекта задано не корректно: '||
            nvl(:NEW.OBJECT_FULL_NAME,'null')||' !',
            'ERROR SP.V_MACROS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
            'Имя объекта задано не корректно: '||
            nvl(:NEW.OBJECT_FULL_NAME,'null')||' !');
    end;          
  ELSE
	  -- Если определено новое короткое имя объекта, то находим идентификатор,
	  -- иначе используем значение идентификатора нового объекта.
	  IF :NEW.OBJECT_SHORT_NAME IS NOT NULL THEN
	    begin
	      if :NEW.OBJECT_GROUP_NAME is null then
	        select ID into ObjID from SP.OBJECTS
	          where upper(NAME) = upper(:NEW.OBJECT_SHORT_NAME);
	      else
	        select o.ID into ObjID from SP.OBJECTS o, SP.GROUPS g
	          where o.GROUP_ID = g.ID
              and upper(o.NAME) = upper(:NEW.OBJECT_SHORT_NAME)
	            and upper(g.NAME) = upper(:NEW.OBJECT_GROUP_NAME);
	      end if;    
	    exception
	        when NO_DATA_FOUND then
	    	    d('Имя объекта задано не корректно: '||
	            nvl(:NEW.OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.OBJECT_SHORT_NAME,'null')||
	            ' !','ERROR SP.V_MACROS_ii');
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
	            'Имя объекта задано не корректно: '||
	            nvl(:NEW.OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.OBJECT_SHORT_NAME,'null')||' !');
	        when too_many_rows then
	    	    d('Имя объекта задано не однозначно: '||
	            nvl(:NEW.OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.OBJECT_SHORT_NAME,'null')||
	            ' !','ERROR SP.V_MACROS_ii');
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
	            'Имя объекта задано не однозначно: '||
	            nvl(:NEW.OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.OBJECT_SHORT_NAME,'null')||' !');
	    end;
	  END IF;
  END IF;  
  -- Если стоит признак обновления,
  -- то изменяем дату изменения объекта на текущую. 
  IF :NEW.MODIFIED > 0 THEN 
    SP.SetObjModified(ObjID);
    MDATE :=null;
    MUSER:= null;
  ELSE
    -- Макрокоманда получит дату изменения и пользователя как у объекта.
    select MODIFIED , M_USER into MDATE, MUSER from SP.OBJECTS
      where ID=ObjID;   
  END IF;
  UObjID:=:NEW.USED_OBJECT_ID;
  -- Если определено новое полное имя используемого объекта, 
  -- то используем его для нахождения идентификатора используемого объекта.
	IF :NEW.USED_OBJECT_FULL_NAME IS NOT NULL THEN
    -- Находим позицию последней точки.
    pos:=instr(:NEW.USED_OBJECT_FULL_NAME,'.',-1);
    -- Находим короткое имя.
    NewName:=substr(:NEW.USED_OBJECT_FULL_NAME,pos+1);
    -- Находим полное имя.
    NewGroup:=substr(:NEW.USED_OBJECT_FULL_NAME,1,pos-1);
    begin
      select o.ID into UObjID from SP.OBJECTS o, SP.GROUPS g
	      where o.GROUP_ID = g.ID
          and upper(o.NAME) = upper(NewName)
          and upper(g.NAME) = upper(NewGroup);
    exception
        when NO_DATA_FOUND then
    	    d('Имя используемого объекта задано не корректно: '||
            nvl(:NEW.USED_OBJECT_FULL_NAME,'null')||' !',
            'ERROR SP.V_MACROS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
            'Имя используемого объекта задано не корректно: '||
            nvl(:NEW.USED_OBJECT_FULL_NAME,'null')||' !');
    end;          
  ELSE
	  -- Если определено новое короткое имя используемого объекта,
    -- то находим идентификатор,
	  -- иначе используем значение идентификатора нового используемого объекта.
	  IF :NEW.USED_OBJECT_SHORT_NAME IS NOT NULL THEN
	    begin
	      if :NEW.USED_OBJECT_GROUP_NAME is null then
	        select ID into UObjID from SP.OBJECTS
	          where upper(NAME) = upper(:NEW.USED_OBJECT_SHORT_NAME);
	      else
	        select o.ID into UObjID from SP.OBJECTS o, SP.GROUPS g
	          where upper(o.NAME) = upper(:NEW.USED_OBJECT_SHORT_NAME)
	            and upper(g.NAME) = upper(:NEW.USED_OBJECT_GROUP_NAME);
	      end if;    
	    exception
	        when NO_DATA_FOUND then
	    	    d('Имя используемого объекта задано не корректно: '||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||':'||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||
	            ' !','ERROR SP.V_MACROS_ii');
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
	            'Имя используемого объекта задано не корректно: '||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||':'||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||' !');
	        when too_many_rows then
	    	    d('Имя используемого объекта задано не однозначно: '||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||':'||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||
	            ' !','ERROR SP.V_MACROS_ii');
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
	            'Имя используемого объекта задано не однозначно: '||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||':'||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||' !');
	    end;
	  END IF;
  END IF;  
  -- Если определено новое имя макрокоманды, то находим идентификатор,
  -- иначе используем значение идентификатора макрокоманды.
  CmdID:=:NEW.CMD_ID;
  IF :NEW.CMD_NAME IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CmdID FROM SP.COMMANDS
        WHERE UPPER(NAME)=UPPER(:NEW.CMD_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii. '||
          'Команда '||:NEW.CMD_NAME||' не найдена!');
    END;
  END IF;
  -- Вставляем новую строку всегда в конец.
  INSERT INTO SP.MACROS (
    OBJ_ID, ALIAS, COMMENTS,
    CMD_ID, USED_OBJ_ID, MACRO, CONDITION, M_DATE, M_USER)
  VALUES (
	  ObjID, :NEW.ALIAS, :NEW.COMMENTS,
    CmdID, UObjID, :NEW.MACRO, :NEW.CONDITION, MDATE, MUSER)
  RETURNING ID, PREV_ID INTO NewID, tmpVar;
  -- Если номер строки не задан, то выход.
  IF :NEW.LINE IS NULL THEN RETURN; END IF;
  -- Если новый номер строки равен "1", то "PrevID"- нулл,
  IF :NEW.LINE = 1 THEN
    PrevID:=NULL;
  ELSE
	  -- иначе находим ссылку на предыдущую строку.
	  BEGIN
	    SELECT ID INTO PrevID FROM SP.V_MACROS
	      WHERE OBJECT_ID=ObjID AND LINE=:NEW.LINE-1;
	  EXCEPTION
	    -- Если такой строки нет, то вставили в конец и порядок.
	    -- Новый номер строки был больше наибольшего существующего.
	    WHEN NO_DATA_FOUND THEN RETURN;
	  END;
  END IF;
  -- Находим идентификатор строки, ссылку которой нужно переправить на
  -- идентификатор текущей строки.
  BEGIN
    SELECT ID INTO OLD_REFERANCER FROM SP.MACROS 
    	WHERE PREV_ID = PrevID;
  EXCEPTION
    -- Если такой строки нет, то вставили в конец и порядок.
    -- Новый номер строки был больше наибольшего существующего.
    WHEN NO_DATA_FOUND THEN 
      -- !! переместить до select
      IF PrevID IS NULL THEN
        BEGIN
          SELECT ID INTO OLD_REFERANCER FROM SP.MACROS 
            WHERE OBJ_ID = ObjID AND PREV_ID IS NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN 
             RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii. '||
          			'Ошибка алгоритма!');
        END;  
      ELSE
        RETURN;
      END IF;
  END;
  -- Исправляем ссылки.
  UPDATE SP.MACROS
    SET PREV_ID = CASE ID
                    WHEN NewID THEN PrevID
                    WHEN OLD_REFERANCER THEN NewID
                  END
    WHERE ID IN (NewID, OLD_REFERANCER);
END;
/
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MACROS_iu
INSTEAD OF UPDATE ON SP.V_MACROS
-- (SP-Catalog-Macros-Instead.trg)
DECLARE
  CmdID NUMBER;
  UObjID NUMBER;
  PrevID NUMBER;
  OLD_REFERANCER NUMBER;
  BACK_REFERANCER NUMBER;
  maxLine NUMBER;
  MDATE DATE;
  MUSER VARCHAR2(60);
  pos NUMBER;
  NewName SP.OBJECTS.NAME%type;
  NewGroup SP.GROUPS.NAME%type;
BEGIN
  -- Изменение принадлежности к объекту запрещено в табличном триггере.
  -- Если задано строковое значение имени команды, то находим идентификатор.
  CmdID := :NEW.CMD_ID;
  IF SP.G.notUpEQ(:NEW.CMD_NAME,:OLD.CMD_NAME) THEN
    BEGIN
      SELECT ID INTO CmdID FROM sp.commands WHERE NAME = :NEW.CMD_NAME;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_iu. '||
        'Команда '||:NEW.CMD_NAME||' не найдена!');
    END;
  END IF;
  UObjID := :NEW.USED_OBJECT_ID;
  -- Если изменено полное используемого имя объекта, 
  -- то используем его для нахождения идентификатора используемого объекта.
	IF SP.G.notUpEQ(:NEW.USED_OBJECT_FULL_NAME, :OLD.USED_OBJECT_FULL_NAME) THEN
    -- Находим позицию последней точки.
    pos:=instr(:NEW.USED_OBJECT_FULL_NAME,'.',-1);
    -- Находим короткое имя.
    NewName:=substr(:NEW.USED_OBJECT_FULL_NAME,pos+1);
    -- Находим полное имя.
    NewGroup:=substr(:NEW.USED_OBJECT_FULL_NAME,1,pos-1);
    begin
      select o.ID into UObjID from SP.OBJECTS o, SP.GROUPS g
	      where o.GROUP_ID = g.ID
          and upper(o.NAME) = upper(NewName)
          and upper(g.NAME) = upper(NewGroup);
    exception
        when NO_DATA_FOUND then
    	    d('Имя используемого объекта задано не корректно: '||
            nvl(:NEW.USED_OBJECT_FULL_NAME,'null')||' !',
            'ERROR SP.V_MACROS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_ii'||
            'Имя используемого объекта задано не корректно: '||
            nvl(:NEW.USED_OBJECT_FULL_NAME,'null')||' !');
    end;          
  ELSE
	  -- Если изменено короткое имя используемого объекта,
	  -- то находим идентификатор.
	  IF  SP.G.notUpEQ(:NEW.USED_OBJECT_SHORT_NAME,:OLD.USED_OBJECT_SHORT_NAME) 
	   or SP.G.notUpEQ(:NEW.USED_OBJECT_GROUP_NAME,:OLD.USED_OBJECT_GROUP_NAME) 
	  THEN
	    begin
	      select o.ID into UObjID from SP.OBJECTS o, SP.GROUPS g
	        where upper(o.NAME) = upper(:NEW.USED_OBJECT_SHORT_NAME)
	          and upper(g.NAME) = upper(:NEW.USED_OBJECT_GROUP_NAME);
	    exception
	        when NO_DATA_FOUND then
	    	    d('Имя используемого объекта задано не корректно: '||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||
	            ' !','ERROR SP.V_MACROS_iu');
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_iu'||
	            'Имя используемого объекта задано не корректно: '||
	            nvl(:NEW.USED_OBJECT_GROUP_NAME,'null')||'.'||
	            nvl(:NEW.USED_OBJECT_SHORT_NAME,'null')||' !');
	    end;
	  END IF;
  END IF;  
  -- Если стоит признак обновления,
  -- то изменяем дату изменения объекта на текущую. 
  IF :NEW.MODIFIED > 0 THEN 
    SP.SetObjModified(:OLD.OBJECT_ID);
    MDATE :=null;
    MUSER:= null;
  ELSE
    -- Макрокоманда получит дату изменения и пользователя как у объекта.
    select MODIFIED , M_USER into MDATE, MUSER from SP.OBJECTS
      where ID=:OLD.OBJECT_ID;   
  END IF;
  -- Обновляем всё кроме изменения номера строки.
  UPDATE  SP.MACROS
    SET ALIAS =       :NEW.ALIAS,
        COMMENTS =    :NEW.COMMENTS,
   			CMD_ID =      CmdID,
        USED_OBJ_ID = UObjID,
        MACRO =       :NEW.MACRO,
        CONDITION =   :NEW.CONDITION,
        M_DATE = MDATE,
        M_USER = MUSER
    WHERE ID = :OLD.ID;
  -- Если не изменён номер строки, то выход.
  IF (:NEW.LINE=:OLD.LINE) OR (:NEW.LINE IS NULL) THEN RETURN; END IF;
  -- Если новая строка равна "1", то идентификатор ссылки равен нулл,
  IF :NEW.LINE <= 1 THEN
    PrevID:=NULL;
  ELSE
    -- иначе находим идентификатор строки для новой ссылки текущей строки.
    IF :NEW.LINE > :OLD.LINE THEN
	    BEGIN
	      SELECT ID INTO PrevID FROM SP.V_MACROS
	        WHERE OBJECT_ID=:OLD.OBJECT_ID AND LINE=:NEW.LINE;
	    EXCEPTION
	      -- Если такой строки нет, то макрокоманда переносится в конец
        -- макропроцедуры.
	      -- Новый номер строки был больше наибольшего существующего.
	      WHEN NO_DATA_FOUND THEN
          BEGIN 
	          SELECT MAX(LINE) INTO maxLine FROM SP.V_MACROS
	            WHERE OBJECT_ID=:OLD.OBJECT_ID;
	          SELECT ID INTO PrevID FROM SP.V_MACROS
	            WHERE OBJECT_ID=:OLD.OBJECT_ID AND LINE=maxLine;
		      EXCEPTION
		        -- Если такой строки нет, то ошибка алгоритма.
		        WHEN NO_DATA_FOUND THEN
		          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_iu. '||
		            'Ошибка алгоритма 1 !');
		      END;
	    END;
    ELSE    
	    BEGIN
	      SELECT ID INTO PrevID FROM SP.V_MACROS
	        WHERE OBJECT_ID=:OLD.OBJECT_ID AND LINE=:NEW.LINE-1;
      EXCEPTION
        -- Если такой строки нет, то ошибка алгоритма.
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MACROS_iu. '||
            'Ошибка алгоритма 2 !');
      END;
    END IF;    
  END IF;
  -- Если он равен текущему или последняя строка должна стать последней,
  -- то выход.
  IF G.EQ(PrevID, :OLD.PREV_ID) OR G.EQ(PrevID, :OLD.ID)  THEN RETURN; END IF;
  -- Находим идентификатор старой строки, уже ссылающуюся на строку,
  -- идентификатор которой мы хотим использовать для новой ссылки.
  BEGIN
    SELECT ID INTO OLD_REFERANCER FROM SP.MACROS 
      WHERE G.S_EQ(PREV_ID,PrevID)=1
        AND (OBJ_ID=:OLD.OBJECT_ID);
  EXCEPTION
    -- Если такой строки нет, то происходит перенос строки в конец листинга.
    WHEN NO_DATA_FOUND THEN OLD_REFERANCER:=NULL;
  END;
  -- Исправляем ссылки.
  -- BACK_REFERANCER - строка, которая ссылалась на текущую строку до начала
  -- операции, а теперь должна ссылка ссылаться :OLD.PREV_ID.
  BEGIN
    SELECT ID INTO BACK_REFERANCER FROM SP.MACROS 
      WHERE G.S_EQ(PREV_ID,:OLD.ID)=1 
        AND (OBJ_ID=:OLD.OBJECT_ID);
  EXCEPTION
    -- Если такой строки нет, то текущая строка была последней.
    WHEN NO_DATA_FOUND THEN
      BACK_REFERANCER := NULL;
  END;
  CASE
    -- Игнорируем перенос последней строки в конец.
    WHEN (OLD_REFERANCER  IS NULL) AND (BACK_REFERANCER  IS NULL) THEN RETURN;    
    -- Текущая строка была последней.
    WHEN BACK_REFERANCER  IS NULL THEN
	    UPDATE SP.MACROS
	      SET PREV_ID = CASE ID
	                      WHEN :OLD.ID THEN PrevID
	                      WHEN OLD_REFERANCER THEN :OLD.ID
	                    END
	      WHERE ID IN (:OLD.ID, OLD_REFERANCER);
    -- Строка переносится в конец.
    WHEN OLD_REFERANCER  IS NULL THEN
	    UPDATE SP.MACROS
	      SET PREV_ID = CASE ID
	                      WHEN :OLD.ID THEN PrevID
	                      WHEN BACK_REFERANCER THEN :OLD.PREV_ID
	                    END
	      WHERE ID IN (:OLD.ID, BACK_REFERANCER);
  ELSE
    UPDATE SP.MACROS
      SET PREV_ID = CASE ID
                      WHEN :OLD.ID THEN PrevID
                      WHEN OLD_REFERANCER THEN :OLD.ID
                      WHEN BACK_REFERANCER THEN :OLD.PREV_ID
                    END
      WHERE ID IN (:OLD.ID, OLD_REFERANCER, BACK_REFERANCER);
  END CASE;  
END;
/
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MACROS_id
INSTEAD OF DELETE ON SP.V_MACROS
-- (SP-Catalog-Macros-Instead.trg)
DECLARE
  tmpVar NUMBER;
  MaxRowID NUMBER;
  OldPrevID NUMBER;
BEGIN
  -- Находим число строк в макропроцедуре.
  SELECT COUNT(*) INTO tmpVar FROM SP.MACROS  
    WHERE OBJ_ID = :OLD.OBJECT_ID;
  --d('line count = '||tmpVar,'V_MACROS_id');
  -- Находим идентификатор последней строки.  
  SELECT ID INTO MaxRowID FROM SP.V_MACROS 
	  WHERE line = tmpVar AND OBJECT_ID = :OLD.OBJECT_ID;
  --d('MaxRowID = '||MaxRowID,'V_MACROS_id');
  -- Находим строку, ссылающуюся на удаляемую.
  BEGIN
    SELECT ID INTO tmpVar FROM SP.MACROS WHERE PREV_ID=:OLD.ID;
  --d('next_ID = '||tmpVar,'V_MACROS_id');
  EXCEPTION
    -- Если такой строки нет, то наша строка последняя.
    -- Удаляем строку и покидаем тригер.
    WHEN NO_DATA_FOUND THEN
      DELETE FROM SP.MACROS WHERE ID = :OLD.ID;
      RETURN;
  END;
  -- Если строка существует,
  -- то у удаляемой строки изменяем ссылку, указывающую на предыдущюю строку
  -- на свой идентификатор (чтобы не нарушить целосттность ограничений),
  -- а у ссылающейся строки изменяем ссылку, указывающую на предыдущюю строку,
  -- равную ссылке, которая была у удаляемой строки.
  --d(':OLD.ID = '||:OLD.ID,'V_MACROS_id');
  --d(':OLD.PREV_ID = '||:OLD.PREV_ID,'V_MACROS_id');
  -- При удалении нескольких строк может возникнуть ситуация,
  -- когда поле :OLD.PREV_ID уже не актуально, 
  -- поскольку могло быть изменено при предыдущих срабатываниях этого тригера.
  SELECT PREV_ID INTO OldPrevID FROM SP.MACROS WHERE ID = :OLD.ID;
  UPDATE SP.MACROS
    SET PREV_ID = CASE ID
                    WHEN :OLD.ID THEN MaxRowID
                    WHEN tmpVar THEN OldPrevID
                  END
    WHERE ID IN (:OLD.ID, tmpVar);
--   for i in(select * from SP.MACROS where ID in(:OLD.ID, tmpVar))
--   loop
--     d('ID = '||i.ID||' PREV_ID = '||i.PREV_ID,'V_MACROS_id');
--   end loop;  
  -- Удаляем строку и покидаем тригер.
  DELETE FROM SP.MACROS  WHERE ID = :OLD.ID;
END;
/

-- end of File 
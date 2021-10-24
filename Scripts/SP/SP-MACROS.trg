-- SP MACROS tables triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010
-- update 02.09.2010 15.10.2010 01.11.2010 24.11.2010 07.12.2010 14.12.2010
-- 				13.01.2010 07.02.2011 10.03.2011 01.11.2011 16.03.2012 03.04.2013
--        27.05.2013 25.08.2013 27.09.2013 30.09.2013 25.04.2014 14.06.2014
--        03.07.2014 04.11.2014 03.01.2015 06.01.2015 31.03.2015 20.08.2015
--        19.02.2016 22.02.2016 05.07.2016 10.05.2017 02.11.2017 11.04.2021
--*****************************************************************************

--SP.COMMANDS
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.COMMANDS_bir
BEFORE INSERT ON SP.COMMANDS 
FOR EACH ROW
--(SP-MACROS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
	SP.TG.ResetFlags;
	RAISE_APPLICATION_ERROR(-20033,'SP.COMMANDS_bir. TABLE BLOCKED!');
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.COMMANDS_bur
BEFORE UPDATE ON SP.COMMANDS 
FOR EACH ROW
--(SP-MACROS.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SP.TG.ResetFlags;
	RAISE_APPLICATION_ERROR(-20033,'SP.COMMANDS_bur. TABLE BLOCKED!');
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.COMMANDS_bdr
BEFORE DELETE ON SP.COMMANDS 
FOR EACH ROW
--(SP-MACROS.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
	SP.TG.ResetFlags;
	RAISE_APPLICATION_ERROR(-20033,'SP.COMMANDS_bdr TABLE BLOCKED!');
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------


--SP.WORK_COMMAND_PAR_S
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
--
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.WORK_COMMAND_PAR_S_bur
BEFORE UPDATE ON SP.WORK_COMMAND_PAR_S 
FOR EACH ROW
--(SP-MACROS.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.R_ONLY = 1 THEN
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.WORK_COMMAND_PAR_S_bur. Параметр '||:OLD.NAME
      ||' только для чтения!');
  END IF; 
  -- Устанавливаем признак обновления параметра.   
  IF :OLD.R_ONLY = -1 THEN
    :NEW.MODIFIED := 1;
  END IF;    
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
--
--AFTER_DELETE_TABLE-----------------------------------------------------------

--SP.M_LOG
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.M_LOG_bir
BEFORE INSERT ON SP.M_LOG
FOR EACH ROW
--(SP-MACROS.trg)
DECLARE
  tmpVar PLS_INTEGER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  select max(line) into tmpVar from SP.M_LOG where ThID = :NEW.ThID;
  :NEW.LINE := nvl(tmpVar, 0) + 1;
END;
/
--
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
--
--AFTER_DELETE_TABLE-----------------------------------------------------------

--SP.M_ERRORS_AND_WARNINGS
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.M_ERRORS_AND_WARNINGS_bir
BEFORE INSERT ON SP.M_ERRORS_AND_WARNINGS
FOR EACH ROW
--(SP-MACROS.trg)
DECLARE
  tmpVar PLS_INTEGER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  select max(line) into tmpVar from SP.M_ERRORS_AND_WARNINGS
    where ThID = :NEW.ThID;
  :NEW.LINE := nvl(tmpVar, 0) + 1;
END;
/
--
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE----------------------------------------------------------------
--
--AFTER_DELETE_TABLE-----------------------------------------------------------

-- SP.MACROS
-------------------------------------------------------------------------------
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
CREATE OR REPLACE TRIGGER SP.INSERTED_MACROS_bi
BEFORE INSERT ON SP.INSERTED_MACROS
--(SP-MACROS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.INSERTED_MACROS;
  IF tmpVar=0 AND SP.TG.AfterInsertMacros THEN 
    SP.TG.AfterInsertMacros:= FALSE;
    d('SP.TG.AfterInsertMacros:= false;','ERROR INSERTED_MACROS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.UPDATED_MACROS_bi
BEFORE INSERT ON SP.UPDATED_MACROS
--(SP-MACROS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.UPDATED_MACROS;
  IF tmpVar=0 AND SP.TG.AfterUpdateMacros THEN 
    SP.TG.AfterUpdateMacros:= FALSE;
    d('SP.TG.AfterUpdateMacros:= false;','ERROR UPDATED_MACROS_bi');
  END IF;
END;
/
--
CREATE OR REPLACE TRIGGER SP.DELETED_MACROS_bi
BEFORE INSERT ON SP.DELETED_MACROS
--(SP-MACROS.trg)
DECLARE
  tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM SP.DELETED_MACROS;
  IF tmpVar=0 AND SP.TG.AfterDeleteMacros THEN 
    SP.TG.AfterDeleteMacros:= FALSE;
    d('SP.TG.AfterDeleteMacros:= false;','ERROR DELETED_MACROS_bi');
  END IF;
END;
/
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_bir
BEFORE INSERT ON SP.MACROS 
FOR EACH ROW
--(SP-MACROS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  SELECT SP.MACRO_SEQ.NEXTVAL INTO tmpVar FROM DUAL;
  :NEW.ID := tmpVar+REPLICATION.NODE_ID;
  IF :NEW.PREV_ID IS NULL THEN
    -- Если у команды ссылка на предыдущую команду отсутствует,
    -- то вставляем команду в конец, присваивая
    -- ей ссылку на последнюю команду.
    BEGIN
	    SELECT ID INTO :NEW.PREV_ID FROM SP.MACROS 
           WHERE OBJ_ID=:NEW.OBJ_ID
             AND CONNECT_BY_ISLEAF=1
	         START WITH PREV_ID IS NULL
	         CONNECT BY PREV_ID = PRIOR ID;
    EXCEPTION
      -- Если ничего не нашли - значит это первая строка макрокоманды.
      WHEN NO_DATA_FOUND THEN NULL;
    END; 
  ELSE   
	  -- Проверяем, что предыдущая строка принадлежит тому же объекту что и 
    -- добавляемая.
    SELECT OBJ_ID INTO tmpVar FROM SP.MACROS 
        WHERE ID = :NEW.PREV_ID;
    IF tmpVar != :NEW.OBJ_ID THEN
		  SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_bir.'||
        ' Ссылка на предыдущую строку, принадлежащую другому объекту!');
    END IF;    
  END IF;
  -- UsedObject может присутствовать только в командах создания объектов или
  -- выполнения команд.
  IF :NEW.CMD_ID NOT IN (
						  SP.G.Cmd_FOR_PARS_IN,
  	 			 	 	SP.G.Cmd_CREATE_OBJECT, 
						  SP.G.Cmd_EXECUTE,
              SP.G.Cmd_FOR_SYSTEMS,
						  SP.G.Cmd_FOR_OBJECTS,
						  SP.G.Cmd_FOR_SELECTED
											  ) 
  THEN
    :NEW.USED_OBJ_ID:= NULL;
  END IF;
  -- Инициируем ошибку, если ссылка на предыдущую строку ссылается на себя.
  IF :NEW.ID=:NEW.PREV_ID THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_bir. Ссылка на себя!');
  END IF;
  -- Инициируем ошибку, если длинна макроблока, с учётом удвоения при экспорте
  -- содержащихся в нём кавычек, превзойдёт 4000.
  IF length(Q_QQ(:NEW.MACRO)) >=4000 THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_bir. Превышен размер блока!');
  END IF;
  -- Если не задана дата изменения или пользователь, то добавляем текущие.
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- Устанавливаем признак изменения у не имеющих родителей композитных 
  -- объектов, которые были созданы сами при помощи этой последовательности
  -- макрокоманд или данная последовательность была использована при создании
  -- их потомков.
  -- !!! Если необходимо, то удаляем пакет, содержащий скомпилированную макру.
  -- Редактировать имет право администратор.
  -- Если роль редактирования объекта не нулл, то редактировать объект
  -- может пользователь, имеющий роль редактирования объекта.
  -- Проверяем соответствие команды и типа используемого ею объекта.
  INSERT INTO SP.INSERTED_MACROS 
    VALUES(:NEW.ID, :NEW.OBJ_ID, :NEW.ALIAS, :NEW.COMMENTS,
           :NEW.PREV_ID, :NEW.CMD_ID,
           :NEW.USED_OBJ_ID, :NEW.MACRO, :NEW.CONDITION,
           :NEW.M_DATE,:NEW.M_USER);
EXCEPTION 
  WHEN OTHERS THEN 
	  SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_bir. '||SQLERRM||'!');
END;
/
--AFTER_INSERT_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_ai
AFTER INSERT ON SP.MACROS
--(SP-MACROS.trg)
DECLARE
	rec SP.INSERTED_MACROS%ROWTYPE;
  ObjName SP.OBJECTS.NAME%TYPE;
  EditRole NUMBER;
  tmpVar NUMBER;
  err BOOLEAN;
  BlockTemplate SP.COMMANDS.COMMENTS%type;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterInsertMacros 
  THEN 
    --d('table тригер => return ','MACROS_ai');
    RETURN; 
  END IF;
  SP.TG.AfterInsertMacros:= TRUE;
  --d('table тригер','MACROS_ai');
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.INSERTED_MACROS WHERE ROWNUM=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
    -- Если шаблон команды и поле :New.Macro не нуллы оба,
    -- то добавляем шаблон в поле MACRO.
    IF rec.NEW_MACRO IS NULL THEN
      BlockTemplate:=SP.Macro_Template(rec.NEW_CMD_ID,rec.NEW_USED_OBJ_ID);
      --d('BlockTemplate '||BlockTemplate,'MACROS_ai');
      IF BlockTemplate IS NOT NULL THEN
        UPDATE SP.MACROS SET MACRO=BlockTemplate WHERE ID=rec.NEW_ID;
      END IF;
    END IF;
    SELECT NAME, EDIT_ROLE INTO ObjName, EditRole 
      FROM SP.OBJECTS
		  WHERE ID=rec.NEW_OBJ_ID;
	  -- Редактировать макропоследовательность композитного объекта имет право
    -- администратор.
	  -- Если роль редактирования объекта не нулл, то редактировать объект
	  -- может пользователь, имеющий роль редактирования объекта.
		IF NOT SP.HasUserEditRoleID(EditRole) THEN		
			SP.TG.ResetFlags;	  
      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_ai.'||
        ' Недостаточно привелегий для изменения объекта: '||ObjName||'!');
    END IF;
    -- Проверяем подходит ли тип используемого объета для данной команды.						  
    IF rec.NEW_USED_OBJ_ID is not null THEN
	    SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS 
	      WHERE ID = rec.NEW_USED_OBJ_ID;
      --d('rec.NEW_USED_OBJ_ID '||rec.NEW_USED_OBJ_ID,'MACROS_ai');
      --d('tmpVar '||tmpVar,'MACROS_ai');
	    err:=false;  
	    IF rec.NEW_CMD_ID=G.Cmd_Create_Object THEN
	      if tmpVar in (SP.G.MACRO_OBJ, SP.G.OPERATION_OBJ) then 
          err:=true; 
        end if;
	    END IF;      
	    IF rec.NEW_CMD_ID in(G.Cmd_Execute, G.Cmd_For_Selected,
	                         G.Cmd_For_Systems,   G.Cmd_For_Objects)
	    THEN
	      if tmpVar not in (SP.G.MACRO_OBJ, SP.G.OPERATION_OBJ) then 
          err:=true; 
        end if;
	    END IF;
	    IF err THEN 
        d(' Тип используемого объекта '||nvl(to_char(tmpVar),'null')||
          'не совместим с командой '||nvl(to_char(rec.New_CMD_ID),'null')||
          '!(Object)'||ObjName,
          'ERROR in Macros_ai');          
	      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_ai.'||
	        ' Тип используемого объекта не совместим с командой!');
	    END IF; 
    END IF;      
    -- Удаляем обработанную запись.
    DELETE FROM SP.INSERTED_MACROS WHERE NEW_ID=rec.NEW_ID;  
	END LOOP;
  SP.TG.AfterInsertMacros := FALSE;
END;
/
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_bur
BEFORE UPDATE ON SP.MACROS 
FOR EACH ROW
--(SP-MACROS.trg)
BEGIN
  IF ReplSession THEN RETURN; END IF;
  :NEW.ID:=:OLD.ID;
  :NEW.OBJ_ID:=:OLD.OBJ_ID;
  -- UsedObject может присутствовать только в командах CreateObject или
  -- ExecuteMacro.
  IF :NEW.CMD_ID NOT IN (
						  SP.G.Cmd_FOR_PARS_IN,
  	 			 	 	SP.G.Cmd_CREATE_OBJECT, 
						  SP.G.Cmd_EXECUTE,
              SP.G.Cmd_FOR_SYSTEMS,
              SP.G.Cmd_For_Selected,
						  SP.G.Cmd_FOR_OBJECTS
											  ) 
  THEN
    :NEW.USED_OBJ_ID:= NULL;
  END IF;
  /*
Cmd_DECLARE CONSTANT NUMBER:=15;
Cmd_FOR_SYSTEMS CONSTANT NUMBER:=16;
Cmd_FOR_OBJECTS  */
  --d(to_char(:NEW.OBJ_ID),'MACROS_bur');
	-- Нельзя удалить объект, если он используется в макрокомандах других
  -- объектов каталога.
  -- И данном случае, срабатывание данного триггера обусловлено обнулением
  -- ссылки на используемый объект в командах создания или выполнения.
  IF SP.TG.ObjectParDeleting THEN 
		  SP.TG.ResetFlags;	  
	    RAISE_APPLICATION_ERROR(-20033, 'SP.MACROS_bur  '||
	    'Нельзя удалить объект '||SP.TG.DeletingObject||
      ', используемый в марокомандах других объектов каталога.');
	END IF;
  -- Инициируем ошибку, если длинна макроблока, с учётом удвоения при экспорте
  -- содержащихся в нём кавычек, превзойдёт 4000.
  IF length(Q_QQ(:NEW.MACRO)) >=4000 THEN
    SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_bur. Превышен размер блока!');
  END IF;
  IF :NEW.M_DATE is null THEN :NEW.M_DATE := sysdate; END IF; 
  IF :NEW.M_USER is null THEN :NEW.M_USER := TG.UserName; END IF; 
  -- В табличном триггере выполняем следующее.
  -- При изменении порядка выполнения, команды, макроопределения или условия
  -- устанавливаем признак изменения у не имеющих родителей композитных 
	-- объектов, которые были созданы сами при помощи этой последовательности
	-- макрокоманд или данная последовательность была использована при создании
	-- их потомков.
  -- Если поле MACRO установлено в нулл, то вставляем шаблон,
  -- если он предусмотрен.
  -- Проверяем соответствие команды и типа используемого ею объекта.
  -- Проверяем, что только администратор или пользователь,
  -- имеющий права редактирования композитного объекта, создаваевомого данной
  -- последовательностью макрокоманд имеет право изменять макроопределение.
  -- !!! Если необходимо, то удаляем пакет, содержащий скомпилированную макру.
  INSERT INTO SP.UPDATED_MACROS 
    VALUES(:NEW.ID, :NEW.OBJ_ID, :NEW.ALIAS, :NEW.COMMENTS,
           :NEW.PREV_ID, :NEW.CMD_ID,
           :NEW.USED_OBJ_ID, :NEW.MACRO, :NEW.CONDITION,
           :NEW.M_DATE,:NEW.M_USER,
           :OLD.ID, :OLD.OBJ_ID, :OLD.ALIAS, :OLD.COMMENTS,
           :OLD.PREV_ID, :OLD.CMD_ID,
           :OLD.USED_OBJ_ID, :OLD.MACRO, :OLD.CONDITION,
           :OLD.M_DATE, :OLD.M_USER);
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_au
AFTER UPDATE ON SP.MACROS
--(SP-MACROS.trg)
DECLARE
	rec SP.UPDATED_MACROS%ROWTYPE;
  ObjName SP.OBJECTS.NAME%TYPE;
  EditRole NUMBER;
  tmpVar NUMBER;
  err BOOLEAN;
  BlockTemplate SP.COMMANDS.COMMENTS%type;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterUpdateMacros
  THEN
    --d('table тригер => return ','MACROS_au');
    RETURN;
  END IF;
  SP.TG.AfterUpdateMacros:= TRUE;
  --d('table тригер!!!','MACROS_au');
  --d('SP.TG.AfterDeleteObjects=>'||to_.STR(SP.TG.AfterDeleteObjects),
  --  'MACROS_au');
  --d('SP.TG.ObjectParDeleting  =>'||to_.STR(SP.TG.ObjectParDeleting  ),
  --  'MACROS_au');
  LOOP
    BEGIN
      SELECT * INTO rec
        FROM (SELECT * FROM SP.UPDATED_Macros) WHERE ROWNUM=1;
      --d('execute','MACROS_au');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        --d('exit','MACROS_au');
        EXIT;
    END;
    --d('select NAME','MACROS_au');
    if not  SP.TG.ObjectParDeleting then
      SELECT NAME, EDIT_ROLE INTO ObjName, EditRole FROM SP.OBJECTS
		  WHERE ID=rec.OLD_OBJ_ID;
		  -- Редактировать имет право администратор.
		  -- Если роль редактирования объекта не нулл, то редактировать объект
		  -- может пользователь, имеющий роль редактирования объекта.
			IF NOT SP.HasUserEditRoleID(EditRole) THEN
				SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_au.'||
	        ' Недостаточно привелегий для изменения объекта: '||ObjName||'!');
	    END IF;
    end if;

 	  -- Если поле MACRO установлено в нулл, то вставляем шаблон,
	  -- если он предусмотрен.
    --d('if rec.NEW_MACRO','MACROS_au');
    IF rec.NEW_MACRO IS NULL THEN
      BlockTemplate:=SP.Macro_Template(rec.NEW_CMD_ID,rec.NEW_USED_OBJ_ID);
	    IF BlockTemplate IS NOT NULL THEN
	      UPDATE SP.MACROS SET MACRO=BlockTemplate WHERE ID=rec.OLD_ID;
	    END IF;
    END IF;
	  -- Если изменёна ссылка на предыдущую строку, то проверяем,
    -- что предыдущая строка принадлежит тому же объекту что и текущая.
    IF     G.notEQ(rec.NEW_PREV_ID,rec.OLD_PREV_ID) 
      AND (rec.NEW_PREV_ID IS NOT NULL)
    THEN
      --d('select OBJ_ID','MACROS_au');
	    SELECT OBJ_ID INTO tmpVar FROM SP.MACROS
        WHERE ID = rec.NEW_PREV_ID;
      IF tmpVar != rec.NEW_OBJ_ID THEN
			  SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_au.'||
          ' Ссылка на предыдущую строку, принадлежащую другому объекту!');
      END IF;
    END IF;
    -- Проверяем соответствие команды и типа используемого ею объекта.
    IF rec.NEW_USED_OBJ_ID is not null THEN
	    SELECT OBJECT_KIND INTO tmpVar FROM SP.OBJECTS 
	      WHERE ID = rec.NEW_USED_OBJ_ID;
      -- d('OBJECT_KIND '||tmpVar,'MACROS_au');	    
	    err:=false;  
	    IF rec.NEW_CMD_ID=G.Cmd_Create_Object THEN
		      if tmpVar in (SP.G.MACRO_OBJ, SP.G.OPERATION_OBJ) then 
          err:=true; 
        end if;
	    END IF;      
	    IF rec.NEW_CMD_ID in(G.Cmd_Execute, G.Cmd_For_Selected,
	                         G.Cmd_For_Systems,   G.Cmd_For_Objects)
	    THEN
	      if tmpVar not in (SP.G.MACRO_OBJ, SP.G.OPERATION_OBJ) then 
          err:=true; 
        end if;
	    END IF;
	    IF err THEN           
	      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_au.'||
	        ' Тип используемого объекта не совместим с командой!');
	    END IF; 
    END IF;      
    -- Удаляем обработанную запись.
    --d('Удаляем обработанную запись','MACROS_au');
    DELETE FROM SP.UPDATED_MACROS WHERE OLD_ID=rec.OLD_ID;
	END LOOP;
  SP.TG.AfterUpdateMacros := FALSE;
  --d('end','MACROS_au');
 END;
/
--BEFORE_DELETE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_bdr
BEFORE DELETE ON SP.MACROS FOR EACH ROW
--(SP-MACROS.trg)
BEGIN
  --d(TO_CHAR(:OLD.ID),'MACROS_bdr');
  IF ReplSession THEN RETURN; END IF;
  IF :OLD.ID < 100 THEN
		SP.TG.ResetFlags;
	  RAISE_APPLICATION_ERROR(-20033,
      'SP.MACROS_bdr. Нельзя удалять предопределенные макросы!');
  END IF;
  -- Если это каскадное удаление макрокоманд после удаления объекта, то выход.
  IF SP.TG.ObjectParDeleting THEN 
    --d('return','MACROS_bdr'); 
    RETURN;
  END IF;
  -- Устанавливаем признак изменения у не имеющих родителей композитных 
	-- объектов, которые были созданы сами при помощи этой последовательности
	-- макрокоманд или данная последовательность была использована при создании
	-- их потомков.
  --d('insert','MACROS_bdr'); 
  INSERT INTO SP.DELETED_MACROS 
    VALUES(:OLD.ID, :OLD.OBJ_ID, :OLD.ALIAS, :OLD.COMMENTS,
           :OLD.PREV_ID, :OLD.CMD_ID,
           :OLD.USED_OBJ_ID, :OLD.MACRO, :OLD.CONDITION,
           :OLD.M_DATE, :OLD.M_USER);
  --d('end','MACROS_bdr'); 
END;
/
--AFTER_DELETE_TABLE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.MACROS_ad
AFTER DELETE ON SP.MACROS
--(SP-MACROS.trg)
DECLARE
	rec SP.DELETED_MACROS%ROWTYPE;
  tmpVar NUMBER;
  ObjName SP.OBJECTS.NAME%TYPE;
  EditRole NUMBER;
BEGIN
  IF ReplSession THEN RETURN; END IF;
  IF SP.TG.AfterDeleteMacros 
  THEN 
    --d('table тригер => return ','MACROS_ad');
    RETURN; 
  END IF;
  SP.TG.AfterDeleteMacros:= TRUE;
  --d('table тригер','MACROS_ad');
  --d('SP.TG.AfterDeleteObjects=>'||to_.STR(SP.TG.AfterDeleteObjects),
  --  'MACROS_ad');
  
  LOOP
    BEGIN
      SELECT * INTO rec FROM SP.DELETED_Macros WHERE ROWNUM=1;
      --d('execute'||rec.OLD_ID,'MACROS_ad');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --d('exit','MACROS_ad');
        EXIT;
    END;
    BEGIN
	    SELECT NAME, EDIT_ROLE INTO ObjName, EditRole 
	      FROM SP.OBJECTS
			  WHERE ID=rec.OLD_OBJ_ID;
		  -- Редактировать имет право администратор.
		  -- Если роль редактирования объекта не нулл, то редактировать объект
		  -- может пользователь, имеющий роль редактирования объекта.
			IF NOT SP.HasUserEditRoleID(EditRole) THEN		
				SP.TG.ResetFlags;	  
	      RAISE_APPLICATION_ERROR(-20033,'SP.MACROS_ad.'||
	        ' Недостаточно привелегий для изменения объекта: '||ObjName||'!');
	    END IF;
    EXCEPTION
      -- Если нет объекта, то нет и проблемм.
      WHEN NO_DATA_FOUND THEN 
        NULL;
        --d('NO_DATA_FOUND','MACROS_ad');
    END;      
    -- Удаляем обработанную запись.
    --d('delete current','MACROS_ad');
    DELETE FROM SP.DELETED_MACROS WHERE OLD_ID=rec.OLD_ID;  
	END LOOP;
  SP.TG.AfterDeleteMacros := FALSE;
END;
/


-- end of file

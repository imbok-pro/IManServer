-- DOCs view triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.10.2013
-- update 11.10.2013 16.10.2013 22.10.2013 24.02.2014 14.06.2014 26.08.2014
--*****************************************************************************
-- 
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_DOCS_ii
INSTEAD OF INSERT ON SP.V_DOCS
-- (SP-DOCs-Instead.trg)
DECLARE
  tmpVar NUMBER;
  NEW_USING_ROLE_ID NUMBER;
  NEW_GROUP_ID NUMBER;
  NEW_FORMAT_ID NUMBER;
  NewID NUMBER;
  PrevID NUMBER;
  OLD_REFERANCER NUMBER;
BEGIN
  if :NEW.FORMAT is null then
    NEW_FORMAT_ID:=0;
  else
    NEW_FORMAT_ID:=:NEW.FORMAT;
  end if;   
  -- Проверяем, существует ли запрашиваемая роль.
  if (:NEW.USING_ROLE is null) and (:NEW.USING_ROLE_ID is null) then
    NEW_USING_ROLE_ID:=null;
  else  
    begin
     if :NEW.USING_ROLE is not null then
       select ID into NEW_USING_ROLE_ID from SP.SP_ROLES
         where NAME=:NEW.USING_ROLE;
     else    
       select ID into NEW_USING_ROLE_ID from SP.SP_ROLES
         where ID=:NEW.USING_ROLE_ID;
     end if;    
   exception
     when no_data_found then 
       SP.TG.ResetFlags;
       RAISE_APPLICATION_ERROR(-20033, 'SP.V_DOCS_ii.'||
         ' Отсутствует или недоступна роль!');
   end;
  end if; 
  -- Если нет символьного обозначения имени группы, то проверяем наличие группы     
  -- с переданным идентификатором. 
  -- Если идентификатор группы отсутствует или неверен, то ошибка.
  if :NEW.GROUP_NAME is null
  then
    begin
      select id into NEW_GROUP_ID from SP.GROUPS g where g.ID=:NEW.GROUP_ID;
    exception
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_ii. Неверен идентификатор группы!' );
    end;
  else 
    -- Находим идентификатор группы, а если его нет,
    -- то добавляем группу с комментарием "DEPRICATED".
  	begin
      -- Находим идентификатор группы по её имени.
		  select ID into NEW_GROUP_ID from SP.GROUPS 
        where upper(NAME)=upper(:NEW.GROUP_NAME);
		exception
	    -- Если нет группы, то вставляем группу и комментарий.
		  when no_data_found then
			  insert into SP.GROUPS
          values(null, null, :NEW.GROUP_NAME, 'DEPRECATED',
                 null,NEW_USING_ROLE_ID,
                 sysdate,tg.UserName)
		      returning ID into NEW_GROUP_ID;
		end;
  end if;

  -- Параграф вставляем всегда в конец группы.
	insert into SP.DOCS (PARAGRAPH,FORMAT_ID,GROUP_ID,USING_ROLE,M_DATE,M_USER)
    values(:NEW.PARAGRAPH, NEW_FORMAT_ID, NEW_GROUP_ID, NEW_USING_ROLE_ID,
           :NEW.M_DATE, :NEW.M_USER)
    returning ID, PREV_ID into NewID, PrevID; 
  -- Если номер параграфа не задан, то выход.
  if :NEW.LINE is null then return; end if;  
  -- Переставляем параграф на его место в группе.
  -- Если номер позиции параграфа <= 1, то ссылка на предыдущий параграф нулл.
  if :NEW.LINE <= 1 then
    -- Если это единственный параграф в группе, то выход.
    if PrevID is null then return; end if;
    -- Если параграф придётся переставлять в начало, 
    -- то его целевая ссылка - нулл.
    PrevID:= null;
  else
    -- Находим ссылку на позицию, которая будет предыдущей для вновь 
    -- добавленного параграфа. Пока позиция параграфа - последняя и на неё
    -- никто не ссылается.
    begin
      select ID into PrevID from SP.V_DOCS
        where (LINE = :NEW.LINE - 1) and (GROUP_ID=NEW_GROUP_ID); 
    exception
     -- Если такой позиции нет, то вставили в конец и порядок.
     -- Новый номер позиции был больше наибольшего существующего.
      when no_data_found then return;
    end;
  end if;
  -- Прежде чем переправить ссылку у вновь вставленного параграфа нужно найти
  -- параграф, который в настоящий момент ссылается на позицию, являющейся
  -- целью для вновь вставленного параграфа.
  if PrevID is null then
    begin
      select ID into OLD_Referancer from SP.DOCS 
        where GROUP_ID = NEW_GROUP_ID and PREV_ID is null;
    exception
      when no_data_found then 
         RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_ii. '||
      			'Ошибка алгоритма!');
    end;
  else    
    begin
      select ID into OLD_Referancer from SP.DOCS 
  	    where PREV_ID = PrevID;
    exception
      -- Если такого параграфа нет, то вставили в конец и порядок.
      -- Новый номер строки был больше наибольшего существующего.
      when no_data_found then return;
    end;
  end if;
  -- Исправляем ссылки.
  update SP.DOCS
    set PREV_ID = case ID
                    when NewID then PrevID
                    when OLD_Referancer then NewID
                  end
    where ID in (NewID, OLD_Referancer);
  -- Исправляем дату и пользователя после исправления ссылок.
  -- Если дата не изменилась после добавления записи, 
  -- то она изменится на текущую после обновления ссылок,
  -- а мы вермнём её назад.
  if :NEW.M_DATE is not null then
	  update SP.DOCS
	    set 
	      M_DATE = :NEW.M_DATE
	    where ID in (NewID, OLD_Referancer);
  end if;  
  if :NEW.M_USER is not null then
	  update SP.DOCS
	    set 
	      M_USER = :NEW.M_USER
	    where ID in (NewID, OLD_Referancer);
  end if;  
END;
/
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_DOCS_iu
INSTEAD OF UPDATE ON SP.V_DOCS
-- (SP-DOCs-Instead.trg)
DECLARE
  UsingROLE NUMBER;
  GroupID NUMBER;
  DocID NUMBER;
  PrevID NUMBER;
  OLD_Referancer NUMBER;
  BACK_Referancer NUMBER;
  maxLine NUMBER;
  ParIsLast BOOLEAN;
BEGIN
  -- Если изменено имя роли, то, если новое значение не нулл,
  -- проверяем существует ли запрашиваемая роль.
  if G.notEQ(:NEW.USING_ROLE, :OLD.USING_ROLE) then
	  if (:NEW.USING_ROLE is null) then
	    UsingROLE:=null;
	  else  
	    begin
	       select ID into UsingROLE from SP.SP_ROLES
	         where NAME=:NEW.USING_ROLE;
	    exception
	      when no_data_found then 
	        SP.TG.ResetFlags;
	        RAISE_APPLICATION_ERROR(-20033, 'SP.V_DOCS_iu.'||
	          ' Отсутствует или недоступна роль '||:NEW.USING_ROLE||' !');
	    end;
	  end if; 
  --  Если изменён идентификатор роли, то, если он не нулл, 
  --  проверяем его наличие. 
  elsif G.notEQ(:NEW.USING_ROLE, :OLD.USING_ROLE) then
    begin
       select ID into UsingROLE from SP.SP_ROLES
         where ID=:NEW.USING_ROLE_ID;
    exception
      when no_data_found then 
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.V_DOCS_iu.'||
        ' Отсутствует или недоступна роль!');
    end;
  else
    UsingROLE := :OLD.USING_ROLE_ID;
  end if;
  -- Если изменено имя группы, то находим её идентификатор.
  if G.notEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) then
    begin
      select id into GroupID from SP.GROUPS g 
        where upper(NAME)=upper(:NEW.GROUP_NAME);
    exception    
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_iu. Неверное имя группы '||:NEW.GROUP_NAME||' !' );
    end;
  -- Если изменён идентификатор группы, то проверяем его существование.   
  elsif G.notEQ(:NEW.GROUP_ID, :OLD.GROUP_ID) then 
    begin
      select id into GroupID from SP.GROUPS g where g.ID=:NEW.GROUP_ID;
    exception
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_iu. Неверен идентификатор группы!' );
    end;
  else
    GroupID := null;    
  end if;
  -- Обновляем параграф, записывая его содержимое всегда в конец группы,
  -- если группа была изменена в этой операции. При этом всегда изменяем дату
  -- обновления и пользователя.
  if GroupID is null then
	  update  SP.DOCS set
	    PARAGRAPH = :NEW.PARAGRAPH,
	    /*IMAGE_ID = :NEW.IMAGE,*/
	   	FORMAT_ID = :NEW.FORMAT,
	    USING_ROLE = UsingRole
	    where ID = :OLD.ID;
    ParIsLast :=false;
  else
    -- Находим ссылку на последний параграф группы.
    begin
	    select ID into PrevID from SP.DOCS
        where GROUP_ID=GroupID
          and CONNECT_BY_ISLEAF=1
	         start with PREV_ID is null
	         connect by PREV_ID = prior ID;
    exception
      -- Если ничего не нашли - значит это единственный параграф в группе.
      when no_data_found then PrevID:=null;
    end;
	  update SP.DOCS set
      PREV_ID = PrevID,
	    PARAGRAPH = :NEW.PARAGRAPH,
	    /*IMAGE_ID = :NEW.IMAGE,*/
	   	FORMAT_ID = :NEW.FORMAT,
	    USING_ROLE = UsingRole,
      GROUP_ID = GroupID
	    where ID = :OLD.ID;
    ParIsLast := true;
  end if;    
  -- Если не изменён номер строки и группа не перемещена, то выход.
  if (:NEW.LINE=:OLD.LINE) and (GroupID is null) then return; end if;
  -- Если сброшен номер строки, то выход.
  if (:NEW.LINE is null) then return; end if;
  -- Производим упорядочивание параграфов внутри группы.
  -- Если новая позиция параграфа меньше или равна единице,
  -- то целевой идентификатор ссылки равен нулл,
  if :NEW.LINE <= 1 then
    PrevID:=null;
  else
    -- иначе находим идентификатор параграфа для обновления ссылки текущего
    -- на предыдущий параграф группы.
    -- Если будем сдвигать позицию в сторону хвоста,
    if (:NEW.LINE > :OLD.LINE) and (not ParIsLast) then
	    begin
         -- то находим параграф, который сейчас занимает целевую позицию.
	      select ID into PrevID from SP.V_DOCS
	        where (GROUP_ID = GroupID) and (LINE = :NEW.LINE);
	    exception
	      -- Если такой позиции нет, то абзац переносится в конец.
	      -- Затребованная позиция больше наибольшей существующей.
	      when no_data_found then
          begin 
	          select MAX(LINE) into maxLine from SP.V_DOCS
	            where GROUP_ID = GroupID ;
	          select ID into PrevID from SP.V_DOCS
	            where (GROUP_ID = GroupID) and (LINE=maxLine);
		      exception
		        -- Если такой строки нет, то ошибка алгоритма.
		        when no_data_found then
		          RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_iu. '||
		            'Ошибка алгоритма 1 !');
		      end;
	    end;
    else 
      -- Позиция группы сдвигается ближе к началу.   
	    begin
	      select ID into PrevID from SP.V_DOCS
	        where (GROUP_ID = GroupID) and (LINE=:NEW.LINE-1);
      exception
        -- Если такой строки нет, то ошибка алгоритма.
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_iu. '||
            'Ошибка алгоритма 2 !');
      end;
    end if;    
  end if;
  -- Если целевая ссылка равна текущей или последняя строка должна стать
  -- последней (вычисленный целевой указатель указывает на сам параграф),
  -- то выход.
  if   G.EQ(PrevID, :OLD.PREV_ID) 
    OR G.EQ(PrevID, :OLD.ID)  
  then 
    return; 
  end if;
  -- Находим идентификатор парграфа, уже ссылающийся на позицию,
  -- идентификатор которой мы хотим использовать для новой ссылки.
  begin
    select ID into OLD_Referancer from SP.DOCS 
      where G.S_EQ(PREV_ID,PrevID)=1
        and (GROUP_ID = GroupID);
  exception
    -- Если такой строки нет, то происходит перенос параграфа в конец группы.
    when no_data_found then OLD_Referancer:=null;
  end;
  -- Находим идентификатор параграфа, ссылающийся на текущий параграф,
  -- а теперь должн будет ссылаться ссылку текущего параграфа.
  begin
    select ID into BACK_Referancer from SP.DOCS 
      where G.S_EQ(PREV_ID, :OLD.ID)=1 
        and (GROUP_ID = GroupID);
  exception
    -- Если такой строки нет, то текущая строка была последней.
    when no_data_found then
      BACK_Referancer := null;
  end;
  -- Исправляем ссылки.
  case
    -- Игнорируем перенос последней строки в конец.
    when (OLD_Referancer is null) and (BACK_Referancer is null) then return;    
    -- Текущая строка была последней.
    when BACK_Referancer is null then
	    update SP.DOCS
	      set PREV_ID = case ID
	                      when :OLD.ID then PrevID
	                      when OLD_Referancer then :OLD.ID
	                    end
	      where ID in (:OLD.ID, OLD_Referancer);
    -- Строка переносится в конец.
    when OLD_Referancer is null then
	    update SP.DOCS
	      set PREV_ID = case ID
	                      when :OLD.ID then PrevID
	                      when BACK_Referancer then :OLD.PREV_ID
	                    end
	      where ID in (:OLD.ID, BACK_Referancer);
  else
     -- Наиболее общий случай. Переписываются три ссылки.
    update SP.DOCS
      set PREV_ID = case ID
                      when :OLD.ID then PrevID
                      when OLD_Referancer then :OLD.ID
                      when BACK_Referancer then :OLD.PREV_ID
                    end
      where ID in (:OLD.ID, OLD_Referancer, BACK_Referancer);
  end case;  
END;
/
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_DOCS_id
INSTEAD OF DELETE ON SP.V_DOCS
-- (SP-DOCs-Instead.trg)
DECLARE
  tmpVar NUMBER;
  MaxRowID NUMBER;
  OldPrevID NUMBER;
BEGIN
  -- Прежде чем удалить параграф необходио проверить и перецепить ссылки
  -- упорядочивающие параграфы.
  -- Находим параграф, ссылающийся на удаляемый.
  begin
    select ID into tmpVar FROM SP.DOCS where PREV_ID=:OLD.ID;
    --d('next_ID = '||tmpVar,'V_DOCS_id');
  exception
   -- Если такого параграфа нет, то наш параграф - последний.
   -- Удаляем параграф и покидаем тригер.
   when no_data_found then
	    delete from SP.DOCS where ID=:OLD.ID;
     return;
  end;
  -- Находим число связей в группе.
  select count(*) into tmpVar from SP.DOCS  
    where GROUP_ID  = :OLD.GROUP_ID;
  --d('line count = '||tmpVar,'V_DOCS_id');
  -- Находим идентификатор последнего параграфа.  
  select ID into MaxRowID from SP.V_DOCS 
   where (line = tmpVar) and (GROUP_ID  = :OLD.GROUP_ID);
  --d('MaxRowID = '||MaxRowID,'V_DOCS_id');
  -- У удаляемого параграфа изменяем ссылку, указывающую на предыдущий параграф
  -- на найденный идентификатор последнего параграфа (чтобы не нарушить
  -- целосттность ограничений),
  -- а у параграфа ссылающегося на удаляемый изменяем ссылку, на ссылку,
  -- равную ссылке, которая была у удаляемого параграфа.
  --d(':OLD.ID = '||:OLD.ID,'V_DOCS_id');
  --d(':OLD.PREV_ID = '||:OLD.PREV_ID,'V_DOCS_id');
  -- При удалении нескольких параграфов может возникнуть ситуация,
  -- когда поле :OLD.PREV_ID уже не актуально, 
  -- поскольку могло быть изменено при предыдущих срабатываниях этого
  -- тригера.
  -- Находим ссылку заново.
  select PREV_ID into OldPrevID from SP.DOCS where ID = :OLD.ID;
  update SP.DOCS
    set PREV_ID = case ID
                    when :OLD.ID then MaxRowID
                    when tmpVar then OldPrevID
                  end
    where ID in (:OLD.ID, tmpVar);
  -- Удаляем параграф и покидаем тригер.
  --d('ID'||to_char(:OLD.ID),'V_DOCS_id');
  delete from SP.DOCS where ID=:OLD.ID;
END;
/

-- end of File 
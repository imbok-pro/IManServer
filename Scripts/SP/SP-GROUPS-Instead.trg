-- SP GROUPS views triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 06.06.2013 17.06.2013 04.10.2013 11.10.2013 16.10.2013 22.10.2013
--        25.10.2013 24.02.2014 15.04.2014 13.06.2014 14.06.2013 26.08.2014
--*****************************************************************************

-- V_GROUPS
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GROUPS_ii
INSTEAD OF INSERT ON SP.V_GROUPS
--(SP-GROUPS.trg)
DECLARE
	tmpVar NUMBER;
	NEW_GR_ID NUMBER;
	NEW_P_ID NUMBER;
  NEW_EDIT_ROLE NUMBER;
  NEW_NAME SP.GROUPS.NAME%type;
  NEW_COMMENTS SP.COMMANDS.COMMENTS%type;
  Rel_ID NUMBER;
  PrevRel_ID NUMBER;
  OLD_Referancer NUMBER;
BEGIN
  -- Триггер может добавить связь между группами, или группу или и то и другое. 
  -- Если нет символьного обозначения имени группы, то проверяем наличие группы     
  -- с переданным идентификатором. 
  -- Если идентификатор группы отсутствует или неверен, то ошибка.
  NEW_NAME := utrim(:NEW.NAME);  
  if NEW_NAME is null
  then
    begin
      select id into NEW_GR_ID from SP.GROUPS g where g.ID=:NEW.G_ID;
    exception
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'V_GROUPS insert. Неверен идентификатор группы!' );
    end;
	else	
  	begin
      -- Находим идентификатор группы по её имени.
		  select ID into NEW_GR_ID from SP.GROUPS 
        where upper(NAME)=upper(NEW_NAME);
		exception
	    -- Если нет группы, то вставляем группу и комментарий.
		  when no_data_found then
        -- Проверяем, существует ли запрашиваемая роль.
        if (:NEW.G_ROLE is null) and (:NEW.G_ER_ID is null) then
          NEW_EDIT_ROLE:=null;
        else  
	        begin
	          if :NEW.G_ROLE is not null then
	            select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	              where NAME=:NEW.G_ROLE;
	          else    
	            select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	              where ID=:NEW.G_ER_ID;
	          end if;    
	        exception
	          when no_data_found then 
              SP.TG.ResetFlags;
	            RAISE_APPLICATION_ERROR(-20033, 'SP.V_GROUPS_ii.'||
	        ' Отсутствует или недоступна роль!');
	        end;
        end if; 
        -- Если комментарий незаполнен и присутствует флаг загрузки,
        -- то вписываем "deprecated"
        if :NEW.COMMENTS is null and TG.ImportDATA then
          NEW_COMMENTS:='DEPRECATED';
        else
          NEW_COMMENTS:=:NEW.COMMENTS;  
        end if;       
			  insert into SP.GROUPS
          values(null, :NEW.G_IM_ID, NEW_NAME, NEW_COMMENTS, :NEW.ALIAS,
                 NEW_EDIT_ROLE, :NEW.M_DATE, :NEW.M_USER)
		      returning ID into NEW_GR_ID;
		end;
	end if;	
  -- Идентификатор группы найден, переходим к нахождению других полей 
  -- добавляемой связи.					
	-- Если символьное или числовое обозначение родителя не нулл,
	-- то вставляем связь.
	if (:NEW.PARENT_G is not null) or (:NEW.P_ID is not null )
	then
    -- При этом, если символьное обозначение включаемой группы не нулл,
  	-- то находим идентификатор включаемой группы.
		if (:NEW.PARENT_G is not null) then
		  begin
			  select ID into NEW_P_ID from SP.GROUPS 
			    where upper(NAME)=upper(utrim(:NEW.PARENT_G));
			exception
        when no_data_found then
          SP.TG.ResetFlags;
	        RAISE_APPLICATION_ERROR(-20033,
            'SP.V_GROUPS_ii. '||:NEW.PARENT_G||' - не существует!' );
      end;
		else
		  -- Проверяем, что идентификатор родителя существует.
		  begin
			  select ID into NEW_P_ID from SP.GROUPS 
			    where ID=:NEW.P_ID;
			exception
        when no_data_found then
          SP.TG.ResetFlags;
	        RAISE_APPLICATION_ERROR(-20033,
            'SP.V_GROUPS_ii. Неверен идентификатор родителя!' );
      end;
		end if;
		-- Если связи с родителем ещё нет, то вставляем связь.	
		select count(*) into tmpVar from SP.REL_S 
		  where (INC=NEW_GR_ID) and (GR=NEW_P_ID);
		if tmpVar=0 then	
	    -- Защита от зацикливания.
	    -- Нельзя включать группу, которая в свою очередь включает вставляемую 
	    -- группу, а так-же, если родитель равен группе.
	    select count(*)into tmpVar from 
		    (select INC from SP.REL_S
	        start with GR  = NEW_GR_ID
	        connect by  GR = prior INC)
			  where INC=NEW_P_ID;
	    if (tmpVar>0)or(NEW_GR_ID=NEW_P_ID) then
	      SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_ii. Cycle Error'||
	      ' Group: '''||:OLD.NAME||''': Parent: '''||:NEW.PARENT_G||''' !');
		  end if;
      -- Связь вставляем всегда в конец ветки.
		  insert into SP.REL_S (GR,INC,M_DATE,M_USER) 
        values(NEW_P_ID,NEW_GR_ID, :NEW.M_DATE, :NEW.M_USER)
        returning ID, PREV_ID into Rel_ID, PrevRel_ID;
      -- Если номер строки не задан, то выход.
      if :NEW.LINE is null then return; end if;  
    else
      -- Если номер строки не задан, то выход.
      if :NEW.LINE is null then return; end if;  
      -- Находим идентификатор связи.
      select ID, PREV_ID into Rel_ID, PrevRel_ID from SP.REL_S 
		  where (INC=NEW_GR_ID) and (GR=NEW_P_ID);    
		end if;	
    -- Вставляем группу на её место в упорядоченной ветке.
    -- Если номер позиции группы <= 1, то ссылка на предыдущую группу нулл.
    if :NEW.LINE <= 1 then
      -- Если группа единственная, то выход.
      if PrevRel_ID is null then return; end if;
      -- Если группу придётся переставлять в начало, то её целевая ссылка нулл.
      PrevRel_ID:= null;
    else
      -- Находим ссылку на позицию, которая будет предыдущей для вновь 
      -- добавленной группы. Пока позиция группы последняя и на неё никто не
      -- ссылается.
      begin
        select R_ID into PrevRel_ID from SP.V_GROUPS
          where (LINE = :NEW.LINE - 1) and (P_ID=NEW_P_ID); 
      exception
	      -- Если такой позиции нет, то вставили в конец и порядок.
	      -- Новый номер позиции был больше наибольшего существующего.
        when no_data_found then return;
      end;
    end if;
    -- Прежде чем переправить ссылку у вновь вставленной связи нужно найти
    -- связь, которая в настоящий момент ссылается на позицию, являющейся
    -- целью для вновь вставленной группы.
    if PrevRel_ID is null then
      begin
        select ID into OLD_Referancer from SP.REL_S 
          where GR = NEW_P_ID and PREV_ID is null;
      exception
        when no_data_found then 
           RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_ii. '||
        			'Ошибка алгоритма!');
      end;
    else    
      begin
        select ID into OLD_Referancer from SP.REL_S 
    	    where PREV_ID = PrevRel_ID;
      exception
        -- Если такой строки нет, то вставили в конец и порядок.
        -- Новый номер строки был больше наибольшего существующего.
        when no_data_found then return;
      end;
    end if;
    -- Исправляем ссылки.
    update SP.REL_S
      set 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER,
        PREV_ID = case ID
                    when Rel_ID then PrevRel_ID
                    when OLD_Referancer then Rel_ID
                  end
      where ID in (Rel_ID, OLD_Referancer);
	end if;
END;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GROUPS_iu
INSTEAD OF UPDATE ON SP.V_GROUPS
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
  NEW_EDIT_ROLE NUMBER;
	NEW_P_ID NUMBER;
  NEW_NAME SP.GROUPS.NAME%type;
  NEW_PARENT SP.GROUPS.NAME%type;
  Rel_ID NUMBER;
  PrevRel_ID NUMBER;
  OLD_PREV_ID NUMBER;
  OLD_Referancer NUMBER;
  BACK_Referancer NUMBER;
  Rel_isLast BOOLEAN;
  maxLine NUMBER;
BEGIN
  NEW_NAME :=utrim(:NEW.NAME);
  NEW_PARENT :=utrim(:NEW.PARENT_G);
  Rel_isLast :=false;
  OLD_PREV_ID := :OLD.PREV_ID;
  -- Нельзя редактировать группу или связь, если идентификаторы меньше 100.
	if   (   (:OLD.G_ID < 100) 
	      and SP.G.notUpEQ(:OLD.NAME,NEW_NAME)
				and (:OLD.COMMENTS != :NEW.COMMENTS)
				)
	  or ( (:OLD.R_ID < 100)
		  and(:OLD.G_ID < 100)
			and((:OLD.P_ID != :NEW.P_ID )
			  or SP.G.notUpEQ(NEW_PARENT,:OLD.PARENT_G))
			  ) 
	then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.V_GROUPS_iu. Group: '||:OLD.NAME||' blocked!' );
	end if;
	-- Имя группы не может быть нулл.
	if NEW_NAME is null then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. New Group name is null!');
	end if;
  -- Изменяем роль на новую, если она изменена.
	if   SP.G.notUpEQ(:NEW.G_ROLE,:OLD.G_ROLE)
    or SP.G.notEQ(:NEW.G_ER_ID,:OLD.G_ER_ID) 
  then
    begin
      if SP.G.notUpEQ(:NEW.G_ROLE,:OLD.G_ROLE) then
        if :NEW.G_ROLE is null then
          NEW_EDIT_ROLE:=null;
        else  
	        select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	          where NAME=:NEW.G_ROLE;
        end if;  
      else    
        if :NEW.G_ER_ID is null then
          NEW_EDIT_ROLE:=null;
        else  
	        select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	          where ID=:NEW.G_ER_ID;
        end if;    
      end if;    
    exception
      when no_data_found then 
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.V_GROUPS_iu.'||
        ' Отсутствует или недоступна роль!');
    end;      
    update SP.GROUPS set EDIT_ROLE=NEW_EDIT_ROLE where ID=:OLD.G_ID;  
  end if;
	-- Изменяем ссылку на объект, если она изменена.
	if SP.G.notEQ(:NEW.ALIAS,:OLD.ALIAS) then
	  update SP.GROUPS 
      set 
        ALIAS = :NEW.ALIAS, 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER
      where ID=:OLD.G_ID;
	end if;
	-- Изменяем имя группы, если оно изменено.
	if SP.G.notUpEQ(NEW_NAME,:OLD.NAME) then
	  update SP.GROUPS 
      set 
        NAME = NEW_NAME, 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER
      where ID=:OLD.G_ID;
	end if;
	-- Изменяем идентификатор изображения группы, если изменён.
	if SP.G.notEQ(:NEW.G_IM_ID,:OLD.G_IM_ID) then
	  update SP.GROUPS 
      set 
        IM_ID = :NEW.G_IM_ID, 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER
      where ID=:OLD.G_ID;
	end if;
  -- Изменяем комментарий, если изменён.
  if SP.G.notEQ(:NEW.COMMENTS,:OLD.COMMENTS) then
	  update SP.GROUPS 
      set 
        COMMENTS = :NEW.COMMENTS, 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER
      where ID=:OLD.G_ID;
  end if;	
  Rel_ID:=null;
  PrevRel_ID:=null;
	-- Если изменилась ссылка.
	if   SP.G.notUpEQ(NEW_PARENT,:OLD.PARENT_G)
	  or SP.G.notEQ(:NEW.P_ID,:OLD.P_ID)
	then	
  	-- Если символьная или числовая часть ссылки стала нуллом,
    -- то просто удаляем связь.
  	if   G.UpEQ(NEW_PARENT,:OLD.PARENT_G) and (:NEW.P_ID is null) 
      or G.UpEQ(:NEW.P_ID,:OLD.P_ID) and (NEW_PARENT is null)
    then
  	  delete from SP.REL_S where ID=:OLD.R_ID;
      -- В этом случае и упорядочивать нечего.
      return;
  	else	
	 		-- Если изменена символьная часть и она не нулл,
      -- то находим идентификатор.
			if     SP.G.notUpEQ(NEW_PARENT,:OLD.PARENT_G) 
			  and (NEW_PARENT is not null)
			then
			  begin
			    select ID into NEW_P_ID from SP.GROUPS 
            where upper(NAME)=upper(NEW_PARENT);
				exception
				  when no_data_found then
						SP.TG.ResetFlags;
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. '||
              'Group: '||NEW_PARENT||' not exist!');
				end;		
			else
				-- Проверка, что родитель с таким идентификатором существует.
			  begin
			    select ID into NEW_P_ID from SP.GROUPS
				    where ID=:NEW.P_ID;
				exception
				  when no_data_found then
						SP.TG.ResetFlags;
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. '||
              'Group with ID: '||:NEW.P_ID||' not exist!');
				end;		
			end if;
      -- Защита от зацикливания.
      -- Нельзя включать группу, которая в свою очередь включает вставляемую
      -- группу.
		  select count(*)into tmpVar from 
				(select INC from SP.REL_S start with GR  = :OLD.G_ID
	                                     connect by   GR = prior INC)
				where INC=NEW_P_ID;
		  if (tmpVar>0)or(:OLD.G_ID=NEW_P_ID) then
			  SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. Group: '||:OLD.NAME||
				' Cycle Error!');
		  end if;
			-- Для перецепления ссылки, нужно удалить старую связь, 
			-- если она существует, и создать новую.
		  if :OLD.R_ID is not null then
	      delete from SP.REL_S where ID=:OLD.R_ID;
			end if;	
			-- Если такая связь не существует, то добавляем.
			select count(*) into tmpVar from SP.REL_S 
			  where (INC=:OLD.G_ID) and (GR=NEW_P_ID);
			if tmpVar=0 then	
		    insert into SP.REL_S (GR,INC,M_DATE,M_USER) 
          values(NEW_P_ID,:OLD.G_ID,:NEW.M_DATE,:NEW.M_USER)
          returning ID, PREV_ID into Rel_ID, PrevRel_ID;
        -- При этом наша связь добавляется в конец списка связей.
        Rel_isLast:=true; 
        OLD_PREV_ID := PrevRel_ID; 
      else
			  select ID, PREV_ID into Rel_ID, PrevRel_ID from SP.REL_S 
			    where (INC=:OLD.G_ID) and (GR=NEW_P_ID);
        OLD_PREV_ID := PrevRel_ID; 
			end if;
		end if;		
	else
    NEW_P_ID:=:NEW.P_ID;
  end if;
  -- Если была добавлена связь и она единственная,
  -- то выход поскольку нечего упорядочивать!
  if    (Rel_ID is not null) and (PrevRel_ID is null) then return; end if;
  -- Если была добавлена связь или изменён порядок следования групп,
  -- то производим упорядовачивание.
  if    ((Rel_ID is not null) or (:OLD.LINE != :NEW.LINE)) 
    and (:NEW.LINE is not null)
  then
    -- Если простое переупорядочивание, то устанавливаем переменную Rel_ID.
    if Rel_ID is null then Rel_ID:=:OLD.R_ID; end if;
    -- Если новая позиция группы меньше или равна единице,
    -- то целевой идентификатор ссылки равен нулл,
    d('Rel_ID '||to_char(Rel_ID)||to_.STR()||
      'NEW_P_ID '||to_char(NEW_P_ID)||to_.STR()||
      'OLD_PREV_ID '||to_char(OLD_PREV_ID)||to_.STR()||
      'PrevRel_ID '||to_char(PrevRel_ID)||to_.STR()||
      ':NEW.LINE '||to_char(:NEW.LINE)
      ,'V_GROUPS_iu');
	  if :NEW.LINE <= 1 then
	    PrevRel_ID:=null;
	  else
	    -- иначе находим идентификатор связи для обновления ссылки текущей связи
      -- на предыдущую связь в списке родителя.
      -- Если будем сдвигать позицию в сторону хвоста,
      if (:NEW.LINE > :OLD.LINE) and (not Rel_isLast) then
		    begin
          -- то находим группу, которая сейчас занимает целевую позицию.
		      select R_ID into PrevRel_ID from SP.V_GROUPS
		        where (P_ID=NEW_P_ID) and (LINE=:NEW.LINE);
		    exception
		      -- Если такой позиции нет, то группа переносится в конец.
		      -- Затребованная позиция больше наибольшей существующей.
		      when no_data_found then
	          begin 
		          select MAX(LINE) into maxLine from SP.V_GROUPS
		            where P_ID = NEW_P_ID ;
		          select R_ID into PrevRel_ID from SP.V_GROUPS
		            where (P_ID=NEW_P_ID) and (LINE=maxLine);
			      exception
			        -- Если такой строки нет, то ошибка алгоритма.
			        when no_data_found then
			          RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. '||
			            'Ошибка алгоритма 1 !');
			      end;
		    end;
	    else 
        -- Позиция группы сдвигается ближе к началу.   
		    begin
		      select R_ID into PrevRel_ID from SP.V_GROUPS
		        where (P_ID=NEW_P_ID) and (LINE=:NEW.LINE-1);
	      exception
	        when no_data_found then
          -- Если связь свежедобавлена при изменении родителя то выход,
          if Rel_isLast then return; end if;
          -- иначе ошибка алгоритма.
	          RAISE_APPLICATION_ERROR(-20033,'SP.V_GROUPS_iu. '||
	            'Ошибка алгоритма 2 !');
	      end;
	    end if;    
	  end if;
	  -- Если целевая ссылка равна текущей или последняя строка должна стать
    -- последней (вычисленный целевой указатель указывает на саму связь),
    -- то выход.
	  if   G.EQ(PrevRel_ID, OLD_PREV_ID) 
      OR G.EQ(PrevRel_ID, Rel_ID)  
    then 
      return; 
    end if;
	  -- Находим идентификатор связи, уже ссылающийся на позицию,
	  -- идентификатор которой мы хотим использовать для новой ссылки.
	  begin
	    select ID into OLD_Referancer from SP.REL_S 
	      where G.S_EQ(PREV_ID,PrevRel_ID)=1
	        and (GR=NEW_P_ID);
	  exception
	    -- Если такой строки нет, то происходит перенос группы в конец списка
      -- групп данного родителя.
	    when no_data_found then OLD_Referancer:=null;
	  end;
    -- Находим идентификатор связи, ссылающийся на текущую связь,
	  -- а теперь должна будет ссылаться ссылку текущей связи.
	  begin
	    select ID into BACK_Referancer from SP.REL_S 
	      where G.S_EQ(PREV_ID, Rel_ID)=1 
	        and (GR=NEW_P_ID);
	  exception
	    -- Если такой строки нет, то текущая группа - последняя в списке групп
      -- родителя.
	    when no_data_found then
	      BACK_Referancer := null;
	  end;
	  -- Исправляем ссылки.
    d('BACK_Referancer '||to_char(BACK_Referancer)||to_.STR()||
      'OLD_Referancer '||to_char(OLD_Referancer)
      ,'V_GROUPS_iu');
	  case
	    when (OLD_Referancer is null) and (BACK_Referancer is null) then return;    
	    -- Текущая группа была последней.
	    when BACK_Referancer  is null then
		    update SP.REL_S
		      set
            M_DATE = :NEW.M_DATE,
            M_USER = :NEW.M_USER,
            PREV_ID = case ID
		                    when Rel_ID then PrevRel_ID
		                    when OLD_Referancer then Rel_ID
		                  end
		      where ID in (Rel_ID, OLD_Referancer);
	    -- Группа переносится в конец.
	    when OLD_Referancer is null then
		    update SP.REL_S
		      set 
            M_DATE = :NEW.M_DATE,
            M_USER = :NEW.M_USER,
            PREV_ID = case ID
		                    when Rel_ID then PrevRel_ID
		                    when BACK_Referancer then OLD_PREV_ID
		                  end
		      where ID in (Rel_ID, BACK_Referancer);
	    -- Игнорируем перенос и так последней группы в конец.
	  else
      -- Наиболее общий случай. Переписываются три ссылки.
	    update SP.REL_S
	      set 
          M_DATE = :NEW.M_DATE,
          M_USER = :NEW.M_USER,
          PREV_ID = case ID
	                    when Rel_ID then PrevRel_ID
	                    when OLD_Referancer then Rel_ID
	                    when BACK_Referancer then OLD_PREV_ID
	                  end
	      where ID in (Rel_ID, OLD_Referancer, BACK_Referancer);
	  end case;  
  end if;  
END;
/	

--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GROUPS_id
INSTEAD OF DELETE ON SP.V_GROUPS
--(SP-GROUPS.trg)
DECLARE 
lineCount NUMBER;
MaxRowID NUMBER;
OldPrevID NUMBER;
NextRelID NUMBER;
BEGIN
  -- Нельзя удалять группы и связи, если их идентификаторы меньше 100.
	if  (:OLD.R_ID < 100)
    or((:OLD.G_ID <100) and (:OLD.R_ID is null))	
	then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.V_GROUPS_id. Group: '||:OLD.NAME||' blocked!' );
	end if;
  -- Удаляем связь, а если "R_ID is null", то группу.
	if :OLD.R_ID is null then
    --d('G_ID'||to_char(:OLD.G_ID),'V_GROUPS_id');
	  delete from SP.GROUPS where ID=:OLD.G_ID;
	else
    -- Прежде чем удалить связь необходио проверить и перецепить ссылки
    -- упорядочивающие связи.
    -- Находим связь, ссылающуюся на удаляемую.
    begin
      select ID into NextRelID FROM SP.REL_S where PREV_ID=:OLD.R_ID;
      --d('NextRelID => '||NextRelID,'V_GROUPS_id');
    exception
	    -- Если такой связи нет, то наша связь последняя.
	    -- Удаляем связь и покидаем тригер.
	    when no_data_found then
	 	    delete from SP.REL_S where ID=:OLD.R_ID;
	      return;
    end;
    -- Находим число связей в группе.
    select count(*) into lineCount from SP.REL_S  
      where GR = :OLD.P_ID;
    --d('line count = '||lineCount,'V_GROUPS_id');
    -- Находим идентификатор последней связи.  
    select R_ID into MaxRowID from SP.V_GROUPS 
	    where (line = lineCount) and (P_ID = :OLD.P_ID);
    --d('MaxRowID = '||MaxRowID,'V_GROUPS_id');
	  -- У удаляемой связи изменяем ссылку, указывающую на предыдущюю сязь
	  -- на найденный идентификатор последней связи (чтобы не нарушить
    -- целосттность ограничений),
	  -- а у ссылающейся связи на удаляемую изменяем ссылку, на ссылку,
	  -- равную ссылке, которая была у удаляемой строки.
	  --d(':OLD.R_ID = '||:OLD.R_ID,'V_GROUPS_id');
	  --d(':OLD.PREV_ID = '||:OLD.PREV_ID,'V_GROUPS_id');
	  -- При удалении нескольких строк может возникнуть ситуация,
	  -- когда поле :OLD.PREV_ID уже не актуально, 
	  -- поскольку могло быть изменено при предыдущих срабатываниях этого
    -- тригера.
    -- Находим ссылку заново.
    -- При изменении ссылки не меняем дату изменения группы.
    select PREV_ID into OldPrevID from SP.REL_S where ID = :OLD.R_ID;
    update SP.REL_S
      set 
        M_DATE = :NEW.M_DATE,
        M_USER = :NEW.M_USER,
        PREV_ID = case ID
                      when :OLD.R_ID then MaxRowID
                      when NextRelID then OldPrevID
                    end
      where ID in (:OLD.R_ID, NextRelID);
    for i in (select * from SP.REL_S where ID in(:OLD.R_ID, NextRelID))
    loop
      d('ID = '||i.ID||' PREV_ID = '||i.PREV_ID,'V_GROUPS_id');
    end loop;  
    -- Удаляем строку и покидаем тригер.
    --d('R_ID =>'||to_char(:OLD.R_ID),'V_GROUPS_id');
 	  delete from SP.REL_S where ID=:OLD.R_ID;
	end if;
END;
/	
--*****************************************************************************

-- V_PRIM_GROUPS
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_GROUPS_ii
INSTEAD OF INSERT ON SP.V_PRIM_GROUPS
--(SP-GROUPS.trg)
DECLARE
	tmpVar NUMBER;
  NEW_EDIT_ROLE NUMBER;
  NEW_NAME SP.GROUPS.NAME%type;
BEGIN
  NEW_NAME :=utrim(:NEW.NAME);
  if (:NEW.G_ROLE is null) and (:NEW.G_ER_ID is null) then
    case TG.SP_Admin
      when true then
        NEW_EDIT_ROLE:=null;
    else
      NEW_EDIT_ROLE:= G.USER_ROLE;   
    end case;
  else  
	  begin
	    if :NEW.G_ROLE is not null then
	      select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	        where NAME=:NEW.G_ROLE;
	    else    
	      select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	        where ID=:NEW.G_ER_ID;
	    end if;    
	  exception
	    when no_data_found then 
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033, 'SP.V_PRIM_GROUPS_ii.'||
	        ' Отсутствует или недоступна роль!');
	  end;
  end if;        
  insert into SP.GROUPS
    values(null, :NEW.G_IM_ID, NEW_NAME, :NEW.COMMENTS, null, NEW_EDIT_ROLE,
           :NEW.M_DATE, :NEW.M_USER);
END;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_GROUPS_iu
INSTEAD OF UPDATE ON SP.V_PRIM_GROUPS
--(SP-GROUPS.trg)
DECLARE
  tmpVar NUMBER;
  NEW_EDIT_ROLE NUMBER;
  NEW_NAME SP.GROUPS.NAME%type;
BEGIN
  NEW_NAME :=utrim(:NEW.NAME);
  -- Нельзя редактировать группу, если её идентификатор меньше 100.
	if :OLD.G_ID < 100 then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.V_PRIM_GROUPS_iu. '||
     'Group: '||:OLD.NAME||' blocked!' );
	end if;
	-- Имя группы не может быть нулл.
	if NEW_NAME is null then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.V_PRIM_GROUPS_iu. '||
      'New Group name is null!');
	end if;
  -- Изменяем роль, если изменена.
	if   SP.G.notUpEQ(:NEW.G_ROLE,:OLD.G_ROLE)
    or SP.G.notEQ(:NEW.G_ER_ID,:OLD.G_ER_ID) 
  then
    begin
      if SP.G.notUpEQ(:NEW.G_ROLE,:OLD.G_ROLE) then
        if :NEW.G_ROLE is null then
          NEW_EDIT_ROLE:=null;
        else  
	        select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	          where NAME=:NEW.G_ROLE;
        end if;  
      else    
        if :NEW.G_ER_ID is null then
          NEW_EDIT_ROLE:=null;
        else  
	        select ID into NEW_EDIT_ROLE from SP.SP_ROLES
	          where ID=:NEW.G_ER_ID;
        end if;    
      end if;    
    exception
      when no_data_found then 
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.V_GROUPS_iu.'||
        ' Отсутствует или недоступна роль!');
    end;      
    update SP.GROUPS set EDIT_ROLE=NEW_EDIT_ROLE where ID=:OLD.G_ID;  
  end if;
	-- Изменяем имя группы, если изменено.
	if SP.G.notUpEQ(NEW_NAME,:OLD.NAME) then
	  update SP.GROUPS 
      set 
        NAME=NEW_NAME 
      where ID=:OLD.G_ID;
	end if;
	-- Изменяем идентификатор изображения группы, если изменён.
	if SP.G.notEQ(:NEW.G_IM_ID,:OLD.G_IM_ID) then
	  update SP.GROUPS 
      set 
        IM_ID=:NEW.G_IM_ID 
      where ID=:OLD.G_ID;
	end if;
  -- Изменяем комментарий, если изменён.
  if SP.G.notEQ(:NEW.COMMENTS,:OLD.COMMENTS) then
    update SP.GROUPS 
      set 
        COMMENTS=:NEW.COMMENTS 
      where ID=:OLD.G_ID;
  end if;	
	-- Изменяем дату изменения группы, если изменена.
	if SP.G.notEQ(:NEW.M_DATE,:OLD.M_DATE) then
	  update SP.GROUPS 
      set 
        M_DATE = :NEW.M_DATE
      where ID=:OLD.G_ID;
	end if;
		-- Изменяем имя пользователя, если изменено.
	if SP.G.notEQ(:NEW.M_USER,:OLD.M_USER) then
	  update SP.GROUPS 
      set 
        M_USER = :NEW.M_USER
      where ID=:OLD.G_ID;
	end if;
END;
/	

--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_GROUPS_id
INSTEAD OF DELETE ON SP.V_PRIM_GROUPS
--(SP-GROUPS.trg)
BEGIN
  -- Нельзя удалять группу, если идентификатор меньше 100.
	if :OLD.G_ID < 100 then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.V_PRIM_GROUPS_id. Group: '||:OLD.NAME||' blocked!' );
	end if;
  delete from SP.GROUPS where ID=:OLD.G_ID;
END;
/	
--*****************************************************************************

-- end of file

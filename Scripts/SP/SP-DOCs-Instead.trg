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
  -- ���������, ���������� �� ������������� ����.
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
         ' ����������� ��� ���������� ����!');
   end;
  end if; 
  -- ���� ��� ����������� ����������� ����� ������, �� ��������� ������� ������     
  -- � ���������� ���������������. 
  -- ���� ������������� ������ ����������� ��� �������, �� ������.
  if :NEW.GROUP_NAME is null
  then
    begin
      select id into NEW_GROUP_ID from SP.GROUPS g where g.ID=:NEW.GROUP_ID;
    exception
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_ii. ������� ������������� ������!' );
    end;
  else 
    -- ������� ������������� ������, � ���� ��� ���,
    -- �� ��������� ������ � ������������ "DEPRICATED".
  	begin
      -- ������� ������������� ������ �� � �����.
		  select ID into NEW_GROUP_ID from SP.GROUPS 
        where upper(NAME)=upper(:NEW.GROUP_NAME);
		exception
	    -- ���� ��� ������, �� ��������� ������ � �����������.
		  when no_data_found then
			  insert into SP.GROUPS
          values(null, null, :NEW.GROUP_NAME, 'DEPRECATED',
                 null,NEW_USING_ROLE_ID,
                 sysdate,tg.UserName)
		      returning ID into NEW_GROUP_ID;
		end;
  end if;

  -- �������� ��������� ������ � ����� ������.
	insert into SP.DOCS (PARAGRAPH,FORMAT_ID,GROUP_ID,USING_ROLE,M_DATE,M_USER)
    values(:NEW.PARAGRAPH, NEW_FORMAT_ID, NEW_GROUP_ID, NEW_USING_ROLE_ID,
           :NEW.M_DATE, :NEW.M_USER)
    returning ID, PREV_ID into NewID, PrevID; 
  -- ���� ����� ��������� �� �����, �� �����.
  if :NEW.LINE is null then return; end if;  
  -- ������������ �������� �� ��� ����� � ������.
  -- ���� ����� ������� ��������� <= 1, �� ������ �� ���������� �������� ����.
  if :NEW.LINE <= 1 then
    -- ���� ��� ������������ �������� � ������, �� �����.
    if PrevID is null then return; end if;
    -- ���� �������� ������� ������������ � ������, 
    -- �� ��� ������� ������ - ����.
    PrevID:= null;
  else
    -- ������� ������ �� �������, ������� ����� ���������� ��� ����� 
    -- ������������ ���������. ���� ������� ��������� - ��������� � �� ��
    -- ����� �� ���������.
    begin
      select ID into PrevID from SP.V_DOCS
        where (LINE = :NEW.LINE - 1) and (GROUP_ID=NEW_GROUP_ID); 
    exception
     -- ���� ����� ������� ���, �� �������� � ����� � �������.
     -- ����� ����� ������� ��� ������ ����������� �������������.
      when no_data_found then return;
    end;
  end if;
  -- ������ ��� ����������� ������ � ����� ������������ ��������� ����� �����
  -- ��������, ������� � ��������� ������ ��������� �� �������, ����������
  -- ����� ��� ����� ������������ ���������.
  if PrevID is null then
    begin
      select ID into OLD_Referancer from SP.DOCS 
        where GROUP_ID = NEW_GROUP_ID and PREV_ID is null;
    exception
      when no_data_found then 
         RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_ii. '||
      			'������ ���������!');
    end;
  else    
    begin
      select ID into OLD_Referancer from SP.DOCS 
  	    where PREV_ID = PrevID;
    exception
      -- ���� ������ ��������� ���, �� �������� � ����� � �������.
      -- ����� ����� ������ ��� ������ ����������� �������������.
      when no_data_found then return;
    end;
  end if;
  -- ���������� ������.
  update SP.DOCS
    set PREV_ID = case ID
                    when NewID then PrevID
                    when OLD_Referancer then NewID
                  end
    where ID in (NewID, OLD_Referancer);
  -- ���������� ���� � ������������ ����� ����������� ������.
  -- ���� ���� �� ���������� ����� ���������� ������, 
  -- �� ��� ��������� �� ������� ����� ���������� ������,
  -- � �� ������ � �����.
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
  -- ���� �������� ��� ����, ��, ���� ����� �������� �� ����,
  -- ��������� ���������� �� ������������� ����.
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
	          ' ����������� ��� ���������� ���� '||:NEW.USING_ROLE||' !');
	    end;
	  end if; 
  --  ���� ������ ������������� ����, ��, ���� �� �� ����, 
  --  ��������� ��� �������. 
  elsif G.notEQ(:NEW.USING_ROLE, :OLD.USING_ROLE) then
    begin
       select ID into UsingROLE from SP.SP_ROLES
         where ID=:NEW.USING_ROLE_ID;
    exception
      when no_data_found then 
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033, 'SP.V_DOCS_iu.'||
        ' ����������� ��� ���������� ����!');
    end;
  else
    UsingROLE := :OLD.USING_ROLE_ID;
  end if;
  -- ���� �������� ��� ������, �� ������� � �������������.
  if G.notEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) then
    begin
      select id into GroupID from SP.GROUPS g 
        where upper(NAME)=upper(:NEW.GROUP_NAME);
    exception    
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_iu. �������� ��� ������ '||:NEW.GROUP_NAME||' !' );
    end;
  -- ���� ������ ������������� ������, �� ��������� ��� �������������.   
  elsif G.notEQ(:NEW.GROUP_ID, :OLD.GROUP_ID) then 
    begin
      select id into GroupID from SP.GROUPS g where g.ID=:NEW.GROUP_ID;
    exception
      when no_data_found then
        SP.TG.ResetFlags;
	      RAISE_APPLICATION_ERROR(-20033,
          'SP.V_DOCS_iu. ������� ������������� ������!' );
    end;
  else
    GroupID := null;    
  end if;
  -- ��������� ��������, ��������� ��� ���������� ������ � ����� ������,
  -- ���� ������ ���� �������� � ���� ��������. ��� ���� ������ �������� ����
  -- ���������� � ������������.
  if GroupID is null then
	  update  SP.DOCS set
	    PARAGRAPH = :NEW.PARAGRAPH,
	    /*IMAGE_ID = :NEW.IMAGE,*/
	   	FORMAT_ID = :NEW.FORMAT,
	    USING_ROLE = UsingRole
	    where ID = :OLD.ID;
    ParIsLast :=false;
  else
    -- ������� ������ �� ��������� �������� ������.
    begin
	    select ID into PrevID from SP.DOCS
        where GROUP_ID=GroupID
          and CONNECT_BY_ISLEAF=1
	         start with PREV_ID is null
	         connect by PREV_ID = prior ID;
    exception
      -- ���� ������ �� ����� - ������ ��� ������������ �������� � ������.
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
  -- ���� �� ������ ����� ������ � ������ �� ����������, �� �����.
  if (:NEW.LINE=:OLD.LINE) and (GroupID is null) then return; end if;
  -- ���� ������� ����� ������, �� �����.
  if (:NEW.LINE is null) then return; end if;
  -- ���������� �������������� ���������� ������ ������.
  -- ���� ����� ������� ��������� ������ ��� ����� �������,
  -- �� ������� ������������� ������ ����� ����,
  if :NEW.LINE <= 1 then
    PrevID:=null;
  else
    -- ����� ������� ������������� ��������� ��� ���������� ������ ��������
    -- �� ���������� �������� ������.
    -- ���� ����� �������� ������� � ������� ������,
    if (:NEW.LINE > :OLD.LINE) and (not ParIsLast) then
	    begin
         -- �� ������� ��������, ������� ������ �������� ������� �������.
	      select ID into PrevID from SP.V_DOCS
	        where (GROUP_ID = GroupID) and (LINE = :NEW.LINE);
	    exception
	      -- ���� ����� ������� ���, �� ����� ����������� � �����.
	      -- ������������� ������� ������ ���������� ������������.
	      when no_data_found then
          begin 
	          select MAX(LINE) into maxLine from SP.V_DOCS
	            where GROUP_ID = GroupID ;
	          select ID into PrevID from SP.V_DOCS
	            where (GROUP_ID = GroupID) and (LINE=maxLine);
		      exception
		        -- ���� ����� ������ ���, �� ������ ���������.
		        when no_data_found then
		          RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_iu. '||
		            '������ ��������� 1 !');
		      end;
	    end;
    else 
      -- ������� ������ ���������� ����� � ������.   
	    begin
	      select ID into PrevID from SP.V_DOCS
	        where (GROUP_ID = GroupID) and (LINE=:NEW.LINE-1);
      exception
        -- ���� ����� ������ ���, �� ������ ���������.
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_DOCS_iu. '||
            '������ ��������� 2 !');
      end;
    end if;    
  end if;
  -- ���� ������� ������ ����� ������� ��� ��������� ������ ������ �����
  -- ��������� (����������� ������� ��������� ��������� �� ��� ��������),
  -- �� �����.
  if   G.EQ(PrevID, :OLD.PREV_ID) 
    OR G.EQ(PrevID, :OLD.ID)  
  then 
    return; 
  end if;
  -- ������� ������������� ��������, ��� ����������� �� �������,
  -- ������������� ������� �� ����� ������������ ��� ����� ������.
  begin
    select ID into OLD_Referancer from SP.DOCS 
      where G.S_EQ(PREV_ID,PrevID)=1
        and (GROUP_ID = GroupID);
  exception
    -- ���� ����� ������ ���, �� ���������� ������� ��������� � ����� ������.
    when no_data_found then OLD_Referancer:=null;
  end;
  -- ������� ������������� ���������, ����������� �� ������� ��������,
  -- � ������ ����� ����� ��������� ������ �������� ���������.
  begin
    select ID into BACK_Referancer from SP.DOCS 
      where G.S_EQ(PREV_ID, :OLD.ID)=1 
        and (GROUP_ID = GroupID);
  exception
    -- ���� ����� ������ ���, �� ������� ������ ���� ���������.
    when no_data_found then
      BACK_Referancer := null;
  end;
  -- ���������� ������.
  case
    -- ���������� ������� ��������� ������ � �����.
    when (OLD_Referancer is null) and (BACK_Referancer is null) then return;    
    -- ������� ������ ���� ���������.
    when BACK_Referancer is null then
	    update SP.DOCS
	      set PREV_ID = case ID
	                      when :OLD.ID then PrevID
	                      when OLD_Referancer then :OLD.ID
	                    end
	      where ID in (:OLD.ID, OLD_Referancer);
    -- ������ ����������� � �����.
    when OLD_Referancer is null then
	    update SP.DOCS
	      set PREV_ID = case ID
	                      when :OLD.ID then PrevID
	                      when BACK_Referancer then :OLD.PREV_ID
	                    end
	      where ID in (:OLD.ID, BACK_Referancer);
  else
     -- �������� ����� ������. �������������� ��� ������.
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
  -- ������ ��� ������� �������� ��������� ��������� � ���������� ������
  -- ��������������� ���������.
  -- ������� ��������, ����������� �� ���������.
  begin
    select ID into tmpVar FROM SP.DOCS where PREV_ID=:OLD.ID;
    --d('next_ID = '||tmpVar,'V_DOCS_id');
  exception
   -- ���� ������ ��������� ���, �� ��� �������� - ���������.
   -- ������� �������� � �������� ������.
   when no_data_found then
	    delete from SP.DOCS where ID=:OLD.ID;
     return;
  end;
  -- ������� ����� ������ � ������.
  select count(*) into tmpVar from SP.DOCS  
    where GROUP_ID  = :OLD.GROUP_ID;
  --d('line count = '||tmpVar,'V_DOCS_id');
  -- ������� ������������� ���������� ���������.  
  select ID into MaxRowID from SP.V_DOCS 
   where (line = tmpVar) and (GROUP_ID  = :OLD.GROUP_ID);
  --d('MaxRowID = '||MaxRowID,'V_DOCS_id');
  -- � ���������� ��������� �������� ������, ����������� �� ���������� ��������
  -- �� ��������� ������������� ���������� ��������� (����� �� ��������
  -- ������������ �����������),
  -- � � ��������� ������������ �� ��������� �������� ������, �� ������,
  -- ������ ������, ������� ���� � ���������� ���������.
  --d(':OLD.ID = '||:OLD.ID,'V_DOCS_id');
  --d(':OLD.PREV_ID = '||:OLD.PREV_ID,'V_DOCS_id');
  -- ��� �������� ���������� ���������� ����� ���������� ��������,
  -- ����� ���� :OLD.PREV_ID ��� �� ���������, 
  -- ��������� ����� ���� �������� ��� ���������� ������������� �����
  -- �������.
  -- ������� ������ ������.
  select PREV_ID into OldPrevID from SP.DOCS where ID = :OLD.ID;
  update SP.DOCS
    set PREV_ID = case ID
                    when :OLD.ID then MaxRowID
                    when tmpVar then OldPrevID
                  end
    where ID in (:OLD.ID, tmpVar);
  -- ������� �������� � �������� ������.
  --d('ID'||to_char(:OLD.ID),'V_DOCS_id');
  delete from SP.DOCS where ID=:OLD.ID;
END;
/

-- end of File 
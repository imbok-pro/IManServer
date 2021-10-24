-- ������� VIEWS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.10.2010
-- update 17.11.2010 23.11.2010 29.11.2010 08.12.2010 23.08.2011 31.05.2013
--        09.06.2013 08.06.2014 13.06.2014 17.06.2014 30.08.2014 23.10.2014
--        28.10.2014 19.03.2015 22.03.2015 23.03.2015 25.03.2015 30.03.2015
--        20.04.2015-23.04.2015 16.05.2015 10.06.2015 08.07.2015 14.07.2015
--        20.08.2015 26.08.2015 14.09.2015 17.09.2015 08.10.2016 17.10.2016
--        19.10.2016 26.07.2017 29.08.2017 25.09.2017 08.05.2018 09.09.2021
--        13.09.2021 29.09.2021
--
-- ���������� ���������. 
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBAL_PAR_S_ii
INSTEAD OF INSERT ON SP.V_GLOBAL_PAR_S
-- (SP-Instead.trg)
DECLARE
	NEW_VALUE TVALUE;
  GP SP.TGPAR;
  str_err VARCHAR2(500):='';
  new_r_only NUMBER;
  new_group_id NUMBER;
BEGIN
  -- �������� ���������� ������������ �����.
  if :NEW.NAME is null then
    str_err := '�� ������ ��� ��������� ';
  end if;  
  if :NEW.TYPE_ID is null or :NEW.TYPE_NAME is null then
    str_err := str_err||'�� ����� ��� ��������� ';
  end if;  
  if :NEW.COMMENTS is null then
    str_err := str_err||'�� ����� ����������� ';
  end if;  
  if str_err <> '' then
   raise_application_error(-20033,'SP.V_GLOBAL_PAR_S_ii '||str_err||'!');
  end if;
  -- ���� ��� ��������� ����� � ���� ������.
  if :NEW.TYPE_NAME is not null then 
	  NEW_VALUE:=TVALUE(:NEW.TYPE_NAME);
	else
    -- ���� ��� ��������� ����� ��������������� ����.
    NEW_VALUE:=TVALUE(:NEW.TYPE_ID);
	end if;
	if :NEW.REACTION is not null then
    GP:= SP.TGPAR(:NEW.NAME,NEW_VALUE);
    SP.CheckReaction(:NEW.REACTION,GP);
  end if;
  -- ��������� R_Only
    if :NEW.R_ONLY is not null then 
	  new_r_only :=SP.to_R_Only(:NEW.R_ONLY);
	else
    new_r_only :=:NEW.R_ONLY_ID;
	end if;
  -- ���� ��� ������ ������ � ���� ������.
  if :NEW.GROUP_NAME is not null then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_GLOBAL_PAR_S_ii '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ���� ����� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  SP.Str_to_Val(Str => :NEW.S_VALUE, V => NEW_VALUE, Safe => true);
  insert into SP.GLOBAL_PAR_S( 
  					ID, NAME, COMMENTS, TYPE_ID, 
  					E_VAL, N, D, S, X, Y, 
            REACTION,R_ONLY, GROUP_ID ) 
  values( NULL, :NEW.NAME, :NEW.COMMENTS, NEW_VALUE.T,
					NEW_VALUE.E, NEW_VALUE.N, NEW_VALUE.D, NEW_VALUE.S,
					NEW_VALUE.X, NEW_VALUE.Y,
   				:NEW.REACTION, new_r_only, new_group_id);
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBAL_PAR_S_iu
INSTEAD OF UPDATE ON SP.V_GLOBAL_PAR_S
-- (SP-Instead.trg)
DECLARE
	NEW_VALUE SP.TVALUE;
  GP SP.TGPAR;
  new_r_only NUMBER;
  new_group_id NUMBER;
  str_err VARCHAR2(500):='';
BEGIN
  -- �������� ������������� ������������ �����
  if :NEW.NAME is null then
    str_err := '�� ������ ��� ��������� ';
  end if;  
  if :NEW.TYPE_ID is null or :NEW.TYPE_NAME is null then
    str_err := str_err||'�� ����� ��� ��������� ';
  end if;  
  if :NEW.COMMENTS is null then
    str_err := str_err||'�� ����� ����������� ';
  end if;  
  if str_err <> '' then
   raise_application_error(-20033,'SP.V_GLOBAL_PAR_S_ii '||str_err||'!');
  end if;
  -- ���� ��� ���� �� ����, �� ��� ���������� ���.
  -- ���� ��� ���� ����, �� ������������� ���� ���������� ���.
  if :NEW.TYPE_NAME is not null then 
	  NEW_VALUE:=TVALUE(:NEW.TYPE_NAME);
	else
    NEW_VALUE:=TVALUE(:NEW.TYPE_ID);
	end if;
-------------
	if :NEW.REACTION is not null and 
  			sp.g.notUpEQ(:NEW.REACTION,:OLD.REACTION) then
    GP:= SP.TGPAR(:NEW.NAME,NEW_VALUE);
    SP.CheckReaction(:NEW.REACTION,GP);
  end if;
  -- ��������� R_Only
    if :NEW.R_ONLY is not null then 
	  new_r_only :=SP.to_R_Only(:NEW.R_ONLY);
	else
    new_r_only :=:NEW.R_ONLY_ID;
	end if;
  -- ���� ��� ������ ��������.
  if G.notEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_GLOBAL_PAR_S_iu '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ����� ���������� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  SP.Str_to_Val(Str => :NEW.S_VALUE, V => NEW_VALUE, Safe => true);
  update SP.GLOBAL_PAR_S set
	  TYPE_ID=NEW_VALUE.T,
	  E_VAL=NEW_VALUE.E,
	  N=NEW_VALUE.N,
	  D=NEW_VALUE.D,
	  S=NEW_VALUE.S,
	  X=NEW_VALUE.X,
	  Y=NEW_VALUE.Y,
		REACTION=:NEW.REACTION,
		R_ONLY= new_r_only,
    COMMENTS=:NEW.COMMENTS,
    GROUP_ID = new_group_id
	where
	  ID=:OLD.ID;
END;
/	
	
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBAL_PAR_S_id
INSTEAD OF DELETE ON SP.V_GLOBAL_PAR_S
-- (SP-Instead.trg)
BEGIN
 delete from SP.GLOBAL_PAR_S where (ID=:OLD.ID);-- and (SP_USER is null);
END;
/

-- �������� ���������� ���������� ��� �������� ������������.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBALS_ii
INSTEAD OF INSERT ON SP.V_GLOBALS
-- (SP-Instead.trg)
BEGIN
 RAISE_APPLICATION_ERROR(-20033,'SP.V_GLOBALS_II - ���������� ���������!' );
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBALS_iu
INSTEAD OF UPDATE ON SP.V_GLOBALS
-- (SP-Instead.trg)
DECLARE
  T_ID NUMBER;
	GPAR SP.TGPAR;
BEGIN
  -- ����� �������� ������ �������� ���������.
	-- ���� ������ ��������� ��������,
  if SP.G.notEQ(:NEW.S_VALUE,:OLD.S_VALUE) then  
    GPAR:=SP.TGPAR(:OLD.NAME);
    -- �� �������� ����� ��������
	  GPAR.VAL.Assign(:NEW.S_VALUE);
    -- � �������� ��� ��������.
	  GPAR.save;
	end if;
EXCEPTION
  when others then
		SP.TG.ResetFlags;
    RAISE;
END;
/	
	
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_GLOBALS_id
INSTEAD OF DELETE ON SP.V_GLOBALS
-- (SP-Instead.trg)
BEGIN
 RAISE_APPLICATION_ERROR(-20033,'SP.V_GLOBALS_id. �������� ���������!' );
END;
/

-- �������� ���������� ���������� ��� ���� �������������.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_GLOBALS_ii
INSTEAD OF INSERT ON SP.V_USERS_GLOBALS
-- (SP-Instead.trg)
DECLARE
TmpVar NUMBER;
newUser VARCHAR2(60);
BEGIN
-- ������ ������ ������������ ������ ��� ���������� ������ ������������.
-- ��� ���������� ��������� ���������� ������������ ������������� V_GLOBAL_PARS.
-- ��� ���������� ������, ���� SP_USER �������� ��� ������ ������������,
-- � ���� ������ �������� ��� ������������� ������.
  -- ���� �� ������ ��� ������������ ��� ������, �� �������.
  IF (:NEW.SP_USER is null) or (:NEW.S_VALUE is null) then 
    raise_application_error(-20033,'SP.V_USERS_GLOBALS_ii. '||
      '����� ��� ������ ������������ �� ������!');
  end if;
 -- ������, ���� ��� ��������� �� ������!
  if G.UpEQ(:NEW.NAME,'USER_PWD') then 
    begin 
      -- ���������� ������ ������������.
      -- ���� ������������ ��� ���������� � �������, �� �������� ��� ������.
      newUser := :NEW.SP_USER;
      newUser := SP.SP_USER(:NEW.SP_USER, :NEW.S_VALUE);
      d('������ ������������','SP.V_USERS_GLOBALS_ii'); 
      select ID into tmpVar from SP.GLOBAL_PAR_S where name = 'USER_PWD';
      update SP.USERS_GLOBALS set s = :NEW.S_VALUE 
        where GL_PAR_ID = tmpVar
          and SP_USER = newUser; 
      if sql%notfound then  
        insert into SP.USERS_GLOBALS(GL_PAR_ID, SP_USER, S) 
          values(tmpVar, newUser, :NEW.S_VALUE);
      end if;
    exception
      when others then
        SP.TG.ResetFlags;
        raise_application_error(-20033,'SP.V_USERS_GLOBALS_ii. '||
          '������ '||SQLERRM||' ��� ���������� ������������ '
          ||:NEW.SP_USER||'!');
    end;  
  else
    raise_application_error(-20033,'SP.V_USERS_GLOBALS_ii. '||
   '��������� ������ ������������� ����� ������ �������� ������ ������������!');
  end if;
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_GLOBALS_iu
INSTEAD OF UPDATE ON SP.V_USERS_GLOBALS
-- (SP-Instead.trg)
DECLARE
Val SP.TValue;
newUser VARCHAR2(60);
BEGIN
--  d('begin'||:OLD.SP_USER||'  '||:NEW.S_VALUE||'  '||:OLD.S_VALUE||'  '
--    ||:OLD.GL_PAR_ID,
--    'SP.V_USERS_GLOBALS_iu');
-- ���������� ��������� ����� ���������� ����� � ���������������� �� �����!
-- ���� �� ������ ��� ������ ������, �� �������.
  if :NEW.SP_USER is null then return; end if;
  -- ���� ��� ��������� USER_PWD,
  if G.UpEQ(:OLD.NAME,'USER_PWD') then
    if G.notEQ(:OLD.S_VALUE, :NEW.S_VALUE) and :NEW.S_VALUE is not null then   
      -- �� ��������� ������,
      --d(:OLD.SP_USER||'  '||:NEW.S_VALUE||'  '||:OLD.S_VALUE,
      --'SP.V_USERS_GLOBALS_iu');
      begin
        newUser := SP.SP_USER(:OLD.SP_USER, :NEW.S_VALUE); 
        update SP.USERS_GLOBALS set s = :NEW.S_VALUE 
          where GL_PAR_ID = :OLD.GL_PAR_ID
            and SP_USER = newUser; 
        if sql%notfound then  
          --d(:OLD.SP_USER||'�� ������!','SP.V_USERS_GLOBALS_iu');
          -- ������� �������� � ������ ��������.
          delete from SP.USERS_GLOBALS 
            where GL_PAR_ID = :OLD.GL_PAR_ID
              and SP_USER = :OLD.SP_USER; 
          insert into SP.USERS_GLOBALS(GL_PAR_ID, SP_USER, S) 
            values(:OLD.GL_PAR_ID, newUser, :NEW.S_VALUE);
          -- ��������� ������� � ���� ���������� ��������.
          update SP.USERS_GLOBALS set SP_USER = newUser 
            where SP_USER = :OLD.SP_USER; 
        end if;
      exception 
        when others then     
          SP.TG.ResetFlags;
          raise_application_error(-20033,'SP.V_USERS_GLOBALS_iu. '||
            '������ ��������� ������������ '||SQLERRM||'!');
      end;
    end if;
   else   
    -- d('else', 'SP.V_USERS_GLOBALS_iu');
     -- ����� ��������� ����������� ���������.
     if G.notEQ(:OLD.S_VALUE,:NEW.S_VALUE) then
     --d('update', 'SP.V_USERS_GLOBALS_iu');
       Val:=SP.TValue(:OLD.TYPE_ID,:NEW.S_VALUE);
       update SP.USERS_GLOBALS 
         set E_VAL = Val.E, N = Val.N, D = Val.D, S = Val.S, 
     				 X = Val.X, Y = Val.Y
         where GL_PAR_ID = :OLD.GL_PAR_ID and SP_USER = :OLD.SP_USER;                         
       if sql%notfound then
     --d('insert', 'SP.V_USERS_GLOBALS_iu');
         insert into SP.USERS_GLOBALS
           (GL_PAR_ID, SP_USER, E_VAL, N, D, S, X, Y ) 
           VALUES (:OLD.GL_PAR_ID, :OLD.SP_USER,
                   Val.E, Val.N, Val.D, Val.S, Val.X, Val.Y); 
       end if;
    end if;
  end if;
END;
/
	
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_GLOBALS_id
INSTEAD OF DELETE ON SP.V_USERS_GLOBALS
-- (SP-Instead.trg)
BEGIN
  if :OLD.SP_USER is null then return; end if;
  delete from SP.USERS_GLOBALS where SP_USER = :OLD.SP_USER;
END;
/

-- ����.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_ROLES_ii
INSTEAD OF INSERT ON SP.V_PRIM_ROLES
-- (SP-Instead.trg)
BEGIN
  insert into SP.SP_ROLES(NAME, COMMENTS, ORA) 
    values(:NEW.NAME,:NEW.COMMENTS,:NEW.ORA);
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_ROLES_iu
INSTEAD OF UPDATE ON SP.V_PRIM_ROLES
-- (SP-Instead.trg)
BEGIN
  UPDATE SP.SP_ROLES SET 
    COMMENTS = :NEW.COMMENTS, 
    NAME = :NEW.NAME, 
    ORA = :NEW.ORA 
    WHERE ID = :OLD.ID;
END;
/

-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_PRIM_ROLES_id
INSTEAD OF DELETE ON SP.V_PRIM_ROLES
-- (SP-Instead.trg)
BEGIN
  -- ������� ���� � ��������, ����� �������� mutating error �������.
  --!! ���������� ������� SP.MODEL_OBJECTS_air ������ ai!
  update SP.MODEL_OBJECTS mo set
    MO.USING_ROLE = null
    where MO.USING_ROLE = :OLD.ID;
  update SP.MODEL_OBJECTS mo set
    MO.EDIT_ROLE = null
    where MO.EDIT_ROLE = :OLD.ID;
  delete from SP.SP_ROLES where (ID=:OLD.ID);
  -- ������� �� �������.
  update SP.MODEL_OBJECT_PAR_STORIES set
    N = null
    where N = :OLD.ID and TYPE_ID = G.TROLE;  
END;
/

-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ROLES_ii
INSTEAD OF INSERT ON SP.V_ROLES
-- (SP-Instead.trg)
DECLARE
  tmpVar NUMBER;
  roleID NUMBER;
  roleName Sp.SP_ROLES.NAME%type;
  parentID NUMBER;
  parentName Sp.SP_ROLES.NAME%type;
BEGIN
  -- ������� ������������� ����.
  roleID := :NEW.ID;
  if :NEW.NAME is not null then
    begin
      select ID into roleID from SP.SP_ROLES where NAME = :NEW.NAME;
    exception
      -- ���� ���� ���, �� ��������� ����.
      when no_data_found then
        insert into SP.SP_ROLES(NAME) values(:NEW.NAME)
          returning ID into roleID;
    end; 
  end if;  
  if :NEW.NAME is null and roleID is not null then
    begin
      select NAME into roleName from SP.SP_ROLES where ID = roleID;
    exception
      -- ���� ���� ���, �� ������.
      when no_data_found then
        raise_application_error(-20033,'SP.V_ROLES_ii '||
          ' ���� � ��������������� '||roleID||' �� �������!');
    end;
  else
    roleName := :NEW.NAME; 
  end if;  
  -- ������� ������������� ���� ��������.
  parentID := :NEW.PID;    
  if :NEW.PARENT is not null then
    begin
      select ID into parentID from SP.SP_ROLES where NAME = :NEW.PARENT;
    exception
      -- ���� ���� ���, �� ������.
      when no_data_found then
        raise_application_error(-20033,'SP.V_ROLES_ii '||
          ' ���� '||:NEW.PARENT||' �� �������!');
    end;
  end if;
  if :NEW.PARENT is null and parentID is not null then
    begin
      select NAME into parentName from SP.SP_ROLES where ID = parentID;
    exception
      -- ���� ���� ���, �� ������.
      when no_data_found then
        raise_application_error(-20033,'SP.V_ROLES_ii '||
          ' ���� � ��������������� '||parentID||' �� �������!');
    end;
  else
    parentName := :NEW.PARENT; 
  end if;  
  -- ���� ����� �����, �� ���������. 
  if parentNAME is not null then
    insert into SP.SP_ROLES_RELS(ROLE_ID, GRANTED_ID)values(parentID, roleID);
  end if;   
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ROLES_iu
INSTEAD OF UPDATE ON SP.V_ROLES
-- (SP-Instead.trg)
DECLARE
  parentID NUMBER;
  tmpVar NUMBER;
BEGIN
  --d('ID '||:NEW.ID||' OLD.ID '||:OLD.ID||
  --' PID '||:NEW.PID||' OLD.PID '||:OLD.PID,
  --  'V_ROLES_iu');
  --d('NAME '||:NEW.NAME||' OLD.NAME '||:OLD.NAME||
  --' PARENT '||:NEW.PARENT||' OLD.PARENT '||:OLD.PARENT,
  --  'V_ROLES_iu');
  -- ���� �������������, �� �������� �������������.
  if   (:NEW.NAME is not null and :OLD.NAME is not null)
    and (:NEW.NAME != :OLD.NAME)
  then
    update SP.SP_ROLES set NAME = :NEW.NAME where ID = :OLD.ID;
  end if;
  -- ���� �������� ������, �� ��������� �����.
  if   (:NEW.PARENT is null and :OLD.PARENT is not null)
    or (:NEW.PID is null and :OLD.PID is not null)
  then
    --d('Revoke '||:OLD.ID||' from '||:OLD.PID, 'V_ROLES_iu');
    delete from SP.SP_ROLES_RELS where ID = :OLD.REL_ID;
  -- ���� ��������� ��������, �� ��������� �����.
  elsif G.NotUpEQ(:OLD.PARENT,:NEW.PARENT) or G.NotEQ(:OLD.PID, :NEW.PID) then
    -- ������� ������������� ���� ��������.
    if G.NotUpEQ(:OLD.PARENT,:NEW.PARENT) then
      begin
        select ID into parentID from SP.SP_ROLES where NAME = :NEW.PARENT;
      exception
        -- ���� ���� ���, �� ������.
        when no_data_found then
          raise_application_error(-20033,'SP.V_ROLES_iu '||
            ' ���� '||:NEW.PARENT||' �� �������!');
      end;
    else
    -- ��������� ��� ���� � ��������� ��������������� ����������.
      begin
        select ID into parentID from SP.SP_ROLES where ID = :NEW.PID;
      exception 
        when no_data_found then
          raise_application_error(-20033,'SP.V_ROLES_iu '||
            ' ���� � ��������������� '||:NEW.PID||' �� �������!');
      end;
    end if;
    if :OLD.PID is not null then
      delete from SP.SP_ROLES_RELS where ID = :OLD.REL_ID;
      --d('Revoke '||:OLD.ID||' from '||:OLD.PID, 'V_ROLES_iu');
    end if;  
    insert into SP.SP_ROLES_RELS(GRANTED_ID, ROLE_ID)values(:OLD.ID, parentID);
    --d('grant '||:OLD.ID||' to '||parentID, 'V_ROLES_iu');
  end if;  
END;
/

-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ROLES_id
INSTEAD OF DELETE ON SP.V_ROLES
-- (SP-Instead.trg)
BEGIN
  -- ���� ������������ �����, �� ������� �����, ����� ����.
  if :OLD.PARENT is not null then
    delete from SP.SP_ROLES_RELS where ID = :OLD.REL_ID;
  else
    -- ������� ���� � ��������, ����� �������� mutating error �������.
    --!! ���������� ������� SP.MODEL_OBJECTS_air ������ ai!
    update SP.MODEL_OBJECTS mo set
      MO.USING_ROLE = null
      where MO.USING_ROLE = :OLD.ID;
    update SP.MODEL_OBJECTS mo set
      MO.EDIT_ROLE = null
      where MO.EDIT_ROLE = :OLD.ID;
    delete from SP.SP_ROLES where (ID=:OLD.ID);
    -- ������� �� �������.
    update SP.MODEL_OBJECT_PAR_STORIES set
      N = null
      where N = :OLD.ID and TYPE_ID = G.TROLE;  
  end if;  
END;
/

-- ������������.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_ii
INSTEAD OF INSERT ON SP.V_USERS
-- (SP-Instead.trg)
DECLARE 
  tmpVar NUMBER;
  tmpVar1 NUMBER;
  s_U VARCHAR2(100);
BEGIN
  -- ���� ������������ ��� ����������, �� ����� ���������� ����������.
  select count(*) into tmpVar from SP.V_USERS_GLOBALS ug 
    where upper(UG.SP_USER) = upper(:NEW.SP_USER);
  if tmpVar != 0 then
    raise_application_error(-20033,'SP.V_USERS_ii. '||
      '������������ � ������ '||:NEW.SP_USER||' ��� ����������!');
  end if;  
  -- ���� ������������ ��� ����� ������������� SP, �� �� ���������� � �������,
  -- �� ����� ���������� ����������. 
  select count(*) into tmpVar from ALL_USERS a 
    where (Upper(a.USERNAME)=Upper(:NEW.SP_USER));
  if tmpVar !=0 then
    raise_application_error(-20033,'SP.V_USERS_ii. '||
      '������������ '||:NEW.SP_USER||' �������������� � �������!');
  end if;  
  d('��������� ������������', 'SP.V_USERS_ii');
  -- ��������� ������������ SP � ������� ������.
  insert into SP.V_USERS_GLOBALS(SP_USER, NAME, S_VALUE) 
    values (:NEW.SP_USER, 'USER_PWD', SP.EPSW(:NEW.PSW));
  if :NEW.SP_ROLE is not null then
    -- ��������� ,��� ���� �� ������ SP. ���� ���� ����������� � ������,
    -- �� ���������� ������. 
    select count(*) into tmpVar from SP.SP_ROLES where NAME = :NEW.SP_ROLE;
    if tmpVar = 0 then
      raise_application_error(-20033,'SP.V_USERS_ii '||
        ' ����  '||:NEW.SP_ROLE||' �� �������!');
    end if; 
    -- ��������� ������������ ����.
    d(:NEW.SP_USER||'   '||:NEW.SP_ROLE, 'SP.V_USERS_ii');
    SP.GRANT_USER_ROLE(:NEW.SP_USER, :NEW.SP_ROLE);   
  end if;  
  select SP_USER into s_U from SP.USERS_GLOBALS 
    where upper(SP_USER) = upper(:NEW.SP_USER);
  d('��������� ��������', 'SP.V_USERS_ii');
  -- ��������� �������� ������������. 
  if :NEW.COMMENTS is not null then
    select ID into tmpVar from SP.GLOBAL_PAR_S where NAME = 'USER_COMMENTS';
    insert into  SP.USERS_GLOBALS (GL_PAR_ID, SP_USER, S) 
      VALUES (tmpVar, s_U, :NEW.COMMENTS);
    d('�������� ��������', 'SP.V_USERS_ii');
  end if;
  -- ���� ������ ������������ �� ����, �� ��������� � ��������� ��������.
  if :NEW.USER_GROUP is not null then 
    select ID into tmpVar1 from SP.GLOBAL_PAR_S where NAME = 'USER_GROUP';
    select count(*) into tmpVar from SP.GROUPS where NAME = :NEW.USER_GROUP;
    if tmpVar = 0 then
      raise_application_error(-20033,'SP.V_USERS_ii '||
        ' ������  '||:NEW.USER_GROUP||' �� �������!');
    end if; 
    insert into  SP.USERS_GLOBALS (GL_PAR_ID, SP_USER, N) 
      VALUES (tmpVar1, s_U, tmpVar);
  end if;
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_iu
INSTEAD OF UPDATE ON SP.V_USERS
-- (SP-Instead.trg)
DECLARE 
tmpVar NUMBER;
BEGIN
  -- ���� ������ ������������, �� ����������.
  if (:NEW.SP_USER != :OLD.SP_USER)then
    raise_application_error(-20033,'SP.V_USERS_iu. '||
      ' ��� ������������ ������ �������� (���� �� �����������)!');
   end if;
  -- ���� ������������ �� ���������� � �������, �� ���������. 
  select count(*) into tmpVar FROM ALL_USERS a 
    where (Upper(a.USERNAME)=upper(:NEW.SP_USER));
  if tmpVar = 0 then
    -- ��������� ������������ SP � ������� ������.
    insert into SP.V_USERS_GLOBALS(SP_USER, NAME, S_VALUE) 
      values (:NEW.SP_USER, 'USER_PWD', SP.EPSW(:NEW.PSW));
  else  
    -- ���� ������ ������.
    if G.notEQ(:NEW.PSW,:OLD.PSW) and (:NEW.PSW is not null) then
      update SP.V_USERS_GLOBALS 
        set S_VALUE = SP.EPSW(:NEW.PSW)
        where NAME = 'USER_PWD'
          and upper(SP_USER) = upper(:OLD.SP_USER);
      if sql%notfound then
        select id into tmpVar from SP.GLOBAL_PAR_S where NAME = 'USER_PWD';
        insert into SP.USERS_GLOBALS(GL_PAR_ID,SP_USER,S) 
          values(tmpVar,:OLD.SP_USER, SP.EPSW(:NEW.PSW));
      end if;
    end if;
  end if;
  -- ���� �������� ����. 
  if SP.G.notEQ(:NEW.SP_ROLE,:OLD.SP_ROLE) then
    -- ������ ��������� ���� ������������ SP.
    SP.GRANT_USER_ROLE(:OLD.SP_USER, 'SP_USER_ROLE');
    if trim(:NEW.SP_ROLE) is not null then
      -- ��������� ,��� ���� �� ������ SP. ���� ���� ����������� � ������,
      -- �� ���������� ������. 
      select count(*) into tmpVar from SP.SP_ROLES where NAME = :NEW.SP_ROLE;
      if tmpVar = 0 then
        raise_application_error(-20033,'SP.V_USERS_iu '||
          ' ����  '||nvl(:NEW.SP_ROLE, 'null')||' �� �������!');
      end if; 
      -- ��������� ������������ ����.  
      SP.GRANT_USER_ROLE(:OLD.SP_USER, :NEW.SP_ROLE);
    end if;
    -- ������� ��� SP-���� ����� ����������� � "SP_USER_ROLE". 
    --d(':OLD.SP_USER '||:OLD.SP_USER, 'SP.V_USERS_iu');
    for r in (select ROLE_NAME from V_USER_ROLES 
                where USER_NAME = :OLD.SP_USER
                  and ROLE_NAME != :NEW.SP_ROLE)
    loop
      --d('revoke ROLE '||r.ROLE_NAME, 'SP.V_USERS_iu');
      if r.ROLE_NAME != 'SP_USER_ROLE' then
        SP.REVOKE_USER_ROLE(:OLD.SP_USER,r.ROLE_NAME);
      end if;  
    end loop;
  end if; 
  -- ���� �������� ����������.
  if G.notEQ(:NEW.COMMENTS,:OLD.COMMENTS)then
    update SP.V_USERS_GLOBALS 
      set S_VALUE = :NEW.COMMENTS
      where NAME = 'USER_COMMENTS'
        and upper(SP_USER) = upper(:OLD.SP_USER);
    if sql%notfound then
      select id into tmpVar from SP.GLOBAL_PAR_S where NAME = 'USER_COMMENTS';
      insert into SP.USERS_GLOBALS(GL_PAR_ID,SP_USER,S) 
        values(tmpVar,:OLD.SP_USER, :NEW.COMMENTS);
    end if;
  end if;
  -- ���� �������� ������.
  if G.notEQ(:NEW.USER_GROUP,:OLD.USER_GROUP)then
    update SP.V_USERS_GLOBALS 
      set S_VALUE = :NEW.USER_GROUP
      where NAME = 'USER_GROUP'
        and upper(SP_USER) = upper(:OLD.SP_USER);
    if sql%notfound then
      select id into tmpVar from SP.GLOBAL_PAR_S where NAME = 'USER_GROUP';
      insert into SP.USERS_GLOBALS(GL_PAR_ID,SP_USER,S) 
        values(tmpVar,:OLD.SP_USER, :NEW.USER_GROUP);
    end if;
  end if;
END;
/

-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USERS_id
INSTEAD OF DELETE ON SP.V_USERS
-- (SP-Instead.trg)
BEGIN
  SP.DROP_USER(:OLD.SP_USER);
  TG.SP_User_Deleting := true;
  delete from SP.USERS_GLOBALS 
    where G.s_Eq(SP_USER, :OLD.SP_USER) = 1;
  TG.SP_User_Deleting := true;
END;
/

-- ���� �������������.
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USER_ROLES_id
INSTEAD OF DELETE ON SP.V_USER_ROLES
-- (SP-Instead.trg)
DECLARE
S VARCHAR2(128);
cnt NUMBER;
BEGIN
   SP.REVOKE_USER_ROLE(:old.user_name,:old.role_name);
--    select count(*) into cnt from DBA_ROLE_PRIVS D, SP.SP_ROLES R 
--       where GRANTEE= upper(:old.user_name)
--       and R.NAME = D.GRANTED_ROLE;
--    if cnt > 1 then    
--      S:='REVOKE "'||:old.role_name||'" FROM "'||:old.user_name||'"';
-- 	   execute immediate(S);
--    end if;
END;
/

-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USER_ROLES_ii
INSTEAD OF INSERT ON SP.V_USER_ROLES
-- (SP-Instead.trg)
BEGIN
  SP.GRANT_USER_ROLE(:new.user_name,:NEW.ROLE_NAME);
END;
/

-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_USER_ROLES_iu
INSTEAD OF UPDATE ON SP.V_USER_ROLES
-- (SP-Instead.trg)
BEGIN
  NULL;
END;
/

-- ����.
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_TYPES_id
INSTEAD OF DELETE ON SP.V_TYPES
-- (SP-Instead.trg)
BEGIN
   delete from SP.PAR_TYPES where ID=:OLD.ID;
END;
/

-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_TYPES_ii
INSTEAD OF INSERT ON SP.V_TYPES
-- (SP-Instead.trg)
DECLARE
  NewTypeID NUMBER;
  new_group_id NUMBER;
BEGIN
  -- ���� ��� ������ ������ � ���� ������.
  if :NEW.GROUP_NAME is not null then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_TYPES_ii '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ���� ����� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
	insert into SP.PAR_TYPES
	  values(null,:NEW.IM_ID,:NEW.NAME,
    :NEW.COMMENTS,:NEW.CHECK_VAL,
	  :NEW.STRING_TO_VAL,:NEW.VAL_TO_STRING,:NEW.SET_OF_VALUES,
    new_group_id, :NEW.M_DATE, :NEW.M_USER)
    returning ID into NewTypeID;
END;
/	


-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_TYPES_iu
INSTEAD OF UPDATE ON SP.V_TYPES
-- (SP-Instead.trg)
DECLARE
  tmpVar NUMBER;
  LastID NUMBER;
  new_group_id NUMBER;
BEGIN
  -- ���� ��� ������ ��������.
  if G.notEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_TYPES_iu '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ����� ���������� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  update SP.PAR_TYPES set
    IM_ID = :NEW.IM_ID,
    NAME = :NEW.NAME,
    COMMENTS = :NEW.COMMENTS,
	  CHECK_VAL = :NEW.CHECK_VAL,
	  VAL_TO_STRING = :NEW.VAL_TO_STRING,
	  STRING_TO_VAL = :NEW.STRING_TO_VAL,
	  SET_OF_VALUES = :NEW.SET_OF_VALUES,
    GROUP_ID = new_group_id,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER
	where
	  ID=:OLD.ID;
END;
/		

-- ��������� �������������� ����.
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ENUMS_id
INSTEAD OF DELETE ON SP.V_ENUMS
-- (SP-Instead.trg)
BEGIN
	delete from SP.ENUM_VAL_S where ID=:OLD.E_ID;
END;
/
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ENUMS_ii
INSTEAD OF INSERT ON SP.V_ENUMS
-- (SP-Instead.trg)
DECLARE
	T_NAME SP.PAR_TYPES.NAME%type;
	T_ID NUMBER;
  tmpVar SP.ENUM_VAL_S.COMMENTS%type;
  new_group_id NUMBER;
BEGIN
  T_ID := :NEW.TYPE_ID;
  if :NEW.TYPE_NAME is not null then
    begin
	  select ID into T_ID
		  from SP.PAR_TYPES where upper(NAME)=upper(:NEW.TYPE_NAME);
    exception
      -- ���� ��� �� ����������, �� ������.
      when no_data_found then
        SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.V_ENUMS_ii. ���: '||:NEW.TYPE_NAME||' �� ����������!' );
    end;
	else
    begin
      select NAME into T_NAME
  	    from SP.PAR_TYPES where ID=:NEW.TYPE_ID;
      exception
      when no_data_found then
    		SP.TG.ResetFlags;
        RAISE_APPLICATION_ERROR(-20033,
          'SP.V_ENUMS_ii. ���: '||to_char(:NEW.TYPE_ID)||' �� ����������!' );
     end;
	end if;
  -- ���� ��� ������ ������ � ���� ������.
  if :NEW.GROUP_NAME is not null then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_ENUMS_ii '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ���� ����� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  --���� ����������� �������� ����������, �� ����������� ���.
  update SP.ENUM_VAL_S set
    IM_ID=:NEW.E_IM_ID,
	  N=:NEW.N,
	  D=:NEW.D,
	  S=:NEW.S,
	  X=:NEW.X,
	  Y=:NEW.Y,
    GROUP_ID = new_group_id,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER
	where (TYPE_ID=T_ID)
    and (upper(E_VAL)=upper(:NEW.E_VAL))
    returning COMMENTS into tmpVar;
  if SQL%NotFound then
		tmpVar:=:NEW.VAL_COMMENTS;
		insert into SP.ENUM_VAL_S values(
      null, :NEW.E_IM_ID, T_ID,
      :NEW.E_VAL,tmpVar,
		  :NEW.N, :NEW.D, :NEW.S, :NEW.X, :NEW.Y,
      new_group_id, :NEW.M_DATE, :NEW.M_USER);
  end if;
END;
/
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ENUMS_iu
INSTEAD OF UPDATE ON SP.V_ENUMS
-- (SP-Instead.trg)
DECLARE
  T_ID NUMBER;
  new_group_id NUMBER;
BEGIN
  if (:NEW.TYPE_NAME is null) and (:NEW.TYPE_ID is null)
	then 
    T_ID:=:OLD.TYPE_ID;
	end if;		
  if (:NEW.TYPE_NAME is null) and (:NEW.TYPE_ID is not null)
	then 
	  -- ���������, ��� ��� �������� ����������.
	  select ID into T_ID
		  from SP.PAR_TYPES where ID=:NEW.TYPE_ID;
	end if;		
  if :NEW.TYPE_NAME is not null  then 
	  -- ������� ������������ ���� ��������.
	  select ID into T_ID
		  from SP.PAR_TYPES where upper(NAME)=upper(:NEW.TYPE_NAME);
	end if;		
  -- ���� ��� ������ ��������.
  if G.notEQ(:NEW.GROUP_NAME, :OLD.GROUP_NAME) then 
	  begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper(:NEW.GROUP_NAME);
    exception
      when no_data_found then
        raise_application_error(-20033,'SP.V_ENUMS_iu '||
          ' ������ '||nvl(:NEW.GROUP_NAME, 'null')||' �� �������!');
    end;    
	else
    -- ����� ���������� ������������� ������.
    new_group_id:=:NEW.GROUP_ID;
	end if;
  update SP.ENUM_VAL_S set
    E_VAL = :NEW.E_VAL,
    IM_ID = :NEW.E_IM_ID,
    COMMENTS = :NEW.VAL_COMMENTS,
	  N = :NEW.N,
	  D = :NEW.D,
	  S = :NEW.S,
	  X = :NEW.X,
    Y = :NEW.Y,
    GROUP_ID = new_group_id,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER
	where
	  ID=:OLD.E_ID;
	-- ��������� �����������.	
EXCEPTION
  when no_data_found then
		SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
     'SP.V_ENUMS_iu. ���: '||to_char(:NEW.TYPE_ID)||' '
		 ||:NEW.TYPE_NAME||' �� ����������!' );
END;
/	
-- end of file

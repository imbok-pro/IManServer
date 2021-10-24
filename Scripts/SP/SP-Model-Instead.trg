-- T������ ��� ������������� �������.
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 13.10.2010 28.10.2010 24.11.2010 16.12.2010 12.01.2010 03.03.2011
-- 		    20.04.2011 24.11.2011 09.12.2011 15.12.2011 29.12.2011 23.03.2012
-- by Nikolay Krasilnikov
--        21.08.2013 26.08.2013 14.02.2014 27.05.2014 14.06.2014 09.10.2014
--        11.11.2014 26.11.2014 28.11.2014 31.03.2015 01.04.2015 28.10.2016
--        29.10.2016 06.03.2017 10.04.2017 09.06.2017 19.01.2018 11.11.2020
--        11.04.2021 08.07.2021 04.09.2021 08.09.2021
-- ������.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_ii
instead of insert on SP.V_MODELS
--SP-Model-Instead.trg
declare
  URole NUMBER;
begin
  if :NEW.USING_ROLE_NAME is not null then
    select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
  else
    URole := :NEW.USING_ROLE_ID;      
  end if;
  insert into SP.MODELS(NAME,COMMENTS,PERSISTENT,LOCAL, USING_ROLE)
  values(:NEW.MODEL_NAME,:NEW.MODEL_COMMENTS, :NEW.PERSISTENT, :NEW.LOCAL,
         URole);
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODELS_ii'||
      '�� ������� ���� � ������ '||:NEW.USING_ROLE_NAME||'!');             
end;
/	
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_iu
instead of update on SP.V_MODELS
--SP-Model-Instead.trg
declare
  URole NUMBER;
begin
  if :NEW.USING_ROLE_NAME is not null then
    select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
  else
    URole := :NEW.USING_ROLE_ID;      
  end if;
   update SP.MODELS 
   set NAME = :NEW.MODEL_NAME,
       COMMENTS = :NEW.MODEL_COMMENTS,
       PERSISTENT = :NEW.PERSISTENT,
       LOCAL = :NEW.LOCAL,
       USING_ROLE = UROLE
   where ID = :OLD.ID; 
exception
  when no_data_found then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODELS_iu'||
      '�� ������� ���� � ������ '||:NEW.USING_ROLE_NAME||'!');             
end;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODELS_id
instead of delete on SP.V_MODELS
--SP-Model-Instead.trg
begin
  delete from SP.MODELS where ID = :OLD.ID;
end;
/	
--*****************************************************************************
-- ������� �������.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_ii
instead of insert on SP.V_MODEL_OBJECTS
-- (SP-Model-Instead.trg)
declare
CatalogObjID NUMBER;
tmpN NUMBER;
FullName SP.COMMANDS.COMMENTS%type;
ShortName SP.MODEL_OBJECTS.MOD_OBJ_NAME%type;
URole NUMBER;
ERole NUMBER;
begin
  if SP.TG.Get_CurModel is null then
    d('�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ',
      'ERROR SP.V_MODEL_OBJECTS_ii');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
      '�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ');
  end if;
  -- ���� ������ ��� ��������� ������� � ��������, �� ������� ��������������,
  -- ����� ���������� ������������� ��������� �������.
  if :NEW.CATALOG_NAME is not null then
    begin
      if :NEW.CATALOG_GROUP_NAME is null then
        select ID into CatalogObjID from SP.OBJECTS
          where upper(NAME) = upper(:NEW.CATALOG_NAME);
      else
        select o.ID into CatalogObjID from SP.OBJECTS o, SP.GROUPS g
          where upper(o.NAME) = upper(:NEW.CATALOG_NAME)
            and upper(g.NAME) = upper(:NEW.CATALOG_GROUP_NAME);
      end if;    
    exception
        when NO_DATA_FOUND then
    	    d('��� ����������� ��������� ������� ������ ������ �� ���������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            '��� ����������� ��������� ������� ������ ������ �� ���������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
        when too_many_rows then
    	    d('��� ����������� ��������� ������� ������ ������ �� ����������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_ii');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            '��� ����������� ��������� ������� ������ ������ �� ����������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
    end;
  else
    CatalogObjID := :NEW.OBJ_ID;
    if :NEW.OBJ_ID is null then
      d('�� ������ �������� ������� ������ �� �������� ',
        'ERROR SP.V_MODEL_OBJECTS_ii');
      RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
      '�� ������ �������� ������� ������ �� ��������!');
    end if;
  end if;
 
  tmpN :=null;
  -- ���� �������� POID ��� PARENT_MOD_OBJ_ID,
  -- �� ��� ��������� �� MOD_OBJ_NAME.
  ShortName:=SP.PATHS.SHORTNAME(:New.MOD_OBJ_NAME);
  
  -- ���� ����� PARENT_MOD_OBJ_ID, �� �������� ��������.
  IF :NEW.PARENT_MOD_OBJ_ID is not null THEN
    tmpN := :NEW.PARENT_MOD_OBJ_ID;
  END IF;
  -- ���� ����� OID �������� � ������������� �������� ��� �� ��������, 
  IF (:NEW.POID is not null)  and (tmpN is null) THEN
    -- �� ������� ������ ������� ����� ID ��������.
    begin
      select ID into tmpN from SP.MODEL_OBJECTS
        where :NEW.POID = OID
          and MODEL_ID = SP.TG.Cur_MODEL_ID;
    exception when NO_DATA_FOUND then
      null;
    end;
  END IF;
  -- ���� ������������� �������� �� ������, 
  IF tmpN is null THEN
    -- �� ��������� � ������ �������������� �������� �� �����.
	  if :NEW.FULL_NAME is not null then
	    FullName:=:New.FULL_NAME;
	    ShortName:=SP.PATHS.SHORTNAME(:New.FULL_NAME);
	  elsif :NEW.PATH is not null then  
	    FullName:= SP.PATHS.NAME(:NEW.PATH,:NEW.MOD_OBJ_NAME);
	    ShortName:=SP.PATHS.SHORTNAME(:New.MOD_OBJ_NAME);
	  else 
	    -- �������� �����������, ������ ����������� � ����� ��������. 
	    tmpN := null;
      FullName := null;
	  end if;
    -- ���� ������ �� � ����� ��������,
    if FullName is not null then
		  -- �� ���� �������� ������� �� ������� �����.
		  tmpN:= SP.MO.MOD_OBJ_ID_BY_FULL_NAME(FullName);
		  if tmpN is null then
			  -- ���� �������� �����������,
	      -- �� �������� ��������������� ���� ������ ����
			  -- �������, ���������� ����������� �������.
			  -- ������������� ������ ���� ������� � ������� ����������������
        -- ��������, ��������� ������ '/' ��� ������� ����� ������.
			  for c1 in (select COLUMN_VALUE s,ROWNUM rn
			     from table (SP.SET_FROM_STRING(SP.PATHS.PATH(FullName),'/')))
			  loop
			    begin
			      -- ���� ID ������������� ������� �� ��������� � ����
			      select ID into tmpN from SP.MODEL_OBJECTS
			        where UPPER(MOD_OBJ_NAME)=UPPER(c1.s)
			          and NVL(PARENT_MOD_OBJ_ID,-1) = NVL(tmpN,-1)
			          and MODEL_ID = SP.TG.Cur_MODEL_ID;
			    exception when NO_DATA_FOUND then
			      -- ���� ID �� �������, ������������ ������ ������� 
			      -- �������� ����������� � ��������� �� ���������� IMan
			      -- #Native Object
			      insert into SP.MODEL_OBJECTS 
			        values (null, SP.TG.Cur_MODEL_ID, c1.s, null, 1, tmpN, 
                      null,null,
                      null, null, 0)
			        returning  ID into tmpN;
			    end;
			  end loop;
		  end if;
    end if;--FullName is not null  
  END IF;
  -- ������� �������������� ����� �������.
  URole := :NEW.USING_ROLE_ID;
  if :NEW.USING_ROLE_NAME is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            '���� '||:NEW.USING_ROLE_NAME||' �� �������!');
    end;  
  end if;
  ERole := :NEW.EDIT_ROLE_ID;
  if :NEW.EDIT_ROLE_NAME is not null then
    begin
      select ID into URole from SP.SP_ROLES where NAME = :NEW.EDIT_ROLE_NAME;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_ii'||
            '���� '||:NEW.EDIT_ROLE_NAME||' �� �������!');
    end;  
  end if;
  --!! �������� ��������, ��� ���������� ������������� �������� �������,
  -- ������������ � ������,
  -- ��������� � ���������� ��������������� ��������� �������.
  -- ��������� ������.
  insert into SP.MODEL_OBJECTS
    values (null, SP.TG.Cur_MODEL_ID, ShortName, :NEW.OID,
            CatalogObjID, tmpN, 
            URole, ERole,
            :NEW.M_DATE, :NEW.M_USER, 0);
  -- ��������� OID ��������, ���� ������� ���� ��������.
  if :NEW.POID is not null then
	  update SP.MODEL_OBJECTS set
	    OID = :NEW.POID
	    where ID=tmpN;
  end if;
end;
/
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_iu
instead of update on SP.V_MODEL_OBJECTS
-- ������ ������ � ������ ������� �������� ������ �� ������.
-- ��� ���������� ������, ����� �������� ����� � �������� ��������,
-- �� ���������� ��������������, ������ �� �������� � ��������� ��������,
-- � ����� �������� �������,
-- � ��������� ������ ��� ������ � ��������� ������� ����� �������.
-- (SP-Model-Instead.trg)
declare
ParentID NUMBER;
CatObj NUMBER;
NewPath SP.COMMANDS.COMMENTS%type;
NewName SP.COMMANDS.COMMENTS%type;
URole NUMBER;
ERole NUMBER;
begin
  -- 1. ���������, ����������� �� ������� ������
  if sp.tg.Cur_MODEL_ID is null then
    d('�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ',
      'ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
      '�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ');
  end if;
	if  sp.tg.Cur_MODEL_ID != :OLD.MODEL_ID then
	   RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
		   '������� ������ �� ������������� ������ ������������� ������!');
	end if;
  -- 2. ������� ��� �������.
  -- ���� �������� ��� �������, � ��� ������ ��� ���, �� ���� ��������� ���,
  -- ����� �������� ��� �� ������� �����.
  if    SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.notEQ(:NEW.MOD_OBJ_NAME, :OLD.MOD_OBJ_NAME) then
    NewName := :NEW.MOD_OBJ_NAME;
  else  
    NewName := SP.Paths.ShortName(:NEW.FULL_NAME);
  end if;  
  if NewName is null then
    d('�� ������ ��� ������� ������','ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
                                   ' �� ������ ��� ������� ������!');
  end if;
  if INSTR(NewName,'/') > 0 then
    d('��� ������� ������ '||:NEW.MOD_OBJ_NAME||
     	' ������ �� ���������!','ERROR SP.V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
      ' ��� ������� ������ '||:NEW.MOD_OBJ_NAME||' ������ �� ���������!');
  end if;
  -- 3. ������� �������� �������.
  -- ���� ������ ���� � �������, � ������ ��� � ������������� �������� 
  -- ������� ���������, �� ������� ������������� �������� �� ���� � �������.
  if    SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.EQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) 
    and SP.G.notEQ(:NEW.PATH, :OLD.PATH) 
  then
    ParentID:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(:NEW.PATH);
    NewPath:=:NEW.PATH;
  -- ���� �������� ������ �� ������������� ��������, �� ���� ��� �� ������,
  -- � ��������� ������� �������� ���� �� ������� �����. 
  elsif SP.G.EQ(:NEW.FULL_NAME, :OLD.FULL_NAME) 
    and SP.G.notEQ(:NEW.PARENT_MOD_OBJ_ID, :OLD.PARENT_MOD_OBJ_ID) 
  then
    ParentID:= :NEW.PARENT_MOD_OBJ_ID;
    NewPath:=null;
  else
    NewPath := SP.Paths.Path(:NEW.FULL_NAME);
    -- �������� ��������� ������.
    NewPath := SUBSTR(NewPath,1,LENGTH(NewPath)-1);
    ParentID:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(NewPath);
  end if;
  -- ���� ��� � �� ������� ����� ��������, �� �������� ��������������� ���� 
  -- ������ ���� �������, ���������� ����������� �������.
  -- ������������� ������ ���� ������� � ������� ���������������� ��������, 
  -- ��������� ������ '/' ��� ������� ����� ������
  if ParentID is null and NewPath is not null then 
    for c1 in (select COLUMN_VALUE s 
               from table (SP.SET_FROM_STRING(NewPath,'/')))
    loop
      begin
        -- ���� ID ������������� ������� �� ��������� � ����
        select ID into ParentID from SP.MODEL_OBJECTS
          where UPPER(MOD_OBJ_NAME)=UPPER(c1.s)
            and NVL(PARENT_MOD_OBJ_ID,-1) = NVL(ParentID,-1)
            and MODEL_ID = SP.TG.Cur_MODEL_ID;
      exception when NO_DATA_FOUND then
        -- ���� ID �� �������, ������������ ������ ������� 
        -- �������� ����������� � ��������� �� ���������� IMan
        -- #Native Object
        insert into SP.MODEL_OBJECTS 
          values (null, SP.TG.Cur_MODEL_ID, c1.s, null, 1, ParentID, 
                  null, null,
                  null, null, 0)
          returning  ID into ParentID;
      end;
    end loop; 
  end if;  
  -- 4. ������� �������� �������. 
  if :NEW.CATALOG_NAME is null and :NEW.OBJ_ID is null then
    d('�� ������ ��� ����������� ��������� ������� ������ !!',
    'ERROR V_MODEL_OBJECTS_iu');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu '||
      '�� ������ ��� ����������� ��������� ������� ������ !');
  end if;
  CatObj := :NEW.OBJ_ID;
  if   SP.G.notUpEQ(:NEW.CATALOG_NAME,:OLD.CATALOG_NAME) 
    or SP.G.notUpEQ(:NEW.CATALOG_GROUP_NAME,:OLD.CATALOG_GROUP_NAME) 
  THEN
    begin
      select o.ID into CatObj from SP.OBJECTS o, SP.GROUPS g
        where upper(o.NAME) = upper(:NEW.CATALOG_NAME)
          and upper(g.NAME) = upper(:NEW.CATALOG_GROUP_NAME);
    exception
        when NO_DATA_FOUND then
    	    d('��� ����������� ��������� ������� ������ ������ �� ���������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_iu');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
            '��� ����������� ��������� ������� ������ ������ �� ���������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
        when too_many_rows then
    	    d('��� ����������� ��������� ������� ������ ������ �� ����������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||
            ' !','ERROR SP.V_MODEL_OBJECTS_iu');
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
            '��� ����������� ��������� ������� ������ ������ �� ����������: '||
            nvl(:NEW.CATALOG_GROUP_NAME,'null')||':'||
            nvl(:NEW.CATALOG_NAME,'null')||' !');
    end;
    -- ������� ��� ��������� ������� ��� ��������� ������ �� ������ ��������.
    delete from SP.MODEL_OBJECT_PAR_S where MOD_OBJ_ID = :OLD.ID; 
  end if;
  if SP.G.notEQ(:NEW.OBJ_ID,:OLD.OBJ_ID)THEN
    -- ������� ��� ��������� ������� ��� ��������� ������ �� ������ ��������.
    delete from SP.MODEL_OBJECT_PAR_S where MOD_OBJ_ID = :OLD.ID; 
  end if;
  -- 5. ������� �������������� ����� �������.
  URole := :NEW.USING_ROLE_ID;
  if G.notUpEQ(:OLD.USING_ROLE_NAME,:NEW.USING_ROLE_NAME)then
    if :NEW.USING_ROLE_NAME is null then
      URole := null;
    else
      begin
        select ID into URole from SP.SP_ROLES where NAME = :NEW.USING_ROLE_NAME;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
              '���� '||:NEW.USING_ROLE_NAME||' �� �������!');
      end;
    end if;  
  end if;
  ERole := :NEW.EDIT_ROLE_ID;
  if G.notUpEQ(:OLD.EDIT_ROLE_NAME,:NEW.EDIT_ROLE_NAME)then
    if :NEW.EDIT_ROLE_NAME is null then
      ERole := null;
    else
      begin
        select ID into ERole from SP.SP_ROLES where NAME = :NEW.EDIT_ROLE_NAME;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_iu'||
              '���� '||:NEW.EDIT_ROLE_NAME||' �� �������!');
      end;
    end if;  
  end if;

  -- 6. ������� ����� ������ � �������.
  update SP.MODEL_OBJECTS set 
    MOD_OBJ_NAME = NewName,
    PARENT_MOD_OBJ_ID = ParentID,
    OBJ_ID = CatObj,
    OID = :NEW.OID,
    USING_ROLE = URole,
    EDIT_ROLE = ERole,
    M_DATE = :NEW.M_DATE,
    M_USER = :NEW.M_USER,
    TO_DEL = 0     
    where ID = :OLD.ID;
  -- 7. ��������� OID ��������, ���� ������� ���� ��������
  -- � �������� �������������� �� ������ ��������.
  if (:NEW.POID is not null) 
    and (:OLD.POID is null) 
    and G.notEQ(ParentID, :OLD.PARENT_MOD_OBJ_ID)  
  then
	  update SP.MODEL_OBJECTS set
	    OID = :NEW.POID
	    where ID = ParentID;
  end if;
end;
/
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECTS_id
instead of delete on SP.V_MODEL_OBJECTS
-- (SP-Model-Instead.trg)
begin
  if SP.TG.Get_CurModel is null then
    d('�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ',
      'ERROR SP.V_MODEL_OBJECTS_id');
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_id'||
      '�� ������ ������� ������! '||
      '���������� ���������� ��������������� ���������� ��������! ');
  end if;    
  if G.notEQ(SP.TG.Get_CurModel, :OLD.MODEL_ID) then
    RAISE_APPLICATION_ERROR(-20033,'SP.V_MODEL_OBJECTS_id'||
      '������ ������� ������� �� ������������� ������� ������, ��������� '||
      '������ �������������! ');
  end if;    
  --d(:OLD.ID,'SP.V_MODEL_OBJECTS_id');
  delete from SP.MODEL_OBJECTS where ID = :OLD.ID;
  --d('end','SP.V_MODEL_OBJECTS_id');
end;
/	
--*****************************************************************************
-- 
-- ��������� �������� ������.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_ii
instead of insert on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
declare
  p SP.TMPAR;
  V SP.TVALUE;
begin
-- ID, OBJ_ID, PARAM_NAME, OBJ_PAR_ID, MOD_OBJ_ID, 
-- TYPE_ID, TYPE_NAME, R_ONLY_ID, R_ONLY, VALUE_ENUM, 
-- SET_OF_VALUES, D_VAL, VAL, E_VAL, N, 
-- D, S, X, Y, ISREDEFINE, 
-- M_DATE, M_USER

-- ��� ���������� ��������� ���������� ������ ������ � ��� ���������.
if :NEW.PARAM_NAME is null or :NEW.MOD_OBJ_ID is null then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_ii'||
    '��� ���������� ��������� ���������� ������ ������ � ��� ���������!');
end if;
p:=TMPAR(:NEW.MOD_OBJ_ID, :NEW.PARAM_NAME);
if p.MP_ID is not null or p.CP_ID is not null then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_ii'||
    '�������� '||:NEW.PARAM_NAME||' ���������� � ������� � ��������������� '||
    :NEW.MOD_OBJ_ID||'!');
end if;
-- ���� ���������� �������� � ���� ������, �� ���������� ��� ����� ������ �� 
-- ��������� �����.
if :NEW.VAL is not null then
  if :NEW.TYPE_NAME is not null then
    --d('1','SP.V_MODEL_OBJECT_PARS_ii');
    V := SP.TVALUE(:NEW.TYPE_NAME,:NEW.VAL);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,:NEW.VAL);
  end if; 
-- �� �������� ����  
elsif  :NEW.E_VAL is null and :NEW.N is null and :NEW.D is null and
         :NEW.S is null and :NEW.X is null and :NEW.Y is null 
then
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME);
  else
    V := SP.TVALUE(:NEW.TYPE_ID);
  end if;  
else
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  end if; 
end if;
-- ����������� �������� � ��������� ��������.
p.VAL:=V;
p.Save;
end;
/	
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_iu
instead of update on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
declare 
V SP.TVALUE;  -- ���������������� �������� ���������
p SP.TMPAR;
begin
-- ID, OBJ_ID, PARAM_NAME, OBJ_PAR_ID, MOD_OBJ_ID, 
-- TYPE_ID, TYPE_NAME, R_ONLY_ID, R_ONLY, VALUE_ENUM, 
-- SET_OF_VALUES, D_VAL, VAL, E_VAL, N, 
-- D, S, X, Y, ISREDEFINE, 
-- M_DATE, M_USER
if :OLD.ID is not null then
  p:=TMPAR(:OLD.ID);
else
  p:=TMPAR(:OLD.MOD_OBJ_ID, :OLD.PARAM_NAME);

end if;  
-- ������������� ����� ������ ��������, ����������� � ��������� ������.
if G.notUpEQ(:NEW.PARAM_NAME, :OLD.PARAM_NAME) then
  if :OLD.OBJ_PAR_ID is not null then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_iu'||
      '������������� ����� ������ ��������, ����������� � ��������� ������!');
  end if;
  p.NAME := :NEW.PARAM_NAME;
  p.Save;    
end if;
-- �������� ��� ����� ������ ��� ���������, ������������ � ��������� ������.
if (   G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) 
    or G.notEQ(:NEW.TYPE_ID, :OLD.TYPE_ID))
 and :OLD.OBJ_ID is not null 
then
  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PARS_iu'||
  '�������� ��� ����� ������ � ���������, ������������ � ��������� ������.!');
end if;
-- ���� ���������� �������� � ���� ������, �� ���������� ��� ����� ������ �� 
-- ��������� �����.
if SP.G.notEQ(:NEW.VAL, :OLD.VAL) then
  if SP.G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) then
    V := SP.TVALUE(:NEW.TYPE_NAME, :NEW.VAL);
  else
    V := SP.TVALUE(:NEW.TYPE_ID, :NEW.VAL);
  end if; 
-- �� �������� ����  
elsif  :NEW.E_VAL is null and :NEW.N is null and :NEW.D is null and
         :NEW.S is null and :NEW.X is null and :NEW.Y is null 
then
  if :NEW.TYPE_NAME is not null then
    V := SP.TVALUE(:NEW.TYPE_NAME);
  else
    V := SP.TVALUE(:NEW.TYPE_ID);
  end if;  
else
  if SP.G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) then
    V := SP.TVALUE(:NEW.TYPE_NAME,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  else
    V := SP.TVALUE(:NEW.TYPE_ID,
                   :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
  end if; 
end if;
-- �������� ��������.
p.Save(V);
end;
/	
-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PARS_id
instead of delete on SP.V_MODEL_OBJECT_PARS
-- (SP-Model-Instead.trg)
begin
  delete from SP.MODEL_OBJECT_PAR_S where ID = :OLD.ID;
end;
/
--
-- ������� ���������� ������.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_ii
instead of insert on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
declare 
V SP.TVALUE; 
ROnly NUMBER;
CoROLE NUMBER;
MoROLE NUMBER;
ObjParID NUMBER;
TypeID NUMBER;
begin
  -- ���� ���������� ��� ���������, �� ������� ��� �������������.
  begin
    if :NEW.PAR_NAME is not null then
      select CO.EDIT_ROLE, cp.ID, CP.R_ONLY, CP.TYPE_ID, MO.EDIT_ROLE  
        into CoROLE, ObjParID, ROnly, TypeID, MoROLE  
        from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
        where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
          and MO.ID = :NEW.MOD_OBJ_ID
          and upper(CP.NAME) = :NEW.PAR_NAME;
    else
      select CO.EDIT_ROLE, cp.ID, CP.R_ONLY, CP.TYPE_ID, MO.EDIT_ROLE  
        into CoROLE, ObjParID, ROnly, TypeID, MoROLE  
        from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
        where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
          and MO.ID = :NEW.MOD_OBJ_ID
          and CP.ID = :NEW.OBJ_PAR_ID;
    end if; 
  exception
    when no_data_found then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        '�� ������ ����� ������ '||:NEW.MOD_OBJ_ID||
        ' ��� �������� '||:NEW.PAR_NAME||'('||:NEW.MOD_OBJ_ID||')!');
  end;      
  -- ���������, ��� �������� ������ ��������� �������.
  if ROnly not in(0,-1) then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
      '�������� '||:NEW.PAR_NAME||'('||:NEW.MOD_OBJ_ID||
      ') � ������ ������ '||:NEW.MOD_OBJ_ID||' �� ������ ��������� �������!');
  end if;  
  -- ���������,��� ������������ �������� ������� �������������� ���
  -- �� ����� ����� �� �������������� ������� ������
  -- � ������� �������� - ��������� ������� ������� ������.
  if not (TG.SP_Admin or  (    SP.HasUserEditRoleID(CoROLE) 
                           and (   SP.HasUserEditRoleID(MoROLE) 
                                or MoROLE is null )  )) 
  then
    raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
      '������������ ���������� ��� �������������� ������� ������ ������ '||
      :NEW.MOD_OBJ_ID||'!');
  end if;
  -- ���� ���������� ������������� ��������, �� ���������� ���,
  -- ����� ������ �� ��������� �����.
  if :NEW.VAL is null then
    begin
      V := SP.TVALUE(TypeID,
                    :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
    exception
      when others then
        d('('||:NEW.E_VAL||', '||:NEW.N||', '||:NEW.D||', '||:NEW.S||
          ', '||:NEW.X||', '||:NEW.Y||') '||SQLERRM,
           'SP.V_MODEL_OBJECT_PAR_STORIES_ii'); 
        raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
          '������ ��������'||SQLERRM||'!');                  
    end;     
  else
    -- ��������� ��� ��������.
    if G.notEQ(TypeID, :NEW.Val.T) then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        '��� �������� '||:NEW.Val.T||
        ' �� ��������� � ����� ��������� '||TypeID||'!');                  
    end if; 
    V := :NEW.VAL;
  end if; 

  -- ��������� ������� ��������� �������.  
  insert into SP.MODEL_OBJECT_PAR_STORIES
  (
  MOD_OBJ_ID,
  OBJ_PAR_ID,
  TYPE_ID,
  E_VAL,
  N,
  D,
  S,
  X,
  Y,
  M_DATE,
  M_USER
  )
  values(
  :NEW.MOD_OBJ_ID,
  ObjParID,
  TypeID,
  V.E,
  V.N,
  V.D,
  V.S,
  V.X,
  V.Y,
  nvl(:NEW.M_DATE, sysdate),
  TG.UserName
  );
end;
/  
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_iu
instead of update on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
declare 
V SP.TVALUE;  
CoROLE NUMBER;
MoROLE NUMBER;
begin
  -- ���� ������������ �� �������������, �� ������� � ��������� ����.
  if not TG.SP_Admin then
    select CO.EDIT_ROLE, MO.EDIT_ROLE  
      into CoROLE, MoROLE  
      from SP.OBJECTS co, SP.OBJECT_PAR_S cp, SP.MODEL_OBJECTS mo 
      where CO.ID = MO.OBJ_ID and CO.ID = CP.OBJ_ID
        and MO.ID = :OLD.MOD_OBJ_ID
        and CP.ID = :OLD.OBJ_PAR_ID;
    -- ���������, ��� ������������ �������� ������� �������������� �������
    -- ������ � ������� �������� - ��������� ������� ������� ������.
    if not  (    SP.HasUserEditRoleID(CoROLE) 
             and (   SP.HasUserEditRoleID(MoROLE) 
                  or MoROLE is null )  )  
    then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_iu'||
        '������������ ���������� ��� �������������� ������� ������ ������ '||
        :OLD.MOD_OBJ_ID||'!');
    end if;
  end if;    
  -- ���� �������� ������������� ��������, �� ���������� ���,
  -- ����� ������ �� ��������� �����.
  if g.EQ(:NEW.VAL, :OLD.VAL) then
    begin
      V := SP.TVALUE(:OLD.Val.T,
                    :NEW.E_VAL, :NEW.N, :NEW.D, 0, :NEW.S, :NEW.X, :NEW.Y);
    exception
      when others then
        d('('||:NEW.E_VAL||', '||:NEW.N||', '||:NEW.D||', '||:NEW.S||
          ', '||:NEW.X||', '||:NEW.Y||') '||SQLERRM,
           'SP.V_MODEL_OBJECT_PAR_STORIES_ii'); 
        raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_iu'||
          '������ ��������'||SQLERRM||'!');                  
    end;     
  else
    -- ��������� ��� ��������.
    if G.notEQ(:OLD.Val.T, :NEW.Val.T) then
      raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_ii'||
        '��� �������� '||:NEW.Val.T||
        ' �� ��������� � ����� ��������� '||:OLD.Val.T||'!');                  
    end if; 
    V := :NEW.VAL;
  end if; 
  update SP.MODEL_OBJECT_PAR_STORIES set 
    E_VAL = V.E,
    N = V.N,
    D = V.D,
    S = V.S,
    X = V.X,
    Y = V.Y,
    M_DATE = nvl(:NEW.M_DATE, sysdate),
    M_USER = TG.UserName
    where ID = :OLD.ID; 
end;
/  

--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_MODEL_OBJECT_PAR_STORIES_id
instead of delete on SP.V_MODEL_OBJECT_PAR_STORIES
--SP-Model-Instead.trg
begin
  delete from SP.MODEL_OBJECT_PAR_STORIES where ID = :OLD.ID;
--  raise_application_error(-20033,'SP.V_MODEL_OBJECT_PAR_STORIES_id'||
--        '�������� ������� �� �������������!');                  
end;
/  

--*****************************************************************************
  
-- end of File 

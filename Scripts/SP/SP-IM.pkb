CREATE OR REPLACE PACKAGE BODY SP.IM
-- IntergraphManager package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.10.2010
-- update 27.10.2010 03.11.2010 08.11.2010 16.11.2010 24.11.2010 29.11.2010
--        08.12.2010 15.12.2010 16.12.2010 03.02.2011 10.02.2011 01.03.2011
--        30.03.2011 13.04.2011 20.04.2011 12.05.2011 10.06.2011 07.09.2011
--        25.09.2011 22.10.2011 02.11.2011 25.11.2011 07.12.2011 15.12.2011
--        20.12.2011 29.12.2011 13.01.2012 17.01.2012 21.01.2012 27.01.2012
--        07.02.2012 16.03.2012 04.04.2013 08.04.2013 10.04.2013 25.08.2013
--        29.08.2013 12.09.2013 20.09.2013 30.09.2013 16.01.2014 16.02.2014
--        16.06.2014 20.06.2014 25.06.2014 27.06.2014 15.07.2014 17.07.2014
--        24.10.2014 26.10.2014 29.10.2014-04.11.2014 07.11.2014 10.11.2014
--        25.11.2014 06.01.2015 25.05.2015 11.06.2015 19.06.2015 08.07.2015
--        03.02.2016 25.02.2016 26.02.2016 29.02.2016 10.06.2016 05.07.2016
--        22.07.2016 16.02.2016 10.04.2017-11.04.2017 17.04.2017-18.04.2017
--        02.05.2017 03.05.2017 10.05.2017 26.05.2017 11.09.2017 14.09.2017
--        07.11.2017 15.11.2017 22.11.2017 01.12.2017 13.12.2017-14.12.2017
--        18.12.2017-21.12.2017 01.02.2018 16.02.2018 21.02.2018 05.03.2018
--        15.03.2018 20.03.2018 29.06.2018 28.01.2019 10.04.2019 22.04.2019
--        24.07.2019 20.08.2019 30.09.2020 01.10.2020 22.10.2020 12.11.2020
--        16.11.2020-17.11.2020 18.05.2021 27.06.2021 30.06.2021 10.07.2021
--        16.07.2021 19.07.2021 29.09.2021
AS

-------------------------------------------------------------------------------
HierarchiesRoot SP.TVALUE;

PROCEDURE PPTRIM(PP IN OUT SP.G.TMacro_Pars)
is
begin
  if PP.exists('NAME') then
    PP('NAME').S := trim(PP('NAME').S);
    PP('NAME').S := replace(PP('NAME').S, chr(10));
  end if;  
  if PP.exists('NEW_NAME') then
    PP('NEW_NAME').S := trim(PP('NEW_NAME').S);
    PP('NEW_NAME').S := replace(PP('NEW_NAME').S, chr(10));
  end if;  
  if PP.exists('PARENT') then
    PP('PARENT').S := trim(PP('PARENT').S);
    PP('PARENT').S := replace(PP('PARENT').S, chr(10));
  end if;  
  if PP.exists('NEW_PARENT') then
    PP('NEW_PARENT').S := trim(PP('NEW_PARENT').S);
    PP('NEW_PARENT').S := replace(PP('NEW_PARENT').S, chr(10));
  end if;  
end PPTRIM;

FUNCTION Set_Par(ParName in VARCHAR2, ParValue in SP.TVALUE) return VARCHAR2
is
s Varchar2(4000);
v SP.TVALUE;
PName SP.OBJECT_PAR_S.Name%type;
begin
  PName := trim(ParName);
  -- ���� ���� ������ ���� ��� ����������� ������� "GET_USER_INPUT",
  -- �� ��������� ��� ��������� ������� ������� ���������� �������.
  if (SP.M.STACK_DEPTH=0) or (CurCommand = SP.G.Cmd_Get_User_Input)
  then
    update SP.V_COMMAND_PAR_S
      set
        E = ParValue.E,
        N = ParValue.N,
        D = ParValue.D,
        S = ParValue.S,
        X = ParValue.X,
        Y = ParValue.Y,
        R_ONLY_ID = ParValue.R_ONLY
      where Name=PName;
    -- ���� �� �������� ���������, �� ��������� ���.
    if SQL%ROWCOUNT = 0 then
      insert into SP.V_COMMAND_PAR_S
      (NAME, TYPE_ID,
       E, N, D, S, X, Y, R_ONLY_ID)
      values
      (PName, ParValue.T,
       ParValue.E, ParValue.N, ParValue.D, ParValue.S, ParValue.X, ParValue.Y,
       ParValue.R_ONLY);
    end if;
  else
    -- ���� �������� ��������������, �� � ������ PP.
    PP(PName):=ParValue;
--     V:=ParValue;
--     s:=V.asString;
--     d(ParName||' '||s,'IM.Set_Par');
  end if;
  return EM;
exception
  when others then
    EM:=SQLERRM;
    d('EM='||em,'ERROR IM.Set_Par');
    return EM;
end Set_Par;

-------------------------------------------------------------------------------
FUNCTION Set_Par(ParName in VARCHAR2, ParValue in VARCHAR2) return VARCHAR2
is
tmpVar NUMBER;
begin
  select Type_ID into tmpVar from SP.V_COMMAND_PAR_S
    where upper(Name)=upper(ParName);
  return Set_Par(ParName,SP.TVALUE(tmpVar,ParValue));
exception
  when no_data_found then
    if ParName in ('SP3DTYPE', 'IS_SYSTEM', 'IS_TINY')then return EM; end if;
    EM:='�������� '||ParName||' �� ������!';
    d('EM='||EM,'ERROR IM.Set_Par');
    return EM; 
end Set_Par;

-------------------------------------------------------------------------------
FUNCTION Set_Pars(ObjectName in VARCHAR2) return VARCHAR2
is
tmpVar NUMBER;
begin
  if trim(ObjectName) is null then return EM; end if;
  select ID into tmpVar from SP.V_OBJECTS 
    where upper(FULL_NAME)=upper(ObjectName);
  return Set_Pars(tmpVar);
exception
  when no_data_found then
    EM:='������ '||nvl(ObjectName, 'null')||' �� ������!';
    d('EM='||EM,'ERROR IM.Set_Pars(2)');
    return EM;
end Set_Pars;

-------------------------------------------------------------------------------
FUNCTION Set_Pars(ObjectID in NUMBER) return VARCHAR2
is
begin
  delete SP.V_COMMAND_PAR_S;
  insert into SP.WORK_COMMAND_PAR_S
    select p.NAME, p.COMMENTS,p.R_ONLY_ID, 0, p.TYPE_ID,
           p.E, p.N, p.D, p.S, p.X, p.Y, p.V
      from SP.V_OBJECT_PAR_S p
      where p.OBJECT_ID=ObjectID;
  return EM;
exception
  when no_data_found then
    EM:='������ � ���������������'||nvl(ObjectID, 'NULL')||' �� ������!';
    d('EM='||EM,'ERROR IM.Set_Pars');
    return EM;
end Set_Pars;


-------------------------------------------------------------------------------
PROCEDURE Clear_Objects
is
begin
  OS.delete;
end Clear_Objects;

-------------------------------------------------------------------------------
PROCEDURE SET_SERVER(ModelName in VARCHAR2, ServerType in NUMBER)
is
M SP.TGPAR;
begin
  if ServerType between 0 and 2 then
    TG.Cur_SERVER:=ServerType;
  else
    raise_application_error(-20033,
      'SP.IM.SET_SERVER. ������������ �������� ServerType!');
  end if;  
  M:=SP.TGPAR('CurModel');
  M.VAL.S:=ModelName;
  M.SAVE;
end SET_SERVER;

-------------------------------------------------------------------------------
PROCEDURE SET_ROOT
is
--RootOID VARCHAR2(128);
OLD_ROOT SP.G.TMACRO_PARS;
tmpVar NUMBER;
tmpPID NUMBER;
s VARCHAR2(4000);
s1 VARCHAR2(4000);
begin
--  D('1', 'IM.SET_ROOT');
--  D('SP.M.Root '||to_.str(SP.M.Root), 'IM.SET_ROOT');
  if OS is null then
    EM:= 'ERROR in SP.IM.Set_ROOT'||
         ' ������ �� ��������!';
    return;
  end if;
  if OS.count != 1 then
    EM:= 'ERROR in SP.IM.Set_ROOT'||
         ' ������ �������� ������������!';
    return;
  end if;
  OLD_ROOT := SP.M.Root;
  SP.M.Root := OS(OS.first);
  PPTRIM(SP.M.Root);
  -- ������ ������������� ��������������� ���������.
  if not SP.M.Root.exists('NAME') then
    SP.M.Root('NAME'):= S_(''); 
  end if; 
  if not SP.M.Root.exists('PARENT') then
    SP.M.Root('PARENT'):= S_(''); 
  end if; 
  if not SP.M.Root.exists('OID') then
    SP.M.Root('OID'):= SP.TVALUE(G.TOID);
  end if;         
  if not SP.M.Root.exists('POID') then
    SP.M.Root('POID'):= SP.TVALUE(G.TOID);
  end if;  
  if not SP.M.Root.exists('PID') then
    SP.M.Root('PID'):= SP.TVALUE(G.TID);
  end if;  
  if not SP.M.Root.exists('IS_SYSTEM') then
    SP.M.Root('IS_SYSTEM'):= B_(true);
  end if;         
  if not SP.M.Root.exists('IS_TINY') then
    SP.M.Root('IS_TINY'):= B_(true);
  end if;         
  if not SP.M.Root.exists('SP3DTYPE') then
    -- ������������� ��� ��� "notDef"
    SP.M.Root('SP3DTYPE') := SP.TVALUE(sp.G.TIType,'notDef');
  end if; 
  --D('OS '||to_.str(SP.M.Root), 'IM.SET_ROOT');
  -- ���� � ������� ���������� �������� "ID" � �� ������ ����,
  -- �� �� ������ ��������� �� ���������� ������,
  -- �����������, ��� ������ ���������� � ������ ������.
  -- ���� ������ �� ����������, �� ����� ������.
  if SP.M.Root.exists('ID') then
    tmpVar := SP.M.Root('ID').N;
    --D('ID '||tmpVar, 'IM.SET_ROOT');
    -- ���� ��� ������ ��������, �� �������� ������� ������.
    if tmpVar = 1 then 
      SP.M.ROOT := SP.MO.GET_MODEL_HROOT;
      return;
    end if;
    if tmpVar > 1 then
      SP.MO.GET_MODEL_OBJECT(SP.M.Root, tmpVar, true); 
      --D('NAME '||SP.M.Root('NAME').S, 'IM.SET_ROOT');
      if SP.M.Root.count = 0 then
        EM:='ERROR in SP.IM.Set_ROOT'||
          ' ������� ������, �������� ���������� "ID="'||
            nvl(to_char(tmpVar),'null')||
          ' �� ���������� � ������!';
        SP.M.Root := OLD_ROOT;
        return;
      end if;
      --D('NEW SP.M.Root 1 '||to_.str(SP.M.Root), 'IM.SET_ROOT');
      return;
    end if;
  end if;
  if (not SP.M.Root.exists('NAME')) and (not SP.M.Root.exists('OID')) then
    EM:='ERROR in SP.IM.Set_ROOT'||
      '  � �������� ������� ����������� ��������� "NAME � "OID"!';
    SP.M.Root := OLD_ROOT;
    return; 
  end if;   
  -- ���� ��� ������ ��������, �� �������� ������� ������.
  if trim(SP.M.Root('NAME').S) = '/' then 
    SP.M.ROOT := SP.MO.GET_MODEL_HROOT;
    return;
  end if;
  --!! ����� ����� �������� ��������, �� OID ����� ��������.    
  -- ���������, ��������� �� ������������ ������ �� ���������� ������.
  -- ���� ������������ �������� POID, �� ��������� �������� PID.
  begin
    select ID into tmpVar from SP.MODEL_OBJECTS 
      where OID = SP.M.Root('POID').S
      and MODEL_ID=SP.TG.Cur_MODEL_ID;  
    SP.M.Root('PID') :=SP.TVALUE(G.TID,tmpVar);
  exception
    when no_data_found then 
      SP.M.Root('PID') := SP.TVALUE(G.TID,-1);
  end;  
--  if SP.M.Root.exists('PID') then       
--    D('3 PID'||SP.M.Root('PID').N, 'IM.SET_ROOT');
--  end if;
  -- ������ �������� "ID" ��� ������� � ���� �������� "-1".
  SP.M.Root('ID') := SP.TVALUE(sp.G.TID,-1);
--  D('4', 'IM.SET_ROOT');
  -- ���� ������ ��������, �� ������������� �����.
  if sp.G.EQ(SP.M.Root('SP3DTYPE'),HierarchiesRoot) then 
    SP.M.ROOT := SP.MO.GET_MODEL_HROOT;
    --D('NEW SP.M.Root '||to_.str(SP.M.Root), 'IM.SET_ROOT');
    return; 
  end if;
  -- ���� ������ ���������� �� ���������� ������, �� ������� ��� ID.
  -- ���� �������� ��������� ������������� �������, �� �� ���� ����������
  -- ������������� �������.
  if SP.M.Root('OID').S is not null then
    --RootOID:=SP.VAL_TO_STR(SP.M.Root('OID'));
    tmpVar:=SP.MO.MOD_OBJ_ID_BY_OID(SP.M.Root('OID').S);
  end if;
  -- ���� ������ �� ������, 
  -- �� ���� �� ������� ����� � ������ �������� �������� �������.
  if tmpVar is null then
    s :=SP.PATHS.NAME(SP.M.Root('PARENT').S,SP.M.Root('NAME').S);
    --d(s,'IM.SET_ROOT');
    s1 :=SP.PATHS.NAME(OLD_ROOT('PARENT').S,OLD_ROOT('NAME').S);
    --d(s1,'IM.SET_ROOT');
    s :=SP.PATHS.NAME(s1,s);
    --d(s,'IM.SET_ROOT');
    tmpVar:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(s);
  end if;
--  D('5', 'IM.SET_ROOT');
  -- ���� ������� ����� ������,
  -- �� ������������� ��������������� �������� ���������� "ID" � "SP3DTYPE".
  -- ����� ��� "ID" ��������� �������� "-1", a ��� "SP3DTYPE" - "notDef",
  -- ��� ������������� ���������� �������.
  if tmpVar is not null then
    SP.M.Root('ID') := SP.TVALUE(sp.G.TID,tmpVar);
    SP.MO.GET_MODEL_OBJECT(SP.M.Root, tmpVar, true);
    if tmpVar = 1 then
      SP.M.Root('SP3DTYPE') := SP.TVALUE(sp.G.TIType,'HierarchiesRoot');    
    else
      SP.M.Root('SP3DTYPE') := 
        SP.TVALUE(sp.G.TIType,SP.getMPar_E(tmpVar,'SP3DTYPE'));    
    end if; 
  else
    -- � ����� ������ ���������� �������� "PID".
    SP.M.Root('PID') := SP.TVALUE(G.TID,-1);
  end if;
  --D('NEW SP.M.Root 2 '||to_.str(SP.M.Root), 'IM.SET_ROOT');

exception
  when others then
    EM:='ERROR in SP.IM.Set_ROOT '||SQLERRM;
    SP.M.Root := OLD_ROOT;
end SET_ROOT;

-------------------------------------------------------------------------------
FUNCTION Set_ObjectPar(ObjectNum in NUMBER,
                       ParName in VARCHAR2,
                       ParValue in TValue)
return VARCHAR2
is
begin
  OS(ObjectNum)(ParName):= ParValue;
  return null;
exception
  when others then
    EM:='ERROR in SP.IM.Set_ObjectPar '||SQLERRM;
    return EM;
end Set_ObjectPar;

-------------------------------------------------------------------------------
FUNCTION START_MACRO(MacroName in VARCHAR2) return VARCHAR2
is
MacroPackageName VARCHAR2(60);
MacroID NUMBER;
MacroKind NUMBER;
tmpNum NUMBER;
tmpS VARCHAR2(4000);
begin
  -- ������� ������ ���������.
  MESSAGES.DELETE;
  -- ���� ������ �� ����, �� ������.
  if SP.M.STACK_DEPTH != 0 then
    -- !!! ����� �������� ���� ��� ��� ������ ���������?
    EM:= 'SP.IM.START_MACRO. ��������� ������ �������������� !!!';
    return EM;
  end if;
  d('Start '||MacroName,'Macro Execution');
  -- ������� ��� �������������� � � ���������� �������������.
  begin
    select 'M'||to_char(ID), ID, KIND_ID
      into MacroPackageName, MacroID, MacroKind
      from SP.V_OBJECTS where upper(FULL_NAME)=upper(MacroName);
  exception
    when no_data_found then
      EM:='SP.IM.START_MACRO. �� ������ ������ '||nvl(MacroName,'null')||'!';
    return EM;
  end;
  -- ���������, ��� ��� ������������ � ���������� ��������� - ���������.
  select count(*) into tmpNum from SP.V_COMMAND_PAR_S p
    where (p.MODIFIED = 0) and (p.R_ONLY_ID = -1);
  if tmpNum > 0 then
    tmpS:='';
    for p in (select NAME from SP.V_COMMAND_PAR_S p
                where (p.MODIFIED = 0) and (p.R_ONLY_ID = -1))
    loop
      tmpS:=tmpS ||' '||p.Name ||',';
    end loop;
    -- ������� ��������� �������.
    tmpS:= rtrim(tmpS,' ,');
    EM:='SP.IM.START_MACRO. ��������(�) => '||tmpS||' ��������� '||MacroName||
        ' ����������� ������(�) ���� ������������(���)!';
    return EM;
  end if;
  -- ���� ��� ��������, �� ��������� ����� MComposit.
  if MacroKind = SP.G.COMPOSITE_OBJ then
    -- ��������� ����.
    SP.M.PUSH('MComposit');
    -- ������������� ���������� ����� ������.
    SP_IM.MComposit.MacroID:=MacroID;
    SP_IM.MComposit.MacroName:=MacroName;
    SP_IM.MComposit.MacroPackageName:=MacroPackageName;
  else
    -- ����� ��������� ��������������, �������� ����.
    SP.M.UsedObject:=-1;
    SP.M.PUSH(MacroPackageName);
  end if;
  EM:='';
  return null;
exception
  when others then
    EM:='ERROR in SP.IM.START_MACRO '||SQLERRM;
    return EM;
end START_MACRO;

-------------------------------------------------------------------------------
FUNCTION START_MACRO(ObjectID in NUMBER) return VARCHAR2
is
begin
  return START_MACRO(SP.M.MacroName(SP.M.MacroPackage(ObjectID)));
end START_MACRO;

-------------------------------------------------------------------------------
FUNCTION get_EM return VARCHAR2
is
begin
  return EM;
end get_EM;

-------------------------------------------------------------------------------
FUNCTION get_WM return VARCHAR2
is
  tmpVar SP.COMMANDS.COMMENTS%type;
begin
  tmpVar := WM;
  WM := '';
  return tmpVar;
end get_WM;

-- ������������ ������ "SP.IM.PP � ������ ������� ���������� "IP" �������
-- ��������������. ����� ���� ������� ������ PP.
-------------------------------------------------------------------------------
procedure Copy_PP2OPa
is
begin
  d(to_.str(SP.IM.PP),'Copy_PP2OPa');                   
  execute immediate('
    begin
      SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa := SP.IM.PP;
      SP.IM.PP.delete;
    end;
                    ');
end;

-- ������������ ������ ������� ���������� "IP" ������� �������������� �
-- ������ "SP.IM.PP". ����� ���� ������� ������ ������� ���������� ������.
-------------------------------------------------------------------------------
procedure Copy_IP2PP
is
begin
  execute immediate('
    begin
      SP.IM.PP:= SP_IM.'||SP.M.WORKING_PACKAGE||'.IP;
      SP_IM.'||SP.M.WORKING_PACKAGE||'.IP.delete;
    end;
                    ');
  d(to_.str(SP.IM.PP),'Copy_IP2PP');                   
end;

-------------------------------------------------------------------------------
FUNCTION get_COMMAND return NUMBER
is
SQL_S VARCHAR2(256);
tmpS  SP.COMMANDS.COMMENTS%type;
tmpVar NUMBER;
tmpP SP.OBJECT_PAR_S.NAME%type;
notID boolean;
notOID boolean;
notName boolean;
--**************
begin
 -- ���������� CurCommand ��� ������� ��������� ����� ��������� ��������
 -- ���������� �������. ����� ������ ���������� ��� ���������� � ����,
 -- ���� ��� ������������� �� ����������.
 -- ���� ���������� ������� �� ����, �� ���������� ��������,
 -- ����������� ���������� �������.
  if CurCommand is not null then
    case CurCommand
      when SP.G.Cmd_Rename then
        -- ���� ������� Rename, �� ��� ��������, ��� ��������
        -- ����� RENAMED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.RENAMED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_Change_Parent then
        -- ���� ������� Change_Parent, �� ��� ��������, ��� ��������
        -- ����� RENAMED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.RENAMED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_Update_Notes then
        -- ���� ������� Update_Notes, �� ��� ��������, ��� ��������
        -- ����� NOTES_UPDATED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.NOTES_UPDATED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_DELETE_OBJECT then
        -- ���� ������� DELETE_OBJECT, �� ��� ��������, ��� ��������
        -- ����� DELETED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.DELETED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_CREATE_OBJECT then
        -- ���� ������� CREATE_OBJECT, �� ��� ��������, ��� ��������
        -- ����� INSERTED ��� UPDATED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.INSERTED ��� SP.IM.UPDATED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_COMPOSITE_ORIGIN then
        -- ���� ������� COMPOSITE_ORIGIN, �� ��� ��������, ��� ��������
        -- ����� INSERTED ��� UPDATED �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.INSERTED ��� SP.IM.UPDATED!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_Reload_Model then
        -- ���� ������� Reload_Model, �� ��� ��������, ��� ��������
        -- ����� Model_Reloaded �� ������� ������� ����������.
        EM:= '�������� ����� SP.IM.Model_Reloaded!';
        return SP.G.Cmd_CANCEL;
      when SP.G.Cmd_GET_OBJECTS then
        -- ���� ������� GET_OBJECTS, �� ��������� ������ OBJECTS
        -- ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OBJECTS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_Get_Full_Objects then
        -- ���� ������� GET_FULL_OBJECTS, �� ��������� ������ OBJECTS
        -- ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OBJECTS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_GET_SYSTEMS
      then
        -- ���� ������� GET_SYSTEMS,
        -- �� ��������� ������ SYSTEMS ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.SYSTEMS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_GET_ALL_SYSTEMS
      then
        -- ���� ������� SP.G.Cmd_GET_ALL_SYSTEMS,
        -- �� ��������� ������ SYSTEMS ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.SYSTEMS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_GET_ALL_OBJECTS
      then
        -- ���� ������� SP.G.Cmd_GET_ALL_OBJECTS,
        -- �� ��������� ������ OBJECTS ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OBJECTS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_GET_ALL_FULLOBJECTS
      then
        -- ���� ������� SP.G.Cmd_GET_ALL_FULLOBJECTS,
        -- �� ��������� ������ OBJECTS ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OBJECTS := SP.IM.OS; end;');
        OS.Delete;
      when SP.G.Cmd_GET_SELECTED then
        -- ���� ������� GET_SELECTED,
        -- �� ��������� ������ SELECTED ������� ��������������.
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.SELECTED := SP.IM.OS;end;');
        OS.Delete;
      when SP.G.Cmd_Execute then
        -- ���� ������� EXECUTE,
        -- �� ��������� ������ OPa ������� ��������������.
        Copy_PP2OPa;
        PP.Delete;
      when SP.G.Cmd_Is_Object_Exist then
        -- ���� ������� Is_Object_Exist,
        -- �� ��������� ������ OPa ������� ��������������.
        Copy_PP2OPa;
        PP.Delete;
      when SP.G.Cmd_Get_Pars then
        -- ���� ������� GET_PARS,
        -- �� ��������� ������ OPa ������� ��������������.
        Copy_PP2OPa;
        PP.Delete;
      when SP.G.Cmd_GET_USER_INPUT then
        -- E��� ������� GET_USER_INPUT,
        -- �� ������������ ���������� ��������� � ������ Opa �
        -- ��������� ������ SELECTED ������� ��������������.
        PP.delete;
        -- ���������, ��� ��� ������������ � ���������� ��������� - ���������.
        select count(*) into tmpVar from SP.V_COMMAND_PAR_S p
          where (p.MODIFIED = 0) and (p.R_ONLY_ID = -1);
        -- ���� ���� ������������ ���������, �� ���������� �������������� �
        -- ��������� �������.
        if tmpVar > 0 then
	        tmpS:='';
	        for p in (select NAME from SP.V_COMMAND_PAR_S p
	                    where (p.MODIFIED = 0) and (p.R_ONLY_ID = -1))
	        loop
	          tmpS:=tmpS ||' '||p.Name ||',';
	        end loop;
	        -- ������� ��������� �������.
	        tmpS:= rtrim(tmpS,' ,');
	        WM:='��������(�) => '||tmpS||
	          ' ����������� ������(�) ���� ������������(���)!';
	        return SP.G.Cmd_GET_USER_INPUT;
        end if;
        -- ��������� ������ ����������.
        for p in (select NAME, TYPE_ID, E_VAL, N, D, S, X, Y
                  from SP.WORK_COMMAND_PAR_S order by NAME)
        loop
          PP(p.NAME):=SP.TVALUE(p.TYPE_ID, p.E_VAL,
                                p.N, p.D,
                                case when p.D is null then 1 else 0 end,
                                p.S, p.X, p.Y);
        end loop;
        execute immediate('
          begin
            SP_IM.'||SP.M.WORKING_PACKAGE||'.SELECTED:= SP.IM.OS;
            SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa:= SP.IM.PP;
          end;
                          ');
        OS.Delete;
        PP.delete;
    else
      null;
    end case;
  end if;
  -- ���������� ���������� ������� ��������������.
<<GET_NEXT_COMMAND>>
  -- ���� ���� �������� ����, �� ���������� ������.
  if SP.M.STACK_DEPTH=0 then
    raise_application_error(-20033,
      'SP.IM.get_COMMAND. ���� ������� ����!');
  end if;
  SQL_S:='
    begin
      :1:=SP_IM.'||SP.M.WORKING_PACKAGE||'.get_command;
    end;
         ';
  begin
    execute immediate(SQL_S) using out CurCommand;
    -- � ������ ������ ����������, ��������� ���� � ���� ������ � ��.
  exception
    when others then
      EM:=SQLERRM||' STACK=>'||SP.M.GET_STACK_asString||'!';
      d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
      return SP.G.Cmd_CANCEL;
  end;
  -- ��������� ��������� �������� � ����������� �� ���� �������.
  case
-- Cmd_CANCEL
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_CANCEL then
      -- ���� ��������� ������� Cancel, �� ������� ���� ��������.
      SP.M.CLEAR_STACK;
      -- ������� ������� Im.
      d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
      rollback;
      return CurCommand;

-- Cmd_RETURN
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_RETURN then
      -- ���� ������� ����� ������ �������, �� ��������� ������� ����� �
      -- �������� ��������� �������,
      if SP.M.STACK_DEPTH > 1 then
        SP.M.POP;
      else
        -- ���� ������� ����� ����� 1, �� ������� ������� Iman.
        d('Cmd_RETURN EM=>'||EM,'Macro Execution');
        commit;
        return CurCommand;
      end if;

-- Cmd_Calculate, Cmd_CASE, Cmd_GO_TO, Cmd_WHEN_OTHERS_END_CASE, Cmd_DECLARE,
-- Cmd_DECLARE_F, Cmd_FOR_PARS_IN, Cmd_FOR_OBJECTS, Cmd_FOR_SYSTEMS,
-- Cmd_FOR_SELECTED, Cmd_FUNCTION
-------------------------------------------------------------------------------
    when CurCommand
      in (SP.G.Cmd_Calculate, SP.G.Cmd_CASE, SP.G.Cmd_GO_TO,
          SP.G.Cmd_WHEN_OTHERS_END_CASE,
          SP.G.Cmd_DECLARE, SP.G.Cmd_DECLARE_F,
          SP.G.Cmd_FOR_PARS_IN, SP.G.Cmd_FOR_OBJECTS,
          SP.G.Cmd_FOR_SYSTEMS, SP.G.Cmd_FOR_SELECTED,
          SP.G.Cmd_FUNCTION)
    then
      -- ���� �������� ������������ �������,
      -- �� �������������� ������ ���������.
      EM:='������ ���������, �������� ������������ ������� '||
          nvl(to_char(CurCommand),'null')||'!';
      d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
      return SP.G.Cmd_CANCEL;

-- Cmd_EXECUTE_MACRO
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_EXECUTE_MACRO then
      -- ���� ��������� ������� EXECUTE_MACRO,
      -- �� ��������� �������������� (����������� ��������� �������),
      -- �� ��������� ���� ����� � IMan.
      null;

-- Cmd_EXECUTE
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_EXECUTE then
      -- �������� ���������.
      Copy_IP2PP;
      -- ������� ������ OPa.
      execute immediate
        ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa.delete; end;');
      -- ��������� ��������, ��������� ������� IMan.
      d('Cmd_EXECUTE ID=>'||SP.M.UsedObject||' EM=>'||EM,
      'Macro Execution');
      return CurCommand;

    
-- Cmd_COMPOSITE_ORIGIN
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_COMPOSITE_ORIGIN then
      EM:=null;
      -- �������� ���������.
     execute immediate('
       begin
         SP.IM.PP:= SP_IM.'||SP.M.WORKING_PACKAGE||'.IP;
       end;
                        ');
      notID := case when PP.exists('ID') then PP('ID').N is null
               else true end;  
      notOID := case when PP.exists('OID') then PP('OID').S is null
                else true end;  
      notName := case when PP.exists('NAME') then PP('NAME').S is null
                 else true end;  
      -- ��������� ������� ��������� "NAME" �� null, ���� ��������� "ID" 
      -- ��� "OID" ����������� ��� ����).     
      if notName and notID and notOID then
        EM:='�������� "NAME" ���� "ID"("OID")'||
            '����������� ��� �� ��������� ��� ���������� �������'||
            ' SP.G.Cmd_COMPOSITE_ORIGIN';
        return SP.G.Cmd_CANCEL;
      end if;     
      if EM is not null then
         EM:=EM||' STACK=>'||SP.M.GET_STACK_asString||'!';
         d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
         return SP.G.Cmd_CANCEL;
      end if;
      -- ������� �������� "OLD_NAME" 
      -- ��� �������������� ��������� ����� ���� ����������� �������
      -- "Rename".
      PP.delete('OLD_NAME');
      -- ������ ������� �������.
      PP('SP3DTYPE'):=SP.TVALUE(SP.G.TIType,'GenericSystem');
      -- ��������� � ���������� ������� ������� ��������� ������� ���������
      -- � ��� ��� ��������� ����� ���������� ���� ����������.
      PP('OBJECT_KIND'):=SP.TVALUE(SP.G.TNOTE,'COMPOSIT');
      PP('Used_Object') := SP.TVALUE(SP.G.TUsed_Object,'#Composit Origin');
      tmpVar:=SP.M.UsedObject;
      -- d(to_char(tmpVar),'add Composit notes');
      PP('OBJECT_CLASS'):=
        SP.TVALUE(SP.G.TNOTE,SP.M.MacroName(SP.M.MacroPackage(tmpVar)));
      for p in (select NAME, V from SP.V_OBJECT_PAR_S
                  where OBJECT_ID=tmpVar and TYPE_ID<>SP.G.TNote)
      loop
        if PP.exists(p.NAME) then
          PP('P_'||p.NAME):=SP.TVALUE(SP.G.TNOTE,PP(p.NAME).asString);
        else
          PP('P_'||p.NAME):=SP.TVALUE(SP.G.TNOTE,p.V);
        end if;
        -- d(p.NAME||' '||PP('P_'||p.NAME).S,'add Composit notes');
      end loop;
      -- ������������� ������ �� ������.
      SP.M.UsedObject:=0;
      -- ������� ������ OPa.
      execute immediate
        ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa.delete; end;');
      -- ������ �������, ��������� IMan ������� ������� ������.
      d('Cmd_CREATE_OBJECT UsedObjectID=>'||SP.M.UsedObject||' EM=>'||EM,
      'Macro Execution');
      return SP.G.Cmd_CREATE_OBJECT;

-- Cmd_CREATE_OBJECT
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_CREATE_OBJECT then
      -- �������� ���������.
      Copy_IP2PP;
      notID := case when PP.exists('ID') then PP('ID').N is null
               else true end;  
      notOID := case when PP.exists('OID') then PP('OID').S is null
                else true end;  
      notName := case when PP.exists('NAME') then PP('NAME').S is null
                 else true end;  
      -- ��������� ������� ��������� "NAME" �� null, ���� ��������� "ID" 
      -- ��� "OID" ����������� ��� ����).     
      if notName and notID and notOID then
        EM:='�������� "NAME" ���� "ID"("OID")'||
            '����������� ��� �� ��������� ��� ���������� �������'||
            ' SP.G.Cmd_CREATE_OBJECT';
        return SP.G.Cmd_CANCEL;
      end if;     
      -- ���� ������������ �������� "OLD_NAME" ��� "OID"("ID"), �� ���������,
      -- ��� ��� ����� - ������� �����.
      if (PP.exists('OLD_NAME') or  PP.exists('OID') or  PP.exists('ID')) then
        if (PP.exists('OLD_NAME') and (instr(PP('OLD_NAME').asString,'/') > 0))
          or (PP.exists('NAME') and (instr(PP('NAME').asString,'/') > 0))
        then
          EM:='���� � ������� "CREATE_OBJECT" �������� ��������'||
              '"OLD_NAME" ��� "OID"("ID"),'||
              ' �� ��� ���������: "OLD_NAME" � "NAME"'||
              '�� ������ ��������� "/"'||
              ' STACK=>'||SP.M.GET_STACK_asString||'!';
          d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
          return SP.G.Cmd_CANCEL;
        end if;
      end if;
      -- ��������� ������� ��������� ������� ��� ������ IMan.
      PP('OBJECT_KIND'):=SP.TVALUE(SP.G.TNOTE,'SINGLE');
      declare
      s varchar2(4000);
      begin
        -- ��������� ��� ������� �� ������ ��������.
        PP('Used_Object') := 
          SP.TVALUE(SP.G.TUsed_Object, SP.M.ObjectFullName(SP.M.UsedObject, s));
        PP('OBJECT_CLASS'):= SP.TVALUE(SP.G.TNOTE, s);
      end;
      -- ������� ������ OPa.
      execute immediate
        ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa.delete; end;');
      -- ������ ������, ��������� ������� IMan.
      d('Cmd_CREATE_OBJECT UsedObjectID=>'||SP.M.UsedObject||' EM=>'||EM,
      'Macro Execution');
      return CurCommand;

-- Cmd_Model3D_COMMIT
-- Cmd_Toggle_Server
-- Cmd_Set_GPars_Vals
-- Cmd_Set_Pars
-------------------------------------------------------------------------------
    when CurCommand in (SP.G.Cmd_Model3D_COMMIT,
                        SP.G.Cmd_Toggle_Server,
                        SP.G.Cmd_Set_GPars_Vals,
                        SP.G.Cmd_Set_Pars)
    then
      -- �������� ���������.
      Copy_IP2PP;
      -- ������� ������� IMan.
      d('Cmd_'||SP.to_str_CMD(CurCommand),'Macro Execution');
      return CurCommand;

-- Cmd_GET_SELECTED
-------------------------------------------------------------------------------
    when CurCommand = SP.G.Cmd_GET_SELECTED
    then
      -- �������� ���������.
      Copy_IP2PP;
      if not PP.exists('MESSAGE') then
        PP('MESSAGE') := S_('�������� �������!');
      end if;
      -- ������� ������� IMan.
      d('Cmd_'||SP.to_str_CMD(CurCommand),'Macro Execution');
      return CurCommand;

-- Cmd_Model3D_Rollback
-- Cmd_Model3D_Refresh
-- Cmd_Model3D_Flush
-- Cmd_Clear_Selected
-------------------------------------------------------------------------------
    when CurCommand in( SP.G.Cmd_Model3D_Refresh,
                        SP.G.Cmd_Model3D_Rollback,
                        SP.G.Cmd_Model3D_Flush,
                        SP.G.Cmd_Clear_Selected)
    then
      -- ������� ������� IMan.
      d('Cmd_'||SP.to_str_CMD(CurCommand),'Macro Execution');
      return CurCommand;

-- Cmd_PLAY
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_PLAY then
      -- �������� ���������.
      Copy_IP2PP;
      -- ���������, ��� ��������� ��������� NAME � REPETITIONS.
      -- ������������� �������� �� ���������, ���� �������� �����������.
      if not PP.EXISTS('NAME') then
        PP('NAME'):=SP.TVALUE(SP.G.TBeep,'Beep');
      end if;
      if not PP.EXISTS('REPETITIONS') then
        PP('REPETITIONS'):=SP.TVALUE(SP.G.TInteger,'1');
      end if;
      d('Cmd_PLAY NAME=>'||PP('NAME').asString,'Macro Execution');
      return CurCommand;

-- Cmd_Change_Parent
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_Change_Parent then
      -- �������� ���������.
      Copy_IP2PP;
      -- ���������, ��� ��������� ��������� NAME ��� OID(ID) � NEW_PARENT
      -- ��� NEW_POID(NEW_PID).
      if not (PP.EXISTS('NAME') or PP.EXISTS('OID') or PP.EXISTS('ID'))then
        EM:='� ������� "Change_Parent"'||
            ' ����������� ������������ �������� "NAME" ��� "OID"("ID"), '||
            ' STACK=>'||SP.M.GET_STACK_asString||'!';
        d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
        return SP.G.Cmd_CANCEL;
      end if;
      if not (PP.EXISTS('NEW_PARENT') 
           or PP.EXISTS('NEW_POID') or PP.EXISTS('NEW_PID')) 
      then
        EM:='� ������� "CHANGE_PARENT"'||
            ' ����������� ������������ �������� "NEW_PARENT"'||
            ' ��� "NEW_POID"("NEW_PID"), '||
            ' STACK=>'||SP.M.GET_STACK_asString||'!';
        d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
        return SP.G.Cmd_CANCEL;
      end if;
      
      d('Cmd_CHANGE_PARENT=>'||
         case
           when PP.EXISTS('NAME') then PP('NAME').asString
           when PP.EXISTS('OID') then PP('OID').asString
           when PP.EXISTS('ID') then PP('ID').asString
         end
        ||','
        ||
         case
           when PP.EXISTS('NEW_PARENT') then PP('NEW_PARENT').asString
           when PP.EXISTS('NEW_OID') then PP('NEW_OID').asString
           when PP.EXISTS('NEW_ID') then PP('NEW_ID').asString
         end
        ,'Macro Execution');
      return CurCommand;

-- Cmd_Rename
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_Rename then
      -- �������� ���������.
      Copy_IP2PP;
      -- ���������, ��� ��������� ��������� NAME ��� OID(ID) � NEW_NAME.
      if    not (PP.EXISTS('NAME') or PP.EXISTS('OID') or PP.EXISTS('ID'))then
        EM:='� ������� "Rename"'||
            ' ����������� ������������ �������� "NAME" ��� "OID"("ID"), '||
            ' STACK=>'||SP.M.GET_STACK_asString||'!';
        d('Cmd_Rename Cancel EM=>'||EM,'Macro Execution');
        return SP.G.Cmd_CANCEL;
      end if;
      if not PP.EXISTS('NEW_NAME') then
        EM:='� ������� "Rename"'||
            ' ����������� ������������ �������� "NEW_NAME"'||
            ' STACK=>'||SP.M.GET_STACK_asString||'!';
        d('Cmd_Rename Cancel EM=>'||EM,'Macro Execution');
        return SP.G.Cmd_CANCEL;
      end if;
      d('Cmd_Rename NAME=> '||
        case when PP.exists('NAME') then PP('NAME').S else 'null' end||
        ', OID =>'||
        case when PP.exists('OID') then PP('OID').S else 'null' end||
        ', NEW_NAME=>'||PP('NEW_NAME').asString,'Macro Execution');
      return CurCommand;


-- Cmd_SET_ROOT
-- Cmd_GET_OBJECTS
-- Cmd_GET_FULL_OBJECTS
-- Cmd_GET_PARS
-- Cmd_GET_SYSTEMS
-- Cmd_IS_OBJECT_EXIST
-- Cmd_GET_ALL_SYSTEMS
-- Cmd_GET_ALL_OBJECTS
-- Cmd_GET_ALL_FULLOBJECTS
-- Cmd_DELETE_OBJECT
-- Cmd_UPDATE_NOTES
-- Cmd_Reload_Model
-------------------------------------------------------------------------------
    when CurCommand
      in (SP.G.Cmd_SET_ROOT,
          SP.G.Cmd_GET_OBJECTS,
          SP.G.Cmd_UPDATE_NOTES,
          SP.G.Cmd_DELETE_OBJECT,
          SP.G.Cmd_GET_FULL_OBJECTS,
          SP.G.Cmd_GET_PARS,
          SP.G.Cmd_GET_SYSTEMS,
          SP.G.Cmd_GET_ALL_SYSTEMS,
          SP.G.Cmd_GET_ALL_OBJECTS,
          SP.G.Cmd_GET_ALL_FULLOBJECTS,
          SP.G.Cmd_Is_Object_Exist,
          SP.G.Cmd_Reload_Model)
    then
      -- �������� ���������.
      Copy_IP2PP;
      -- ���� ������� Cmd_GET_PARS ��� Cmd_Is_Object_Exist,
      -- �� ������� ������ OPa.
      if CurCommand in(SP.G.Cmd_GET_PARS,
                       SP.G.Cmd_Is_Object_Exist)
      then
        execute immediate
          ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OPa.delete; end;');
      end if;
      -- ��������� ������������� ���������������� ��������� "NAME" 
      -- ��� "OID"("ID").
      if not (PP.EXISTS('NAME') or PP.EXISTS('OID') or PP.EXISTS('ID')) then
        EM:='� ������� '||SP.to_str_cmd(CurCommand)||
            ' ����������� ������������ ��������'||
            '"NAME" ��� "OID"'||' STACK=>'||SP.M.GET_STACK_asString||'!';
        d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
        return SP.G.Cmd_CANCEL;
      end if;
      -- ������� ������� IMan
      d(SP.to_str_cmd(CurCommand)||' NAME=>'||
      case when PP.exists('NAME') then PP('NAME').S else 'null' end||
        ', PARENT=>'||
         case when PP.exists('PARENT') then PP('PARENT').S else 'null' end||
         ', OID=>'||
         case when PP.exists('OID') then PP('OID').S else 'null' end||
         case when PP.exists('ID') then PP('ID').S else 'null' end,
        'Macro Execution');
      -- ���� ������� �������������, �� �������� ������� ��� ����������,
      -- ������������ ��������� �������.
      -- ������������� ��������� ������� �������� � �������� ID.
      -- ������ �������� ������, ���� �� �����������.
      -- (��. �������� � Mark_to_Delete) 
      if CurCommand = SP.G.Cmd_Reload_Model then 
        Mark_to_Delete;
      end if;  
      return CurCommand;

-- Cmd_GET_USER_INPUT
-------------------------------------------------------------------------------
    when CurCommand=SP.G.Cmd_GET_User_Input then
      -- �������� ���������.
      Copy_IP2PP;
      -- �������� ��������� �� ��������� �������.
      delete SP.V_COMMAND_PAR_S;
      -- ���� ���������� ���, �� �����.
      if PP.count>0 then
	      tmpP:=PP.first;
	      loop
	        insert into SP.WORK_COMMAND_PAR_S
	          (NAME, COMMENTS, R_ONLY, TYPE_ID, E_VAL, N,D,S,X,Y,DEF_V)
	          values
	          (tmpP, PP(tmpP).COMMENTS, PP(tmpP).R_ONLY, PP(tmpP).T, PP(tmpP).E,
	           PP(tmpP).N, PP(tmpP).D, PP(tmpP).S, PP(tmpP).X, PP(tmpP).Y,
	           SP.VAL_TO_STR(PP(tmpP)));
	        tmpP:=PP.next(tmpP);
	        -- ���� ��������� ���������, �� �����.
	        if tmpP is null then exit; end if;
	      end loop;
      end if;
      -- ������� ������� IMan.
      d('Cmd_GET_User_Input','Macro Execution');
      return CurCommand;
--
  else
    -- ������� � EM ��������� �� ������ ���� �������.
    -- ������� ������� CANCEL
    EM:='SP.IM.get_COMMAND. ������ ���������, �������� ������������ ������� '||
        nvl(to_char(CurCommand),'null')||'!';
        d('Cmd_CANCEL EM=>'||EM,'Macro Execution');
    return SP.G.Cmd_CANCEL;
  end case;
  goto GET_NEXT_COMMAND;
exception
  when others then
    EM:='ERROR in SP.IM.get_COMMAND for command ['
    ||SP.to_str_cmd(CurCommand)||'] \r\n'||SQLERRM;
    return SP.G.Cmd_CANCEL;    
end get_COMMAND;

-------------------------------------------------------------------------------
FUNCTION get_PARS return SP.TIMAN_PARS pipelined
is
p SP.TIMAN_PAR_REC;
tmpVar SP.OBJECT_PAR_S.NAME%type;
begin
	p:= SP.TIMan_Par_Rec;
  -- ���� ���� ����, �� ������� �� ������������� SP.V_COMMAND_PAR_S
  if SP.M.STACK_DEPTH = 0 then
    for c in (select NAME, TYPE_ID, E, N, D, S, X, Y, R_ONLY_ID
                from SP.V_COMMAND_PAR_S order by NAME)
    loop
      p.Assign(c.NAME,
               SP.TVALUE(c.TYPE_ID,null,c.R_ONLY_ID,c.E,c.N,c.D,c.S,c.X,c.Y));
	    pipe row(p);
    end loop;
    return;
  else
	  -- ���� ���������� ���, �� �����.
	  if PP.count=0 then return; end if;
	  tmpVar:=PP.first;
	  loop
	    p.Assign(tmpVar,PP(tmpVar));
	    pipe row(p);
	    tmpVar:=PP.next(tmpVar);
	    -- ���� ��������� ���������, �� �����.
	    if tmpVar is null then return; end if;
	  end loop;
	  return;
  end if;
end get_PARS;

-------------------------------------------------------------------------------
FUNCTION get_ROOT return SP.TIMAN_PARS pipelined
is
p SP.TIMAN_PAR_REC;
tmpVar SP.OBJECT_PAR_S.NAME%type;
begin
	p:= SP.TIMan_Par_Rec;
  tmpVar:=SP.M.ROOT.first;
  loop
    p.Assign(tmpVar,SP.M.ROOT(tmpVar));
    pipe row(p);
    tmpVar:=SP.M.ROOT.next(tmpVar);
    -- ���� ��������� ���������, �� �����.
    if tmpVar is null then return; end if;
  end loop;
  return;
end get_ROOT;

-------------------------------------------------------------------------------
FUNCTION get_ROOT_FULL_NAME return VARCHAR2
is
begin
  --return SP.M.root('PARENT').S||SP.M.root('NAME').S;  --PF 2019-08-20
  return SP.PATHS.NAME(SP.M.Root('PARENT').S,SP.M.Root('NAME').S);
end get_ROOT_FULL_NAME;

-------------------------------------------------------------------------------
FUNCTION get_MESSAGES return CLOB
is
tmpVar BINARY_INTEGER;
result CLOB;
s SP.COMMANDS.COMMENTS%type;
begin
  -- d('Messages count => '||MESSAGES.count,'im.get_MESSAGES');
  DBMS_LOB.createtemporary(result,true,12);
  tmpVar:=MESSAGES.first;
  if tmpVar is null then return result; end if;
  loop
    s:= to_char(tmpVar)||'.  '||MESSAGES(tmpVar)||to_.str();
    DBMS_LOB.WRITEAPPEND (result,length(s),s);
    tmpVar:=MESSAGES.next(tmpVar);
    exit when tmpVar is null;
  end loop;
  -- ������� ������ ����� �������� ������� ���������.
  MESSAGES.DELETE;
  -- d('Message length => '||length(result),'im.get_MESSAGES');
  return result;
exception
  when others then
  d(SQLERRM,'ERROR in im.get_MESSAGES');
  EM:='ERROR in SP.IM.get_COMMAND '||SQLERRM;
  return null;
end get_MESSAGES;

-------------------------------------------------------------------------------
PROCEDURE INSERTED_or_UPDATED
is
tmpVar NUMBER;
OldName SP.COMMANDS.COMMENTS%type;
begin
  --d('START INSERTED_or_UPDATED','SP.IM.INSERTED_or_UPDATED');
  CurCommand:=null;
  -- ������� �� ������ ���������� �������� "Used_Object",
  -- ������ �������� �� ������������ � �������� ����.
  -- ������ ��������� �� ������ �������� ����� ���� OBJ_ID ������� 
  -- SP.MODEL_OBJECTS
  PPTRIM(PP);
  if  PP.exists('Used_Object') then
    PP.delete('Used_Object');
  end if;
  -- ���� ��� ���������� �������.
  if  PP.exists('OLD_NAME') or PP.exists('ID') then
    -- �� ��������� ��� ���������.
    tmpVar:=null;
    if PP.exists('ID') then
      tmpVar:=PP('ID').N;
    end if;
    if tmpVar is not null then
      tmpVar:= SP.MO.UPDATE_OBJECT(PP, SP.M.UsedObject, tmpVar);
      if PP.exists('OLD_NAME') then
        update SP.MODEL_OBJECTS set
          MOD_OBJ_NAME = PP('NAME').S,
          M_DATE = null,
          M_USER = null
          where ID = tmpVar;
      end if;
    end if;  
    -- ���� ���������� �� c��������, �� ��������� ������.
    -- ���������� ��������� ������ ���� ���������� ���� ����������������.
    if tmpVar is null then
      tmpVar:=SP.MO.MERGE_OBJECT(PP, SP.M.UsedObject);
      --d('MERGED '||nvl(to_char(tmpVar),'null!!!'),'SP.IM.INSERTED_or_UPDATED');
    end if;
  else
	  -- ��������� ������ � ������ � ��������� ��� ���������.
    --d('BEGIN MERGE','SP.IM.INSERTED_or_UPDATED');
    tmpVar:=SP.MO.MERGE_OBJECT(PP, SP.M.UsedObject);
    --d('MERGED '||nvl(to_char(tmpVar),'null!!!'),'SP.IM.INSERTED_or_UPDATED');
  end if;
  -- �������� ID � PID
  PP('ID'):= V_(G.TID,tmpVar);
  --!! ������ ������ ������ ������� ��������� �� �������
  select PARENT_MOD_OBJ_ID into tmpVar from SP.MODEL_OBJECTS where ID = tmpVar;
  PP('PID'):= V_(G.TID,tmpVar);
  -- �������� ��������� ���������� ������� � ������ OPa.
  Copy_PP2OPa;
--!!! ������ ����� ����������� ���������� � ������� � ������ ������� ���� ������ commit ��� ��� rollback!!!
	commit;
end INSERTED_or_UPDATED;

-------------------------------------------------------------------------------
PROCEDURE NOTES_UPDATED
is
tmpVar NUMBER;
AbsName SP.COMMANDS.COMMENTS%type;
begin
  CurCommand:=null;
  SP.MO.UPDATE_NOTES(PP);
	commit;
end NOTES_UPDATED;

-------------------------------------------------------------------------------
PROCEDURE RENAMED
is
OldName SP.COMMANDS.COMMENTS%type;
NewName SP.COMMANDS.COMMENTS%type;
begin
  PPTRIM(PP);
  case CurCommand
    when SP.G.Cmd_Rename then
      SP.MO.RENAME_OBJECT(PP);
    when SP.G.Cmd_Change_Parent then
      SP.MO.CHANGE_PARENT(PP);
  else
    EM:='������ ���������, ������������ ���������� ������� '||
        nvl(to_char(CurCommand),'null')||'!';
  end case;
  CurCommand:=null;
end RENAMED;

-------------------------------------------------------------------------------
PROCEDURE DELETED
is
begin
  PPTRIM(PP);
  CurCommand:=null;
  SP.MO.DELETE_OBJECT(PP);
end DELETED;

-------------------------------------------------------------------------------
PROCEDURE HALT
is
begin
  CurCommand:=null;
  -- �������� ����������, ������� ����.
  rollback;
  SP.M.CLEAR_STACK;
  PP.delete;
  EM:=null;
end HALT;


-------------------------------------------------------------------------------
PROCEDURE CONFIRM_END
is
begin
  -- ������� ����.
  SP.M.CLEAR_STACK;
  -- ��������� ����������.
  commit;
end CONFIRM_END;

-------------------------------------------------------------------------------
PROCEDURE Mark_to_Delete 
is
OID VARCHAR2(40);
tmpVar NUMBER;
begin
  OID := null;
  if not PP.exists('ID') then
    tmpVar := SP.MO.MOD_OBJ_ID(pp, OID);
    PP('ID') := SP.TVALUE(G.TID);
    PP('ID').N := tmpVar; 
  end if;
  if not PP.exists('OID') then
    PP('OID') := SP.TVALUE(G.TOID);
    PP('OID').S := OID;
    if    (PP('ID').N is not null) 
      and (OID is null) 
      and (PP('ID').N > 1) --!! ��������� �������� ���������� OID ��� �����.
    then
      select OID into PP('OID').S from SP.MODEL_OBJECTS where ID = PP('ID').N;
    end if;  
  end if;
  -- ���� ��������� ������ ������������� �� ��������� ������
  -- �� �� �������� ������, �� �������������� ������� �� ������ ������.
  -- ������� ���� �� ����������. 
  if PP('ID').N is null then
    PP.delete('ID');
    tmpVar := SP.MO.MERGE_OBJECT(PP,1);
    PP('ID') := SP.TVALUE(G.TID);
    PP('ID').N := tmpVar;
    return;
  end if;  
  -- ���� ��������� ���� ���� ������ ������, �� �������� ��� ������.
  if PP('ID').N is null or PP('ID').N = 1 then
    update SP.MODEL_OBJECTS mo set
      TO_DEL = 1
      where MO.MODEL_ID = SP.TG.Cur_MODEL_ID;
    return;
  end if;
  -- �������� ������� �������� ����������.    
    update SP.MODEL_OBJECTS mo set
      TO_DEL = 1
      where ID in
      (
        select ID from SP.MODEL_OBJECTS mo
          start with  MO.PARENT_MOD_OBJ_ID = PP('ID').N
          connect by  MO.PARENT_MOD_OBJ_ID = prior MO.ID
      )
    ;  
end Mark_to_Delete;
  
-------------------------------------------------------------------------------
FUNCTION FLUSH_OBJECTS return VARCHAR2
is
i BINARY_INTEGER;
j VARCHAR2(128);
tmpVar NUMBER;
tmpParent NUMBER;
pth# VARCHAR2(4000);
begin
  i := OS.first;
  while i is not null
  loop
    tmpVar:=null;
    -- ������� ������ �� ������ ��������
    if OS(i).exists('Used_Object') then
      tmpVar := SP.MO.GET_CATALOG_OBJECT(OS(i)('Used_Object'));
      OS(i).delete('Used_Object');
    else
      -- ���� �� ����� �� �����, �� ���� �� ����.
      j := OS(i).first;
      while j is not null  
      loop
        if OS(i)(j).T = G.TUsed_Object then
          tmpVar := SP.MO.GET_CATALOG_OBJECT(OS(i)(j));
          OS(i).delete(j);
          exit;
        end if;
        j := OS(i).next(j);
      end loop;
    end if;
    if tmpVar is null then
      tmpVar := 1;  
    end if;
    -- ��������� ������ � ������.
    tmpVar := SP.MO.MERGE_OBJECT(OS(i), tmpVar);
    -- ��������� ������ � ���.
    -- ��������, ��� ����� �� ������� �������� �������� � ������ ����� �������
    -- �� ������!!!
    /*
    select Parent_MOD_OBJ_ID into tmpParent from SP.MODEL_OBJECTS 
      where ID = tmpVar;
    insert into SP.MODEL_OBJECT_PATHS
      (ID, MODEL_ID, MOD_OBJ_PATH, PARENT_MOD_OBJ_ID, INVALID) 
      values
      (tmpVar, SP.TG.Cur_MODEL_ID, SP.MO.FULL_NAME(tmpVar), tmpParent, 0);
      
      ������ ��� ��� ������� �� Merge Into, ��������� ��� ��������� �����������
      ���� �� ������ ������ ��������� ������ ������������ �������� �����
      PK_M_OBJECT_PATHS 
      �.�. ���� �������� �������� �� ������������� ������, ����� �� ���������
      �� ��������.
    */
    
    pth#:=SP.MO.FULL_NAME(tmpVar);
    
    Merge Into  SP.MODEL_OBJECT_PATHS T
    Using
    (
      Select  
        mo.ID
        , SP.TG.Cur_MODEL_ID as MODEL_ID
        , pth# as MOD_OBJ_PATH --pth# ������ ������ �� SP.MO.FULL_NAME(tmpVar)
        --�� ������� ������������� ���������� 
        --ora-04091 table is mutating trigger/function may not see it
        --�������: ������� SP.MO.FULL_NAME 
        --         ������ �� ������� SP.MODEL_OBJECT_PATHS
        , mo.PARENT_MOD_OBJ_ID
        , 0 as INVALID
      From SP.MODEL_OBJECTS mo
      Where ID = tmpVar
    ) S
    On (T.ID=S.ID)
    When Matched Then Update
    Set T.INVALID=S.INVALID
    --��������, ���������� �������� �������� � ������ �����
    When Not Matched Then Insert
    (T.ID, T.MODEL_ID, T.MOD_OBJ_PATH, T.PARENT_MOD_OBJ_ID, T.INVALID)
    Values
    (S.ID, S.MODEL_ID, S.MOD_OBJ_PATH, S.PARENT_MOD_OBJ_ID, S.INVALID)
    ;    

    i := OS.next(i);
  end loop;
  OS.delete;
  commit;
  return null;
exception
  when others then
    EM := '������ FLUSH_OBJECTS '||SQLERRM;
    d(to_.str(OS(i)),' ERROR in FLUSH_OBJECTS');
    rollback;
    return EM;  
end FLUSH_OBJECTS;

-------------------------------------------------------------------------------
FUNCTION DELETE_MARKED return VARCHAR2
is
begin
  delete from SP.MODEL_OBJECTS mo where TO_DEL = 1;
exception
  when others then
    EM := '������ DELETE_MARKED '||SQLERRM;
    rollback;
    return EM;  
end DELETE_MARKED;

-------------------------------------------------------------------------------
FUNCTION SYM2REL return VARCHAR2
is
ModelID NUMBER;
ObjectID NUMBER;
i pls_integer;
s VARCHAR2(4000);
pName VARCHAR2(128);
rel SP.TVALUE;
begin
  d('START '||PP('ID').N, 'IM.SYM2REL');  
  -- ������� ��� ���������� ������, ������������ � ������ ���� ���������� ����.
  for rec in
  (
    select ID, MOD_OBJ_NAME from SP.MODEL_OBJECTS mo
      start with  (MO.PARENT_MOD_OBJ_ID = PP('ID').N)
                  or((MO.PARENT_MOD_OBJ_ID is null) and (PP('ID').N = 1))
      connect by  MO.PARENT_MOD_OBJ_ID = prior MO.ID
  )
  loop
    -- ��� ���� ���������� ������ �������
    for props in
    (
      select * from SP.MODEL_OBJECT_PAR_S mp 
        where MP.MOD_OBJ_ID = rec.ID
          and MP.TYPE_ID = G.TSymRel
    )
    loop
      if props.S is null then
        ObjectID := null;  
      else
        rel := SP.TVALUE(G.TREL, props.S);
        ObjectID := rel.N;
      end if;  
      update SP.MODEL_OBJECT_PAR_S set
        TYPE_ID = G.TRel,
        S = null,
        N = ObjectID
        where ID = props.ID;
    end loop;  
  end loop;        
  d('END '||PP('ID').N, 'IM.SYM2REL');  
  return null;
exception
  when others then
    EM := '������ SYM2REL '||SQLERRM;
    d(EM,' ERROR in IM.SYM2REL'); 
    return EM;  
end SYM2REL;

-------------------------------------------------------------------------------
PROCEDURE Model_Reloaded
is
begin
  OS.delete;
  CurCommand:=null;
  commit;
  d('Update or Insert model objects Time: '
  ||to_char(DEBUG_LOG.STOP_WATCH.GetTotalTimeInterval(1).IDS)
  ||chr(13)||chr(10)
  ||'Update object parameters Time: '
  ||to_char(DEBUG_LOG.STOP_WATCH.GetTotalTimeInterval(2).IDS)
  ||chr(13)||chr(10)||'=========================='
  ||chr(13)||chr(10)||'SP.IM.Model_Reloaded','Info');
  
end Model_Reloaded;

-------------------------------------------------------------------------------
PROCEDURE SELECT_OBJECT(ID in VARCHAR2)
is
i BINARY_INTEGER;
j VARCHAR2(128);
tmpID NUMBER;
begin
--!!! ��������� ��� �������� ������������ �������� � ���������!
-- �������� ������� ������� �������� ����� �� MM(ID) == i
if ID is null then return; end if;
tmpID := to_number(trim(ID));
i:=nvl(SS.last+1,1);
if tmpID = 1 then
  SS(i) := SP.MO.GET_MODEL_HROOT;
  j:=PP.first;
  while j is not null
  loop
    SS(i)(j) := PP(j);
    j :=PP.next(j);
  end loop;
else 
  SS(i) := PP; 
  SS(i)('NAME') := S_('');
  SS(i)('PARENT') := S_('');
  SS(i)('IS_SYSTEM') := B_(false);
  SS(i)('OID') := SP.TVALUE(G.TOID);
  SS(i)('ID') := ID_(tmpID);
  SS(i)('SP3DTYPE') := SP.TVALUE(G.TIType);
  Fill_OBJECT(SS(i),true);
end if;
--exception
--  when others then
--  EM := 'Error in SP.IM.SELECT_OBJECT '||SQLERRM;
--  d(SQLERRM, 'Error in SP.IM.SELECT_OBJECT');
end SELECT_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE CLEAR_SELECTED
is
begin
  SS.delete;
end CLEAR_SELECTED;

-------------------------------------------------------------------------------
FUNCTION get_SELECTED return SP.TIMAN_PARS pipelined
is
p SP.TIMAN_PAR_REC;
tmpVar SP.OBJECT_PAR_S.NAME%type;
i BINARY_INTEGER;
begin
	p:= SP.TIMan_Par_Rec;
  i := SS.first;
  while i is not null
  loop
	  tmpVar:=SS(i).first;
    while tmpVar is not null
	  loop
	    p.Assign(tmpVar,SS(i)(tmpVar),i);
	    pipe row(p);
	    tmpVar:=SS(i).next(tmpVar);
	  end loop;
    i := SS.next(i);
  end loop;  
	return;
end get_SELECTED;

-------------------------------------------------------------------------------
FUNCTION get_OBJECT return SP.TIMAN_PARS pipelined
is
p SP.TIMAN_PAR_REC;
tmpVar SP.OBJECT_PAR_S.NAME%type;
begin
	p:= SP.TIMan_Par_Rec;
  tmpVar:=PP.first;
   while tmpVar is not null
  loop
    p.Assign(tmpVar,PP(tmpVar),0);
    pipe row(p);
    tmpVar:=PP.next(tmpVar);
  end loop;
  return;
end get_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE set_OBJECT
is
begin
  SP.MO.UPDATE_OBJECT_PARS(PP);
end set_OBJECT;

-------------------------------------------------------------------------------
FUNCTION get_OBJECTS return SP.TIMAN_PARS pipelined
is
p SP.TIMAN_PAR_REC;
tmpVar SP.OBJECT_PAR_S.NAME%type;
i BINARY_INTEGER;
begin
	p:= SP.TIMan_Par_Rec;
  i := OS.first;
  while i is not null
  loop
	  tmpVar:=OS(i).first;
    while tmpVar is not null
	  loop
	    p.Assign(tmpVar,OS(i)(tmpVar),i);
	    pipe row(p);
	    tmpVar:=OS(i).next(tmpVar);
	  end loop;
    i := OS.next(i);
  end loop;  
	return;
end get_OBJECTS;

-------------------------------------------------------------------------------
PROCEDURE Fill_OBJECT(O in OUT SP.G.TMACRO_PARS,
                      TINY in BOOLEAN default false)
is
tmpVAR NUMBER;
tmpOID SP.COMMANDS.COMMENTS%type;
s SP.COMMANDS.COMMENTS%type;
tmpTiny boolean;
begin
  if O.exists('TINY') then
    tmpTiny := O('TINY').asBoolean;
    O.delete('TINY');
  else
    tmpTiny := TINY;
  end if;   
  SP.MO.GET_MODEL_OBJECT(O, tmpVar, tmpTiny);
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling object '||SQLERRM;
end Fill_OBJECT;

-------------------------------------------------------------------------------
PROCEDURE Fill_OBJECTS
is
tmpVar NUMBER;
tmpOID SP.COMMANDS.COMMENTS%type;
curObj NUMBER;
begin
  OS.delete;
  -- ������� ������.
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
  if tmpVar = 1 then
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID is null
                  and MODEL_ID = SP.get_MODEL_ID)
	  loop 
      OS(curObj) := PP;           
	    OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),true);
	    curObj := curObj +1;
	  end loop;
  else                
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID = tmpVar)
	  loop            
      OS(curObj) := PP;           
      OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),true);
	    curObj := curObj +1;
	  end loop;
  end if;                
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end Fill_OBJECTS;

-------------------------------------------------------------------------------
PROCEDURE Fill_SYSTEMS
is
tmpVar NUMBER;
tmpOID SP.COMMANDS.COMMENTS%type;
curObj NUMBER;
begin
  --d('1','SP.IM.Fill_SYSTEMS');
  OS.delete;
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID); 
  --d('2 '||tmpVar,'SP.IM.Fill_SYSTEMS');
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
  if tmpVar = 1 then
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID is null)
	  loop            
      OS(curObj) := PP;
      OS(curObj)('IS_SYSTEM') := B_(false);           
      OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),true);
      if OS(curObj)('IS_SYSTEM').N > 0 then
        curObj := curObj +1;
      else
        OS.delete(curObj);
      end if;
	  end loop;
  else                
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID = tmpVar)
	  loop            
      OS(curObj) := PP;
      OS(curObj)('IS_SYSTEM') := B_(false);           
      OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),true);
      if OS(curObj)('IS_SYSTEM').N > 0 then
        curObj := curObj +1;
      else
        OS.delete(curObj);
      end if;  
	  end loop;
  end if;                
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end Fill_SYSTEMS;

-------------------------------------------------------------------------------
PROCEDURE Fill_FULL_OBJECTS
is
tmpVar NUMBER;
tmpOID SP.COMMANDS.COMMENTS%type;
curObj NUMBER;
begin
  OS.delete;
  --d('Q'||tmpVar,'SP.IM.Fill_FULL_OBJECTS'); 
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID);
  --d('2'||tmpVar,'SP.IM.Fill_FULL_OBJECTS'); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
  if tmpVar = 1 then
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID is null )
	  loop            
	    OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),false);
	    curObj := curObj +1;
	  end loop;              
  else
	  for c in (select ID from SP.MODEL_OBJECTS 
	              where PARENT_MOD_OBJ_ID = tmpVar)
	  loop            
	    OS(curObj)('ID') := N_(c.ID);
	    FILL_OBJECT(OS(curObj),false);
	    curObj := curObj +1;
	  end loop;
  end if;                
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end Fill_FULL_OBJECTS;

-------------------------------------------------------------------------------
FUNCTION IS_OBJECT_EXIST(O in out SP.G.TMACRO_PARS) return number
is
tmpVar NUMBER;
tmpID NUMBER;
tmpOID SP.COMMANDS.COMMENTS%type;
s SP.COMMANDS.COMMENTS%type;
begin
  tmpVar := nvl(SP.MO.MOD_OBJ_ID(O, tmpOID),0); 
  --d(tmpVar,'SP.IM.IS_OBJECT_EXIST');
  O('EXISTS'):= SP.B_(tmpVar>0);
  return tmpVar;  
end IS_OBJECT_EXIST;

-------------------------------------------------------------------------------
FUNCTION IS_OBJECT_EXIST return number
is
begin
  return IS_OBJECT_EXIST(SP.IM.PP);
end IS_OBJECT_EXIST;

-------------------------------------------------------------------------------
PROCEDURE UPDATE_MOD_OBJ_PARS
is
tmpOID VARCHAR2(40);
id NUMBER;
begin
  -- ���� ������ �� ��������� � ������ �� ����������, �� �� ��������� ���������!
  id := SP.MO.MOD_OBJ_ID(PP, tmpOID);
  if id is null then
    if SP.TG.Cur_SERVER = G.SLocal then
      EM := '����������� ������ �� ������!';
      return;
    end if;
    return;
  end if;  
  SP.MO.UPDATE_OBJECT_PARS(PP, id );
exception
  when others then 
    EM := 'ERROR Updating PARS '||SQLERRM||' '||EM;   
end UPDATE_MOD_OBJ_PARS;

------------------------------------------------------------------------------
PROCEDURE FILL_ALL_FULL_OBJECTS
is
tmpVar NUMBER;
tmpOID SP.MODEL_OBJECTS.OID%TYPE;
curObj NUMBER;
tmpID Number;
c_cur SYS_REFCURSOR;
PARS SP.G.TMACRO_PARS;
begin
--d('START 6 FILL_ALL_FULL_OBJECTS','DEBUG SP.IM.FILL_ALL_FULL_OBJECTS');
  OS.delete;
  --d('Q'||tmpVar,'SP.IM.Fill_FULL_OBJECTS'); 
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID);
  --d('2: '||tmpVar,'SP.IM.Fill_FULL_OBJECTS'); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
  if tmpVar = 1 then
    --������ ��� ��������� ������� ������� ������
    OPEN c_cur FOR
    select mo.ID from SP.MODEL_OBJECTS mo 
	              start with mo.PARENT_MOD_OBJ_ID is null 
                  And mo.MODEL_ID=SP.TG.Get_CurModel()
                  connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
    ;
  else
    --������ ��� ����������� �������
    OPEN c_cur FOR
    select mo.ID from SP.MODEL_OBJECTS mo 
	              start with mo.PARENT_MOD_OBJ_ID = tmpVar
                  connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
    ;
  end if;   
  
  
  Loop
    Fetch c_cur Into tmpID;
    Exit When c_cur%NOTFOUND;
    PARS.Delete;
    PARS('ID') := N_(tmpID);
    SP.MO.GET_MODEL_OBJECT(PARS,tmpID,false);
    OS(curObj):=PARS;
    curObj := curObj +1;
  End Loop;
  close c_cur;
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end FILL_ALL_FULL_OBJECTS;

------------------------------------------------------------------------------
PROCEDURE FILL_ALL_OBJECTS
is
tmpVar NUMBER;
tmpOID SP.MODEL_OBJECTS.OID%TYPE;
curObj NUMBER;
c_cur SYS_REFCURSOR;
tmpID Number;
PARS SP.G.TMACRO_PARS;
begin
--d('START FILL_ALL_OBJECTS','SP.IM.FILL_ALL_OBJECTS');
  OS.delete;
  -- ������� ������.
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
  if tmpVar = 1 then
      --������ ��� ��������� ������� ������� ������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID is null 
      And mo.MODEL_ID=SP.TG.Get_CurModel()
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  else                
    --������ ��� ����������� �������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID = tmpVar
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  end if; 
  
  Loop
    Fetch c_cur Into tmpID;
    Exit When c_cur%NOTFOUND;
    PARS:=PP;
    PARS('ID') := N_(tmpID);
    PARS('IS_SYSTEM') := B_(false);               
    SP.MO.GET_MODEL_OBJECT(PARS,tmpID,true);
    OS(curObj):=PARS;
	curObj := curObj +1;
  End Loop;
  close c_cur;
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end FILL_ALL_OBJECTS;

------------------------------------------------------------------------------
PROCEDURE FILL_ALL_SYSTEMS
is
tmpVar NUMBER;
tmpOID SP.MODEL_OBJECTS.OID%TYPE;
curObj NUMBER;
c_cur SYS_REFCURSOR;
tmpID Number;
PARS SP.G.TMACRO_PARS;
begin
--d('START FILL_ALL_SYSTEMS','SP.IM.FILL_ALL_SYSTEMS');
  OS.delete;
  -- ������� ������.
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
--!!! �������������� ������, ����� �� ���������� ��� �������
  if tmpVar = 1 then
      --������ ��� ��������� ������� ������� ������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID is null 
      And mo.MODEL_ID=SP.TG.Get_CurModel()
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  else                
    --������ ��� ����������� �������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID = tmpVar
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  end if; 
  
  Loop
    Fetch c_cur Into tmpID;
    
    Exit When c_cur%NOTFOUND;
    PARS:=PP;
    PARS('IS_SYSTEM') := B_(false);           
    PARS('ID') := N_(tmpID);
--!!! �������������� ������, ����� �� ���������� ��� �������
    SP.MO.GET_MODEL_OBJECT(PARS,tmpID,true);
    if PARS('IS_SYSTEM').N > 0 then
      OS(curObj):=PARS;
      curObj := curObj +1;
    end if;
  
  End Loop;
  close c_cur;
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end FILL_ALL_SYSTEMS;

------------------------------------------------------------------------------
PROCEDURE FILL_ALL_FULL_SYSTEMS
is
tmpVar NUMBER;
tmpOID SP.MODEL_OBJECTS.OID%TYPE;
curObj NUMBER;
c_cur SYS_REFCURSOR;
tmpID Number;
PARS SP.G.TMACRO_PARS;
begin
--d('START FILL_ALL_FULL_SYSTEMS','SP.IM.FILL_ALL_FULL_SYSTEMS');
  OS.delete;
  -- ������� ������.
  tmpVar := SP.MO.MOD_OBJ_ID(PP, tmpOID); 
  curObj :=1;
  -- ������� ���� ����� � ��������� ������.
  -- ���� ������� ������ ���� ������ ��������.
--!!! �������������� ������, ����� �� ���������� ��� �������
  if tmpVar = 1 then
      --������ ��� ��������� ������� ������� ������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID is null 
      And mo.MODEL_ID=SP.TG.Get_CurModel()
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  else                
    --������ ��� ����������� �������
    OPEN c_cur FOR
      select mo.ID from SP.MODEL_OBJECTS mo 
      start with mo.PARENT_MOD_OBJ_ID = tmpVar
      connect by prior mo.ID=mo.PARENT_MOD_OBJ_ID
      ;
  end if; 
  
  Loop
    Fetch c_cur Into tmpID;
    
    Exit When c_cur%NOTFOUND;
    
    PARS:=PP;
    PARS('IS_SYSTEM') := B_(false);
    PARS('ID') := N_(tmpID);
--!!! �������������� ������, ����� �� ���������� ��� �������
    SP.MO.GET_MODEL_OBJECT(PARS,tmpID,false);
    if PARS('IS_SYSTEM').N > 0 then
      OS(curObj):=PARS;
      curObj := curObj +1;
    end if;
  
  End Loop;
  close c_cur;
exception
  when others then  
  -- ���� ������ �� ������, ������������� ������.
  EM:= 'ERROR Filling objects '||SQLERRM;
end FILL_ALL_FULL_SYSTEMS;

FUNCTION CopyOS2SYSTEMS return VARCHAR2
is
EM VARCHAR2(4000);
begin
if SP.M.WORKING_PACKAGE is not null then
  execute immediate
    ('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.SYSTEMS := SP.IM.OS; end;');
end if;
return '';
exception
  when others then
    EM := 'Error in CopyOS2OBJECTS: '||SQLERRM||'!';
    return EM;
end CopyOS2SYSTEMS;

FUNCTION CopyOS2OBJECTS return VARCHAR2
is
EM VARCHAR2(4000);
begin
if SP.M.WORKING_PACKAGE is not null then
execute immediate
('begin SP_IM.'||SP.M.WORKING_PACKAGE||'.OBJECTS := SP.IM.OS; end;');
end if;
return '';
exception
  when others then
    EM := 'Error in CopyOS2OBJECTS: '||SQLERRM||'!';
    return EM;
end CopyOS2OBJECTS;


begin
  -- ����� ��������� ��� ��������� � ����� SP.G
  HierarchiesRoot := SP.TVALUE(SP.G.TIType, 'HierarchiesRoot');
end IM;
/
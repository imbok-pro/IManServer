CREATE OR REPLACE PACKAGE BODY SP.M
-- MACROCOMAND package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.11.2010
-- update 09.11.2010 16.11.2010 25.11.2010 29.11.2010 17.12.2010 31.01.2011
--        07.02.2010 28.02.2011 01.03.2011 17.03.2011 30.03.2011 22.06.2011
--        02.11.2011 16.11.2011 25.11.2011 09.12.2011 29.12.2011 25.01.2012
--        13.04.2012 06.06.2012 04.04.2013 25.08.2013 24.06.2014 04.11.2014
--        11.04.2017 21.01.2021 25.01.2021 04.09.2021 11.09.2021 16.09.2021
AS
-- ���� ������ �������.
S SP.G.TINAMES;
I BINARY_INTEGER;

-------------------------------------------------------------------------------
FUNCTION MacroName(MacroPackage in VARCHAR2) return VARCHAR2
is
tmpName SP.OBJECTS.NAME%type;
SQL_Str VARCHAR2(255);
begin
  SQL_Str:='
  begin :NAME:=SP_IM.'||MacroPackage||'.MacroName; end;
  ';
  execute immediate SQL_Str using out tmpName; 
  return tmpName;
exception
  when others then 
    d('�� ������� �������������� ��� ������ '||nvl(MacroPackage,'null')||'!',
      'ERROR SP.M.MacroName');
    return null;
end MacroName;

-------------------------------------------------------------------------------
FUNCTION ObjectName(ObjectID in NUMBER) return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
begin
  select NAME into tmpVar from SP.OBJECTS where ID = ObjectID;
  return tmpVar;
exception
  when no_data_found then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.M.ObjectName. �� ������ ������ � ��������������� '||
       nvl(to_char(ObjectID),'null')||'!');
end ObjectName;

-------------------------------------------------------------------------------
FUNCTION ObjectFullName(ObjectID in NUMBER, ObjectName out VARCHAR2)
return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
begin
  select o.NAME, G.NAME||'.'||o.NAME into ObjectNAME, tmpVar 
    from SP.OBJECTS o, SP.GROUPS g
    where o.ID = ObjectID
      and o.GROUP_ID = G.ID;
  return tmpVar;
exception
  when no_data_found then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.M.ObjectFullName. �� ������ ������ � ��������������� '||
       nvl(to_char(ObjectID),'null')||'!'
       ||' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
end ObjectFullName;

-------------------------------------------------------------------------------
FUNCTION ObjectID(ObjectName in VARCHAR2) return  NUMBER
is
i PLS_INTEGER;
tmpVar SP.COMMANDS.COMMENTS%type;
begin
  i:= instr(ObjectName, '.', -1);
  select o.ID into tmpVar from SP.OBJECTS o, SP.GROUPS g
      where o.NAME = substr(ObjectName,1,i-1)
        and g.NAME = substr(ObjectName,i+1)
        and o.GROUP_ID = G.ID;
  return tmpVar;
exception
  when no_data_found then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.M.ObjectID. �� ������ ������ '||nvl(ObjectName,'null')||'!'
      ||' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
end ObjectID;

-------------------------------------------------------------------------------
FUNCTION MacroPackage(MacroName in VARCHAR2) return VARCHAR2
is
tmpVar NUMBER;
begin
  select ID into tmpVar from SP.OBJECTS where upper(NAME)=upper(MacroName);
  return 'M'||to_char(tmpVar);
exception
  when no_data_found then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.M.MacroPackage. �� ������ ������ '||nvl(MacroName,'null')||'!');
    return null;
end MacroPackage;

-------------------------------------------------------------------------------
FUNCTION MacroPackage(ObjectID in NUMBER) return VARCHAR2
is
begin
  return 'M'||to_char(ObjectID);
end MacroPackage;

-------------------------------------------------------------------------------
FUNCTION WORKING_PACKAGE return VARCHAR2
is
begin
  case 
    when I=0 then return null;
    when I>0 then 
      if S.exists(I) then return S(I); end if;
  end case;
  RAISE_APPLICATION_ERROR(-20033,
    'SP.M.WORKING_PACKAGE. ������ ��������� �����!');
end WORKING_PACKAGE;

-------------------------------------------------------------------------------
FUNCTION CALLING_PACKAGE return VARCHAR2
is
begin
  -- d('i='||to_char(i),'M.CALLING_PACKAGE');
  case 
    when I=0 then return null;
    when I=1 then return null;
    -- d('s(i)='||s(i),'M.CALLING_PACKAGE');
    when I>1 then 
      if S.exists(I-1) then 
        -- d('s(i-1)='||s(i-1),'M.CALLING_PACKAGE');
	      return S(I-1); 
      end if;
  end case;
  RAISE_APPLICATION_ERROR(-20033,
      'SP.M.CALLING_PACKAGE. ������ ��������� �����!');
end CALLING_PACKAGE;

-------------------------------------------------------------------------------
PROCEDURE PUSH(MacroPackage in VARCHAR2)
is
tmpVar SP.COMMANDS.COMMENTS%type;
begin
  if I>0 then
    -- ���� ������� ����� ������ ����, �� �������� ��������� �� ����������
    -- ���������.
    -- ��� �������� ���������� � ���������� UsedObject ������������
    -- ������ �� ���������� ������ ��������.
    -- ��������������� 0 �������� ������ #Composit Origin.
    -- ���� ����������� ����� ���������� ���������,
    -- �� ���������� ��� ��������� � ��������������� ����������.
    tmpVar:='
     begin 
       SP_IM.'||MacroPackage||'.P := SP_IM.'||S(I)||'.IP;
       if SP.M.UsedObject = 0 then
         SP_IM.'||MacroPackage||'.Composit:= SP_IM.'||S(I)||'.OPa;
       else
         SP_IM.'||MacroPackage||'.Composit.delete;
       end if;    
     end;
            ';
  else  
    -- �����.
    -- �������� ��������� �� ������� ������� ���������� � ������ P �����������,
    -- �������� ������ OS ������ IM, ���������� ����� ��������,
    -- ���������� ������������� ����� �������� ��������������,
    -- � ������ SELECTED �����������.
    tmpVar:='
      declare
        V SP.TVALUE;
      begin 
        for p in (select * from SP.V_COMMAND_PAR_S)
        loop
          SP_IM.'||MacroPackage||'.P(p.NAME):=
            SP.TVALUE(p.TYPE_ID, null, 0, p.E, p.N, p.D, p.S, p.X, p.Y);
        --d(''������� �������� ''||p.Name,''SP.M.PUSH'');  
        end loop;
        SP_IM.'||MacroPackage||'.SELECTED:=SP.IM.OS;
        SP.IM.OS.Delete;
      end;      
            ';
  end if;
--  D('tmpVar => '||tmpVar,'SP.M.PUSH');
  execute immediate( tmpVar);
  -- ������� ���������� � ������� ������������ ������.
  -- ������� ��������� ����� ��������� � ��� ���������� ������ ���������:
  -- OBJECTS
  -- SYSTEMS
  -- SELECTED
  -- ����� ���� ������� OBJECTS, SYSTEMS, SELECTED, OPa ��������� ����� �������
  -- ������ GET_OBJECTS, GET_SYSTEMS, GET_SELECTED, GET_PARS ��������������.
  tmpVar:='
    begin
      SP_IM.'||MacroPackage||'.IP.delete;
      SP_IM.'||MacroPackage||'.OBJECTS.delete;
      SP_IM.'||MacroPackage||'.SYSTEMS.delete;
      SP_IM.'||MacroPackage||'.SELECTED.delete;
      SP_IM.'||MacroPackage||'.OPa.delete;
      SP_IM.'||MacroPackage||'.IPs.delete;
      SP_IM.'||MacroPackage||'.MOPs.delete;
      SP_IM.'||MacroPackage||'.�OPs.delete;
      SP_IM.'||MacroPackage||'.EM:=null;
      SP_IM.'||MacroPackage||'.ExecutionPoint:=1;
      SP_IM.'||MacroPackage||'.CurIndex:=null;
      SP_IM.'||MacroPackage||'.CreateComposit:=false;
      SP_IM.'||MacroPackage||'.CurSystem:=null;
      SP_IM.'||MacroPackage||'.CurObject:=null;
      SP_IM.'||MacroPackage||'.CASE_EXECUTED:=false;
    end;
        ';  
--  D('tmpVar => '||tmpVar,'SP.M.PUSH');
  execute immediate( tmpVar);
--  D('last ','SP.M.PUSH');

  -- ���������� ���������� � ��������� ����� � ����.
  I:=I+1;
  S(I):=MacroPackage;
exception
  when others then
    D(MacroPackage||' => '||SQLERRM,'ERROR SP.M.PUSH');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.M.PUSH. ������ ������ ������ ' ||nvl(MacroPackage,'null')||
      ' => '||SQLERRM||'!');  
end PUSH;

-------------------------------------------------------------------------------
FUNCTION TEST_PARAMS(IP in out NOCOPY SP.G.TMACRO_PARS,
                     UsedObjectID in NUMBER default null)
return VARCHAR2
is
EM SP.COMMANDS.COMMENTS%type;
UO NUMBER; 
begin
  if not SP.TG.TEST_MACRO_PARS then return ''; end if;
  if UsedObjectID is null then 
    UO := UsedObject;
  else
    UO := UsedObjectID;
  end if;    
  -- � ����� �� ���� ���������� ������� ��������.
  for p in (select * from SP.OBJECT_PAR_S where OBJ_ID=UO)
  loop
    -- d(p.NAME,'��������� �������: '||to_char(UO));
    -- ��������� ������� ��������� � ������� ����������.
		if not IP.exists(p.NAME)then
      -- ���� �������� �����������, ��: 
      -- ���� �������� ������������,
      if p.R_ONLY=-1 then
        -- �� ���������� ������,
        EM:='����������� ������������ ��������'||p.NAME||'!';
        return EM;
      --��������� ���������, ��������� ������ �� ������.  
      elsif p.R_ONLY=1 then
        IP(p.NAME) := 
          SP.TVALUE(p.TYPE_ID,null, 0, p.E_VAL, p.N, p.D, p.S, p.X, p.Y);  
      end if;
		elsif p.R_ONLY=1 then 
      -- ��������� c����������� �������� ��������� �� ��������� ���
      -- �����������, ��������� ������ �� ������.
      if not SP.G.EQ( IP(p.NAME),
         SP.TVALUE(p.TYPE_ID,null, 0, p.E_VAL, p.N, p.D, p.S, p.X, p.Y))
      then
        -- �� ���������� ������,
        EM:='������ ��������� ������ �� ������ ��������'||p.NAME||'!';
        return EM;
      end if;  
    --d(i,'�������� �������� �������: '||to_char(UO));
    end if;      
  end loop;
  return '';
end TEST_PARAMS;

-------------------------------------------------------------------------------
PROCEDURE FILL_PARAMS(IP in out NOCOPY SP.G.TMACRO_PARS,
                      UsedObjectID in NUMBER)
is
begin
  UsedObject := UsedObjectID;
  if SP.TG.CURMODEL_LOCAL then return; end if;
  -- � ����� �� ���� ���������� ������� ��������.
  for p in (select * from SP.OBJECT_PAR_S where OBJ_ID=UsedObjectID)
  loop
    -- d(p.NAME,'��������� �������: '||to_char(UsedObjectID));
    -- ���������� ������������ ���������.
    if p.R_ONLY != -1 then
      -- ���������� ����������� ��������� ���������, ��������� �� ������/������
      if (not IP.exists(p.NAME)) or (p.R_ONLY = 1) then
      IP(p.NAME):=
        SP.TVALUE(p.TYPE_ID,null, 0, p.E_VAL, p.N, p.D, p.S, p.X, p.Y);
      end if;  
    end if;  
  end loop;

end FILL_PARAMS;

-------------------------------------------------------------------------------
PROCEDURE POP
is
tmpVar SP.COMMANDS.COMMENTS%type;
tmpN NUMBER;
begin
  -- ���� ������� ����� ������ ����, �� �������� �������� ��������� �
  -- ���������� ��������� ��� ������� ��,
  -- ���� � �������������� ������ ���� ������ ����.
  -- ������� ������� ������ IP � ����������� ������. ������ ����� �������
  -- ��� ���� ������������ � ���������� ������ � ������ ������ ���� ������
  -- ����� ��� �������������� � ����������� ��������. 
  if I>0 then 
    execute immediate('
        begin :1:=SP_IM.'||S(I)||'.OPa.count;end;
      ')
      using out tmpN;
    if tmpN>0 then
      execute immediate('
        begin 
          SP_IM.'||S(I-1)||'.OPa := SP_IM.'||S(I)||'.OPa;
        end;
      ');
    else
      execute immediate('
        begin SP_IM.'||S(I-1)||'.OPa.delete; end;
      ');
    end if; 
    execute immediate('
        begin SP_IM.'||S(I-1)||'.IP.delete; end;
    ');
  end if;
  -- ������� ������� OBJECTS � SYSTEMS �������������� ������.
  tmpVar:='
    begin
      SP_IM.'||S(I)||'.OBJECTS.delete;
      SP_IM.'||S(I)||'.SYSTEMS.delete;
      SP_IM.'||S(I)||'.SELECTED.delete;
    end;
        ';  
  execute immediate( tmpVar);
  if I>0 then
    S.delete(I);
    I:=I-1;
  end if;  
end POP;
 
-------------------------------------------------------------------------------
PROCEDURE CLEAR_STACK
is
tmpI BINARY_INTEGER;
tmpVar SP.COMMANDS.COMMENTS%type;
begin
  -- ���� ���� �� ����, �� ��� ���� ������� � ����� �������� �� ���������� �
  -- �������� ���������.
  tmpI:=S.first;
  while tmpI is not null 
  loop
    tmpVar:='
      begin
       SP_IM.'||S(I)||'.SELECTED.delete;
       SP_IM.'||S(I)||'.OBJECTS.delete;
       SP_IM.'||S(I)||'.SYSTEMS.delete;
       SP_IM.'||S(I)||'.IP.delete;
       SP_IM.'||S(I)||'.OPa.delete;
       SP_IM.'||S(I)||'.IPs.delete;
       SP_IM.'||S(I)||'.MOPs.delete;
       SP_IM.'||S(I)||'.�OPs.delete;
       SP_IM.'||S(I)||'.EM:=null;
       SP_IM.'||S(I)||'.ExecutionPoint:=1;
       SP_IM.'||S(I)||'.CurIndex:=null;
       SP_IM.'||S(I)||'.CreateComposit:=false;
       SP_IM.'||S(I)||'.CurSystem:=null;
       SP_IM.'||S(I)||'.CurObject:=null;
       SP_IM.'||S(I)||'.CASE_EXECUTED:=false;
      end;
          ';
   execute immediate( tmpVar);
    -- ���� ��������� ����� � �����.  
    tmpI:=S.next(tmpI);
  end loop;
  I:=0;
  S.delete;
  UsedObject:=null;
end CLEAR_STACK;
 
-------------------------------------------------------------------------------
FUNCTION GET_STACK return SP.G.TINAMES
is
begin
  return S;
end GET_STACK;

-------------------------------------------------------------------------------
FUNCTION GET_STACK_asString return VARCHAR2
is
tmpString SP.COMMANDS.COMMENTS%type;
tmpVar BINARY_INTEGER;
begin
  tmpVar:=S.first;
  if tmpVar is null then return null; end if;
  tmpString:=S(tmpVar);
  tmpVar:=S.next(tmpVar);
  while tmpVar is not null
  loop
  -- !!! ����� �������� ������ ���������� ������ ���������� ������ � �����!!!
    tmpString:=tmpString||' | '||S(tmpVar);
    tmpVar:=S.next(tmpVar);
  end loop;
  return tmpString;
end GET_STACK_asString;
 
-------------------------------------------------------------------------------
FUNCTION STACK_DEPTH return NUMBER
is
begin
  return I;
end STACK_DEPTH;
 
-------------------------------------------------------------------------------
PROCEDURE RT_MACRO_ERROR(M_NAME in VARCHAR2, C_ORD in NUMBER, EM in VARCHAR2)
is
begin
  D(M_NAME||' ������ '||to_char(C_ORD)||' : '||EM,'RT_MACRO_ERROR');
  SP.IM.EM:=M_NAME||' ������ '||to_char(C_ORD)||' : '||EM
          ||', in '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
end RT_MACRO_ERROR;

-------------------------------------------------------------------------------
FUNCTION StartCompositID return NUMBER 
is
begin
  if upper(S(1))='MCOMPOSIT' then
    return SP_IM.MCOMPOSIT.MacroID; 
  else
   return to_number(substr(S(1),2));
  end if;
end;

-------------------------------------------------------------------------------
FUNCTION CurCompositID return NUMBER 
is
begin
  if upper(WORKING_PACKAGE)='MCOMPOSIT' then
    return SP_IM.MCOMPOSIT.MacroID; 
  else
   return to_number(substr(WORKING_PACKAGE,2));
  end if;
end;

-------------------------------------------------------------------------------
FUNCTION CheckCanCreate_ID2_by_ID1(ID1 NUMBER,ID2 NUMBER) return BOOLEAN
is
IsCheck BOOLEAN;
cnt NUMBER;
begin
  IsCheck := false;
  select count (*) into cnt 
    from SP.OBJECTS where ID=ID1 and OBJECT_KIND=1;
  if cnt = 1 then 
    select count (*) into cnt 
      from  SP.OBJECTS where ID=ID2 and OBJECT_KIND in(0,1);
  end if;
  if cnt = 1 then
    select count(*) into cnt 
      from SP.MACROS 
        where OBJ_ID = ID2 and USED_OBJ_ID = ID1;
  end if;
  if cnt > 0 then
    IsCheck := true;
  end if;
  return IsCheck;
end;

-------------------------------------------------------------------------------
begin
  I:=0;
  Root := SP.MO.GET_MODEL_HROOT;
END M;
/

CREATE OR REPLACE PACKAGE BODY SP.B
-- BUILD package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.09.2010
-- update 03.11.2010 09.11.2010 15.11.2010 19.11.2010 23.11.2010 08.12.2010
--        20.12.2010 11.02.2011 28.02.2011 04.03.2011 10.03.2011 15.03.2011
--        16.03.2011 30.03.2011 05.04.2011 14.04.2011 15.04.2011 10.05.2011
--        16.05.2011 09.06.2011 28.06.2011 22.10.2011 02.11.2011 10.11.2011
--        25.11.2011 09.11.2011 15.12.2011 20.12.2011 16.01.2012 23.01.2012
--        27.01.2012 02.02.2011 07.02.2012 14.02.2012 16.03.2012 20.03.2012
--        28.03.2012 24.01.2013 31.01.2013 04.04.2013 22.05.2013 27.05.2013
--        25.08.2013 29.08.2013 20.09.2013 30.09.2013 01.10.2013 04.10.2013
--        06.02.2014 16.06.2014 27.06.2014 16.07.2014 28.11.2014 06.01.2015
--        16.02.2015 18.02.2015 07.07.2016 08.07.2016 21.11.2016 05.03.2017
--        12.04.2017 17.02.2017 01.12.2017 21.01.2021 29.07.2021 12.09.2021
AS
EM SP.COMMANDS.COMMENTS%type;
-------------------------------------------------------------------------------
-- ���������� ��������� ������ ������� (��������������) �� ������� �����.
-- ���� � ����� ����������� �����, �� ���� �� ��������� �����.
-- ���� ������ �� ������, �� ������� ���������� 0, � ���� ������ ���������� EM 
-- �������� ��������� �� ������.
-- ���� ���������� �������� MACRO, �� ���� ������ ����� ���� � ����������.
FUNCTION GetIDbyName(MACRO_FULL_NAME IN VARCHAR2, FName IN VARCHAR2,
                     MACRO IN BOOLEAN default true)
return number
is 
  tmpVar NUMBER;
begin
  if instr(MACRO_FULL_NAME,'.')=0 then
    begin
      if MACRO then
        select ID into tmpVar from SP.OBJECTS 
          where upper(NAME)=upper(MACRO_FULL_NAME)
            and OBJECT_KIND in (SP.G.MACRO_OBJ, SP.G.COMPOSITE_OBJ);
      else
        select ID into tmpVar from SP.OBJECTS 
          where upper(NAME)=upper(MACRO_FULL_NAME);
      end if;    
    exception
      when too_many_rows then
        raise_application_error(-20033,
        'SP.B.'||FName||'.'||
        '���������� ������ ������ ��� ������� '||MACRO_FULL_NAME||'!');
    end;    
  else
    if MACRO then
      select ID into tmpVar from SP.V_OBJECTS 
        where upper(FULL_NAME)=upper(MACRO_FULL_NAME)
          and KIND_ID in (SP.G.MACRO_OBJ, SP.G.COMPOSITE_OBJ);
    else
      select ID into tmpVar from SP.V_OBJECTS 
        where upper(FULL_NAME)=upper(MACRO_FULL_NAME);
    end if;    
  end if;    
  return tmpVar;
exception
  when no_data_found then
    EM:='SP.B.'||FName||'. '||MACRO_FULL_NAME||' �� ����������!';
    return 0;   
end GetIDbyName;  
-------------------------------------------------------------------------------
FUNCTION COMPILE_MACRO(MACRO_FULL_NAME IN VARCHAR2)  
return VARCHAR2
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'COMPILE_MACRO');
  if tmpVar>0 then
    EM:=COMPILE_MACRO(tmpVar);
  end if;    
  return EM;
end COMPILE_MACRO;

-------------------------------------------------------------------------------
FUNCTION COMPILE_MACRO(MACRO_ID IN NUMBER) return VARCHAR2
is
  MP VARCHAR2(32000);
  tmpVar NUMBER;
  MacroName VARCHAR2(4000);
  EM SP.COMMANDS.COMMENTS%type;
begin
  -- ���������, ��� �������������� ����������.
 begin
   select FULL_NAME into MacroName from SP.V_OBJECTS 
     where ID=MACRO_ID 
       and KIND_ID in (SP.G.MACRO_OBJ, SP.G.COMPOSITE_OBJ);
 exception
   when no_data_found then
     EM:='SP.B.COMPILE_MACRO. '||
         '������� � ���������������: '||MACRO_ID||' �� ����������!';
     return EM;   
 end;
  MP:='
CREATE OR REPLACE PACKAGE SP_IM.MMACRO##ID
-- MACRO##NAME package
-- recreate ##NOW 
AUTHID CURRENT_USER
AS
-- ���� ����� ������������� ������ ������� SP.B �� ������.
-- ��� ������ �������� ������������� ������� ��������������.
-- ������ ���������� ��������������.
-- ��� ������� �������������� ���� ������ �������� ������� ���������.
P SP.G.TMACRO_PARS;
-- ������ ������� ���������� (������ TValue). � ���� ������ ���������� �������
-- ��������� ����� ����������� �������, ��������: ����� ����������� �������,
-- ������� ������ �������������� � �.�.
IP SP.G.TMACRO_PARS;
-- ������ �������� ���������� (������ TValue). 
-- ����� ���������� ���� ������ ���� ������ �������� ���������,
-- ������������ ����� ���������.
OPa SP.G.TMACRO_PARS;
-- ������ ��������, ������������ � �������� "GET_OBJECTS".
-- ������ ��������� ����� ��������� � ��� ���������� ������ ���������.
OBJECTS SP.G.TOBJECTS;
-- ������ ������, ������������ � �������� "GET_SYSTEMS".
-- ������ ��������� ����� ��������� � ��� ���������� ������ ���������.
SYSTEMS SP.G.TOBJECTS;
-- ������ ��������� ��������, ������������ � �������� "GET_SELECTED".
-- ����� ���� � ������ ������� �� IMan-� ���� ������ �������� 
-- ��������� ������������� ������� ������.
-- ������ ��������� ����� ��������� � ��� ���������� ������ ���������.
SELECTED SP.G.TOBJECTS;
-- ������ ������� ���������� ��� ������������ "FOR_PARS_IN".
IPs SP.G.TOBJECTS;
-- ��������� ������� ������ (������ IP ��� ������ �������� TValue).
MOPs SP.G.TMODEL_PARS;
-- ��������� ������� ��������.
�OPs SP.G.TCATALOG_PARS;
-- ��������� �� ������.
EM SP.V_COMMANDS.COMMENTS%type;
-- ��� ���������� �������������� IMan ������������ �������� ������ �����.
-- ���������� ExecutionPoint ������ ��� ����������� ����� �����������
-- ���������� ������ ��� ��������� ������.
ExecutionPoint PLS_INTEGER;
-- ������������� ����������.
-- ���������� ��������� �� ������� ����������� ������ ��������������.
CurLine PLS_INTEGER;
-- ������ ������� ��� ���������� ������� "FOR_RARS_IN".
CurIndex BINARY_INTEGER;
-- ���� ���������� ������� �������� �������.
CreateComposit BOOLEAN;
-- ������ ���������� ������ ���������� � ������� ������.
-- (��� ���������� ������� "FOR_SYSTEMS").
CurSystem BINARY_INTEGER;
-- ������ ���������� ������ ���������� � ������� ��������� �������� ������.
-- (��� ���������� ������� "FOR_SELECTED").
CurSelected BINARY_INTEGER;
-- ������ ���������� ������ ���������� � ������� ��������.
-- (��� ���������� ������� "FOR_OBJECTS").
CurObject BINARY_INTEGER;
-- ���� ������ �������������� ������ ����������� ������,
-- �� ������ ���������� �������� ��������� ������� ���������.
-- ���� ������ �������������� - ����� ��� "MACRO", �� ������ ����.
-- ��� �������� �� ��������������, ���� ����� ���������� ���������� �
-- ������ OPa
Composit SP.G.TMACRO_PARS;

-- ������� �������� ���������� ��������, ���������������� � ��������
-- For_Pars_IN, For_Objects, For_Selected, For_Systems, ��� �������� �
-- ���������� ����.
-- ��� ������ �������� � �������� Create_Object, Change_Parent, Rename,
-- Execute, Update_Notes.
-- ��� ��������� ����� ����� ���������� �������� � ���������� ���������
-- SKIP_EXECUTION.
F_SKIP_EXECUTION BOOLEAN;
-- ������� ������ �� ����� � �������� For_Pars_IN, For_Objects, For_Selected,
-- For_Systems ��� ���� ��������, ��������������� �� ������ ���� ������� 
-- ����� ���������. ��� ������ �� ����� ��� ���������� �������� ����������
-- ������������� ������� � ���������� ��������� SKIP_EXECUTION.
-- ��� ��������� ����� ����� ���������� ��������  � ���������� ���������
-- EXIT_LOOP.
-- ����� ��������� EXIT_LOOP �� ���������������� ���������� �������� �����
-- ������������!
-- ��� ������ �� ���������� (������) ����� ������������ ������� pls "exit".
F_EXIT_LOOP BOOLEAN;
-- ������� ���������� �������� ������ ����� CASE.
CASE_EXECUTED BOOLEAN;

MacroName constant VARCHAR2(128):=''MACRO##NAME'';

-- ��������� ���������� ������. ��������  � �������� ��������� ������,
-- ���������� ���������� s, ��� ������� ��������������
-- � ����� ������������ � ��������������.
PROCEDURE dprn(s VARCHAR2);

-- ��������� ������� �������������� ������������. �������������� ���������� �
-- ��������� ���� ������, � �� � �������� ������ ���������, ��� ��� ����������
-- ������. 
PROCEDURE WARNING(s VARCHAR2);

-- ������ ���������� ������ ��� ���������,
-- ������� ������ ������ ��������������.
FUNCTION Get_Composit_Name  return VARCHAR2;

-- ������ ��������� ����������� ���������� ������ ����������������������� �
-- ���������� ������������� �������, ������� �������������������
-- ��������������, ���������������� ������ ��� IMan�.
FUNCTION get_COMMAND return NUMBER;

end MMACRO##ID;
  ';
  -- �������� ��������� ������� �� ��������.
  MP:=replace(MP,'MACRO##ID',to_.STR(MACRO_ID));
  MP:=replace(MP,'MACRO##NAME',MacroName);
  MP:=replace(MP,'##NOW',to_.STR(sysdate));
  -- ����������� �����.
  begin
    execute immediate(MP);
  exception
    -- ���� ���������� �� �������, �� ���������� ������.
    when others then
      EM:='SP.B.COMPILE_MACRO. '||SQLERRM;
      return EM;
  end;
  -- ������������� ��������� ����� �� ���������� ������.
  execute immediate('
    grant execute on SP_IM.M'||to_.STR(MACRO_ID)||' to public
                    ');
  EM:='';                  
  return EM;  
end COMPILE_MACRO;

-------------------------------------------------------------------------------
FUNCTION COMPILE_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2) 
return VARCHAR2
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'COMPILE_MACRO_BODY');
  if tmpVar>0 then
    EM:=COMPILE_MACRO_BODY(tmpVar);
  end if;    
  return EM;
end COMPILE_MACRO_BODY;

-------------------------------------------------------------------------------
FUNCTION COMPILE_MACRO_BODY(MACRO_ID IN NUMBER) return VARCHAR2
is
  ALL_MP DBMS_SQL.VARCHAR2A;
  -- ������ ������ � ������� SP.MACROS ������������� � ���� ����.
  -- ���������� MP_NUM ������������� ���� LINE � �������������� ������.
  MP VARCHAR2(32000);
  tmpVar NUMBER;
  i BINARY_INTEGER;
  MacroName VARCHAR2(4000);
  InsideCASE BOOLEAN;
  EM SP.COMMANDS.COMMENTS%type;
  -- �������� ������� ���� ������, ������������ ��� ������������� �������
  -- ���� ������.
  function EmptyMacro(MACRO_ID IN NUMBER)return VARCHAR2
  is  
    MP SP.COMMANDS.COMMENTS%type;
    MacroName VARCHAR2(4000);
    -- �������� ������ ������� ������ 
    begin
      MP := '
  CREATE OR REPLACE PACKAGE BODY SP_IM.M'||to_char(MACRO_ID)||'
  -- ������ ������ ����� 
  -- recreate '||to_char(sysdate)||'
  AS
--
   function Get_Composit_Name  return VARCHAR2
   is 
    begin
      return Composit(''NAME'').asString;
    end;
--    procedure SKIP_EXECUTION
--    is 
--     begin
--       F_SKIP_EXECUTION:=true;
--     end;
--    procedure EXIT_LOOP
--    is 
--     begin
--       F_EXIT_LOOP:=true;
--     end;
  /';
  return(MP);   
  end EmptyMacro;
  --
  -- ��������� ��������� ������� �� ������� WHEN_OTHERS_END_CASE. 
  procedure goto_EndCase(CLINE in NUMBER)
  is
  begin
    select min(LINE) into tmpVar from SP.V_MACROS
      where OBJECT_ID=MACRO_ID
        and LINE > CLINE
        and CMD_ID=SP.G.Cmd_WHEN_OTHERS_END_CASE;
    MP:=MP||to_.str||'
    -- ������ ������� ����������� ������ CASE.
    -- ������� �� ������� END_CASE
    ExecutionPoint:='||to_.str(tmpVar)||';
    CASE_EXECUTED:=true;
    ';
  exception
    when no_data_found then
      EM:='�� ������� �������, ����������� �������� CASE ����� ������: '||
           CLINE||'!';      
  end goto_EndCase;
---------  
begin
  InsideCASE:=false;
  -- ���������, ��� �������������� ����������.
 begin
   select FULL_NAME into MacroName from SP.V_OBJECTS 
     where ID=MACRO_ID 
       and KIND_ID in (SP.G.MACRO_OBJ, SP.G.COMPOSITE_OBJ);
 exception
   when no_data_found then
     EM:='SP.B.COMPILE_MACRO_BODY. '||
         '������� � ���������������: '||MACRO_ID||' �� ����������!';
     return EM;   
 end;
  -- ���������, ��� ����� ����������.
  --!!!
  -- ������ ��� ������� ������� ����������� � �������� FUNCTION.
  for ma in (select * from SP.V_MACROS 
              where OBJECT_ID= MACRO_ID
                and CMD_ID = SP.G.Cmd_FUNCTION
                and CONDITION is null
                and MACRO is not null 
              order by LINE)
  loop
    if ma.ALIAS is null then 
      EM:='������ � ������ '||ma.LINE||
          '. ���������� ������ ��� ��� ������� � ����  ALIAS.';
      return EM;    
    end if;
    MP:=
'CREATE OR REPLACE FUNCTION SP_IM.F_##ALIAS'||to_.STR||'
/* function declared at line ##LINE of MACRONAME##
  recreate ##NOW */
MACRO##
';
    MP:=replace(MP,'##ALIAS',ma.ALIAS);
    MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
    MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
    MP:=replace(MP,'MACRONAME##',MacroName);
    MP:=replace(MP,'##NOW',to_.STR(sysdate));
    -- ����������� �������.
    begin
      execute immediate(MP);
    exception
      -- ���� ���������� �� �������, �� ���������� ������.
      when others then
        EM:='������ �������� ������� � ������ ('||ma.LINE||') => '||SQLERRM;
        return EM;
    end;
    -- ������������� ��������� ����� �� ���������� ��������� �������
    -- � ������ � ��������� ��������.
    begin
      execute immediate('
      grant execute on SP_IM.F_'||ma.ALIAS||' to public
                    ');
    exception
      -- ���� �������������� ������ �� �������, �� ���������� ������.
      when others then
        EM:='������ �������������� ������ ������� � ������'||ma.LINE
        ||'  '||SQLERRM;
        return EM;
    end;
    begin
      execute immediate('
      create or replace public synonym F_'||ma.ALIAS||' for SP_IM.F_'||
      ma.ALIAS
                       );
    exception
      -- ���� �������� ���������� �������� �� �������, �� ���������� ������.
      when others then
        EM:='������ �������� �������� ������� � ������'||ma.LINE
        ||'  '||SQLERRM;
        return EM;
    end;
  end loop;
  -- �������� ���� ������.
  -- �������� ���������.
  MP:='CREATE OR REPLACE PACKAGE BODY SP_IM.MMACRO##ID'||to_.STR||'
-- MACRO##NAME package body
-- recreate ##NOW
AS
-- ������ ���������� ��� �������� �����, ������������������ �� �� ��������.
TYPE TLINES is table of NUMBER index by VARCHAR2(60);
LINES TLINES;
  ';
  -- �������� ������ ������� ���������� � ��������� � ������ �����������.
  for ma in (select * from SP.V_MACROS 
              where OBJECT_ID= MACRO_ID
                and CMD_ID= SP.G.Cmd_DECLARE 
              order by LINE)
  loop
    MP:=MP||to_.STR||'-- Declare in LINE '||to_.STR(ma.LINE);
    MP:=MP||to_.STR||ma.MACRO||to_.STR;
  end loop;

  -- �������� ������ ������� ���������� ������� � ��������� � ������
  -- �����������.
  for ma in (select * from SP.V_MACROS 
              where OBJECT_ID= MACRO_ID
                and CMD_ID= SP.G.Cmd_DECLARE_F 
              order by LINE)
  loop
    MP:=MP||to_.STR||'-- Declare in LINE '||to_.STR(ma.LINE);
    MP:=MP||to_.STR||ma.MACRO||to_.STR;
  end loop;
 
  -- �������� ��������� ������� �� ��������.
  MP:=replace(MP,'MACRO##ID',to_.STR(MACRO_ID));
  MP:=replace(MP,'MACRO##NAME',MacroName);
  MP:=replace(MP,'##NOW',to_.STR(sysdate));
  
  
  -- �������� ������ GET_COMMAND
  MP:=MP||to_.STR||' 
FUNCTION get_COMMAND return NUMBER
is 
result NUMBER;
tmpName VARCHAR2(128);
commandNum NUMBER;
procedure SKIP_EXECUTION
is 
begin
  F_SKIP_EXECUTION:=true;
end;
procedure EXIT_LOOP
is 
begin
  F_EXIT_LOOP:=true;
end;
begin
  commandNum:=0;
  loop
    -- �������� ������������ ��������������.
    commandNum:=commandNum+1;
    if commandNum > 100000 then
      SP.M.RT_MACRO_ERROR(MacroName, ExecutionPoint, 
      ''������������ ��� ���������� ��������� �������!'');
      return g.Cmd_CANCEL;
    end if;           
    case ExecutionPoint 
     -- ����� ���������� ��� ����� ������������ � ��������������.
  ';
  -- ���������� �� ��� ��������� � �������������� ������ � ������� ����.
  ALL_MP(0):=MP;
  MP:='';
  -- ���� � �������������� ����������� ������, �� ����� � �������.
  select count(*) into tmpVar from dual 
    where exists (select * from SP.V_MACROS where OBJECT_ID=MACRO_ID);
  if tmpVar=0 then
    EM:='SP.B.COMPILE_MACRO_BODY. '||
        '� �������������� '||MacroName||' ����������� ������������!';
    return EM;
  end if;    
  -- ��������� ���� �� �������������, ������������ ��������������.
  -- ������� ������������� ���������� ���� ������ ��� ���������
  -- ��������������.
  for ma in (select ID, PREV_ID, OBJECT_ID, OBJECT_FULL_NAME, ALIAS, 
    COMMENTS, LINE, CMD_NAME, CMD_ID, USED_OBJECT_FULL_NAME, 
   USED_OBJECT_ID, USED_OBJECT_KIND_NAME, USED_OBJECT_KIND_ID, MACRO,
     decode(CONDITION,null,null,'('||CONDITION||')')  CONDITION
  from SP.V_MACROS
  where OBJECT_ID=MACRO_ID order by LINE)
  loop
    case 

-- CALCULATE
--*************
       when ma.CMD_ID=SP.G.Cmd_Calculate then
        MP:='
     when ##LINE then   
       CurLine:= ##LINE;
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� �������, ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           begin
        ';
       -- ���� ������ ������� ����������� ������ ����� �ASE,
       -- �� ���������� ��������� ������� �� ������� WHEN_OTHERS_END_CASE 
       if InsideCASE then goto_EndCase(ma.LINE); end if;
       -- ���������� ���������� ���� ������� Calculate.
       MP:=MP||to_.STR||'    
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
         exception
           when others then
             -- ������������� ������.
             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
             return g.Cmd_CANCEL;
         end;
        end if;
       exception
         when others then
           -- ������������� ������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCondition: ''||SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        
-- CANCEL
--*************
      when ma.CMD_ID=SP.G.Cmd_CANCEL then
        MP:='
     when ##LINE then 
       CurLine:= ##LINE;  
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� ��������� �����, ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           begin
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
             -- ���������� ��������� �� ������, ���� ��� ������������. 
             SP.IM.EM:=MacroName||'' ��������� ������� CANCEL � ������ ''||
                     to_char(##LINE)||'' � ����������: ''||EM;
             return g.Cmd_CANCEL;
         exception
           when others then
             -- ������������� ������, ��������� ��� ���������� ����������.
             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
             return g.Cmd_CANCEL;
         end;
         end if;
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));

-- RETURN
--*************
      when ma.CMD_ID=SP.G.Cmd_Return then
        MP:='
     when ##LINE then
       CurLine:= ##LINE;   
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� ����� �� ��������������, 
       -- ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           begin
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
             -- ���� �� �� ������� ����� ��������,
             -- �� ������� � �������,
             -- ����� ������� � ���������, � ��������� ����� ����������.
             return g.Cmd_RETURN;
         exception
           when others then
             -- ������������� ������, ��������� ��� ���������� ����������.
             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
             return g.Cmd_CANCEL;
         end;
         end if;
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));

-- GO_TO
--*************
       when ma.CMD_ID=SP.G.Cmd_GO_TO then
        MP:='
     when ##LINE then   
       CurLine:= ##LINE;
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� �������, ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           -- ������������ ��������� ������ ��������.
           -- ������������ ����� ������ ��������.
           -- ���������, ��� ������� �� �������������� ����� CASE.
           begin
-- ��������� ���� ��������.
-- MacroLine ##LINE
tmpName:=MACRO##;
            exception
             when no_data_found then
               SP.M.RT_MACRO_ERROR(MacroName, ##LINE, 
                ''�� �������� ������� �� ������ ''||tmpName||''!'');
               return g.Cmd_CANCEL;
            end;  
            ExecutionPoint:=LINES(upper(tmpName));
         end if;
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));


-- CASE
--*************
       when ma.CMD_ID=SP.G.Cmd_CASE then
        InsideCASE:=true;
        MP:='
     when '||to_.STR(ma.LINE)||' then   
       ExecutionPoint:=ExecutionPoint+1;
       CASE_EXECUTED:=false;
        ';


-- WHEN_OTHERS_END_CASE
--*************
       when ma.CMD_ID=SP.G.Cmd_WHEN_OTHERS_END_CASE then
         InsideCASE:=false;
        MP:='
     when ##LINE then
       CurLine:= ##LINE;		   
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� �������, ���� �� ���� ���� �� ��� ��������.
       begin
         if not CASE_EXECUTED then
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
         end if;
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� ����������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
           return g.Cmd_CANCEL;
       end;
        CASE_EXECUTED:=false;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
      
-- PLAY 
-- GET_OBJECTS
-- GET_FULL_OBJECTS
-- GET_SYSTEMS
-- GET_SELECTED
-- CLEAR_SELECTED
-- GET_ALL_SYSTEMS
-- GET_ALL_FULLOBJECTS
-- GET_ALL_OBJECTS
-- GET_USER_INPUT
-- DELETE_OBJECT 
-- CHANGE_PARENT
-- RENAME
-- UPDATE_PARENT
-- GET_PARS
-- SET_PARS
-- IS_OBJECT_EXIST
-- SET_ROOT 
-- MODEL3D_COMMIT 
-- MODEL3D_ROLLBACK 
-- MODEL3D_REFRESH
-- SET_GPARS_VALS
-- TOGGLE_SERVER 
-- Reload_Model
--*************
      when ma.CMD_ID 
        in(SP.G.Cmd_PLAY, SP.G.Cmd_GET_OBJECTS, SP.G.Cmd_GET_FULL_OBJECTS,
           SP.G.Cmd_GET_SYSTEMS,
           SP.G.Cmd_GET_PARS, SP.G.Cmd_SET_PARS,
           SP.G.Cmd_DELETE_OBJECT, SP.G.Cmd_SET_ROOT,
           SP.G.Cmd_GET_ALL_SYSTEMS,
           SP.G.Cmd_GET_ALL_OBJECTS,
           SP.G.Cmd_GET_ALL_FULLOBJECTS,
           SP.G.Cmd_GET_SELECTED,
           SP.G.Cmd_GET_USER_INPUT,
           SP.G.Cmd_MODEL3D_COMMIT, SP.G.Cmd_Model3D_Rollback,
           SP.G.Cmd_Model3D_Flush,
           SP.G.Cmd_MODEL3D_REFRESH, SP.G.Cmd_Change_Parent,
           SP.G.Cmd_Rename, SP.G.Cmd_Update_Notes,
           SP.G.Cmd_Clear_Selected, SP.G.Cmd_Is_Object_Exist,
           SP.G.Cmd_Set_GPars_Vals, SP.G.Cmd_Toggle_Server,
           SP.G.Cmd_Reload_Model) 
      then
        MP:='
     when ##LINE then
       CurLine:= ##LINE;   
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� �������, ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           begin
        ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� ������� WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||' 
             F_SKIP_EXECUTION:= false;   
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
	         -- ���� ���������� ���� �������� ��������,
	         -- �� �������� ������ ����������,
	         -- ��� � � ������ ���������� ��������,
	         -- � ��������� � ��������� �������.
	         if F_SKIP_EXECUTION then
	           IP.delete;
	           return SP.G.Cmd_Execute_Macro; 
	         end if;  
	         -- ��������� �������.
	         return ##Cmd;
         end if;
       exception
         when others then
           -- ������������� ������.
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
 
-- EXECUTE
--*************
      when ma.CMD_ID = SP.G.Cmd_EXECUTE 
      then
        if ma.USED_OBJECT_ID is null then
          EM:='SP.B.COMPILE_MACRO_BODY. '
            ||'� ������'||to_.STR(ma.LINE)
            ||'�� ����� ������ ��� ������� "EXECUTE"!';
          return EM;        
        end if;
        MP:='
     when ##LINE then
       CurLine:= ##LINE;   
       ExecutionPoint:=ExecutionPoint+1;
       -- ��������� �������, ���� ������� �� ���������� ��� ���������.
       begin
         -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
         if (##CONDITION) then
           begin
        ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� ������� WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||' 
             F_SKIP_EXECUTION:= false; 
             SP.M.FILL_PARAMS(IP,##Obj);
  
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
	         -- ���� ���������� ���� �������� ��������,
	         -- �� �������� ������ ����������,
	         -- ��� � � ������ ���������� ��������,
	         -- � ��������� � ��������� �������.
	         if F_SKIP_EXECUTION then
	           IP.delete;
	           return SP.G.Cmd_Execute_Macro;
	         end if;  
	         -- ��������� ���������.
	         EM:=SP.M.TEST_PARAMS(IP);
	         if EM is not null then
	           -- ������������� ������.
	           SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
	           return g.Cmd_CANCEL;
	         end if;  
	         -- ��������� �������.
        ';
        if ma.USED_OBJECT_KIND_ID = SP.G.OPERATION_OBJ then
          -- ���� ��� ���������� �������� ��������
          MP:=MP||to_.STR||'
           return SP.G.Cmd_Execute;
          ';
        else  
          MP:=MP||to_.STR||'
	         SP.M.PUSH(SP.M.MacroPackage(##Obj)); 
	         return SP.G.Cmd_Execute_Macro;
          ';
        end if;  
          MP:=MP||to_.STR||'
         end if;
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));

-- CREATE_OBJECT 
--*************
      when ma.CMD_ID=SP.G.Cmd_CREATE_OBJECT then
        if ma.USED_OBJECT_ID is null then
          EM:='SP.B.COMPILE_MACRO_BODY. '
            ||'� ������'||to_.STR(ma.LINE)
            ||'�� ����� ������ ��� ������� "CREATE_OBJECT"!';
          return EM;        
        end if;
        MP:='
     when ##LINE then
       CurLine:= ##LINE;
        -- ������ ������� ������� �� ���� ������ � ������ ��������
        -- ������������ �������.
        -- �� ������ ����� ��������� �������� ������� � ������� �����
        -- ������������� ��� ������� ���������.
        -- �� ������ ����� ���������� �������������� ��������� ��� ���������
        -- �������.      
        if CreateComposit then
          -- ���� ��� ������ ����.
          CreateComposit:=false;
         ExecutionPoint:=ExecutionPoint+1;
          SP.M.PUSH(SP.M.MacroPackage(##Obj));
          return SP.G.Cmd_Execute_Macro;
        end if;   
       -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
       begin
         if not (##CONDITION) then
           ExecutionPoint:=ExecutionPoint+1;
         else
           begin  
             -- ��������� �������, ���� ������� �� ���������� ��� ���������.
        ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� ������� WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||' 
            F_SKIP_EXECUTION:= false;
            SP.M.FILL_PARAMS(IP,##Obj);

-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
           -- ���� ���������� ���� �������� ��������,
           -- �� �������� ������ ����������,
           -- ��� � � ������ ���������� ��������,
           -- � ��������� � ��������� �������.
           if F_SKIP_EXECUTION then
             IP.delete;
             ExecutionPoint:=ExecutionPoint+1;
             return SP.G.Cmd_Execute_Macro;
           end if;  
           -- ��������� ���������.
           EM:=SP.M.TEST_PARAMS(IP);
           if EM is not null then 
             SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
             return g.Cmd_CANCEL;
           end if;  
        ';
        if ma.USED_OBJECT_KIND_ID = SP.G.SINGLE_OBJ then
          -- ���� ��� ������� ������, �� ������ ������ 
          -- � ��������� � ��������� ������ ��������������.
          MP:=MP||to_.STR||'
           ExecutionPoint:=ExecutionPoint+1;
           return SP.G.Cmd_CREATE_OBJECT;
          ';
        else  
          -- ����� ������������� ������� ������� ����� � ���������� 
          -- ������� ������� ������� ��� ������� ������.
          MP:=MP||to_.STR||' 
           CreateComposit:=true;
           return SP.G.Cmd_COMPOSITE_ORIGIN; 
          ';
        end if;  
        MP:=MP||to_.STR||'    
         end if;  
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##OKIND',ma.USED_OBJECT_KIND_ID);
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));
        
         
-- FOR_SELECTED
-- FOR_SYSTEMS
-- FOR_OBJECTS
--*************
      when ma.CMD_ID in (SP.G.Cmd_FOR_OBJECTS,
                         SP.G.Cmd_FOR_SYSTEMS,
                         SP.G.Cmd_FOR_SELECTED) 
      then
        if ma.USED_OBJECT_ID is null then
          EM:='SP.B.COMPILE_MACRO_BODY. '
            ||'� ������ '||to_.STR(ma.LINE)
            ||' �� ����� ������ ��� ������� "'||to_char(ma.CMD_ID)||'"!';
          return EM;        
        end if;
        MP:='
     when ##LINE then
       CurLine:= ##LINE;
       begin
         if ##IND is null then
           -- ������ ������ ���� �������.
           -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
           -- ���� ���� CONDITON false ��� �������� ������ ����, 
           -- ��������� � ���������� ��������� ������������.
           if (##CONDITION) and (##ARR.count>0) then
             ##IND:=##ARR.first;
             F_EXIT_LOOP:=false;
           end if;
         else
           -- ��������� ������.
           if F_EXIT_LOOP then
             ##IND:=null;
           else  
             ##IND:=##ARR.next(##IND);
           end if;  
         end if;  
         if ##IND is null then
           -- ���� �������, ��������� � ��������� �������.
           ExecutionPoint:=ExecutionPoint+1;
            ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� �������
        -- WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||'
            -- ������� ������ ��������.
            --##ARR.delete;
         else
           begin  
             -- ��������� ���������.
             IP:=##ARR(##IND);
             SP.M.FILL_PARAMS(IP,##Obj);

             F_SKIP_EXECUTION:=false; 
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
           -- ��������� �������.
           if F_SKIP_EXECUTION then
             IP.delete;
             return SP.G.Cmd_Execute_Macro;
           else
             -- ��������� ���������.
             EM:=SP.M.TEST_PARAMS(IP);
             if EM is not null then
               -- ������������� ������.
               SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
               return g.Cmd_CANCEL;
             end if;  
           end if;  
	         -- ��������� �������.
        ';
        if ma.USED_OBJECT_KIND_ID = SP.G.OPERATION_OBJ then
          -- ���� ��� ���������� �������� ��������
          MP:=MP||to_.STR||'
           return SP.G.Cmd_Execute;
          ';
        else  
          MP:=MP||to_.STR||'
	         SP.M.PUSH(SP.M.MacroPackage(##Obj)); 
	         return SP.G.Cmd_Execute_Macro;
          ';
        end if;  
          MP:=MP||to_.STR||'
         end if;            
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));
        MP:=replace(MP,'##IND',
          case ma.CMD_ID 
            when SP.G.Cmd_FOR_OBJECTS then 'CurObject'
            when SP.G.Cmd_FOR_SYSTEMS then 'CurSystem'
            when SP.G.Cmd_FOR_SELECTED then 'CurSelected'
          end);
        MP:=replace(MP,'##ARR',
          case ma.CMD_ID 
            when SP.G.Cmd_FOR_OBJECTS then 'OBJECTS'
            when SP.G.Cmd_FOR_SYSTEMS then 'SYSTEMS'
            when SP.G.Cmd_FOR_SELECTED then 'SELECTED'
          end);

-- FOR_PARS_IN and null!!!
--*************
      when ma.CMD_ID=SP.G.Cmd_FOR_PARS_IN
        and
           ma.USED_OBJECT_KIND_ID is null
      then
        EM:='SP.B.COMPILE_MACRO_BODY. '
          ||'� ������ '||to_.STR(ma.LINE)
          ||' �� ����� ������ ��� ������� "FOR_PARS_IN"!';
        return g.Cmd_CANCEL;  
              
-- FOR_PARS_IN and EXECUTE (OPERATION)
--*************
      when ma.CMD_ID=SP.G.Cmd_FOR_PARS_IN
        and
           ma.USED_OBJECT_KIND_ID = SP.G.OPERATION_OBJ
      then
        MP:='
     when ##LINE then
       CurLine:= ##LINE;
       begin
         if CurIndex is null then
           -- ������ ������ ���� �������.
           -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
           -- ���� ���� CONDITON false ��� �������� ������ ����, 
           -- ��������� � ���������� ��������� ������������.
           if (##CONDITION) and (IPs.count>0) then
             CurIndex:=IPs.first;
             F_EXIT_LOOP:=false;
           end if;
         else
           -- ��������� ������.
           if F_EXIT_LOOP then
             CurIndex:=null;
           else  
             CurIndex:=IPs.next(CurIndex);
           end if;  
         end if;            
         if CurIndex is null then
           -- ���� �������, ��������� � ��������� �������.
           ExecutionPoint:=ExecutionPoint+1;
            ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� �������
        -- WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||'
           -- ������� ������ ����������.
           --IPs.delete;
         else
           begin
             -- ��������� ���������.
             IP:=IPs(CurIndex);
             SP.M.FILL_PARAMS(IP,##Obj);
             F_SKIP_EXECUTION:=false; 
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
	         -- ��������� �������.
	         if F_SKIP_EXECUTION then
	           IP.delete;
	         else
	          -- ��������� ���������.
	          EM:=SP.M.TEST_PARAMS(IP);
	          if EM is not null then
	            -- ������������� ������.
	            SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
	            return g.Cmd_CANCEL;
	          end if;  
	         end if;  
	         return SP.G.Cmd_Execute;
         end if;  
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));
        
-- FOR_PARS_IN and EXECUTE (MACRO)
--*************
      when ma.CMD_ID=SP.G.Cmd_FOR_PARS_IN
        and
           ma.USED_OBJECT_KIND_ID = SP.G.MACRO_OBJ 
      then
        MP:='
     when ##LINE then
       CurLine:= ##LINE;
       begin
         if CurIndex is null then
           -- ������ ������ ���� �������.
           -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
           -- ���� ���� CONDITON false ��� �������� ������ ����, 
           -- ��������� � ���������� ��������� ������������.
           if (##CONDITION) and (IPs.count>0) then
             CurIndex:=IPs.first;
             F_EXIT_LOOP:=false;
           end if;
         else
           -- ��������� ������.
           if F_EXIT_LOOP then
             CurIndex:=null;
           else  
             CurIndex:=IPs.next(CurIndex);
           end if;  
         end if;            
         if CurIndex is null then
           -- ���� �������, ��������� � ��������� �������.
           ExecutionPoint:=ExecutionPoint+1;
            ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� �������
        -- WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||'
           -- ������� ������ ����������.
           --IPs.delete;
         else
           begin
             -- ��������� ���������.
             IP:=IPs(CurIndex);
             SP.M.FILL_PARAMS(IP,##Obj);  
             F_SKIP_EXECUTION:=false; 
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
	         -- ��������� �������.
	         if F_SKIP_EXECUTION then
	           IP.delete;
	         else
	          -- ��������� ���������.
	          EM:=SP.M.TEST_PARAMS(IP);
	          if EM is not null then
	            -- ������������� ������.
	            SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
	            return g.Cmd_CANCEL;
	          end if;  
	           SP.M.PUSH(SP.M.MacroPackage(##Obj));
	         end if;  
	         return SP.G.Cmd_Execute_Macro;
         end if;  
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));
        
-- FOR_PARS_IN and (CREATE_SINGLE or CREATE_COMPOSITE)
--*************
      when ma.CMD_ID=SP.G.Cmd_FOR_PARS_IN 
        and
           ma.USED_OBJECT_KIND_ID != SP.G.MACRO_OBJ 
      then
        MP:='
     when ##LINE then
     CurLine:= ##LINE;
        ';
        if ma.USED_OBJECT_KIND_ID = SP.G.COMPOSITE_OBJ then
        MP:=MP||to_.STR||'
       -- ������ ���� ���� ������� ������� �� ���� ������
       -- � ������ �������� ������������ �������.
       -- �� ������ ����� ��������� �������� ������� � ������� �����
       -- ������������� ��� ������� ���������.
       -- �� ������ ����� ���������� �������������� ��������� ��� ���������
       -- �������.      
       if CreateComposit then
         -- ���� ��� ������ ����.
         CreateComposit:=false;
         SP.M.PUSH(SP.M.MacroPackage(##Obj));
         return SP.G.Cmd_Execute_Macro;
       end if;
        ';
        end if;  
        MP:=MP||to_.STR||'
       begin
         if CurIndex is null then
           -- ������ ������ ���� �������.
           -- ���� ���� CONDITION ����, �� ������ ��������� ����� true.
           -- ���� ���� CONDITON false ��� �������� ������ ����, 
           -- ��������� � ���������� ��������� ������������.
           if (##CONDITION) and (IPs.count>0) then
             CurIndex:=IPs.first;
             F_EXIT_LOOP:=false;
           end if;
         else
           -- ��������� ������.
           if F_EXIT_LOOP then
             CurIndex:=null;
           else  
             CurIndex:=IPs.next(CurIndex);
           end if;  
         end if;  
         if CurIndex is null then
           -- ���� �������, ��������� � ��������� �������.
           ExecutionPoint:=ExecutionPoint+1;
            ';
        -- ���� ������ ������� ����������� ������ ����� �ASE,
        -- �� ���������� ��������� ������� �� �������
        -- WHEN_OTHERS_END_CASE 
        if InsideCASE then goto_EndCase(ma.LINE); end if;
        -- ���������� ���������� ���� �������.
        MP:=MP||to_.STR||'
           -- ������� ������ ����������.
           -- IPs.delete;
         else
           begin  
             -- ��������� ���������.
             IP:=IPs(CurIndex);
             SP.M.FILL_PARAMS(IP,##Obj);  
             F_SKIP_EXECUTION:=false; 
-- ��������� ���� ��������.
-- MacroLine ##LINE
MACRO##
	         exception
	           when others then
	             -- ������������� ������, ��������� ��� ���������� ����������.
	             SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inMACRO: ''||SQLERRM);
	             return g.Cmd_CANCEL;
	         end;
           -- ��������� �������.
        ';
        if ma.USED_OBJECT_KIND_ID = SP.G.SINGLE_OBJ then
          -- ���� ��� ������� ������, �� ������ ������.
          MP:=MP||to_.STR||'
           if F_SKIP_EXECUTION then
             IP.delete;
             return SP.G.Cmd_Execute_Macro;
           else  
            -- ��������� ���������.
            EM:=SP.M.TEST_PARAMS(IP);
            if EM is not null then
              -- ������������� ������.
              SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
              return g.Cmd_CANCEL;
            end if;  
             return SP.G.Cmd_CREATE_OBJECT;
           end if;  
          ';
        else  
          -- ������������� ������� ������� ����� � ����������
          -- ������� ������� ������� ��� ������� ������.
          MP:=MP||to_.STR||' 
           if F_SKIP_EXECUTION then
             IP.delete;
             return SP.G.Cmd_Execute_Macro;
           else  
            -- ��������� ���������.
            EM:=SP.M.TEST_PARAMS(IP);
            if EM is not null then
              -- ������������� ������.
              SP.M.RT_MACRO_ERROR(MacroName, ##LINE, EM);
              return g.Cmd_CANCEL;
            end if;  
             CreateComposit:=true;
             return SP.G.Cmd_COMPOSITE_ORIGIN; 
           end if;  
          ';
        end if;  
        MP:=MP||to_.STR||'
         end if;            
       exception
         when others then
           -- ������������� ������, ��������� ��� ���������� �������.
           SP.M.RT_MACRO_ERROR(MacroName, ##LINE,''inCONDITION: ''|| SQLERRM);
           return g.Cmd_CANCEL;
       end;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##CONDITION',nvl(ma.CONDITION,'true'));
        MP:=replace(MP,'MACRO##',nvl(ma.MACRO,'null;'));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));
        MP:=replace(MP,'##Obj',to_char(ma.USED_OBJECT_ID));
        
-- DECLARE, DECLARE_F, FUNCTION
--*************
      when ma.CMD_ID in (SP.G.Cmd_DECLARE, SP.G.Cmd_DECLARE_F,
                         SP.G.Cmd_FUNCTION) 
      then
        MP:='
     when ##LINE then
       CurLine:= ##LINE; 
       -- ##Cmd - ��������� � ��������� �������.  
       ExecutionPoint:=ExecutionPoint+1;
        ';
        -- �������� ��������� ������� �� ��������.
        MP:=replace(MP,'##LINE',to_.STR(ma.LINE));
        MP:=replace(MP,'##Cmd',to_char(ma.CMD_ID));

-- ������� �� �������!!!
--*************
    else
      EM:='SP.B.COMPILE_MACRO_BODY. '||'����������� ������� '||ma.CMD_ID||'!';
      return EM;
    end case;
    -- ���� ������ �� ������, �� ��������� � � ���� ������, ����� ����
    -- �������.
    if MP is not null then
      ALL_MP(ma.LINE):=MP;
      MP:=null;
    end if;
  end loop;
  -- ��������� �������������� ������.
  MP:='
     else 
        -- ������������ �� ��������������;
        return g.Cmd_RETURN;
   end case;  
  end loop;
end;
  ';
-- ��������� ������� Get_Composit_Name.
 MP:=MP||to_.STR||'    
FUNCTION Get_Composit_Name  return VARCHAR2
is 
begin
  return Composit(''NAME'').asString;
end;
  ';
-- ��������� ��������� prnt.
 MP:=MP||to_.STR||'    
PROCEDURE dprn(s VARCHAR2)
is
begin
  print(MacroName||''-''||TO_.STR(CurLine)||'': ''||s);
end;
  ';
-- ��������� ��������� WARNING.
 MP:=MP||to_.STR||'    
PROCEDURE WARNING(s VARCHAR2)
is
begin
  SP.IM.WM:=s;
end;
  ';
  -- ��������� ������ �������������.
  MP:=MP||to_.STR||'    
begin 
-- ��������� ������ ��������� ���������.
  null;
  ';
  -- ��������� ������ ��������� ���������.
  -- ��������� ������ �������� - ��� ������ �� ���������� ����������� ���
  -- ����������� CASE � ������� ��������� �� ������ ����.
  InsideCASE:=false;
  for ma in (select * from SP.V_MACROS where OBJECT_ID=MACRO_ID 
             order by LINE)
  loop 
    if not InsideCASE and (ma.ALIAS is not null) then             
      MP:=MP||to_.STR||'
  LINES('''||upper(ma.ALIAS)||'''):='||to_.str(ma.LINE)||';        
                       ';
    end if;
    if ma.CMD_ID=SP.G.Cmd_CASE then
      InsideCASE:=true;
    end if;
    if ma.CMD_ID=SP.G.Cmd_WHEN_OTHERS_END_CASE then
      InsideCASE:=false;
    end if;
  end loop;
  MP:=MP||to_.STR||'end;';
  -- ��������� �������������� ������ � ���� ������.
  i:=ALL_MP.last+1;
  ALL_MP(i):=MP;
  -- ���������� ������ ���������� ������
--   d(  'first:'||to_char(ALL_MP.first)
--     ||', last:'||to_char(ALL_MP.last)||'.',
--     'Compile Body');
-- 	begin
-- 	  i:=ALL_MP.first;
-- 	  while i <= ALL_MP.last 
-- 	  loop
-- 	    d(to_char(i),'Compile Body');
-- 	    d(ALL_MP(i),'Compile Body');
-- 	    i:=i+1;
-- 	  end loop;
-- 	exception
-- 	  when no_data_found then
-- 	    return 'SP.B.COMPILE_MACRO_BODY. '||
-- 	           '� �������������� ������ ����� �����������������'||
-- 	           ' ��� ���������� �� � �������!';
-- 	  when others then
-- 	    return 'SP.B.COMPILE_MACRO_BODY. '||sqlerrm;     
-- 	end; 
	--
  -- �����������.
  begin
    DECLARE
    c INTEGER;
    BEGIN
      c:= DBMS_SQL.OPEN_CURSOR;
      -- DDL statements are run by the parse call,
      -- which performs the implied commit.
      DBMS_SQL.PARSE(c,ALL_MP,ALL_MP.first,ALL_MP.last,true, DBMS_SQL.NATIVE);
      DBMS_SQL.CLOSE_CURSOR(c);
    EXCEPTION
      WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(c);
        if SQLCODE=24344 then
          EM:=SQLERRM;
          -- !!! ����� ��������� ��� � ���� "VALID"
          return null;
        else
          EM:='SP.B.COMPILE_MACRO_BODY. '||SQLERRM;
          return EM;
        end if;  
    END;
  end; 
  return EM;  
end COMPILE_MACRO_BODY;

-------------------------------------------------------------------------------
FUNCTION COMPILE_ALL return NUMBER
is
EM SP.COMMANDS.COMMENTS%type;
tmpVar NUMBER;
begin
  tmpVar:=0;
  for m in (select ID, Name from SP.OBJECTS 
              where (OBJECT_KIND = SP.G.COMPOSITE_OBJ)
                or  (OBJECT_KIND = SP.G.MACRO_OBJ))
  loop
    EM:=COMPILE_MACRO(m.ID);
    if EM is null then
      EM:=COMPILE_MACRO_BODY(m.ID);
    end if;
    if EM is not null then
      tmpVar:=tmpVar+1;
      EM:=null;
    end if;    
  end loop;
  return tmpVar;
end COMPILE_ALL;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_LISTING_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
  return CLOB
is
  tmpVar NUMBER;
  c CLOB;
  tmpS SP.COMMANDS.COMMENTS%type;
begin
  EM:='';
  tmpVar:=SP.MO.GET_CATALOG_OBJECT(MACRO_FULL_NAME);
  if tmpVar=0 then
    return null;
  end if;    
  DBMS_LOB.createtemporary(c,true,12); 
  tmpS := MACRO_FULL_NAME||to_.str||to_.str;   
  DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
  for e in (select RPAD(nvl(Alias, ' '),20,' ')||' | ' ||Condition S1,
                   to_char(Line,'0009')||' | '||RPAD(CMD_Name,25,' ')||'  '||
                   Used_Object_Full_Name s2,
                   Comments, Macro
            from SP.V_MACROS 
              where OBJECT_ID = tmpVar
              order by line  
            )
  loop
    if trim(e.S1) != '|' then
      tmpS := e.S1||to_.str;
      DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
      tmpS :=
      '-----------------------------------------------------------------'
      ||to_.str;
      DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
    end if;  
    tmpS := e.S2||to_.str;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
    tmpS :=
    '-----------------------------------------------------------------';
--    ||to_.str;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
    if e.Comments is not null then
      tmpS := to_.str||e.Comments||to_.str;
      DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
      tmpS :=
      '-----------------------------------------------------------------';
      DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
    end if;  
    tmpS := to_.str||e.Macro||to_.str||to_.str;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
  end loop;
  return c;
exception
  when no_data_found then return null;  
end MACRO_BODY_LISTING_AS_CLOB;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
return CLOB
is
  tmpVar NUMBER;
  c CLOB;
  tmpS SP.COMMANDS.COMMENTS%type;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'MACRO_BODY_SOURCE_AS_CLOB');
  if tmpVar=0 then
    return null;
  end if;    
  DBMS_LOB.createtemporary(c,true,12);    
  for e in (select text from DBA_SOURCE 
              where upper(OWNER)=upper('SP_IM')
                and upper(NAME)=upper('M'||to_char(tmpVar)) 
                and type='PACKAGE BODY'
              order by line  
            )
  loop
    tmpS:=e.text;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
  end loop;
  return c;
exception
  when no_data_found then return null;  
end MACRO_BODY_SOURCE_AS_CLOB;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_SOURCE(MACRO_FULL_NAME IN VARCHAR2) 
return SP.TSOURCE pipelined
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'MACRO_BODY_SOURCE');
  if tmpVar=0 then
    return;
  end if;    
  --   
  for e in (select line, text from DBA_SOURCE 
              where upper(OWNER)=upper('SP_IM')
                and upper(NAME)=upper('M'||to_char(tmpVar)) 
                and type='PACKAGE BODY'
              order by line  
            )
  loop
    pipe row(SP.TSOURCE_LINE(e.LINE, e.TEXT));
  end loop;
  return;
exception
  when no_data_found then return;  
end MACRO_BODY_SOURCE;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_SOURCE(MACRO_ID IN NUMBER) return SP.TSOURCE pipelined
is
begin
  for e in (select line, text from DBA_SOURCE 
              where upper(OWNER)=upper('SP_IM')
                and upper(NAME)=upper('M'||to_char(MACRO_ID)) 
                and type='PACKAGE BODY'
              order by line  
)
  loop
    pipe row(SP.TSOURCE_LINE(e.LINE, e.TEXT));
  end loop;
  return;
exception
  when no_data_found then return;  
end MACRO_BODY_SOURCE;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_ERRORS(MACRO_NAME IN VARCHAR2) 
return SP.TERROR_RECORDS pipelined
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_NAME,'MACRO_BODY_ERRORS');
  if tmpVar=0 then
    return;
  end if;    
  for e in (select OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE from DBA_ERRORS 
            where upper(OWNER)=upper('SP_IM')
              and upper(NAME)=upper('M'||to_char(tmpVar)) 
            order by ATTRIBUTE,SEQUENCE)
  loop
    pipe row(SP.TERROR_REC(e.OWNER, e.NAME, e.TYPE, e.LINE, e.POSITION,
                           e.TEXT, e.ATTRIBUTE));
  end loop;
  return;
end MACRO_BODY_ERRORS;

-------------------------------------------------------------------------------
FUNCTION MACRO_BODY_ERRORS(MACRO_ID IN NUMBER) 
  return SP.TERROR_RECORDS pipelined
is
begin
  for e in (select OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE from DBA_ERRORS 
            where upper(OWNER)=upper('SP_IM')
              and upper(NAME)=upper('M'||to_char(MACRO_ID)) 
            order by ATTRIBUTE,SEQUENCE)
  loop
    pipe row(SP.TERROR_REC(e.OWNER, e.NAME, e.TYPE, e.LINE, e.POSITION,
                           e.TEXT, e.ATTRIBUTE));
  end loop;
  return;
exception
  when no_data_found then return;  
end MACRO_BODY_ERRORS;

-------------------------------------------------------------------------------
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_FULL_NAME IN VARCHAR2) 
return SP.TERROR_RECORDS pipelined
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'MACRO_FUNCTION_ERRORS');
  if tmpVar=0 then
    return;
  end if;    
  for e in (select OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE from DBA_ERRORS 
            where upper(OWNER)=upper('SP_IM')
              and upper(NAME)in
              (select 'F_'||upper(ALIAS) from SP.MACROS 
                 where OBJ_ID=tmpVar and Cmd_ID=SP.G.Cmd_FUNCTION )
            order by ATTRIBUTE,SEQUENCE)
  loop
    pipe row(SP.TERROR_REC(e.OWNER, e.NAME, e.TYPE, e.LINE, e.POSITION,
                           e.TEXT, e.ATTRIBUTE));
  end loop;
  return;
end MACRO_FUNCTION_ERRORS;

-------------------------------------------------------------------------------
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_ID IN NUMBER) 
  return SP.TERROR_RECORDS pipelined
is
begin
  for e in (select OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE from DBA_ERRORS 
            where upper(OWNER)=upper('SP_IM')
              and upper(NAME)in
              (select 'F_'||upper(ALIAS) from SP.MACROS 
                 where OBJ_ID=MACRO_ID and Cmd_ID=SP.G.Cmd_FUNCTION )
            order by ATTRIBUTE,SEQUENCE)
  loop
    pipe row(SP.TERROR_REC(e.OWNER, e.NAME, e.TYPE, e.LINE, e.POSITION,
                           e.TEXT, e.ATTRIBUTE));
  end loop;
  return;
exception
  when no_data_found then return;  
end MACRO_FUNCTION_ERRORS;

-------------------------------------------------------------------------------
PROCEDURE DROP_MACRO
is
begin
  raise_application_error(-20033,
    'SP.B.DROP_MACRO. �� �����������!');
end DROP_MACRO;

-------------------------------------------------------------------------------
PROCEDURE DROP_MACRO(MACRO_FULL_NAME IN VARCHAR2) 
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'DROP_MACRO');
  if tmpVar=0 then
    return;
  end if;    
  DROP_MACRO(tmpVar);
exception
  when no_data_found then null;   
end DROP_MACRO;

-------------------------------------------------------------------------------
PROCEDURE DROP_MACRO(MACRO_ID IN NUMBER)
is
tmpVar NUMBER;
begin
  select count(*) into tmpVar from ALL_PROCEDURES ap 
   where (ap.OBJECT_NAME='M'||to_char(MACRO_ID)) and (ap.OWNER='SP_IM');
 if tmpVar>0 then
    execute immediate('DROP PACKAGE SP_IM.M'||to_char(MACRO_ID));
  else
    commit;  
  end if;  
end DROP_MACRO;

-------------------------------------------------------------------------------
PROCEDURE DROP_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2) 
is
  tmpVar NUMBER;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'DROP_MACRO_BODY');
  if tmpVar=0 then
    return;
  end if;    
  DROP_MACRO_BODY(tmpVar);
end DROP_MACRO_BODY;

-------------------------------------------------------------------------------
PROCEDURE DROP_MACRO_BODY(MACRO_ID IN NUMBER)
is
tmpVar NUMBER;
begin
  select count(*) into tmpVar from ALL_OBJECTS o 
   where (o.OBJECT_NAME='M'||to_char(MACRO_ID)) 
      and (o.OWNER='SP_IM')
      and (o.OBJECT_TYPE='PACKAGE BODY');
 if tmpVar>0 then
    execute immediate('DROP PACKAGE BODY SP_IM.M'||to_char(MACRO_ID));
  else
    commit;  
  end if;  
end DROP_MACRO_BODY;

-------------------------------------------------------------------------------
FUNCTION STATUS(MACRO_ID IN NUMBER) return VARCHAR
is
  tmpVar VARCHAR2(12);
  tmpN NUMBER;
begin
  if MACRO_ID is null then return 'INVALID'; end if;
  select o.OBJECT_KIND into tmpN from SP.OBJECTS o where ID=MACRO_ID;
  if tmpN in (G.SINGLE_OBJ, G.OPERATION_OBJ) then return 'VALID'; end if;
  select STATUS into tmpVar from ALL_OBJECTS o 
   where (o.OWNER='SP_IM')
      and (o.OBJECT_NAME='M'||to_char(MACRO_ID))
      and (o.OBJECT_TYPE='PACKAGE BODY');
  return tmpVar;    
exception
  when no_data_found then
    return 'INVALID';
end STATUS;

-------------------------------------------------------------------------------
FUNCTION MACRO_SOURCES(Macros IN SP.TNUMBERS,
                       Q in NUMBER default -1)
return SP.TSOURCE pipelined
is 
  tmpVar NUMBER;
  tmpS SP.COMMANDS.COMMENTS%type;
  S SP.COMMANDS.COMMENTS%type;
  I BOOLEAN;
  k NUMERIC;
  NewObject BOOLEAN;
  FMT VARCHAR2(80) := NULL;
  NLS VARCHAR2(80) := NULL;
begin
  select value into FMT from V$NLS_PARAMETERS
    where PARAMETER = 'NLS_DATE_FORMAT';
  select value into NLS from V$NLS_PARAMETERS
    where PARAMETER = 'NLS_DATE_LANGUAGE';
  k:= 1;
  -- ������������ ��� ������� � �� ���������.
  for o in (select * from SP.V_Objects obj 
              where ID in (select * from table(Macros))
            order by obj.FULL_NAME)
  loop
	  tmpS := 'begin'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'SP.INPUT.Object(NAME=>'''||o.Full_Name||''','||to_.STR;
    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'OID=>'''||o.OID||''','||to_.STR;
    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    if o.IM_ID is not null then
	    tmpS := 'ImageIndex=>'||TO_CHAR(o.IM_ID)||','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end if;
	  if o.COMMENTS is not null then
	    tmpS := 'Comments=>'''||Q_QQ(o.COMMENTS)||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end if;
	  if o.KIND is not null then
	    tmpS := 'Kind=>'''||o.KIND||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end if;
	  if o.USING_ROLE is not null then
	    tmpS := 'UsingRole=>'''||o.USING_ROLE||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end if;
	  if o.EDIT_ROLE is not null then
	    tmpS := 'EditRole=>'''||o.EDIT_ROLE||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end if;
	  -- ������� ������ � NLS � FMT.
	  tmpS := 'DNLS=>'''||NLS||''', '||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 'DFMT=>'''||FMT||''', '||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 'MDATE=>'''||
            TO_CHAR(o.MODIFIED,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''', '||
            to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 'MUSER=>'''||o.M_USER||''', '||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 'Q=>'||to_char(Q)||');'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := '--���������'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  -- ������������ ��������� �������.
	  for P in (select p.NAME, p.COMMENTS, p.TYPE_ID,t.NAME TYPE_NAME, p.R_ONLY,
	                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y,
	                   SP.Val_to_Str( SP.TVALUE(p.TYPE_ID,null, 0,
	                     p.E_VAL,p.N,p.D,p.S,p.x,p.y)) S_VALUE,
	                   t.CHECK_VAL, t.VAL_TO_STRING, t.STRING_TO_VAL,
	                   p.M_DATE, P.M_USER,
                     (select Name from sp.GROUPS where ID = p.GROUP_ID)
                     GROUP_NAME
	              from SP.OBJECT_PAR_S p, SP.PAR_TYPES t
	                where p.OBJ_ID=o.ID
	                  and t.ID=p.TYPE_ID
                order by p.NAME    
	           )
	  loop
	    tmpS := '--'||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'SP.INPUT.ObjectPar(Name=>'''||P.NAME||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'ObjectName=>'''||o.FULL_NAME||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    if length(p.COMMENTS)>3500 then
	      tmpS := 'Comments=>'''||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      tmpS := p.COMMENTS||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      tmpS := ''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    else
	      tmpS := 'Comments=>'''||Q_QQ(p.COMMENTS)||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
      tmpS := 'ParType=>'''||P.TYPE_NAME||''', '||to_.STR;
      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
      tmpS := 'GROUP_NAME=>'''||P.GROUP_NAME||''', '||to_.STR;
      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
      tmpS := 'MDATE=>'''||
              TO_CHAR(p.M_DATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''', '||
              to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'MUSER=>'''||P.M_USER||''', '||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'R_ONLY=>'''||SP.to_strR_ONLY(P.R_ONLY)||''','||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    -- �������� ������������ ��������� � ������� ���� �� ����
	    -- ��� ����������� ���� ����� ��������� �������� �������������� ��������
	    -- � ������. � ������, ��� ����� �� ����������� ��������,
	    -- � ���� �������������� � ������ ��� ������� ����������.
	    -- � ���� ������ ������������ �������� �� �����.
	    ------------------------------------------------------------------------
	    if (P.D is not null)
	        or (   (P.CHECK_VAL is not null)
	            and
	               ((P.VAL_TO_STRING is null) or (P.STRING_TO_VAL is null))
	           )
	    then
	      -- ������������ �������� �� �����.
	      if P.N is not null then
	        tmpS := 'N=>'||to_.str(P.N)||','||to_.STR;
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      end if;
	      if P.D is not null then
	        tmpS:='D=>'''||TO_CHAR(P.D,FMT,
	              'NLS_DATE_LANGUAGE ='||NLS)||''','||to_.STR;
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      end if;
	      S:=P.S;
	      i:=false;
	      if P.S is not null then
	        i:=true;
	        tmpS:='S=>'''||to_.STR;
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	        tmpS:=Q_QQ(P.S);
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      end if;
	      case
	        when P.X is null and P.Y is null then
	          S:='Q=>0);';
	        when P.X is not null and P.Y is not null then
	          S:='X=>'||to_.str(P.X)||', Y=>'||to_.str(P.Y)||');';
	        when P.X is not null and P.Y is null then
	          S:='X=>'||to_.str(P.X)||');';
	        when P.X is null and P.Y is not null then
	          S:='Y=>'||to_.str(P.Y)||');';
	      end case;
	      if i then
	        tmpS:=''', '||S||to_.STR;
	      else
	        tmpS:=S;
	      end if;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    else
	    -- ������������ �������� ��� ������.
	      if P.S_VALUE is not null  then
	        tmpS:='V=>'''||Q_QQ(P.S_VALUE)||''');'||to_.STR;
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      else
	        tmpS:='Q=>0);'||to_.STR;
	        pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      end if;
	    end if;
	  end loop;
    tmpS := 'commit;'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'end;'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := '/'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := '-- '||to_.STR;
    -- ���� ������ �� �����, �� �����������.
    if o.Kind_ID not in (SP.G.SINGLE_OBJ, SP.G.OPERATION_OBJ) then
	    tmpS := 'begin'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
		  tmpS :=
        'o(''�������� ������ '||o.FULL_NAME
        ||'  ''||SP.B.compile_macro('''||o.FULL_NAME||'''));'
        ||to_.str;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
		  tmpS := 
        'd(''�������� ������ '||o.FULL_NAME
        ||''',''Update_macros'');'
        ||to_.str;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'end;'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := '/'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    else
	    tmpS := 'begin'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
		  tmpS :='o(''�������� ����� '||o.FULL_NAME||''');'||to_.str;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
		  tmpS :=
        'd(''�������� ����� '||o.FULL_NAME||''',''Update_macros'');'
        ||to_.str;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := 'end;'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    tmpS := '/'||to_.STR;
		  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    end if;
  end loop; 
  -- ������������ ������ �����������.
	tmpS :=to_.STR||'--������������'||to_.STR;
	pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
  for o in (select * from SP.V_Objects obj 
              where ID in (select * from table(Macros))
                and KIND_ID in (SP.G.MACRO_OBJ, SP.G.COMPOSITE_OBJ)
            order by obj.FULL_NAME)
	loop   
  
	  NewObject:=true;
	  tmpS := '-- '||o.FULL_NAME||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  for M in (select LINE, ALIAS, COMMENTS, CMD_NAME, USED_OBJECT_FULL_NAME,
	                   MACRO, CONDITION
	              from SP.V_MACROS
	                where OBJECT_ID=o.ID
	            )
	  loop
    tmpS := 'begin'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    if NewObject then
	      tmpS:='SP.INPUT.Macro(ObjectName=>'''||o.FULL_NAME||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	      NewObject:=false;
	      tmpS:='LineNum=>'''||M.LINE
	            ||''', Command=>'''||M.CMD_NAME||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    else
	      tmpS:='SP.INPUT.Macro(LineNum=>'''||M.LINE||
	            ''', Command=>'''||M.CMD_NAME||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
	    if M.ALIAS is not null then
	      tmpS:='Alias=>'''||M.ALIAS||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
	    if M.USED_OBJECT_FULL_NAME is not null then
	      tmpS:='UsedObject=>'''||M.USED_OBJECT_FULL_NAME||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
	    -- Comments
	    if m.COMMENTS is not null  then
	      tmpS:='Comments=>'''||Q_QQ(M.COMMENTS)||''','||to_.STR;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
	    -- MacroBlock
	    if M.MACRO is not null  then
        begin
	      tmpS:='MacroBlock=>'''||to_.STR||Q_QQ(M.MACRO)||''','||to_.STR;
        exception
          when others then
            raise_application_error(-20033,
            'SP.B.MACRO_SOURCES. '||SQLERRM||'  tmpS=>'||tmpS||
            '  length M.MACRO=>'||length(M.MACRO)||' OBJECT_ID=> '||o.ID);
        end;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
	    --Condition
	    if M.CONDITION is not null  then
	      tmpS:='Condition=>'''||to_.STR||Q_QQ(M.CONDITION)||''');'||to_.str;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    else
	      tmpS:=to_.str||'Q=>0);'||to_.str;
	      pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	    end if;
      tmpS := 'end;'||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
      tmpS := '/'||to_.STR;
	    pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  end loop;
    tmpS := 'begin'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'commit;'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'end;'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := '/'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := '-- '||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 'declare EM SP.COMMANDS.COMMENTS%type;'||to_.str;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 
      'begin EM:=SP.B.compile_macro_body('''||o.FULL_NAME||''');'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS :=
      'o(''compile body '||o.FULL_NAME||' ''||EM);'
      ||to_.str;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
	  tmpS := 
      'd(''compile body '||o.FULL_NAME||' ''||EM,''Update_macros'');'
      ||to_.str;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := 'end;'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
    tmpS := '/'||to_.STR;
	  pipe row(SP.TSOURCE_LINE(k, tmpS));  k := k + 1;
  end loop;  
exception
  when no_data_found then null;  
end Macro_Sources;

-------------------------------------------------------------------------------
FUNCTION MACRO_SOURCE(MACRO_FULL_NAME IN VARCHAR2, Q in NUMBER default 0)
return SP.TSOURCE pipelined
is 
  M SP.TNUMBERS;
  tmpVar NUMBER;
  tmpS SP.COMMANDS.COMMENTS%type;
  O SP.V_Objects%ROWTYPE;
  S SP.COMMANDS.COMMENTS%type;
  I BOOLEAN;
  k NUMERIC;
  NewObject BOOLEAN;
begin
  EM:='';
  tmpVar:=GetIDbyName(MACRO_FULL_NAME,'MACRO_SOURCE', false);
  if tmpVar=0 then
    return;
  end if; 
  M := SP.TNUMBERS(tmpVar);   
  --select ID bulk collect into M from SP.OBJECTS where ID=tmpVar;
--    
  for mac in (select * from table(SP.B.MACRO_SOURCES(M,Q)))
  loop
    pipe row(SP.TSOURCE_LINE(mac.line,mac.text));
  end loop;
  return;  
end Macro_Source;  

-------------------------------------------------------------------------------
FUNCTION MACRO_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2,
                              Q in NUMBER default 0)
return CLOB
is
  c CLOB;
  tmpS SP.COMMANDS.COMMENTS%type;
begin
  DBMS_LOB.createtemporary(c,true,12);    
  for e in (select * from Table(Macro_Source(MACRO_FULL_NAME,Q))
            order by line  
            )
  loop
    tmpS:=e.text;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
  end loop;
  return c;
exception
  when no_data_found then return null;  
end Macro_Source_as_Clob;

-------------------------------------------------------------------------------
FUNCTION MACRO_SOURCES_AS_CLOB(Changed_After IN DATE)
return CLOB
is 
  M SP.TNUMBERS;
  c CLOB;
  tmpS SP.COMMANDS.COMMENTS%type;
begin
  if Changed_After is null then return null; end if;
  select ID bulk collect into M from SP.VG_Objects 
    where modified >= Changed_After;
  DBMS_LOB.createtemporary(c,true,12);    
  for mac in (select * from table(SP.B.MACRO_SOURCES(M,-1)))
  loop
    tmpS:=mac.text;
    DBMS_LOB.WRITEAPPEND (c,length(tmpS),tmpS);
  end loop;
  return c; 
exception
  when others then
    raise_application_error(-20033,
    'SP.B.MACRO_SOURCES_AS_CLOB. '||SQLERRM||'  tmpS=>'||tmpS);
end Macro_Sources_as_Clob;

-------------------------------------------------------------------------------
PROCEDURE CloneMacro(
     MacroName IN VARCHAR2,
	   NewShortName IN VARCHAR2 default null)
IS
  NewObjID NUMBER;
  NewMacroGroup NUMBER;
  NewMacroName SP.OBJECTS.NAME%type;
  Obj SP.V_OBJECTS%ROWTYPE;
  Par SP.V_OBJECT_PAR_S%ROWTYPE;
  Macro SP.V_MACROS%ROWTYPE;
BEGIN
  if MacroName is null then return; end if;
  select * into Obj from SP.V_OBJECTS 
    where upper(FULL_NAME)=upper(MacroName);
  NewMacroName:=case 
                  when NewShortName is null then 'Clon_of__'||Obj.SHORT_NAME
                  else NewShortName end;
  -- ������� ����� ������� (��������� � ������� SP.OBJECTS)
  Obj.SHORT_NAME := NewMacroName;
  Obj.FULL_NAME :=null;
  Obj.MODIFIED := null;
  Obj.OID := null;
  insert into SP.V_OBJECTS values Obj;
  select ID into NewObjID from SP.V_OBJECTS 
    where SHORT_NAME = NewMacroName
      and GROUP_NAME = Obj.GROUP_NAME;
  -- ��������� ��������� �������.
  FOR P IN (SELECT * FROM SP.V_OBJECT_PAR_S WHERE OBJECT_ID=Obj.ID)
  LOOP
    Par:=P;
    Par.OBJECT_ID:=NewObjID;
    INSERT INTO SP.V_OBJECT_PAR_S VALUES Par;
  END LOOP;
  -- ���� ������ "SINGLE", �� �����.
  if Obj.KIND_ID in(G.SINGLE_OBJ, G.OPERATION_OBJ) then return; end if;
  -- ��������� ������������.
  FOR M IN (SELECT * FROM SP.V_MACROS WHERE OBJECT_ID = Obj.ID order by LINE)
  LOOP
    Macro:=M;
    Macro.OBJECT_ID:=NewObjID;
    Macro.OBJECT_FULL_NAME:=null;
    Macro.OBJECT_SHORT_NAME:=null;
    INSERT INTO SP.V_MACROS VALUES Macro;
  END LOOP;
  commit;
  NewMacroName:=Compile_Macro(NewObjID);
  NewMacroName:=Compile_Macro_Body(NewObjID);
END CloneMacro;    

END B;
/

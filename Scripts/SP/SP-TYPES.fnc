-- Types procedures
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010
-- update 21.10.2010 02.11.2010 16.11.2010 30.11.2010 16.12.2010 18.01.2011
--        11.05.2011 23.10.2011 24.11.2011 16.12.2011 30.12.2011 10.02.2012
--        16.03.2012 27.03.2012 19.07.2013 25.08.2013 02.07.2014 10.09.2014
--        30.10.2014 26.11.2014 03.03.2015 28.04.2015 25.05.2015 25.06.2015
--        08.07.2015 24.08.2015 11.11.2015 21.09.2016 19.10.2016 21.11.2016
--        31.01.2017 22.02.2017 10.01.2019
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.SET_OF_VALUES(V in SP.TVALUE)
return SP.TS_VALUES_COMMENTS pipelined
-- ������� ������������� ����� ���������� ��������� �������� � ������������ �
-- ��� ��� ������ �������� ���������. 
-- ������������ ������ ������ �������������� ����� ������ SET_OF_VALUES
-- ������� PAR_TYPES.
-- ����� ����������� ������� �������� ��������� � ���������� ���������� 
-- SP.TG.CurValue.
--  (SP-TYPES.fnc).
as
  cur SYS_REFCURSOR;
  valID NUMBER;
  Val SP.COMMANDS.COMMENTS%type;
  Comm SP.COMMANDS.COMMENTS%type;
  C SP.COMMANDS.COMMENTS%type;
  ChV VARCHAR2(4000);
  V_C SP.TS_VALUE_COMMENTS;
  PName SP.PAR_TYPES.NAME%type;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  if V is null then
    -- ����� ������ ������.
    pipe row(V_C);
    return;
  end if;
  SP.TG.CurValue:=V;
  select SET_OF_VALUES, CHECK_VAL, NAME into C,ChV,PName 
    from SP.PAR_TYPES
    where ID=V.T;
  if Chv is not null then
    if C is not null then
        --d(C,'SP.SET_OF_VALUES');
      begin
        OPEN cur for C;
        --d('1','SP.SET_OF_VALUES');
        LOOP
          fetch cur into valID,Val,Comm;
          exit when cur%NOTFOUND;
          --d('2','SP.SET_OF_VALUES');
          V_C.ID := valID;
          V_C.S_VALUE:=Val;
          V_C.COMMENTS:=Comm;
          pipe row(V_C);
        END LOOP;
        CLOSE cur;
      exception
        when no_data_found then
          -- ����� ������ ������, ��� � � ������, ���� ���� �� ��������.
          pipe row(V_C);
          return;
        when no_data_needed then
          return;  
        when others then
          close cur;
          d('������ ����� ������ ������ �������� '||SQLERRM||
          ' ��� ���� '||PName||'!','ERROR =>SP.SET_OF_VALUES');
          raise_application_error(-20033,
          '������ ����� ������ ������ �������� '||SQLERRM||
          ' ��� ���� '||PName||'!');
      end;
    else
      -- ���� ���� �� ��������, �� ������ ����� ������ ������, ������
      -- ���������� "������ �� �������".
      pipe row(V_C);
      return;  
    end if;  
  -- ����� ������ ��� E_VAL.  
  else
    for ev in (select e.ID, e.E_VAL, e.COMMENTS COMMENTS 
                 from SP.ENUM_VAL_S e
                 where (e.TYPE_ID=V.T) 
                   
                     )
    loop
      V_C.ID:=ev.ID;
      V_C.S_VALUE:=ev.E_VAL;
      V_C.COMMENTS:=ev.COMMENTS;
      pipe row(V_C);
    end loop;
  end if;  
  return;
exception
  when no_data_needed then
    return;  
  when others then
    raise_application_error(-20033,'SP.SET_OF_VALUES. '||SQLERRM);
end;
/
--
GRANT EXECUTE ON SP.SET_OF_VALUES to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Val_to_Str(Val in SP.TVALUE)
return VARCHAR2
-- ������������� ��������� �������� ���������. (SP-TYPES.fnc)
as
  tmpVar SP.COMMANDS.COMMENTS%type;
  B VARCHAR2(100):='DECLARE S SP.COMMANDS.COMMENTS%type; V SP.TVALUE;'||
                   'BEGIN V:=:1;';
  E VARCHAR2(20):=' :2:=S;END;';
  VAL2STR SP.COMMANDS.COMMENTS%type;
begin
  -- ���� ��� ������, �� ���������� ���� "S".
  if Val.T=SP.G.TStr4000 then 
    return Val.S;
  end if;
  -- ���� ��� ����� ����������� ��������, �� ���������� E.
  if Val.E is not null then
    return Val.E;
  end if;
  begin
    select VAL_TO_STRING into Val2Str from SP.PAR_TYPES
      where ID=Val.T;
  exception
    when no_data_found then
      d(' Wrong type '||nvl(to_char(Val.T),'null')||' !',
        'ERROR =>SP.Val_to_Str');
      raise;  
  end;  
  -- ���� ���� �������������� �� ����, �� �� ���������� ��������.
  if Val2Str is not null then
    begin
      execute immediate(B||Val2Str||E)
        using IN Val, OUT tmpVar;
    exception
      when others then
        d(' Val2Str='||B||Val2Str||E||' '||
          SQLERRM,'ERROR =>SP.Val_to_Str');
      raise;  
    end;
  else
    -- ��� ����� ����������� �������� � ��� ����� null.
    return null;  
  end if;  
  return tmpVar;
end;
/
--
GRANT EXECUTE ON SP.Val_to_STR to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Val_COMMENTS(Val in SP.TVALUE)
return VARCHAR2
-- ������� ������������� ����������� � �������� ��������� (SP-TYPES.fnc).
as
  tmpVar SP.COMMANDS.COMMENTS%type;
  result SP.COMMANDS.COMMENTS%type;
begin
  -- ���������� ����������� � ����.
  begin
    select COMMENTS into result from  SP.PAR_TYPES where ID=Val.T; 
  exception
    when no_data_found then 
      result:=null;
  end;    
  -- ���� ��� ����� ����������� ��������, �� ��������� ����������� �
  -- ������������ ��������.
  if Val.E is not null then
    select e.COMMENTS into tmpVar from  SP.ENUM_VAL_S e
      where (e.TYPE_ID=Val.T) and(e.E_VAL=Val.E); 
    return result||to_.STR||tmpVar;
  end if;
  -- ����� ���������� ����������� � ������� � ����������� � ����.
  begin
    --! ����� �������� �� ������������?
    select COMMENTS into tmpVar from 
      (select COMMENTS from table (SP.SET_OF_VALUES(Val))
         where S_VALUE=SP.VAL_TO_STR(Val)
         order by COMMENTS
       )
       where ROWNUM =1  
      ;
  exception
    when no_data_found then 
      return result; 
    when others then
      d(SQLERRM||' ��� �������� '||SP.VAL_TO_STR(Val)||
                 ' ���� '||SP.TO_StrType(Val.T),
      'ERROR in SP.Val_COMMENTS');
      return result;  
  end;
  return result||to_.STR||tmpVar;
end;
/
--
GRANT EXECUTE ON SP.Val_COMMENTS to public;
---
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.Str_to_Val(
  -- C�����, ������� ����� �������������.
  Str in VARCHAR2, 
  --  ��������, �������� ����� ��������� ������.
  V in out NOCOPY SP.TVALUE,
  -- ���� ��������� ������, ��� ������������ ������
  -- (������������ � ������������� TVALUE).
  Safe in BOOLEAN default false) 
-- �������������� ���������� �������� � �������� ��������� � �������������� 
-- ����� ��������������.
-- (SP-TYPES.fnc)
as
  B VARCHAR2(100);
  E VARCHAR2(20);
  Str2Val SP.COMMANDS.COMMENTS%type;
  ChV SP.COMMANDS.COMMENTS%type;
begin
  begin
    select STRING_TO_VAL, CHECK_VAL into Str2Val,ChV from SP.PAR_TYPES
      where ID=V.T;
  exception
    when no_data_found then 
      raise_application_error(-20033,'SP.Str_to_Val. '||
        '��� '||nvl(to_char(V.T),'null')||' �����������!');    
  end;  
  -- ���� �������� �����������, �� ����������� �������� �� ������� �������.
  if ChV is null then
    begin
      select E_VAL,N,D,S,X,Y into V.E,V.N,V.D,V.S,V.X,V.Y from SP.ENUM_VAL_S 
        where (TYPE_ID=V.T) and (upper(E_VAL)=upper(Str));
    exception
      when no_data_found then 
        if Safe then
          select E_VAL,N,D,S,X,Y into V.E,V.N,V.D,V.S,V.X,V.Y 
            from
            (
            select E_VAL,N,D,S,X,Y from SP.ENUM_VAL_S 
            where TYPE_ID=V.T
            order by N
            )
            where rownum=1;
        else
          raise_application_error(-20033,'SP.Str_to_Val. '||
            '�������� '||nvl(Str,'null')||' ��� ���� '||SP.to_strType(V.T)||
            ' ����������� ��� ����������!');
        end if;  
    end; 
    return;   
  end if;  
  -- ���� ���� ���� ��������������, �� �� ���������� ������������ ��������.
  if Str2Val is not null then
    begin
      B:='DECLARE S SP.COMMANDS.COMMENTS%type; V SP.TVALUE;'||
      'BEGIN  S:=:1; V:=:2; ';
      E:=' :2:=V; END;';
      execute immediate(B||Str2Val||E)
        using in Str,in out V;
    exception
      when others then
        if Safe then
          -- ������� ������ �������� �� ������.
          begin
            select S_Value into ChV from 
              table (SP.SET_OF_VALUES(V))
              where rownum=1;
             -- ��������� ��������������.  
            B:='DECLARE S SP.COMMANDS.COMMENTS%type; V SP.TVALUE;'||
            'BEGIN  S:=:1; V:=:2; ';
            E:=' :2:=V; END;';
            execute immediate(B||Str2Val||E)
              using in ChV, in out V;
          exception
             when others then
              d('safe! Str2Val='||B||Str2Val||E||' '||
              SQLERRM, 'ERROR =>SP.Str_to_Val');
              raise;
          end;              
        else
          d('Str2Val='||B||Str2Val||E||', Str='||nvl(Str,'null')||' '||
            SQLERRM, 'ERROR =>SP.Str_to_Val');
          raise;
        end if;
    end;
    -- ��������� ���������� ��������, ���� �������� ���������.
    if TG.Check_ValEnabled then
      SP.CheckVal(ChV,V);  
    end if;    
  else
    -- ���������� ����.
    V.E:=null;
    V.N:=null;
    V.D:=null;
    V.S:=null;
    V.X:=null;
    V.Y:=null;
  end if;  
end;  
/
-----
GRANT EXECUTE ON SP.STR_to_VAL to public;

--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.S2XY(S in VARCHAR2, 
                                           XY in out NOCOPY SP.TVALUE) 
-- �������������� ������ � ������� ����� (SP-TYPES.fnc).
is
tmpVar PLS_INTEGER;
tmpS VARCHAR2(90);
begin
  tmpVar:=regexp_instr(S,';|:');
  tmpS:=substr(S,1,tmpVar-1);
  XY.X:=case when tmpS is null then null else to_number(tmpS) end;
  tmpS:=substr(S,tmpVar+1);
  XY.Y:=case when tmpS is null then null else to_number(tmpS) end;
exception
  when others then     
    raise_application_error(-20033,'Wrong XY: '||S||' '||SQLERRM);
end;
/
grant execute on SP.S2XY to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.S3XYZ(S in VARCHAR2, 
                                           XYZ in out NOCOPY SP.TVALUE) 
-- �������������� ������ � ������� ����� (SP-TYPES.fnc).
is
tmpVar PLS_INTEGER;
tmpS VARCHAR2(90);
begin
  tmpVar:=regexp_instr(S,';|:');
  XYZ.X:=to_number(substr(S,1,tmpVar-1));
  tmpS := substr(S,tmpVar+1);
  tmpVar:=regexp_instr(tmpS,';|:');
  XYZ.Y:=to_number(substr(tmpS,1,tmpVar-1));
  XYZ.N:=to_number(substr(tmpS,tmpVar+1));
exception
  when others then     
    raise_application_error(-20033,'Wrong XYZ: '||S||' '||SQLERRM);
end;
/
grant execute on SP.S3XYZ to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HAS_TYPE_SET_OF_VALUES(PAR_TYPE in NUMBER)
return BOOLEAN
-- ������� ���������� ����� �� ��� ����� ���������� ��������� ��������
-- (SP-TYPES.fnc).
as
  tmpVar NUMBER;
begin
  select case
           when (SET_OF_VALUES is null) and (CHECK_VAL is not null)
           then 0 else 1 end
    into tmpVar
    from SP.PAR_TYPES
    where ID=PAR_TYPE;
  return case when tmpVar=1 then true else false end;
exception
  when no_data_found then return null;
end;
/
--
grant execute on SP.HAS_TYPE_SET_OF_VALUES to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_TYPE_HAS_SET_OF_VALUES(PAR_TYPE in NUMBER)
return NUMBER
-- ������� ���������� ����� �� ��� ����� ���������� ��������� ��������.
-- (SP-TYPES.fnc).
as
  tmpVar NUMBER;
begin
  select case
           when (SET_OF_VALUES is null) and (CHECK_VAL is not null)
           then 0 else 1 end
    into tmpVar
    from SP.PAR_TYPES
    where ID=PAR_TYPE;
  return tmpVar;
exception
  when no_data_found then return 0;
end;
/
--
grant execute on SP.S_TYPE_HAS_SET_OF_VALUES to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.IS_ENUM_TYPE(PAR_TYPE in NUMBER)
return BOOLEAN
-- ������� ���������� ����� �� ��� ����������� �������� (SP-TYPES.fnc).
as
  tmpVar NUMBER;
begin
  select case
           when CHECK_VAL is null
           then 1 else 0 end
    into tmpVar
    from SP.PAR_TYPES
    where ID=PAR_TYPE;
  return case when tmpVar=1 then true else false end;
exception
  when no_data_found then return null;
end;
/
--
grant execute on SP.IS_ENUM_TYPE to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_IS_ENUM_TYPE(PAR_TYPE in NUMBER)
return NUMBER
-- ������� ���������� ����� �� ��� ����������� �������� (SP-TYPES.fnc).
as
  tmpVar NUMBER;
begin
  select case
           when CHECK_VAL is null
           then 1 else 0 end
    into tmpVar
    from SP.PAR_TYPES
    where ID=PAR_TYPE;
  return tmpVar;
exception
  when no_data_found then return 0;
end;
/
--
grant execute on SP.S_IS_ENUM_TYPE to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.STRINGS(pSTRINGS in SP.TSTRINGS)
return SP.TSTRINGS pipelined
-- ������� ������������� ������ pSTRINGS ��� �������.
-- declare NAMES SP.TSTRINGS;
-- ...
-- select * from table(SP.STRINGS(NAMES));
-- (SP-TYPES.fnc).
as
  tmpVar NUMBER;
begin
  tmpVar:= pSTRINGS.first;
  while tmpVar is not null 
  loop
    pipe row(pSTRINGS(tmpVar));
    tmpVar:=pSTRINGS.next(tmpVar);    
  end loop;
  return;
exception
  when no_data_needed then
    return;  
  when others then
     raise_application_error(-20033,'SP.STRINGS. '||
          '������ ������ ������ �������� '||SQLERRM||'!');
end;
/
--
GRANT EXECUTE ON SP.STRINGS to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.STRINGS_FROM_NAMES(NAMES in SP.G.TNAMES)
return SP.TSTRINGS
-- ������� ����������� ������ NAMES � ������� TSTRINGS,
-- ������� ����� ������������ � �������.
-- (SP-TYPES.fnc).
as
  tmpVar NUMBER;
  S SP.TSTRINGS;
begin
  S:=SP.TSTRINGS();
  S.extend(NAMES.last);
  --d('NAMES.count=>'||NAMES.last,'SP.STRINGS_FROM_NAMES');
  tmpVar:= NAMES.first;
  --d('tmpVar=>'||tmpVar,'SP.STRINGS_FROM_NAMES');
  while tmpVar is not null
  loop
    S(tmpVar):=(NAMES(tmpVar));
    tmpVar:=NAMES.next(tmpVar);
    --d('tmpVar=>'||tmpVar,'SP.STRINGS_FROM_NAMES');
  end loop;
  --d('Return','SP.STRINGS_FROM_NAMES');
  return S;
exception
  when others then
     raise_application_error(-20033,'SP.STRINGS_FROM_NAMES. '||
          '������ ������ ������ �������� '||SQLERRM||'!');
end;
/
--
GRANT EXECUTE ON SP.STRINGS_FROM_NAMES to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE procedure SP.Str_Note_ToVal(S in VARCHAR2,
                                              Note in out NOCOPY SP.TVALUE)
-- �������������� ������ � ���������� (SP-TYPES.fnc).
is
Strings SP.G.TNAMES;
EM SP.COMMANDS.COMMENTS%type;
begin
  EM  := 'Wrong Note: '||S||' ';
  if Note is null then
    Note := SP.TVALUE;
  end if;
  if SP.G.notEQ(substr(S,1,2), '!!') then
    Note.N := 0;
    Note.X := 0;
    Note.Y := 1;
    Note.S:=S;
  else
    begin
      select * bulk collect into Strings
        from table(SP.SET_FROM_STRING(substr(S,3),'!')) t;
      if Strings.count != 4 then
        raise_application_error(-20033,EM);
      end if;
      -- Keypoint
      begin
        Note.N:=to_number(Strings(1));
      exception when others then
        raise_application_error(-20033,EM||'Keypoint => '||SQLERRM);
      end;
      if not(Note.N between 0 and 100) then
         raise_application_error(-20033,EM||'Keypoint is out of range!');
      end if;
      -- Dimension
      begin
        Note.X:=to_number(Strings(2));
      exception when others then
        raise_application_error(-20033,EM||'Dimension => '||SQLERRM);
      end;
      if not(Note.X in(0,1)) then
         raise_application_error(-20033,EM||'Dimension is out of range!');
      end if;
      -- Purpose
      begin
        select N into Note.Y from SP.ENUM_VAL_S
          where N = to_number(Strings(3)) and TYPE_ID = SP.G.TNotePurpose;
        exception when no_data_found then
        raise_application_error(-20033,EM||'unknown Purpose => '||Strings(3));
      end;
      -- Notes
      Note.S:=(Strings(4));
    exception when others then
      raise_application_error(-20033,'Wrong Note: '||S||' '||SQLERRM);
    end;
  end if;
end;
/
grant execute on SP.Str_Note_ToVal to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE function SP.Val_Note_ToStr(V in SP.TVALUE) return VARCHAR2
-- �������������� ���������� (Note) � ������ (SP-TYPES.fnc).
-- Note - ����������������� ����������� ��� ������� ������.
as
TmpS SP.ENUM_VAL_S.E_VAL%TYPE;
Val SP.COMMANDS.COMMENTS%type;
begin
  if V.N = 0 and V.X = 0 and V.Y = 1 then
    return V.S;
  else
    Val := '!!'||to_char(V.N)||'!'||to_char(V.X)||
           '!'||to_char(V.Y)||'!'||V.S;
    return Val;
  end if;  
end;
/
grant execute on SP.Val_Note_ToStr to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE procedure SP.Str_Flags_ToVal(S in VARCHAR2,
                                               Flags in out NOCOPY SP.TVALUE)
-- �������������� ������ � ����� ������ (SP-TYPES.fnc).
is
Strings SP.G.TNAMES;
EM SP.COMMANDS.COMMENTS%type;
type TFValue is table of BINARY_INTEGER index by VARCHAR2(128);
FValue TFValue;
tmpVar BINARY_INTEGER;
i BINARY_INTEGER;
begin
  EM  := 'Wrong Flags: '||S||' ';
  if Flags is null then
    Flags := SP.TVALUE;
  end if;
  if S is null then
    Flags.S := 'NoValue';
    Flags.N := 0;
    return;
  end if;
  select * bulk collect into Strings from table(SP.SET_FROM_STRING(S));
  if Strings.count < 2 then
    raise_application_error(-20033,EM||' �� ������� ��������!');
  end if;
  Flags.S := trim(Strings(1));
  -- ��������� ��������� �� "none".
  if upper(trim(Strings(2)))='NONE' then
    Flags.N:=0;
    return;
  end if;
  -- ��������� ��������� �� "all".
  if upper(trim(Strings(2)))='ALL' then
    Flags.N:=power(2,31)-1;
    return;
  end if;
  -- ������� ��������� ������ �� ����.
  for v in (select * from SP.ENUM_VAL_S where TYPE_ID = 
             (
              select ID from SP.PAR_TYPES 
                where upper(NAME)= upper(trim(Strings(1)))
             ))
  loop
    FValue(v.E_VAL):=v.N;
  end loop;
  --��������� ����� ������.
  i:= 2;
  tmpVar:=0;
  while i is not null
  loop
    tmpVar:= tmpVar + FValue(Strings(i)) - bitand(tmpVar,FValue(Strings(i)));
    i:=Strings.next(i);
  end loop;
  Flags.N := tmpVar;
exception 
  when no_data_found then
    raise_application_error(-20033,EM||'unknown ENUM => '||Strings(1));
end;
/
grant execute on SP.Str_Flags_ToVal to public;
--
--
-------------------------------------------------------------------------------
CREATE OR REPLACE function SP.Val_Flags_ToStr(V in SP.TVALUE) return VARCHAR2
-- �������������� ������ ������ (Flags) � ������ (SP-TYPES.fnc).
as
Val SP.COMMANDS.COMMENTS%type;
Strings SP.G.TNAMES;
tmpVar BINARY_INTEGER;
f BOOLEAN;
begin
  Val:=V.S||':';
  f:=false;
  if V.N = 0 then  return Val||'NONE'; end if; 
  if V.N >= power(2,31)-1 then  return Val||'ALL'; end if; 
  -- ������� ��������� ��������. 
  for e in (select * from SP.ENUM_VAL_S where TYPE_ID = 
             (
              select ID from SP.PAR_TYPES 
                where upper(NAME)= upper(V.S)
             ))
  loop
    Strings(e.N):=e.E_VAL;
  end loop;
  -- ��������� ���������.           
  for i in 0..31
  loop
    tmpVar:=bitand(V.N,power(2,i));
    if tmpVar > 0 then 
      if f then 
        Val:=Val||','||Strings(tmpVar);
      else 
        f:=true;  
        Val:=Val||Strings(tmpVar);
      end if;
    end if; 
  end loop; 
  return Val;
end;
/
grant execute on SP.Val_Flags_ToStr to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE function SP.Mod_Obj_Name(ID in NUMBER) return VARCHAR2
-- �������������� ��������� ����� ������� �� ������ �� ���� (SP-TYPES.fnc).
-- ID - ���������� ������������� �������.
as
tmpS SP.COMMANDS.COMMENTS%type;
N NUMBER;
begin
  N := ID;
  if N is null then
    return null;
  else
    select MOD_OBJ_NAME into tmpS from SP.MODEL_OBJECTS where id = N;
    return tmpS;
  end if;  
end;
/
grant execute on SP.Mod_Obj_Name to public;
create or replace synonym SP.Rel2Obj_Name for SP.Mod_Obj_Name;
-- end of file


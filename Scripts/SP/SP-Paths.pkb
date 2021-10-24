CREATE OR REPLACE PACKAGE BODY SP.Paths
-- Path package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 24.11.2011
-- update 25.11.2011 27.06.2012 22.05.2013 25.08.2013 01.11.2014 10.03.2015
-- ����� �������������� ����� � ��� ��������.
AS

-------------------------------------------------------------------------------
FUNCTION ShortName(Name in VARCHAR2) return VARCHAR2
as
TmpStr SP.COMMANDS.COMMENTS%type;
begin
  if Name is null then return null; end if;
  select s into TmpStr from 
    (select rownum rn, column_value s
        from table(sp.SET_FROM_STRING(Name,'/')))
          where rn = (select count(*)
                        from table(sp.SET_FROM_STRING(Name,'/')));
  return TmpStr;
end ShortName;

-------------------------------------------------------------------------------
FUNCTION Path(FullName in VARCHAR2) return VARCHAR2
as
TmpStr SP.COMMANDS.COMMENTS%type;
TmpVar NUMBER;
begin
  --���� ��� �� �������� "/", �� ��� ������� ���
  --������� ���������� "./" ����������� ������ Name, ������� ��������
  -- "./" � ������ ���, ���������� ������ ���.
  if INSTR(FullName,'/')=0 then
    return './';
  end if;

  -- ���� ������ ������ �� "/", �� FullName �� ����
  if substr(FullName,1,1) != '/' then
    RAISE_APPLICATION_ERROR(-20033,FullName||' �� ����� ���� �����!'); 
  end if;
  -- ���� �������� ���� ���������� � "/" ��� " ", �� FullName �� ����
  if substr(FullName,2,1) in ('/',' ') then
    RAISE_APPLICATION_ERROR(-20033,FullName||' �� ����� ���� �����!'); 
  end if;
  TmpStr:= '';
  for c in ( select column_value s
               from table(sp.SET_FROM_STRING(FullName,'/'))
               where rownum < (select count(*)
                               from table(sp.SET_FROM_STRING(FullName,'/')))
            )
  loop
   -- ���� ���������� � '/'
    tmpStr:=tmpStr||'/'||c.s;
   end loop;
   -- � ������������� '/'
  return TmpStr||'/';
end Path;

-------------------------------------------------------------------------------
FUNCTION Name2Path(Name in VARCHAR2) return VARCHAR2
as
begin
  -- ���� ��������� ������ �� "/", �� ��������� "/".
  if substr(trim(Name),-1,1) != '/' then
    return Name||'/';
  end if;
  return Name;  
end Name2Path;

-------------------------------------------------------------------------------
FUNCTION Path2Name(Path in VARCHAR2) return VARCHAR2
as
begin
	if (Path is null) or (trim(Path)='/') then return '/';end if;
	-- ���� ��������� ������ "/", � �������������  ".", �� ����������
	-- �������� �������� ��� ���������.
  if substr(trim(Path),-2,2) = './' then
    return Path;
  end if;
  return rtrim(Path,'/ ');  
end Path2Name;

-------------------------------------------------------------------------------
FUNCTION Lev(FullName in VARCHAR2)
return NUMBER
as
TmpVar NUMBER;
begin
  select COUNT(*) INTO TmpVar from table(sp.SET_FROM_STRING(FullName,'/'));
  return TmpVar;
end Lev;

-------------------------------------------------------------------------------
FUNCTION NAME(Path in VARCHAR2, Name in VARCHAR2) return VARCHAR2
is
 NAMES SP.G.TNAMES;
 N BINARY_INTEGER;
 PATHS SP.G.TNAMES;
 P BINARY_INTEGER;
 tmpVar BINARY_INTEGER;
 tmpStr SP.COMMANDS.COMMENTS%type;
 b BOOLEAN;
 a BOOLEAN;
begin
  -- ���� ��� ���� � ���� ����, �� ���������� "/".
  if (trim(Name) is null) and (trim(Path) is null) then return '/'; end if;
  -- ���� ��� ����, �� ���������� ����.
  if trim(Name) is null then return Path2Name(Path); end if;
  -- ���� ���� ����, �� ���������� ���.
  if trim(Path) is null then return Path2Name(Name); end if;
  -- ���� ��� �������� ������ ������ "/", �� ��� ���������� ���.
  -- ���� ��� ������� �� "/", �� ���������� "/"
  if substr(trim(Name),1,1)='/' then return nvl(rtrim(Name,'/ '),'/'); end if;
  -- ���� ���� �������� ������ ������ "/", �� ��� ���������� ����.
  a:=false;
  if substr(trim(Path),1,1)='/' then a:=true; end if;
  tmpVar:=1;
  -- ���������� ���� � ��� � �������.
  NAMES:= SP.NAMES_FROM_STRING(trim(Name),'/');
  PATHS:= SP.NAMES_FROM_STRING(trim(Path),'/');
  -- ��������� ���-�� ��������� � ����� ��� ������� ������� � �������
  -- �������� �� ��������.
  -- ������� ��������� ������ �� ������� ����������.
  -- ��������� ������������� ������� �������.
  -- ����� ������, ���� ./ ������������ ������ ��� ../ ��������� �����
  -- ���������� ���� ��� �����.
  tmpVar:= NAMES.first;
  N:=0;
  b:=false;
  while tmpVar is not null 
  loop
    if not b then
	    case NAMES(tmpVar)
	      when '.' then  NAMES.delete(tmpVar); b:=true;
	      when '..' then NAMES.delete(tmpVar); N:= N+1;
	    else
	      b:=true;  
	    end case;
    else
	    case 
	      when NAMES(tmpVar) in ('.','..') then 
    			RAISE_APPLICATION_ERROR(-20033,'SP.Path.Name.'||
      			' ������������ ������������ � �������� ��������� NAME =>'||
            Name||'!');
	    else
	      null;  
	    end case;
    end if;
    tmpVar:=NAMES.next(tmpVar);
  end loop;
  tmpVar:= PATHS.first;
  P:=0;
  b:=false;
  while tmpVar is not null 
  loop
    if not b then
	    case PATHS(tmpVar)
	      when '.' then  PATHS.delete(tmpVar); b:=true;
	      when '..' then PATHS.delete(tmpVar); P:= P+1;
	    else
	      b:=true;  
	    end case;
    else
	    case 
	      when PATHS(tmpVar) in ('.','..') then 
    			RAISE_APPLICATION_ERROR(-20033,'SP.Path.Name.'||
      			' ������������ ������������ � �������� ��������� Path =>'||
            Path||'!');
	    else
	      null;  
	    end case;
    end if;
    tmpVar:=PATHS.next(tmpVar);
  end loop;
  tmpStr:='';
  -- ������������ ���������� ��������� � ����� ������.
  tmpVar:= PATHS.count - N;
   -- ���� ������� ������ �� �����.
  if tmpVar <= 0 then
    -- ���� ���� ����������, ������ ������������������ ���� �����.
    if (tmpVar < 0) and a then
    	RAISE_APPLICATION_ERROR(-20033,'SP.Path.Name.'
        ||' ������ ������������������ ���� ����� Path =>'
        ||Path||' NAME =>'||Name||'!');
    end if;
    -- ���� ���� ����������, �� ����� ��������� "/".
    if a then 
      tmpStr:='/';
    else  
	    for i in 1..(P-tmpVar)
	    loop
	      if tmpStr is null then 
	        tmpStr:='..';
	      else  
	        tmpStr:=tmpStr||'/..';
	      end if;
	    end loop;
    end if;
    if NAMES.count > 0 then 
	    for i in NAMES.first..NAMES.last
	    loop
	      if (tmpStr is null) or (tmpStr ='/') then 
	        tmpStr:=tmpStr||NAMES(i); 
	      else
	        tmpStr:=tmpStr||'/'||NAMES(i);
	      end if;
	    end loop;
    end if;
    if tmpStr='..' then return '../'; end if;  
    -- ���� ����� ����, �� ������� "./".
    if tmpStr is null then return './'; end if;  
    return tmpStr; 
  end if;
  -- ���� ������� �� ���� � �����.
  -- ���� ���� ����������, �� ����� ��������� "/".
  if a then 
    tmpStr:='/';
  else  
	  for i in 1..P
	  loop
	    if tmpStr is null then 
	      tmpStr:='..';
	    else  
	      tmpStr:=tmpStr||'/..';
	    end if;
	  end loop;
  end if;   
  if PATHS.count > 0 then
   for i in PATHS.first..PATHS.last-N
   loop
     if (tmpStr is null) or (tmpStr ='/') then 
       tmpStr:=tmpStr||PATHS(i); 
     else
       tmpStr:=tmpStr||'/'||PATHS(i);
     end if;
   end loop;
  end if;
  if NAMES.count > 0 then 
	  for i in NAMES.first..NAMES.last
	  loop
	    tmpStr:=tmpStr||'/'||NAMES(i);
	  end loop;
  end if;  
  if tmpStr = '..' then return '../'; end if;  
  if tmpStr is null then return './'; end if;  
  return tmpStr; 
end NAME;

end Paths;
/

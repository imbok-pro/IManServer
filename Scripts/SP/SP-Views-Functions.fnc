-- SP Views functions
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 13.06.2013 25.03.2015 23.04.2015 05.08.2021


-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Is_Group_Link_Possible(
                          Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN
-- ����������� ������������� � ������ � ������ � ���� ��������������
--(SP-Views-Functions.fnc).
is
  tmpVar NUMBER;
begin
  if not SP.GRAPH2TREE.Is_Link_Possible(Src_Node,Dest_Node) then
    return false;
  end if;
  if TG.SP_Admin then return true; end if;
  select count(*) into tmpVar from SP.USER_ROLES 
    where ROLE_ID = (select G_ER_ID from SP.V_PRIM_GROUPS 
                       where G_ID=SP.GRAPH2TREE.NID(Dest_Node));
  if tmpVar=0 then return false; end if;
  return true;                     
end;
/  
grant execute on SP.Is_Group_Link_Possible to public; 

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.UserRole(SUser in VARCHAR2,
                                       Delim in VARCHAR default ' ! ')
return VARCHAR2
-- ���� ����������� ������������ �� ������ ����� �������.
-- ���� ������������ �� �� ������ ����� ������� ������������. 
-- ���� ���� �� ����, �� ����� ������ ��� ���� ����� �����������. 
--(SP-Views-Functions.fnc).
is
SpUser VARCHAR2(60);
result VARCHAR2(4000);
f boolean;
begin
  -- ���� ��� ������������ ������� ������ �� ��������� ���� � ����,
  -- �� ��������� �������. 
  -- � SP.USERS_GLOBALS ����� ������������� ��������� � ��� ���� ��� ��� ����
  -- ������� ���������������, �� ��� �������� ������������, ���� ��� �����
  -- ���������� �� ��������� �������, ��� ��� ����������� �������� ���
  -- ������������ ��� ������������ ����������, ��������� ������������ �������. 
  if regexp_instr(SUser,'[^A-Za-z0-9_]+') = 0 then
    SpUser := upper(SUser);
  else
    SpUser := SUser;
  end if;
  result := ''; 
  f:= true;
  for r in (  SELECT R.NAME FROM DBA_ROLE_PRIVS D,SP.SP_ROLES R
                WHERE SpUser = D.GRANTEE 
                  AND R.NAME = D.GRANTED_ROLE
           )
  loop
    if f then 
      result := r.Name;
      f := false;
    else  
      result := result || Delim || r.Name;
    end if;
  end loop;
  return result;
end;
/  
-- grant execute on SP.UserRole to public; 

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.UserRoles(SUser in VARCHAR2)
return SP.TSTRINGS pipelined
-- ��� ���� ������������. �������� ������ ������. 
--(SP-Views-Functions.fnc).
is
SpUser VARCHAR2(60);
result VARCHAR2(4000);
begin
  result := ' ';
  -- ���� ������������ �� �����, �� ����� � ������ ���
  if not TG.SP_Admin then pipe row (result);return; end if; 
  -- ���� ��� ������������ ������� ������ �� ��������� ���� � ����,
  -- �� ��������� �������. 
  -- � SP.USERS_GLOBALS ����� ������������� ��������� � ��� ���� ��� ��� ����
  -- ������� ���������������, �� ��� �������� ������������, ���� ��� �����
  -- ���������� �� ��������� �������, ��� ��� ����������� �������� ���
  -- ������������ ��� ������������ ����������, ��������� ������������ �������. 
  if regexp_instr(SUser,'[^A-Za-z0-9_]+') = 0 then
    SpUser := upper(SUser);
  else
    SpUser := SUser;
  end if;
  result := ''; 
  for r in (  
    with GR_ROLE as 
    ( select distinct r.GRANTED_ROLE 
        from DBA_ROLE_PRIVS r 
        where DEFAULT_ROLE='YES'
          and SpUser = r.GRANTEE )
    select distinct ID, NAME from
    (
      select distinct ID, NAME from
        (
          select r.ID, r.NAME, connect_by_Root r.PARENT PARENT from SP.V_ROLES r
            connect by prior r.ID = r.PID
        )rr
        where rr.PARENT in
        (
          select * from GR_ROLE
        )
      union all
      select distinct ID, NAME from SP.SP_ROLES sr, GR_ROLE ur
        where ur.GRANTED_ROLE = sr.NAME
    )            
           )
  loop
    result := r.Name;
    pipe row (result);
  end loop;
end;
/  
grant execute on SP.UserRoles to public; 


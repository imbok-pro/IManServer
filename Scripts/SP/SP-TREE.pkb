CREATE OR REPLACE PACKAGE BODY SP.TREE
-- CATALOG TREE package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.11.2010
-- update 19.11.2010 24.11.2010 13.12.2010 16.12.2010 22.12.2010 06.10.2011
--        19.10.2011 17.06.2013 25.08.2013 25.05.2015
AS

-------------------------------------------------------------------------------
FUNCTION ShortName(Name in VARCHAR2) return VARCHAR2
as
TmpStr SP.COMMANDS.COMMENTS%type;
begin
  select s into TmpStr from
    (select rownum rn, column_value s
        from table(sp.SET_FROM_STRING(Name,'\\')))
          where rn = (select count(*)
                        from table(sp.SET_FROM_STRING(Name,'\\')));
  return TmpStr;
end ShortName;

-------------------------------------------------------------------------------
PROCEDURE CHECK_VALUE(V in SP.TVALUE)
is
tmpVar NUMBER;
begin
  if V.T != SP.G.TTreeNode then
    raise_application_error(-20033,'SP.TREE.CHECK_VALUE. '||
      '��� �������� �� "TreeNode" !');
  end if;
  if V.N is null and instr(nvl(V.S,'0'),'\') > 0 then return; end if;
  if V.N is null then 
    if instr(nvl(V.S,'0'),'\') = 0 then
      raise_application_error(-20033,'SP.TREE.CHECK_VALUE. '||
        '���� N � ���� S �� ������ ������������!');
	end if;
  end if;
  select count(*) into tmpVar from SP.CATALOG_TREE
    where (ID=V.N) or (PARENT_ID=V.N);
-- ���� N ������ ��������� ������ �� ���� ������.
-- ���� ������ ����, �� ���� Y ������ ��������� "1", ����� "0".
  if (tmpVar >1) and (V.Y!=0) then
    raise_application_error(-20033,'SP.TREE.CHECK_VALUE. '||
      '���� Y='||nvl(to_char(V.Y),'null')||' ������ 0!');
  end if;
  if (tmpVar =1) and (V.Y!=1) then
    raise_application_error(-20033,'SP.TREE.CHECK_VALUE. '||
      '���� Y='||nvl(to_char(V.Y),'null')||' ������ 1!');
  end if;
  if tmpVar =0 then
    raise_application_error(-20033,'SP.TREE.CHECK_VALUE. '||
      '���� '||nvl(to_char(V.N),'null')||' �� ������!');
  end if;
end CHECK_VALUE;

-------------------------------------------------------------------------------
PROCEDURE S2V(S in VARCHAR2, V in out NOCOPY SP.TVALUE)
is
tmpVar NUMBER;
tmpN NUMBER;
begin
  if V.T != SP.G.TTreeNode then
    raise_application_error(-20033,'SP.TREE.S2V. '||
      '��� �������� �� "TreeNode" !');
  end if;
  if (S is null) or (trim(S)='\') or (trim(S) is null) then
    V.N:=null;
	V.S:=S;
    return;
  end if;
  tmpVar:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(S,'\\')))
  loop
    select ID into tmpN from SP.CATALOG_TREE
      where upper(NAME)=upper(n.s)
        and nvl(PARENT_ID,-1) = nvl(tmpVar,-1);
    tmpVar:=tmpN;
  end loop;
    select case count(*) when 0 then 1 else 0 end into V.Y from SP.CATALOG_TREE
      where PARENT_ID=tmpVar;
  V.N:=tmpN;
  V.S:=S;
  return;
exception
  when no_data_found then
    begin
	  V.N:=null;
	  V.S:=S;
	end;
    
	--raise_application_error(-20033,'SP.TREE.S2V. '||
    --  '�� ������ ���� '||nvl(S,'null')||' !');
end S2V;

-------------------------------------------------------------------------------
FUNCTION GetID(S in VARCHAR2)return NUMBER
is
tmpVar NUMBER;
tmpN NUMBER;
begin
  if (S is null) or (trim(S)='\') or (trim(S) is null) then
    return -1;
  end if;
  tmpN:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(S,'\\')))
  loop
    begin
    select ID into tmpN from SP.CATALOG_TREE
      where upper(NAME)=upper(n.s)
        and nvl(PARENT_ID,-1) = nvl(tmpN,-1);
    exception when no_data_found then
      return -1;
    end;
  end loop;
  return tmpN;
end GetID;

-----------------------------------------------------------------------------
FUNCTION GetParentID(S in VARCHAR2)return NUMBER
is
tmpVar NUMBER;
tmpN NUMBER;
begin
  tmpVar := -1;
  if (S is null) or (trim(S)='\') or (trim(S) is null) then
    return -1;
  end if;
  tmpN:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(S,'\\')))
  loop
    tmpVar := tmpN; 
    begin
    select ID into tmpN from SP.CATALOG_TREE
      where upper(NAME)=upper(n.s)
        and nvl(PARENT_ID,-1) = nvl(tmpN,-1);
    exception when no_data_found then
      return -1;
    end;
  end loop;
  return tmpVar;
end GetParentID;

-------------------------------------------------------------------------------
FUNCTION FullNodeName(NodeID in NUMBER,S in VARCHAR2) return VARCHAR2
is
tmpVar SP.COMMANDS.COMMENTS%type;
result SP.COMMANDS.COMMENTS%type;
begin
  if NodeID is null then return S; end if;
  select SYS_CONNECT_BY_PATH(NAME, '\') into tmpVar from SP.CATALOG_TREE
    where PARENT_ID is null
    start with ID=NodeID
    connect by prior PARENT_ID=ID;
  -- ���������� ���� ������������ ���������.
  result:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(tmpVar,'\\')))
  loop
    result:=case when result is null then n.s else n.s||'\'||result end;
  end loop;
  return '\'||result;
exception
  when no_data_found then
    raise_application_error(-20033,'SP.TREE.FullNodeName. '||
      '�� ������  ���� '||nvl(to_char(NodeID),'null')||' !');
end FullNodeName;

-------------------------------------------------------------------------------
FUNCTION NODES return SP.TS_VALUES_COMMENTS pipelined
-- ������� ������������� ��������� ����� ����, ���� �� �� ����,
-- ��� ��������� �������, ���� ���� ����.
-- ��� ������ �������� ������� ���������� ���������� ���������� SP.TG.CurValue.
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  -- ���� ���� �� ��������, �� ������������� �������� �������� � �������
  -- �������� "/".
  if SP.TG.CurValue.N is null then
	 tmpVar:=null;
  else  
	 -- ����� ������ ����� 
	 if SP.TG.CurValue.Y=0 then
	    tmpVar:=SP.TG.CurValue.N;
	 else
	    -- ����� ������ ����� ��������
		select PARENT_ID into tmpVar from SP.CATALOG_TREE
	      where ID=SP.TG.CurValue.N;
	 end if;
  end if;  
  for n in (select FULL_NAME, COMMENTS from SP.V_CATALOG_TREE 
              where G.S_EQ(PARENT_ID,tmpVar)=1
              order by NAME)
  loop
    V_C.S_VALUE:=n.FULL_NAME;
    V_C.COMMENTS:=n.COMMENTS;
    pipe row(V_C);
  end loop;
  return;
exception
  when no_data_found then
    raise_application_error(-20033,'SP.TREE.NODES. '||
      '�� ������ ������� ���� '||nvl(to_char(SP.TG.CurValue.N),'null')||' !');
end NODES;

-------------------------------------------------------------------------------
FUNCTION NodeName(NodeID in NUMBER, ILevel in NUMBER) return VARCHAR2
-- ������� ������������� ������������� ��� ����,
-- �������������� �� i-� ������ �� �����.
is
tmpName SP.CATALOG_TREE.NAME%type;
pLevel NUMBER;
begin
  if NodeID is null then return null; end if;
  pLevel:=abs(ILevel);
  begin
    select NAME into tmpName from SP.CATALOG_TREE where ID=NodeID;
  exception
    when no_data_found then
      raise_application_error(-20033,'SP.TREE.NodeName. '||
        '���� � ��������������� '|| nvl(to_char(NodeID),'null')||
        ' �� ������!');
  end;
  if pLevel=0 then return tmpName; end if;
  for c in (select NAME, rownum N from SP.CATALOG_TREE
              where (rownum <= pLevel+1)
              start with ID=NodeID
              connect by prior PARENT_ID = ID
               )
  loop
    if c.N=pLevel+1 then return c.NAME; end if;
  end loop;
  raise_application_error(-20033,'SP.TREE.NodeName. '||
      '���� ������ - '|| nvl(to_char(ILevel),'null')||
      ' y ����'||nvl(FullNodeName(NodeID,''),'null')||' �� ������!');
end NodeName;

-------------------------------------------------------------------------------
FUNCTION LastNodeNames(NodeID in NUMBER, FirstVisibleID in NUMBER)
return VARCHAR2
-- ������� ������������� ���� ����, ���������� �� ����� �� ���������� ����.
is
tmpVar SP.COMMANDS.COMMENTS%type;
result SP.COMMANDS.COMMENTS%type;
begin
  if NodeID is null then return ''; end if;
  if FirstVisibleID is null then
    return FullNodeName(NodeID,'');
  end if;
  select SYS_CONNECT_BY_PATH(NAME, '\') into tmpVar from SP.CATALOG_TREE
    where SP.G.S_EQ(ID,FirstVisibleID)=1
    start with ID=NodeID
    connect by prior PARENT_ID=ID;
  -- ���������� ���� ������������ ���������.
  result:=null;
  for n in (select column_value s from table (SP.SET_FROM_STRING(tmpVar,'\\')))
  loop
    result:=case when result is null then n.s else n.s||'\'||result end;
  end loop;
  return '\'||result;
exception
  when no_data_found then
    raise_application_error(-20033,'SP.TREE.LastNodeNames. '||
        '���� � ��������������� '|| nvl(to_char(NodeID),'null')||
        ' �� ������!');
end LastNodeNames;

END TREE;
/

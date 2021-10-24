CREATE OR REPLACE PACKAGE BODY SP.RolesTree
-- SP RolesTree package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 22.03.2013
-- update 23.03.2015, 19.08.2015

AS
toDel_PID TN;
toDel_NID TN;

------------------------------------------------------------------------------
FUNCTION GetRoot(TreeName in VARCHAR2 default '1') return NUMBER
is
begin
  if not Root.exists(TreeName) then
    Root(TreeName):=null; 
    RootName(TreeName):=''; 
    toDel_PID(TreeName):= null;
    toDel_NID(TreeName):= null;
  end if;  
  return Root(TreeName);
end GetRoot; 
-------------------------------------------------------------------------------
PROCEDURE SetRoot(NID in NUMBER, TreeName in VARCHAR2 default '1')
is
begin
  select NAME into RootName(TreeName) from SP.SP_ROLES
	  where ID = NID;
  Root(TreeName):=NID;
exception
  when no_data_found then 
    Root(TreeName):=null; 
    RootName(TreeName):=''; 
end SetRoot;

-------------------------------------------------------------------------------
PROCEDURE SetRootbyName(NewRoot in VARCHAR2, TreeName in VARCHAR2 default '1')
is
  NID NUMBER;
begin
  select ID into Root(TreeName) from SP.SP_ROLES
	  where upper(Name) = upper(NewRoot);
  RootName(TreeName):=NewRoot;  
exception
  when no_data_found then 
    Root(TreeName):=null; 
    RootName(TreeName):=''; 
end SetRootbyName;

-------------------------------------------------------------------------------
FUNCTION SelectTree(TreeName in VARCHAR2 default '1') 
return SP.TROLE_RECORDS pipelined
is
Type Trec is record 
(
PID NUMBER,
NID NUMBER,
Text VARCHAR2(128),
L NUMBER,
Leaf NUMBER(1)
);
Type IDs is table of NUMBER index by VARCHAR2(128);
rec Trec;
TYPE TrecCursor IS REF CURSOR RETURN Trec;
C TrecCursor;
TrRow SP.TROLE_REC;
CurVG_ID IDs;
CurVP_ID IDs;
GIndex VARCHAR2(64);
PIndex VARCHAR2(64);
PName VARCHAR2(64);
begin
  if not Root.exists(TreeName) then
    Root(TreeName):=null; 
    RootName(TreeName):=''; 
    toDel_PID(TreeName):= null;
    toDel_NID(TreeName):= null;
  end if;  
  trRow:=TROLE_REC(null,null,null,0);
	if (Root(TreeName) is null) or (Root(TreeName) < 0) then
    open C FOR
      select * from(
        select PID as PID, ID as NID, Name as Text,
               Level as L, CONNECT_BY_ISLEAF as Leaf
          from SP.V_ROLES s
          start with s.PID is null
          connect by s.PID = prior s.ID
          order siblings by s.Name) s1
        where ROWNUM <= MaxRecords;
	else
    open C FOR
      select * from(
        select PID as PID,ID as NID, Name as Text,
               Level as L, CONNECT_BY_ISLEAF as Leaf
          from SP.V_ROLES s
          start with s.PID = Root(TreeName)
          connect by s.PID = prior s.ID
          order siblings by s.Name) s1
        where ROWNUM <= MaxRecords;
	end if;
	loop
	  fetch C into rec;
		exit when C%NotFound;
		if C%RowCount= MaxRecords then
		  -- Поскольку запрос к серверу из общих соображений не должен генерировать
      -- ошибку когда это возможно, то выдаем дерево из одного сообщения.
		  close C;
		  trRow.Node:='L0D1';
		  trRow.PNode:=null;
		  trRow.NAME:='Tree is too large and pruned!!!';
		  trRow.Leaf:=1;
	    pipe row (trRow);
			return;
		end if;
	  PName:=to_.str(rec.PID)||'L'||to_.str(rec.L-1);
	  PIndex:=to_.str(rec.NID)||'>'||PName;
		begin
		  CurVP_ID(PIndex):=CurVP_ID(PIndex)+1;
		exception
		  when no_Data_Found then CurVP_ID(PIndex):=1;
		end;
	  GIndex:=to_.str(rec.NID)||'L'||rec.L;
		begin
		  CurVG_ID(GIndex):=CurVG_ID(GIndex)+1;
		exception
		  when no_Data_Found then CurVG_ID(GIndex):=1;
		end;
	  trRow.Node:=GIndex||'D'||CurVG_ID(GIndex);
	  trRow.PNode:=PName||'D'||CurVP_ID(PIndex);
	  trRow.NAME:=rec.TEXT;
		trRow.Leaf:=rec.Leaf;
	  pipe row (trRow);
	end loop;
	if((Root(TreeName) is null) or (Root(TreeName) < 0)) then
		-- Если уровень родителя равен "0" и не задан стартовый узел,
		-- то добавляем связь псевдоузла "Root" с нулл.
		trRow.Node:='L0D1';
		trRow.PNode:=null;
		trRow.NAME:='Root';
		trRow.Leaf:=1;
	  pipe row (trRow);
  else
    -- Если уровень родителя равен "0" и задан стартовый узел,
    -- то добавляем связь этого узла с нулл.
		trRow.Node:=to_.str(Root(TreeName))||'L0D1';
		trRow.PNode:=null;
		trRow.NAME:=RootName(TreeName);
		trRow.Leaf:=1;
	  pipe row (trRow);
	end if;
	Close C;
	return;
exception
  when others then
	  if C%isOpen then Close C;end if;
	  D(SQLERRM,'ERROR SelectRolesTree');
		-- Поскольку запрос из общих соображений не должен генерировать
    -- ошибку когда это возможно, то выдаем дерево из одного сообщения.
		trRow.Node:='L0D1';
		trRow.PNode:=null;
		trRow.NAME:=SQLERRM;
		trRow.Leaf:=1;
		pipe row (trRow);
end SelectTree;

-------------------------------------------------------------------------------
FUNCTION NID(Node in VARCHAR2)return NUMBER
is
tmpVar NUMBER;
begin
  if Node is null then return null;end if;
	if upper(Node)='ROOT' then return null;end if;
  tmpVar:=instr(node,'L',1,1);
	if tmpVar>1 then
    return to_number(substr(Node,1,tmpVar-1));
	else
	  return null;
	end if;
end NID;

-------------------------------------------------------------------------------
FUNCTION Node_L(Node in VARCHAR2)return NUMBER
is
tmpVar NUMBER;
D_position NUMBER;
begin
  if Node is null then return 0;end if;
	if upper(Node)='ROOT' then return 0; end if;
  tmpVar:=instr(node,'L',1,1);
	if tmpVar>1 then
    D_position:=instr(node,'D',1,1);
    if D_position=0 then return 0; end if;
    return to_number(substr(Node,tmpVar+1,D_Position-tmpVar-1));
	else
	  return 0;
	end if;
end Node_L;


-------------------------------------------------------------------------------
PROCEDURE Ins_Role_Link(N_Pnode in VARCHAR2,-- Новый родитель.
                        RoleName in VARCHAR2 -- Добавляемый узел.
                        )
is
N_PID NUMBER;
begin
  --d('INSERT Pnode=>'||N_Pnode||' RoleName=>'||RoleName,
  --'Rolestree');
  N_PID:= NID(N_PNode);
  insert into SP.V_ROLES (NAME,PID) values (RoleName, N_PID);
  commit;
end Ins_Role_Link;

-------------------------------------------------------------------------------
PROCEDURE Upd_Role_Link(N_Pnode in VARCHAR2,
                        O_Node in VARCHAR2,
                        O_Pnode in VARCHAR2)
is
O_NID NUMBER;
O_PID NUMBER;
N_PID NUMBER;
begin
  --d('UPDATE Pnode=>'||N_Pnode||' O_node=>'||O_node||' O_Pnode=>'||O_Pnode,
  --'Rolestree');
  O_NID:= NID(O_Node);
  O_PID:= NID(O_PNode);
  N_PID:= NID(N_PNode);
	update SP.V_ROLES
	  set PID=N_PID
	  where (ID=O_NID) 
      and (G.S_EQ(PID,O_PID)>0);
	commit;
end Upd_Role_Link;

-------------------------------------------------------------------------------
PROCEDURE Del_Role_or_Link(O_Node in out VARCHAR2,
                           O_Pnode in out VARCHAR2,
                           TreeName in VARCHAR2 default '1')
is
begin
 -- Если выделенная позиция дерева имеет детей, то DbTree удаляет всю ветку,
 -- начиная с детей и заканчивая выделенной позицией,
 -- а нам надо удалить только связь или группу, которая выделена.
 -- Последовательно запоминаем все удаления в массив,
 -- а удаляем последнюю в процедуре DoDelete, которую можно вызвать
 -- из ON_Idle(клиента).
  d('DELETE treeName '||TreeName||' O_node=>'||O_node||' O_Pnode=>'||O_Pnode,
    'Rolestree');
	toDel_PID(TreeName):=NID(O_Pnode);
	toDel_NID(TreeName):=NID(O_node);
end Del_Role_or_Link;

-------------------------------------------------------------------------------
PROCEDURE DoDelete(TreeName in VARCHAR2 default '1')
is
begin
  -- Если PID есть нулл, то удаляем группу, иначе связь.
  --d('DODELETE O_node=>'||to_char(toDel(Set_Name).NID)||
  --           ' Pnode=>'||to_char(toDel(Set_Name).PID),'dbtree');
  if toDel_PID(TreeName) is null then
    delete from SP.V_ROLES where ID=toDel_NID(TreeName);
  else  
	  delete from SP.V_ROLES 
      where PID=toDel_PID(TreeName)
        and ID=toDel_NID(TreeName);
  end if;  
	commit;
end DoDelete;

-------------------------------------------------------------------------------
FUNCTION Is_Link_Possible(Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN
is
Src NUMBER;
Dest NUMBER;
tmpVar NUMBER(1);
begin
  -- Перенос в корень не возможен, поскольку это означает удаление всех связей!
  if (Src_Node='L0D1')or (Dest_Node='L0D1') then return false; end if;
  Src:=NID(Src_Node);
  Dest:=NID(Dest_Node);
  if Src=Dest then return false; end if;
	-- Возвращаем ложь, если циклическая ссылка
	select count(*)into tmpVar 
   from (
	  select ID from SP.V_ROLES
      start with PID  = Src
      connect by PID = prior ID
         )
	where (ID = Dest);
	if tmpVar>0 then return false; end if;
  -- если роль уже содержит эту роль.
	-- 	select count(*)into tmpVar from LinkTable
	-- 		where (Child = Child_Src)and(Parent = Parent_Dest);
	select count(*) into tmpVar from SP.V_ROLES
		where (ID = Src) and (G.S_EQ(PID,Dest)=1) and rownum < 2;
	if tmpVar>0 then return false; end if;
	return true;
end Is_Link_Possible;

BEGIN
  toDel_PID('1'):= null;
  toDel_NID('1'):= null;
  Root('1'):= null;
  RootName('1'):= null;
END RolesTree;
/

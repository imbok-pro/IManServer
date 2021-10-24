CREATE OR REPLACE PACKAGE BODY SP.Graph2Tree
-- SP Graph as Tree package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 09.06.2013 17.06.2013 25.06.2013 25.08.2013 17.10.2013 25.05.2015
--        22.01.2021
AS
Type TDR is RECORD(PID NUMBER,NID NUMBER);
Type T2TDR is TABLE of TDR index by VARCHAR2(128);
toDel T2TDR;
curSet T2NUMBERS;
curSetValid TBOOLEANS;
-------------------------------------------------------------------------------
PROCEDURE isSetExists(SetName in VARCHAR2)
is
BEGIN
--   d('SetName =>'||SetName,'Graph2Tree');
  if not curSetValid.exists(SetName) then
		Root(SetName):= null;
		RootName(SetName):='';
		MaxLevel(SetName):=-1;
		curSetValid(SetName) :=false;
		curSet(SetName):=SP.TNUMBERS(-1);
	  toDel(SetName).PID:=null;
	  toDel(SetName).NID:=null;
  end if;
--   d('Root =>'||to_Char(Root(SetName))||
-- 		'  RootName =>'||RootName(SetName)||
-- 		'  MaxLevel =>'||to_Char(MaxLevel(SetName))||
-- 		'  curSetValid =>'||b2char(curSetValid(SetName))||
-- 	  '  toDel.PID =>'||toDel(SetName).PID||
-- 	  '  toDelNID =>'||toDel(SetName).NID,'Graph2Tree');
END isSetExists;
-------------------------------------------------------------------------------
FUNCTION GetRoot(Set_Name in VARCHAR2 default '0') return NUMBER
is
begin
  isSetExists(Set_Name);
  return Root(Set_Name);
end GetRoot; 
-------------------------------------------------------------------------------
PROCEDURE SetRoot(NID in NUMBER,Set_Name in VARCHAR2 default '0')
is
begin
  isSetExists(Set_Name);
  select NAME into RootName(Set_Name) from SP.GROUPS
	  where ID = NID;
  if G.notEQ(NID,Root(Set_Name)) then curSetValid(Set_Name):=false; end if;
  Root(Set_Name):=NID;
exception
  when no_data_found then 
    Root(Set_Name):=null; 
    RootName(Set_Name):=''; 
    curSetValid(Set_Name):=false;
end SetRoot;
-------------------------------------------------------------------------------
PROCEDURE SetRootbyName(NewRoot in VARCHAR2,Set_Name in VARCHAR2 default '0')
is
  NID NUMBER;
begin
  isSetExists(Set_Name);
  select ID into Root(Set_Name) from SP.GROUPS
	  where upper(Name) = upper(NewRoot);
  if G.notUPEQ(RootName(Set_Name), NewRoot) then 
    curSetValid(Set_Name) :=false; 
  end if;
  RootName(Set_Name):=NewRoot;  
exception
  when no_data_found then 
    Root(Set_Name):=null; 
    RootName(Set_Name):=''; 
    curSetValid(Set_Name):=false;
end SetRootbyName;
-------------------------------------------------------------------------------
PROCEDURE SetMaxLevel(NewMaxLevel in NUMBER,Set_Name in VARCHAR2 default '0')
is
begin
  isSetExists(Set_Name);
  if MaxLevel(Set_Name) != NewMaxLevel then 
    curSetValid(Set_Name):=false; 
  end if;
  MaxLevel(Set_Name):=NewMaxLevel;
end SetMaxLevel;
-------------------------------------------------------------------------------
FUNCTION SelectNodes(Set_Name in VARCHAR2 default '0') return SP.TNumbers
is
begin
	isSetExists(Set_Name);
	if curSetValid(Set_Name) then return curSet(Set_Name); end if;
	if (Root(Set_Name) is null) or (Root(Set_Name) < 0) then
	  if (MaxLevel(Set_Name) is null) or (MaxLevel(Set_Name) <= 0) then
		  select distinct NID bulk collect into curSet(Set_Name) from(
		    select P_ID as PID, G_ID as NID
		      from SP.V_GROUPS s
		      start with s.P_ID is null
		      connect by s.P_ID = prior s.G_ID
			    ) s1
			  where ROWNUM <= MaxRecords;
		else
		  select distinct NID bulk collect into curSet(Set_Name) from(
		    select P_ID as PID,G_ID as NID, Level as L 
		      from SP.V_GROUPS s
		      start with s.P_ID is null
		      connect by s.P_ID = prior s.G_ID
			    ) s1
			  where (s1.L <= MaxLevel(Set_Name)) and (ROWNUM <= MaxRecords);
		end if;
	else
		if (MaxLevel(Set_Name) is null) or (MaxLevel(Set_Name) <= 0) then
		  select distinct NID bulk collect into curSet(Set_Name) from(
        select 1 as PID, Root(Set_Name) as NID from dual
        union all
		    select P_ID as PID,G_ID as NID
		      from SP.V_GROUPS s
		      start with s.P_ID = Root(Set_Name)
		      connect by s.P_ID = prior s.G_ID
			    ) s1
			  where ROWNUM <= MaxRecords;
		else
		  select distinct NID bulk collect into curSet(Set_Name) from(
        select 1 as PID, Root(Set_Name) as NID, 1 as L from dual
        union all
  	    select P_ID as PID,G_ID as NID, Level as L 
		      from SP.V_GROUPS s
		      start with s.P_ID = Root(Set_Name)
		      connect by s.P_ID = prior s.G_ID
			    ) s1
			  where (s1.L <= MaxLevel(Set_Name)) and (ROWNUM <= MaxRecords);
		 end if;
	end if;
	if curSet(Set_Name).count = MaxRecords then
	  curSet(Set_Name):=SP.TNUMBERS(-1);
	end if;
	curSetValid(Set_Name):=true;
	return curSet(Set_Name);
end SelectNodes;
-------------------------------------------------------------------------------
PROCEDURE Reset(Set_Name in VARCHAR2 default '0')
is
begin
  curSetValid(Set_Name) :=false;
end Reset;
-------------------------------------------------------------------------------
FUNCTION SelectTree(Set_Name in VARCHAR2 default '0') 
return SP.TGRAPH2TREE_NODES
pipelined
is
Type Trec is record (
PID NUMBER,
NID NUMBER,
Text VARCHAR2(128),
L NUMBER,
Leaf NUMBER(1),
Line NUMBER(9));
rec Trec;
TYPE TrecCursor IS REF CURSOR RETURN Trec;
C TrecCursor;
TrRow SP.TGRAPH2TREE_NODE;
CurVG_ID TNUMBERS;
CurVP_ID TNUMBERS;
GIndex VARCHAR2(64); PIndex VARCHAR2(64); PName VARCHAR2(64);
begin
  isSetExists(Set_Name);
  trRow:=TGraph2Tree_NODE(null,null,null,0,0);
	if (Root(Set_Name) is null) or (Root(Set_Name) < 0) then
	  if (MaxLevel(Set_Name) is null) or (MaxLevel(Set_Name) <= 0) then
		  open C FOR
			  select * from(
			    select P_ID as PID, G_ID as NID, Name as Text,
                 Level as L, CONNECT_BY_ISLEAF as Leaf,
                 LINE as Line
			      from SP.V_GROUPS s
			      start with s.P_ID is null
			      connect by s.P_ID = prior s.G_ID
				    order siblings by s.Line) s1
				  where ROWNUM <= MaxRecords;
		else
		  open C FOR
			  select * from(
			    select P_ID as PID,G_ID as NID, Name as Text,
                 Level as L, CONNECT_BY_ISLEAF as Leaf,
                 LINE as Line  
			      from SP.V_GROUPS s
			      start with s.P_ID is null
			      connect by s.P_ID = prior s.G_ID
				    order siblings by s.Line) s1
				  where (s1.L <= MaxLevel(Set_Name)) and (ROWNUM <= MaxRecords);
		end if;
	else
		if (MaxLevel(Set_Name) is null) or (MaxLevel(Set_Name) <= 0) then
		  open C FOR
			  select * from(
			    select P_ID as PID,G_ID as NID, Name as Text,
                 Level as L, CONNECT_BY_ISLEAF as Leaf,
                 LINE as Line  
			      from SP.V_GROUPS s
			      start with s.P_ID = Root(Set_Name)
			      connect by s.P_ID = prior s.G_ID
				    order siblings by s.Line) s1
				  where ROWNUM <= MaxRecords;
		else
	    open C FOR
			  select * from(
			    select P_ID as PID,G_ID as NID, Name as Text,
                 Level as L, CONNECT_BY_ISLEAF as Leaf,
                 LINE as Line  
			      from SP.V_GROUPS s
			      start with s.P_ID = Root(Set_Name)
			      connect by s.P_ID = prior s.G_ID
				    order siblings by s.Line) s1
				  where (s1.L <= MaxLevel(Set_Name)) and (ROWNUM <= MaxRecords);
		 end if;
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
		  trRow.TEXT:='Tree is too large and pruned!!!';
		  trRow.Leaf:=1;
		  trRow.Line:=1;
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
	  trRow.TEXT:=rec.TEXT;
		trRow.Leaf:=rec.Leaf;
		trRow.Line:=rec.Line;
	  pipe row (trRow);
	end loop;
	if((Root(Set_Name) is null) or (Root(Set_Name) < 0)) then
		-- Если уровень родителя равен "0" и не задан стартовый узел,
		-- то добавляем связь псевдоузла "Root" с нулл.
		trRow.Node:='L0D1';
		trRow.PNode:=null;
		trRow.TEXT:='Root';
		trRow.Leaf:=1;
		trRow.Line:=0;
	  pipe row (trRow);
  else
    -- Если уровень родителя равен "0" и задан стартовый узел,
    -- то добавляем связь этого узла с нулл.
		trRow.Node:=to_.str(Root(Set_Name))||'L0D1';
		trRow.PNode:=null;
		trRow.TEXT:=RootName(Set_Name);
		trRow.Leaf:=1;
		trRow.Line:=0;
	  pipe row (trRow);
	end if;
	Close C;
	return;
exception
  when others then
	  if C%isOpen then Close C;end if;
	  D(SQLERRM,'ERROR SelectTree');
		-- Поскольку запрос из общих соображений не должен генерировать
    -- ошибку когда это возможно, то выдаем дерево из одного сообщения.
		trRow.Node:='L0D1';
		trRow.PNode:=null;
		trRow.TEXT:=SQLERRM;
		trRow.Leaf:=1;
		trRow.Line:=0;
		pipe row (trRow);
end SelectTree;
-------------------------------------------------------------------------------
-- Функция извлекает NID из Node (или PID из PNode).
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
-- Функция извлекает LEVEL из Node или PNode.
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
------------------------------------------------------------------------------
PROCEDURE Ins_Group_or_Link(N_Pnode in VARCHAR2,N_Text in VARCHAR2)
is
  N_PID NUMBER;
begin
  -- Если идентификатор родителя сгенерён DbTree,
	-- то это перенос "хвоста" дерева при копировании. Такие записи мы 
  -- игнорируем.
  if instr(N_PNode,'-',1,1)>0 then return; end if;
  --d('INSERT Pnode=>'||N_Pnode||' text=>'||N_text,'dbtree');
  -- Если узел N_Text существует, то вставляем связь (NODE=>PNODE) в таблицу
  -- связей,  если только N_PNode не нулл.
	-- Иначе вставляем как новый узел, так и связь, если N_PNode не нулл.
	-- Проверку на зацикливание при этом необходимо проверять в определяющих
  -- таблицах или представлениях.
  N_PID:= NID(N_PNode);
  insert into SP.V_GROUPS (Name, P_ID) values (N_Text, N_PID);
	if ACommit then commit; end if;
end Ins_Group_or_Link;
-------------------------------------------------------------------------------
PROCEDURE Upd_Group_or_Link(N_Pnode in VARCHAR2,N_Text in VARCHAR2,
                             O_Node in VARCHAR2,O_Pnode in VARCHAR2)
is
O_NID NUMBER;
O_PID NUMBER;
N_PID NUMBER;
begin
  --d('UPDATE Pnode=>'||N_Pnode||' text=>'||N_text||
	--	' O_node=>'||O_node||' O_Pnode=>'||O_Pnode,'dbtree');
  O_NID:= NID(O_Node);
  O_PID:= NID(O_PNode);
  N_PID:= NID(N_PNode);
	update SP.V_GROUPS
	  set G_ID=O_NID, Name=N_text, P_ID=N_PID, LINE=null
	  where (G_ID=O_NID) and (G.S_EQ(P_ID,O_PID)>0);
	if ACommit then commit; end if;
end Upd_Group_or_Link;
-------------------------------------------------------------------------------
PROCEDURE Upd_Link_Line(O_Node in VARCHAR2,
                        O_Pnode in VARCHAR2,
                        NewLine in NUMBER)
is
O_NID NUMBER;
O_PID NUMBER;
begin
  --d('UPDATE O_node=>'||O_node||' Line=>'||Line,'dbtree');
  O_NID:= NID(O_Node);
  O_PID:= NID(O_Pnode);
	update SP.V_GROUPS
	  set LINE=NewLine
	  where (G_ID=O_NID) and (P_ID = O_PID);
	if ACommit then commit; end if;
end Upd_Link_Line;
-------------------------------------------------------------------------------
PROCEDURE Del_Group_or_Link(O_Node in out VARCHAR2,
                            O_Pnode in out VARCHAR2,
                            Set_Name in VARCHAR2 default '0')
is
begin
  isSetExists(Set_Name);
 -- Если выделенная позиция дерева имеет детей, то DbTree удаляет всю ветку,
 -- начиная с детей и заканчивая выделенной позицией,
 -- а нам надо удалить только связь или группу, которая выделена.
 -- Последовательно запоминаем все удаления в массив,
 -- а удаляем последнюю в процедуре DoDelete, которую можно вызвать
 -- из ON_Idle(клиента).
  --d('DELETE O_node=>'||O_node||' O_Pnode=>'||O_Pnode,'dbtree');
	toDel(Set_Name).PID:=NID(O_Pnode);
	toDel(Set_Name).NID:=NID(O_node);
end Del_Group_or_Link;
-------------------------------------------------------------------------------
PROCEDURE DoDelete(Set_Name in VARCHAR2 default '0')
is
begin
  isSetExists(Set_Name);
  -- Если PID есть нулл, то удаляем группу, иначе связь.
  --d('DODELETE O_node=>'||to_char(toDel(Set_Name).NID)||
  --           ' Pnode=>'||to_char(toDel(Set_Name).PID),'dbtree');
  if toDel(Set_Name).PID is null then
    delete from SP.V_GROUPS where G_ID=toDel(Set_Name).NID;
  else  
	  delete from SP.V_GROUPS 
      where (P_ID=toDel(Set_Name).PID) and (G_ID=toDel(Set_Name).NID);
  end if;  
	if ACommit then commit; end if;
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
	  select G_ID from SP.V_GROUPS
      start with P_ID  = Src
       connect by P_ID = prior G_ID
         )
	where (G_ID = Dest);
	if tmpVar>0 then return false; end if;
  -- если группа уже содержит эту группу.
	-- 	select count(*)into tmpVar from LinkTable
	-- 		where (Child = Child_Src)and(Parent = Parent_Dest);
	select count(*) into tmpVar from SP.V_GROUPS
		where (G_ID = Src) and (G.S_EQ(P_ID,Dest)=1) and rownum < 2;
	if tmpVar>0 then return false; end if;
	return true;
end Is_Link_Possible;
-------------------------------------------------------------------------------
FUNCTION GROUP_NODES return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  curName SP.COMMANDS.COMMENTS%type;
  curCOMMENTS SP.COMMANDS.COMMENTS%type;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  --Устанавливаем значение корня  
  SetRoot(SP.TG.CurValue.N,'TVALUE');
  if SP.TG.CurValue.N is null then
    curName:='Root';
    curCOMMENTS:='Все группы';
  else
    curName:=SP.TG.CurValue.asString();
    select COMMENTS into curCOMMENTS from SP.V_PRIM_GROUPS 
      where G_ID = SP.TG.CurValue.N;
  end if;  
  -- Выдаём результат.  
  for n in (
		select NAME, COMMENTS, ROWNUM*100000 N 
      from (select NAME,COMMENTS from SP.V_PRIM_GROUPS
		          where G_ID in(
                select * from Table (SP.Graph2Tree.SelectNodes('TVALUE')))
		  order by Name)
		union
		select NAME, COMMENTS, rownum+5 N 
      from (select NAME, COMMENTS from SP.V_GROUPS
		          where G_ID in (select P_ID from SP.V_GROUPS 
                               where G_ID = SP.TG.CurValue.N)
		  order by Name)
		union
		select distinct NAME, COMMENTS, rownum N from
		  (select 'Root' NAME, 'Все группы' COMMENTS, 1 n from dual
		   union
		   select curName NAME,
              decode(curName,'Root','Все группы', curCOMMENTS) COMMENTS,
              decode(curName,'Root',1,0) n from dual
		   order by n)
		order by N
            )
  loop
    V_C.ID := null;
    V_C.S_VALUE:=n.NAME;
    V_C.COMMENTS:=n.COMMENTS;
    pipe row(V_C);
  end loop;
  return;
exception
  when others then
    d(SQLERRM,'ERROR in SP.GRAPH2TREE.GROUP_NODES');
    d(nvl(to_char(SP.TG.CurValue.N),'null'),
      'ERROR in SP.GRAPH2TREE.GROUP_NODES');
    raise_application_error(-20033,'SP.GRAPH2TREE.GROUP_NODES. '||SQLERRM||
      ' идентификатор группы:'||nvl(to_char(SP.TG.CurValue.N),'null')||' !');
end GROUP_NODES;
-------------------------------------------------------------------------------
BEGIN
isSetExists('0');
END Graph2Tree;
/

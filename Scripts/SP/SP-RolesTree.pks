CREATE OR REPLACE PACKAGE SP.RolesTree
-- SP RolesTree package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 22.03.2015
-- update 23.03.2015 19.08.2015

AS
-- !!! сделать глобальным параметром
MaxRecords PLS_INTEGER:=10000;
type TN is table of NUMBER index by VARCHAR2(60);
type TS is table of VARCHAR2(60) index by VARCHAR2(60);
Root TN;
RootName TS;
/* 
NID - идентификатор Роли						 
PID - идентификатор родителя						 
TEXT - имя Роли
  Функция выборки дерева предоставляет нам полное дерево, в котором каждый узел
в отличие от представления имеет одного родителя.
  Формат записи узла NID||'L'||Level||D||occurence. 
  Одновременно можно оперировать с несколькими деревьями,
каждое из которых будет иметь свой корень.
  При этом, параметр TreeName определяет имя набора.
  Если параметр не указан используется набор с именем "1"
*/
-- Процедура предоставляет идентификатор корневого уровеня.
-- TreeName имя набора.
FUNCTION GetRoot(TreeName in VARCHAR2 default '1') return NUMBER;

-- Процедура устанавливает корневой уровень по идентификатору узла.
PROCEDURE SetRoot(NID in NUMBER, TreeName in VARCHAR2 default '1');

-- Процедура устанавливает корневой узел по имени узла.
PROCEDURE SetRootbyName(NewRoot in VARCHAR2, TreeName in VARCHAR2 default '1');

-- Функция предоставляет дерево ролей.
FUNCTION SelectTree(TreeName in VARCHAR2 default '1') 
return SP.TROLE_RECORDS pipelined;
  
-- Процедура добавляет связь роли с другим родителем. 
-- Процедура производит commit.
PROCEDURE Ins_Role_Link(N_Pnode in VARCHAR2,--Новый родитель.
                        RoleName in VARCHAR2 -- Добавляемый узел.
                        );
-- Процедура перемещает роль к другому родителю. 
-- Процедура производит commit.
PROCEDURE Upd_Role_Link(N_Pnode in VARCHAR2,--Новый родитель.
                        O_Node in VARCHAR2, --Обновляемый узел.
                        O_Pnode in VARCHAR2 --Старый родитель.
                        );

-- Запоминает параметры для последующего удаления.
PROCEDURE Del_Role_or_Link(O_Node in out VARCHAR2, 
                           O_Pnode in out VARCHAR2,
                           TreeName in VARCHAR2 default '1'
                          );
                            
-- Выполняет собственно удаление.
-- Процедура производит commit.
PROCEDURE DoDelete(TreeName in VARCHAR2 default '1');

-- Функция определяет возможность установления связи между Src_Node и
-- Dest_Node (в качестве родителя).
FUNCTION Is_Link_Possible(Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN;

-- Извлекает NID из Node (или PID из PNode).
FUNCTION NID(Node in VARCHAR2)return NUMBER;
pragma RESTRICT_REFERENCES(NID,RNDS,WNDS,RNPS,WNPS);

-- Извлекает LEVEL из Node или PNode.
FUNCTION Node_L(Node in VARCHAR2)return NUMBER;


End RolesTree;
/


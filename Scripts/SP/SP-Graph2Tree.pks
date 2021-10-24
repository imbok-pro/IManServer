CREATE OR REPLACE PACKAGE SP.Graph2Tree
-- SP Graph as Tree package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 09.06.2013 25.06.2013 25.06.2013 16.10.2013 31.10.2013
--        22.03.2015

AS
-- !!! сделать глобальным параметром
MaxRecords PLS_INTEGER:=10000;
ACommit BOOLEAN :=false;
-- Массив чисел.
TYPE TNUMBERS IS TABLE OF NUMBER INDEX BY VARCHAR2(128);
-- Массив имён.
TYPE TNAMES IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(128);
-- Булев массив.
TYPE TBOOLEANS IS TABLE OF BOOLEAN INDEX BY VARCHAR2(128);
TYPE T2NUMBERS is TABLE of SP.TNUMBERS INDEX by VARCHAR2(128);
Root TNUMBERS;
RootName TNAMES;
MaxLevel TNUMBERS;
/* 
NID - идентификатор сущности						 
PID - идентификатор родителя						 
TEXT - название сущности
Функция выборки дерева предоставляет нам полное дерево, в котором каждый узел
в отличие от представления имеет одного родителя.
Формат записи узла NID||'L'||Level||D||occurence 
*/
-- Процедура предоставляет идентификатор корневого уровеня.
FUNCTION GetRoot(Set_Name in VARCHAR2 default '0') return NUMBER;
-- Процедура устанавливает корневой уровень по идентификатору узла.
PROCEDURE SetRoot(NID in NUMBER,Set_Name in VARCHAR2 default '0');
-- Процедура устанавливает корневой узел по имени узла.
PROCEDURE SetRootbyName(NewRoot in VARCHAR2,Set_Name in VARCHAR2 default '0');
-- Процедура устанавливает максимальный уровень рассмотрения.
PROCEDURE SetMaxLevel(NewMaxLevel in NUMBER,Set_Name in VARCHAR2 default '0');
-- Функция предоставляет идентификаторы групп с учётом корня и кол-ва уровней.
FUNCTION SelectNodes(Set_Name in VARCHAR2 default '0') return SP.TNumbers;
-- Процедура сбрасывает признак актуальности набора идентификаторов.
PROCEDURE Reset(Set_Name in VARCHAR2 default '0');
-- Функция предоставляет граф в виде дерева с учётом корня и кол-ва уровней.
FUNCTION SelectTree(Set_Name in VARCHAR2 default '0') 
  return SP.TGRAPH2TREE_NODES pipelined;
-- Процедура добавляет новый узел с именем заданным, текстовым полем N_Text
-- к родителю с именем N_Pnode.
PROCEDURE Ins_Group_or_Link(N_Pnode in VARCHAR2,N_Text in VARCHAR2);
-- Процедура обновляет группу или связь. 
PROCEDURE Upd_Group_or_Link(N_Pnode in VARCHAR2,--Новый родитель.
                            N_Text in VARCHAR2, --Новое имя.
                            O_Node in VARCHAR2, --Обновляемый узел.
                            O_Pnode in VARCHAR2 --Старый родитель.
                            );
-- Процедура изменяет положение связи (порядковый номер) в группе. 
-- Обновляемая связь задаётся двумя узлами: 
-- идентификатором узла и идентификатором его родителя.
PROCEDURE Upd_Link_Line(O_Node in VARCHAR2, 
                        O_Pnode in VARCHAR2,
                        NewLine in NUMBER -- Новый номер O_Node в O_Pnode.
                        );
-- Запоминает параметры для последующего удаления.
PROCEDURE Del_Group_or_Link(O_Node in out VARCHAR2,
                            O_Pnode in out VARCHAR2,
                            Set_Name in VARCHAR2 default '0');
-- Выполняет собственно удаление.
PROCEDURE DoDelete(Set_Name in VARCHAR2 default '0');
-- Функция определяет возможность установления связи между Src_Node и
-- Dest_Node (в качестве родителя).
FUNCTION Is_Link_Possible(Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN;
-- Извлекает NID из Node (или PID из PNode).
FUNCTION NID(Node in VARCHAR2)return NUMBER;
pragma RESTRICT_REFERENCES(NID,RNDS,WNDS,RNPS,WNPS);
-- Извлекает LEVEL из Node или PNode.
FUNCTION Node_L(Node in VARCHAR2)return NUMBER;
-- Функция предоставляет состав группы.
-- При выборе значений функция использует глобальную переменную SP.TG.CurValue.
FUNCTION GROUP_Nodes return SP.TS_VALUES_COMMENTS pipelined;

End Graph2Tree;
/


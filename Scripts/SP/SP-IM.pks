CREATE OR REPLACE PACKAGE SP.IM
-- IntergraphManager package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.08.2010
-- update 12.10.2010 03.11.2010 09.11.2010 15.11.2010 24.11.2010 09.12.2010
--        11.11.2011 18.11.2011 23.11.2011 11.01.2012 17.01.2012 30.01.2012
--        04.04.2013 25.08.2013 29.08.2013 16.06.2014 20.06.2014 24.06.2014
--        03.07.2014 26.20.2014-03.11.2014 25.05.2015 03.02.2016 25.02.2016
--        29.02.2016 06.11.2016 10.04.2017-11.04.2017 17.04.2017 11.09.2017
--        07.11.2017 01.12.2017 14.12.2017 19.02.2018 05.03.2018 22.04.2019
--        23.07.2019 01.10.2020 12.11.2020 18.05.2021

AS
-- Данный пакет является основой взаимодействия сервера алгоритмов с серверами
-- моделей.

-- Сообщение об исправимой ошибке (предупреждение).
WM SP.COMMANDS.COMMENTS%type;
-- Сообщение о критической ошибке.
EM SP.COMMANDS.COMMENTS%type;
-- Код текущей выполняющийся команды, на стороне IMan.
-- Точнее код последней переданной команды IMan или нулл, если
-- происходит запрос очередной команды.
CurCommand NUMBER;
-- Массив параметров команды.
PP SP.G.TMACRO_PARS;
-- Массив объектов.
OS SP.G.TOBJECTS;
-- Массив объектов, используемый в процессе выбора во внутренней модели.
SS SP.G.TOBJECTS;
-- Массив сообщений макропроцедуры.
-- Массив очищается при запуске макропроцедуры или после его прочтения
-- функцией get_Messages.
MESSAGES SP.G.TNAMES;

-----------------------------
-- Макропроцедура состоит из макрокоманд и представляет собой набор команд для 
-- построения и изменения объектов на сервере модели.
-- Перед запуском макропроцедуры на сервере клиенту необходимо передать на
-- сервер значения параметров, определяющих поведение запускаемой процедуры.
-- После выполнения ряда макрокоманд, клиету так же необходимо передать
-- значения параметров, возвращаемых этими командами.
-- Форматы вызова функции передачи параметров из клиента могут быть следующими:
--   Sp.IM.Set_Par(<ParName>,SP.TVALUE(<ParType>,N,D,DisN,S,X,Y));
--   Sp.IM.Set_Par(<ParName>,SP.TVALUE(<ParType>,<S_Value>));
-- где, ParName - имя параметра
--      ParType - тип параметра
--      S_Value - значение параметра в виде строки.
---------------------------

-- Функция добавляет  или изменяет параметр либо в массиве параметров,
-- если клиент находится в режиме ввода параметров, либо массив результата, 
-- если клиент - в режиме выполнения команд.  
-- Функция возвращают нулл, если всё нормально или сообщение об ошибке.
-- Функция добавляет параметр, если таковой отсутствует.
FUNCTION Set_Par(ParName in VARCHAR2, ParValue in SP.TVALUE)return VARCHAR2;

-- Перезагруженный вариант функции. Получает тип значения по имени параметра.
-- Не может быть использован для добавления параметра.
-- В случае отсутствия параметра сообщает об ошибке.
-- Игнорирует (не добавляет и не ругается) отсутствие служебных параметров
-- SP3DTYPE,IS_SYSTEM и IS_TINY
FUNCTION Set_Par(ParName in VARCHAR2, ParValue in VARCHAR2)return VARCHAR2;

-- Функция копирует параметры объекта каталога во временную рабочую таблицу
-- параметров команды. 
-- Эта таблица впоследствии может быть изменена функциями Set_Par.
-- Функция возвращают нулл, если всё нормально или сообщение об ошибке.
-- ObjectName - полное имя объекта, например: (SysObjects.#Native Object).
-- Если входной параметр null, то функция НЕ возвращает ошибку, но и
-- не заполняет таблицу 
FUNCTION Set_Pars(ObjectName in VARCHAR2) return VARCHAR2;
FUNCTION Set_Pars(ObjectID in NUMBER) return VARCHAR2;

-- Функция предназначени для передачи на сервер параметров объектов.
-- Функция используется в командах "GET_SELECTED", "GET_OBJECTS",
-- "GET_SYSYEMS" и "GET_ALL_SYSYEMS" и "Set_Root".
-- Функция возвращают нулл, если всё нормально или сообщение об ошибке.
FUNCTION Set_ObjectPar(ObjectNum in NUMBER,
                       ParName in VARCHAR2,
                       ParValue in TValue) 
return VARCHAR2;

-- Процедура очищает массив объектов.
PROCEDURE Clear_Objects;

-- Процедура используется для переключения между серверами моделей
-- и установки имени текущей модели. 
-- Процедура очищает значение опорного объекта, установка значения опорного
-- объекта в соответствии с сервером модели возложено на клиента!
PROCEDURE SET_SERVER(ModelName in VARCHAR2, ServerType in NUMBER);

-- Процедура используется для установки переменной сервера SP.M.ROOT в 
-- соответствии со значением опорного объекта иерархии клиента.
-- В частности после выполнения команды "SET_PATH" необходимо вызвать эту
-- процедуру. Процедура использует объект из массива "OS",
-- проверяя при этом, что он единственный.
-- Объект на корорый указывает опорный объект при этом может не существовать во
-- внутренней модели IMan.
-- Если опорный объект существует во внутренней модели, то процедура заполняет
-- параметр "ID" уникальным идентификатором объекта.
-- Если текущий объект является корнем иерархии,
-- то процедура установит его ID равным "1".
-- В остальных случаях, если объект отсутствует во внутренней модели,
-- его "ID" будет установлен в нулл. 
PROCEDURE SET_ROOT;   

-- Запуск макропроцедуры.
-- Если у макропроцедуры есть параметры, то клиент передаёт их перед
-- вызовом этой функции.
-- Функция возвращают нулл, если всё нормально или сообщение об ошибке.
FUNCTION START_MACRO(MacroName in VARCHAR2) return VARCHAR2;
FUNCTION START_MACRO(ObjectID in NUMBER) return VARCHAR2;

-- После успешного запуска макропроцедуры, клиент, в цикле, вызывает функцию,
-- предоставляющюю очередной идентификатор команды,
-- которую необходимо исполнить.
-- Цикл завершается при получении команды G.Cmd_CANCEL или G.Cmd_Return.
FUNCTION get_COMMAND return NUMBER;

-- Функция предоставляет сообщение об ошибке.
-- В особенности это полезно после получения команды G.Cmd_CANCEL.
FUNCTION get_EM return VARCHAR2;  

-- Функция предоставляет сообщение об исправимой ошибке.
-- В особенности это полезно после получения команды G.Cmd_Get_User_Input.
FUNCTION get_WM return VARCHAR2;  

-- Функция предоставляет все сообщения макропроцедуры в виде CLOB,
-- после чего очищает массив сообщений.
FUNCTION get_MESSAGES return CLOB;  

-- Функция предоставляет параметры текущей команды или выборку из представления
-- SP.V_COMMAND_PAR_S, 
-- если стек пуст (макропроцедура не запущена или выполняется команда
-- "GET_USER_INPUT").
-- Если для выполнения команды клиенту необходимы параметры, то ему необходимо
-- выполнить следующий запрос:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y
--   from table(SP.IM.get_PARS);
FUNCTION get_PARS return SP.TIMAN_PARS pipelined;

-- Функция предоставляет параметры текущего опорного объекта.
-- Запрос:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y
--   from table(SP.IM.get_ROOT);
FUNCTION get_ROOT return SP.TIMAN_PARS pipelined;

-- Функция предоставляет путь к текущему опорному объекту.
FUNCTION get_ROOT_FULL_NAME return VARCHAR2;

-- После удачного завершения выполнения команды G.Cmd_CREATE_OBJECT
-- Клиент передаёт на сервер параметры уточнённые в ходе выполнения команды,
-- после чего выполняет на сервере эту процедуру.
-- Выполнение процедуры завершает транзакцию.
PROCEDURE INSERTED_or_UPDATED;

-- После удачного завершения выполнения команды G.Cmd_UPDATE_NOTES
-- клиент выполняет на сервере процедуру подтвержджающую это.
-- Выполнение процедуры завершает транзакцию.
PROCEDURE NOTES_UPDATED;

-- После удачного завершения выполнения команд G.Cmd_Change_Parent
-- или G.Cmd_Rename
-- клиент выполняет на сервере процедуру подтвержджающую это.
-- Выполнение процедуры завершает транзакцию.
PROCEDURE RENAMED;

-- После удачного завершения выполнения команды G.Cmd_DELETE_OBJECT 
-- клиент выполняет на сервере процедуру подтвержджающую это.
-- Выполнение процедуры завершает транзакцию.
PROCEDURE DELETED;

-- Передача серверу указания на аварийное завершение макропроцедуры.
-- Отладочные и экранные сообщения при этом выдаёт клиент.
-- Выполнение процедуры завершает транзакцию (Происходит откат).
PROCEDURE HALT;

-- После выполнения команд G.Cmd_CANCEL или G.Cmd_Return клиент выдаёт
-- подтверждение завершения макропроцедуры.
-- Выполнение процедуры завершает транзакцию.
PROCEDURE CONFIRM_END;

-- Перезагрузка данных в локальную Модель - макрокоманда RELOAD_MODEL.
--******************************
-- 1. Помечаем все объекты относительно корневого объекта команды
-- как готовые к удалению. Команда заполняет параметр "ID" команды ссылкой на корневой объект модели. Если такой объект находится вне модели, то параметр будет нулл, а если он корень иерархии, то - "1"
PROCEDURE Mark_to_Delete; 

-- 2. Записываем изменённые объекты во внутреннюю модель,
-- снимая отметку об удалении.
-- Функция возвращает null, при удачном завершение или сообщение об ошибке.
-- Функция производит откат, при ошибке.
FUNCTION FLUSH_OBJECTS return VARCHAR2;

-- 3. Удаляем оставшиеся помеченные объекты из внутренней модели.
-- Функция возвращает null, при удачном завершение или сообщение об ошибке.
-- Функция производит откат, при ошибке.
FUNCTION DELETE_MARKED return VARCHAR2;

-- 4. Заменяем объекты символьных ссылок на объекты типа "Rel".
-- Функция возвращает null, при удачном завершение или сообщение об ошибке.
-- Функция НЕ ВЫПОЛНЯЕТ commit в случае успешного завершения операции.
-- Функция НЕ ПРОИЗВОДИТ откат, при ошибке.
-- Это сделано для облегчения отладки связей.

FUNCTION SYM2REL return VARCHAR2;

-- 5. Процедура сообщает об успешном завершении синхронизации.
-- Процедура завершает транзакцию.
-- Если синхронизация завершается с ошибкой, то вместо этой процедуры
-- производим сброс.
PROCEDURE Model_Reloaded;
--******************************

-- Дополнительные функции для работы с локальной моделью.
--****************************************************************************
-- Добавление в массив выбранных объектов "SS" объекта с идентификатором "ID".
PROCEDURE SELECT_OBJECT(ID in VARCHAR2);

-- Очистка массива выбранных объектов.
PROCEDURE CLEAR_SELECTED;

-- Функция предоставляет выбранные объекты во внутренней модели, через запрос:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y,R_ONLY,OBJECT_INDEX
--   from table(SP.IM.get_SELECTED);
FUNCTION get_SELECTED return SP.TIMAN_PARS pipelined;

-- Для переписывания выбранных объектов в массив результа, при выполнении
-- команды GET_SELECTED можно выполнить следующий блок.
-- begin SP.IM.OS:=SP.IM.SS; end;

-- Функция записывает массив OS в массив SYSTEMS текущего пакета.
-- Функция ничего не делает если ни один пакет не запущен.
-- Функция возвращает сообщение об ошибке.
FUNCTION CopyOS2SYSTEMS return VARCHAR2;

-- Процедура записывает массив OS в массив OBJECTS текущего пакета
-- Функция ничего не делает если ни один пакет не запущен.
-- Функция возвращает сообщение об ошибке.
FUNCTION CopyOS2OBJECTS return VARCHAR2;

-- Функция возвращает параметры объекта.
-- Если параметр TINY - false, то будут возврацены все параметры объекта,
-- иначе - лишь параметры, присутствующие в массиве PP.
-- Используется для работы с внутренней моделью.
FUNCTION get_OBJECT return SP.TIMAN_PARS pipelined;

-- Процедура обновляет параметры объекта.
-- Обновляемые параметры и сам объект должены быть определены в массиве PP.
-- Используется для работы с внутренней моделью.
PROCEDURE set_OBJECT;

-- Функция предоставляет объекты модели, полученные в результате выполнения
-- процедур данного пакета Fill_OBJECTS, Fill_FULL_OBJECTS, Fill_SYSTEMS.
-- Для получения объектов необходимо выполнить запрос:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y,R_ONLY,OBJECT_INDEX
--   from table(SP.IM.get_OBJECTS);
FUNCTION get_OBJECTS return SP.TIMAN_PARS pipelined;

-- Процедура заполняет все недостоющие св-ва объекта,
-- находящегося в массиве O.
PROCEDURE Fill_OBJECT(O in out SP.G.TMACRO_PARS,
                      -- Если параметр TINY = true, то заполняются только
                      -- базовые св-ва, а так же параметры присутствующие в
                      -- массиве O.
                      -- Если в массиве O присутствует параметр TINY,
                      -- то он имеет приоретет над входным параметром и
                      -- удален из выходного набора.
                      TINY in BOOLEAN default false);

-- Процедура выбирает все дочерние объекты объекта PP и заполняет их tiny
-- клонами массив OS.
PROCEDURE Fill_OBJECTS;

-- Процедура выбирает все дочерние системы объекта PP и заполняет их tiny
-- клонами массив OS.
PROCEDURE Fill_SYSTEMS;

-- Процедура выбирает все дочерние объекты объекта PP и заполняет ими массив
-- OS.
PROCEDURE Fill_FULL_OBJECTS;

-- Функция возвращает ID объекта, если массив, указанный в параметре 
-- (PP - если параметр отсутствует) содержит объект, существующий в текущей модели.
-- Функция возвращает "0", если объект отсутствует в модели.
-- Если объект существует, то в набор параметров объекта добавляется 
-- параметр "EXISTS" = true, иначе параметр всё равно добавляется,
-- но равным false. 
FUNCTION IS_OBJECT_EXIST(O in out SP.G.TMACRO_PARS) return number;

FUNCTION IS_OBJECT_EXIST return number;

-- Процедура обновляем параметры объекта модели, массив PP определяет объект и
-- новые значения.
-- Процедура используется для выполнения команды SET_PARS на локальной модели.
-- Если возникает ошибка, то записываем её в EM.
PROCEDURE UPDATE_MOD_OBJ_PARS;

-- Процедура выбирает всех потомков объекта PP и заполняет ими массив OS.
PROCEDURE Fill_ALL_FULL_OBJECTS;

-- Процедура выбирает всех потомков объекта PP и заполняет их tiny
-- клонами массив OS.
PROCEDURE Fill_ALL_OBJECTS;

-- Среди всех потомков объекта PP процедура выбирает системы и заполняет их 
--tiny-клонами массив OS.
PROCEDURE Fill_ALL_SYSTEMS;

-- Процедура выбирает всех потомков объекты объекта PP и заполняет их полными
-- клонами массив OS.
PROCEDURE Fill_ALL_FULL_SYSTEMS;


--****************************************************************************
/*
--Implementation pattern
Declare
  v SP.TVALUE;
  cnt Number;
Begin
  SP.IM.PP.Delete;
  --v:=ID_(943496400);
  v:=ID_(947728000);
  SP.IM.PP('ID'):=v;
  SP.IMT.FILL_ALL_OBJECTS;
  
  WITH IDs As
  (
    SELECT DISTINCT OBJECT_INDEX
    FROM TABLE (SP.IM.get_OBJECTS)
  )
  SELECT COUNT(*) Into cnt
  FROM IDs
  ;
  
  DBMS_OUTPUT.Put_Line('Объектов: '||to_char(cnt));
End;
/
Select obs.NAME, obs.T, obs.E, obs.N, obs.D, obs.S, obs.X, obs.Y
    , obs.R_ONLY, obs.OBJECT_INDEX 
From TABLE(SP.IM.get_OBJECTS) obs
Order By obs.OBJECT_INDEX, obs.NAME
;

*/
/*
--Implementation pattern
Declare
  v SP.TVALUE;
  cnt Number;
Begin
  SP.SET_CURMODEL('BRCM||DUMP');
  SP.IM.PP.Delete;
  --v:=ID_(943496400);
  
  V:=S_('/Project_INT_RACEWAY');
  SP.IM.PP('NAME'):=v;

  --v:=ID_(1020442300);
  --SP.IM.PP('ID'):=v;

  SP.IMT.FILL_ALL_FULL_OBJECTS;
--  SP.IMT.FILL_ALL_SYSTEMS;
  
  WITH IDs As
  (
    SELECT DISTINCT OBJECT_INDEX
    FROM TABLE (SP.IM.get_OBJECTS)
  )
  SELECT COUNT(*) Into cnt
  FROM IDs
  ;
  
  DBMS_OUTPUT.Put_Line('Объектов: '||to_char(cnt));
End;


/
Select obs.NAME, obs.T, obs.E, obs.N, obs.D, obs.S, obs.X, obs.Y
    , obs.R_ONLY, obs.OBJECT_INDEX 
From TABLE(SP.IM.get_OBJECTS) obs
Order By obs.OBJECT_INDEX, obs.NAME
;
/



Select Count(*) as cnt
       FROM table(SP.IM.get_OBJECTS) 
;

Select NAME, T, E, SP.TO_.STR(N) As N,
       D, S, SP.TO_.STR(X) As X, SP.TO_.STR(Y) As Y, R_ONLY,
       LPAD(to_char(OBJECT_INDEX),6,'0') As OINDEX 
       FROM table(SP.IM.get_OBJECTS) 
ORDER BY OINDEX, NAME
;

*/

-- СЕРВИСНЫЕ ФУНКЦИИ

--1. Возврат имени значения по идентификатору типа и полям значения.
--  declare
--   EnumValue VARCHAR2(100);
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(ValueType => :ParType,
--           N=>:N, D=>:D, DisN=>:DisN, S=>:S, X=>:X, Y=>:Y);
--       :RESULT:=V.E;
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 51,'',sysdate,0,'RUSSIAN','','', out EnumValue,out em; 
--   o(EnumValue);
--  o('EM = '||EM);
-- end;
--2. Возврат значения параметра в виде строки по идентификатору типа
-- и значениям полей параметра.
-- declare
--   ValS SP.COMMANDS.COMMENTS%type;
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(ValueType => :ParType,
--           N=>:N, D=>:D, DisN=>:DisN, S=>:S, X=>:X, Y=>:Y);
--       :ValS := SP.Val_to_Str(V);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 4,1,sysdate,0,'','','', out ValS,out em;
--   o(ValS);
--  o('EM = '||EM);
-- end;

--3. Возврат всех полей значения по идентификатору типа и значению
-- параметра в виде строки.
-- declare
--   rn VARCHAR2(40);
--   rd DATE;
--   rx VARCHAR2(40);
--   ry VARCHAR2(40);
--   EM SP.COMMANDS.COMMENTS%type;
--   ValS SP.COMMANDS.COMMENTS%type;
--   rs SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(:ParType);
--       SP.Str_to_Val(:ValS,V);
--       :RN:=SP.TO_.STR(V.N);
--       :RD:=V.D;
--       :RS:=V.S;
--       :RX:=SP.TO_.STR(V.X);
--       :RY:=SP.TO_.STR(V.Y);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 2,'09-12-2010',out rn, out rd, out rs ,out rx, out ry, 
--     		out em;
--   o(rd);
--   или для даты
--     using 2,'09-12-2010',out rn, out rd, out rs ,out rx, out ry, 
--     		out em;
--   o(rd);
--   конец или
--  o('EM = '||EM);
-- end; 
--4. Возврат всех полей значения по идентификатору типа и имени значения.
-- declare
--   rn VARCHAR2(40);
--   rd DATE;
--   rs SP.COMMANDS.COMMENTS%type;
--   rx VARCHAR2(40);
--   ry VARCHAR2(40);
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(:ParType,:E_VAL);
--       :RN:=SP.TO_.STR(V.N);
--       :RD:=V.D;
--       :RS:=V.S;
--       :RX:=SP.TO_.STR(V.X);
--       :RY:=SP.TO_.STR(V.Y);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 5,'true',out rn, out rd, out rs, out rx, out ry,out em;
--   o(rn);
--  o('EM = '||EM);
-- end;


-- 5. Запрос набора уникальных строковых значений и комментариев к
-- ним для параметра, определённого типа.
-- select S_VALUE, COMMENTS from table(SP.SET_OF_VALUES(SP.TVALUE(<TypeID>)));
-- где TypeID идентификатор типа параметра.
-- Для встроенных типов TypeID можно определить константой из пакета SP.G.
-- Вместо TypeID можно исползовать "имя" типа.

-- 6. Установка имени модели.
-- declare
-- P SP.TGPAR;
-- begin
--   P:=SP.TGPAR('CurModel');
--   P.VAL.Assign('<Имя модели>');
--   P.Save;
-- end;   

-- 7. Запрос имени узла, расположенного на расстоянии "N" от самого узла
-- по направлению к вершине.
-- NodeName(NodeID in NUMBER, ILevel in NUMBER);
-- NodeID - это поле "N" значения типа TTreeNode.

end IM;
/

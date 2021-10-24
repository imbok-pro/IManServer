CREATE OR REPLACE PACKAGE BODY SP.MACRO
-- Macros execution
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.09.2010
-- update 01.11.2010 10.05.2011 01.11.2011 16.12.2015 21.12.2015 10.02.2016
--        15.02.2016 19.02.2016 22.02.2016-26.02.2016 29.02.2016 03.03.2016
--        08.03.2016 10.03.2016 11.03.2016 15.03.2016 02.11.2017 07.11.2017
--        12.02.2018
AS

-- Массив потоков выполнения. 
-- Одновременно можно выполнять несколько макропроцедур, каждую в своём потоке.
Macros TMacros;

/* Тип THREADS.EXEC
TYPE TState is RECORD (
 State NUMBER,           --  0 поток свободен и готов
                         --  1 поток занят 
												 --  2 поток свободен, но таблица ещё не принята
                         --     (необходимо несколько раз опросить состояние,
												 --      уменьшить разницу PipeBUF и BufSize)
                         -- -1 поток ждет очереди на запуск
                         -- -2 поток не запущен
												 -- -3 возникла ошибка при выполнении потока
												 -- -4 завершён
 PrBar NUMBER,					 -- % выполнения			 
 Moment DATE,            -- время присвоения значения
 Mess VARCHAR2(256),     -- произвольное сообщение
 ERR VARCHAR2(3000)      -- сообщение об ошибке Оракла, возникшей в потоке
 );
 
 Перечень всех состояний
G.MS_NotDef, G.MS_Starting, G.MS_Waiting,
G.MS_Ready, G.MS_Warning, 
G.MS_Working, G.MS_Stepping, G.MS_Paused,
G.MS_Error, G.MS_Closing,
G.MS_WaitingUser, G.MS_WaitingSelection, G.MS_ClearSelected, G.MS_MustBeep
 
*/

-------------------------------------------------------------------------------
procedure setState(ThreadID in NUMBER, State in VARCHAR2) 
is
begin
  Macros(ThreadID).oldState := Macros(ThreadID).State;
  Macros(ThreadID).State := State;
exception
  when no_data_found then
    raise_application_error(-20033,
      'SP.MACRO.LogError. Обращение к несуществующему потоку '
      ||to_.str(nvl(ThreadID, null))||' !');
end setState;

-- Добавляем в таблицу лога и таблицу ошибок сообщение об ошибке.
-------------------------------------------------------------------------------
procedure LogError(ThreadID in NUMBER, EM in VARCHAR2,
                   setErrorState in BOOLEAN Default true) 
is
begin
  if not Macros.exists(ThreadID) then 
    raise_application_error(-20033,
      'SP.MACRO.LogError. Обращение к несуществующему потоку '
      ||to_.str(nvl(ThreadID, null))||' !');
  end if;
  d(EM,'ERROR in MACRO');
  insert into sp.M_Log (THID, TIME, TEXT)
    values (ThreadID, sysdate, 'ERROR:'||to_.str||EM); 
  insert into sp.M_Errors_and_Warnings (THID, TIME, TEXT, Err_or_Warn)
    values (ThreadID, sysdate, EM, 'ERROR');
  if setErrorState then  
    setState(ThreadID, G.MS_Error);
  end if;
end LogError;

-- Добавляем в таблицу лога и таблицу ошибок сообщение о предупреждении.
-------------------------------------------------------------------------------
procedure LogWarning(ThreadID in NUMBER default 1, WM in VARCHAR2) 
is
begin
  if not Macros.exists(ThreadID) then 
    raise_application_error(-20033,
      'SP.MACRO.LogWarning. Обращение к несуществующему потоку '
      ||to_.str(nvl(ThreadID, null))||' !');
  end if;
  d(WM,'WARNING in MACRO');
  insert into sp.M_Log (THID, TIME, TEXT)
    values (ThreadID, sysdate, 'WARNING:'||to_.str||WM); 
  insert into sp.M_Errors_and_Warnings (THID, TIME, TEXT)
    values (ThreadID, sysdate, WM); 
end LogWarning;


-- функция опроса состояния потока. 
-- Используется при ожидании состояния потока (WaitThread) 
-- или при возврате состояния потока (getThread).
-------------------------------------------------------------------------------
function getThreadState(ThreadID in NUMBER default 1,
                        WaitReady in BOOLEAN) return VARCHAR2
is
s THREADS.EXEC.TState;
n PLS_INTEGER;
tmpVar PLS_INTEGER;
newState VARCHAR2(128);
begin
-- Если поток не определён, то так и возвращаем.
if not Macros.exists(ThreadID) then
  Macros(ThreadID).State := G.MS_NotDef;
  Macros(ThreadID).OldState := G.MS_NotDef;
end if;
-- Производим опрос состояния потока.
  n := 0;
<<GET_STATE>>
  n:= n+1;
  -- Если не превысили, то обрабатываем:
  if n < WStateLimit then 
    s:=THREADS.EXEC.isReady(ThreadID);
    d('Приняли состояние '||s.State||' с сообщением '||nvl(s.Mess,'null'),
      'SP.MACRO.getState');
    case s.State
      -- Поток готов, состояние потока передано в сообщении.
      when  0 then
        NewState:=s.Mess;
        -- Если это первое принятое состояние после запуска потока,
        if NewState = THREADS.Exec.StateWaiting then
          -- то настраиваем сессию потока.
          -- В режиме отладки, передаём переменные, но не настраиваем сессию.
          tmpVar :=THREADS.Exec.Proc
          (
            ThreadID => ThreadID,
            ExecStr =>' SP.Macro_I.ThID := '||ThreadID||';'||
                      ' SP.Macro_I.CurMacro := '||Macros(ThreadID).ID||';'||
                      ' if not THREADS.isDebug then '||
                      '   SP.setSession('''||SP.TG.UserName||''');'||
                      ' end if;'||
                      ' SP.Macro_I.SetState('''||G.MS_READY||''');',
            IniPrBar => 0,
            IniMess => G.MS_Ready
          );
          if tmpVar != ThreadID then
            LogError(ThreadID,
              'Непредвиденная ошибка при установке идентификаторов в потоке!');
          end if;
          -- Предоставляем время потоку подготовить сессию.
          DBMS_LOCK.SLEEP(1);
          -- Устанавливаем состояние старта.
          NewState := G.MS_Starting;
          goto GET_STATE;
        end if;
        -- Если вновь принятое состояние указывает на ошибки или предупреждения,
        -- а поток работоспособен,
        -- то принимаем таблицу ошибок и предупреждений.
        if    (NewState in (G.MS_Error, G.MS_Warning)) 
          and (Macros(ThreadID).State != NewState)
        then
          setState(ThreadID, NewState); 
          tmpVar :=THREADS.Exec.Proc
          (
            ThreadID => ThreadID,
            ExecStr =>' SP.Macro_I.setState(SP.Macro_I.MacroState);', 
            TableName =>'SP.M_ERRORS_AND_WARNINGS',
            IniPrBar => 0,
            IniMess =>NewState
          );
          if tmpVar != ThreadID then
            LogError(ThreadID,
              'Непредвиденная ошибка при приеме таблицы ошибок!');
          else    
            -- Предоставляем время потоку подготовить сессию.
            DBMS_LOCK.SLEEP(1);
            -- Повторяем приём состояния.
            goto GET_STATE;
          end if;
        end if;  
        --Если принятое состояние не из набора допустимых состояний потока,
        if NewState not in 
        (
         G.MS_NotDef, G.MS_Starting, G.MS_Waiting, G.MS_Ready, G.MS_Warning,
         G.MS_Working, G.MS_Stepping, G.MS_Paused, G.MS_Error, G.MS_Closing,
         G.MS_WaitingUser, G.MS_WaitingSelection, G.MS_ClearSelected,
         G.MS_MustBeep  
        ) 
        then
          -- то восстанавливаем состояние потока в потоке из переменной пакета.
          tmpVar := THREADS.Exec.Proc
          (
            ThreadID => ThreadID,
            ExecStr =>' SP.Macro_I.setState(SP.Macro_I.MacroState);',
            IniPrBar => 0,
            IniMess => Macros(ThreadID).State
          );
          -- Если ошибка, то принимаем устанавливаем состояние ошибки.
          if tmpVar != THreadID then
            LogError(ThreadID,
              'Ошибка восстановления состояния потока из состояния,'||NewState
              ||' !');
          else
            -- Иначе. Предоставляем время потоку подготовить сессию.
            DBMS_LOCK.SLEEP(1);
            -- Повторяем приём состояния.
            goto GET_STATE;
          end if;  
        end if;
      when  1 then
        -- Поток работает - состояние неизменно.
        -- Если выполняется синхронная операция, то необходимо
        -- необходимо дождаться готовности.
        if WaitReady then
          DBMS_LOCK.SLEEP(1);
          goto GET_STATE;
        end if;
      when  2 then
        -- Таблица не принята, продолжаем приём таблицы.
        DBMS_LOCK.SLEEP(1);
        goto GET_STATE;
      when -1 then
        NewState := G.MS_Starting;
      when -2 then
        NewState := G.MS_NotDef;
      when -3 then
        -- Получили ошибку, не перехваченную в пакете macros.
        -- Пишем её в протокол.
        LogError(ThreadID,
        'Неперехваченная ошибка '||s.Err||' !');
      when -4 then
        NewState := G.MS_Closing;
    end case; 
  else 
    NewState := G.MS_Waiting;
    -- Записываем неудачу как предупреждение.
    LogWarning(ThreadID,
      'Не смогли принять таблицу или восстановить состояние за '||WStateLimit||
      ' попыток!');
  end if;
  if Macros(ThreadID).State not in (NewState, G.MS_Error) then
    setState(ThreadID, NewState);
  end if;
  return Macros(ThreadID).State;
end getThreadState;

-- Все синхронные процедуры используют данную функцию для ожидания завершения 
-- выполнения очередной операции потоком.
-- Функцию необходимо вызвать, если мы хотим выполнить несколько операций с
-- потоком подряд. Функция возвращает false, если возникла ошибка. 
-------------------------------------------------------------------------------
function WaitThread(ThreadID in NUMBER default 1) return BOOLEAN
is
s VARCHAR2(128);
tmpVar PLS_INTEGER;
begin
  s := getThreadState(ThreadID => ThreadID, WaitReady  => true); 
  -- Если не дождались потока то возвращаем false.
  return S not in (G.MS_Error, G.MS_Waiting);
end WaitThread;    

-------------------------------------------------------------------------------
procedure forceLog(ThreadID in NUMBER default 1)
is
newState VARCHAR2(128);
begin
  newState := getState(ThreadID);
  -- Если макропроцедура выполняется,
  if newState = G.MS_Working then
    -- то посылаем сигнал приостановки.
    if THREADS.EXEC.SETSIGNAL(ThreadID, 'forceLog') != 0 then
        LogError(ThreadID,
        'Не смогли передать сигнал потоку '||ThreadID||' !');
        return;
    end if;
    -- В цикле опрашиваем состояние.
    -- Если не удалось принять лог за WStateLimit попыток,
    if  not WaitThread(ThreadID) then
      -- Записываем неудачу как предупреждение.
      LogWarning(ThreadID,
        'Не смогли приостановить поток за '||WStateLimit||' попыток!');
      return;
    end if;
    -- Если дождались, то передаём команду на продолжение выполнения.
    --!! Проверить, что лог принят!!!
    ContinueMacro(false,ThreadID);
  end if;
end forceLog;

-------------------------------------------------------------------------------
function getLog(ThreadID in NUMBER default 1,
                forced in boolean default false) 
return CLOB
is
result CLOB;
s VARCHAR2(4000);
begin
  -- Eсли поток работает и установлен флаг forced, то выполняем forceLog.
  if (getState(ThreadID) = G.MS_Working) and forced then
    forceLog(ThreadID);
  end if;
  -- Передаём содержимое как CLOB.
  DBMS_LOB.createtemporary(result,true,12);
  for r in (select TIME, TEXT from SP.M_LOG 
              where ThID = ThreadID 
              order by "LINE")
  loop 
    s:= to_.str(r.TIME)||'  '||r.TEXT;           
    DBMS_LOB.WRITEAPPEND (result,length(s),s);
  end loop;
  return result;
end getLog;

-------------------------------------------------------------------------------
function getErrorsAndWarnings(ThreadID in NUMBER default 1) return CLOB
is
result CLOB;
s VARCHAR2(4000);
begin
  -- Передаём содержимое таблицы как CLOB.
  DBMS_LOB.createtemporary(result,true,12);
  for r in (select TIME, TEXT from SP.M_ERRORS_AND_WARNINGS 
              where ThID = ThreadID 
              order by "LINE")
  loop 
    s:= to_.str(r.TIME)||'  '||r.TEXT;           
    DBMS_LOB.WRITEAPPEND (result,length(s),s);
  end loop;
  return result;
end getErrorsAndWarnings;

-------------------------------------------------------------------------------
procedure clearErrors(ThreadID in NUMBER default 1)
is
begin
  delete from SP.M_ERRORS_AND_WARNINGS where ThID = ThreadID;
end clearErrors;

-------------------------------------------------------------------------------
function getState(ThreadID in NUMBER default 1) return VARCHAR2
is
s THREADS.EXEC.TState;
n PLS_INTEGER;
tmpVar PLS_INTEGER;
newState VARCHAR2(128);
begin
--! ВОЗМОЖНО! Необходимо измерять время между запросами состояния.
--! Пауза между запросами состояния может определяться глобальным параметром.
--! При повторном запросе возможно нужно засыпать на время,
--! определённое глобальным параметром.
-------
-- Если поток не определён, то так и возвращаем.
if not Macros.exists(ThreadID) then
  Macros(ThreadID).State := G.MS_NotDef;
  Macros(ThreadID).OldState := G.MS_NotDef;
end if;
  -- Производим опрос состояния потока, только в том случае,
  -- если он находится в состоянии ожидания старта или завершения выполнения
  -- очередной асинхронной операции.
  if Macros(ThreadID).State in
  (
   G.MS_NotDef, 
   --G.MS_Starting, G.MS_Waiting, 
   G.MS_Ready, G.MS_Warning,
   --G.MS_Working, G.MS_Stepping, 
   G.MS_Paused, G.MS_Error, G.MS_Closing,
   G.MS_WaitingUser, G.MS_WaitingSelection, G.MS_ClearSelected, G.MS_MustBeep 
  )  
  then
    return Macros(ThreadID).State;
  else  
    return getThreadState(ThreadID => ThreadID, WaitReady => false);
  end if;
end getState;

-- Общая часть алгоритма запуска макропроцедуры.
-------------------------------------------------------------------------------
function ExecMacro(MacroName in VARCHAR2, MacroID in NUMBER, ThreadID in NUMBER)
return NUMBER
is
em VARCHAR2(4000);
tID PLS_INTEGER;
begin
  -- Если поток равен нулл, то создаём новый.
  if ThreadID is null then
    tID := THREADS.EXEC.StartNewThread;
  else  
    tID := ThreadID;
    -- Если поток существует.
    if Macros.exists(tID) then
      ResetMacro(tID);    
    end if;
    -- Cоздаем или перезапускаем поток. 
    tID := THREADS.EXEC.StartNewThread(tID);
  end if;
  if tID = -1 then
    raise_application_error(-20033,
      'SP.MACRO.ExecMacro. Очередь к потокам переполнена!');
  end if;
  -- Изменяем состояние потока на исходное.
  Macros(tID).OldState := G.MS_NotDef;
  Macros(tID).State := G.MS_Starting;
  -- Очищаем протокол, но не ошибки.
  delete from SP.M_LOG where ThID = tID;
  -- Заполняем таблицу параметров в текущей сессии.
  em := SP.IM.Set_Pars(MacroID);
  if em is not null then
    -- Устанавливаем состояние ошибки. 
    LogError(tID,
      'Ошибка ExecMacro '||em||'!');
  end if;
  -- Заполняем имя макропроцедуры и её идентификатор в массиве потоков.
  -- В потоке идентификатор заполнится при опросе состояния.
  Macros(tID).NAME := MacroName;
  Macros(tID).ID := MacroID;
  return tID;
end ExecMacro;

-------------------------------------------------------------------------------
function ExecMacro(MacroName in VARCHAR2, ThreadID in NUMBER default 1) 
return NUMBER
is
tmpVar NUMBER;
begin
  select ID into tmpVar from SP.V_OBJECTS where FULL_NAME = MacroName;
  return ExecMacro(MacroName, tmpVar, ThreadID);
exception
  when no_data_found then
    if Macros.exists(ThreadID) then
      LogError(ThreadID,
        'Отсутствует макропроцедура '||nvl(MacroName,'null')||'!', false);
      Macros(ThreadID).oldState := G.MS_Error;
      Macros(ThreadID).State := G.MS_Error;
      return ThreadID;
    else
      raise_application_error(-20033,
        'Отсутствует макропроцедура '||nvl(MacroName,'null')||'!');
    end if;
end ExecMacro;

-------------------------------------------------------------------------------
function ExecMacro(MacroID in NUMBER, ThreadID in NUMBER default 1)
return NUMBER
is
tmpVar VARCHAR2(4000);
begin
  select FULL_NAME into tmpVar from SP.V_OBJECTS where ID = MacroID;
  return ExecMacro(tmpVar, MacroID, ThreadID);
exception
  when no_data_found then
    if Macros.exists(ThreadID) then
      LogError(ThreadID,
        'Отсутствует макропроцедура '||nvl(MacroID,null)||'!', false);
      Macros(ThreadID).oldState := G.MS_Error;
      Macros(ThreadID).State := G.MS_Error;
      return ThreadID;
    else
      raise_application_error(-20033,
        'Отсутствует макропроцедура '||nvl(MacroID,null)||'!');
    end if;
end ExecMacro;

-------------------------------------------------------------------------------
procedure setRoot(root in SP.G.TMACRO_PARS, ThreadID in NUMBER default 1) 
is
tmpVar PLS_INTEGER;
tmpRoot SP.G.TMACRO_PARS;
s VARCHAR2(128);
begin
  -- Если состояние потока позволяет, то устанавливаем его опорный объект.
  s := getState(ThreadID);
  if s in
  ( 
    G.MS_Ready, G.MS_Warning
    --G.MS_Paused, G.MS_WaitingUser
  )
  then
    -- Проверяем наличие опорного объекта.
    tmpRoot := root;
    tmpVar := SP.IM.IS_OBJECT_EXIST(tmpRoot);
    if  tmpVar < 1 then
      LogError(ThreadID,
      'Не удалось установить опорный объект. '||
      'Отсутствует объект '||to_.str(root)||'!');
      return;
    end if;
    -- Устанавливаем опорный объект в массиве.
    Macros(ThreadID).Root := root;
    -- Устанавливаем опорный объект в потоке.
    tmpVar := THREADS.Exec.Proc
    (
      ThreadID => ThreadID,
      ExecStr =>' SP.Macro_I.setRoot('||Macros(ThreadID).ID||');',
      IniPrBar => 0,
      IniMess =>s
    );
    if tmpVar != ThreadID then
      LogError(ThreadID,
      'Не удалось установить опорный объект. '||
      'Функция THREADS.Exec.Proc вернула: '||tmpVar||'!');
    end if;
    if not WaitThread(ThreadID) then
      LogError(ThreadID,
      'Не удалось восстановить состояние после установки опорного объекта!');
    end if;
  else
    -- Если поток не готов, то переводим поток в состояние ошибки.
    LogError(ThreadID,
      'Состояние потока '||s||'не позволяет установить опорный объект!');
  end if;
end setRoot;

-------------------------------------------------------------------------------
procedure setPars(ThreadID in NUMBER default 1)
is
tmpVar PLS_INTEGER;
begin
  -- Если поток готов, то передаём таблицу параметров,
  if Macros(ThreadID).State in
  ( 
   G.MS_Ready, G.MS_Warning,
   G.MS_Paused, G.MS_WaitingUser
  )
  then
    tmpVar := THREADS.Exec.SetTable(ThreadID, 'SP.WORK_COMMAND_PAR_S');
    if tmpVar !=0 then
      LogError(ThreadID,
      'Не удалось передать таблицу параметров. '||
      'Функция THREADS.Exec.SetTable вернула: '||tmpVar||'!');
    end if;
    -- Дожидаемся исполнения.
    if not WaitThread(ThreadID) then
      LogError(ThreadID,
      'Не удалось восстановить состояние после передачи таблицы параметров!');
    end if;
  else
    -- иначе возбуждаем ошибку.
    LogError(ThreadID,
      'Состояние потока '||Macros(ThreadID).State||
      '. Поток не готов для установки параметров !');
  end if;
end setPars;

-------------------------------------------------------------------------------
procedure ContinueMacro(byStep in BOOLEAN default false,
                        ThreadID in NUMBER default 1)
is
s VARCHAR2(128);
nextState VARCHAR2(128); 
tmpVar PLS_INTEGER;
begin
  s:= getState(ThreadID);
  nextState := case when byStep then G.MS_Stepping else G.MS_Working end;
  -- Если не инициализована макропроцедура, то ошибка.
  if s in ( G.MS_READY, G.MS_WARNING) and Macros(ThreadID).ID is null  then
    LogError(ThreadID,
      'Необходимо определить выполняемую макропроцедуру !');
    return;  
  end if;
  case    
    when  s in
    ( 
      G.MS_READY, G.MS_WARNING,
      G.MS_Paused, G.MS_WaitingUser, G.MS_WaitingSelection,
      G.MS_ClearSelected, G.MS_MustBeep
    ) 
    then 
      -- Продолжаем выполнение, если поток в режиме ожидания.
      tmpVar := THREADS.Exec.Proc
      (
        ThreadID => ThreadID,
        ExecStr => case 
                     when byStep then' SP.Macro_I.ContinueMacro(''byStep'');'
                   else 
                     ' SP.Macro_I.ContinueMacro();'
                   end,
        TableName =>'SP.M_LOG',
        IniPrBar => 0,
        IniMess =>nextState 
      );
      if tmpVar < 0 then
        LogError(ThreadID,
          'Не удалось продолжить выполнение, код возврата THREADS.Exec.Proc '||
           tmpVar||' !');
      else
        setState(ThreadID, nextState);     
      end if;
  else
    -- Иначе возбуждаем ошибку.
    LogError(ThreadID,
      'Состояние потока '||Macros(ThreadID).State||
      ' не позволяет приступить или продолжить выполнение макропроцедуры !');
    return;  
  end case;
end ContinueMacro;

-------------------------------------------------------------------------------
procedure PauseMacro(ThreadID in NUMBER default 1)
is
tmpVar PLS_INTEGER;
begin
  -- Проверяем состояние.
  -- Если поток выполняется, то посылаем ему сигнал приостановки.
  if getState(ThreadID) = G.MS_Working then
    tmpVar := THREADS.EXEC.setSignal(ThreadID, 'PAUSE');
    if tmpVar != 0 then
      LogError(ThreadID,
        'Не удалось передать сигнал, код возврата THREADS.Exec.setSignal '
        ||tmpVar||' !');
    end if;
    --! Возможно - дождаться остановки потока?
  end if;
end PauseMacro;

-------------------------------------------------------------------------------
procedure setSelected(SELECTED SP.G.TOBJECTS, ThreadID in NUMBER default 1)
is
i BINARY_INTEGER;
a ThArrs.TNums;
tmpVar PLS_INTEGER;
s VARCHAR2(128);
begin
  -- Проверяем состояние макропроцедуры.
  s:= getState(ThreadID);
  if s not in 
  ( 
     G.MS_Ready, G.MS_Warning,
     G.MS_Paused, 
     G.MS_WaitingUser, G.MS_WaitingSelection  
  ) 
  then
    LogError(ThreadID,
      'Состояние потока '||s||
      ' не позволяет передать в поток макропроцедуры выбранные объекты!');
    return;
  end if;    
  -- Заполняем массив идентификаторов.
  i := SELECTED.first;
  while i is not null 
  loop
    a(i) := SELECTED(i)('ID').N;
    i := SELECTED.next(i);
  end loop; 
  -- Передаём массив идентификаторов объектов.
  tmpVar := THREADS.Exec.setArr(ThreadID => ThreadID,
                                ArrName => 'ID',
                                Arr => a);
  if tmpVar != 0 then
    LogError(ThreadID,
      'Не удалось передать массив, код возврата THREADS.Exec.setArr '
      ||tmpVar||' !');
  end if;
  if not WaitThread(ThreadID) then
    LogError(ThreadID,
      'Не удалось восстановить состояние после передачи массива SELECTED!');
  end if;
  -- Устанавливаем выбранные объекты из массива.
  tmpVar :=THREADS.EXEC.Proc(ThreadID => ThreadID,
                             ExecStr =>'SP.Macro_I.setSelected;',
							               IniPrBar => 0,
							               IniMess => Macros(ThreadID).State);
  if tmpVar != ThreadID then
    LogError(ThreadID,
      'Не удалось установить SELECTED, код возврата THREADS.Exec.Proc '
      ||tmpVar||' !');
  end if;
  if not WaitThread(ThreadID) then
    LogError(ThreadID,
      'Не удалось восстановить состояние после установки SELECTED!');
  end if;
exception
  -- Если у объекта отсутствует идентификатор, возбуждаем ошибку.
  when no_data_found then 
    LogError(ThreadID,
      'Элемент '||i||' выбранных объектов не содержит параметр "ID" ');
end setSelected;

-------------------------------------------------------------------------------
procedure getPars(ThreadID in NUMBER default 1)
is
newState VARCHAR2(128);
tmpVar PLS_INTEGER;
s VARCHAR2(128);
begin
  -- Проверяем состояние макропроцедуры.
  s:= getState(ThreadID);
  if s not in 
  ( 
     G.MS_Ready, G.MS_Warning,
     G.MS_Paused, 
     G.MS_WaitingUser, G.MS_WaitingSelection,
     G.MS_MustBeep  
  ) 
  then
    LogError(ThreadID,
      'Состояние потока '||s||
      ' не позволяет передать в основной поток таблицу параметров!');
    return;
  end if; 
  execute immediate('truncate table SP.WORK_COMMAND_PAR_S');   
  -- Передаём таблицу параметров из сессии потока в сессию пользователя.
  tmpVar := THREADS.Exec.Func
  (
    ThreadID => ThreadID,
    ExecStr =>' SP.Macro_I.getPars()',
    TableName =>'SP.WORK_COMMAND_PAR_S',
    IniPrBar => 0,
    IniMess =>Macros(ThreadID).State
  );
  if tmpVar < 0 then
    LogError(ThreadID,
      'Не удалось передать таблицу параметров, код возврата THREADS.Exec.Func '
      ||tmpVar||' !');
  end if;
  -- Ожидаем завершения операции.
  if not WaitThread(ThreadID) then
    LogError(ThreadID,
      'Не удалось восстановить состояние после передачи таблицы параметров!');
  end if;
end getPars;

-------------------------------------------------------------------------------
procedure getRoot(ThreadID in NUMBER default 1)
is
newState VARCHAR2(128);
tmpVar PLS_INTEGER;
s VARCHAR2(128);
begin
  -- Проверяем состояние макропроцедуры.
  s:= getState(ThreadID);
  if s not in 
  ( 
     G.MS_Ready, G.MS_Warning,
     G.MS_Paused, 
     G.MS_WaitingUser, G.MS_WaitingSelection,
     G.MS_MustBeep  
  ) 
  then
    LogError(ThreadID,
      'Состояние потока '||s||
      ' не позволяет передать в основной поток опорный объект!');
    return;
  end if; 
  execute immediate('truncate table SP.WORK_OBJECTS_PAR_S');   
  -- Передаём таблицу параметров из сессии потока в сессию пользователя.
  tmpVar := THREADS.Exec.Func
  (
    ThreadID => ThreadID,
    ExecStr =>' SP.Macro_I.getRoot()',
    TableName =>'SP.WORK_OBJECTS_PAR_S',
    IniPrBar => 0,
    IniMess =>Macros(ThreadID).State
  );
  if tmpVar < 0 then
    LogError(ThreadID,
      'Не удалось передать опорный объект, код возврата THREADS.Exec.Func '
      ||tmpVar||' !');
  end if;
  -- Ожидаем завершения операции.
  if not WaitThread(ThreadID) then
    LogError(ThreadID,
      'Не удалось восстановить состояние после передачи опорного объекта!');
  end if;
end getRoot;

-------------------------------------------------------------------------------
procedure ResetMacro(ThreadID in NUMBER default 1)
is
begin
  ExitThread(ThreadID);
  -- Сбрасываем поля массива текущего потока.
  Macros(ThreadID).OldState := G.MS_NotDef;
  Macros(ThreadID).State := G.MS_NotDef;
  Macros(ThreadID).Name := '';
  Macros(ThreadID).ID := null;
  Macros(ThreadID).Root.delete;
  -- Удаляем протокол, но не ошибки.
  delete from SP.M_Log where ThID = ThreadID;
end ResetMacro;

-------------------------------------------------------------------------------
procedure ExitThread(ThreadID in NUMBER default 1)
is
s THREADS.EXEC.TState;
n PLS_INTEGER;
begin
  -- Если поток не существует, то создаём и выход.
  if not Macros.exists(ThreadID) then
    Macros(ThreadID).State := G.MS_NotDef;
    Macros(ThreadID).OldState := G.MS_NotDef;
    Macros(ThreadID).Name := '';
    Macros(ThreadID).ID := null;
    Macros(ThreadID).Root := SP.M.ROOT;
    return;
  end if;  
  -- Если поток закрыт, то выход.
  if Macros(ThreadID).State = G.MS_Closing then return; end if;
  -- В режиме отладки сбрасываем пакет IM.
  if THREADS.EXEC.GET_THREAD(ThreadID).FlagDebug then 
    SP.IM.HALT;
  end if;
  -- Закрываем поток.
  Macros(ThreadID).OldState := Macros(ThreadID).State;
  Macros(ThreadID).State := G.MS_Closing;
  Macros(ThreadID).Name := '';
  Macros(ThreadID).ID := null;
  Macros(ThreadID).Root := SP.M.ROOT;
  s:=THREADS.EXEC.isReady(ThreadID);
  case 
    when  s.State = 0 then
      -- Поток готов, передаём команду на завершение.
      n := THREADS.EXEC.STOPTHREAD(ThreadID);
    when  s.State in (1,2,-3) then
      -- Поток работает сбрасываем сессию.
      n := THREADS.EXEC.KILLTHREAD(ThreadID);
  else
    null;
  end case; 
end ExitThread;

-------------------------------------------------------------------------------
BEGIN
Macros(1).State := G.MS_NotDef;
Macros(1).OldState := G.MS_NotDef;
Macros(1).Name := '';
Macros(1).ID := null;
Macros(1).Root := SP.M.ROOT;
THREADS.EXEC.STARTTUBE:=G.DaemonPipe;
END Macro;
/
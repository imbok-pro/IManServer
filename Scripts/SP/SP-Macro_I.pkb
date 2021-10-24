CREATE OR REPLACE PACKAGE BODY SP.MACRO_I
-- Macros execution
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.09.2010
-- update 01.11.2010 10.05.2011 01.11.2011 16.12.2015 21.12.2015 10.02.2016
--        11.02.2016 22.02.2016 26.02.2016 29.02.2016 03.03.2016 08.03.2016
--        11.03.2016 02.11.2017 22.10.2020
AS

-- Сообщение об ошибке.
EM VARCHAR2(4000);

-- Предупреждение.
WM VARCHAR2(4000);

-- Добавляем в таблицу лога и таблицу ошибок сообщение об ошибке.
-------------------------------------------------------------------------------
procedure LogMessages 
is 
PRAGMA autonomous_transaction;
i PLS_INTEGER;
dt DATE;
begin
  dt := sysdate;
  i := SP.IM.MESSAGES.first;
  while i is not null
  loop
    insert into SP.M_Log(THID, TIME, TEXT) 
      values (ThID, dt, SP.IM.MESSAGES(i)); 
    i := SP.IM.MESSAGES.next(i);
  end loop;
  -- Очищаем массив сообщений.
  SP.IM.MESSAGES.delete;
  commit;  
end LogMessages;

-- Добавляем в таблицу лога и таблицу ошибок сообщение об ошибке.
-------------------------------------------------------------------------------
procedure LogErrorMessage 
is 
PRAGMA autonomous_transaction;
begin
  insert into SP.M_Log (THID, TIME, TEXT)
    values (ThID, sysdate, 'ERROR:'||to_.str||EM); 
  insert into SP.M_Errors_and_Warnings (THID, TIME, TEXT, Err_or_Warn)
    values (ThID, sysdate, EM, 'ERROR');
  commit;  
end LogErrorMessage;


-- Добавляем в таблицу лога и таблицу ошибок сообщение об ошибке.
-------------------------------------------------------------------------------
procedure LogError(setErrorState in BOOLEAN Default true) 
is 
begin
  LogErrorMessage;
  if setErrorState then  
    setState(G.MS_Error);
  end if;
end LogError;

-- Добавляем в таблицу лога и таблицу ошибок сообщение о предупреждении.
-------------------------------------------------------------------------------
procedure LogWarning 
is
PRAGMA autonomous_transaction;
begin
  insert into SP.M_Log (THID, TIME, TEXT)
    values (ThID, sysdate, 'WARNING:'||to_.str||WM); 
  insert into SP.M_Errors_and_Warnings (THID, TIME, TEXT)
    values (ThID, sysdate, WM);
  WM := ''; 
  commit;  
end LogWarning;

-- При возникновении ошибки на сервере необходимо установить ошибку выполнения
-- макропроцедуры и прекратить её выполнение,
-- ошибку процедуры записать в лог.
-------------------------------------------------------------------------------
function checkEM return BOOLEAN
is
begin
  -- Если сообщение об ошибке уже заполнено, переходим в состояние ошибки.
  if EM is not null then return true; end if;
  -- Опрашиваем сообщение об ошибке.
  EM:=SP.IM.get_EM;
  -- Протоколируем ошибку и устанавливаем состояние ошибки.
  if EM is not null then logError; end if;
  return (EM is not null);
end;

-------------------------------------------------------------------------------
-- При возникновении предупреждений мы устанавливаем соответствующее состояние
-- после выполнения макропроцедуры.
-- Суть предупреждения добавляем в таблицу предупреждений.
procedure checkWM
is
begin
  WM:=SP.IM.get_WM;
  if WM is not null then
    logWarning;
  end if;
end;

-- Процедура добавляет в Лог содержимое массива SP.IM.PP
-------------------------------------------------------------------------------
procedure logPP
as
PRAGMA autonomous_transaction;
i SP.OBJECT_PAR_S.NAME%type;
s VARCHAR2(4000);
dt DATE;
begin
  i := SP.IM.PP.first;
  dt := sysdate; 
  while i is not null
  loop
    s := i || ' => '|| SP.VAL_TO_STR(SP.IM.PP(i));
    insert into sp.M_Log (THID, TIME, TEXT) values (ThID, dt, s); 
    i := SP.IM.PP.next(i);
  end loop;
  commit;
end logPP;

-- Процедура добавляет в Лог значение параметра "NAME" массива SP.IM.PP.
-------------------------------------------------------------------------------
procedure logPP(Name in VARCHAR2)
as
PRAGMA autonomous_transaction;
s VARCHAR2(4000);
dt DATE;
begin
  dt := sysdate; 
  if SP.IM.PP.exists(Name) then
    s := Name || ' => '|| SP.VAL_TO_STR(SP.IM.PP(Name));
  else
    s := Name || ' => absent!!!';
  end if;  
  insert into sp.M_Log (THID, TIME, TEXT) values (ThID, dt, s);
  commit; 
end logPP;

-- Процедура добавляет в Лог строку.
-------------------------------------------------------------------------------
procedure logS(s in VARCHAR2)
as
PRAGMA autonomous_transaction;
dt DATE;
begin
  dt := sysdate; 
  insert into sp.M_Log (THID, TIME, TEXT) values (ThID, dt, s);
  commit; 
end logS;

-- Взаимодействие с моделью
/*************************************************************************/
-- Команда подачи звукового сигнала. 
-- На входе два параметра "NAME" - имя мелодии (строка)
-- и "REPETITIONS" - количество повторов (Integer). Имена мелодии должны 
-- быть из списка {"BEEP", "ASTERISK", "EXCLAMATION", "HAND, "QUESTION"}.
-- Если имя мелодии будет не из списка, или вообще будет отсутсвовать, то 
-- воспроизводиться будет мелодия по умолчанию ("EXCLAMATION"). 
-- Если будет отсутсвовать параметр количество повторов, то мелодия будет
-- проиграна один раз.
-- Заполняем состояние, приостанавливаем выполнение? чтобы можно было бибикнуть
-------------------------------------------------------------------------------
procedure CmdPlay
is
begin
  -- Посылаем состояние бибикнуть.
  setState(G.MS_MustBeep);
end CmdPlay; 
 
-- Команда получает опорный объект из БД и изменяетет его в моделе.
-------------------------------------------------------------------------------
procedure CmdSetRoot
is
tmpVar BOOLEAN;
begin
  SP.IM.OS(1) := SP.IM.PP;
  SP.IM.SET_ROOT;
  tmpVar := checkEM;
end CmdSetRoot;

-- Команда завершает транзакцию.
-------------------------------------------------------------------------------
procedure CmdCommit
is
begin
  commit;
end CmdCommit;  

-- Команда выполняет откат транзакции.
-------------------------------------------------------------------------------
procedure CmdRollback
is
begin
  rollback;
end CmdRollback;  

-- Команда выполняет обновление модели.
-------------------------------------------------------------------------------
procedure CmdRefresh
is
begin
  -- На локальной модели ничего не делает.
  null;
end CmdRefresh;  

-- Команда выполняет очистку кэша SP3D Iman. 
-- Ничего не делаем!
-------------------------------------------------------------------------------
procedure CmdFlush
is
begin
  -- На локальной модели ничего не делает.
  null;
end CmdFlush;  

-- Команда выполняет операцию на сервере модели.
-------------------------------------------------------------------------------
procedure CmdExecute
is
begin
  -- Посылаем ошибку, о том что это неподдерживаемая команда.
  EM := 'Комманда Execute не поддерживается в пакете Macro!'; 
  logError; 
end CmdExecute;  

-- Команда создаёт или обновляет объект.
-------------------------------------------------------------------------------
procedure CmdCreateOrUpdate
is
begin
  SP.IM.INSERTED_or_UPDATED;
end CmdCreateOrUpdate;

-- Команда изменяет примечания объекта.
-------------------------------------------------------------------------------
procedure CmdUpdateNotes
is
begin
  SP.IM.NOTES_UPDATED; 
end CmdUpdateNotes;

-- Команда предоставляет полный набор параметров объекта модели.
-------------------------------------------------------------------------------
procedure CmdGetObjectPars
is
begin
  SP.IM.FILL_OBJECT(SP.IM.PP); 
  -- В режиме пошагового выполнения распечатываем параметры.
  if MacroState = G.MS_Stepping then
    logPP;
  end if; 
end CmdGetObjectPars;
 
-- Команда проверяет существвание объекта модели.
-------------------------------------------------------------------------------
procedure CmdIsObjectExist
is
tmpVar NUMBER;
begin
  tmpVar := SP.IM.IS_OBJECT_EXIST;
  -- В режиме пошагового выполнения печатаем ID и EXISTS.
  if MacroState = G.MS_Stepping then
    logPP('ID');
    logPP('EXISTS');
  end if; 
end CmdIsObjectExist;

-- Команда удаляет объект модели.
-------------------------------------------------------------------------------
procedure CmdDeleteObject
is
begin
  SP.IM.DELETED;
end CmdDeleteObject;

-- Команда перемещяет объект по дереву иерархии.
-------------------------------------------------------------------------------
procedure CmdChangeParent
is
tmpVar BOOLEAN;
begin
  SP.IM.RENAMED; 
  tmpVar := checkEM;
end CmdChangeParent;  
 
-- Команда изменяет короткое имя объекта (Переименование).
-------------------------------------------------------------------------------
procedure CmdRename
is
tmpVar BOOLEAN;
begin
  SP.IM.RENAMED; 
  tmpVar := checkEM;
end CmdRename;  

-- Команда считывания дочерних, но не внучатых, объектов по отношению к
-- заданному пути.
-- Systems > Если параметр равен true, то считываются только системы.
-- full > Если параметр равен true, то считываются все свойства объектов.
-------------------------------------------------------------------------------
procedure CmdGetObjects(Systems in boolean, full in boolean)
is
i PLS_INTEGER;
begin
  -- Считываем объекты при помощи пакета IM.
  if Systems then
    SP.IM.FILL_SYSTEMS;
  else
    if full then
      SP.IM.FILL_FULL_OBJECTS;
    else
      SP.IM.FILL_OBJECTS;
    end if;
  end if; 
  if MacroState = G.MS_Stepping then
    -- По каждому элементу принятого массива "ID" cоздаём элемент массива OS.
    i := SP.IM.OS.first;
    while i is not null
    loop
      if SP.IM.OS(i).exists('NAME') then
        logS(SP.VAL_TO_STR(SP.IM.OS(i)('NAME')));
      else
        logS('Объект без имени!!!!');
      end if;  
      i := SP.IM.OS.next(i);
    end loop;
  end if; 
end CmdGetObjects;

-- Команда прерывает выполнение макропроцедуры и ожидает пока пользователь
-- выделит некоторые объекты в модели. Макропроцедура продолжит выполнение
-- после вызова метода Continue().
-------------------------------------------------------------------------------
procedure CmdGetSelected
is 
begin
  -- Изменяем состояние выполнения.
  setState(G.MS_WaitingSelection);
end CmdGetSelected;

-- Команда очищает выделение в моделе.
-------------------------------------------------------------------------------
procedure CmdClearSelected
is 
begin
  -- Изменяем состояние выполнения.
  setState(G.MS_CLEARSELECTED);
end CmdClearSelected; 

-- Команда прерывает выполнение макропроцедуры и ожидает пока пользователь
-- отредактирует значения параметров в представлении V_COMMAND_PAR_S.
-- Макропроцедура продолжит выполнение после вызова метода Continue().
-------------------------------------------------------------------------------
procedure CmdGetUserInput
is 
begin
  -- Изменяем состояние выполнения.
  setState(G.MS_WAITINGUSER);
end CmdGetUserInput; 

-- Команда считывания объектов нахоящихся ниже по отношению к
-- опорному объекту.
-- Systems > Если параметр равен true, то считываются только системы.
-- full > Если параметр равен true, то считываются все свойства объектов.
-------------------------------------------------------------------------------
procedure CmdGetAllObjects(Systems in boolean, full in boolean)
is 
begin    
-- Заполняем массив OS содержимым всех объектов относительно объекта PP.
  case
    when Systems and full then SP.IM.FILL_ALL_FULL_SYSTEMS();
    when Systems and not full then SP.IM.FILL_ALL_SYSTEMS();
    when not Systems and full then SP.IM.FILL_ALL_FULL_OBJECTS();
    when not Systems and not full then SP.IM.FILL_ALL_OBJECTS();
  end case;
  if SP.IM.EM is not null then
    EM := SP.IM.EM;
    logError();
  end if;
end CmdGetAllObjects; 

-- Команда переключает текущий сервер модели.
-- изменяем локальную модель, иначе выдаём ошибку. 
-------------------------------------------------------------------------------
procedure CmdToggleServer
is 
p SP.TGPAR;
tmpVar BOOLEAN;
begin  
  -- Проверяем, что модель локальная PP('SERVER') - Local.
  if SP.IM.PP('SERVER').E != 'Local' then
    EM := 'Попытка переключиться на нелокальную модель! ';
    logError();
    return;
  end if;
  p:=SP.TGPAR('CurModel');
  p.VAL.S:=SP.IM.PP('MODEL').S;
  p.SAVE;
  -- Устанавливаем root в корень.
  SP.IM.OS.delete;
  SP.IM.OS(1) := SP.MO.GET_MODEL_HROOT;
  SP.IM.SET_ROOT;
  tmpVar := checkEM;
end CmdToggleServer;
 
procedure CmdSetPars
is 
p SP.TGPAR;
begin
  SP.IM.UPDATE_MOD_OBJ_PARS;
  if SP.IM.EM is not null then
    EM := SP.IM.EM;
    logError();
    return;    
  end if;
end CmdSetPars;
 
-- Устанавливаем входные параметры в соответствии с наботом входных параметров.
procedure CmdSetGParsVals
is 
p SP.TGPAR;
name VARCHAR2(4000);
v SP.TVALUE;
begin
  name := SP.IM.PP.first;
  while name is not null
  loop
    p := SP.TGPAR(name);
    p.VAL := SP.IM.PP(name);
    p.save;
    name := SP.IM.PP.next(name);
  end loop;
exception  
  when others then
    EM := 'Ошибка присвоения значения глобальному параметру '
          ||nvl(name, 'NULL')||SQLERRM||' ! ';
    logError();
    return; 
end CmdSetGParsVals;
 

-- Процедура выполняет очередную макрокоманду.
-------------------------------------------------------------------------------
procedure ExecuteCommand
as
begin
  CurCmd := SP.IM.get_COMMAND;
  D('Выполняем команду: '|| SP.to_str_CMD(CurCmd)||
    ' EM=>'||nvl(EM, 'null')||' SP.IM.EM=>'||nvl(SP.IM.EM, 'null'),
    'SP.Macro_I');
  -- Заносим в лог сообщения, оставленные при выполнении команды.
  logMessages;
  -- Проверяем предупреждения.
  checkWM;
  --
  case CurCmd
    when G.CMD_Cancel then
      CmdRollback;
      SP.IM.CONFIRM_END;
      EM :=SP.IM.EM;
      -- Протоколируем ошибку и переходим в состояние ошибки.
      logError;
    when G.CMD_Create_Object then
      CmdCreateOrUpdate;
      if (MacroState = G.MS_STEPPING) then
        -- Выполняем commit, иначе не будут видны изменения в модели.
        commit;
      end if;  
    when G.CMD_Delete_Object then
      CmdDeleteObject;
    when  G.CMD_Get_Objects then
      CmdGetObjects(Systems => false, full => false);
    when G.CMD_Get_Full_Objects then
      CmdGetObjects(Systems => false, full => true);
    when G.CMD_Get_Pars then
      CmdGetObjectPars;
    when G.CMD_Is_Object_Exist then
      CmdIsObjectExist;
    when G.CMD_Get_Systems then
      CmdGetObjects(Systems => true, full=> false);
    when G.CMD_Get_All_Systems then
      CmdGetAllObjects(Systems => true, full => false);
    when G.CMD_Get_All_Objects then
      CmdGetAllObjects(Systems => false, full => false);
    when G.CMD_Get_All_FullObjects then
      CmdGetAllObjects(Systems => false, full => true);
    when G.CMD_Play then
      CmdPlay;
    when G.CMD_Return then
      commit;
      SP.IM.CONFIRM_END;
      -- Устанавливаем состояние завершения.
      setState(G.MS_Ready);
    when G.CMD_Set_Root then
      CmdSetRoot;
    when G.CMD_Model3D_Commit then
      CmdCommit;
    when G.CMD_Model3D_Rollback then
      CmdRollback;
    when G.CMD_Model3D_Refresh then
      CmdRefresh;
    when G.CMD_Model3D_Flush then
      CmdFlush;
    when G.CMD_Get_Selected then
      CmdGetSelected;
    when G.CMD_Get_User_Input then
      CmdGetUserInput;
    when G.CMD_Change_Parent then
      CmdChangeParent;
    when G.CMD_Rename then
      CmdRename;
    when G.CMD_Update_Notes then
      CmdUpdateNotes;
    when G.CMD_Clear_Selected then
      CmdClearSelected;
    when G.CMD_Toggle_Server then
      CmdToggleServer;
    when G.CMD_Execute then
      CmdExecute;
    when G.CMD_Set_Pars then
      CmdSetPars;
    when G.CMD_Set_GPars_Vals then
      CmdSetGParsVals;
  else
    EM := 'ERROR in SP.MACRO_I. Invalid command =>'|| CurCmd||'!';
    -- Протоколируем ошибку и переходим в состояние ошибки.
    logError;
  end case;
end ExecuteCommand;



-- Основной цикл автомата. Автомат изменяет состояние макропроцедуры
-- и выполняет необходимые макрооперации.
-------------------------------------------------------------------------------
procedure MainLoop
is
signal VARCHAR2(128);
begin
  loop  
    -- Выполняем очередную команду.
    ExecuteCommand();
    -- Проверяем сигнал.
    signal := THREADS.GETSIGNAL;
    -- Если приняли сигнал, то переходим в состояние ожидания.
    if signal is not null then
      d('Приняли сигнал '||signal,'SP.MACRO_I');
      setState(G.MS_PAUSED);
    end if;
    -- Если пошаговое выполнение, то переходим в состояние ожидания.
    if MacroState = G.MS_STEPPING then
      setState(G.MS_PAUSED);
    end if;
    -- Если состояние ожидания или готовности или ошибки, то выход из процедуры.
    exit when MacroState != G.MS_Working;
  end loop;  
exception
  when others then
    D(SQLERRM,'UNHANDLED ERROR in Macro_I');
    EM := 'UNHANDLED ERROR in Macro_I => '||SQLERRM;
    LogError;
end;
   
   
    
-------------------------------------------------------------------------------
--!!! Посмотреть когда нужна очистка параметров
--    protected void ORA_CLEAR_OBJECTS()
--    cmd.CommandText = "begin SP.IM.Clear_Objects; end;";
-------------------------------------------------------------------------------



-- Публичный интерфейс
/*************************************************************************/
-------------------------------------------------------------------------------
procedure setState(State in VARCHAR2)
is
s VARCHAR2(128);
tmpVar NUMBER;
begin
  if State in 
  (
     G.MS_NotDef, G.MS_Starting, G.MS_Waiting, G.MS_Ready, G.MS_Warning,
     G.MS_Working, G.MS_Stepping, G.MS_Paused, G.MS_Error, G.MS_Closing,
     G.MS_WaitingUser, G.MS_WaitingSelection, G.MS_ClearSelected, G.MS_MustBeep  
  )
  then
    s := State;
    if s = G.MS_Ready then 
      select count(*) into tmpVar from SP.M_ERRORS_AND_WARNINGS;
      if tmpVar > 0 then
        s := G.MS_Warning;
      end if;  
    end if;
    MacroState := s;
    THREADS.SendState(ProgressBarPos => 100, Mess => s);
    d('Установили состояние '||MacroState,'SP.Macro_I');
  else
    EM := 'ERROR in SP.MACRO_I.setState. Недопустимое состояние '||
           nvl(State, 'null')||' !';
    LogError(false);       
  end if;  
end setState;

-------------------------------------------------------------------------------
procedure setSelected
is
i PLS_INTEGER;
begin
  -- По каждому элементу принятого массива "ID" cоздаём элемент массива OS.
  i := ThArrs.num('ID').first;
  while i is not null
  loop
    SP.IM.SELECT_OBJECT(ThArrs.num('ID')(i));
    i := ThArrs.num('ID').next(i);
  end loop;
  SP.IM.OS := SP.IM.SS;
  setState(MacroState); 
end setSelected;

-------------------------------------------------------------------------------
procedure ContinueMacro(byStep in VARCHAR2 default '') 
is
s VARCHAR2(128);
--r SP.TMLOG_RECORD;
begin
  s:= MacroState;
  if s in  
  (
   -- G.MS_NotDef, G.MS_Starting, G.MS_Waiting,
    G.MS_Ready, G.MS_Warning, 
   -- G.MS_Working, G.MS_Stepping, 
    G.MS_Paused,
   -- G.MS_Error, G.MS_Closing,
    G.MS_WaitingUser, G.MS_WaitingSelection, G.MS_ClearSelected, G.MS_MustBeep
  )
  then
    -- Устанавливаем состояние работы.
    setState(case 
               when byStep is not null then G.MS_Stepping 
               else G.MS_Working 
             end);
    -- Если состояние готов, то стартуем процедуру.
    if s in ( G.MS_Ready, G.MS_Warning) then
      EM := SP.IM.START_MACRO(CurMacro);
      d('START_MACRO EM => '||EM,'SP.MACRO_I');
      if CheckEM then 
        d('Получили ошибку => '||EM,'SP.MACRO_I');
        logError; 
        return; 
      end if;
    end if;
    -- Запускаем выполнение.
    d('Запускаем выполнение.','SP.MACRO_I');
    MainLoop;  
  else 
    -- Записываем ошибку, если состояние не позволяет продолжить работу.
    EM := 'Не возможно продолжить выполнение из состояния '||s||'!'; 
    logError; 
  end if;
end ContinueMacro;

-------------------------------------------------------------------------------
function getPars return TWCPars pipelined
is
begin
  if not THREADS.isDebug then
    -- Передаём таблицу WORK_COMMAND_PAR_S.
    for c in (select * from SP.WORK_COMMAND_PAR_S)
    loop
      pipe row(c);
    end loop;
  end if; 
  setState(MacroState); 
end getPars;

-------------------------------------------------------------------------------
function getRoot return SP.TIMAN_PARS pipelined
is 
p SP.TIMAN_PAR_REC;
i VARCHAR2(256);
begin
  p := TIMAN_PAR_REC;
  -- Передаём корневой объект.
  i := SP.M.ROOT.first;
  while i is not null
  loop
    p.Assign(i,SP.M.ROOT(i),1);
    pipe row(p);
    i := SP.M.ROOT.next(i);
  end loop; 
  setState(MacroState); 
end getRoot;  

-------------------------------------------------------------------------------
procedure setRoot(RootID in NUMBER) 
is
begin 
  -- Установка текущей позиции корневого объекта дерева модели.
  -- Процедура сначала заполняет массив SP.IM.OS. значениями параметров объекта
  -- модели с идентификатором RootID,
  SP.IM.OS.delete;
  SP.IM.OS(1)('ID') := SP.TVALUE(G.TID,rootID);
  SP.IM.FILL_OBJECT(SP.IM.OS(1));
  -- а потом устанавливает положение корневого объекта.
  SP.IM.SET_ROOT;
  setState(MacroState); 
end setRoot;


-- Инициализация пакета.
-------------------------------------------------------------------------------
BEGIN
EM := null;
WM := null;
MacroState := G.MS_NotDef;
CurCmd := SP.G.CMD_Cancel;
END Macro_I;
/
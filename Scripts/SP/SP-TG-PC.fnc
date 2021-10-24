-- SP Set TG variables and triggers procedures
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.08.2010
-- update 29.10.2010 02.11.2010 19.11.2010 24.11.2010 03.03.2011 02.11.2011
--        09.11.2011 25.11.2011 01.12.2011 05.12.2011 15.12.2011 20.12.2011
--        16.01.2012 08.02.2012 16.03.2012 13.04.2012 27.05.2013 17.06.2013
--        25.08.2013 30.09.2013 14.06.2014 15.06.2014 22.06.2014 27.06.2014
--        02.07.2014 03.07.2014 11.07.2014 26.08.2014 04.11.2014 25.11.2014
--        09.07.2015 27.04.2017 18.09.2017 16.11.2017 26.12.2020 29.06.2021
--        30.06.2021 08.09.2021

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Get_CurValue return VARCHAR2
-- Процедура получения строкового значения переменной SP.TG.CurValue. 
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.VAL_TO_STR(SP.TG.CurValue);
end; 
/
grant execute on SP.Get_CurValue to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SET_CheckValEnabled(val in NUMBER)
-- Процедура установки глобального параметра CheckValEnabled.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  SP.TG.Check_ValEnabled:=case val when 0 then false else true end;
end;
/

grant execute on SP.SET_CheckValEnabled to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SET_Create_Model(val in NUMBER)
-- Процедура установки глобального параметра Create_Model.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  SP.TG.Create_Model:=case val when 0 then false else true end;
end;
/

grant execute on SP.SET_Create_Model to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SET_Delete_Start_Composit(val in NUMBER)
-- Процедура установки глобального параметра Delete_Start_Composit.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  SP.TG.Delete_Start_Composit:=case val when 0 then false else true end;
end;
/

grant execute on SP.SET_Delete_Start_Composit to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GET_Delete_Start_Composit return BOOLEAN
-- Процедура доступа к глобальному параметру Delete_Start_Composit.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.TG.Delete_Start_Composit;
end;
/

grant execute on SP.GET_Delete_Start_Composit to SP_IM;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SET_CurModel(val in VARCHAR2)
-- Процедура установки глобального параметра CurModel.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
tmpVar NUMBER;
localModel NUMBER(1);
URole NUMBER;
begin
  -- Находим идентификатор модели.
  select ID, LOCAL, USING_ROLE into tmpVar, localModel, URole from SP.MODELS 
    where upper(NAME)=upper(val);
  -- Проверяем, что пользователь админ, или имеет роль.
  IF NOT (SP.HasUserRoleID(UROLE) or SP.TG.SP_ADMIN)
    THEN
      SP.TG.ResetFlags;    
      RAISE_APPLICATION_ERROR(-20033,'SP.SET_CurModel. '||
     'Недостаточно привелегий для просмотра выбранной модели: '||val||'!');
  END IF;  
  -- Устанавливаем переменную пакета SP.TG.
  SP.TG.Cur_MODEL_ID:=tmpVar;
  if localModel >0 then 
    SP.TG.CurModel_LOCAL := true;
  else
    SP.TG.CurModel_LOCAL := false;
  end if;  
exception
  when no_data_found then  
    -- Добавляем модель в таблицу.
    insert into SP.MODELS values(null,val,'Добавлена автоматически',
                                 0,0, null, sysdate,tg.UserName)
      returning ID into tmpVar;
    -- Устанавливаем переменную пакета SP.TG.
    SP.TG.Cur_MODEL_ID:=tmpVar;
    SP.TG.CurModel_LOCAL := false;
end;
/

grant execute on SP.SET_CurModel to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SET_CurBuh(val in VARCHAR2)
-- Процедура установки глобального параметра CurBuh.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
tmpVar NUMBER;
begin
  -- Находим идентификатор модели среди локальных, постоянных моделей.
  select ID into tmpVar from SP.MODELS 
    where upper(NAME)=upper(val)
      and LOCAL = 1
      and PERSISTENT = 1;
  -- Устанавливаем переменную пакета SP.TG.
  SP.TG.Cur_Buh_ID:=tmpVar;
exception
  when no_data_found then  
    RAISE_APPLICATION_ERROR(-20033, 'SP.SET_CurBuh.'||
        ' Модель плана счетов '||nvl(val,'null')||
        ' не найдена, либо несоответствует требованиям!');
end;
/

grant execute on SP.SET_CurModel to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GET_User return VARCHAR2
-- Фунция возвращает переменную User пакета TG.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.TG.UserName;
end;
/
grant execute on SP.GET_User to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GET_Model_ID return NUMBER
-- Фунция возвращает идентификатор текущей модели.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.TG.Cur_MODEL_ID;
end;
/
grant execute on SP.GET_Model_ID to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GET_Model_Name return VARCHAR2
-- Фунция возвращает имя текущей модели.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.TG.GET_CurMODEL_NAME;
end;
/
grant execute on SP.GET_Model_Name to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GET_ServerType return NUMBER
-- Фунция возвращает тип сервера модели.
-- Сам пакет TG недоступен снаружи SP.
-- (SP-TG-PC.fnc)
is
begin
  return SP.TG.Cur_Server;
end;
/
grant execute on SP.GET_ServerType to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.Clear_Model
-- Процедура удаляет все объекты для текущей модели,
-- если только она не имеет признак постоянной.
-- (SP-TG-PC.fnc)
is
 tmpVar NUMBER;
begin
  select m.PERSISTENT into tmpVar from SP.MODELS m 
    where ID=SP.GET_Model_ID;
  if tmpVar > 0 then
    return;
  end if;  
  delete from SP.MODEL_OBJECTS  where MODEL_ID=SP.GET_Model_ID;
  delete from SP.MODEL_OBJECT_PATHS where MODEL_ID=SP.GET_Model_ID;
  commit;
end;
/
grant execute on SP.Clear_Model to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.Clear_Models
-- Процедура удаляет все объекты для всех не локальных и не постоянных моделей.
-- Не постоянные модели удаляет совсем, если они добавлены автоматически и не использовались 300 дней.
-- (SP-TG-PC.fnc)
is
begin
  for m in (select * from SP.MODELS)
  loop
	  if m.PERSISTENT = 0 then
      begin
        delete from SP.MODEL_OBJECTS  where MODEL_ID=m.ID;
        delete from SP.MODEL_OBJECT_PATHS where MODEL_ID=m.ID;
        commit;
        d(m.NAME||' cleaned','SP.Clear_Models');
        if (m.COMMENTS = 'Добавлена автоматически')
          and ((sysdate - M.M_DATE) > 300)
        then
          delete from SP.MODELS where ID=m.ID;
          commit;
          d(m.NAME||' deleted','SP.Clear_Models');
        end if;
      exception
        when others then
          d(m.NAME||' raise '||SQLERRM,'ERROR in SP.Clear_Models');
      end;
    end if;
  end loop;
exception
  when others then
  d(SQLERRM,'ERROR in SP.Clear_Models');
end;
/
--grant execute on SP.Clear_Models to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Macro_Template(
  Command in NUMBER,  
  UsedObject in NUMBER default null) 
return VARCHAR2
-- Фунция возвращает содержимое поля макро при добавлении новой макрокоманды
-- или изменении ссылки макрокоманды на объект каталога. Результат этой функции
-- используется как шаболон, помогающий запрограмировать макрооперацию.
-- Command - идентификатор команды.
-- CurObject - ссылка на поле "USED_OBJ_ID" текущей записи.
-- (SP-TG-PC.fnc)
is
  tmpVar VARCHAR2(32000);
  procedure addPars
  is
  begin
    -- Заполняем шаблон блока макрокоманды кодом присвоения параметров
    -- объекта значениями по умолчанию.
      for p in (select * from V_OBJECT_PAR_S 
                where OBJECT_ID=UsedObject
                  and R_ONLY_ID!=SP.G.ReadOnly
                order by R_ONLY_ID,NAME)
      loop
        -- Присвоение значения параметра в зависимости от его типа.
        case p.TYPE_ID
          when sp.G.TStr4000 then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= S_('''||p.V||''');'
                   ||to_.STR;
          when sp.G.TInteger then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= I_('||p.V||');'
                   ||to_.STR;
          when sp.G.TNumber then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= N_('||p.V||');'
                   ||to_.STR;
          when sp.G.TBoolean then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= B_('||p.V||');'
                   ||to_.STR;
          when sp.G.TDouble then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= R_('||p.V||');'
                   ||to_.STR;
          when sp.G.TXYZ then
            if p.R_ONLY_ID=sp.G.Required then 
              tmpVar:=tmpVar||to_.STR||'-- Обязательный!'||to_.STR; 
            end if; 
            tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                   'IP('''||p.NAME||'''):= P_('''||p.V||''');'
                   ||to_.STR;
        else          
          tmpVar:=tmpVar||'/* '||p.COMMENTS||'*/'||to_.STR||
                  'IP('''||p.NAME||'''):= V_('''||
                  p.VALUE_TYPE||''', '''||p.V||''');'
                  ||to_.STR;
        end case;        
      end loop;
  end;
begin
  tmpVar:='';
  case Command
    when SP.G.Cmd_CREATE_OBJECT then
      if UsedObject is null then
        tmpVar:='-- Необходимо определить создаваемый объект.';
      else
        addPars;
      end if;  
    when SP.G.Cmd_DELETE_OBJECT then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_EXECUTE then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметров
      -- макропроцедуры значениями по умолчанию.
      if UsedObject is null then
        tmpVar:='-- Необходимо определить выполняемую процедуру.';
      else
        addPars;
      end if;  
    when SP.G.Cmd_SET_ROOT then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "NAME"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_PARS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_SYSTEMS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_ALL_SYSTEMS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_ALL_OBJECTS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_ALL_FULLOBJECTS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_OBJECTS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_GET_FULL_OBJECTS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= S_(''?'');';
    when SP.G.Cmd_FOR_OBJECTS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= OBJECTS(CurObject)(''NAME'');';
      addPars;
    when SP.G.Cmd_FOR_SYSTEMS then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''NAME''):= SYSTEMS(CurSYSTEM)(''NAME'');';
      addPars;
    when SP.G.Cmd_FOR_SELECTED then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметра "Name"
      -- объекта.
      tmpVar:='IP(''ID''):= SELECTED(CurSELECTED)(''ID'');';
      addPars;
    when SP.G.Cmd_PLAY then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметров "Name"
      -- и "Repetitions".
      tmpVar:=to_.str||'IP(''NAME''):= V_(G.TBeep,''BEEP'');'||
              to_.str||'IP(''REPETITIONS''):=I_(1);';
    when SP.G.Cmd_Change_Parent then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметров "Name"
      -- и "NEW_PARENT".
      tmpVar:=to_.str||'IP(''NAME''):= S_(''?'');'||
              to_.str||'IP(''NEW_PARENT''):=S_(''?'');';
    when SP.G.Cmd_FUNCTION then
      -- Заполняем шаблон блока макрокоманды.
      tmpVar:='(N in NUMBER) return NUMBER'||
              to_.str||
              'is'||
              to_.str||
              'BEGIN'||
              to_.str||
              '-- Тело функции.'||
              to_.str||
              'return N;'||
              to_.str||
              'END;';
    when SP.G.Cmd_Toggle_Server then
      -- Заполняем шаблон блока макрокоманды кодом присвоения параметров
      -- "SERVER" и "MODEL".
      tmpVar:='-- Тип сервера: Primary, Secondary, Local'|| 
              to_.str||'IP(''SERVER''):= V_(G.TServerType,''Local'');'||
              to_.str||'-- Имя модели необходимо только локальному серверу.'|| 
              to_.str||'IP(''MODEL''):=S_(''DEFAULT '');';
    when SP.G.Cmd_Set_GPars_Vals then
      -- Заполняем шаблон блока макрокоманды кодом присвоения глобального
      -- параметра.
      tmpVar:=to_.str||'-- Имя входного параметра '||
                       '- имя глобального параметра'|| 
              to_.str||'IP(''PAR_NAME''):= V_(''ValueType'',''Value'');';
    when SP.G.Cmd_Get_Selected then
      -- Заполняем шаблон блока макрокоманды кодом выбора объектов
      tmpVar:='-- Текст сообщения пользователю. '||
              to_.str||'IP(''MESSAGE''):= S_(''Выберите объект(ы)!'');';
  else
    null;
  end case;
  if length(tmpVar) > 3999 then
    tmpVar := substr(tmpVar,1,3990)||'...';
  end if;     
  return tmpVar;
end;
/
grant execute on SP.Macro_Template to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp.Is_Catalog_Parent_Possible(
  Item in VARCHAR2, Parent in VARCHAR2)
return NUMBER 
-- возвращает 1 если возможен перенос, 0 - если нельзя
-- (SP-TG-PC.fnc)
is
ItemID NUMBER;
ParentID NUMBER;
cnt NUMBER;
begin
  ItemID := sp.tree.GetID(Item);
  if ItemID < 0 then return 0; end if;
-- В корень всегда можно.
  if Parent = '\' then return 1; end if;
  ParentID := sp.tree.GetID(Parent);
  if ParentID < 0 then return 0; end if;
  if ParentID = ItemID then return 0; end if;
-- Зацикливание недопустимо!  
  select mod(count(*)+1,2) into cnt from (
    select id from SP.CATALOG_TREE
      where id != ItemID
        connect by prior id = parent_id 
        start with id = ItemID) where id = ParentID;
  return cnt;
end;
/

-- end of file
 

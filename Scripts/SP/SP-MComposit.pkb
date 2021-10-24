CREATE OR REPLACE PACKAGE BODY SP_IM.MComposit
-- Composit package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 28.02.2011 
-- update 14.11.2011 25.11.2011 24.01.2013 01.10.2013 25.06.2014 31.03.2015
--        21.01.2021 

--(SP-MComposit.pkb)
AS

FUNCTION get_COMMAND return NUMBER
is
result NUMBER;
tmpName VARCHAR2(128);
begin
  loop
    case ExecutionPoint
      when 1 then
        ExecutionPoint:=ExecutionPoint+1;
        if not P.exists('PARENT') then
          SP.M.RT_MACRO_ERROR(MacroName, 1,
                              'Отсутствует обязательный параметр PARENT!');
          return g.Cmd_CANCEL;
        end if;  
        if not P.exists('NAME') then
          SP.M.RT_MACRO_ERROR(MacroName, 1,
                              'Отсутствует обязательный параметр NAME!');
          return g.Cmd_CANCEL;
        end if;  
        -- Если установлен флаг, то удаляем одноимённый объект в модели.
        if SP.GET_Delete_Start_Composit then 
	        IP('NAME') := S_(Paths.NAME(P('PARENT').S,P('NAME').S));
	        return SP.G.Cmd_Delete_Object;
        end if;
      when 2 then
        ExecutionPoint:=ExecutionPoint+1;
        -- Если удалили объект, то даем Commit модели.
        if SP.GET_Delete_Start_Composit then 
	        return SP.G.Cmd_Model3D_Commit;
        end if;
      when 3 then
        -- Данная команда состоит из двух этапов в случае создания
        -- композитного объекта.
        -- На первом этапе выполняем создание системы в которой будут
        -- располагаться все объекты композита.
        -- На втором этапе вызывается макропроцедура создающая все остальные
        -- объекты.
        if CreateComposit then
          -- Если это второй этап.
          CreateComposit:=false;
          ExecutionPoint:=ExecutionPoint+1;
          SP.M.PUSH(MacroPackageName);
          -- Заполняем массив вабранных пользователем объектов, 
          -- перед запуском макропроцедуры.
          execute immediate('
            begin SP_IM.'||MacroPackageName||'.SELECTED:=
            SP_IM.MComposit.SELECTED;end;
                            ');
          return SP.G.Cmd_EXECUTE_MACRO;
        end if;
        SP.M.FILL_PARAMS(IP,MacroID);
        -- Переписываем массив параметров в массив входных параметров.
        IP:=P;
        -- Проверяем параметры.
        EM:=SP.M.TEST_PARAMS(IP);
        if EM is not null then
          SP.M.RT_MACRO_ERROR(MacroName, 1, SQLERRM);
          return g.Cmd_CANCEL;
        end if;
        CreateComposit:=true;
        return SP.G.Cmd_COMPOSITE_ORIGIN;
    else
      -- Возвращаемся из макропроцедуры;
      return g.Cmd_RETURN;
      end case;
  end loop;
exception
  when others then
    -- Протоколируем ошибку.
    SP.M.RT_MACRO_ERROR(MacroName, 1, SQLERRM);
    return g.Cmd_CANCEL;
end;

end MComposit;
/



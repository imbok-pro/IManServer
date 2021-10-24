-- Тригеры для Work views
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.11.2010
-- update 23.09.2011 28.09.2011 03.04.2013 02.04.2015 20.02.2017 30.09.2020
--
-- Параметры комманды.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_COMMAND_PAR_S_ii
INSTEAD OF INSERT ON SP.V_COMMAND_PAR_S
--(SP-Work-Instead.trg)
declare
  str_err VARCHAR2(500):='';
  Val SP.TVALUE;
  TypeID NUMBER;
  RO_ID NUMBER;
BEGIN
  if :NEW.VALUE_TYPE is not null then
    TypeID:=SP.TO_TYPE(:NEW.VALUE_TYPE);
  else
    TypeID:=:NEW.TYPE_ID;  
  end if;
  if :NEW.R_ONLY is not null then
    RO_ID:=SP.to_R_ONLY(:NEW.R_ONLY);
  else
    RO_ID:=:NEW.R_ONLY_ID;  
  end if;
  if TypeID is null then
    str_err := str_err||'Не задан тип параметра ';
  end if;   
  if RO_ID is null then
    str_err := str_err||'Не задан модификатор параметра ';
  end if;   
  if str_err != '' then
    raise_application_error(-20033,'SP.V_COMMAND_PAR_S_ii '||str_err||'!');
  end if;  
  if :NEW.V is not null then
    Val:=SP.TVALUE(TypeID,:NEW.V);
  else
    Val:=SP.TVALUE(TypeID,:NEW.N,:NEW.D, 1,:NEW.S,:NEW.X,:NEW.Y);
  end if;          
    insert into  SP.WORK_COMMAND_PAR_S
      VALUES (:NEW.NAME,:NEW.COMMENTS,RO_ID, 0,TypeID, 
    				  Val.E, Val.N, Val.D, Val.S, Val.X, Val.Y, SP.Val_to_Str(Val)); 
END;
/	
-- 
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_COMMAND_PAR_S_iu
INSTEAD OF UPDATE ON SP.V_COMMAND_PAR_S
--(SP-Work-Instead.trg)
declare
  Val SP.TVALUE;
BEGIN
  -- Редактировать тип нельзя.
  -- Проверяем, что параметр можно редактировать.
  if :OLD.R_ONLY_ID = 1 then
    raise_application_error(-20033,'SP.V_COMMAND_PAR_S_iu, Параметр '
      ||:OLD.NAME||' только для чтения!');
  end if;  
  -- Если значение - дата.
  if :OLD.TYPE_ID in (G.TDATE, G.TNULLDATE) then
    update SP.WORK_COMMAND_PAR_S set
      D = :NEW.D
    where
      NAME = :OLD.NAME;
  else
    -- Если изменено строковое значение параметра, то используем его.
    -- ! В данном случае мы учитываем регистр значения.
    if SP.G.notEQ(:NEW.V, :OLD.V) then
      Val:=SP.TVALUE(:OLD.TYPE_ID,:NEW.V);
    else
        Val:=SP.TVALUE(:OLD.TYPE_ID,:NEW.N,:NEW.D, 1,:NEW.S,:NEW.X,:NEW.Y);
    end if;
    update SP.WORK_COMMAND_PAR_S set
      E_VAL=Val.E,
      N=Val.N,
      D=Val.D,
      S=Val.S,
      X=Val.X,
      Y=Val.Y
    where
      NAME = :OLD.NAME;
  end if;  
END;
/

-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_COMMAND_PAR_S_id
INSTEAD OF DELETE ON SP.V_COMMAND_PAR_S
--(SP-Work-Instead.trg)
BEGIN
 delete from SP.WORK_COMMAND_PAR_S where NAME = :OLD.NAME;
END;
/	
--*****************************************************************************
-- 

-- end of File 
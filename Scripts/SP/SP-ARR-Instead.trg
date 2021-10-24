-- Тригеры для ARR views
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.01.2018
-- update 
--
-- Массивы.
-- INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ARRAYS_ii
INSTEAD OF INSERT ON SP.V_ARRAYS
--(SP-ARR-Instead.trg)
declare
  str_err VARCHAR2(500):='';
  Val SP.TVALUE;
  TypeID NUMBER;
  GroupID NUMBER;
BEGIN
  if :NEW.TYPE_NAME is not null then
    TypeID:=SP.TO_TYPE(:NEW.TYPE_NAME);
  else
    TypeID:=:NEW.TYPE_ID;  
  end if;
  if :NEW.GROUP_NAME is not null then
    begin
      select ID into GroupID from SP.GROUPS where NAME = :NEW.GROUP_NAME;
    exception
      when others then 
        GroupID:=null;
    end;
  else
    GroupID:=:NEW.GROUP_ID;  
  end if;
  if TypeID is null then
    str_err := str_err||'Не задан тип параметра ';
  end if;   
  if GroupID is null then
    str_err := str_err||'Отсутствует группа '||:NEW.GROUP_NAME;
  end if;   
  if str_err != '' then
    raise_application_error(-20033,'SP.V_ARRAYS_ii '||str_err||'!');
  end if;  
  if :NEW.V is not null then
    Val:=SP.TVALUE(TypeID,:NEW.V);
  else
    Val:=SP.TVALUE(TypeID,:NEW.N,:NEW.D, 1,:NEW.S,:NEW.X,:NEW.Y);
  end if;          
    insert into  SP.ARRAYS
    (
      NAME,
      GROUP_ID,
      IND_X,
      IND_Y,
      IND_Z,
      IND_D,
      IND_S,
      TYPE_ID,
      E_VAL,
      N,
      D, 
      S, 
      X, 
      Y,
      M_DATE,
      M_USER
    )
      VALUES 
    (
      :NEW.NAME,
      GroupID,
      :NEW.IND_X,
      :NEW.IND_Y,
      :NEW.IND_Z,
      :NEW.IND_D,
      :NEW.IND_S,
      TypeID, 
      Val.E,
      Val.N, 
      Val.D,
      Val.S,
      Val.X, 
      Val.Y,
      :NEW.M_DATE,
      :NEW.M_USER
    ); 
END;
/	
-- 
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ARRAYS_iu
INSTEAD OF UPDATE ON SP.V_ARRAYS
--(SP-ARR-Instead.trg)
declare
  Val SP.TVALUE;
  TypeID NUMBER;
BEGIN
  -- Редактировать можно только значение элемента.
  -- Если изменено строковое значение параметра, то используем его.
  if SP.G.notUpEQ(:NEW.TYPE_NAME, :OLD.TYPE_NAME) then
    TypeID:=SP.TO_TYPE(:NEW.TYPE_NAME);
  else
    TypeID:=:NEW.TYPE_ID;  
  end if;
  if SP.G.notEQ(:NEW.V, :OLD.V) then
    --d(, 'SP.V_ARRAYS_iu');
    Val:=SP.TVALUE(TypeID,:NEW.V);
  else
    Val:=SP.TVALUE(TypeID,:NEW.N,:NEW.D, 1,:NEW.S,:NEW.X,:NEW.Y);
  end if;
    update SP.ARRAYS set
      TYPE_ID = Val.T, 
      E_VAL = Val.E,
      N = Val.N,
      D = Val.D,
      S = Val.S,
      X = Val.X,
      Y = Val.Y
    where ID = :OLD.ID;
END;
/

-- INSTEAD_OF_DELETE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.V_ARRAYS_id
INSTEAD OF DELETE ON SP.V_ARRAYS
--(SP-Arr-Instead.trg)
BEGIN
  delete from SP.ARRAYS 
    where ID = :OLD.ID;
END;
/	
--*****************************************************************************
-- 

-- end of File 
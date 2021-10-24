-- SP Views
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 23.08.2010
-- update 09.04.2013
--*****************************************************************************
CREATE OR REPLACE FUNCTION SP.COMPILE_ERRORS(
  SName in VARCHAR2 default 'SP', ObjName in VARCHAR2 default null) 
return SP.TERROR_RECORDS
pipelined
-- Ошибки компиляции.
as
--(SP-Views-Error.vw)
begin
  for e in (select OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE from DBA_ERRORS 
            where upper(OWNER)=upper(SName)
              and ((upper(NAME)=upper(ObjName)) or (ObjName is null))
            order by OWNER,NAME,TYPE,ATTRIBUTE,SEQUENCE)
  loop
    pipe row(SP.TERROR_REC(e.OWNER, e.NAME, e.TYPE, e.LINE, e.POSITION,
                           e.TEXT, e.ATTRIBUTE));
  end loop;
  return;
exception
  when no_data_found then return;  
end;
/  
--
grant execute on SP.COMPILE_ERRORS to public; 
--
CREATE OR REPLACE VIEW SP.V_ERRORS
(OWNER,NAME,TYPE,LINE,POSITION,TEXT,ATTRIBUTE)
AS 
select OWNER, NAME, TYPE, 
       cast(LINE as NUMBER(6)), 
       cast(POSITION as NUMBER(6)),
       TEXT, ATTRIBUTE 
  from table(SP.COMPILE_ERRORS);
--
Comment on table SP.V_ERRORS is 'Ошибки компиляции.(SP-Views-Error.vw)';

COMMENT ON COLUMN SP.V_ERRORS.OWNER IS 'Владелец объекта.';
COMMENT ON COLUMN SP.V_ERRORS.NAME IS 'Имя объекта.';
COMMENT ON COLUMN SP.V_ERRORS.TYPE IS 'Тип объекта.';
COMMENT ON COLUMN SP.V_ERRORS.LINE 
  IS 'Указание на строку кода, содержащую ошибку.';
COMMENT ON COLUMN SP.V_ERRORS.POSITION 
  IS 'Указатель на позицию в строке кода.';
COMMENT ON COLUMN SP.V_ERRORS.TEXT IS 'Сообщение об ошибке.';
COMMENT ON COLUMN SP.V_ERRORS.ATTRIBUTE 
  IS 'Признак, является ли данная запись сообщением об ошибке или 
предупреждением.';

grant select on SP.V_ERRORS to public;
-- end of file




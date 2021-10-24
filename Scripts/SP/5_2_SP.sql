-- Основной скрипт SP 
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 26.11.2010
-- update 23.05.2014 28.03.2016
--*****************************************************************************
SET SQLBL ON;  
spool .\Log\5_2_sp.txt; 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;

-- Останавливаем всех демонов SP.
DECLARE
  tmpVar NUMBER;
BEGIN
  select count(*) into tmpVar from ALL_PROCEDURES ap 
	  where (ap.OBJECT_NAME='STOPSERVERS') and (ap.OWNER='SP');
  IF tmpVar>0 THEN 
    EXECUTE IMMEDIATE('
      begin
        SP.StopServers;
      end;
      ');
    EXECUTE IMMEDIATE('
      DROP Procedure SP.StopServers
      ');
    EXECUTE IMMEDIATE('
      begin
        raise_application_Error(-20000,
        ''Остановка серверов завершилась удачно!''||to_.STR||
        '' НЕОБХОДИМО завершить соединение,''||to_.STR||
        '' повторно соединится и перезапустить скрипт для продолжения обновления!'');
      end;
      ');
  END IF;
END;
/
declare
  tmpVar NUMBER;
begin
  -- Проверяем признак завершения восстановления данных при предыдущем
  -- обновлении базы, избежать обработки частично удалённой схемы "SP".
  select count(*) into tmpVar from ALL_PROCEDURES ap 
	  where (ap.OBJECT_NAME='OK') and (ap.OWNER='SP');
	if tmpVar = 0 then
    select count(*)into tmpVar from dual where exists 
       (select * from All_Users where USERNAME='SP');
    if tmpVar!=0 then 
       execute immediate('
         DROP USER "SP" CASCADE
         ');
    end if;
  else
    EXECUTE IMMEDIATE('
      begin
        raise_application_Error(-20000,
        ''Создание резервных данных завершилось неудачно!''||to_.STR||
        '' НЕОБХОДИМ разбор полёта перед продолжением!'');
      end;
      ');
  end if;
end;
/
--
spool off;
exit;


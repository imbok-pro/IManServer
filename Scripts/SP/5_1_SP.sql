-- Скрипт выгрузки данных SP 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 24.11.2010
-- update 24.11.2010 10.12.2010 15.03.2011 16.04.2011 03.06.2013 09.10.2013
--        22.05.2014 17.01.2018 21.04.2021
--*****************************************************************************
--
SET SQLBL ON;  
spool .\Log\5_1_sp.txt; 
--Выгружаем данные из схемы SP в схему SP-IO.
declare
  tmpVar NUMBER;
  Error VARCHAR2(4000);
begin
  -- Проверяем признак завершения восстановления данных при предыдущем
  -- обновлении базы, избежать обработки частично удалённой схемы "SP".
  select count(*) into tmpVar from ALL_PROCEDURES ap 
	  where (ap.OBJECT_NAME='OK') and (ap.OWNER='SP');
	if tmpVar>0 then
      o(' ! EXPORT DATA');
      d(' ! EXPORT','5_SP');
	  -- Устанавливаем признак администратора.
    execute immediate(
      'begin '||
	    '  SP.TG.SP_Admin:=true;'||
	    '  SP.TG.ResetFlags;'||
      'end;');
    execute immediate(
      'begin '||
		  'SP.OUTPUT.Reset;'||
      'd('' ! Reset'',''5_SP'');'||
      'o('' ! Reset'');'||
      'SP.OUTPUT.Roles;'||
      'd('' ! Roles'',''5_SP'');'||
      'o('' ! Roles'');'||
		  'SP.OUTPUT.Users;'||
      'd('' ! Users'',''5_SP'');'||
      'o('' ! Users'');'||
      'SP.OUTPUT.Types;'||
      'd('' ! Types'',''5_SP'');'||
      'o('' ! Types'');'||
		  'SP.OUTPUT.Enums;'||
      'd('' ! Enums'',''5_SP'');'||
      'o('' ! Enums'');'||
		  'SP.OUTPUT.Globals;'||
      'd('' ! Globals'',''5_SP'');'||
      'o('' ! Globals'');'||
		  'SP.OUTPUT.GlobalValues;'||
      'd('' ! GlobalValues'',''5_SP'');'||
      'o('' ! GlobalValues'');'||
		  'SP.OUTPUT.CatalogTree;'||
      'd('' ! CatalogTree'',''5_SP'');'||
      'o('' ! CatalogTree'');'||
      'SP.OUTPUT.DOCS;'||
      'd('' ! DOCS'',''5_SP'');'||
      'o('' ! DOCS'');'||
      'SP.OUTPUT.ARRAYS;'||
      'd('' ! ARRAYS'',''5_SP'');'||
      'o('' ! ARRAYS'');'||
  	  'SP.OUTPUT.GROUPS;'||
      'd('' ! GROUPS'',''5_SP'');'||
      'o('' ! GROUPS'');'||
		  'SP.OUTPUT.Catalog;'||
      'd('' ! Catalog'',''5_SP'');'||
      'o('' ! Catalog'');'||
		  'SP.OUTPUT.Model;'||
      'd('' ! Model'',''5_SP'');'||
      'o('' ! Model'');'||
		  'commit; :Result:=1;'||
      'exception  when others then '||
      ' :Result:=0; :Err:=SQLERRM; '||
      'end;')using out tmpVar, out Error;
    if tmpVar=0 then
      o('ERROR in Output: '||Error);
      d(Error,'5_SP');
      raise_application_Error(-20000,
      'Экспорт данных завершился неудачно!!!'||
      ' ТРЕБУЕТСЯ разбор полёта перед обновлением базы!');
    end if;
    o('EXPORT SUCCESS!');
    execute immediate('drop procedure SP.OK'); 
    o('ok droped');   
    raise_application_Error(-20000,
      'Экспорт данных завершился удачно!'||to_.STR||
      ' НЕОБХОДИМО завершить соединение,'||to_.STR||
      ' повторно соединится и запустить скрипт для продолжения обновления!');
  end if;
  raise_application_Error(-20000,
    'Экспорт данных НЕ произведён!'||to_.STR||
    ' Это либо повторный экспорт, либо импорт не удался!');
end;
/
-- Oстановливаем пакет в случае ошибки.
WHENEVER SQLERROR EXIT ROLLBACK;
spool off;
exit;

-- Основной скрипт SP (part 3) 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.08.2010
-- update 31.08.2010 07.09.2010 13.10.2010 29.10.2010 03.11.2010 19.11.2010
--        22.11.2010 30.11.2010 17.12.2010 11.02.2011 28.02.2011 18.03.2011
--		    23.08.2011 24.11.2011 21.12.2011 05.06.2013 10.06.2013 17.06.2013 
--        19.06.2013 25.08.2013 09.10.2013 16.10.2013 06.02.2014 13.02.2014
--        23.05.2014 13.06.2014 14.06.2014 17.06.2014 24.06.2014 11.07.2014
--        16.07.2014 24.08.2014 26.08.2014 08.09.2014 13.10.2014 24.10.2014
--        04.11.2014
-- update by JP 
--        14.11.2014
-- update by NK
--        15.11.2014 26.11.2014 
-- update by SG
--        05.02.2015 16.02.2015
-- update by NK
--        19.02.2015 01.03.2015 22.03.2015 23.03.2015 25.03.2015 31.03.2015
--        21.04.2015 18.05.2015 20.05.2015-21.05.2015 08.07.2015 10.07.2015
--        13.07.2015 21.10.2015 02.11.2015 06.11.2015 03.02.2016 26.02.2016
--        28.03.2016 04.07.2016 06.07.2016 12.07.2016 23.07.2016 29.07.2016
--        02.08.2016 15.08.2016 01.09.2016 06.09.2016-07.09.2016 09.09.2016
--        12.09.2016-13.09.2016 04.10.2016 26.10.2016 31.10.2016 26.11.2016
--        17.01.2017 22.03.2017 23.03.2017 03.04.2017 06.04.2017 24.04.2017
--        10.05.2017 18.07.2017 24.07.2017 26.07.2017 07.08.2017 12.09.2017
--        18.09.2017 23.09.2017 27.11.2017 09.01.2018-10.01.2018 17.01.2017
--        18.01.2018-19.01.2018 11.05.2018
-- update by Azarov 
--        08.02.2018 19.02.2018 02.03.2018
-- update by NK
--        09.01.2019
-- update by PF
--        15.01.2019 10.04.2019 27.08.2019 04.09.2019 25.09.2019 28.08.2020
--        07.03.2021-08.03.2021 23.03.2021 05.04.2021 13.04.2021
-- update by NIK (новая версия после Hydroproject)
--        08.04.2021 20.04.2021 27.04.2021 17.06.2021 23.06.2021 16.07.2021
--        29.07.2021
-- В этом файле НЕЛЬЗЯ использовать спецсимвол восклицательный знак "!" !!!
--*****************************************************************************
--
SET SQLBL ON;  
--spool .\LOG\5_3_sp.txt; 
SET echo ON; 
--
-- Удаляем схему SP_IM.
DECLARE
  tmpVar NUMBER;
BEGIN
  SELECT COUNT(*)INTO tmpVar FROM DUAL WHERE EXISTS 
  (SELECT * FROM ALL_USERS WHERE USERNAME='SP_IM');
  IF tmpVar>0 THEN 
    EXECUTE IMMEDIATE('
      DROP USER "SP_IM" CASCADE
      ');
  END IF;
END;
/
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
--! Сделать удаление всех ролей из таблицы ролей, кроме встроенных.
--!! или отдельный скрипт очистки для неиспользуемых ролей, имеющих префикс SP.

-- Удаляем схему SP.
DECLARE
  tmpVar NUMBER;
BEGIN
  SELECT COUNT(*)INTO tmpVar FROM DUAL WHERE EXISTS 
  (SELECT * FROM ALL_USERS WHERE USERNAME='SP');
  IF tmpVar>0 THEN 
    EXECUTE IMMEDIATE('
     DROP USER "SP" CASCADE
     ');
  END IF;
END;
/
-- Проверяем отсутствие схемы SP
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
       (select * from All_Users where USERNAME='SP');
  if tmpVar!=0 then 
    tmpVar := 1 / 0;
  end if;
  o('SP deleted');
end;
/
-- Удаляем JOB ежедневной очистки моделей
declare
  tmpVar NUMBER;
begin
  for c1 in (
    select * from DBA_JOBS 
      where UPPER(WHAT)='SP.CLEAR_MODELS;')
  loop
    dbms_ijob.remove(c1.job);
  end loop;     
end;
/
-- Удаляем JOB ежедневного обновления кеша имен объектов моделей
declare
  tmpVar NUMBER;
begin
  for c1 in (
    select * from DBA_JOBS 
      where UPPER(WHAT)='SP.RENEW_MODEL_PATHS;')
  loop
    dbms_ijob.remove(c1.job);
  end loop;     
end;
/
--
-- Создаём схему SP.
CREATE USER "SP" IDENTIFIED BY "S"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;
-- 
ALTER USER "SP" QUOTA UNLIMITED ON SP_FILES; 
-- Создаём схему SP_IM.
CREATE USER "SP_IM" IDENTIFIED BY "S"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;
--
-- Предоставляем привилегии.

GRANT CREATE TABLE TO SP;
GRANT CREATE PROCEDURE TO SP;
GRANT CREATE PUBLIC SYNONYM TO SP;
GRANT CREATE ANY PROCEDURE TO SP;
GRANT ALTER ANY PROCEDURE TO SP;
GRANT DROP ANY PROCEDURE TO SP;
GRANT DROP ANY SEQUENCE TO SP;
GRANT GRANT ANY OBJECT PRIVILEGE TO SP;
GRANT CREATE VIEW TO SP;
GRANT ALTER SYSTEM TO SP;
GRANT CREATE USER TO SP;
GRANT DROP USER TO SP;
GRANT ALTER USER TO SP;
GRANT CREATE ROLE TO SP;
GRANT GRANT ANY ROLE TO SP;
GRANT DROP ANY ROLE TO SP;
GRANT GRANT ANY PRIVILEGE TO SP;
GRANT SELECT ON SYS.V_$SESSION TO "SP";
GRANT SELECT ON SYS.DBA_ROLES TO "SP";
GRANT SELECT ON SYS.DBA_SOURCE TO "SP";
GRANT SELECT ON SYS.DBA_ERRORS TO "SP";
GRANT SELECT ON SYS.DBA_SEQUENCES TO "SP";
GRANT SELECT ON SYS.DBA_ROLE_PRIVS TO "SP";
-- Строка нужна только для 10-го ORACLE. Eсли ORACLE 11, то лучше закоментить.
GRANT ALL ON SYS.DBA_ROLE_PRIVS TO "SP";
GRANT SELECT ON SYS.ROLE_ROLE_PRIVS TO "SP";
GRANT ALTER SYSTEM TO "SP";
GRANT EXECUTE ON SYS.dbms_LOCK TO "SP";
GRANT EXECUTE ON SYS.dbms_CRYPTO TO "SP";
GRANT EXECUTE ON SYS.utl_smtp TO "SP";
GRANT EXECUTE ON SYS.utl_tcp TO "SP";
--
GRANT SELECT,UPDATE,DELETE,INSERT ON SP_IO.CLIENT_SCRIPTS TO SP;
--
-- Права использования объектов схемы THREADS. 
GRANT ALL ON THREADS.JOBS TO "SP";
GRANT EXECUTE ON THREADS.SERVER TO "SP";
GRANT EXECUTE ON THREADS.ExecI TO "SP";
GRANT CREATE ANY JOB TO "SP";
GRANT SELECT ON dba_objects TO "SP";

-- Права на пакет UTL_MAIL, если он развернут 
declare
  tmpVar NUMBER;
begin
  select count(*) into tmpVar 
  from dba_objects where object_type='PACKAGE' and object_name = 'UTL_MAIL';
  if tmpVar > 0 then
   EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.UTL_MAIL TO "SP"';
  end if;
end;
/
-- Пакет копирования комментариев.
CREATE OR REPLACE PACKAGE SP.CC
AS
fT VARCHAR2(30);
tT VARCHAR2(30);
PROCEDURE C(fromColumn IN VARCHAR2, toCol IN VARCHAR2);
PROCEDURE all_av;
END;
/
CREATE OR REPLACE PACKAGE BODY SP.CC
AS
--
PROCEDURE C(fromColumn IN VARCHAR2, toCol IN VARCHAR2)
IS
  tmp VARCHAR2(32000);
BEGIN 
	SELECT comments INTO tmp FROM ALL_COL_COMMENTS 
	  WHERE (OWNER='SP')
		  AND (TABLE_NAME=fT)
			AND (COLUMN_NAME=FromColumn);
  tmp:='COMMENT ON COLUMN SP.'||tT||'.'||toCol||' IS '''||tmp||'''';		
  EXECUTE IMMEDIATE (tmp);
END C;
--
PROCEDURE all_av 
IS
 tmp SP.COMMANDS.COMMENTS%type;
BEGIN
  FOR c IN(
	SELECT COLUMN_NAME,COMMENTS FROM ALL_COL_COMMENTS 
	  WHERE (OWNER='SP')
		  AND (TABLE_NAME=fT))
	LOOP		
		tmp:='COMMENT ON COLUMN SP.'||tT||'.'||C.COLUMN_NAME||
		' IS '''||C.COMMENTS||'''';
		BEGIN		
      EXECUTE IMMEDIATE (tmp);
		EXCEPTION
		  WHEN OTHERS THEN NULL;	
		END;	
  END LOOP;
END all_av; 
END CC;
/ 
CREATE OR REPLACE PUBLIC SYNONYM cc FOR SP.CC;
--
-- Генераторы последовательностей идентификаторов.
@"SP-SEQUENCES.sql"
--
-- Спецификации типов.
@"SP-TValue.tps"
@"SP-TPar.tps"
@"SP-TYPES.tps"
@"SP-CONCAT_AGG_T.tps"
@"SP-CS_CYLINDR.tps"
--
-- Спецификации пакетов.
@"SP-G.pks"
GRANT EXECUTE ON SP.G TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM G FOR SP.G;
@"SP-C.pks"
GRANT EXECUTE ON SP.C TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM C FOR SP.C;
@"SP-A.pks"
GRANT EXECUTE ON SP.A TO PUBLIC;
--CREATE OR REPLACE PUBLIC SYNONYM A FOR SP.A;
@"SP-TG-PS.pks"
@"SP-TO_.pks"
GRANT EXECUTE ON SP.TO_ TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM TO_ FOR SP.TO_;
@"SP-TREE.pks"
@"SP-IMPORT.pks"
@"SP-INPUT.pks"
@"SP-OUTPUT.pks"
@"SP-IM.pks" 
GRANT EXECUTE ON SP.IM TO PUBLIC;
@"SP-M.pks"
GRANT EXECUTE ON SP.M TO SP_IM;
@"SP-B.pks"
GRANT EXECUTE ON SP.B TO PUBLIC;
@"SP-FUNC.pks"
GRANT EXECUTE ON SP.Func TO PUBLIC;
@"SP-Lobs.pks"
GRANT EXECUTE ON SP.LOBS TO PUBLIC;
@"SP-MO.pks"
GRANT EXECUTE ON SP.MO TO PUBLIC;
@"SP-Paths.pks"
GRANT EXECUTE ON SP.Paths TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM Paths FOR SP.Paths;
@"SP-Graph2Tree.pks"
GRANT EXECUTE ON SP.Graph2Tree TO PUBLIC;
@"SP-RolesTree.pks"
GRANT EXECUTE ON SP.RolesTree TO PUBLIC;
@"SP-Map.pks"
GRANT EXECUTE ON SP.Map TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM Map FOR sp.Map;
@"SP-MComposit.pks"
GRANT EXECUTE ON SP_IM.MComposit TO PUBLIC;
@"SP-STAIRWAY.pks"
GRANT EXECUTE ON SP.STAIRWAY TO PUBLIC;
@"SP-BUH.pks"
GRANT EXECUTE ON SP.BUH TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM BUH FOR sp.BUH;
@"SP-docPrj.pks"
GRANT EXECUTE ON SP.DOCPRJ TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM DOCPRJ FOR sp.DOCPRJ;
@"SP-docPrjGen.pks"
GRANT EXECUTE ON SP.DOCPRJGEN TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM DOCPRJGEN FOR sp.DOCPRJGEN;
@"SP-Macro.pks"
@"SP-Macro_I.pks"
GRANT EXECUTE ON SP.Macro TO PUBLIC;
GRANT EXECUTE ON SP.Macro_I TO THREADS;
@"SP-TJ_WORK.pks"
GRANT EXECUTE ON SP.TJ_WORK TO PUBLIC;
@"SP-TJ_MANAGEMENT.pks"
GRANT EXECUTE ON SP.TJ_MANAGEMENT TO PUBLIC;
@"SP-RGM.pks"
GRANT EXECUTE ON SP.RGM TO PUBLIC;

-- Скрипты таблиц.
@"SP-COMMANDS.sql" 
@"SP-ROLES.sql" 
@"SP-GROUPS.sql" 
@"SP-TYPES.sql"
@"SP-TYPES_ENUMS.sql"
@"SP-GLOBALS.sql"
@"SP-ARRAYS.sql"
@"SP-CATALOG.sql"
@"SP-MACROS.sql"
@"SP-MODEL.sql"
@"SP-Lobs.sql"
--
-- Таблицы PKF
@"SP-MAIL.sql"
@"SP-GRID_MD.sql"
-- TJ
@"SP-TJ.sql"
--
-- Устанавливаем ограничения для ALIAS.
ALTER TABLE SP.GROUPS ADD (
  CONSTRAINT REF_GROUPS_TO_MODEL 
  FOREIGN KEY (ALIAS)
  REFERENCES SP.MODEL_OBJECTS
  );
@"SP-Trans.sql"
@"SP-DOCS.sql" 
COMMIT;
-- Tригггера.
@"SP-TABLES.trg"
@"SP-GROUPS.trg"
@"SP-CATALOG.trg"
@"SP-MODEL.trg"
@"SP-MACROS.trg"
@"SP-TRANS.trg"
@"SP-ARRAYS.trg"
@"SP-DOCS.trg"
@"SP-Lobs.trg"
-- Системные процедуры и триггера.
@"SP-SYS.fnc"
GRANT ADMINISTER DATABASE TRIGGER to SP;
@"SP-SYS.trg"
-- Процедуры. 
-- Расширение *.prc желательно не использовать.
-- При редактировании программой PsPad файл завязывается узлом.
@"SP-WORK-PROCEDURES.fnc"
@"SP-PROCEDURES.fnc"
@"SP-TYPES.fnc"
@"SP-TG-PC.fnc"
@"SP-Views-Functions.fnc"
@"SP-agg_concat.fnc"
-- Процедуры SG
-- Обработка действия drag and drop
@"SP-DND_PROCESSING.prc"
-- LOBs jobs
@"SP-LOBS_JOBS.prc"
-- Сохранение глобальных параметров
@"SP-GLOBAL_VAR_CHANGE.prc"

--
GRANT EXECUTE ON SP.AGG_CONCAT TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM AGG_CONCAT FOR sp.AGG_CONCAT;
@"SP-get_obj_param_value.fnc"
GRANT EXECUTE ON SP.GET_OBJ_PARAM_VALUE TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM GET_OBJ_PARAM_VALUE FOR sp.GET_OBJ_PARAM_VALUE;

-- функции для работы с кодами ККС
@"SP-KKS.fnc"


-- Права использования объектов схемы SP схемой THREADS?. 
--!!
-- Тела пакетов и типов.
@"SP-TIMAN_PAR_REC.tpb"  
@"SP-TVALUE.tpb"  
@"SP-TGPAR.tpb"  
@"SP-TCPAR.tpb"  
@"SP-TMPAR.tpb" 
@"SP-TSPAR.tpb" 
@"SP-CONCAT_AGG_T.tpb"
@"SP-CS_CYLINDR.tpb"
@"SP-G.pkb"
@"SP-A.pkb"
@"SP-TG-PB.pkb"
@"SP-TO_.pkb"
@"SP-INPUT.pkb"
@"SP-IMPORT.pkb"
@"SP-OUTPUT.pkb"
@"SP-IM.pkb"
@"SP-M.pkb"
@"SP-TREE.pkb"
@"SP-Graph2Tree.pkb"
@"SP-RolesTree.pkb"
@"SP-B.pkb"
@"SP-C.pkb"
@"SP-MComposit.pkb"
@"SP-FUNC.pkb"
@"SP-Lobs.pkb"
@"SP-MO.pkb"
@"SP-Paths.pkb"
@"SP-Map.pkb"
@"SP-STAIRWAY.pkb"
@"SP-BUH.pkb"
@"SP-docPrj.pkb"
@"SP-docPrjGen.pkb"
@"SP-Macro.pkb"
@"SP-Macro_I.pkb"
@"SP-TJ_WORK.pkb"
@"SP-TJ_MANAGEMENT.pkb"
@"SP-RGM.pkb"
--
--Unwrap (перед включением провести ревизию и обновить содержимое файла)
--@"Unwrp.sql"
-- Представления.
@"SP-Views-Error.vw"
@"SP-Views.vw"
@"SP-Catalog-Views.vw"
@"SP-Model-Views.vw"
@"SP-Work-Views.vw"
@"SP-ARR-Views.vw"
@"SP-Groups-Views.vw"
@"SP-GObjects-Views.vw"
@"SP-DOCs-Views.vw"
@"SP-GUsedObjects-Views.vw"
@"SP-KKS-Views.vw"
-- ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';
-- Перекомпилируем неверные объекты и выдаём диагностику.
-- 1.
DECLARE
  tmpVar VARCHAR2(38);
BEGIN
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP');
  O('SP Invalid Obj before: '||tmpVar);   
   sys.utl_recomp.recomp_serial('SP',0);
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP');
  O('after: '||tmpVar);   
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP_IM');
  O('SP_IM Invalid Obj before: '||tmpVar);   
   sys.utl_recomp.recomp_serial('SP_IM',0);
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP_IM');
  O('after: '||tmpVar);   
--  KOCEL.TABLE2SHEET('SP.V_ERRORS','ERRORS','SP COMPILE ERRORS');   
END;
/
-- Поднимаем триггер OnLoggon
alter trigger SP.ON_LOGON compile;
--
DECLARE
  tmpVar VARCHAR2(38);
BEGIN
  O('Повторно для SP');   
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP');
  O('SP Invalid Obj before: '||tmpVar);   
   sys.utl_recomp.recomp_serial('SP',0);
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP');
  O('after: '||tmpVar);   
END;
/
EXIT;
-- Загрузка данных из схемы SP_IO.
-- Признак безопастной загрузки.
begin
  -- При отсутствии конкретного допустимого значения параметра объекта модели,
  -- параметру будет присвоено первое допустимое значение.
  SP.INPUT.SAFE := true;
  -- При отсутствии конкретного допустимого значения параметра объекта модели,
  -- будет прервано выполнение загрузки.
--  SP.INPUT.SAFE := false;  
end;
/  
-------------------------------------------------------------------------------
-- Устанавливаем признак администратора.
-- 2.
BEGIN
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
END;
/
-- Oстановливаем пакет в случае ошибки.
-- 3.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт ролей.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN  
  EM:=SP.import.Script('ROLES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('ROLES');
COMMIT;
EXCEPTION
  WHEN OTHERS THEN o(SQLERRM);ROLLBACK;RAISE;  
END;
/
-- Импорт иерархии ролей.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN  
  EM:=SP.import.Script('ROLES_RELS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('ROLES_RELS');
COMMIT;
EXCEPTION
  WHEN OTHERS THEN o(SQLERRM);ROLLBACK;RAISE;  
END;
/
-- Заполняеми временную таблицу ролей для текущей сессии.
-- 4.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN  
  INSERT INTO SP.USER_ROLES (SELECT ID,NAME FROM SP.SP_ROLES);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN o(SQLERRM);ROLLBACK;RAISE;  
END;	
/

begin
  SYS.DBMS_LOCK.sleep(10);
  o('PAUSE');
end;
/
-- Oстановливаем пакет в случае ошибки.
-- 5.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт групп, пользователей, типов, именованных значений 
-- и глобальных параметров.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  EM:=SP.import.Script('SEQUENCES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('SEQUENCES');
  COMMIT;
END;
/

DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  EM:=SP.import.Script('GROUPS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('GROUPS');
  EM:=SP.import.Script('USERS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('USERS');
  EM:=SP.import.Script('USER_ROLES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('USER_ROLES');
  EM:=SP.import.Script('TYPES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('TYPES');
  EM:=SP.import.Script('ENUMS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('ENUMS');
  EM:=SP.import.Script('GLOBALS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('GLOBALS');
  EM:=SP.import.Script('USERS_GLOBALS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('USERS_GLOBALS');
  COMMIT;
END;
/
-- Oстановливаем пакет в случае ошибки.
-- 6.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт дерева каталога и документов.
DECLARE
EM SP.COMMANDS.COMMENTS%type;
BEGIN
  EM:=SP.import.Script('CATALOG_TREE');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('CATALOG_TREE');
  EM:=SP.import.Script('DOCS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('DOCS');
  COMMIT;
END;
/
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт Объектов.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  EM:=SP.import.Script('OBJECTS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('OBJECTS');
  EM:=SP.import.Script('OBJECT_PARS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('OBJECT_PARS');
  EM:=SP.import.Script('MACROS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MACROS');
  COMMIT;
END;
/
-- Oстановливаем пакет в случае ошибки.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт Массивов.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
  EM:=SP.import.Script('ARRAYS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('ARRAYS');
  COMMIT;
END;
/
-- Oстановливаем пакет в случае ошибки.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт Модели.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
  EM:=SP.import.Script('MODELS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODELS');
  EM:=SP.import.Script('MODEL_OBJECTS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODEL_OBJECTS');
  COMMIT;
END;
/
WHENEVER SQLERROR EXIT ROLLBACK;
--
Analyze Table SP.MODELS Compute Statistics;
Analyze Table SP.MODEL_OBJECTS Compute Statistics;
-- Заполняем таблицу кэша полных имён объектов.
BEGIN
  SP.RENEW_MODEL_PATHS;
  COMMIT;
END;
/
Analyze Table SP.MOD_OBJ_PARS_CACHE Compute Statistics;

-- Импорт Связей объектов каталога.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  SP.INPUT.SAFE := true;
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
  EM:=SP.import.Script('OBJECT_RELS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('OBJECT_RELS');
  COMMIT;
END;
/
WHENEVER SQLERROR EXIT ROLLBACK;
--
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  SP.INPUT.SAFE := true;
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
  EM:=SP.import.Script('MODEL_OBJECT_PARS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODEL_OBJECT_PARS');
  EM:=SP.import.Script('MODEL_OBJECT_STORIES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODEL_OBJECT_PAR_STORIES');
  COMMIT;
END;
/
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт Связей.
DECLARE
em SP.COMMANDS.COMMENTS%type;
BEGIN
  SP.TG.SP_Admin:=TRUE;
  SP.TG.UserName:='SP';
  SP.TG.IMPORTDATA := true;
  EM:=SP.import.Script('ALIASES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('ALIASES');
  EM:=SP.import.Script('MODEL_OBJECT_RELS');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODEL_OBJECT_RELS');
  EM:=SP.import.Script('MODEL_OBJECT_REL_STORIES');
  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
  o('MODEL_OBJECT_REL_STORIES');
  COMMIT;
END;
/
-- Oстановливаем пакет в случае ошибки.
-- 8.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Импорт параметров форм приложений.
--DECLARE
--em SP.COMMANDS.COMMENTS%type;
--BEGIN
--  EM:=SP.import.Script('FORM_PARAMS');
--  IF EM IS NOT NULL  THEN RAISE_APPLICATION_ERROR(-20000,EM);END IF;
--  o('FORM_PARAMS');
--  SP.TG.IMPORTDATA := false;
--  COMMIT;
--END;
--/
-- Oстановливаем пакет в случае ошибки.
-- 9.
WHENEVER SQLERROR EXIT ROLLBACK;
-- Созданием этой процедуры подтверждается успешный импорт данных.
CREATE PROCEDURE SP.OK AS BEGIN NULL; END;
/
-- Создаём JOB ежедневной очистки моделей
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
     ,what       => 'SP.CLEAR_MODELS;'
     ,next_date  => sysdate +1
     ,interval   => 'SYSDATE+1 '
     ,no_parse   => FALSE
    );
END;
/
-- Создаём JOB ежедневного обновления кеша имен объектов моделей
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
     ,what       => 'SP.RENEW_MODEL_PATHS;'
     ,next_date  => sysdate +1/1440
     ,interval   => 'SYSDATE+1 '
     ,no_parse   => FALSE
    );
END;
/
-- Создаём JOB ежедневного обновления кеша имен объектов моделей
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
     ,what       => 'SP.RENEW_MODEL_PATHS;'
     ,next_date  => sysdate +1/1440
     ,interval   => 'SYSDATE+1 '
     ,no_parse   => FALSE
    );
END;
/
-- удаляем JOB  ежедневнного ночного подъёма схемы
declare
  tmpVar NUMBER;
begin
  for c1 in (
	  select * from DBA_JOBS 
	    where UPPER(WHAT)='BEGIN SP.TG.SP_ADMIN:=TRUE;SP.DATA_EXPORT;END;')
  loop
	  dbms_ijob.remove(c1.job);
	end loop;		 
end;
/
@"SP-LOBS_JOBS.sql"
--=====ДОПОЛНИТЕЛЬНЫЕ БИБЛИОТЕКИ================================================
--Создание DB Link к БД Oracle Zuken e3.series
--@"SP-E3_DbLink.sql"

@"SP-TRANSLIT.pks"
GRANT EXECUTE ON SP.TRANSLIT TO PUBLIC;
@SP-VEC.pks
GRANT EXECUTE ON SP.VEC TO PUBLIC;
@SP-VEC_SEGMENT.pks
GRANT EXECUTE ON SP.VEC#SEGMENT TO PUBLIC;
@"SP-E3C.pks"
GRANT EXECUTE ON SP.E3C TO PUBLIC;
@"SP-KKS.pks"
GRANT EXECUTE ON SP.KKS TO PUBLIC;
@"SP-E3#TJ.pks"
GRANT EXECUTE ON SP.E3#TJ TO PUBLIC;
@"SP-TJ_WORK.pks"
GRANT EXECUTE ON SP.TJ_WORK TO PUBLIC;
@"SP-KKS#2.pks"
GRANT EXECUTE ON SP.KKS#2 TO PUBLIC;
@"SP-TJ#ELECTRO.pks"
GRANT EXECUTE ON SP.TJ#ELECTRO TO PUBLIC;
--временные таблицы для BRCM#DUMP 
@"SP-BRCM#DUMP.sql"
@"SP-BRCM#DUMP.pks"
GRANT EXECUTE ON SP.BRCM#DUMP TO PUBLIC;
@"SP-BRCM#TJ.pks"
GRANT EXECUTE ON SP.BRCM#TJ TO PUBLIC;
@"SP-TJ#AEP.pks"
GRANT EXECUTE ON SP.TJ#AEP TO PUBLIC;

@"SP-TRANSLIT.pkb"
@"SP-VEC.pkb"
@"SP-VEC_SEGMENT.pkb"
@"SP-E3C.pkb"
@"SP-KKS.pkb"
@"SP-E3#TJ.pkb"
@"SP-BRCM#DUMP.pkb"
@"SP-TJ_WORK.pkb"
@"SP-KKS#2.pkb"
@"SP-TJ#ELECTRO.pkb"
@"SP-BRCM#TJ.pkb"
@"SP-TJ#AEP.pkb"


--
-- Компилируем все макрокоманды. Создаём пакеты.
-- 10.
BEGIN
  o('Compiling Macros.');
  o(TO_CHAR(SP.B.COMPILE_ALL));
END;
/
--
-- Перекомпилируем ошибки, связанные с зависимостью пакетов.
DECLARE
  tmpVar VARCHAR2(38);
BEGIN
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP_IM');
	O('SP_IM Invalid Obj before: '||tmpVar);	 
   sys.utl_recomp.recomp_serial('SP_IM',0);
  SELECT TO_CHAR(COUNT(*)) INTO tmpVar FROM DBA_OBJECTS o 
     WHERE  (o.STATUS='INVALID') AND (o.OWNER='SP_IM');
	O('after: '||tmpVar);	 
--  KOCEL.TABLE2SHEET('SP.V_ERRORS','ERRORS','SP COMPILE ERRORS');	 
END;
/
-- Разрешаем работу приложениям.
update SP.GLOBAL_PAR_S set E_VAL = 'false', N = 0 where NAME = 'ServerService';
commit;
EXIT;

-- Создаём JOB подъёма схемы
create or replace function SP.next_DATA_UP return DATE
-- Пакет DBMS_JOB не любит субботу, поэтому формируем рассчёт даты для расписания поднятия данных в отдельной фунции.(5_3_SP.sql)
is
  L VARCHAR2(255);
  nd DATE;
begin
  SELECT Value into L FROM    V$NLS_PARAMETERS 
    where parameter = 'NLS_DATE_LANGUAGE';
  SP.SetNLS_Date_Language('RUSSIAN');
  nd := next_day(trunc(sysdate), 'Суббота')+20/24;
--  nd := trunc(sysdate +1)+0.1/24;
  SP.SetNLS_Date_Language(L);
  return nd;
end;
/
GRANT EXECUTE ON SP.next_DATA_UP to public;

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
     ,what       => 'begin SP.TG.SP_Admin:=TRUE;SP.Data_Export;end;'
     ,next_date  => SP.next_DATA_UP()
     ,interval   => 'SP.next_DATA_UP()'
     ,no_parse   => FALSE
    );
commit;    
END;
/

-- Скрипт анализа, необходимо запускать после восстановления данных и отработки
-- демона создающего кэш.
Analyze Table SP.BALANS Compute Statistics;
Analyze Table SP.CATALOG_TREE Compute Statistics;
Analyze Table SP.COMMANDS Compute Statistics;
Analyze Table SP.DOCS Compute Statistics;
Analyze Table SP.ENUM_VAL_S Compute Statistics;
Analyze Table SP.GLOBAL_PAR_S Compute Statistics;
Analyze Table SP.GRID_MD Compute Statistics;
Analyze Table SP.GROUPS Compute Statistics;
Analyze Table SP.MACROS Compute Statistics;
Analyze Table SP.MODELS Compute Statistics;
Analyze Table SP.MODEL_OBJECTS Compute Statistics;
Analyze Table SP.MODEL_OBJECT_PAR_S Compute Statistics;
Analyze Table SP.MODEL_OBJECT_PAR_STORIES Compute Statistics;
Analyze Table SP.MODEL_OBJECT_PATHS Compute Statistics;
Analyze Table SP.MOD_OBJ_PARS_CACHE Compute Statistics;
Analyze Table SP.OBJECTS Compute Statistics;
Analyze Table SP.OBJECT_PAR_S Compute Statistics;
Analyze Table SP.PAR_TYPES Compute Statistics;
Analyze Table SP.REL_S Compute Statistics;
Analyze Table SP.SP_ROLES Compute Statistics;
Analyze Table SP.SP_ROLES_RELS Compute Statistics;
Analyze Table SP.TRANS Compute Statistics;
Analyze Table SP.TRANS_DOC_S Compute Statistics;
Analyze Table SP.USER_ROLES Compute Statistics;
Analyze Table SP.SP_ROLES Compute Statistics;
Analyze Table SP.SP_ROLES_RELS Compute Statistics;

/

-- Конец скрипта создания. 

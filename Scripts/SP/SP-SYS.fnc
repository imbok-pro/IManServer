-- SP SYSTEM procedures
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.08.2010
-- update 31.08.2010 02.09.2010 23.09.2010 20.10.2010 08.11.2010 23.11.2010
--        11.02.2011 28.02.2011 09.03.2011 15.03.2011 11.11.2011 11.04.2012
--        03.04.2013 25.08.2013 27.09.2013 25.11.2013 17.06.2014 26.11.2014
--        22.03.2015 25.03.2015 30.03.2015 02.04.2015 20.04.2015-23.04.2015
--        17.05.2015 15.06.2015 02.07.2015 08.07.2015 10.07.2015 20.08.2015
--        17.09.2015 02.10.2015 05.11.2015 03.02.2015 04.07.2016 
--        04.07.16 Azarov add SP.AllUserPRoles
--        06.07.2016 15.08.2016 07.09.2016 21.09.2016 08.10.2016 17.10.2016
--        05.03.2017 26.07.2017 12.09.2017 01.12.2017 17.01.2018 09.01.2019
--        21.04.2021 18.07.2021 04.09.2021 09.09.2021 15.09.2021
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.EPSW(p IN VARCHAR2) RETURN VARCHAR2
-- Зашифровать пароль (SP-Sys.fnc).
IS
  key_bytes_raw RAW (32):=
  HEXTORAW('49204C4F5645204B495341203339303920CAE8F1F320EBFEE1E8F8FC21212149');
  encryption_type PLS_INTEGER := SYS.DBMS_CRYPTO.ENCRYPT_AES256
  + SYS.DBMS_CRYPTO.CHAIN_CBC
  + SYS.DBMS_CRYPTO.PAD_PKCS5;
encrypted_raw RAW(2000);
BEGIN
  encrypted_raw := SYS.DBMS_CRYPTO.ENCRYPT(
    src => UTL_I18N.STRING_TO_RAW (p),
    typ => encryption_type,
    KEY => key_bytes_raw);
  RETURN RAWTOHEX(encrypted_raw);
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.DPSW(p IN VARCHAR2) RETURN VARCHAR2
-- Расшифровать пароль (SP-Sys.fnc).
IS
  key_bytes_raw RAW (32):=
  HEXTORAW('49204C4F5645204B495341203339303920CAE8F1F320EBFEE1E8F8FC21212149');
  encryption_type PLS_INTEGER := SYS.DBMS_CRYPTO.ENCRYPT_AES256
    + SYS.DBMS_CRYPTO.CHAIN_CBC
    + SYS.DBMS_CRYPTO.PAD_PKCS5;
  encrypted_raw RAW(2000);
  decrypted_raw RAW(2000);
BEGIN
  encrypted_raw :=HEXTORAW(p);
  decrypted_raw := SYS.DBMS_CRYPTO.DECRYPT(
    src => encrypted_raw,
    typ => encryption_type,
    KEY => key_bytes_raw);
  RETURN UTL_I18N.RAW_TO_CHAR (decrypted_raw);
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.NEW_ROLE(NewRole IN VARCHAR2)
--Создаём роль (SP-Sys.fnc).
AS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
  tmpVar NUMBER;
BEGIN
  -- Если роль уже существует, то выход.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES WHERE ROLE=NewRole;
  IF tmpVar > 0 THEN RETURN; END IF;
  S:='CREATE ROLE "'||NewRole||'" NOT IDENTIFIED';
  EXECUTE IMMEDIATE(S);
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,'SP');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.NEW_ROLE. Ошибка создания роли: '||NewRole||'!');
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.GRANT_ROLE(GROLE_ID IN NUMBER,
                                          GRANTEE_ID IN NUMBER)
-- Предоставляем права роли другой роле. (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
  GROLE VARCHAR2(60);
  GRANTEE_NAME VARCHAR2(60);
  tmpVar NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.GRANT_ROLE. Привилегий недостаточно!');
  END IF;
  -- Получаем имена ролей из идентификаторов.
  SELECT NAME INTO GROLE FROM SP.SP_ROLES WHERE ID=GROLE_ID;
  SELECT NAME INTO GRANTEE_NAME FROM SP.SP_ROLES WHERE ID=GRANTEE_ID;
  -- Проверяем что роль существует на сервере, и если нужно, то создаём.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GROLE;
  IF tmpVar=0 THEN
    S:='CREATE ROLE "'||GROLE||'"';
    EXECUTE IMMEDIATE(S);
  END IF;
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GRANTEE_NAME;
  IF tmpVar=0 THEN
    S:='CREATE ROLE "'||GRANTEE_NAME||'"';
    EXECUTE IMMEDIATE(S);
  END IF;
  --Проверяем, что грант отсутствует.
  SELECT COUNT(*) INTO tmpVar FROM DBA_Role_PRIVS r 
    WHERE R.GRANTEE=GRANTEE_NAME AND R.GRANTED_ROLE=GROLE;
  IF tmpVar=0 THEN
    -- Предоставляем грант.
    S:='GRANT "'||GROLE||'" TO "'||GRANTEE_NAME||'" with admin option';
    d(S,'SP.GRANT_ROLE');
  EXECUTE IMMEDIATE(S);
  END IF;
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,' ERROR in SP.GRANT_ROLE');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.GRANT_ROLE. Ошибка предоставления роли: '||GROLE||
      ' роли: '||GRANTEE_NAME||'!');
END;
/
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.GRANT_USER_ROLE(SUser IN VARCHAR2,
                                           GRANTED IN VARCHAR2)
-- Предоставляем роль пользователю. (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  SpUser VARCHAR2(60);
  S VARCHAR2(128);
  tmpVar NUMBER;
  cnt NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
        'SP.GRANT_USER_ROLE. Привилегий недостаточно!');
  END IF;
  -- Проверяем есть ли такая роль в справочнике.
  SELECT COUNT(*) INTO cnt FROM SP.SP_ROLES WHERE NAME=GRANTED;
  -- Проверяем что роль существует на сервере.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GRANTED;
  -- Если имя пользователя состоит только из латинских букв и цифр,
  -- то поднимаем регистр. 
  -- В SP.USERS_GLOBALS имена пользователей храняться в том виде как они были
  -- введены администратором, но при создании пользователя, если все буквы
  -- английские мы поднимаем регистр, что даёт возможность написать имя
  -- пользователя при установлении соединения, используя произвольный регистр. 
  if regexp_instr(SUser,'[^A-Za-z0-9_]+') = 0 then
    SpUser := upper(SUser);
  else
    SpUser := SUser;
  end if;
  -- Предоставляем грант.
  IF cnt != 0 AND tmpVar != 0 THEN
    S:='GRANT "'||GRANTED||'" TO "'||SpUser||'" with admin option';
    --d(S,'SP.grant_role');
    EXECUTE IMMEDIATE(S);
    S:='ALTER USER "'||SpUser||'" DEFAULT ROLE ALL';
    --d(S,'SP.grant_role');
    EXECUTE IMMEDIATE(S);
  END IF;
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,'error SP.grant_role');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.GRANT_ROLE. Ошибка предоставления роли: '||GRANTED||
      ' пользователю: '||SpUser||'!');
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.REVOKE_ROLE(GROLE_ID IN NUMBER,
                                           GRANTED_ID IN NUMBER)
-- Отнимаем права роли(GRANTED) у другой роли(GROLE). (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
  GROLE VARCHAR2(60);
  GRANTED VARCHAR2(60);
  tmpVar NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.REVOKE_ROLE. Привилегий недостаточно!');
  END IF;
  -- Получаем имена ролей из идентификаторов/
  SELECT NAME INTO GROLE FROM SP.SP_ROLES WHERE ID=GROLE_ID;
  SELECT NAME INTO GRANTED FROM SP.SP_ROLES WHERE ID=GRANTED_ID;
  -- проверяем и если что либо отсутствует, то выход
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GROLE;
  IF tmpVar=0 THEN RETURN; END IF;
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GRANTED;
  IF tmpVar=0 THEN RETURN; END IF;
  S:='REVOKE "'||GRANTED||'" FROM "'||GROLE||'"';
  EXECUTE IMMEDIATE(S);
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,'ERROR SP.revoke_role');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.REVOKE_ROLE. Ошибка отнимания роли: '||GRANTED||
      ' у роли: '||GROLE||'!');
END;
/
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.REVOKE_USER_ROLE(SUser IN VARCHAR2,
                                                 GRANTED IN VARCHAR2)
-- Отнимаем роль у пользователя (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  SpUser VARCHAR2(60);
  S VARCHAR2(128);
  tmpVar NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.REVOKE_USER_ROLE. Привилегий недостаточно!');
  END IF;
  -- Проверяем есть ли такая роль в справочнике.
  SELECT COUNT(*) INTO tmpVar FROM SP.SP_ROLES WHERE NAME=GRANTED;
  IF tmpVar=0 THEN RETURN; END IF;
  -- Проверяем что роль существует на сервере.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=GRANTED;
  IF tmpVar=0 THEN RETURN; END IF;
  -- Если имя пользователя состоит только из латинских букв и цифр,
  -- то поднимаем регистр. 
  -- В SP.USERS_GLOBALS имена пользователей храняться в том виде как они были
  -- введены администратором, но при создании пользователя, если все буквы
  -- английские мы поднимаем регистр, что даёт возможность написать имя
  -- пользователя при установлении соединения используя произвольный регистр. 
  if regexp_instr(SUser,'[^A-Za-z0-9_]+') = 0 then
    SpUser := upper(SUser);
  else
    SpUser := SUser;
  end if;
  -- Проверяем, что эта не единственная роль пользователя.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLE_PRIVS D, SP.SP_ROLES R
    WHERE GRANTEE = SpUser
      AND R.NAME = D.GRANTED_ROLE;
  IF tmpVar <= 1 THEN RETURN; END IF;
  -- Отнимаем роль.
  S:='REVOKE "'||GRANTED||'" FROM "'||SpUser||'"';
  --d(S,'SP.REVOKE_USER_ROLE');
  EXECUTE IMMEDIATE(S);
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,'ERROR SP.REVOKE_USER_ROLE');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.REVOKE_USER_ROLE. Ошибка отнимания роли: '||GRANTED||
      ' у пользователя: '||SUser||'!');
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.DROP_ROLE(BROLE IN VARCHAR2)
-- Удаляем роль. (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
  tmpVar NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.DROP_ROLE. Привилегий недостаточно!');
  END IF;
  -- Если роли на сервере нет, то просто выход.
  SELECT COUNT(*) INTO tmpVar FROM DBA_ROLES r WHERE r.ROLE=BROLE;
  IF tmpVar=0 THEN RETURN; END IF;
  S:='DROP ROLE "'||BROLE||'"';
  EXECUTE IMMEDIATE(S);
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d(SQLERRM,'SP');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.DROP_ROLE. Ошибка удаления роли: '||BROLE||'!');
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.EXEC_AUTO(S IN VARCHAR2)
-- Выполнить автономную транзакцию (SP-Sys.fnc).
AS
PRAGMA autonomous_transaction;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20033,'SP.EXEC_AUTO. Привилегий недостаточно!');
  END IF;
  EXECUTE IMMEDIATE(S);
  COMMIT;
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    ROLLBACK;
    d(SQLERRM,'SP.EXEC_AUTO');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.EXEC_AUTO. Ошибка автономной транзакции: '||S||
      ' error:'||SQLERRM||'!' );
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.NUMBER_AUTO(S IN VARCHAR2) RETURN NUMBER
-- Выполнить автономную транзакцию и вернуть number (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  result NUMBER;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.NUMBER_AUTO. Привилегий недостаточно!');
  END IF;
  EXECUTE IMMEDIATE(S) USING OUT result;
  COMMIT;
  RETURN result;
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    ROLLBACK;
    d(SQLERRM,'SP.NUMBER_AUTO');
    RAISE_APPLICATION_ERROR(-20033,
      'SP.NUMBER_AUTO. Ошибка автономной транзакции: '||S||
      ' error:'||SQLERRM||'!' );
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetWarnings(ON_OFF IN BOOLEAN)
-- Включение-выключение режима выдачи предупреждений при перекомпиляции.
-- (SP-Sys.fnc).
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  IF ON_OFF THEN
    S:='ALTER SESSION SET PLSQL_WARNINGS=''ENABLE:ALL''';
  ELSE
    S:='ALTER SESSION SET PLSQL_WARNINGS=''DISABLE:ALL''';
  END IF;  
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetWarnings TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNLS_Language(NEW_Lang IN VARCHAR2)
--  Изменение NLS_Language текущей сессиии (SP-Sys.fnc).
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  S:='ALTER SESSION SET NLS_LANGUAGE = '||UPPER(NEW_Lang);
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNLS_Language TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNLS_Date_Language(NEW_Lang IN VARCHAR2)
-- Изменение NLS_Date_Language текущей сессиии (SP-Sys.fnc).
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  S:='ALTER SESSION SET NLS_DATE_LANGUAGE = '||UPPER(NEW_Lang);
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNLS_Date_Language TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNLS_Territory(NEW_Territory IN VARCHAR2)
-- Изменение NLS_Territory текущей сессиии. (SP-Sys.fnc)
IS
PRAGMA autonomous_transaction;
  NNumChars VARCHAR2(60);
  NEW_Sort VARCHAR2(60);
  S VARCHAR2(128);
BEGIN
-- Временно запоминаем значения разделителей числа и правила сортировки.
-- Заново устанавливаем их значения на сервере после установки кода территории.
  SELECT VALUE INTO NNumChars FROM V$NLS_PARAMETERS 
    WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
  SELECT VALUE INTO NEW_Sort FROM V$NLS_PARAMETERS 
    WHERE PARAMETER = 'NLS_SORT';
  S:='ALTER SESSION SET NLS_TERRITORY = '''||UPPER(NEW_TERRITORY)||'''';
  EXECUTE IMMEDIATE (S);
  S:='ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '''||UPPER(NNumChars)||'''';
  EXECUTE IMMEDIATE (S);
  S:='ALTER SESSION SET NLS_Sort = '||UPPER(NEW_Sort);
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNLS_Territory TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNNumChars(NEW_NNumChars IN VARCHAR2)
-- Изменение NLS_Numeric_Characters текущей сессиии (SP-Sys.fnc).
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  S:='ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '''||
     UPPER(NEW_NNumChars)||'''';
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNNumChars TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNLS_Sort(NEW_Sort IN VARCHAR2)
-- Изменение NLS_SORT текущей сессиии (SP-Sys.fnc).
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  S:='ALTER SESSION SET NLS_Sort = '||UPPER(NEW_Sort);
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNLS_Sort TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.SetNLS_DFormat(NEW_DFormat IN VARCHAR2)
-- Изменение NLS_DFormat текущей сессиии. (SP-Sys.fnc)
IS
PRAGMA autonomous_transaction;
  S VARCHAR2(128);
BEGIN
  S:='ALTER SESSION SET NLS_Date_Format = '''||NEW_DFormat||'''';
  EXECUTE IMMEDIATE (S);
  COMMIT;
END;
/

GRANT EXECUTE ON SP.SetNLS_DFormat TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserRoleName(RName IN VARCHAR2) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль с именем RName.
-- Пользователь по определению имеет неопределённую роль.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF (RName IS NULL) OR SP.TG.SP_Admin THEN RETURN TRUE; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_NAME=RName;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserRoleName(RName IN VARCHAR2) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с именем RName.
-- Пользователь по определению имеет неопределённую роль.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserRoleName(RName) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserRoleID(RID IN NUMBER) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль, определённую идентификатором RID.
-- Пользователь по определению имеет неопределённую роль.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF (RID IS NULL) OR SP.TG.SP_Admin THEN RETURN TRUE; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_ID=RID;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserRoleID(RID IN NUMBER) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с идентификатором RID.
-- Пользователь по определению имеет неопределённую роль.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserRoleID(RID) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserExactRoleName(RName IN VARCHAR2) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль с именем RName.
-- Привилегии пользователя не учитываются.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF RName IS NULL THEN RETURN false; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_NAME=RName;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserExactRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserExactRoleName(RName IN VARCHAR2) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с именем RName.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserExactRoleName(RName) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserExactRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserExactRoleID(RID IN NUMBER) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль, определённую идентификатором RID.
-- Привилегии пользователя не учитываются.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF RID IS NULL THEN RETURN false; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_ID=RID;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserExactRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserExactRoleID(RID IN NUMBER) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с идентификатором RID.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserExactRoleID(RID) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserExactRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserEditRoleName(RName IN VARCHAR2) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль с именем RName.
-- Если RName нулл, то её имеет только администратор.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF SP.TG.SP_Admin THEN RETURN TRUE; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_NAME=RName;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserEditRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserEditRoleName(RName IN VARCHAR2) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с именем RName.
-- Если RName нулл, то её имеет только администратор.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserEditRoleName(RName) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserEditRoleName TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.HasUserEditRoleID(RID IN NUMBER) 
RETURN BOOLEAN
-- Проверяем имеет ли пользователь роль, определённую идентификатором RID.
-- Если RName нулл, то её имеет только администратор.
-- (SP-Sys.fnc)
IS
tmpVar NUMBER;
BEGIN
  IF SP.TG.SP_Admin THEN RETURN TRUE; END IF;  
  SELECT COUNT(*) INTO tmpVar FROM SP.USER_ROLES WHERE ROLE_ID=RID;
  IF tmpVar=0 THEN RETURN FALSE; END IF;  
  RETURN TRUE;
END;
/
GRANT EXECUTE ON SP.HasUserEditRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_HasUserEditRoleID(RID IN NUMBER) 
RETURN NUMBER
-- Проверяем имеет ли пользователь роль с идентификатором RID.
-- Если RName нулл, то её имеет только администратор.
-- (SP-Sys.fnc)
IS
BEGIN
  if SP.HasUserEditRoleID(RID) then 
    RETURN 1;
  else
    RETURN 0;
  end if;    
END;
/
GRANT EXECUTE ON SP.S_HasUserEditRoleID TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_isUserAdmin
RETURN NUMBER
-- Проверяем является ли пользователь администратором.
-- (Вариант финкции для SQL запросов).
-- (SP-Sys.fnc)
IS
BEGIN
  IF SP.TG.SP_Admin THEN RETURN 1; END IF;  
  RETURN 0;
END;
/
GRANT EXECUTE ON SP.S_isUserAdmin TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.isUserAdmin
RETURN BOOLEAN
-- Проверяем является ли пользователь администратором.
-- (SP-Sys.fnc)
IS
BEGIN
  RETURN SP.TG.SP_Admin;
END;
/
GRANT EXECUTE ON SP.isUserAdmin TO PUBLIC;

----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.StartServers(N in NUMBER default 1)
-- Процедура запускает демонов с правами SP для асинхнхронного выполнения
-- макропроцедур.
-- (SP-Sys.fnc)
is 
  cmd VARCHAR2(4000);
  temp NUMBER;
begin
  for i in 1..N
  loop
    cmd := 'THREADS.Server(G.DaemonPipe);';
    -- После завершения операции поток отдыхает одну секунду.
    dbms_JOB.submit(temp,cmd,SysDate,'SysDate+1/(24*60*60)');
    insert into THREADS.JOBS 
    values (0,temp,G.DaemonPipe,
            sys_context('userenv', 'session_user'),null,null,0);
    commit;
  end loop;
end;
/

----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.StopServers
-- Процедура останавливает всех демонов с правами SP.
-- (SP-Sys.fnc)
is
begin
  for c in (select JOB_ID from THREADS.JOBS where JOB_TUBE = G.DaemonPipe)
  loop
    --!! по aid найти параметры сессии и сбросить - этого делать не нужно, 
    -- необходимо дать возможность уже работающим демонам закончить свою работу!
    begin
      -- Если не починить сломанную работу, то виснет сессия удаления задания.
      dbms_job.broken(c.JOB_ID, false, sysdate+1); 
      dbms_JOB.remove(c.JOB_ID);
    exception
      when others then
        d('StopServer '||SQLERRM,'ERROR in SP.StopServers');
        raise;
    end;  
    delete from THREADS.JOBS j where j.JOB_ID=c.JOB_ID; 
    commit;
  end loop;
end;
/

----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.setSession(UName in VARCHAR2 default null)
-- Тело триггера OnLogon
-- (SP-Sys.fnc)
IS
tmpVar VARCHAR2(30);
service NUMBER;
BEGIN
--  DEBUG_OUTPUT.SETSTATE(true);
--  d('Logon '||SQLERRM,'ON_LOGON');
  tmpVar:= nvl(UName, S_User);
  -- d('User '||tmpVar||'!','ON_LOGON');
  IF tmpVar='SP' THEN
    SYS.DBMS_LOCK.sleep(10000000000);
  END IF;
  -- до ORACLE 12 SYS был не виден при установлении соединения!
  IF tmpVar IS NULL THEN
    RETURN;
  END IF;
  IF tmpVar in ('SYS', 'SYSTEM') THEN
    RETURN;
  END IF;
  -- Если USER не имеет роль SP_USER, то это не наш юзер.
  IF NOT HasUserRole(tmpVar,'SP_USER_ROLE') THEN 
    --d('User '||tmpVar||' не наш!','ON_LOGON');
    RETURN;
  END IF; 
  BEGIN
    select N into service from SP.Global_PAR_S
      where NAME ='ServerService';
    if service = 1 then
      --d('User регламент'||tmpVar||'!','ON_LOGON');
      RAISE_APPLICATION_ERROR(-20100,
        'Соединение отклонено - идут регламентные работы!');
    end if;
    SP.TG.UserName:=tmpVar;
    -- Если USER имеет роль SP_ADMIN, то устанавливаем поле в SP.TG
    IF HasUserRole(tmpVar,'SP_ADMIN_ROLE') THEN 
      SP.TG.SP_Admin:=TRUE;
    END IF; 
    -- Заполняем перечень ролей юзера во временную таблицу
    --D('Заполняем перечень ролей юзера во временную таблицу.','ON_LOGON');
    DELETE FROM SP.USER_ROLES;
    INSERT INTO SP.USER_ROLES 
    with GR_ROLE as 
    (  select distinct r.GRANTED_ROLE 
        from DBA_ROLE_PRIVS r 
        where DEFAULT_ROLE='YES'
          and tmpVar = r.GRANTEE )
    select distinct ID, NAME from
    (
      select distinct ID, NAME from
        (
          select r.ID, r.NAME, connect_by_Root r.PARENT PARENT from SP.V_ROLES r
            connect by prior r.ID = r.PID
        )rr
        where rr.PARENT in
        (
          select * from GR_ROLE
        )
      union all
      select distinct ID, NAME from SP.SP_ROLES sr, GR_ROLE ur
        where ur.GRANTED_ROLE = sr.NAME
    );             
    --D('Заполняем глобальные параметры.','ON_LOGON');
    -- Заполняем глобальные параметры
    delete from SP.WORK_GLOBAL_PAR_S;
    INSERT INTO SP.WORK_GLOBAL_PAR_S
      SELECT NULL,p.NAME,p.TYPE_ID,pt.ROWID,
             E_VAL,N,D,S,X,Y,REACTION,R_ONLY
        FROM SP.GLOBAL_PAR_S p,SP.PAR_TYPES pt
          WHERE pt.ID=p.TYPE_ID 
            AND UPPER(p.NAME) not in ( 'USER_PWD',
                                       'USER_COMMENTS', 'USER_GROUP')
            AND p.ID NOT IN ( SELECT GL_PAR_ID FROM SP.USERS_GLOBALS u 
                                 WHERE  UPPER(u.SP_USER)=tmpVar)
      UNION ALL 
      SELECT p.ID,p.NAME,p.TYPE_ID,pt.ROWID,
             U.E_VAL,U.N,U.D,U.S,U.X,U.Y,REACTION,R_ONLY 
        FROM SP.GLOBAL_PAR_S p,SP.PAR_TYPES pt, SP.USERS_GLOBALS u 
          WHERE u.GL_PAR_ID = p.ID 
            AND p.TYPE_ID = pt.ID 
            AND UPPER(u.SP_USER)=tmpVar;
    COMMIT;    
    --D('Выполняем блоки реакции глобальных параметров','ON_LOGON');
    -- Выполняем блоки реакции глобальных параметров, если они определены
    FOR rec IN (SELECT * FROM SP.WORK_GLOBAL_PAR_S 
                   WHERE REACTION IS NOT NULL)
    LOOP
      BEGIN  
--          D('Выполняем блок параметра: '||rec.Name,'ON_LOGON');
--          if upper(rec.Name)='DEBUG_MODE' then
--            D('Устанавливаем "DEBUG_MODE": '||rec.E_VAL,'ON_LOGON');
--          end if;  
        SP.GPAR_REACTION(
          rec.REACTION,
          TGPAR(rec.NAME,SP.TVALUE(rec.TYPE_ID,NULL,0,
                                    rec.E_VAL,rec.N,rec.D,rec.S,rec.X,rec.Y))
                              );
--          if upper(rec.Name)='DEBUG_MODE' then
--            D('Установлен "DEBUG_MODE": '||
--               to_.STR(DEBUG_OUTPUT.STATE),'ON_LOGON');
--          end if;  
      EXCEPTION
        WHEN others THEN 
          DEBUG_OUTPUT.SETSTATE(TRUE);
          D('Ошибка при выполнении блока параметра: '||
             rec.NAME,'ERROR ON_LOGON');
         NULL;-- диагностику даёт SP.GPAR_REACTION
      END;                                        
    END LOOP;
  EXCEPTION
    -- не надо мешать коннектится остальным юзерам базы
    WHEN others THEN 
      if sqlcode = -20100 then 
        d(SQLERRM,'ERROR ON_LOGON');
        raise; 
      end if;
      DEBUG_OUTPUT.SETSTATE(TRUE);
      d(tmpVar||' ON_LOGON '||SQLERRM,'ERROR ON_LOGON');
  END;
  COMMIT;
END;
/

----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.CheckReaction(Reaction IN VARCHAR2,
                                             Par IN SP.TGPAR)
-- Проверка реакции глобального параметра (SP-Sys.fnc)
AUTHID CURRENT_USER
IS
  cursor_name INTEGER;
BEGIN
  cursor_name := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name, 
  'DECLARE p SP.TGPAR; BEGIN p:=:1;'||Reaction||'END;',
   DBMS_SQL.NATIVE);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
EXCEPTION
  WHEN others THEN
  D('Pl/Sql '||Reaction ||' блок задан не корректно '||SQLERRM,
    'sp.CheckReaction');
    RAISE_APPLICATION_ERROR(-20003,
      'Pl/Sql '||Reaction ||' блок задан не корректно '||SQLERRM);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
END;
/

---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.SP_USER(
  -- Имя пользователя.
  UName IN VARCHAR2,
  -- зашифрованный пароль
  Psw IN VARCHAR2)
return VARCHAR2  
-- Создаём нового пользователя. Или меняем пользователю пароль.
-- Функция присваивает пользователю роль SP_USER_ROLE,
-- а также привилегии создании сессиии и соединения.
-- Если имя пользователя состоит только из латинских цифр и букв, 
-- то поднимаем регистр пользователя и создаём его без кавычек("").
-- Это даёт возможность выполнять соединение с базой,
-- набирая имя без учёта региста.
-- (SP-Sys.fnc).
AS
PRAGMA autonomous_transaction;
  S VARCHAR2(4000);
  Login VARCHAR2(60);
  tmpVar NUMBER;
BEGIN
  -- Если пользователь меняет не свой пароль и он не администратор,
  -- то вызываем перерывание.  
  IF G.notUpEQ(SP.TG.USERNAME,UName) and (NOT SP.TG.SP_Admin) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.SP_USER.  Привилегий недостаточно!');
  END IF;
  -- Выясняем, существует ли пользователь в базе данных.
  -- В IMan пользователи не отличаются регистром.
  SELECT COUNT(*) INTO tmpVar FROM ALL_USERS a 
    WHERE (Upper(a.USERNAME)=UPPER(UName));
  --d('count ='||tmpVar||' '||UName||' '||Psw,'SP.SP_USER');  
  -- Если имя пользователя состоит только из латинских букв и цифр,
  -- то поднимаем регистр. 
  -- Это позволит писать имя пользователя в строке соединения не обращая
  -- внимания на регистр. 
  if regexp_instr(UName,'[^A-Za-z0-9_]+') = 0 then
    Login := upper(UName);
  else
    Login := Uname;
  end if;
  -- Если пользователь существует, но написан в другом регистре,
  -- то удаляем пользователя.
  IF (tmpVar = 1) and (Login != Uname) THEN
    SELECT a.USERNAME INTO S FROM ALL_USERS a 
    WHERE (Upper(a.USERNAME)=UPPER(UName));
    S:='DROP USER "'||S||'"';
    EXECUTE IMMEDIATE(S);
    tmpVar:=0;
  END IF;
  -- Если пользователь отсутствует, то создаём,  
  IF tmpVar = 0 THEN
    BEGIN
      --d('создаём '||login||' '||SP.DPSW(Psw),'SP.SP_USER');  
      S:='CREATE USER "'||Login||'" IDENTIFIED BY "'||SP.DPSW(Psw)||'"';
      EXECUTE IMMEDIATE(S);
      S:='GRANT SP_USER_ROLE to "'||Login||'"';
      EXECUTE IMMEDIATE(S);
      S:='ALTER USER "'||Login||'" DEFAULT ROLE ALL';
      EXECUTE IMMEDIATE(S);
    EXCEPTION
      WHEN others THEN
        SP.TG.ResetFlags;
        d(SQLERRM,'ERROR SP.SP_USER');
        RAISE_APPLICATION_ERROR(-20033,
          'SP.SP_USER. Ошибка создания пользователя: ' ||Login);
    END;  
  -- Иначе изменяем пользователю пароль.  
  ELSE
    S:='ALTER USER "'||Login||'" IDENTIFIED BY "'||SP.DPSW(Psw)||'"';
    EXECUTE IMMEDIATE(S);
  END IF;
  -- Предоставляем возможность пользователю создавать сессию и присоединяться.
  S:='GRANT CONNECT to "'||Login||'"';
  EXECUTE IMMEDIATE(S);
  S:='GRANT CREATE SESSION to "'||Login||'"';
  EXECUTE IMMEDIATE(S);
  return Login;
END;
/
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.DROP_USER(UNAME IN VARCHAR2)
-- Удаляем пользователя. (SP-Sys.fnc)
AS
PRAGMA autonomous_transaction;
  SpUser VARCHAR2(60);
  S VARCHAR2(128);
  tmpVar NUMBER; 
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.DROP_USER. Привилегий недостаточно!');
  END IF;
  -- Если пользователя не существует, то выход.
  SELECT COUNT(*)INTO tmpVar FROM ALL_USERS a 
    WHERE upper(a.USERNAME)=upper(UNAME);
  IF tmpVar = 0 THEN RETURN; END IF;
  -- Если имя пользователя состоит только из латинских букв и цифр,
  -- то поднимаем регистр. 
  if regexp_instr(UName,'[^A-Za-z0-9_]+') = 0 then
    SpUser := upper(UName);
  else
    SpUser := Uname;
  end if;
  -- Закрыть все сессии данного пользователя.
  -- Потоки закроются при закрытии сессии после команды на закрытие сессии. 
  -- Сессия может удалиться не сразу, поэтому ждем и повторяем несколько раз.
  FOR i IN 1..5 
  LOOP
    SELECT COUNT(*) INTO tmpVar FROM V$SESSION s WHERE USERNAME=SpUser;
    IF tmpVar=0 THEN 
      -- Удаляем пользователя
      --d('Пытаемся удалить '||SpUser||'!','SP.DROP_USER');
      S:='DROP USER "'||SpUser||'" CASCADE';
      BEGIN
        EXECUTE IMMEDIATE(S);
        RETURN;
      EXCEPTION WHEN others THEN 
        d(SpUser||' '||SQLERRM,' ERROR in SP.DROP_USER');
      END;   
    END IF;
    FOR c IN 
      (SELECT TO_CHAR(s.SID)||','||TO_CHAR(s.serial#)SID FROM V$SESSION s
         WHERE USERNAME=SpUser)
    LOOP  
      S:='ALTER SYSTEM KILL SESSION '''||c.SID||''' IMMEDIATE';
      BEGIN          
      EXECUTE IMMEDIATE(S);
        EXCEPTION WHEN others THEN d(SQLERRM,' ERROR in SP.DROP_USER');
      END;
    END LOOP;
    SYS.DBMS_LOCK.sleep(1+(i-1)*5);
  END LOOP;  
  SP.TG.ResetFlags;
  RAISE_APPLICATION_ERROR(-20033,
    'SP.DROP_USER. Необходимо закрыть все сессии  пользователя: '||SpUser||'!');
END;
/

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.CHNG_PSW(
  -- имя пользователя, если параметр - равен нулл, то пользователь текущий
  NAME IN VARCHAR2,
  -- старый пароль
  OLD_PSW IN VARCHAR2,
  -- новый пароль
  NEW_PSW IN VARCHAR2,
  -- подтверждение пароля
  NEW_PSW1 IN VARCHAR2
  )
-- Замена пароля. (SP-Sys.fnc)
AS
  userName VARCHAR2(60);
  p VARCHAR2(128);
  tmpVar NUMBER;
BEGIN
  -- Если пользователь нулл, то это текущий пользователь.
  if NAME is null then
    if TG.USERNAME is null then
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,'SP.CHNG_PSW.'||
        ' Ошибка алгоритма TG.USERNAME is null!');
    end if; 
    userName := TG.USERNAME;
  else
    userName:=NAME;
  end if;  
  -- Если пользователь меняет не свой пароль или он не администратор,
  -- то вызываем перерывание.  
  -- d(SP.TG.USERNAME||'  '||userName,'SP.CHNG_PSW');
  IF G.notUpEQ(SP.TG.USERNAME,userName) and (NOT SP.TG.SP_Admin) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,'SP.CHNG_PSW. Привилегий недостаточно!');
  END IF;
  -- Если пароли не совпадают, то вызываем прерывание.
  IF G.notEQ(NEW_PSW, NEW_PSW1) THEN
    SP.TG.ResetFlags;
    RAISE_APPLICATION_ERROR(-20033,
      'SP.CHNG_PSW. Пароль и подтверждение не совпадают!');
  END IF;
  -- Если старый пароль не верен, то вызываем прерывание.
  begin
    select SP.DPSW(S_VALUE) into p from SP.V_USERS_GLOBALS 
      where upper(SP_USER) = upper(userName)
        and NAME = 'USER_PWD';
    --d(nvl(userNAME,'null')||', '||nvl(p,'null')||', '||
    --  nvl(NAME,'null')||', '||nvl(OLD_PSW,'null')||', '||
    --  nvl(NEW_PSW,'null')||', '||nvl(NEW_PSW1,'null')||'!',
    --  'SP.CHNG_PSW');
    IF p != OLD_PSW THEN
      SP.TG.ResetFlags;
      RAISE_APPLICATION_ERROR(-20033,
        'SP.CHNG_PSW. Старый пароль неверен!');
    END IF;
    -- Изменяем пароль пользователя.
    update SP.V_USERS_GLOBALS 
      set S_VALUE=SP.EPSW(NEW_PSW) 
      where upper(SP_USER) = upper(userName)
        and NAME = 'USER_PWD';
  exception 
    when no_data_found then 
      -- Если пароль пользователя не найден, то добавляем новый пароль в 
      -- глобальные параметры пользователя.
      select ID into tmpVar from SP.GLOBAL_PAR_S where name = 'USER_PWD';
      insert into SP.USERS_GLOBALS(GL_PAR_ID,SP_USER,S) 
        values(tmpVar, userNAME, SP.EPSW(NEW_PSW));
  end;        
EXCEPTION
  WHEN others THEN
    SP.TG.ResetFlags;
    d('Ошибка замены пароля у пользователя: '||
      nvl(userNAME,'null')||', '||nvl(p,'null')||', '||
      nvl(NAME,'null')||', '||nvl(OLD_PSW,'null')||', '||
      nvl(NEW_PSW,'null')||', '||nvl(NEW_PSW1,'null')||', '||SQLERRM||'!',
      'ERROR in SP.CHNG_PSW');
    RAISE_APPLICATION_ERROR(-20033,SQLERRM);
END;
/
GRANT EXECUTE ON SP.CHNG_PSW TO PUBLIC;


-------------------------------------------------------------------------------
-- CREATE OR REPLACE PROCEDURE SP.Data_Clear
-- -- .
-- -- Процедура удаляет данные, внесенные пользователем, из схемы SP
-- -- и тем самым подготавливает схему SP для импорта данных из схемы SP_IO.
-- -- (SP-Sys.fnc)
-- AS
-- BEGIN
--   IF NOT SP.TG.SP_ADMIN THEN 
--     RAISE_APPLICATION_ERROR(-20033,
--       'SP.Data_Clear. Привилегий недостаточно!');
--   END IF;
--   DELETE FROM SP.FORM_SIGN_S;
--   DELETE FROM SP.MODEL_OBJECTS  WHERE model_id >= 100;
--   DELETE FROM SP.MODELS           WHERE ID >= 100;
--   DELETE FROM SP.OBJECTS         WHERE ID >= 100;
--   DELETE FROM SP.MACROS;
--   DELETE FROM SP.USERS_GLOBALS   WHERE ID >= 100;
--   DELETE FROM SP.GLOBAL_PAR_S     WHERE ID >= 100;
--   DELETE FROM SP.ENUM_VAL_S         WHERE ID >= 100;
--   DELETE FROM SP.CATALOG_TREE;
--   DELETE FROM SP.SP_ROLES           WHERE ID >= 100;
--   DELETE FROM SP.PAR_TYPES     WHERE ID >= 1000;
--   DELETE FROM SP.REL_S     WHERE ID >= 100;
--   DELETE FROM SP.GROUPS     WHERE ID >= 100;
--   DELETE FROM SP.DOCS     WHERE ID >= 100;
-- END;
-- /
-- 
-- GRANT EXECUTE ON SP.Data_Clear TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.Data_Export
-- Процедура выгружает данные из схемы SP в схему SP_IO.
-- (SP-Sys.fnc)
AS
  Error SP.COMMANDS.COMMENTS%type;
BEGIN
  IF NOT SP.TG.SP_ADMIN THEN 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.Data_Export. Привилегий недостаточно!');
  END IF;
  d('Start','Datа_Export');
  SP.OUTPUT.RESET;
  SP.OUTPUT.ROLES;
  SP.OUTPUT.USERS;
  SP.OUTPUT.TYPES;
  d('ROLES,USERS, TYPES','Datа_Export');
  COMMIT; 
  SP.OUTPUT.Enums;
  SP.OUTPUT.Globals;
  SP.OUTPUT.GlobalValues;
  d('Enums, Globals, GlobalValues','Datа_Export');
  COMMIT; 
  SP.OUTPUT.CatalogTree;
  d('CatalogTree','Datа_Export');
  COMMIT; 
  SP.OUTPUT.Arrays;
  d('Arrays','Datа_Export');
  COMMIT; 
  SP.OUTPUT.DOCs;
  d('DOCs','Datа_Export');
  COMMIT; 
  SP.OUTPUT.Groups;
  d('Groups','Datа_Export');
  COMMIT; 
  SP.OUTPUT.CATALOG;
  d('CATALOG','Datа_Export');
  COMMIT; 
  SP.OUTPUT.MODEL;
  d('MODEL','Datа_Export');
  COMMIT; 
EXCEPTION  
  WHEN others THEN 
    ROLLBACK;
    Error:=SQLERRM; 
    d(Error,'Datа_Export');
    RAISE_APPLICATION_ERROR(-20000,
      'Экспорт данных завершился неудачно!!!'||
      ' ТРЕБУЕТСЯ разбор полёта перед обновлением базы!');
END;
/

GRANT EXECUTE ON SP.Data_Export TO PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.AllUserPRoles(UserRole in VARCHAR2) return VARCHAR2
-- возвращает перечень первичных ролей, полученных пользовательской ролью UserRole непосредственно или посредством других (агрегирующих) ролей  (SP-Sys.fnc)
AS
  OUT_Line VARCHAR2(1000);
BEGIN
 OUT_Line := '';
 for q in
 (
  SELECT DISTINCT Name, Parent 
  FROM
  (
    SELECT Name, Parent, CONNECT_BY_ISLEAF l
    FROM  SP.V_ROLES
    START WITH Parent = UserRole
    CONNECT by prior Name =  Parent
  )
   WHERE l = 1
   order by Name
 )
 LOOP
    OUT_Line := OUT_Line || ', ' || q.Name;
 END LOOP;
 --o(OUT_Line);
 SELECT SUBSTR(OUT_Line,2) into OUT_Line FROM DUAL;
 RETURN OUT_Line;
EXCEPTION
  WHEN no_data_found THEN
    RETURN 'NOT FOUND';  
  WHEN OTHERS THEN d(SQLERRM||'ERROR in SP.AllUserPRoles');
END;

/

GRANT EXECUTE ON SP.AllUserPRoles TO PUBLIC;



-------------------------------------------------------------------------------

-- CREATE OR REPLACE PROCEDURE SP.Data_Import
-- -- Процедура импортирует данные в схему SP из схемы SP_IO.
-- -- (SP-Sys.fnc)
-- AS
-- em SP.COMMANDS.COMMENTS%type;
-- BEGIN
--   IF NOT SP.TG.SP_ADMIN THEN 
--   RAISE_APPLICATION_ERROR(-20033,
--       'SP.Data_Export. Привилегий недостаточно!');
--   END IF;



-- END;
-- /
-- 
-- GRANT EXECUTE ON SP.Data_Import TO PUBLIC;

-- end of file

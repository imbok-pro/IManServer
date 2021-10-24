CREATE OR REPLACE PACKAGE BODY SP.C
-- C package body
-- пакет кэширования параметров объекта
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 10.05.2017
-- update 11.05.2017 08.08.2017 14.11.2017 15.11.2017 20.11.2017 22.11.2017
--        30.11.2017 03.12.2017 04.02.2019 21.07.2021

AS
curOBJ TOBJECTS;

-------------------------------------------------------------------------------
PROCEDURE setOBJECT(Object_ID in NUMBER)
is
begin
  setOBJECT(Object_ID, 1);
end setOBJECT;

-------------------------------------------------------------------------------
PROCEDURE setOBJECT(Object_ID in NUMBER, setKey in VARCHAR2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
  curOBJ(setKey) := Object_ID;
  DELETE FROM SP.MOD_OBJ_PARS_CACHE where set_key = setKey;
  insert into SP.MOD_OBJ_PARS_CACHE
  (
    ID,
    MOD_OBJ_ID,
    NAME,
    OBJ_PAR_ID,
    R_ONLY,
    TYPE_ID,
    E_VAL,
    N,
    D,
    S,
    X,
    Y,
    M_DATE,
    M_USER,
    set_key
  )
  select 
    ID,
    MOD_OBJ_ID,
    NAME,
    OBJ_PAR_ID,
    R_ONLY_ID,
    TYPE_ID,
    E_VAL,
    N,
    D,
    S,
    X,
    Y,
    M_DATE,
    M_USER, 
    setKey
  from 
  (
     WITH mod_objects
          AS (SELECT ID, OBJ_ID
                FROM SP.MODEL_OBJECTS m
               WHERE  (ID = Object_ID)
                  AND(   
                        (m.USING_ROLE IS NULL)
                     OR (SP.S_isUserAdmin = 1)
                     OR (m.USING_ROLE IN (SELECT ROLE_ID FROM SP.USER_ROLES)))),
          obj_pars
          AS (SELECT ID, OBJ_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y
                FROM SP.OBJECT_PAR_S cp
                where  UPPER (cp.NAME) NOT IN ('NAME',
                                               'PARENT',
                                               'POID',
                                               'OID',
                                               'ID',
                                               'PID',
                                               'USING_ROLE',
                                               'EDIT_ROLE')
                                              ),            
         mod_obj_pars
         AS (SELECT ID, OBJ_PAR_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y,
                     MOD_OBJ_ID, M_DATE, M_USER
                FROM SP.MODEL_OBJECT_PAR_S mp
                where  mp.MOD_OBJ_ID = Object_ID)
     SELECT mp.ID ID,
            NVL (mo.ID, mp.MOD_OBJ_ID) MOD_OBJ_ID,
            NVL (mp.NAME, cp.NAME) NAME,
            cp.ID OBJ_PAR_ID,
            NVL2 (mp.ID, mp.R_ONLY, cp.R_ONLY) R_ONLY_ID,
            NVL2 (mp.ID, mp.TYPE_ID, cp.TYPE_ID) TYPE_ID,
            NVL2 (mp.ID, mp.E_VAL, cp.E_VAL) E_VAL,
            NVL2 (mp.ID, mp.N, cp.N) N,
            NVL2 (mp.ID, mp.D, cp.D) D,
            NVL2 (mp.ID, mp.S, cp.S) S,
            NVL2 (mp.ID, mp.X, cp.X) X,
            NVL2 (mp.ID, mp.Y, cp.Y) Y,
            mp.M_DATE,
            mp.M_USER
       FROM mod_objects mo
            INNER JOIN obj_pars cp
               ON     cp.OBJ_ID = mo.OBJ_ID
            FULL JOIN mod_obj_pars mp
               ON mp.MOD_OBJ_ID = mo.ID AND mp.OBJ_PAR_ID = cp.ID
  );
  COMMIT;
end setOBJECT;

-------------------------------------------------------------------------------
PROCEDURE addOBJECT(Object_ID in NUMBER, setKey in VARCHAR2)
is
begin
  curOBJ(setKey) := Object_ID;
  DELETE FROM SP.MOD_OBJ_PARS_CACHE where set_key = setKey;
  insert into SP.MOD_OBJ_PARS_CACHE
  (
    ID,
    MOD_OBJ_ID,
    NAME,
    OBJ_PAR_ID,
    R_ONLY,
    TYPE_ID,
    E_VAL,
    N,
    D,
    S,
    X,
    Y,
    M_DATE,
    M_USER,
    set_key
  )
  select 
    ID,
    MOD_OBJ_ID,
    NAME,
    OBJ_PAR_ID,
    R_ONLY_ID,
    TYPE_ID,
    E_VAL,
    N,
    D,
    S,
    X,
    Y,
    M_DATE,
    M_USER, 
    setKey
  from 
  (
     WITH mod_objects
          AS (SELECT ID, OBJ_ID
                FROM SP.MODEL_OBJECTS m
               WHERE  (ID = Object_ID)
                  AND(   
                        (m.USING_ROLE IS NULL)
                     OR (SP.S_isUserAdmin = 1)
                     OR (m.USING_ROLE IN (SELECT ROLE_ID FROM SP.USER_ROLES)))),
          obj_pars
          AS (SELECT ID, OBJ_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y
                FROM SP.OBJECT_PAR_S cp
                where  UPPER (cp.NAME) NOT IN ('NAME',
                                               'PARENT',
                                               'POID',
                                               'OID',
                                               'ID',
                                               'PID',
                                               'USING_ROLE',
                                               'EDIT_ROLE')
                                              ),            
         mod_obj_pars
         AS (SELECT ID, OBJ_PAR_ID, R_ONLY, TYPE_ID, E_VAL, NAME, N, D, S, X, Y,
                     MOD_OBJ_ID, M_DATE, M_USER
                FROM SP.MODEL_OBJECT_PAR_S mp
                where  mp.MOD_OBJ_ID = Object_ID)
     SELECT mp.ID ID,
            NVL (mo.ID, mp.MOD_OBJ_ID) MOD_OBJ_ID,
            NVL (mp.NAME, cp.NAME) NAME,
            cp.ID OBJ_PAR_ID,
            NVL2 (mp.ID, mp.R_ONLY, cp.R_ONLY) R_ONLY_ID,
            NVL2 (mp.ID, mp.TYPE_ID, cp.TYPE_ID) TYPE_ID,
            NVL2 (mp.ID, mp.E_VAL, cp.E_VAL) E_VAL,
            NVL2 (mp.ID, mp.N, cp.N) N,
            NVL2 (mp.ID, mp.D, cp.D) D,
            NVL2 (mp.ID, mp.S, cp.S) S,
            NVL2 (mp.ID, mp.X, cp.X) X,
            NVL2 (mp.ID, mp.Y, cp.Y) Y,
            mp.M_DATE,
            mp.M_USER
       FROM mod_objects mo
            INNER JOIN obj_pars cp
               ON     cp.OBJ_ID = mo.OBJ_ID
            FULL JOIN mod_obj_pars mp
               ON mp.MOD_OBJ_ID = mo.ID AND mp.OBJ_PAR_ID = cp.ID
  );
end addOBJECT;

-------------------------------------------------------------------------------
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return SP.TMPAR
is
begin
  return getMPAR(NAME, Object_ID, 1);
end getMPAR;

-------------------------------------------------------------------------------
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return SP.TMPAR
is
p SP.TMPAR;
rp SP.MOD_OBJ_PARS_CACHE%rowtype;
pNAME SP.MOD_OBJ_PARS_CACHE.NAME%type;
crp number;
begin
  if not curOBJ.exists(setKey) then
    curOBJ(setKey) := null;
  end if;
  if curOBJ(setKey) is null and Object_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      ' ERROR in SP.C.getMPAR. Объект не определён!');
  end if;
  if Object_ID is not null and G.notEQ(curOBJ(setKey), Object_ID) then
    setOBJECT(Object_ID, setKey);  
  end if;
  pNAME := NAME;
--  ---DEBUG----------------------------------------------------------------------
--  select count(*) into crp from SP.MOD_OBJ_PARS_CACHE 
--    where UPPER(NAME) = upper(pNAME)
--      and SET_KEY = setKey;
--    If crp>1 Then
--      d('Нарушение уникальности: обнаружено повторений = '|| crp
--      ||' сочетания setKey ['||setKey||'] upper(pNAME) ['||upper(pNAME)
--      ||'], Object_ID = '||Object_ID
--      , 'C.getMPar');
--
--      For rr In ( select * from SP.MOD_OBJ_PARS_CACHE 
--                  where UPPER(NAME) = upper(pNAME)
--                 and SET_KEY = setKey
--      ) Loop
--        d('setKey ['||rr.SET_KEY||'], NAME ['||rr.NAME||'], S ['||rr.S
--        ||'], MOD_OBJ_ID ='||rr.MOD_OBJ_ID||', ID ='||rr.ID
--        ||', OBJ_PAR_ID ='||rr.OBJ_PAR_ID
--        , 'C.getMPar');
--      End Loop;
--    End If;
--    --------------------------------------------------------------DEBUG---------
  select count(*) into crp from SP.MOD_OBJ_PARS_CACHE 
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
--  d('crp '||crp, 'C.getMPar');    
--  d('setKey '||setKey||to_.str|| 
--    ' upper(pNAME) '||upper(pNAME)||to_.str
--    , 'C.getMPar');    
  select * into rp from SP.MOD_OBJ_PARS_CACHE 
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
--  d('rp.MOD_OBJ_ID '||rp.MOD_OBJ_ID||to_.str|| 
--    ' rp.OBJ_PAR_ID '||rp.OBJ_PAR_ID||to_.str
--    , 'C.getMPar');    
  p := SP.TMPAR
  (
    MO_ID => rp.MOD_OBJ_ID,
    MP_ID => rp.ID,
    CP_ID => rp.OBJ_PAR_ID,
    G_ID => rp.G_ID,
    NAME => rp.NAME, 
    R_ONLY => rp.R_ONLY,
    VAL => SP.TVALUE
    (
      T => rp.TYPE_ID,
      COMMENTS => null,
      R_ONLY => rp.R_ONLY,
      E => rp.E_VAL,
      N => rp.N,
      D => rp.D,
      S => rp.S,
      X => rp.X,
      Y => rp.Y
    ),
    MDATE => rp.M_DATE,
    MUSER => rp.M_USER,
    NEW_MDATE =>null,
    NEW_MUSER =>null
  );
  return p;
exception 
  when no_data_found then
    case NAME
      when 'NAME' then
        p:= SP.TMPAR(curOBJ(setKey), 'NAME');
      when 'PARENT' then
        p:= SP.TMPAR(curOBJ(setKey), 'PARENT');
      when 'POID' then
        p:= SP.TMPAR(curOBJ(setKey), 'POID');
      when 'OID' then
        p:= SP.TMPAR(curOBJ(setKey), 'OID');
      when 'ID' then
        p:= SP.TMPAR(curOBJ(setKey), 'ID');
      when 'PID' then
        p:= SP.TMPAR(curOBJ(setKey), 'PID');
      when 'USING_ROLE' then
        p:= SP.TMPAR(curOBJ(setKey), 'USING_ROLE');
      when 'EDIT_ROLE' then
        p:= SP.TMPAR(curOBJ(setKey), 'EDIT_ROLE');
    else
--      d('вставляем пустой параметр ', 'C.getMPar');    
      p := SP.TMPAR
      (
        MO_ID => curOBJ(setKey),
        MP_ID => null,
        CP_ID => null,
        G_ID => null,
        NAME => pNAME, 
        R_ONLY => 0,
        VAL => SP.TVALUE
        (
          T => G.TNoValue,
          COMMENTS => null,
          R_ONLY => 0,
          E => null,
          N => null,
          D => null,
          S => null,
          X => null,
          Y => null
        ),
        MDATE => null,
        MUSER => null,
        NEW_MDATE =>null,
        NEW_MUSER =>null
      );
    end case; 
    return p; 
end getMPAR;  

-------------------------------------------------------------------------------
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2
is
begin
  return getMPAR_E(NAME, Object_ID, 1);
end getMPAR_E;

-------------------------------------------------------------------------------
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2
is
tmpVar VARCHAR(4000);
pNAME SP.MOD_OBJ_PARS_CACHE.NAME%type;
begin
  if not curOBJ.exists(setKey) then
    curOBJ(setKey) := null;
  end if;
  if curOBJ(setKey) is null and Object_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      ' ERROR in SP.C.getMPAR_E. Объект не определён!');
  end if;
  if Object_ID is not null and G.notEQ(curOBJ(setKey), Object_ID) then
    setOBJECT(Object_ID, setKey);  
  end if;
  pNAME := NAME;
  select E_VAL into tmpVar from SP.MOD_OBJ_PARS_CACHE
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
  return tmpVar;
exception 
  when no_data_found then
    if NAME in ('NAME',
                'PARENT',
                'POID',
                'OID',
                'ID',
                'PID',
                'USING_ROLE',
                'EDIT_ROLE')
    then 
      return null;
    else             
      RAISE_APPLICATION_ERROR(-20033,
        ' ERROR in SP.C.getMPAR_E. Параметр с именем '||NAME
        ||' не найден у объекта '||curOBJ(setKey)||'!');
    end if;    
end getMPAR_E;  

-------------------------------------------------------------------------------
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2
is
begin
  return getMPAR_S(NAME, Object_ID, 1);
end getMPAR_S;

-------------------------------------------------------------------------------
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2
is
tmpVar VARCHAR(4000);
pNAME SP.MOD_OBJ_PARS_CACHE.NAME%type;
begin
  if not curOBJ.exists(setKey) then
    curOBJ(setKey) := null;
  end if;
  if curOBJ(setKey) is null and Object_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      ' ERROR in SP.C.getMPAR_S. Объект не определён!');
  end if;
  if Object_ID is not null and G.notEQ(curOBJ(setKey), Object_ID) then
    setOBJECT(Object_ID, setKey);  
  end if;
  pNAME := NAME;
  select S into tmpVar from SP.MOD_OBJ_PARS_CACHE 
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
  return tmpVar;
exception 
  when no_data_found then
    begin
    case NAME
      when 'NAME' then
        select MOD_OBJ_NAME into tmpVar from SP.MODEL_OBJECTS 
          where ID = curOBJ(setKey);
      when 'PARENT' then
        tmpVar := SP.PATHS.PATH(SP.MO.FULL_NAME(curOBJ(setKey)));
      when 'POID' then
        select p.OID into tmpVar 
          from SP.MODEL_OBJECTS o, SP.MODEL_OBJECTS p 
          where o.ID = curOBJ(setKey)
            and p.ID = O.PARENT_MOD_OBJ_ID;
      when 'OID' then
        select OID into tmpVar 
          from SP.MODEL_OBJECTS o
          where o.ID = curOBJ(setKey);
      when 'ID' then
        tmpVar := null;
      when 'PID' then
        tmpVar := null;
      when 'USING_ROLE' then
        tmpVar := null;
      when 'EDIT_ROLE' then
        tmpVar := null;
    else
      RAISE_APPLICATION_ERROR(-20033,
        ' ERROR in SP.C.getMPAR_S. Параметр с именем '||NAME||
        ' не найден у объекта '||curOBJ(setKey)||'!');
    end case;
    exception 
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          ' ERROR in SP.C.getMPAR_S. Ошибка запроса параметра '||NAME||' у объекта '||
          nvl(to_char(curOBJ(setKey)), 'null')||'!');
    end;  
end getMPAR_S;  

-------------------------------------------------------------------------------
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return DATE
is
begin
  return getMPAR_D(NAME, Object_ID, 1);
end getMPAR_D;

-------------------------------------------------------------------------------
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return DATE
is
tmpVar DATE;
pNAME SP.MOD_OBJ_PARS_CACHE.NAME%type;
begin
  if not curOBJ.exists(setKey) then
    curOBJ(setKey) := null;
  end if;
  if curOBJ(setKey) is null and Object_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      ' ERROR in SP.C.getMPAR_D. Объект не определён!');
  end if;
  if Object_ID is not null and G.notEQ(curOBJ(setKey), Object_ID) then
    setOBJECT(Object_ID, setKey);  
  end if;
  pNAME := NAME;
  select D into tmpVar from SP.MOD_OBJ_PARS_CACHE
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
  return tmpVar;
exception 
  when no_data_found then
    if NAME in ('NAME',
                'PARENT',
                'POID',
                'OID',
                'ID',
                'PID',
                'USING_ROLE',
                'EDIT_ROLE')
    then 
      return null;
    else             
      RAISE_APPLICATION_ERROR(-20033,
        ' ERROR in SP.C.getMPAR_D. Параметр с именем '||NAME||' не найден у объекта '||
        curOBJ(setKey)||'!');
    end if;    
end getMPAR_D;  

-------------------------------------------------------------------------------
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return NUMBER
is
begin
  return getMPAR_N(NAME, Object_ID, 1);
end getMPAR_N;

-------------------------------------------------------------------------------
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return NUMBER
is
tmpVar NUMBER;
pNAME SP.MOD_OBJ_PARS_CACHE.NAME%type;
begin
  if not curOBJ.exists(setKey) then
    curOBJ(setKey) := null;
  end if;
  if curOBJ(setKey) is null and Object_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      ' ERROR in SP.C.getMPAR_N. Объект не определён!');
  end if;
  if Object_ID is not null and G.notEQ(curOBJ(setKey), Object_ID) then
    setOBJECT(Object_ID, setKey);  
  end if;
  pNAME := NAME;
  select N into tmpVar from SP.MOD_OBJ_PARS_CACHE 
    where UPPER(NAME) = upper(pNAME)
      and SET_KEY = setKey;
  return tmpVar;
exception 
  when no_data_found then
    begin
    case NAME
      when 'NAME' then
        tmpVar := null;
      when 'PARENT' then
        tmpVar := null;
      when 'POID' then
        tmpVar := null;
      when 'OID' then
        tmpVar := null;
      when 'ID' then
        tmpVar := curOBJ(setKey);
      when 'PID' then
        select PARENT_MOD_OBJ_ID into tmpVar from SP.MODEL_OBJECTS 
          where ID = curOBJ(setKey);
      when 'USING_ROLE' then
        select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
          where ID = curOBJ(setKey);
      when 'EDIT_ROLE' then
        select EDIT_ROLE into tmpVar from SP.MODEL_OBJECTS 
          where ID = curOBJ(setKey);
    else
      RAISE_APPLICATION_ERROR(-20033,
        ' ERROR in SP.C.getMPAR_N. Параметр с именем '||NAME||
        ' не найден у объекта '||curOBJ(setKey)||'!');
    end case;
    exception 
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          ' ERROR in SP.C.getMPAR_N. Ошибка запроса параметра '||NAME||
          ' у объекта '||nvl(to_char(curOBJ(setKey)), 'null')||'!');
    end;  
end getMPAR_N;  

END C;  

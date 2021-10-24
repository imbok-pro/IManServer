-- SP Model Views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 14.10.2010 28.10.2010 23.11.2010 16.12.2010 12.01.2010 10.11.2011
--        24.11.2011 09.12.2011 15.12.2011 17.01.2012 18.01.2012 16.03.2012
--        03.04.2013 09.04.2013 22.08.2013 24.08.2013 16.01.2013 13.02.2014
--        14.06.2014 20.06.2014 25.06.2014 02.07.2014 10.07.2014 10.10.2014
--        26.11.2014 01.12.2014 16.02.2015 19.02.2015 31.03.2015 17.05.2015
--        05.10.2015 25.02.2016 11.08.2016 19.10.2016 27.10.2016 28.10.2016
--        12.01.2017 10.02.2017 03.05.2017 11.11.2020 24.01.2021 09.04.2021
--        08.09.2021 15.09.2021

-- Модели.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_MODELS
(ID,
 SITE,
 PLANT,
 MODEL_NAME,
 MODEL_COMMENTS,
 PERSISTENT,
 LOCAL,
 USING_ROLE_ID,
 USING_ROLE_NAME,
 M_DATE,
 M_USER)
AS 
 SELECT 
   ID,
   case
     when instr(NAME,'||') > 0 then
       substr(NAME,1,instr(NAME,'||')-1)
     else
       ''
   end AS SITE,        
   case
     when instr(NAME,'||') > 0 then
       substr(NAME,instr(NAME,'||')+2)
     else
       NAME
   end AS PLANT,        
   NAME AS MODEL_NAME, 
   COMMENTS AS MODEL_COMMENTS,
   PERSISTENT,
   LOCAL,
   USING_ROLE USING_ROLE_ID,
   (select Name from SP.SP_ROLES where ID = USING_ROLE  ) USING_ROLE_NAME, 
   M_DATE, M_USER
   FROM SP.MODELS sm 
     where  SP.S_HasUserRoleID(USING_ROLE)=1
   ;

GRANT ALL ON SP.V_MODELS TO "SP_ADMIN_ROLE";
GRANT SELECT ON SP.V_MODELS TO PUBLIC;

COMMENT ON TABLE SP.V_MODELS IS 'Модели. (SP-Model-Views.vw)';

COMMENT ON COLUMN SP.V_MODELS.SITE IS 'Имя сервера моделей или некоторой общности локальных моделей.';
COMMENT ON COLUMN SP.V_MODELS.PLANT IS 'Имя модели конкретного объекта.';
COMMENT ON COLUMN SP.V_MODELS.USING_ROLE_NAME IS 'Имя роли модели.';


BEGIN
 cc.fT:='MODELS';
 cc.tT:='V_MODELS';
 cc.c('ID','ID');
 cc.c('NAME','MODEL_NAME');
 cc.c('COMMENTS','MODEL_COMMENTS');
 cc.c('PERSISTENT','PERSISTENT');
 cc.c('LOCAL','LOCAL');
 cc.c('USING_ROLE','USING_ROLE_ID');
 cc.c('M_DATE','M_DATE');
 cc.c('M_USER','M_USER');
END;
/

-- Объекты моделей.
-------------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW SP.V_MODEL_OBJECTS
(ID, 
 OID, 
 PARENT_MOD_OBJ_ID, 
 POID, 
 OBJ_ID, 
 MODEL_ID,
 MODEL_NAME, 
 MOD_OBJ_NAME, 
 PATH, 
 FULL_NAME, 
 OBJ_LEVEL, 
 KIND, 
 KIND_ID, 
 CATALOG_NAME,
 CATALOG_GROUP_NAME, 
 CATALOG_COMMENTS, 
 USING_ROLE_NAME,
 USING_ROLE_ID,
 EDIT_ROLE_NAME,
 EDIT_ROLE_ID,
 M_DATE,
 M_USER)
AS 
SELECT 
  mo.ID, 
  mo.OID, 
  mo.PARENT_MOD_OBJ_ID, 
  pmo.OID POID, 
  mo.OBJ_ID, 
  mo.MODEL_ID,
	mm.NAME MODEL_NAME, 
  mo.MOD_OBJ_NAME, 
  SP.Paths.Path(SP.MO.FULL_NAME(mo.ID)) PATH, 
  SP.MO.FULL_NAME(mo.ID) FULL_NAME, 
  to_char(SP.Paths.Lev(SP.MO.FULL_NAME(mo.ID))) OBJ_LEVEL, 
  SP.to_str_Obj_Kind(o.OBJECT_KIND) KIND,
  o.OBJECT_KIND KIND_ID, 
  o.NAME CATALOG_NAME, 
  g.NAME CATALOG_GROUP_NAME, 
  o.COMMENTS CATALOG_COMMENTS, 
  ur.NAME,
  mo.USING_ROLE,
  er.NAME,
  mo.EDIT_ROLE,
  mo.M_DATE, 
  mo.M_USER 
FROM SP.MODELS mm, SP.MODEL_OBJECTS mo, SP.MODEL_OBJECTS pmo,
     SP.OBJECTS o, SP.GROUPS g,
     SP.SP_ROLES ur, SP.SP_ROLES er
WHERE g.ID = o.GROUP_ID
  and mm.ID = mo.MODEL_ID   
  and (   (mm.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (SP.S_HasUserRoleID(mm.USING_ROLE) = 1)
      )
  and mo.OBJ_ID=o.ID
  and mo.PARENT_MOD_OBJ_ID = pmo.ID(+)
  and mo.USING_ROLE = ur.ID(+) 
  and mo.EDIT_ROLE = er.ID(+) 
  and (   (mo.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (SP.S_HasUserRoleID(mm.USING_ROLE) = 1)
      )
;


-- Триггера представления сопоставляют роли пользователя с ролями объектов. 
GRANT ALL ON SP.V_MODEL_OBJECTS TO PUBLIC;

COMMENT ON TABLE SP.V_MODEL_OBJECTS IS 'Объекты модели. (SP-Model-Views.vw)';

BEGIN
 cc.fT:='OBJECTS';
 cc.tT:='V_MODEL_OBJECTS';
 cc.c('OBJECT_KIND','KIND_ID');
 
 cc.fT:='MODELS';
 cc.tT:='V_MODEL_OBJECTS';
 cc.c('NAME','MODEL_NAME'); 
 cc.c('ID','MODEL_ID'); 
 
 cc.fT:='MODEL_OBJECTS';
 cc.tT:='V_MODEL_OBJECTS';
 cc.c('ID','ID');  
 cc.c('OID','OID');  
 cc.c('PARENT_MOD_OBJ_ID','PARENT_MOD_OBJ_ID');  
 cc.c('OBJ_ID','OBJ_ID'); 
 cc.c('USING_ROLE','USING_ROLE_NAME'); 
 cc.c('EDIT_ROLE','EDIT_ROLE_NAME'); 
 cc.c('M_DATE','M_DATE'); 
 cc.c('M_USER','M_USER'); 
END; 
/

COMMENT ON COLUMN SP.V_MODEL_OBJECTS.PATH IS 'Полный путь к объекту модели.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.MOD_OBJ_NAME IS 'Имя объекта модели. Может быть присвоено генератором имён. При добавлении, изменении или удалении объекта можно использовать полное имя объекта, включающее в себя путь. Если используется полное имя, то путь игнорируется. Можно также использовать относительное имя. В этом случае оно соединяется с полем "PATH".';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.KIND IS 'Описание вида объекта.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.OBJ_LEVEL IS 'Уровень вложенности объекта.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.POID IS 'Сторонний уникальный идентификаторродителя.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.CATALOG_NAME IS 'Имя объекта каталога.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.CATALOG_GROUP_NAME IS 'Имя группы объекта каталога. Уникальными в каталоге, является пара "имя группы"+"имя объекта".';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.CATALOG_COMMENTS 
  IS 'Описание объекта каталога.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.FULL_NAME 
  IS 'Полное имя объекта модели.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.USING_ROLE_ID 
  IS 'Идентификатор роли использования объекта модели.';
COMMENT ON COLUMN SP.V_MODEL_OBJECTS.EDIT_ROLE_ID 
  IS 'Идентификатор роли изменения объекта модели.';

-- Объекты текущей модели, относительно текущего опорного объекта.
-------------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW SP.V_CUR_MODEL_OBJECTS
(ID,
 OID,
 PARENT_MOD_OBJ_ID, 
 POID, 
 OBJ_ID, 
 MOD_OBJ_NAME,
 PATH,
 FULL_NAME,
 OBJ_LEVEL,
 KIND, 
 KIND_ID,
 CATALOG_NAME, 
 CATALOG_FULL_NAME, 
 CATALOG_COMMENTS, 
 M_DATE,
 M_USER)
AS 
SELECT 
  nvl(mo.ID,1),
  mo.OID, 
  case 
    when mo.ID is null 
    then null
    else  nvl(mo.PARENT_MOD_OBJ_ID,1)
  end PARENT_MOD_OBJ_ID, 
  pmo.OID POID, 
  mo.OBJ_ID, 
  mo.MOD_OBJ_NAME, 
  SP.Paths.Path(mo.FULL_NAME) PATH,
  mo.FULL_NAME FULL_NAME, 
  to_char(mo.OBJ_LEVEL) OBJ_LEVEL, 
  o.KIND KIND, o.KIND_ID KIND_ID, 
  o.SHORT_NAME CATALOG_NAME, 
  o.FULL_NAME CATALOG_FULL_NAME, 
  o.COMMENTS CATALOG_COMMENTS, 
  mo.M_DATE,
  mo.M_USER 
FROM (select rownum RN, q.* from TABLE(SP.MO.CUR_MODEL_OBJECTS())q) mo,
     SP.MODEL_OBJECTS pmo, SP.V_OBJECTS o 
WHERE mo.OBJ_ID=o.ID
  and mo.PARENT_MOD_OBJ_ID = pmo.ID(+)
ORDER BY RN   
;


GRANT ALL ON SP.V_CUR_MODEL_OBJECTS TO "SP_ADMIN_ROLE";
GRANT SELECT, UPDATE, INSERT, DELETE ON SP.V_CUR_MODEL_OBJECTS TO PUBLIC;

COMMENT ON TABLE SP.V_CUR_MODEL_OBJECTS 
  IS 'Объекты текущей модели с учётом опорного объекта и прав пользователя. (SP-Model-Views.vw)';

BEGIN
 cc.fT:='OBJECTS';
 cc.tT:='V_CUR_MODEL_OBJECTS';
 cc.c('OBJECT_KIND','KIND_ID');
 
 cc.fT:='MODEL_OBJECTS';
 cc.tT:='V_CUR_MODEL_OBJECTS';
-- cc.c('ID','ID');  
 cc.c('OID','OID');  
-- cc.c('PARENT_MOD_OBJ_ID','PARENT_MOD_OBJ_ID');  
 cc.c('OBJ_ID','OBJ_ID'); 
 cc.c('M_DATE','M_DATE'); 
 cc.c('M_USER','M_USER'); 
END; 
/

COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.PATH IS 'Полный путь объекта.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.MOD_OBJ_NAME IS 'Имя объекта модели. Может быть присвоено генератором имён. При добавлении, изменении или удалении объекта можно использовать полное имя объекта, включающее в себя путь. Если используется полное имя, то путь игнорируется. Можно также использовать относительное имя. В этом случае оно соединяется с полем "PATH".';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.KIND IS 'Описание вида объекта.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.OBJ_LEVEL IS 'Уровень вложенности объекта.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.POID IS 'Сторонний уникальный идентификатор родителя.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.ID IS 'Уникальный идентификатор объекта. В отличие от других представлений и таблиц идентификатор корня иерархии не нулл, а "1"';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.PARENT_MOD_OBJ_ID IS 'Уникальный идентификатор родителя объекта. В отличие от других представлений и таблиц идентификатор корня иерархии не нулл, а "1"';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.CATALOG_NAME IS 'Имя объекта каталога.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.CATALOG_FULL_NAME IS 'Полное имя объекта каталога (с учётом его группы).';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.CATALOG_COMMENTS 
  IS 'Описание объекта каталога.';
COMMENT ON COLUMN SP.V_CUR_MODEL_OBJECTS.FULL_NAME 
	IS 'Полное имя объекта модели.';

  
-------------------------------------------------------------------------------  
CREATE OR REPLACE FUNCTION SP.CPAR_DEF_S(objID in NUMBER, pNAME in VARCHAR2)
RETURN VARCHAR2
-- Функция возвращает поле "S" значения по умолчанию для параметра объекта каталога, определённого именем и ссылкой на объект каталога.
-- (SP-Model-Views.vw)
AS
tmpVar NUMBER;
tmpS SP.COMMANDS.COMMENTS%type; 
BEGIN
  select TYPE_ID, S into tmpVar, tmpS from SP.OBJECT_PAR_S 
    where upper(NAME) = upper(pNAME)
      and OBJ_ID = objID;
  IF tmpVar = G.TSTR4000 then RETURN tmpS; end if;
  return '';
EXCEPTION
  when no_data_found then return '';
END;
/
--GRANT EXECUTE ON SP.CPAR_DEF_S TO PUBLIC;

-------------------------------------------------------------------------------  
CREATE OR REPLACE FUNCTION SP.CPAR_DEF_RoleName(objID in NUMBER,
                                                pNAME in VARCHAR2)
RETURN VARCHAR2
-- Функция возвращает имя роли по умолчанию для объекта модели, если таковая определена в каталоге для прообраза объекта, определённого именем и ссылкой на объект каталога.
-- (SP-Model-Views.vw)
AS
tmpVar NUMBER;
tmpS VARCHAR2(60); 
BEGIN
  select p.TYPE_ID, r.NAME into tmpVar, tmpS 
    from SP.OBJECT_PAR_S p, SP.SP_ROLES r  
    where upper(p.NAME) = upper(pNAME)
      and p.OBJ_ID = objID
      and p.N = r.ID;
  IF tmpVar = G.TRole then RETURN tmpS; end if;
  return '';
EXCEPTION
  when no_data_found then return '';
END;
/
--GRANT EXECUTE ON SP.CPAR_DEF_S TO PUBLIC;

-- Параметры объектов моделей.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_MODEL_OBJECT_PARS
(ID, OBJ_ID, PARAM_NAME,
 OBJ_PAR_ID, MOD_OBJ_ID,
 TYPE_ID, TYPE_NAME, 
 R_ONLY_ID, R_ONLY, 
 VALUE_ENUM,SET_OF_VALUES,
 D_VAL, 
 VAL, 
 E_VAL,N,D,S,X,Y,
 ISREDEFINE,
 M_DATE, M_USER)
AS 
with mod_objects as
(select * from SP.MODEL_OBJECTS m
    where (m.USING_ROLE is null)
       or (SP.S_isUserAdmin = 1)
       or (m.USING_ROLE in (select ROLE_ID from SP.USER_ROLES)))
select
  mp.ID,
  mo.OBJ_ID,
  NVL (mp.NAME, cp.NAME) PARAM_NAME,
  cp.ID OBJ_PAR_ID,
  mo.ID MOD_OBJ_ID,
  nvl2(mp.ID, mp.TYPE_ID, cp.TYPE_ID) TYPE_ID,
  SP.to_strTYPE (nvl2(mp.ID, mp.TYPE_ID, cp.TYPE_ID)) TYPE_NAME,
  nvl2(mp.ID, mp.R_ONLY, cp.R_ONLY) R_ONLY_ID,
  SP.to_strR_ONLY (nvl2(mp.ID, mp.R_ONLY, cp.R_ONLY)) R_ONLY,
  SP.S_IS_ENUM_TYPE (nvl2(mp.ID, mp.TYPE_ID, cp.TYPE_ID)) VALUE_ENUM,
  SP.S_TYPE_HAS_SET_OF_VALUES (nvl2(mp.ID, mp.TYPE_ID, cp.TYPE_ID))
    SET_OF_VALUES,
  SP.Val_to_str (SP.TVALUE (nvl(cp.TYPE_ID, 15),
                                  NULL,
                                  0,
                                  cp.E_VAL,
                                  cp.N,
                                  cp.D,
                                  cp.S,
                                  cp.X,
                                  cp.Y))
    D_VAL,
  NVL2( mp.ID,
        SP.Val_to_str (SP.TVALUE (nvl(mp.TYPE_ID, 15),
                                  NULL,
                                  0,
                                  mp.E_VAL,
                                  mp.N,
                                  mp.D,
                                  mp.S,
                                  mp.X,
                                  mp.Y)),
        SP.Val_to_str (SP.TVALUE (nvl(cp.TYPE_ID, 15),
                                  NULL,
                                  0,
                                  cp.E_VAL,
                                  cp.N,
                                  cp.D,
                                  cp.S,
                                  cp.X,
                                  cp.Y)))
    VAL,
  NVL2 (mp.ID, mp.E_VAL, cp.E_VAL) E_VAL,
  NVL2 (mp.ID, mp.N, cp.N) N,
  NVL2 (mp.ID, mp.D, cp.D) D,
  NVL2 (mp.ID, mp.S, cp.S) S,
  NVL2 (mp.ID, mp.X, cp.X) X,
  NVL2 (mp.ID, mp.Y, cp.Y) Y,
  NVL2 (mp.ID, 1, 0) AS IsRedefine,
  mp.M_DATE,
  mp.M_USER
  FROM mod_objects mo 
  INNER JOIN SP.OBJECT_PAR_S cp
  ON cp.OBJ_ID=mo.OBJ_ID
  AND UPPER (cp.NAME) NOT IN ('NAME',
                              'PARENT',
                              'POID',
                              'OID',
                              'ID',
                              'PID',
                              'USING_ROLE',
                              'EDIT_ROLE')
 LEFT JOIN SP.MODEL_OBJECT_PAR_S mp 
  ON mp.MOD_OBJ_ID = mo.ID
  AND mp.OBJ_PAR_ID = cp.ID
union all
select
  mp.ID,
  mo.OBJ_ID,
  mp.NAME PARAM_NAME,
  null,
  mp.MOD_OBJ_ID,
  mp.TYPE_ID TYPE_ID,
  SP.to_strTYPE (mp.TYPE_ID) TYPE_NAME,
  mp.R_ONLY R_ONLY_ID,
  SP.to_strR_ONLY (mp.R_ONLY) R_ONLY,
  SP.S_IS_ENUM_TYPE (mp.TYPE_ID) VALUE_ENUM,
  SP.S_TYPE_HAS_SET_OF_VALUES (mp.TYPE_ID) SET_OF_VALUES,
  null D_VAL,
  SP.Val_to_str (SP.TVALUE (nvl(mp.TYPE_ID, 15),
                                  NULL,
                                  0,
                                  mp.E_VAL,
                                  mp.N,
                                  mp.D,
                                  mp.S,
                                  mp.X,
                                  mp.Y))
    VAL,
  mp.E_VAL E_VAL,
  mp.N N,
  mp.D D,
  mp.S S,
  mp.X X,
  mp.Y Y,
  1 IsRedefine,
  mp.M_DATE,
  mp.M_USER
  FROM mod_objects mo, SP.MODEL_OBJECT_PAR_S mp
  where mo.ID = mp.MOD_OBJ_ID and mp.OBJ_PAR_ID is null
  UNION ALL
   SELECT -1 ID,
          mo1.OBJ_ID OBJ_ID,
          'ID' PARAM_NAME,
          NULL OBJ_PAR_ID,
          mo1.ID MOD_OBJ_ID,
          /*G.TID*/
          37 TYPE_ID,
          'ID' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          NULL D_VAL,
          TO_CHAR (mo1.ID) VAL,
          NULL E_VAL,
          mo1.ID N,
          NULL D,
          NULL S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo1.M_DATE M_DATE,
          mo1.M_USER M_USER
     FROM mod_objects mo1
   UNION ALL
   SELECT -1 ID,
          mo1.OBJ_ID OBJ_ID,
          'PID' PARAM_NAME,
          NULL OBJ_PAR_ID,
          mo1.ID MOD_OBJ_ID,
          /*G.TID*/
          37 TYPE_ID,
          'ID' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          NULL D_VAL,
          TO_CHAR (mo1.PARENT_MOD_OBJ_ID) VAL,
          NULL E_VAL,
          mo1.PARENT_MOD_OBJ_ID N,
          NULL D,
          NULL S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo1.M_DATE M_DATE,
          mo1.M_USER M_USER
     FROM mod_objects mo1
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'OID' PARAM_NAME,
          NULL OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TOID*/
          36 TYPE_ID,
          'OID' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          SP.CPAR_DEF_S (mo2.ID, 'OID') d_VAL,
          mo2.OID VAL,
          NULL E_VAL,
          NULL N,
          NULL D,
          mo2.OID S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'POID' PARAM_NAME,
          NULL OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TOID*/
          36 TYPE_ID,
          'OID' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          SP.CPAR_DEF_S (mo2.ID, 'POID') d_VAL,
          pmo.OID VAL,
          NULL E_VAL,
          NULL N,
          NULL D,
          pmo.OID S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2, mod_objects pmo
    WHERE mo2.Parent_MOD_OBJ_ID = pmo.ID
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'NAME' PARAM_NAME,
          -1 OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TSting*/
          3 TYPE_ID,
          'Str4000' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          SP.CPAR_DEF_S (mo2.OBJ_ID, 'NAME') d_VAL,
          mo2.MOD_OBJ_NAME VAL,
          NULL E_VAL,
          NULL N,
          NULL D,
          mo2.MOD_OBJ_NAME S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'PARENT' PARAM_NAME,
          -2 OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TSting*/
          3 TYPE_ID,
          'Str4000' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          0 SET_OF_VALUES,
          SP.CPAR_DEF_S (mo2.ID, 'PARENT') d_VAL,
          SP.Paths.PATH (SP.MO.FULL_NAME (mo2.ID)) VAL,
          NULL E_VAL,
          NULL N,
          NULL D,
          SP.Paths.PATH (SP.MO.FULL_NAME (mo2.ID)) S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'USING_ROLE' PARAM_NAME,
          -3 OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TRole*/
          61 TYPE_ID,
          'Role' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          1 SET_OF_VALUES,
          SP.CPAR_DEF_RoleName (mo2.ID, 'USING_ROLE') d_VAL,
          CASE
             WHEN mo2.USING_ROLE IS NULL
             THEN
                NULL
             ELSE
                (SELECT NAME
                   FROM SP.SP_ROLES
                  WHERE ID = mo2.USING_ROLE)
          END
             VAL,
          NULL E_VAL,
          mo2.USING_ROLE N,
          NULL D,
          NULL S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2
   UNION ALL
   SELECT -1 ID,
          mo2.OBJ_ID OBJ_ID,
          'EDIT_ROLE' PARAM_NAME,
          -4 OBJ_PAR_ID,
          mo2.ID MOD_OBJ_ID,
          /*G.TRole*/
          61 TYPE_ID,
          'Role' TYPE_NAME,
          /*G.ReadOnly*/
          1 R_ONLY_ID,
          'R_Only' R_ONLY,
          0 VALUE_ENUM,
          1 SET_OF_VALUES,
          SP.CPAR_DEF_RoleName (mo2.ID, 'EDIT_ROLE') d_VAL,
          CASE
             WHEN mo2.EDIT_ROLE IS NULL
             THEN
                NULL
             ELSE
                (SELECT NAME
                   FROM SP.SP_ROLES
                  WHERE ID = mo2.EDIT_ROLE)
          END
             VAL,
          NULL E_VAL,
          mo2.EDIT_ROLE N,
          NULL D,
          NULL S,
          NULL X,
          NULL Y,
          1 AS IsRedefine,
          mo2.M_DATE M_DATE,
          mo2.M_USER M_USER
     FROM mod_objects mo2
;

GRANT ALL ON SP.V_MODEL_OBJECT_PARS TO "SP_ADMIN_ROLE";
GRANT SELECT, INSERT, UPDATE, DELETE ON SP.V_MODEL_OBJECT_PARS TO PUBLIC;

COMMENT ON TABLE SP.V_MODEL_OBJECT_PARS 
  IS 'Параметры объектов моделей. (SP-Model-Views.vw) Параметры с именами: "NAME", "PARENT", "OID", "POID", "ID", "PID", "EDIT_ROLE", "USING_ROLE" являются виртуальными.';

BEGIN
 cc.fT:='MODEL_OBJECTS';
 cc.tT:='V_MODEL_OBJECT_PARS';
 cc.c('OBJ_ID','OBJ_ID');
 
 cc.fT:='MODEL_OBJECT_PAR_S';
 cc.tT:='V_MODEL_OBJECT_PARS';
 cc.c('E_VAL','E_VAL'); 
 cc.c('N','N'); 
 cc.c('D','D'); 
 cc.c('S','S'); 
 cc.c('X','X'); 
 cc.c('Y','Y'); 
 cc.c('M_DATE','M_DATE'); 
 cc.c('M_USER','M_USER'); 

 cc.fT:='OBJECT_PAR_S';
 cc.tT:='V_MODEL_OBJECT_PARS';
 cc.c('NAME','PARAM_NAME');  
 cc.c('TYPE_ID','TYPE_ID');  
 cc.c('R_ONLY','R_ONLY_ID');  
END; 
/
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.ID 
  IS 'Идентификатор параметра объекта модели.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.D_VAL IS 
  'Поле содержит значение по умолчанию для данного параметра в виде строки.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.VAL IS 
  'Значение для данного параметра в виде строки.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.TYPE_NAME IS 'Имя типа.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.R_ONLY 
  IS 'Имя значения модификатора доступа R_ONLY_ID';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.IsRedefine 
  IS 'Если параметр имеет значение по умолчанию, то значение данного поля "0", если значение переопределено, то - "1".';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.OBJ_PAR_ID 
  IS 'Идентификатор параметра объекта в каталоге.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.MOD_OBJ_ID 
  IS 'Идентификатор объекта модели.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.VALUE_ENUM IS 'Признак именованного значения. 0 - значение не имеет имени, 1 - значение именовано.';
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PARS.SET_OF_VALUES IS 'Признак наличия у типа списка выбора для значения. 0 - значение не имеет списка выбора, 1 - значение имеет список выбора.';

CREATE OR REPLACE Synonym SP.V_MODEL_OBJECT_PAR_S for SP.V_MODEL_OBJECT_PARS;

-- История параметров объектов моделей.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_MODEL_OBJECT_PAR_STORIES
(
   ID,
   MOD_OBJ_ID,
   OBJ_PAR_ID,
   PAR_NAME,
   TYPE_ID,
   TYPE_NAME,
   VAL,
   E_VAL,
   N,
   D,
   S,
   X,
   Y,
   M_DATE,
   M_USER
)
AS
   SELECT s.ID,
          s.MOD_OBJ_ID,
          s.OBJ_PAR_ID,
          p.NAME PAR_NAME,
          s.TYPE_ID,
          t.NAME TYPE_NAME,
          SP.TVALUE (NVL (s.TYPE_ID, 15),
                     NULL,
                     0,
                     s.E_VAL,
                     s.N,
                     s.D,
                     s.S,
                     s.X,
                     s.Y)
              VAL,
          s.E_VAL,
          s.N,
          s.D,
          s.S,
          s.X,
          s.Y,
          s.M_DATE,
          s.M_USER
     FROM SP.MODEL_OBJECT_PAR_STORIES s, SP.OBJECT_PAR_S p, SP.PAR_TYPES t
    WHERE s.OBJ_PAR_ID = p.ID 
      AND s.TYPE_ID = t.ID;

GRANT ALL ON SP.V_MODEL_OBJECT_PAR_STORIES TO PUBLIC;

COMMENT ON TABLE SP.V_MODEL_OBJECT_PAR_STORIES 
  IS ' История параметров объектов моделей.  Для редактирования значений истории пользователю необходимы права редактирования объекта модели, которому принадлежит параметр, а также права на сингл, который является прообразом объекта модели. Администратор всегда может редактировать историю. (SP-Model-Views.vw)';

BEGIN
 cc.fT:='OBJECT_PAR_STORIES';
 cc.tT:='V_MODEL_OBJECT_PAR_STORIES';
 cc.all_av;
 
 cc.fT:='OBJECT_PAR_S';
 cc.tT:='V_MODEL_OBJECT_PAR_STORIES';
 cc.c('NAME','PAR_NAME');  
   
 cc.fT:='PAR_TYPES';
 cc.tT:='V_MODEL_OBJECT_PAR_STORIES';
 cc.c('NAME','TYPE_NAME');  
END; 
/
COMMENT ON COLUMN SP.V_MODEL_OBJECT_PAR_STORIES.VAL IS 
  'Значение для данного параметра в виде универсального значения.';

--*****************************************************************************
@"SP-Model-Instead.trg"


-- end of file


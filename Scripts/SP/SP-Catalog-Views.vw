-- SP Catalog Views 
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 22.10.2010 03.11.2010 22.11.2010 01.12.2010 07.12.2010 10.12.2010
--        17.12.2010 10.02.2011 06.05.2011 23.09.2011 10.11.2011 21.12.2011
--        19.01.2012 15.03.2012 03.04.2013 09.04.2013 13.06.2013 13.06.2014
--        30.08.2014 10.10.2014 28.11.2014 06.01.2015-07.01.2015 31.03.2015
--        08.07.2015 12.04.2017 17.01.2021
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_CATALOG_TREE
/* SP-Catalog-Views.vw */
(ID,
 IM_ID, 
 NAME,
 FULL_NAME,
 COMMENTS,
 PARENT_NAME,
 PARENT_ID,
 NODE_LEVEL,
 LEAF,
 GROUP_ID,GROUP_NAME,
 M_DATE, M_USER)
AS 
select 
  t.ID,
  t.IM_ID,
  t.NAME,
  SP.TREE.FullNodeName(t.ID,'') FULL_NAME,
  t.COMMENTS,
  SP.TREE.FullNodeName(t.PARENT_ID,'\') PARENT_NAME,
  t.PARENT_ID PARENT_ID,
  t.NODE_LEVEL,
  t.LEAF,
  t.GROUP_ID, g.NAME,
  t.M_DATE, t.M_USER
from (select ID, IM_ID, NAME, COMMENTS, PARENT_ID, GROUP_ID,
             LEVEL NODE_LEVEL, CONNECT_BY_ISLEAF LEAF, M_DATE, M_USER
       from SP.CATALOG_TREE
       start with PARENT_ID is null
       connect by PARENT_ID = prior ID
       ) t,
       SP.GROUPS g
where g.ID = t.GROUP_ID       
;

grant all on SP.V_CATALOG_TREE to "SP_ADMIN_ROLE";
grant select on SP.V_CATALOG_TREE to public;
Comment on table SP.V_CATALOG_TREE is 'Дерево каталога. SP-Catalog-Views.vw';

begin
 cc.fT:='CATALOG_TREE';
 cc.tT:='V_CATALOG_TREE';
 cc.all_av;
end; 
/

Comment on column SP.V_CATALOG_TREE.FULL_NAME 
  is 'Пролное имя узла (включая путь).';
Comment on column SP.V_CATALOG_TREE.PARENT_NAME 
  is 'Полное имя родительского узла.';
Comment on column SP.V_CATALOG_TREE.GROUP_NAME 
  is 'Имя группы, в которую включён данный узел.';
Comment on column SP.V_CATALOG_TREE.NODE_LEVEL is 'Уровень иерархии узла.';
Comment on column SP.V_CATALOG_TREE.LEAF 
  is 'Признак того, что узел является листом.';

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_OBJECTS
/* SP-Catalog-Views.vw */
(ID,
 OID,
 IM_ID,
 FULL_NAME, 
 SHORT_NAME,
 COMMENTS,
 KIND,
 KIND_ID,
 STATUS,
 LINES,
 GROUP_ID,
 GROUP_NAME,
 USING_ROLE,
 EDIT_ROLE,
 USING_ROLE_ID,
 EDIT_ROLE_ID,
 MODIFIED,
 M_USER)
AS 
select 
  o.ID,
  o.OID,
  o.IM_ID,
  g.NAME||'.'||o.NAME FULL_NAME,
  o.NAME SHORT_NAME,
  o.COMMENTS,
  cast( SP.to_str_obj_kind(o.OBJECT_KIND) as VARCHAR2(30)) KIND,
  cast(o.OBJECT_KIND as NUMBER(3)) KIND_ID,
  cast (SP.B.STATUS(o.ID) as VARCHAR2(12))  STATUS,
  (select count(*) from SP.Macros m where m.OBJ_ID = o.ID) LINES,
  o.GROUP_ID GROUP_ID,
  g.NAME GROUP_NAME,
  u.NAME USING_ROLE,
  e.NAME EDIT_ROLE,
  o.USING_ROLE USING_ROLE_ID,
  o.EDIT_ROLE EDIT_ROLE_ID,
  o.MODIFIED,
  o.M_USER
from SP.OBJECTS o, SP.SP_ROLES e, SP.SP_ROLES u, SP.GROUPS g
where g.ID = o.GROUP_ID 
  and o.USING_ROLE=u.ID(+)
  and o.EDIT_ROLE=e.ID(+)
  and (   (o.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (o.USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
      )  order by SHORT_NAME
;

grant all on SP.V_OBJECTS to public;
Comment on table SP.V_OBJECTS is 'Объекты. SP-Catalog-Views.vw';

begin
 cc.fT:='SP_ROLES';
 cc.tT:='V_OBJECTS';
 cc.c('NAME','EDIT_ROLE');
 cc.c('NAME','USING_ROLE');

 cc.fT:='OBJECTS';
 cc.tT:='V_OBJECTS';
 cc.c('ID','ID');
 cc.c('OID','OID');
 cc.c('GROUP_ID','GROUP_ID');
 cc.c('IM_ID','IM_ID');
 cc.c('NAME','SHORT_NAME');
 cc.c('COMMENTS','COMMENTS');
-- cc.c('OBJECT_KIND','KIND');
 cc.c('OBJECT_KIND','KIND_ID');
 cc.c('USING_ROLE','USING_ROLE_ID');
 cc.c('EDIT_ROLE','EDIT_ROLE_ID'); 
 cc.c('MODIFIED','MODIFIED');
 cc.c('M_USER','M_USER');
 
 cc.fT:='GROUPS';
 cc.tT:='V_OBJECTS';
 cc.c('NAME','GROUP_NAME');
end; 
/

Comment on column SP.V_OBJECTS.FULL_NAME is 'Полное имя объекта (<имя группы>.<имя объекта>).';
Comment on column SP.V_OBJECTS.KIND is 'Описание вида объекта.';
Comment on column SP.V_OBJECTS.STATUS is 'Состояние готовности объекта к выполнению "VALID" - объект скомпилирован и может быть исполнен. Простые объекты всегда готовы.';
Comment on column SP.V_OBJECTS.LINES is 'Число втрок в макропроцедуре.';
Comment on column SP.V_OBJECTS.USING_ROLE is 'Роль, которую должен иметь пользователь, чтобы иcпользовать объект в элементах своих объектов. Пользователь, имеющий SP_ADMIN_ROLE, может использовать любой объект. Если поле нулл, то объект публичен.';
Comment on column SP.V_OBJECTS.EDIT_ROLE is 'Роль, которую должен иметь пользователь дополнительно к SP_DEVELOPING_ROLE, чтобы изменять объект, а также добавлять удалять или изменять его параметры. Пользователь, имеющий SP_ADMIN_ROLE, может изменять любой объект. Если поле нулл, то только администратор может изменять объект.';

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_OBJECT_PAR_S
/* SP-Catalog-Views.vw */
(ID,
 OBJECT_ID,
 NAME,
 COMMENTS,
 VALUE_COMMENTS,
 VALUE_TYPE,
 TYPE_ID,
 VALUE_ENUM,
 SET_OF_VALUES,
 R_ONLY,
 R_ONLY_ID,
 V,
 E,N,D,S,X,Y,
 MODIFIED,
 GROUP_ID,
 GROUP_NAME,
 M_DATE,
 M_USER
)
AS 
select 
  p.ID,
  o.ID OBJECT_ID,
/*  o.NAME as OBJECT_NAME, */
  p.NAME,
  p.COMMENTS,
  SP.Val_Comments(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y)) 
    VALUE_COMMENTS,
  cast (SP.to_strTYPE(p.TYPE_ID)as VARCHAR2(128) ) VALUE_TYPE,
  cast(p.TYPE_ID as NUMBER(9)) TYPE_ID,
  cast(SP.S_IS_ENUM_TYPE(p.TYPE_ID) as NUMBER(1)) VALUE_ENUM,
  cast(SP.S_TYPE_HAS_SET_OF_VALUES(p.TYPE_ID) as NUMBER(1)) SET_OF_VALUES,
  cast (SP.to_strR_ONLY(p.R_ONLY) as VARCHAR2(60) ) R_ONLY,
  cast(p.R_ONLY as NUMBER(3)) R_ONLY_ID,
  SP.Val_to_Str(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.X,p.Y)) "V",
  p.E_VAL,p.N,p.D,p.S,p.X,p.Y,
  cast(0 as NUMBER(1)) MODIFIED,
  p.GROUP_ID, g.NAME GROUP_NAME, 
  p.M_DATE, p.M_USER
from SP.OBJECTS o, SP.SP_ROLES u, SP.OBJECT_PAR_S p, SP.GROUPS g 
where o.USING_ROLE=u.ID(+)
  and p.OBJ_ID=o.ID       
  and (   (o.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (o.USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
      )
  and p.GROUP_ID = g.ID(+)    
;

grant all on SP.V_OBJECT_PAR_S to public;
Comment on table SP.V_OBJECT_PAR_S is 
'Параметры объектов. SP-Catalog-Views.vw';

begin
 cc.fT:='OBJECTS';
 cc.tT:='V_OBJECT_PAR_S';
 cc.c('ID','OBJECT_ID');
/* cc.c('NAME','OBJECT_NAME'); */
 
 cc.fT:='OBJECT_PAR_S';
 cc.tT:='V_OBJECT_PAR_S';
 cc.c('ID','ID');
 cc.c('NAME','NAME'); 
 cc.c('COMMENTS','COMMENTS');
 cc.c('TYPE_ID','VALUE_TYPE'); 
 cc.c('TYPE_ID','TYPE_ID'); 
 cc.c('GROUP_ID','GROUP_ID'); 
 cc.c('R_ONLY','R_ONLY_ID');  
 cc.c('E_VAL','E');  
 cc.c('N','N');  
 cc.c('D','D');  
 cc.c('S','S');  
 cc.c('X','X');  
 cc.c('Y','Y');  
 cc.c('M_DATE','M_DATE');  
 cc.c('M_USER','M_USER');
   
 cc.fT:='GROUPS';
 cc.tT:='V_OBJECT_PAR_S';
 cc.c('NAME','GROUP_NAME');
end; 
/

Comment on column SP.V_OBJECT_PAR_S.R_ONLY
  is 'Имя значения модификатора доступа R_ONLY_ID';
Comment on column SP.V_OBJECT_PAR_S.V is 'Представление типа в виде строки.';
Comment on column SP.V_OBJECT_PAR_S.VALUE_COMMENTS is 'Комментарий к значению параметра.';
Comment on column SP.V_OBJECT_PAR_S.VALUE_ENUM is 'Признак именованного значения. 0 - значение не имеет имени, 1 - значение именовано.';
Comment on column SP.V_OBJECT_PAR_S.SET_OF_VALUES is 'Признак наличия у типа списка выбора для значения. 0 - значение не имеет списка выбора, 1 - значение имеет список выбора.';
Comment on column SP.V_OBJECT_PAR_S.MODIFIED is 'Если при добавлении или редактировании параметра это поле не равно 0, то поле MODIFIED у родительского объекта получит значение текущей даты.';


-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_MACROS
/* SP-Catalog-Views.vw */
(ID,
 PREV_ID,
 OBJECT_ID,
 OBJECT_FULL_NAME,
 OBJECT_SHORT_NAME,
 OBJECT_GROUP_NAME,
 ALIAS,
 COMMENTS,
 LINE,
 CMD_NAME,
 CMD_ID,
 USED_OBJECT_FULL_NAME,
 USED_OBJECT_SHORT_NAME,
 USED_OBJECT_GROUP_NAME,
 USED_OBJECT_ID,
 USED_OBJECT_KIND_NAME,
 USED_OBJECT_KIND_ID,
 MACRO,
 CONDITION,
 MODIFIED,
 M_DATE,
 M_USER)
AS 
select 
  m.ID,
  m.PREV_ID,
  m.OBJ_ID,
  og.NAME||'.'||o.NAME OBJECT_FULL_NAME,
  o.NAME OBJECT_SHORT_NAME,
  og.NAME OBJECT_GROUP_NAME,
  m.ALIAS,
  m.COMMENTS,
  cast(m.LINE as NUMBER(9)) LINE,
  c.NAME CMD_NAME,
  cast(m.CMD_ID as NUMBER(3)) CMD_ID,
  nvl2(u.NAME,(select NAME||'.' from SP.GROUPS ug 
                 where u.GROUP_ID = ug.ID),'')||u.NAME
    USED_OBJECT_FULL_NAME,
  u.NAME USED_OBJECT_SHORT_NAME,
  nvl2(u.NAME,(select NAME from SP.GROUPS ug where u.GROUP_ID = ug.ID),'')
    USED_OBJECT_GROUP_NAME,
  m.USED_OBJ_ID,
  cast (SP.to_STR_OBJ_KIND(u.OBJECT_KIND)as VARCHAR2(60))
    USED_OBJECT_KIND_NAME,
  cast(u.OBJECT_KIND as NUMBER(3)) USED_OBJECT_KIND_ID,
  m.MACRO,
  m.CONDITION,
  cast(0 as NUMBER(1)) MODIFIED,
  m.M_DATE,
  m.M_USER
from 
  (select LEVEL LINE, ma.* from SP.MACROS ma 
     start with PREV_ID is null
     connect by PREV_ID = prior ID) m,
  SP.OBJECTS o, SP.COMMANDS c, SP.OBJECTS u, SP.GROUPS og
where m.OBJ_ID=o.ID
  and m.CMD_ID=c.ID
  and o.GROUP_ID = og.ID
  and m.USED_OBJ_ID=u.ID(+)
  and (   (o.EDIT_ROLE in (select ROLE_ID from SP.USER_ROLES))
       or (SP.S_isUserAdmin=1))  
;

grant all on SP.V_MACROS to public;
Comment on table SP.V_MACROS is 'Макросы. SP-Catalog-Views.vw';

begin
 cc.fT:='OBJECTS';
 cc.tT:='V_MACROS';
 cc.c('NAME','OBJECT_SHORT_NAME');
 cc.c('OBJECT_KIND','USED_OBJECT_KIND_ID');

 cc.fT:='COMMANDS';
 cc.tT:='V_MACROS';
 cc.c('NAME','CMD_NAME');

 cc.fT:='MACROS';
 cc.tT:='V_MACROS';
 cc.c('ID','ID'); 
 cc.c('OBJ_ID','OBJECT_ID');
 cc.c('ALIAS','ALIAS'); 
 cc.c('COMMENTS','COMMENTS');
 cc.c('PREV_ID','PREV_ID'); 
 cc.c('CMD_ID','CMD_ID'); 
 cc.c('USED_OBJ_ID','USED_OBJECT_ID');  
 cc.c('MACRO','MACRO');  
 cc.c('CONDITION','CONDITION');  
 cc.c('M_DATE','M_DATE');  
 cc.c('M_USER','M_USER');  
end; 
/
Comment on column SP.V_MACROS.OBJECT_GROUP_NAME is ' Имя группы(namespace) объекта. Уникальность объекта определена для <имя группы>.<имя объекта>.';
Comment on column SP.V_MACROS.OBJECT_FULL_NAME is ' Полное имя объекта.(<имя группы>.<имя объекта>)';
Comment on column SP.V_MACROS.USED_OBJECT_FULL_NAME is 'Полное имя объекта каталога или типовой процедуры, использованного текущей коммандой.';
Comment on column SP.V_MACROS.USED_OBJECT_SHORT_NAME is 'Короткое имя объекта каталога или типовой процедуры, использованное текущей коммандой.';
Comment on column SP.V_MACROS.USED_OBJECT_GROUP_NAME is 'Группа (namespace) объекта каталога или типовой процедуры, использованное текущей коммандой.';
Comment on column SP.V_MACROS.USED_OBJECT_KIND_NAME is 'Вид используемого объекта в виде строкового значения.';
Comment on column SP.V_MACROS.LINE is 'Порядковый номер макрокоманды в макропроцедуре.';
Comment on column SP.V_MACROS.MODIFIED is 'Если при добавлении или редактировании строки это поле не равно 0, то поле MODIFIED у родительского объекта получит значение текущей даты.';


--*****************************************************************************
@"SP-Catalog-Instead.trg"
@"SP-Catalog-Macros-Instead.trg"


-- end of file


-- SP GUsedObjects Views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.06.2013
-- update 26.06.2013 02.07.2013 30.09.2013 10.10.2014 06.01.2015 08.07.2015
--  
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.VG_USED_OBJECTS
/* SP-GUsedObjects-Views.vw */
(ID,
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
  and g.ID in (select * from table (SP.GRAPH2TREE.SelectNodes('UsedObjectGroup'))
               union
               select SP.Graph2Tree.GetRoot('UsedObjectGroup') from dual
               )
  and o.USING_ROLE=u.ID(+)
  and o.EDIT_ROLE=e.ID(+)
  and (   (o.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (o.USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
      )  order by SHORT_NAME
;

grant all on SP.VG_USED_OBJECTS to public;
Comment on table SP.VG_USED_OBJECTS is 'Объекты, включенные в группу, определяемую глобальным параметром UsedObjectGroup. SP-GUsedObjects-Views.vw';

begin
 cc.fT:='SP_ROLES';
 cc.tT:='VG_USED_OBJECTS';
 cc.c('NAME','EDIT_ROLE');
 cc.c('NAME','USING_ROLE');

 cc.fT:='OBJECTS';
 cc.tT:='VG_USED_OBJECTS';
 cc.c('ID','ID');
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
 cc.tT:='VG_USED_OBJECTS';
 cc.c('NAME','GROUP_NAME');
end; 
/

Comment on column SP.VG_OBJECTS.FULL_NAME is 'Полное имя объекта (<имя группы>.<имя объекта>).';
Comment on column SP.VG_USED_OBJECTS.KIND is 'Описание вида объекта.';
Comment on column SP.VG_USED_OBJECTS.LINES is 'Число втрок в макропроцедуре.';
Comment on column SP.VG_USED_OBJECTS.USING_ROLE is 'Роль, которую должен иметь пользователь, чтобы иcпользовать объект в элементах своих объектов. Пользователь, имеющий SP_ADMIN_ROLE, может использовать любой объект. Если поле нулл, то объект публичен.';
Comment on column SP.VG_USED_OBJECTS.EDIT_ROLE is 'Роль, которую должен иметь пользователь дополнительно к SP_DEVELOPING_ROLE, чтобы изменять объект, а также добавлять удалять или изменять его параметры. Пользователь, имеющий SP_ADMIN_ROLE, может изменять любой объект. Если поле нулл, то только администратор может изменять объект.';



--*****************************************************************************
@"SP-GUsedObjects-Instead.trg"


-- end of file


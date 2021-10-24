-- SP LOBS_JOBS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 29.07.2021
-- update 31.07.2021 01.08.2021
------------------------------------------------------------------------------- 


--Очистка и нормализация LOB
------------------------------------------------------------------------------- 
create or replace procedure SP.LOBS_FREE_UNUSED
-- Заполняем идентификатор LOB по его GUID. (SP-LOBS_JOBS.prc)
is
tmpVar NUMBER;
begin

-- удаляем LOBы на которые нет ссылок из моделей, за исключением вновь добавленных, на которые ссылки ещё не проставлены.
delete from SP.LOB_S l 
  where l.ID not in
  (
    select N ID from SP.MODEL_OBJECT_PAR_S where TYPE_ID in (103,104)
       and N is not null 
    union all
    select N ID from SP.MODEL_OBJECT_PAR_STORIES where TYPE_ID in (103,104)
      and N is not null
    union all
    select N ID from SP.OBJECT_PAR_S where TYPE_ID in (103,104)
      and N is not null
  )
  and M_DATE < sysdate - 1
;

begin
  SP.TG.ImportDATA:=true;
  for rec in
  (
    select ID, S from SP.MODEL_OBJECT_PAR_S 
    where TYPE_ID in (103,104) 
    and (S is not null) and (N is null)
  )
  loop
    select ID into tmpVar from sp.LOB_S where GUID = rec.S;
    update SP.MODEL_OBJECT_PAR_S
    set
      N = tmpVar
    where rec.ID = ID;  
  end loop;
  SP.TG.ImportDATA:=false;
exception
  when others then
      SP.TG.ImportDATA:=false;
      raise;
end;
--
for rec in
(
  select ID, S from SP.MODEL_OBJECT_PAR_STORIES 
  where TYPE_ID in (103,104) 
  and (S is not null) and (N is null)
)
loop
  select ID into tmpVar from sp.LOB_S where GUID = rec.S;
  update SP.MODEL_OBJECT_PAR_STORIES
  set
    N = tmpVar
  where rec.ID = ID;  
end loop;
--
for rec in
(
  select ID, S from SP.OBJECT_PAR_S
  where TYPE_ID in (103,104) 
  and (S is not null) and (N is null)
)
loop
  select ID into tmpVar from sp.LOB_S where GUID = rec.S;
  update SP.MODEL_OBJECT_PAR_STORIES
  set
    N = tmpVar
  where rec.ID = ID;  
end loop;

end;
/
GRANT EXECUTE ON SP.LOBS_FREE_UNUSED to public;

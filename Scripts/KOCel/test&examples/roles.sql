select st.A.S   "A" 
from (table(KOCEL.Cell.Vals('Роли-Объекты','Роли-Объекты')))st 
;

select *
from table(KOCEL.Cell.Vals('Роли-Объекты','Роли-Объекты'))
;

begin
  KOCEL.CELL.INBOOK := 'Роли-Объекты';
  KOCEL.CELL.INSHEET := 'Роли-Объекты';
  d(KOCEL.CELL.INSHEET,'play with Roles');
  o(KOCEL.CELL.INSHEET);
end;
/
;
select *
from table(KOCEL.Cell.inVals)
;

select *
from table(KOCEL.Cell.Vals_as_STR('Роли-Объекты','Роли-Объекты'))
;
select A "Роль", B "Объект"
from table(KOCEL.Cell.Vals_as_STR('Роли-Объекты','Роли-Объекты'))
;

begin
for r in
(
  select A "Роль", B "Объект"
  from table(KOCEL.Cell.Vals_as_STR('Роли-Объекты','Роли-Объекты'))
)
loop
  o(r."Роль");
end loop;
end;

select B "Объект"
from table(KOCEL.Cell.Vals_as_STR('Роли-Объекты','Роли-Объекты'))
where A = 'PPM_LAYCHAU'
;

select count(*) from SP.V_PRIM_ROLES where name = 'q'
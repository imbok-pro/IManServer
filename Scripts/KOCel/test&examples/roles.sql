select st.A.S   "A" 
from (table(KOCEL.Cell.Vals('����-�������','����-�������')))st 
;

select *
from table(KOCEL.Cell.Vals('����-�������','����-�������'))
;

begin
  KOCEL.CELL.INBOOK := '����-�������';
  KOCEL.CELL.INSHEET := '����-�������';
  d(KOCEL.CELL.INSHEET,'play with Roles');
  o(KOCEL.CELL.INSHEET);
end;
/
;
select *
from table(KOCEL.Cell.inVals)
;

select *
from table(KOCEL.Cell.Vals_as_STR('����-�������','����-�������'))
;
select A "����", B "������"
from table(KOCEL.Cell.Vals_as_STR('����-�������','����-�������'))
;

begin
for r in
(
  select A "����", B "������"
  from table(KOCEL.Cell.Vals_as_STR('����-�������','����-�������'))
)
loop
  o(r."����");
end loop;
end;

select B "������"
from table(KOCEL.Cell.Vals_as_STR('����-�������','����-�������'))
where A = 'PPM_LAYCHAU'
;

select count(*) from SP.V_PRIM_ROLES where name = 'q'
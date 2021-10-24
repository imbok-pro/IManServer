begin
  KOCEL.UPDATE_CELL(2,2,
  2,null,null,null,
	'Q','Q');
end;

begin
  KOCEL.INSERT_CELL(2,1,
  2,null,null,null,
	'Q2',2,'Q');
end;

select * from KOCEL.V_SHEETS	where BOOK='Q'

begin
  KOCEL.Insert_CELL(5,5,
  2,null,null,null,
	'Q','Q');
end;

call d('Q','Q');

begin
  debug_output.SETSTATE(true);
end;

select count(*) from (select distinct sheet from KOCEL.SHEETS 
where BOOK='денис')

select distinct sheet from KOCEL.V_SHEETS 
where BOOK='Q' order by sheet 

select 1 from DUAL
union
select 2 from DUAL
union
select 1 from DUAL

(
select NUM,SHEET from KOCEL.SHEETS_ORDER
  where upper(BOOK)=upper(&SourceBook)
union
select 1000 NUM,r.SHEET from 
 (select distinct s.SHEET from KOCEL.SHEETS s
  where (upper(s.BOOK)=upper(&SourceBook))
	  and (s.Sheet not in (select so.SHEET from KOCEL.SHEETS_ORDER so
                       where upper(so.BOOK)=upper(&SourceBook))))r
)
order by NUM

select sysdate from dual
select 'Кису Любишь!' from dual

select * from scott.dept
------------------------------------------------------------------------------
declare
r NUMBER;
f VARCHAR2(256);
begin
  r:=KOCELSYS.FIND_MD_FIELD(
	  'select sysdate, sysdate d1 from dual',
    'select sysdate, sysdate d1 from dual',
		f);
	o(to_.STR(r));
	o(f);
end;
/

------------------------------------------------------------------------------
declare
r VARCHAR2(256);
SQLstr VARCHAR2(4000);
p VARCHAR2(256);
begin
  SQLstr:='select :p1 from dual';
	p:='Кису Любишь';
  execute immediate (SQLstr)into r using p;
	o(r);
end;
/

select * from table (kocel.cell.vals_as_str('Q','Q'))

select * from table (kocel.cell.vals('Sheet1','Ж-П 76601 50'))

select regexp_substr('Приход:Кассовая справка
Расчеты с покупателями и заказчиками
Касса супермаркета  т/выр
Декор-студия Гламур ООО
Дог. № 10-30-406 от 07.05.02
Супермаркет секция "Одежда-трикотаж"
ККМ № 00044465'
,'ККМ\s№\s\d{8}') from dual

select KOCEL.Cell.Col2Num('J') from dual

select st.A.D   "A" ,
       sum(case
             when st.F.N is null then 0
             when st.F.N >0 then st.F.N
           else 0
           end) "B",
       sum(case
             when st.F.N is null then 0
             when st.F.N < 0 then -st.F.N
           else 0
           end) "C",
       st.J.S   "J"    
from (table(KOCEL.Cell.Vals('Sheet1','Ж-П 76601 50')))st 
where (st.A.D is not null)
group by st.J.S,st.A.D   
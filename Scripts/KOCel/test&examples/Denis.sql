update kocel.sheets set fmt=0 where upper(book)=upper('ooo_data_2011')

update kocel.sheets set S=nvl(to_char(N),S),N=null 
  where upper(book)=upper('ooo_data_2011')
    and C in (3,4,5,6,10,13,17)
    and R > 1
    
    
select "B" from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))

CREATE TABLE PROG.SENCE( 
  INN VARCHAR2(10),
	P_NAME VARCHAR2(4000),
	ADR VARCHAR2(4000),
	R_N VARCHAR2(255)not null,
	R_F VARCHAR2(255)not null,
	
	CONSTRAINT PK_INN PRIMARY KEY (INN)
);

CREATE UNIQUE INDEX PROG.SENCE ON PROG.SENCE(P_NAME);

CREATE TABLE PROG.NALOG( 
  INN VARCHAR2(10),
	Y NUMBER(4),
  Q NUMBER(1),
  S NUMBER,
	CONSTRAINT PK_N_INN PRIMARY KEY (INN,Y,Q)
);

  select trim("C"), "B", "H", "L", "K" 
    from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
    where "C"!='ИНН'
      

      
 select "C", "B", "H", "L", "K" 
    from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
    where "C"!='ИНН'
      and "C" not in (
  select distinct "C" 
    from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
    where "C"!='ИНН')
  
select q,c from( select count(*) q, "C" c
  from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
  group by "C")
  where q > 1
  
select q,c from( select count(*) q, "B" c
  from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
  group by "B")
  where q > 1
  
  
declare
  inn VARCHAR2(10);
begin
  inn:='0';
  for c in 
    (select "C" INN, "B" NAME, "H" ADR, "L" R_N, "K" R_F 
       from table(Kocel.Cell.Vals_as_Str('Учетные данные','ooo_data_2011'))
       where "C"!='ИНН')
  loop
    if (c.INN!=inn) and (c.R_N is not null) and (c.R_F is not null) then
      begin
        insert into PROG.SENCE values c;
      exception
        -- игнорируем строчки с повторными именами и т.д.
        when others then null;
      end;  
    end if;
    inn:=c.INN;
  end loop;     
end; 


declare
  inn VARCHAR2(10);
begin
  inn:='0';
  for c in 
    (select "D" INN, to_number("A") S
       from table(Kocel.Cell.Vals_as_Str(
         'Реестр деклараций ЮЛ', 'ooo_nalog_2011_2')) n,
         SENCE d
       where n."D"!='ИНН'
         and d.INN=n."D")
  loop
    if (c.INN!=inn) and (c.S is not null) then
      begin
	        insert into PROG.NALOG values (c.INN,2011,2,c.S);
      exception
        when others then 
          o(c.INN||'   '||SQLERRM);
      end;  
    end if;
    inn:=c.INN;
  end loop;     
end; 

select "D" INN, to_number("A") S, P_Name
       from table(Kocel.Cell.Vals_as_Str(
         'Реестр деклараций ЮЛ', 'ooo_nalog_2010_4')) n,
         SENCE d
       where n."D"='7727576505'
         and d.INN=n."D"
         
select count(*) from SENCE d, 
  (select * from NALOG n where Y=2010 and Q=1) n1, 
  (select * from NALOG n where Y=2010 and Q=4) n2,
  (select * from NALOG n where Y=2011 and Q=1) n3,
  (select * from NALOG n where Y=2011 and Q=2) n4
  where d.INN=n1.INN         
    and d.INN=n2.INN
    and d.INN=n3.INN
    and d.INN=n4.INN
    and n2.S < n4.S
    and n3.S < n4.S
    
    
select count(*) from SENCE d, 
  (select * from NALOG where Y=2010 and Q=4) n2,
  (select * from NALOG where Y=2011 and Q=1) n3,
  (select * from NALOG where Y=2011 and Q=2) n4
  where d.INN not in(select INN from NALOG where Y=2010 and Q=1)         
    and d.INN=n2.INN
    and d.INN=n3.INN
    and d.INN=n4.INN
    and n2.S < n4.S
    and n3.S < n4.S
    and n4.S < 300000

select * from 
  (select INN, P_Name from SENCE) d, 
  (select INN,S S2 from NALOG where Y=2010 and Q=4) n2,
  (select INN,S S3 from NALOG where Y=2011 and Q=1) n3,
  (select INN,S S4 from NALOG where Y=2011 and Q=2) n4
  where d.INN not in(select INN from NALOG where Y=2010 and Q=1)         
    and d.INN=n2.INN
    and d.INN=n3.INN
    and d.INN=n4.INN
    and n2.S2 < n4.S4
    and n3.S3 < n4.S4
order by S2    
    
    
select * from SENCE d, NALOG n 
  where d.INN=n.INN         


-- Получение имени и отчества с точками из имени и отчества в одном поле.
CREATE OR REPLACE FUNCTION PROG.IDOT_ODOT(S in VARCHAR2)return VARCHAR2
is
begin
  return upper(substr(S,1,1)||'.'||substr(S,instr(S,' ')+1,1)||'.');
end;
/

select initcap('мDGJGFKLJhhhhh') from dual

select PROG.IDOT_ODOT('MTYFUGY ЙУЦКОГ') from dual

-- Получение индекса из адреса
CREATE OR REPLACE FUNCTION PROG.ADR_INDEX(S in VARCHAR2)return VARCHAR2
is
begin
 return substr(S,1, instr(S,',')-1); 
end;
/

select PROG.ADR_INDEX('1234567,MTYFUGY ЙУЦКОГ') from dual
  
-- Получение улицы и дома из адреса
CREATE OR REPLACE FUNCTION PROG.ADR_LAST(S in VARCHAR2)return VARCHAR2
is
i NUMBER;
begin
 i:= instr(S,',,,,');
 if i=0 then
   i:= instr(S,', , , ,');
   if i=0 then 
     return null;
   else
     i:=i+8;   
   end if;
 else
   i:=i+4;  
 end if;
 return  initcap(replace(replace(rtrim(substr(S,i),','),',,',','),', ,',',')); 
end;
/
  
select ADR, PROG.ADR_LAST(ADR) from PROG.SENCE  


select inn from SENCE where (rownum<10) and (P_NAME like 'ООО%')

select initcap(R_N) Name, inn, P_Name,
        IDOT_ODOT(R_N)||' '||initcap(R_F) NName
from SENCE

update sence set
  p_name=replace(p_name,'Общество с ограниченной ответственностью','OOO')
  where p_name like '%Общество с ограниченной ответственностью%'

select * from	Table(KOCEL.Describe('Kocel.SHEETS'))
select * from	Table(KOCEL.Describe('Kocel.V_SHEETS'))
select * from	Table(KOCEL.Describe('Kocel.V_BOOK_CELLS'))
select * from	Table(KOCEL.Describe('Kocel.SHEETS'))
select * from	Table(KOCEL.Describe('Kocel.SHEETS'))
select * from	Table(KOCEL.Describe('Kocel.SHEETS'))


DECLARE
  type TDef is record (COLNAME VARCHAR2(100),COLTYPENAME VARCHAR2(100),
    COLTYPE NUMBER,COLLENGTH NUMBER); 
  type TRetVal is table of TDEF;
  RetVal TRetVal;
  TABLENAME VARCHAR2(200);
BEGIN 
  TABLENAME := 'Kocel.SHEETS';
  select COLNAME,COLTYPENAME, COLTYPE,COLLENGTH bulk collect into RetVal 
    from	TABLE(KOCEL.Describe(TABLENAME));
  for i in 1..RetVal.count
	loop
	  dbms_output.put_line (retval(i).ColName 
		                     ||' '|| retval(i).ColTypeName
												 ||' '|| retval(i).ColLength);
	end loop;
END; 


BEGIN 
  for i in (select * from	TABLE(KOCEL.Describe('Kocel.SHEETS')))
	loop
	  dbms_output.put_line (i.ColName 
		                     ||' '|| i.ColTypeName
												 ||' '|| i.ColLength);
	end loop;
END; 


begin
KOCEL.TABLE2SHEET('BDR.USER_ROLES','ROLES','BDR_TEST');
end;

--создание DB Link к серверу Oracle БД Zuken e3.series
--created 2017-08-08
--updated 2019-01-15
Declare
  DbLinkName Varchar2(4000);
Begin
  Select DB_LINK Into DbLinkName From ALL_DB_LINKS
  Where OWNER='PUBLIC'
  AND (DB_LINK = 'E3ORA' Or DB_LINK Like 'E3ORA.%');
  
  EXECUTE IMMEDIATE('
  DROP PUBLIC DATABASE LINK '||DbLinkName
  );
  
Exception When NO_DATA_FOUND then
  null;
End;

/
CREATE PUBLIC DATABASE LINK "E3ORA"
CONNECT TO "PROG" IDENTIFIED BY p
USING
'(DESCRIPTION=
(ADDRESS=
(PROTOCOL=TCP)
(HOST="MD-ORCL-DB-4.hydroproject.ru" )
(PORT=1521))
(CONNECT_DATA=
(SID=XE)))';   

/
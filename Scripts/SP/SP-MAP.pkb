CREATE OR REPLACE PACKAGE BODY SP.MAP
-- Map package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.07.2014 
-- update 
AS
cmap VARCHAR2(128);
maps TMAPS;
rmaps TMAPRECS;
-------------------------------------------------------------------------------
FUNCTION LOAD_VALUE(m in VARCHAR2, K in VARCHAR2) return VARCHAR2
is
result VARCHAR2(128);
tr number;
begin
  if not rmaps.exists(m) then
    return null;
  end if;
  d(1,'map.LOAD_VALUE');
  select R into tr from KOCEL.SHEETS 
    where upper(BOOK) = UPPER(rmaps(m).BOOK)
      and upper(SHEET) = UPPER(rmaps(m).SHEET)   
      and C = rmaps(m).KeyColumn   
      and trim(K) = trim(S);   
  d(tr,'map.LOAD_VALUE');
  select S into result from KOCEL.SHEETS 
    where upper(BOOK) = UPPER(rmaps(m).BOOK)
      and upper(SHEET) = UPPER(rmaps(m).SHEET)   
      and R = tr and C = rmaps(m).ValueColumn;
  maps(m)(K):= result;
  return result;    
exception
  when no_data_found then
    raise_application_error(-20033,
      'SP.MAP.LOAD_VALUE. Отсутствует значение : map=> '||m||
       ', BOOK=> '||rmaps(m).BOOK||', SHEET=> '||rmaps(m).SHEET ||
       ', KeyColumn=> '||rmaps(m).KeyColumn ||
       ', ValueColumn=>'||rmaps(m).ValueColumn ||', V=>'||K || '!');
end;

-------------------------------------------------------------------------------
FUNCTION V(MapName IN VARCHAR2, K IN VARCHAR2)  return VARCHAR2
is
begin
  if MapName is null then 
    raise_application_error(-20033,
      'SP.MAP.V. Отсутствует значение имя карты!');
  end if;
  if not rmaps.exists(MapName) then
    raise_application_error(-20033,
      'SP.MAP.V. Карта'||MapName||' не инициализирована!');
  end if;    
  cmap := MapName;
  return V(K);    
end V;

-------------------------------------------------------------------------------
FUNCTION V(K IN VARCHAR2)  return VARCHAR2
is
begin
  if cmap is null then
    return null;
  elsif not rmaps.exists(cmap) then
    raise_application_error(-20033,
      'SP.MAP.V. Карта '||cmap||' не инициализирована!');
  -- Загружаем значение, если нет ни одного инициализированного   
  elsif not maps.exists(cmap) then
    return LOAD_VALUE(cmap,K);
  --  или требуемого.  
  elsif not maps(cmap).exists(K) then
    return LOAD_VALUE(cmap,K);
  else
    return maps(cmap)(K);
  end if;     
end V;

-------------------------------------------------------------------------------
PROCEDURE NEW(
  MapName IN VARCHAR2,
  BOOK IN VARCHAR2, Sheet IN VARCHAR2,
  KeyColumn IN VARCHAR2, KeyColumnRow IN NUMBER,
  ValueColumn IN VARCHAR2, ValueColumnRow IN NUMBER)
is
  rec TMAPREC;
  tc NUMBER;
begin
  rec.BOOK := BOOK;
  rec.SHEET := SHEET;
  -- Выбираем и запоминаем колонку ключа.
  select C into rec.KeyColumn from KOCEL.SHEETS 
    where upper(BOOK) = UPPER(rec.BOOK)
      and upper(SHEET) = UPPER(rec.SHEET)   
      and R = KeyColumnRow  
      and trim(KeyColumn) = trim(S);   
  -- Выбираем и запоминаем колонку результата.
  select C into rec.ValueColumn from KOCEL.SHEETS 
    where upper(BOOK) = UPPER(rec.BOOK)
      and upper(SHEET) = UPPER(rec.SHEET) 
      and R = ValueColumnRow   
      and trim(ValueColumn) = trim(S);   
  rmaps(MapName) := rec;
  cmap := MapName;
exception
  when no_data_found then
    raise_application_error(-20033,
      'SP.MAP.NEW. Отсутствуют данные : map=> '||MapName||
       ', BOOK=> '||BOOK||', SHEET=> '||SHEET ||
       ', KeyColumn=> '||KeyColumn ||', KeyColumnRow=> '||KeyColumnRow||
       ', ValueColumn=>'||ValueColumn ||
       ', ValueColumnRow=>'||ValueColumnRow||'!');
end NEW;

BEGIN
cmap:=null;

END MAP;
/

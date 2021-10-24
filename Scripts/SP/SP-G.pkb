CREATE OR REPLACE PACKAGE BODY SP.G
as
-- Globals package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.08.2010
-- update 19.10.2010 03.11.2010 09.11.2010 13.04.2011 10.11.2011 02.02.2012
--        14.02.2012

-------------------------------------------------------------------------------
FUNCTION EQ(a1 NUMBER, a2 NUMBER) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return true; end if;
return false;
end EQ;

-------------------------------------------------------------------------------
FUNCTION EQ(a1 DATE, a2 DATE) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return true; end if;
return false;
end EQ;

-------------------------------------------------------------------------------
FUNCTION EQ(a1 VARCHAR2, a2 VARCHAR2) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return true; end if;
return false;
end EQ;

-------------------------------------------------------------------------------
FUNCTION EQ_R(a1 RAW, a2 RAW) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return true; end if;
return false;
end EQ_R;

-------------------------------------------------------------------------------
FUNCTION notEQ(a1 NUMBER, a2 NUMBER) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notEQ;

-------------------------------------------------------------------------------
FUNCTION notEQ(a1 DATE, a2 DATE) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notEQ;

-------------------------------------------------------------------------------
FUNCTION notEQ(a1 VARCHAR2, a2 VARCHAR2) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notEQ;

-------------------------------------------------------------------------------
FUNCTION notEQ_R(a1 RAW, a2 RAW) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notEQ_R;

-- SQL функции.
-------------------------------------------------------------------------------
FUNCTION S_EQ(a1 NUMBER, a2 NUMBER) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_EQ;

-------------------------------------------------------------------------------
FUNCTION S_EQ(a1 DATE, a2 DATE) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_EQ;

-------------------------------------------------------------------------------
FUNCTION S_EQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_EQ;

-------------------------------------------------------------------------------
FUNCTION S_EQ_R(a1 RAW, a2 RAW) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_EQ_R;

-------------------------------------------------------------------------------
FUNCTION S_notEQ(a1 NUMBER, a2 NUMBER) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 0; end if;
return 1;
end S_notEQ;

-------------------------------------------------------------------------------
FUNCTION S_notEQ(a1 DATE, a2 DATE) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 0; end if;
return 1;
end S_notEQ;

-------------------------------------------------------------------------------
FUNCTION S_notEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 0; end if;
return 1;
end S_notEQ;

FUNCTION S_notEQ_R(a1 RAW, a2 RAW) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 0; end if;
return 1;
end S_notEQ_R;

-- Функции, сравнивающие значения в верхнем регистре.
-------------------------------------------------------------------------------
FUNCTION UpEQ(a1 VARCHAR2, a2 VARCHAR2) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)=upper(a2);
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return true; end if;
return false;
end UpEQ;

-------------------------------------------------------------------------------
FUNCTION notUpEQ(a1 VARCHAR2, a2 VARCHAR2) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)!=upper(a2);
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notUpEQ;

-------------------------------------------------------------------------------
FUNCTION S_UpEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)=upper(a2);
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_UpEQ;

FUNCTION S_notUpEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)!=upper(a2);
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 0; end if;
return 1;
end S_notUpEQ;

-------------------------------------------------------------------------------
-- Функция возвращает истину, если значения параметров равны или оба нуллы.
FUNCTION EQ(V1 in SP.TValue, V2 in SP.TValue)return BOOLEAN
is
begin
  if V1.T != V2.T then return false; end if;
  if V1.T in (TDate, TNullDate) then return EQ(V1.D,V2.D); end if;
  if V1.T = TNoValue then return true; end if;
  if    SP.G.EQ(V1.E,V2.E)
	  and SP.G.EQ(V1.N,V2.N)
		and SP.G.EQ(V1.S,V2.S)
		and SP.G.EQ(V1.X,V2.X)
		and SP.G.EQ(V1.Y,V2.Y)
	then
	  return true;
	else
	  return false;
  end if;
end EQ;

-------------------------------------------------------------------------------
-- Функция возвращает 1, если значения параметров равны или оба нуллы,
-- иначе "0".
FUNCTION S_EQ(V1 in SP.TValue, V2 in SP.TValue)return NUMBER
is
begin
 if EQ(V1,V2)
 then
   return 1;
 else
   return 0;
 end if;
end S_EQ;

-------------------------------------------------------------------------------
-- Функция возвращает истину, если индекс присутствует в массиве
-- и значение в массиве с индексом во втором параметре равно третьему значению.
FUNCTION EQ(P in TMACRO_PARS, ParName in VARCHAR2, V in SP.TValue)
return BOOLEAN
is
begin
 if P.exists(ParName) then 
   return EQ(P(ParName),V);
 else
   return false;
 end if;
end EQ;

end G;
/

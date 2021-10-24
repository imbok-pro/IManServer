-- KARBUILDER Threads GetArrs
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.11.2009
-- update 24.12.2015
-------------------------------------------------------------------------------

-- Предоставляем массив, переданный из основного потока
-- THREADS.GetArrs.Num(Name).TNums(Index) или ThArrs.Num(Name)(Index)
-- -- пример
-- begin
-- ThArrs.Num('f')(1) :=5;
-- o(to_char(ThArrs.Num('f')(1)));
-- end;
-- /
CREATE or REPLACE PACKAGE THREADS.GetArrs
AS

type TNums is TABLE of NUMBER index by PLS_INTEGER;
type TNamNums is TABLE of TNums index by VARCHAR2(30);
type TVChars is TABLE of VARCHAR2(4000) index by PLS_INTEGER;
type TNamVChars is TABLE of TVChars index by VARCHAR2(30);
type TDats is TABLE of DATE index by PLS_INTEGER;
type TNamDats is TABLE of TDats index by VARCHAR2(30);
type TROWIDs is TABLE of ROWID index by PLS_INTEGER;
type TNamROWIDs is TABLE of TROWIDs index by VARCHAR2(30);
type TRAWs is TABLE of RAW(2000) index by PLS_INTEGER;
type TNamRAWs is TABLE of TRAWs index by VARCHAR2(30);

Num   TNamNums;
VChar TNamVChars;
Dat   TNamDats;
RID   TNamROWIDs;
RW    TNamRAWs;

end GetArrs;
/


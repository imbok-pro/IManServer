CREATE OR REPLACE PACKAGE BODY SP.STAIRWAY
-- STAIRWAY package body
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 06.07.2011, 
-- update 22.08.2011 26.08.2011 07.09.2011 25.05.2015
AS

-------------------------------------------------------------------------------
FUNCTION SetOfStairH return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
  n1 number;
  n2 number;
  cur number;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  n1:= 600;
  n2 := 4200;
  cur := n1;
  WHILE (cur <= n2) LOOP
    V_C.S_VALUE:=to_char(cur);
    V_C.COMMENTS:='Высота = '||to_char(cur)||' мм.';
    pipe row(V_C);
    cur := cur + 600;
  END LOOP;
  return;
end SetOfStairH;

-------------------------------------------------------------------------------
FUNCTION SetOfLadderH return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
  n1 number;
  n2 number;
  cur number;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  n2 := 7000;
  cur := 2200;
  V_C.S_VALUE:='';
  V_C.COMMENTS:='Стремянки нет.';
  pipe row(V_C);
  WHILE (cur <= n2) LOOP
    V_C.S_VALUE:=to_char(cur);
    V_C.COMMENTS:='Высота = '||to_char(cur)||' мм.';
    pipe row(V_C);
    cur := cur + 600;
  END LOOP;
  V_C.S_VALUE:='8200';
  V_C.COMMENTS:='Высота = '||to_char(cur)||' мм.';
  pipe row(V_C);
  return;
end SetOfLadderH;

-------------------------------------------------------------------------------
FUNCTION SetOfLanding return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
  n1 number;
  n2 number;
  cur number;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  n1:= 900;
  n2 := 2400;
  cur := n1;
  WHILE (cur <= n2) LOOP
    V_C.S_VALUE:='720 x '||to_char(cur);
    V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
    pipe row(V_C);
    V_C.S_VALUE:='920 x '||to_char(cur);
    V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
    pipe row(V_C);
    cur := cur + 300;
  END LOOP;
  V_C.S_VALUE:='720 x 3000';
  V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
  pipe row(V_C);
  V_C.S_VALUE:='920 x 3000';
  V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
  pipe row(V_C);
  cur := 3600;
  WHILE (cur <= 6000) LOOP
    V_C.S_VALUE:='700 x '||to_char(cur);
    V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
    pipe row(V_C);
    V_C.S_VALUE:='900 x '||to_char(cur);
    V_C.COMMENTS:='Размер лощадки - '||V_C.S_VALUE||' мм.';
    pipe row(V_C);
    cur := cur + 600;
  END LOOP;
  cur := cur + 300;
  return;
end SetOfLanding;

-------------------------------------------------------------------------------
PROCEDURE LandSV
		  (LandingSize IN VARCHAR2,V in out NOCOPY SP.TVALUE)
Is
begin
  for c1 in (select column_value s, rownum rnm 
     from table (SP.SET_FROM_STRING(LandingSize,'x')))
  loop
     case c1.rnm 
	   when 1 then
	     V.X := c1.s;
	   when 2 then
	     V.Y := c1.s;
	 else 
	   null;
	 end case;
  end loop;
end LandSV;  

-------------------------------------------------------------------------------
FUNCTION stairH( Floor number,
				 HFloor number,
				 HVar varchar2,
				 Litera varchar2) 
RETURN NUMBER
IS
tmpVar NUMBER;
tmpStr varchar2(100);
BEGIN
  select count(*) into tmpVar from(
    SELECT *
            FROM TABLE(SP.SET_FROM_STRING(HVar,';')) t)
   			WHERE COLUMN_VALUE like Litera||'_'||to_char(Floor)||'_%';
  if tmpVar = 1 then
    begin
	select COLUMN_VALUE into tmpStr from(
      SELECT *
            FROM TABLE(SP.SET_FROM_STRING(HVar,';')) t)
   			WHERE COLUMN_VALUE like Litera||'_'||to_char(Floor)||'_%';
	  select replace(tmpStr,Litera||'_'||to_char(Floor)||'_','') into tmpStr from dual; 
	return to_number(tmpStr);  
	exception when others then
	   d('SP.stairH некорректные значения для вычисления высоты этажа!'||
	      SQLERRM,'ERROR SP.stairH');
	   raise_application_error(-20033,
	   	'SP.stairH некорректные значения для вычисления высоты этажа!');
	end;
  else 
    return HFloor;  
  end if;
end stairH;

-------------------------------------------------------------------------------
FUNCTION SetOfRailH return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
  n1 number;
  n2 number;
  cur number;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  V_C.S_VALUE:='1000';
  V_C.COMMENTS:='Высота = 1000 мм.';
  pipe row(V_C);
  V_C.S_VALUE:='1200';
  V_C.COMMENTS:='Высота = 1200 мм.';
  pipe row(V_C);
  return;
end SetOfRailH;

-------------------------------------------------------------------------------
FUNCTION SetOfBarrierH return SP.TS_VALUES_COMMENTS pipelined
is
  V_C SP.TS_VALUE_COMMENTS;
  tmpVar NUMBER;
  n1 number;
  n2 number;
  cur number;
begin
  V_C:=SP.TS_VALUE_COMMENTS(null,null,null);
  n1:= 1240;
  n2 := 6040;
  cur := n1;
  WHILE (cur <= n2) LOOP
    V_C.S_VALUE:=to_char(cur);
    V_C.COMMENTS:='Высота = '||to_char(cur)||' мм.';
    pipe row(V_C);
    cur := cur + 600;
  END LOOP;
  return;
end SetOfBarrierH;
-------------------------------------------------------------------------------

FUNCTION GetRailVertL (H in number, alfa in number)return number
is
begin
  case alfa
    when 45 then
	case H 
	  when 1200 then 
	    return 500;
	  when 1800 then 
	    return 1350;
	  when 2400 then 
	    return 1100;
	  when 3000 then 
	    return 1500;
	  when 3600 then 
	    return 1300;
	  when 4200 then 
	    return 1500;
	  else 
	    return 0;
    end case;
	when 60 then
	case H 
	  when 1800 then 
	    return 720;
	  when 2400 then 
	    return 1420;
	  when 3000 then 
	    return 1050;
	  when 3600 then 
	    return 1400;
	  when 4200 then 
	    return 1150;
	  else 
	    return 0;
    end case;
	when 0 then
	case H 
	  when 900 then 
	    return 300;
	  when 1200 then 
	    return 600;
	  when 1500 then 
	    return 900;
	  when 1800 then 
	    return 1200;
	  when 2100 then 
	    return 1500;
	  when 2400 then 
	    return 900;
	  when 3000 then 
	    return 1200;
	  when 3600 then 
	    return 1500;
	  when 4200 then 
	    return 1200;
	  when 4800 then 
	    return 1400;
	  when 5400 then 
	    return 1200;
	  when 6000 then 
	    return 1350;
	  else 
	    return 0;
    end case;
	else
      return 0;
  end case;
end GetRailVertL;

-------------------------------------------------------------------------------

END STAIRWAY;
/

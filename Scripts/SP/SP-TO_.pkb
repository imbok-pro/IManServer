CREATE OR REPLACE PACKAGE BODY SP.TO_
-- TO_ packagebody
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- by Nikolai Krasilnikov
-- create 16.08.2010
-- update 01.12.2011 21.05.2015 11.06.2015 05.11.2015
as
--
FUNCTION STR(val in NUMBER)return VARCHAR2
is
BEGIN
  return to_char(val,'TM9','NLS_NUMERIC_CHARACTERS = ''. ''');
END;
--
FUNCTION STR(val in NUMBER, prec in NUMBER)return VARCHAR2
is
F VARCHAR2(100);
BEGIN
  if prec is null then return STR(val);end if;
  if not (prec between -20 and 20) then
		RAISE_APPLICATION_ERROR(-20033,
      'SP.TO_. Недопустимый спецификатор формата: '||prec||'!');
  end if;
  F:='9999999999999999999999999999999999999990';
  case prec
    when 0 then 
      null;
    when 1 then
      F:=F||'.9';
    when 2 then
      F:=F||'.99';
    when 3 then
      F:=F||'.999';
    when 4 then
      F:=F||'.999';
    when 5 then
      F:=F||'.999';
    when 6 then
      F:=F||'.999';
  else
    if prec > 0 then 
      F:=F||'.';
      for i in 1..prec 
      loop
        F:=F||'9';
      end loop;
--     else
--       F:=substr(F,-1,prec);
--       for i in 1..prec 
--       loop
--         F:=F||'0';
--       end loop;
    end if;    
  end case;
  return trim(to_char(round(val,prec),F,'NLS_NUMERIC_CHARACTERS = ''. '''));
END;
--
FUNCTION STR(val in BOOLEAN)return VARCHAR2
is
BEGIN
  return DEBUG_LOG.B2CHAR(val);
END;
--
FUNCTION STR return VARCHAR2
is
BEGIN
  return chr(10);
END;
--
FUNCTION STR(val in DATE)return VARCHAR2
is
BEGIN
  return to_char(val);
END;
--
FUNCTION STR(val in TIMESTAMP)return VARCHAR2
is
BEGIN
  return to_char(val);
END;
--
FUNCTION STR(val in RAW)return VARCHAR2
is
BEGIN
  return UTL_I18N.RAW_TO_CHAR(val);
END;
--
FUNCTION STR(val in SP.TVALUE)return VARCHAR2
is
BEGIN
  return SP.VAL_TO_STR(val);
END;
--
FUNCTION STR(val in SP.G.TMACRO_PARS)return VARCHAR2
is
S VARCHAR2(32000);
I VARCHAR2(4000);
BEGIN
  s:='';
  i:= val.first;
  while i is not null
  loop
    s := s ||' '||i||'=>'||nvl(SP.VAL_TO_STR(val(i)),'null');
    i:= val.next(i);
  end loop;
  return s;
END;
--
FUNCTION DATA(val in VARCHAR2)return RAW
is
BEGIN
  return UTL_I18N.STRING_TO_RAW(val);
END;
--
FUNCTION BIN(val in NUMBER, width in NUMBER default 31) return VARCHAR2
is
  v_result VARCHAR2(128);
  v_temp NUMBER;
  large_power_2 NUMBER;
BEGIN  
  if width>31 then 
		raise_application_error(-20033,
      'BDR.to_.bin. Width must be less or equal "31"!');
  end if;
  if val>2147483647 then 
		raise_application_error(-20033,
      'BDR.to_.bin. Val must be less or equal "2147483647"!');
  end if;
  v_temp:=bitand(val,power(2,width+1)-1);
  large_power_2:= power(2,width-1); -- max bits-1
  for i in 1 .. width -- must match NUMBER of bits
  loop   
    if v_temp >= large_power_2 then
      v_result := v_result || '1';
      v_temp := v_temp - large_power_2;
    else
      v_result := v_result || '0';
    end if;
    large_power_2 := trunc(large_power_2/2);
  end loop;
  return v_result; 
END;
--
FUNCTION HEX(val in NUMBER) return VARCHAR2
is
BEGIN
  return trim(to_char(val,
    'FMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'));
END;

end;
/

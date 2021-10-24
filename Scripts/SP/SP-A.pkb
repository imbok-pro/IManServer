CREATE OR REPLACE PACKAGE BODY SP.A
-- A package body
-- пакет кэширования параметров объекта
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.01.2018
-- update 18.01.2018 22.01.2018-23.01.2018 12.02.2018 31.07.2021

AS
F CONSTANT VARCHAR2(100) := 'YYYY-MM-DD_HH:MI:SS';
PP SP.G.TMACRO_PARS;

-------------------------------------------------------------------------------
FUNCTION getP return SP.G.TMACRO_PARS
is
begin
  return PP;
end getP;

-------------------------------------------------------------------------------
PROCEDURE setP(P in SP.G.TMACRO_PARS)
is
begin
  PP := P;
end setP;

-------------------------------------------------------------------------------
PROCEDURE S2ARR(S in VARCHAR2, V in out nocopy SP.TVALUE )
is
tmpVar NUMBER;
tmpD DATE;
begin
  tmpVar := instr(S, ' ',-1);
  V := SP.TVALUE(G.TARR);
  if tmpVar > 0 then
    V.S := trim(substr(S,1,tmpVar));
    V.D := to_Date(substr(S,tmpVar+1), F);
  else
    V.S := trim(S);
  end if;
  tmpVar := instr(S, '.',-1);
  if tmpVar = 0 or tmpVar is null then 
    V.N := 10; 
  else
    begin
      select ID into V.N from SP.GROUPS 
        where upper(NAME) = upper(substr(V.S,1,tmpVar-1));
    exception
      when no_data_found then 
        raise_application_error(-20033,
          'SP.A.S2ARR. Группа '||substr(V.S,1,tmpVar-1)||' отсутствует!');
    end;
    V.S := substr(V.S, tmpVar+1);
  end if;
end S2ARR;

-------------------------------------------------------------------------------
FUNCTION ARR2S(V in SP.TVALUE) return VARCHAR2
is
GroupName SP.GROUPS.NAME%type;
begin
  if V.T != g.TARR then
    raise_application_error(-20033,
      'SP.A.ARR2S. Тип '||V.T||' не является массивом!');
  end if;
  if V.N is null then
    return null;
  end if;
  begin
    select NAME into GroupName from SP.GROUPS where ID = V.N;
  exception
    when no_data_found then 
      raise_application_error(-20033,
        'SP.A.ARR2S. Группа '||V.N||' отсутствует!');
  end;
  return GroupName||'.'||V.S||' '||to_CHAR(V.D, F);
end ARR2S;

-------------------------------------------------------------------------------
function getValArr(V in SP.TVALUE) return TVals
is
  result TVals;
  Val TVal;
begin
  if V.T != G.TARR then
    raise_application_error(-20033,
      'SP.A.getValArr. Тип '||V.T||' не является массивом!');
  end if;
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.getValArr. Массив не определён!');
  end if;
  for rec in 
  (
    select * from SP.ARRAYS where GROUP_ID = V.N and NAME = V.S
      and (V.D is null or (ind_D = V.D))
  )
  loop
    Val.T := rec.TYPE_ID;
    Val.E := rec.E_VAL;
    Val.N := rec.N;
    Val.D := rec.D;
    Val.X := rec.X;
    Val.Y := rec.Y;
    result(rec.ind_X) := Val; 
    if   rec.Ind_Y is not null 
      or rec.Ind_Z is not null 
      or rec.Ind_S is not null 
      or (rec.Ind_D is not null and V.D is null)
    then  
      raise_application_error(-20033,
        'SP.A.getValArr. Массив '||to_.str(V)
        ||' не является одномерным массивом!');
    end if;  
  end loop;
  return result;
end getValArr;

-------------------------------------------------------------------------------
function getIntArr(V in SP.TVALUE) return TInts
is
  result TInts;
  tmpVals TVals;
begin
  tmpVals := getValArr(V);
  for i in tmpVals.first..tmpVals.last
  loop
    if not tmpVals.exists(i) then continue; end if;
    result(i) := tmpVals(i).N;
  end loop; 
  return result;
end getIntArr;

-------------------------------------------------------------------------------
function getDblArr(V in SP.TVALUE) return TDbls
is
  result TDbls;
  tmpVals TVals;
begin
  tmpVals := getValArr(V);
  for i in tmpVals.first..tmpVals.last
  loop
    if not tmpVals.exists(i) then continue; end if;
    result(i) := tmpVals(i).N;
  end loop; 
  return result;
end getDblArr;

-------------------------------------------------------------------------------
function get2DblArr(V in SP.TVALUE) return T2Dbls
is
  result T2Dbls;
  tmpVals TVals;
begin
  tmpVals := getValArr(V);
  for i in tmpVals.first..tmpVals.last
  loop
    if not tmpVals.exists(i) then continue; end if;
    if tmpVals(i).T != G.TXY then
      raise_application_error(-20033,
       'SP.A.get2DblArr. В массиве '||to_.str(V)||' встретился тип значения '
       ||V.T||', а не "XY"!');
    end if;
    result(i).X := tmpVals(i).X;
    result(i).Y := tmpVals(i).Y;
  end loop; 
  return result;
end get2DblArr;

PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals)
is
f pls_integer;
l pls_integer;
begin
  f := NEW_Vals.first;
  l := NEW_Vals.last;
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  delete from SP.ARRAYS where GROUP_ID = V.N and upper(NAME) = upper(V.S);
  for i in f..l
  loop
    if NEW_Vals.exists(i) then
      d(V.N||'  '||V.S||' '||i||' '||V.D, 'SP.A.Assign');
      insert into SP.ARRAYS
      (GROUP_ID, NAME, Ind_X, Ind_D, TYPE_ID, E_VAL, N, D, S, X, Y)
      values
      (V.N, V.S, i, V.D, NEW_Vals(i).T, NEW_Vals(i).E,
       NEW_Vals(i).N, NEW_Vals(i).D, NEW_Vals(i).S,
       NEW_Vals(i).X, NEW_Vals(i).Y);
    end if;
  end loop;
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals, OLD_Vals in TVals)
is
f pls_integer;
l pls_integer;
begin
  f := NEW_Vals.first;
  l := NEW_Vals.last;
  d(f||'  '||l, 'SP.A.Assign');
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  -- Удаляем все элементы массива вне диапазона (first-last) нового массива.
  delete from SP.ARRAYS 
    where GROUP_ID = V.N and upper(NAME) = upper(V.S)
      and Ind_X < f and Ind_X > l;
  -- в цикле по этому диапазону:
  for i in f..l
  loop
    case
      -- Если в новом массиве нет индекса, а в старом он был,
      when not NEW_Vals.exists(i) and OLD_Vals.exists(i) then
        -- то удаляем элемент из талицы из таблицы,
        delete from SP.ARRAYS 
          where GROUP_ID = V.N and upper(NAME) = upper(V.S)
            and Ind_X = i;
        continue;    
      -- иначе переходим к следующему элементу.
      when not NEW_Vals.exists(i) and not OLD_Vals.exists(i) then
        continue;
      -- Если элемента нет в массиве старых значений,
      when not OLD_Vals.exists(i) then
        d('3  ', 'SP.A.Assign');
        -- то добавляем элемент в таблицу,
        insert into SP.ARRAYS
        (GROUP_ID, NAME, Ind_X, Ind_D, TYPE_ID, E_VAL, N, D, S, X, Y)
        values
        (V.N, V.S, i, V.D, NEW_Vals(i).T, NEW_Vals(i).E,
         NEW_Vals(i).N, NEW_Vals(i).D, NEW_Vals(i).S,
         NEW_Vals(i).X, NEW_Vals(i).Y);
    else
      d('4  ', 'SP.A.Assign');
      -- иначе редактируем.
      update SP.ARRAYS set
      TYPE_ID = NEW_Vals(i).T,
      E_VAL = NEW_Vals(i).E, 
      N = NEW_Vals(i).N, 
      D = NEW_Vals(i).D, 
      S = NEW_Vals(i).S, 
      X = NEW_Vals(i).X, 
      Y = NEW_Vals(i).Y
      where GROUP_ID = V.N and upper(NAME) = upper(V.S)
        and Ind_X = i
        and (Ind_D = V.D or V.D is null);
    end case;
  end loop;
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts, OLD_Vals in TInts)
is
tmpNEWArr TVals;
tmpOLDArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).N := NEW_Vals(i);
    tmpNEWArr(i).T := G.TInteger;
  end loop;
  for i in OLD_Vals.first..OLD_Vals.last
  loop
    if not OLD_Vals.exists(i) then continue; end if;
    tmpOLDArr(i).N := OLD_Vals(i);
    tmpOLDArr(i).T := G.TInteger;
  end loop;
  Assign(V, tmpNEWArr, tmpOLDArr); 
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls, OLD_Vals in TDbls)
is
tmpNEWArr TVals;
tmpOLDArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).N := NEW_Vals(i);
    tmpNEWArr(i).T := G.TDouble;
  end loop;
  for i in OLD_Vals.first..OLD_Vals.last
  loop
    if not OLD_Vals.exists(i) then continue; end if;
    tmpOLDArr(i).N := OLD_Vals(i);
    tmpOLDArr(i).T := G.TDouble;
  end loop;
  Assign(V, tmpNEWArr, tmpOLDArr); 
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls, OLD_Vals in T2Dbls)
is
tmpNEWArr TVals;
tmpOLDArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).X := NEW_Vals(i).X;
    tmpNEWArr(i).Y := NEW_Vals(i).Y;
    tmpNEWArr(i).T := G.TXY;
  end loop;
  for i in OLD_Vals.first..OLD_Vals.last
  loop
    if not OLD_Vals.exists(i) then continue; end if;
    tmpOLDArr(i).X := OLD_Vals(i).X;
    tmpOLDArr(i).Y := OLD_Vals(i).Y;
    tmpOLDArr(i).T := G.TXY;
  end loop;
  Assign(V, tmpNEWArr, tmpOLDArr); 
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts)
is
tmpNEWArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).N := NEW_Vals(i);
    tmpNEWArr(i).T := G.TInteger;
  end loop;
  Assign(V, tmpNEWArr); 
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls)
is
tmpNEWArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).N := NEW_Vals(i);
    tmpNEWArr(i).T := G.TDouble;
  end loop;
  Assign(V, tmpNEWArr); 
end Assign;

-------------------------------------------------------------------------------
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls)
is
tmpNEWArr TVals;
begin
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.Assign. Массив не определён!');
  end if;
  for i in NEW_Vals.first..NEW_Vals.last
  loop
    if not NEW_Vals.exists(i) then continue; end if;
    tmpNEWArr(i).X := NEW_Vals(i).X;
    tmpNEWArr(i).Y := NEW_Vals(i).Y;
    tmpNEWArr(i).T := G.TXY;
  end loop;
  Assign(V, tmpNEWArr); 
end Assign;


-------------------------------------------------------------------------------
PROCEDURE forArr(V in SP.TVALUE, S in VARCHAR2,
                 P in out nocopy SP.G.TMACRO_PARS)
is
SS VARCHAR2(32000);
Sl VARCHAR2(128);
begin
  if V.T != G.TARR then
    raise_application_error(-20033,
      'SP.A.forArr. Тип '||V.T||' не является массивом!');
  end if;
  if V.S is null then
    raise_application_error(-20033,
      'SP.A.forArr. Массив не определён!');
  end if;
  if V.D is null then
    Sl := 'select * from SP.ARRAYS '||'
           where GROUP_ID = '||V.N||' and NAME = '''||V.S||'''';
  else
    Sl :='select * from SP.ARRAYS '||
         'where GROUP_ID = '||V.N||' and NAME = '''||V.S||
         ''' and ind_D = '||V.D;
  end if; 
  setP(P);     
  SS :='
  declare
  P SP.G.TMACRO_PARS;
  begin
    P := SP.A.getP;
    for rec in 
    (
    '||Sl||'
    )
    loop
    '||S||'
    null;
    end loop;
    SP.A.setP(P);
  exception
    when others then 
      d(SQLERRM, '' ERROR in SP.A.forArr'');
      raise;  
  end;
  ';
  execute immediate SS;
end forArr;

FUNCTION Val2TVALUE(Vals in TVals, i in binary_integer) return SP.TVALUE
is
begin
  return SP.TVALUE(ValueType => Vals(i).T,
                           E => Vals(i).E,
                           N => Vals(i).N,
                           D => Vals(i).D,
                        DisN => case when Vals(i).D is null then 1 else 0 end,
                           S => Vals(i).S,
                           X => Vals(i).X,
                           Y => Vals(i).Y);
end Val2TVALUE;
 
PROCEDURE TVALUE2Val(Vals in out nocopy TVALS, i in binary_integer,
                     V in SP.TVALUE)
is
begin
  Vals(i).T := V.T;
  Vals(i).E := V.E;
  Vals(i).N := V.N;
  Vals(i).D := V.D;
  Vals(i).S := V.S;
  Vals(i).X := V.X;
  Vals(i).Y := V.Y;
end TVALUE2Val;


END A;  

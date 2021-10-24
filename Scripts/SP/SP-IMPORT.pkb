CREATE OR REPLACE PACKAGE BODY SP.IMPORT
as
-- IMPORT package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010
-- update 13.10.2010 19.11.2010 24.11.2010 30.11.2010 13.12.2010 01.03.2011
--        21.12.2011 25.03.2013 03.04.2013 25.08.2013

function Script(item in VARCHAR2)return VARCHAR2
is
  -- Исходный текст из таблицы.
  inputScript DBMS_SQL.VARCHAR2A;
  -- Текст, подготовленный для компиляции.
  execScript DBMS_SQL.VARCHAR2A;
  -- Идентификатор курсора. 
  c NUMBER;
  -- Сообщение об ошибке.
  EM SP.COMMANDS.COMMENTS%type;
  -- Исполняемая строка скрипта.
  execLine PLS_INTEGER;
  -- Порядковый номер первой строки части скрипта.
  partLine PLS_INTEGER;
  -- Временные переменные.
  tmpVar  NUMBER;
  k PLS_INTEGER;
  GP SP.TGPAR;
  -- Функция выполняет скрипт, подготовленный в массиве execScript.
  function exec_part return BOOLEAN
  is
  begin
    -- Добавляем заключительные строки.
    -- Добавляем строку, выводящую отладочное сообщение об удачном выполнении
    -- последней строки скрипта.
	  execScript(execScript.last+1):=
	    'd('''||to_char(execLine)||' OK! '',''Import Script '||item||''');';
    -- Добавляем ключевое слово END.  
	  execScript(execScript.last+1):=' END;';
	  -- Записываем в отладчик получившийся скрипт.
	  for i in 1..execScript.last
	  loop
      -- Если текущая строка более 3500 символов, то разбиваем её на две.
      if length(execScript(i)) > 3500 then
	      d(to_char(partLine+i)||'_1 '|| substr(execScript(i),1,3500),
          'Import Script '||item);
	      d(to_char(partLine+i)||'_2 '|| substr(execScript(i),3501),
          'Import Script '||item);
      else
	      d(to_char(partLine+i)||' '|| execScript(i),'Import Script '||item);
      end if;  
	  end loop;
    -- Компилируем скрипт.
	  begin
	    dbms_sql.parse(c, execScript, 1, execScript.last, true, dbms_sql.native);
	  exception
		  when others then
		    if dbms_sql.is_open(c) then
		      dbms_sql.close_cursor(c);
		    end if;
	      EM:=SQLERRM;
	      d(EM,'ERROR parse Import.Script '||item);
	      EM:='ERROR parse Import.Script '||item||'  '||EM;
	      return false;
	  end;
	  -- Выполняем скрипт.
	  begin
	   tmpVar:=dbms_sql.execute(c);
	  exception
		  when others then
		    if dbms_sql.is_open(c) then
		      dbms_sql.close_cursor(c);
		    end if;
	      EM:=SQLERRM;
	      d(EM,'ERROR execute Import.Script '||item);
	      EM:='ERROR execute Import.Script '||item||'  '||EM;
	      return false;
	  end;
    return true;
  end exec_part;
--
--  
begin
  -- Проверяем создана ли копия глобальных параметров.
  -- Потому что, если пакет вызывается из скрипта первичной загрузки, то он
  -- работает от имени SYS и параметров нет.
  select count(*) into tmpVar from SP.WORK_GLOBAL_PAR_S;
  if tmpVar=0 then
	  -- Если нет, то создаём набор параметров по умолчанию.
		insert into SP.WORK_GLOBAL_PAR_S
		  select null,p.NAME,
	           p.TYPE_ID,pt.ROWID,E_VAL,N,D,S,X,Y,REACTION,R_ONLY
			  from SP.GLOBAL_PAR_S p,SP.PAR_TYPES pt
	        where pt.ID=p.TYPE_ID;
		commit;
		-- Выполняем блоки реакции глобальных параметров, если они определены.
		for rec in (select * from SP.WORK_GLOBAL_PAR_S
                   where REACTION is not null)
		loop
		  begin
			  SP.GPAR_REACTION(
				  rec.REACTION,
					SP.TGPAR(rec.NAME,
                   SP.TVALUE(rec.TYPE_ID,null,0,
								             rec.E_VAL,rec.N,rec.D,rec.S,rec.X,rec.Y))
								 				);
			exception
			  WHEN others THEN
          --Разрешаем выдачу отладочных сообщений.
          DEBUG_OUTPUT.SETSTATE(true);
          EM:='Ошибка при выполнении блока параметра: '||rec.Name||'!';
          D(EM,'ERROR SP.IMPORT');
          return EM;
			end;
		end loop;
    -- Pазрешаем выдачу отладочных сообщений.
    GP:=SP.TGPAR('DEBUG_MODE');
    GP.VAL.Assign(true);
    GP.save;
    -- Устанавливаем англииский язык как язык сессии.
    GP:=SP.TGPAR('NLS_Language');
    GP.VAL.Assign('EN');
    GP.save;
  end if;
  -- Загружаем скрипт.
  select Line bulk collect into inputScript from SP_IO.CLIENT_SCRIPTS
    where upper(SCRIPT)=item
    order by LINE_NUM;
  if inputScript.first is null then
    d(item||' is empty?!!!','Import ClientScript');
    return null;
  end if;
  -- Добавляем первую строку.
  execScript(1):='BEGIN ';
  execLine:=1;
  partLine:=0;
  k:=1;
	c:=dbms_sql.open_cursor;
  -- Формируем части скрипта длиной в block_size строк,
  -- выстраивая каждый вызов пакета INPUT в одну строку.
  for i in inputScript.first..inputScript.last
  loop
    -- Начинаем новую строку выходного скрипта,
    -- если  строка входного скрипта начинается с вызова пакета INPUT.
    if instr(inputScript(i),'SP.INPUT.') = 1 then
	    -- Если число строк в скрипте более block_size,
	    -- то выполняем часть скрипта.
	    if k >= block_size then
		    -- Если возникла ошибка, то возвращаемся из функции.
		    if not exec_part then return EM; end if;
        execScript.delete;
        k:=1;
		    -- Добавляем BEGIN к следующей части скрипта.
		    execScript(k):='BEGIN ';
        partLine:=execLine;
		    execLine:=execLine+1;
	    end if;  
      if k > 1 then
        execScript(execScript.last+1):=
          'd('''||to_char(execLine)||' OK! '',''Import Script '||item||''');';
        k:=k+1;
        execLine:=execLine+1;
      end if;    
      k:=k+1;
      execLine:=execLine+1;
      execScript(k):=inputScript(i);
    else
      execScript(k):=execScript(k)||inputScript(i);
    end if;
  end loop;
  -- Выполняем последнюю часть скрипта, .
  if not exec_part then return EM; end if;
  dbms_sql.close_cursor(c);
  return null;
exception
  when others then
    if dbms_sql.is_open(c) then
      dbms_sql.close_cursor(c);
    end if;
    EM:=SQLERRM;
    d(SQLERRM,'Other!!! ERROR Import.Script '||item);
    return 'Other!!! ERROR Import.Script '||item||'  '||EM;
end Script;

end IMPORT;
/

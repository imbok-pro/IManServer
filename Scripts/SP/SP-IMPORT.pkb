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
  -- �������� ����� �� �������.
  inputScript DBMS_SQL.VARCHAR2A;
  -- �����, �������������� ��� ����������.
  execScript DBMS_SQL.VARCHAR2A;
  -- ������������� �������. 
  c NUMBER;
  -- ��������� �� ������.
  EM SP.COMMANDS.COMMENTS%type;
  -- ����������� ������ �������.
  execLine PLS_INTEGER;
  -- ���������� ����� ������ ������ ����� �������.
  partLine PLS_INTEGER;
  -- ��������� ����������.
  tmpVar  NUMBER;
  k PLS_INTEGER;
  GP SP.TGPAR;
  -- ������� ��������� ������, �������������� � ������� execScript.
  function exec_part return BOOLEAN
  is
  begin
    -- ��������� �������������� ������.
    -- ��������� ������, ��������� ���������� ��������� �� ������� ����������
    -- ��������� ������ �������.
	  execScript(execScript.last+1):=
	    'd('''||to_char(execLine)||' OK! '',''Import Script '||item||''');';
    -- ��������� �������� ����� END.  
	  execScript(execScript.last+1):=' END;';
	  -- ���������� � �������� ������������ ������.
	  for i in 1..execScript.last
	  loop
      -- ���� ������� ������ ����� 3500 ��������, �� ��������� � �� ���.
      if length(execScript(i)) > 3500 then
	      d(to_char(partLine+i)||'_1 '|| substr(execScript(i),1,3500),
          'Import Script '||item);
	      d(to_char(partLine+i)||'_2 '|| substr(execScript(i),3501),
          'Import Script '||item);
      else
	      d(to_char(partLine+i)||' '|| execScript(i),'Import Script '||item);
      end if;  
	  end loop;
    -- ����������� ������.
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
	  -- ��������� ������.
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
  -- ��������� ������� �� ����� ���������� ����������.
  -- ������ ���, ���� ����� ���������� �� ������� ��������� ��������, �� ��
  -- �������� �� ����� SYS � ���������� ���.
  select count(*) into tmpVar from SP.WORK_GLOBAL_PAR_S;
  if tmpVar=0 then
	  -- ���� ���, �� ������ ����� ���������� �� ���������.
		insert into SP.WORK_GLOBAL_PAR_S
		  select null,p.NAME,
	           p.TYPE_ID,pt.ROWID,E_VAL,N,D,S,X,Y,REACTION,R_ONLY
			  from SP.GLOBAL_PAR_S p,SP.PAR_TYPES pt
	        where pt.ID=p.TYPE_ID;
		commit;
		-- ��������� ����� ������� ���������� ����������, ���� ��� ����������.
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
          --��������� ������ ���������� ���������.
          DEBUG_OUTPUT.SETSTATE(true);
          EM:='������ ��� ���������� ����� ���������: '||rec.Name||'!';
          D(EM,'ERROR SP.IMPORT');
          return EM;
			end;
		end loop;
    -- P�������� ������ ���������� ���������.
    GP:=SP.TGPAR('DEBUG_MODE');
    GP.VAL.Assign(true);
    GP.save;
    -- ������������� ���������� ���� ��� ���� ������.
    GP:=SP.TGPAR('NLS_Language');
    GP.VAL.Assign('EN');
    GP.save;
  end if;
  -- ��������� ������.
  select Line bulk collect into inputScript from SP_IO.CLIENT_SCRIPTS
    where upper(SCRIPT)=item
    order by LINE_NUM;
  if inputScript.first is null then
    d(item||' is empty?!!!','Import ClientScript');
    return null;
  end if;
  -- ��������� ������ ������.
  execScript(1):='BEGIN ';
  execLine:=1;
  partLine:=0;
  k:=1;
	c:=dbms_sql.open_cursor;
  -- ��������� ����� ������� ������ � block_size �����,
  -- ���������� ������ ����� ������ INPUT � ���� ������.
  for i in inputScript.first..inputScript.last
  loop
    -- �������� ����� ������ ��������� �������,
    -- ����  ������ �������� ������� ���������� � ������ ������ INPUT.
    if instr(inputScript(i),'SP.INPUT.') = 1 then
	    -- ���� ����� ����� � ������� ����� block_size,
	    -- �� ��������� ����� �������.
	    if k >= block_size then
		    -- ���� �������� ������, �� ������������ �� �������.
		    if not exec_part then return EM; end if;
        execScript.delete;
        k:=1;
		    -- ��������� BEGIN � ��������� ����� �������.
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
  -- ��������� ��������� ����� �������, .
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

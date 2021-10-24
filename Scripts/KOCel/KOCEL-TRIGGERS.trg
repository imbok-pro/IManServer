-- KOCEL tables triggers 
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 27.04.2009 01.02.2010 16.02.2010 02.03.2020
--*****************************************************************************

-- �����.
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.SHEETS_bir
BEFORE INSERT ON KOCEL.SHEETS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
BEGIN
  -- ���� ���� ���� �� ����, �� ������ � ����� ������ ������.
	if :NEW.D is not null then
	  :NEW.N:=null;
		:NEW.S:=null;
	else 
	-- ���� ���� ���� ����, �� ���� ����� �� ����, �� ������ ����.
	  if :NEW.N is not null then 
		  :NEW.S:=null;
		end if;		
	end if;
--	  raise_application_Error(-20443,'!!!! ');
  if :NEW.Fmt is null then :NEW.Fmt:=0; end if;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.SHEETS_bur
BEFORE UPDATE ON KOCEL.SHEETS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  -- ���, �������, ����� � ���� �������� ������ - ����� ������� � ��������.
	:NEW.R:=:OLD.R;
	:NEW.C:=:OLD.C;
	:NEW.BOOK:=:OLD.BOOK;
	:NEW.SHEET:=:OLD.SHEET;
  -- ���� ���� ���� ���� ����, � ����� �� ����,
	-- �� ������ � ����� ������ ������.
	if (:NEW.D is not null) and (:OLD.D is NULL)  then
	  :NEW.N:=null;
		:NEW.S:=null;
		return;
	end if;
  -- ���� ���� ����� ���� ����, � ����� �� ����,
	-- �� ������ � ���� ������ ������.
	if (:NEW.N is not null) and (:OLD.N is NULL)  then
	  :NEW.D:=null;
		:NEW.S:=null;
		return;
	end if;
  -- ���� ���� ������ ���� ����, � ����� �� ����,
	-- �� ���� � ����� ������ ������.
	if (:NEW.S is not null) and (:OLD.S is NULL)  then
	  :NEW.N:=null;
		:NEW.D:=null;
		return;
	end if;
--	  raise_application_Error(-20443,'!!!! ');
  if :NEW.Fmt is null then :NEW.Fmt:=0; end if;
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.SHEETS_aur
AFTER UPDATE ON KOCEL.SHEETS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
  if :OLD.R=0 and :OLD.C=0 then return; end if;
  -- ���� ������ ������ �������, �� ������ ������ � ���� ����� �������.
  if :NEW.Fmt != :OLD.Fmt and :OLD.R=0 then
    update KOCEL.SHEETS set Fmt=:NEW.Fmt
      where R>0
        and C=:OLD.C
        and upper(SHEET)=upper(:NEW.SHEET)
        and upper(BOOK)=upper(:NEW.BOOK);
    return;    
  end if;
  -- ���� ������ ������ ����, �� ������ ������ � ���� ����� ����.
  if :NEW.Fmt != :OLD.Fmt and :OLD.R=0 then
    update KOCEL.SHEETS set Fmt=:NEW.Fmt
      where C>0
        and R=:OLD.R
        and upper(SHEET)=upper(:NEW.SHEET)
        and upper(BOOK)=upper(:NEW.BOOK);
  end if;
END;
/
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE_TABLE----------------------------------------------------------
--
--AFTER_DELETE_TABLE----------------------------------------------------------
--
--*****************************************************************************

-- �������.
--BEFORE_INSERT_TABLE----------------------------------------------------------
--
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.FORMATS_bir
BEFORE INSERT ON KOCEL.FORMATS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
BEGIN
--  IF ReplSession THEN return; END IF;
  SELECT KOCEL.FORMAT_SEQ.NEXTVAL INTO :NEW.Fmt FROM DUAL;
--  :NEW.Fmt := :NEW.Fmt+REPLICATION.NODE_ID;
  IF :NEW.FORMAT_STRING is null THEN :NEW.FORMAT_STRING:='GENERAL';END IF;
END;
/
--AFTER_INSERT-----------------------------------------------------------------
--
--AFTER_INSERT_TABLE-----------------------------------------------------------
--
--BEFORE_UPDATE_TABLE----------------------------------------------------------
--
--BEFORE_UPDATE----------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.FORMATS_bur
BEFORE UPDATE ON KOCEL.FORMATS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
BEGIN
  raise_application_Error(-20443,
    'KOCEL.FORMATS_bur. �������������� ���������! ����� ������� � ��������.');
END;
/
--AFTER_UPDATE-----------------------------------------------------------------
--
--AFTER_UPDATE_TABLE-----------------------------------------------------------
--
--BEFORE_DELETE_TABLE----------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.FORMATS_bdr
BEFORE DELETE ON KOCEL.FORMATS
FOR EACH ROW
-- (KOCEL_TRIGGERS.trg)
BEGIN
  if :OLD.Fmt<100 then
    raise_application_Error(-20443,
      'KOCEL.FORMATS_bur. ��������� ������� ���������� �������!');
  end if;
END;
/
--AFTER_DELETE_TABLE----------------------------------------------------------
--
--*****************************************************************************

-- ������������� ����������� �����.
--INSTEAD_OF_INSERT------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_MERGED_CELLS_ii
INSTEAD OF INSERT ON KOCEL.V_MERGED_CELLS
-- (KOCEL_TRIGGERS.trg)
DECLARE
  type TMS is record(RID ROWID, L NUMBER,T NUMBER,R NUMBER,B NUMBER);
  type TMSS is TABLE of TMS;
  MSS TMSS;
  i PLS_INTEGER;
BEGIN
  -- ���������, ��� � ������������ ��������� ����� ��� ����������� � ���,
  -- ������������� �����������.
  -- ���� ����������� ���, �� ��������� ����� ��������.
  -- ���� ����������� ����������, �� ������� ��������� �� ��� �����������,
  -- ��������� � �� ��� ������ � ������� ���������.
  select ROWID RID, L,T,R,B bulk collect into MSS from KOCEL.MERGED_CELLS
    where upper(SHEET)=upper(:NEW.SHEET)
      and upper(BOOK)=upper(:NEW.BOOK)
      and L between :NEW.L and :NEW.R 
      and T between :NEW.T and :NEW.B 
      and R between :NEW.L and :NEW.R
      and B between :NEW.T and :NEW.B;
  if MSS.count=0 then
    insert into KOCEL.MERGED_CELLS values (
      :NEW.L, :NEW.T, :NEW.R, :NEW.B, :NEW.SHEET, :NEW.BOOK);
    return;    
  end if;
  i:=MSS.last;      
  for j in MSS.first..i   
  loop
    MSS(i).L:=least(MSS(i).L, MSS(j).L);
    MSS(i).T:=least(MSS(i).T, MSS(j).T);
    MSS(i).R:=greatest(MSS(i).R,MSS(j).R);
    MSS(i).L:=greatest(MSS(i).B,MSS(j).B);
    if i!=j then
      delete from KOCEL.MERGED_CELLS where ROWID=MSS(j).RID;
    end if;  
  end loop;    
    MSS(i).L:=least(MSS(i).L,:NEW.L);
    MSS(i).T:=least(MSS(i).T,:NEW.T);
    MSS(i).R:=greatest(MSS(i).R,:NEW.R);
    MSS(i).L:=greatest(MSS(i).B,:NEW.B);
  update KOCEL.MERGED_CELLS set 
    L=MSS(i).L,
    T=MSS(i).T,
    R=MSS(i).R,
    B=MSS(i).B
    where ROWID=MSS(i).RID;
END;
/
--
--INSTEAD_OF_UPDATE------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_MERGED_CELLS_iu
INSTEAD OF UPDATE ON KOCEL.V_MERGED_CELLS
-- (KOCEL_TRIGGERS.trg)
DECLARE
  type TMS is record(RID ROWID, L NUMBER,T NUMBER,R NUMBER,B NUMBER);
  type TMSS is TABLE of TMS;
  MSS TMSS;
  i PLS_INTEGER;
BEGIN
  -- ������� ��� ������������ ���������, � �������� ��������� ����������� �
  -- ���������� ���������.
  -- �������� ��������, ��������� ��� �������������� ���������.
  -- ������� ��������� ���������.
  select ROWID RID, L,T,R,B bulk collect into MSS from KOCEL.MERGED_CELLS
    where upper(SHEET)=upper(:OLD.SHEET)
      and upper(BOOK)=upper(:OLD.BOOK)
      and L between :NEW.L and :NEW.R 
      and T between :NEW.T and :NEW.B 
      and R between :NEW.L and :NEW.R
      and B between :NEW.T and :NEW.B;
  if MSS.count=0 then
  update KOCEL.MERGED_CELLS set 
    L=:NEW.L,
    T=:NEW.T,
    R=:NEW.R,
    B=:NEW.B
    where L =:OLD.L
      and T =:OLD.T 
      and R =:OLD.R 
      and B =:OLD.B 
      and  upper(SHEET)=upper(:OLD.SHEET)
      and upper(BOOK)=upper(:OLD.BOOK);
    return;    
  end if;      
  i:=MSS.last;      
  for j in MSS.first..i   
  loop
    MSS(i).L:=least(MSS(i).L, MSS(j).L);
    MSS(i).T:=least(MSS(i).T, MSS(j).T);
    MSS(i).R:=greatest(MSS(i).R,MSS(j).R);
    MSS(i).L:=greatest(MSS(i).B,MSS(j).B);
    delete from KOCEL.MERGED_CELLS where ROWID=MSS(j).RID;
  end loop;    
  MSS(i).L:=least(MSS(i).L,:NEW.L);
  MSS(i).T:=least(MSS(i).T,:NEW.T);
  MSS(i).R:=greatest(MSS(i).R,:NEW.R);
  MSS(i).L:=greatest(MSS(i).B,:NEW.B);
  update KOCEL.MERGED_CELLS set 
    L=MSS(i).L,
    T=MSS(i).T,
    R=MSS(i).R,
    B=MSS(i).B
    where L =:OLD.L
      and T =:OLD.T 
      and R =:OLD.R 
      and B =:OLD.B 
      and  upper(SHEET)=upper(:OLD.SHEET)
      and upper(BOOK)=upper(:OLD.BOOK);
END;
/
--
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_MERGED_CELLS_id
INSTEAD OF DELETE ON KOCEL.V_MERGED_CELLS
-- (KOCEL_TRIGGERS.trg)
BEGIN
  delete from KOCEL.V_MERGED_CELLS 
    where L=:OLD.L 
      and T=:OLD.T 
      and upper(SHEET)=upper(:OLD.SHEET) 
      and upper(BOOK)=upper(:OLD.BOOK);
END;
/

--*****************************************************************************

-- ������������� ���������� ������.
--INSTEAD_OF_INSERT------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_SHEET_PARS_ii
INSTEAD OF INSERT ON KOCEL.V_SHEET_PARS
-- (KOCEL_TRIGGERS.trg)
DECLARE
  NewN NUMBER;
  NewD DATE;
  NewS KOCEL.SHEET_PARS.S%type;
BEGIN
  NewN:=null;
  NewD:=null;
  NewS:=null;
  -- ���� �������� ���� ��������� �� ����, �� ��������� � ������������
  -- � �����.
  case 
    when upper(:NEW.T)='N' then 
      NewN:=:NEW.N;
      NewD:=null;
      NewS:=null;
    when upper(:NEW.T)='D' then 
      NewN:=null;
      NewD:=:NEW.D;
      NewS:=null;
    when upper(:NEW.T)='S' then 
      NewN:=null;
      NewD:=null;
      NewS:=:NEW.S;
    -- ���� ��� ����, �� ������� ���������.
    when :NEW.T is null then 
      case 
        -- ���� ���� "N" �� ����, �� ������� � ���� ������ ���� "N".
        when :NEW.N is not null then NewN:=:NEW.N; 
        -- ���� ���� "D" �� ����, �� ������� � ���� ������ ���� "D".
        when :NEW.D is not null then NewD:=:NEW.D; 
      -- ���� ���� "N" � "D" ����, �� ������� � ���� ������ ���� "S".
      else
        NewS:=:NEW.S;
      end case;
  else
    -- ���� ��� �� ��������� ��������, �� ������.
    raise_application_Error(-20443,
      'KOCEL.V_SHEET_PARS_ii. �������� ��� ���������!');
  end case;
  -- ���� �������� ��� ����������, �� ����������� �������� ���������.
  -- ���� �������� �����������, �� ��������� ����� ��������.
  if :NEW.SHEET is null then
    update KOCEL.SHEET_PARS
      set N=NewN,D=NewD,S=NewS
      where SHEET ='*'
        and BOOK=:NEW.BOOK
        and PAR_NAME=:NEW.PAR_NAME;
  else
    update KOCEL.SHEET_PARS
      set N=NewN,D=NewD,S=NewS
      where SHEET=:NEW.SHEET
        and BOOK=:NEW.BOOK
        and PAR_NAME=:NEW.PAR_NAME;
  end if;
  if SQL%rowcount = 0 then
    if :NEW.SHEET is null then
	    insert into KOCEL.SHEET_PARS 
	      values(:NEW.PAR_NAME,NewN,NewD,NewS,'*',:NEW.BOOK);
    else  
	    insert into KOCEL.SHEET_PARS 
	      values(:NEW.PAR_NAME,NewN,NewD,NewS,:NEW.SHEET,:NEW.BOOK);
    end if;  
  end if;
END;
/
--
--INSTEAD_OF_UPDATE------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_SHEET_PARS_iu
INSTEAD OF UPDATE ON KOCEL.V_SHEET_PARS
-- (KOCEL_TRIGGERS.trg)
DECLARE
  NewN NUMBER;
  NewD DATE;
  NewS KOCEL.SHEET_PARS.S%type;
BEGIN
  NewN:=null;
  NewD:=null;
  NewS:=null;
  -- ���� �������� ���� ��������� �� ����, �� ��������� � ������������
  -- � �����.
  case 
    when upper(:NEW.T)='N' then 
      NewN:=:NEW.N;
      NewD:=null;
      NewS:=null;
    when upper(:NEW.T)='D' then
      NewN:=null;
      NewD:=:NEW.D;
      NewS:=null;
    when upper(:NEW.T)='S' then 
      NewN:=null;
      NewD:=null;
      NewS:=:NEW.S;
    -- ���� ��� ����, �� ������� ���������.
    when :NEW.T is null then 
      case 
        -- ���� ���� "N" �� ����, �� ������� � ���� ������ ���� "N".
        when :NEW.N is not null then NewN:=:NEW.N; 
        -- ���� ���� "D" �� ����, �� ������� � ���� ������ ���� "D".
        when :NEW.D is not null then NewD:=:NEW.D; 
      -- ���� ���� "N" � "D" ����, �� ������� � ���� ������ ���� "S".
      else
        NewS:=:NEW.S;
      end case;
  else
    -- ���� ��� �� ��������� ��������, �� ������.
    raise_application_Error(-20443,
      'KOCEL.V_SHEET_PARS_ii. �������� ��� ���������!');
  end case;
  -- ���� �������� ��� ���������, ����� ��� ����, �� ������.
  if not(     :OLD.PAR_NAME=:NEW.PAR_NAME 
         and (   (:NEW.SHEET=:OLD.SHEET)
              or (:NEW.SHEET is null and :OLD.SHEET is null) )
         and :OLD.BOOK=:NEW.BOOK)      
  then
    raise_application_Error(-20443,
      'KOCEL.V_SHEET_PARS_iu. �������� ����� ������ �������� ���������!');
  end if;
  -- ���� �������� ��� ����������, �� ����������� �������� ���������.
  -- ���� �������� �����������, �� ��������� ����� ��������.
  if :OLD.SHEET is null then
    update KOCEL.SHEET_PARS
      set N=NewN,D=NewD,S=NewS
      where SHEET ='*'
        and BOOK=:OLD.BOOK
        and PAR_NAME=:OLD.PAR_NAME;
  else
    update KOCEL.SHEET_PARS
      set N=NewN,D=NewD,S=NewS
      where SHEET=:OLD.SHEET
        and BOOK=:OLD.BOOK
        and PAR_NAME=:OLD.PAR_NAME;
  end if;
  if SQL%rowcount = 0 then
    if :OLD.SHEET is null then
	    insert into KOCEL.SHEET_PARS 
	      values(:OLD.PAR_NAME,NewN,NewD,NewS,'*',:OLD.BOOK);
    else    
	    insert into KOCEL.SHEET_PARS 
	      values(:OLD.PAR_NAME,NewN,NewD,NewS,:OLD.SHEET,:OLD.BOOK);
    end if;    
  end if;
END;
/
--
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER KOCEL.V_SHEET_PARS_id
INSTEAD OF DELETE ON KOCEL.V_SHEET_PARS
-- (KOCEL_TRIGGERS.trg)
BEGIN
  return;
END;
/

--*****************************************************************************


--*****************************************************************************
-- ����� �������� 


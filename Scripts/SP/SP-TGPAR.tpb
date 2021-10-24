CREATE OR REPLACE TYPE BODY SP.TGPAR
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 22.09.2010 13.10.2010 19.10.2010 17.11.2010 10.12.2010 12.09.2017
--        07.11.2017 10.01.2019
--****************************************************************************
as

/* —оздание нулл параметра.*/
CONSTRUCTOR FUNCTION TGPAR
return SELF AS RESULT
is
begin
  self.Name:=null;
	self.Val:=SP.TVALUE;
	return;
end;

/* «агрузка текущего (из рабочей таблицы) параметра.*/
-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TGPAR(Name in VARCHAR2)
return SELF AS RESULT
is
ro number;
gID number;
begin
  self:=TGPAR;
	self.NAME:=Name;
	begin
	  select g.TYPE_ID,g.E_VAL,g.N,g.D,g.S,g.X,g.Y, G.R_ONLY, g.UG_ID
	    into self.Val.T, self.Val.E,
			     self.Val.N, self.Val.D, self.Val.S, self.Val.X, self.Val.Y,
           ro, gID
	    from SP.WORK_GLOBAL_PAR_S g
	    where upper(g.Name)=upper(self.Name);
	exception
	  when no_data_found then
       if NAME ='ServerService' then
         self.Val.T := 5;
         self.Val.E := 'true';
         self.Val.N := 1;
         --self.Val.D := null;
         --self.Val.S := '';
         --self.Val.X := null;
         --self.Val.Y := null;
         --ro = 1;
         --gID
         return;
       end if;
       RAISE_APPLICATION_ERROR(-20033,'SP.TGPAR. GPar '||Name||' missing!');
	end;
  -- ≈сли параметр только дл€ чтени€, то читаем значение из посто€нных таблиц.
  if ro = 1 then
    begin
      if gID is null then
        select g.E_VAL,g.N,g.D,g.S,g.X,g.Y
          into self.Val.E,
               self.Val.N, self.Val.D, self.Val.S, self.Val.X, self.Val.Y
          from SP.GLOBAL_PAR_S g
          where upper(g.Name)=upper(self.Name);
      else
        select g.E_VAL,g.N,g.D,g.S,g.X,g.Y
          into self.Val.E,
               self.Val.N, self.Val.D, self.Val.S, self.Val.X, self.Val.Y
          from SP.USERS_GLOBALS g
          where g.ID = gID;
      end if;  
    exception
      when no_data_found then
         RAISE_APPLICATION_ERROR(-20033,'SP.TGPAR. GPar '||Name||
           ' unExpected ERROR!');
    end;     
  end if;
  return;
end TGPAR;

/* ќбъединение имени параметра и его строкового значени€ 
!!! возможно что две строки длиннее 3900 станут равны,
если отличаютс€ в последних байтах*/
-------------------------------------------------------------------------------
MAP MEMBER FUNCTION map_globals(self IN OUT NOCOPY SP.TGPAR)
return VARCHAR2
is
begin
  return self.name||self.Val.asString;
end map_globals;

/* —охранение параметра в таблицу обновлЄнных параметров).*/
-------------------------------------------------------------------------------
MEMBER PROCEDURE Save(self IN OUT  NOCOPY SP.TGPAR)
is
pragma autonomous_transaction;
begin
  -- ≈сли значение именованное, то подставл€ем значение
	if self.Val.E is not null then  
  	begin
	  	select e.N,e.D,e.S,e.X,e.Y 
        into self.Val.N,self.Val.D,self.Val.S,self.Val.X,self.Val.Y
        from SP.ENUM_VAL_S e
	  	  where e.TYPE_ID=self.Val.T and upper(e.E_VAL)=upper(self.Val.E);
		exception
			  when no_data_found then	
          rollback;
				  RAISE_APPLICATION_ERROR(-20033,
		      'SP.TGPAR. »менованное значение '||self.Val.E||
				  ' не найдено, дл€ параметра '||self.Name);
		end;
  end if; 
    update SP.WORK_GLOBAL_PAR_S
      set E_Val=self.Val.E,N=self.Val.N,D=self.Val.D,S=self.Val.S,
      		X=self.Val.X ,Y=self.Val.Y
      where upper(NAME) = upper(self.Name);
    commit;  
end Save;

end;
/


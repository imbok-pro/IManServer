CREATE OR REPLACE TYPE BODY KOCEL.TFORMAT 
-- KOCEL.TFORMAT Type body
-- create 14.05.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 19.01.2015
--*****************************************************************************
as

/* Загрузка из базы. Если Fmt нулл или не существует,
  то создаётся новый формат с параметрами по умолчанию.*/
-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TFORMAT( Fmt in NUMBER default null)
return SELF AS RESULT
is
  tmpVar NUMBER;
  dflt BOOLEAN;
begin
  self.Tag:=null;
  dflt:=true;
  if (Fmt is not null) and (Fmt > 0) then 
	  dflt:=false;
	  tmpVar:=Fmt;
	  begin
		  select Fmt, Font_Name, Font_Size20, Font_Color, Font_Style,
		    Font_Underline, Font_Family, Font_CharSet, Left_Style, Left_Color,
		    Right_Style, Right_Color, Top_Style, Top_Color, Bottom_Style,
		    Bottom_Color, Diagonal, Diagonal_Style, Diagonal_Color, Format_String,
		    Fill_Pattern, Fill_FgColor, Fill_BgColor, H_Alignment, V_Alignment,
		    E_Locked, E_Hidden, Parent_Fmt, Wrap_Text, Shrink_To_Fit,
		    Text_Rotation,Text_Indent
			  into self.Fmt, self.Font_Name, self.Font_Size20, self.Font_Color,
			   self.Font_Style, self.Font_Underline, self.Font_Family,
	       self.Font_CharSet, self.Left_Style, self.Left_Color, self.Right_Style,
	       self.Right_Color, self.Top_Style, self.Top_Color, self.Bottom_Style,
	       self.Bottom_Color, self.Diagonal, self.Diagonal_Style,
	       self.Diagonal_Color, self.Format_String, self.Fill_Pattern,
	       self.Fill_FgColor, self.Fill_BgColor, self.H_Alignment,
	       self.V_Alignment, self.E_Locked, self.E_Hidden, self.Parent_Fmt,
	       self.Wrap_Text, self.Shrink_To_Fit, self.Text_Rotation,
         self.Text_Indent
		   from KOCEL.FORMATS where Fmt=tmpVar;
	  exception
	    when no_data_found then dflt:=true;
	  end;
  end if;  
  if dflt then
    self.Fmt:=0;
    self.Font_Name:='Arial';
    self.Font_Size20:=200;
    self.Font_Color:=KOCEL.FORMAT.clDefault;
		self.Font_Style:=0;
    self.Font_Underline:=KOCEL.FORMAT.u_None;
    self.Font_Family:=0;
    self.Font_CharSet:=0;
    self.Left_Style:=KOCEL.FORMAT.bs_None;
    self.Left_Color:=KOCEL.FORMAT.clNone;
    self.Right_Style:=KOCEL.FORMAT.bs_None;
	  self.Right_Color:=KOCEL.FORMAT.clNone;
    self.Top_Style:=KOCEL.FORMAT.bs_None;
    self.Top_Color:=KOCEL.FORMAT.clNone;
    self.Bottom_Style:=KOCEL.FORMAT.bs_None;
    self.Bottom_Color:=KOCEL.FORMAT.clNone;
    self.Diagonal:=KOCEL.FORMAT.db_None;
    self.Diagonal_Style:=KOCEL.FORMAT.bs_None;
    self.Diagonal_Color:=KOCEL.FORMAT.clNone;
    self.Format_String:='GENERAL';
    self.Fill_Pattern:=KOCEL.FORMAT.ps_None;
	  self.Fill_FgColor:=KOCEL.FORMAT.clDefault;
    self.Fill_BgColor:=KOCEL.FORMAT.clDefault;
    self.H_Alignment:=KOCEL.FORMAT.ha_left;
    self.V_Alignment:=KOCEL.FORMAT.va_top;
    self.E_Locked:=0;
    self.E_Hidden:=0;
    self.Parent_Fmt:=0;
    self.Wrap_Text:=0;
    self.Shrink_To_Fit:=0;
    self.Text_Rotation:=0;
    self.Text_Indent:=0;
  end if;
  return;    
end TFORMAT;

/*Сохранение формата. 
  Если идентификатор формата не существует, то присваивается новый.
  Если аналогичный формат сушествует,
  то просто возвращается его идентификатор.*/
-------------------------------------------------------------------------------
MEMBER FUNCTION Save(self in out KOCEL.TFORMAT) return NUMBER
is
begin
  if self.Format_String is null then self.Format_String:='GENERAL';end if;
  select /*+ index(kf KOCEL.FORMATS) */ Fmt into self.Fmt from KOCEL.FORMATS kf
  where  upper(Font_Name)=upper(self.Font_Name) 
     and self.Font_Size20=Font_Size20 
     and self.Font_Color=Font_Color
     and self.Font_Style=Font_Style 
     and self.Font_Underline=Font_Underline 
     and self.Font_Family=Font_Family 
     and self.Font_CharSet=Font_CharSet 
     and self.Left_Style=Left_Style
     and self.Left_Color=Left_Color 
     and self.Right_Style=Right_Style 
     and self.Right_Color=Right_Color 
     and self.Top_Style=Top_Style 
     and self.Top_Color=Top_Color 
     and self.Bottom_Style=Bottom_Style 
     and self.Bottom_Color=Bottom_Color
     and self.Diagonal=Diagonal 
     and self.Diagonal_Style=Diagonal_Style 
     and self.Diagonal_Color=Diagonal_Color 
     and self.Format_String=Format_String
     and self.Fill_Pattern=Fill_Pattern
     and self.Fill_FgColor=Fill_FgColor 
     and self.Fill_BgColor=Fill_BgColor 
     and self.H_Alignment=H_Alignment
     and self.V_Alignment=V_Alignment 
     and self.E_Locked=E_Locked 
     and self.E_Hidden=E_Hidden 
     and self.Parent_Fmt=Parent_Fmt
     and self.Wrap_Text=Wrap_Text 
     and self.Shrink_To_Fit=Shrink_To_Fit 
     and self.Text_Rotation=Text_Rotation
     and self.Text_Indent=Text_Indent;
  return self.Fmt;   
exception
  when no_data_found then 
    insert into KOCEL.FORMATS values(
      self.Fmt, self.Font_Name, self.Font_Size20, self.Font_Color,
			self.Font_Style, self.Font_Underline, self.Font_Family,
	    self.Font_CharSet, self.Left_Style, self.Left_Color, self.Right_Style,
	    self.Right_Color, self.Top_Style, self.Top_Color, self.Bottom_Style,
	    self.Bottom_Color, self.Diagonal, self.Diagonal_Style,
	    self.Diagonal_Color, self.Format_String, self.Fill_Pattern,
	    self.Fill_FgColor, self.Fill_BgColor, self.H_Alignment,
	    self.V_Alignment, self.E_Locked, self.E_Hidden, self.Parent_Fmt,
	    self.Wrap_Text, self.Shrink_To_Fit, self.Text_Rotation, self.Text_Indent)
    returning  Fmt into self.Fmt;       
    return self.Fmt; 
end Save;

END;

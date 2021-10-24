CREATE OR REPLACE PACKAGE BODY KOCEL.FORMAT
-- KOCEL  FORMAT packagebody
-- Definitions for the formats in a cell.
-- create 03.03.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 26.09.2016
--*****************************************************************************
is

-------------------------------------------------------------------------------
function Name2Color(val in VARCHAR2) return NUMBER
is
 R VARCHAR2(40);
 G VARCHAR2(40);
 B VARCHAR2(40);
begin
  case upper(Val)
    when 'CLBLACK'  then return 0;
    when 'CLMAROON'  then return 128;
    when 'CLGREEN'  then return 32768;
    when 'CLOLIVE' then return 32896 ;
    when 'CLNAVY'  then return 8388608 ;
    when 'CLPURPLE'  then return 8388736;
    when 'CLTEAL'  then return 8421376;
    when 'CLGRAY'  then return 8421504;
    when 'CLSILVER'  then return 12632256;
    when 'CLRED'  then return 255;
    when 'CLLIME'  then return 65280;
    when 'clYellow'  then return 65535;
    when 'CLBLUE'  then return 16711680;
    when 'CLFUCHSIA'  then return 16711935;
    when 'CLAQUA'  then return 16776960;
    when 'CLLTGRAY'  then return 12632256;
    when 'CLDKGRAY'  then return 8421504;
    when 'CLWHITE'  then return 16777215;
    when 'CLSKYBLUE'  then return 15780518;
    when 'CLCREAM'  then return 15793151;
    when 'CLMEDGRAY'  then return 10789024;
    when 'CLNONE'  then return 536870911;
    when 'CLDEFAULT'  then return 536870912;
  else  
		-- Если строка вида "R=...,G=...,B=..." , то преобразуем её в цвет,
		R:=regexp_substr(val,'R=+\D');
		if R is not null then
		  R:=regexp_substr(R,'+\D');
		  G:=regexp_substr(val,'G=+\D');
		  G:=regexp_substr(G,'+\D');
		  B:=regexp_substr(val,'B=+\D');
		  B:=regexp_substr(B,'+\D');
		  begin
		    return to_number(R)+to_number(G)*255+to_number(B)*255*255;
		  exception
		    when others then
		      raise_application_error (-20443,
			      'KOCEL.FORMAT.Name2Color'||
						' Невозможно преобразовать RGB строку в цвет!');
		  end;
	  else
	    raise_application_error (-20443,
	      'KOCEL.FORMAT.Name2Color'||
			  ' Невозможно преобразовать строку в цвет!');
	  end if;
  end case;    
end Name2Color;

-------------------------------------------------------------------------------
function Color2Name(val in NUMBER) return VARCHAR2
is
  s VARCHAR2(128);
begin
  case Val
    when 0  then return 'clBlack';
    when 128  then return 'clMaroon';
    when 32768  then return 'clGreen';
    when 32896  then return 'clOlive';
    when 8388608  then return 'clNavy';
    when 8388736  then return 'clPurple';
    when 8421376  then return 'clTeal';
    when 8421504  then return 'clGray';
    when 12632256  then return 'clSilver';
    when 255  then return 'clRed';
    when 65280  then return 'clLime';
    when 65535  then return 'clYellow';
    when 16711680  then return 'clBlue';
    when 16711935  then return 'clFuchsia';
    when 16776960  then return 'clAqua';
    when 12632256  then return 'clLtGray';
    when 8421504  then return 'clDkGray';
    when 16777215  then return 'clWhite';
    when 15780518  then return 'clSkyBlue';
    when 15793151  then return 'clCream';
    when 10789024  then return 'clMedGray';
    when 536870911  then return 'clNone';
    when 536870912  then return 'clDefault';
  else
		if val<=clWhite then
		  S:='R='||to_char(bitand(val,to_number('FF','XX')));
		  S:=S||',G='||to_char(bitand(val,to_number('FF00','XX'))/256);
		  S:=S||',B='||to_char(bitand(val,to_number('FF0000','XX'))/256/256);
	  else
  	  raise_application_Error(-20443,
        'KOCEL.FORMAT.Color2Name. Недопустимое значение!');
	  end if;    
		return S;
  end case;  
end Color2Name;

-------------------------------------------------------------------------------
function get_CellHorAlignment(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0  then return 'ha_general';
    when 1  then return 'ha_left';
    when 2  then return 'ha_center';
    when 3  then return 'ha_right';
    when 4  then return 'ha_fill';
    when 5  then return 'ha_justify';
    when 6  then return 'ha_center_across_selection';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellHorAlignment. Недопустимое значение!');
  end case;  
end get_CellHorAlignment;

-------------------------------------------------------------------------------
function get_CellHorAlignment(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'HA_GENERAL'  then return 0;
    when 'HA_LEFT'  then return 1;
    when 'HA_CENTER'  then return 2;
    when 'HA_RIGHT'  then return 3;
    when 'HA_FILL'  then return 4;
    when 'HA_JUSTIFY'  then return 6;
    when 'HA_CENTER_ACROSS_SELECTION'  then return 6;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellHorAlignment. Недопустимое значение!');
  end case;  
end get_CellHorAlignment;

-------------------------------------------------------------------------------
function get_CellHorAlignments return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..6
  loop
    pipe row(get_CellHorAlignment(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellHorAlignments');
    raise;
end get_CellHorAlignments;


-------------------------------------------------------------------------------
function get_CellVertAlignment(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0  then return  'va_top';
    when 1  then return  'va_center';
    when 2  then return  'va_bottom';
    when 3  then return  'va_justify';
    when 4  then return  'va_distributed';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellVertAlignment. Недопустимое значение!');
  end case;  
end get_CellVertAlignment;

-------------------------------------------------------------------------------
function get_CellVertAlignment(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'VA_TOP'  then return 0;
    when 'VA_CENTER'  then return 1;
    when 'VA_BOTTOM'  then return 2;
    when 'va_justify'  then return 3;
    when 'VA_DISTRIBUTED'  then return 4;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellVertAlignment. Недопустимое значение!');
  end case;  
end get_CellVertAlignment;

-------------------------------------------------------------------------------
function get_CellVertAlignments return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..4
  loop
    pipe row(get_CellVertAlignment(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellVertAlignments');
    raise;
end get_CellVertAlignments;

-------------------------------------------------------------------------------
function get_CellBorderStyle(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0 then return  'bs_None';
    when 1 then return  'bs_Thin';
    when 2 then return  'bs_Medium';
    when 3 then return  'bs_Dashed';
    when 4 then return  'bs_Dotted';
    when 5 then return  'bs_Thick';
    when 6 then return  'bs_Double';
    when 7 then return  'bs_Hair';
    when 8 then return  'bs_Medium_dashed';
    when 9 then return  'bs_Dash_dot';
    when 10 then return  'bs_Medium_dash_dot';
    when 11 then return  'bs_Dash_dot_dot';
    when 12 then return  'bs_Medium_dash_dot_dot';
    when 13 then return  'bs_Slanted_dash_dot';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellBorderStyle. Недопустимое значение!');
  end case;  
end get_CellBorderStyle;

-------------------------------------------------------------------------------
function get_CellBorderStyle(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'BS_NONE' then return 0;
    when 'BS_THIN' then return 1;
    when 'BS_MEDIUM' then return 2;
    when 'BS_DASHED' then return 3;
    when 'BS_DOTTED'then return 4;
    when 'BS_THICK' then return 5;
    when 'BS_DOUBLE' then return 6;
    when 'BS_HAIR' then return 7;
    when 'BS_MEDIUM_DASHED' then return 8;
    when 'BS_DASH_DOT' then return 9;
    when 'BS_MEDIUM_DASH_DOT' then return 10;
    when 'BS_DASH_DOT_DOT' then return 11;
    when 'BS_MEDIUM_DASH_DOT_DOT' then return 12;
    when 'BS_SLANTED_DASH_DOT' then return 13;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellBorderStyle. Недопустимое значение!');
  end case;  
end get_CellBorderStyle;

-------------------------------------------------------------------------------
function get_CellBorderStyles return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..13
  loop
    pipe row(get_CellBorderStyle(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellBorderStyles');
    raise;
end get_CellBorderStyles;

-------------------------------------------------------------------------------
function get_CellPatternStyle(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0  then return  'ps_Automatic';
    when 1  then return  'ps_None';
    when 2  then return  'ps_Solid';
    when 3  then return  'ps_Gray50';
    when 4  then return  'ps_Gray75';
    when 5  then return  'ps_Gray25';
    when 6  then return  'ps_Horizontal';
    when 7  then return  'ps_Vertical';
    when 8  then return  'ps_Down';
    when 9  then return  'ps_Up';
    when 10  then return  'ps_Checker';
    when 11  then return  'ps_SemiGray75';
    when 12  then return  'ps_LightHorizontal';
    when 13  then return  'ps_LightVertical';
    when 14  then return  'ps_LightDown';
    when 15  then return  'ps_LightUp';
    when 16  then return  'ps_Grid';
    when 17  then return  'ps_CrissCross';
    when 18  then return  'ps_Gray16';
    when 19  then return  'ps_Gray8';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellPatternStyle. Недопустимое значение!');
  end case;  
end get_CellPatternStyle;

-------------------------------------------------------------------------------
function get_CellPatternStyle(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'PS_AUTOMATIC'  then return 0;
    when 'PS_NONE'  then return 1;
    when 'PS_SOLID'  then return 2;
    when 'PS_GRAY50'  then return 3;
    when 'PS_GRAY75'  then return 4;
    when 'PS_GRAY25'  then return 5;
    when 'PS_HORIZONTAL'  then return 6;
    when 'PS_VERTICAL'  then return 7;
    when 'PS_DOWN'  then return 8;
    when 'PS_UP'  then return 9;
    when 'PS_CHECKER'  then return 10;
    when 'PS_SEMIGRAY75'  then return 11;
    when 'PS_LIGHTHORIZONTAL'  then return 12;
    when 'PS_LIGHTVERTICAL'  then return 13;
    when 'PS_LIGHTDOWN'  then return 14;
    when 'PS_LIGHTUP'  then return 15;
    when 'PS_GRID'  then return 16;
    when 'PS_CRISSCROSS'  then return 17;
    when 'PS_GRAY16'  then return 18;
    when 'PS_GRAY8'  then return 19;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellPatternStyle. Недопустимое значение!');
  end case;  
end get_CellPatternStyle;

-------------------------------------------------------------------------------
function get_CellPatternStyles return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..19
  loop
    pipe row(get_CellPatternStyle(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellPatternStyles');
    raise;
end get_CellPatternStyles;

-------------------------------------------------------------------------------
function get_CellDiagBorder(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0 then return  'db_None';
    when 1 then return  'db_DiagDown';
    when 2 then return  'db_DiagUp';
    when 3 then return  'db_Both';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellDiagBborder. Недопустимое значение!');
  end case;  
end get_CellDiagBorder;

-------------------------------------------------------------------------------
function get_CellDiagBorder(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'DB_NONE' then return 0;
    when 'DB_DIAGDOWN' then return 1;
    when 'DB_DIAGUP' then return 2;
    when 'DB_BOTH' then return 3;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellDiagBorder. Недопустимое значение!');
  end case;  
end get_CellDiagBorder;

-------------------------------------------------------------------------------
function get_CellDiagBorders return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..3
  loop
    pipe row(get_CellDiagBorder(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellDiagBorders');
    raise;
end get_CellDiagBorders;

-------------------------------------------------------------------------------
function get_CellFontStyle(val in NUMBER) return VARCHAR2
is
  S VARCHAR2(90);
begin
  select decode(bitand(val,Bold),Bold,'Bold')
       ||decode(bitand(val,Italic),Italic,'Italic')  
       ||decode(bitand(val,StrikeOut),StrikeOut,'StrikeOut')  
       ||decode(bitand(val,Superscript),Superscript,'Superscript')  
       ||decode(bitand(val,Subscript),Subscript,'Subscript')
    into S from dual;
  if S is null then 
    return 'Normal'; 
  else
    return S;
  end if;          
end get_CellFontStyle;

-------------------------------------------------------------------------------
function And_CellFontStyle(val in NUMBER,style in NUMBER) return NUMBER
is
begin
  return bitand(val,style);
end And_CellFontStyle;

-------------------------------------------------------------------------------
function get_CellUnderlineStyle(val in NUMBER) return VARCHAR2
is
begin
  case val
    when 0 then return  'u_None';
    when 1 then return  'u_Single';
    when 2 then return  'u_Double';
    when 3 then return  'u_SingleAccounting';
    when 4 then return  'u_DoubleAccounting';
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellUnderline. Недопустимое значение!');
  end case;  
end get_CellUnderlineStyle;

-------------------------------------------------------------------------------
function get_CellUnderlineStyle(val in VARCHAR2) return NUMBER
is
begin
  case upper(val)
    when 'U_NONE' then return 0;
    when 'U_SINGLE' then return 1;
    when 'U_DOUBLE' then return 2;
    when 'U_SINGLEACCOUNTING' then return 3;
    when 'U_DOUBLEACCOUNTING' then return 4;
  else
  	raise_application_Error(-20443,
     'KOCEL.FORMAT.get_CellUnderline. Недопустимое значение!');
  end case;  
end get_CellUnderlineStyle;

-------------------------------------------------------------------------------
function get_CellUnderlineStyles return KOCEL.TSTRINGS
pipelined
is
begin
  for i in 0..4
  loop
    pipe row(get_CellUnderlineStyle(i));
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.FORMAT.get_CellUnderlineStyles');
    raise;
end get_CellUnderlineStyles;

-------------------------------------------------------------------------------
function EQ(fmt1 KOCEL.TFORMAT, fmt2 KOCEL.TFORMAT) return BOOLEAN
is
begin
  if    upper(fmt1.Font_Name)=upper(fmt2.Font_Name)
    and fmt1.Font_Size20=fmt2.Font_Size20
    and fmt1.Font_Color=fmt2.Font_Color
		and fmt1.Font_Style=fmt2.Font_Style
    and fmt1.Font_Underline=fmt2.Font_Underline
    and fmt1.Font_Family=fmt2.Font_Family
    and fmt1.Font_CharSet=fmt2.Font_CharSet
    and fmt1.Left_Style=fmt2.Left_Style
    and fmt1.Left_Color=fmt2.Left_Color
    and fmt1.Right_Style=fmt2.Right_Style
	  and fmt1.Right_Color=fmt2.Right_Color
    and fmt1.Top_Style=fmt2.Top_Style
    and fmt1.Top_Color=fmt2.Top_Color
    and fmt1.Bottom_Style=fmt2.Bottom_Style
    and fmt1.Bottom_Color=fmt2.Bottom_Color
    and fmt1.Diagonal=fmt2.Diagonal
    and fmt1.Diagonal_Style=fmt2.Diagonal_Style
    and fmt1.Diagonal_Color=fmt2.Diagonal_Color
    and fmt1.Format_String=fmt2.Format_String
    and fmt1.Fill_Pattern=fmt2.Fill_Pattern
	  and fmt1.Fill_FgColor=fmt2.Fill_FgColor
    and fmt1.Fill_BgColor=fmt2.Fill_BgColor
    and fmt1.H_Alignment=fmt2.H_Alignment
    and fmt1.V_Alignment=fmt2.V_Alignment
    and fmt1.E_Locked=fmt2.E_Locked
    and fmt1.E_Hidden=fmt2.E_Hidden
    and fmt1.Parent_fmt=fmt2.Parent_fmt
    and fmt1.Wrap_Text=fmt2.Wrap_Text
    and fmt1.Shrink_To_Fit=fmt2.Shrink_To_Fit
    and fmt1.Text_Rotation=fmt2.Text_Rotation
    and fmt1.Text_Indent=fmt2.Text_Indent
  then
    return true;
  else 
    return false;    
  end if;
end EQ;

-- Если форматы равны, то функция возвращает "1", иначе "0".
-------------------------------------------------------------------------------
function S_EQ(fmt1 KOCEL.TFORMAT, fmt2 KOCEL.TFORMAT) return NUMBER
is
begin
  if EQ(fmt1, fmt2) then return 1; else return 0; end if;
end S_EQ;

END;
/

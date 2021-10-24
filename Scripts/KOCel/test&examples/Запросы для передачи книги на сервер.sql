-- sql_1 Добавление нового листа в книгу
begin
KOCEL.INSERT_CELL(0,0,null,null,null,null,
  :SHEET,:SHEET_NUM,:BOOK,0);
end;

-- sql_2 Добавление формата.
begin
KOCEL.INSERT_FORMAT(
  :FmtNum,
  :Font_Name,
  :Font_Size20,
  :Font_Color,
  :Font_Style,
  :Font_Underline,
  :Font_Family,
  :Font_CharSet,
  :Left_Style,
  :Left_Color,
  :Right_Style,
  :Right_Color,
  :Top_Style,
  :Top_Color,
  :Bottom_Style,
  :Bottom_Color,
  :Diagonal,
  :Diagonal_Style,
  :Diagonal_Color,
  :Format_String,
  :Fill_Pattern,
  :Fill_FgColor,
  :Fill_BgColor,
  :H_Alignment,
  :V_Alignment,
  :E_Locked,
  :E_Hidden,
  :Parent_Fmt,
  :Wrap_Text,
  :Shrink_To_Fit,
  :Text_Rotation,
  :Text_Indent);
end;

-- sql_3 Определение параметров листа
insert into KOCEL.V_SHEET_PARS
(PAR_NAME, T, N, D, S, SHEET, BOOK)
values(:ParName,:T,:N,:D,:S,:sheet,:book)

-- sql_4 Добавление колонки.
begin
  KOCEL.INSERT_COLUMN(:C,:W,:SHEET,:SHEET_NUM,:BOOK,:Fmt);
end;

-- sql_5 Добавление ряда
begin
  KOCEL.INSERT_ROW(:R,:H,:SHEET,:SHEET_NUM,:BOOK,:Fmt);
end;

-- sql_6 Добавление пяти ячеек в книгу
begin
KOCEL.INSERT_5CELLS(
  :COUNT,
  :R1,:C1,:N1,:D1,:S1,:F1,:Fmt1,
  :R2,:C2,:N2,:D2,:S2,:F2,:Fmt2,
  :R3,:C3,:N3,:D3,:S3,:F3,:Fmt3,
  :R4,:C4,:N4,:D4,:S4,:F4,:Fmt4,
  :R5,:C5,:N5,:D5,:S5,:F5,:Fmt5,
  :SHEET,:SHEET_NUM,:BOOK);
end;

-- sql_7 Определение склеенных ячеек.
insert into KOCEL.V_MERGED_CELLS
(L, T, R, B, SHEET, BOOK)
values(:L,:T,:R,:B,:sheet,:book)

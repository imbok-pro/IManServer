
{------------------------------------------------------------------------------}
procedure ImportSource(bookName:string);
var
  i,tmp_i,tmp_Fmt,Default_i,DCount,r,c,cIndex,sheet,MRow,MCol:integer;
  ShName:string;
  v: TXlsCellValue;
  n:double;
  d:TdateTime;
  s,f:string;
  XF: Integer;
  HasDate: Boolean;
  HasTime: Boolean;
  Fmt: TFlxFormat;
  t:TT;
  book:string;
  R1C1:string;
  ASheet:integer;
  FlxFontStyle:SetOfTFlxFontStyle;
  OraFontStyle:integer;
  MRange:TXlsCellRange;
  SQl_IC:TOraSQL;
  function GetColor(const index: integer): TColor;
  begin
    if (Index>0) and (Index<=MainForm.FlexCelImportFile.ColorPaletteCount) then
      Result:=MainForm.FlexCelImportFile.ColorPalette[Index]
    else
      Result:=clBlack;
  end;
 procedure Rollback;
  begin
    MainForm.OraSession.Rollback;
    UExec.FormExec.Hide;
    MainForm.Show;
  end;
  function b2i(value:boolean):integer;
  begin
    result:=0;
    if value then result:=1;
  end;
  procedure ImportFloat;
  begin
    {KOCEL.INSERT_5CELLS(
      :COUNT [0],
      :R1 [1],:C1 [2],:N1 [3],:D1 [4],:S1 [5],:F1 [6],:Fmt1 [7],
      :R2 [1+DCount*7],:C2,:N2,:D2,:S2,:F2,:Fmt2,
      :R3,:C3,:N3,:D3,:S3,:F3,:Fmt3,
      :R4,:C4,:N4,:D4,:S4,:F4,:Fmt4,
      :R5,:C5,:N5,:D5,:S5,:F5,:Fmt5,
      :SHEET,:SHEET_NUM,:BOOK);}
    SQL_IC.Params[DCount*7+1].asInteger:=r;
    SQL_IC.Params[DCount*7+2].asInteger:=c;
    SQL_IC.Params[DCount*7+3].asFloat:=n;
    SQL_IC.Params[DCount*7+4].Value:=Null;
    SQL_IC.Params[DCount*7+5].Value:=Null;
    SQL_IC.Params[DCount*7+6].asString:=f;
    if XF=15 then
      SQL_IC.Params[DCount*7+7].asInteger:=0
    else
      SQL_IC.Params[DCount*7+7].asInteger:=XF;
    DCount:=DCount+1;
    SQL_IC.Params[0].asInteger:=DCount;
    if DCount=5 then
      begin
        SQl_IC.Execute;
        DCount:=0;
      end;
  end;
  procedure ImportDate;
  begin
    {KOCEL.INSERT_5CELLS(
      :COUNT [0],
      :R1 [1],:C1 [2],:N1 [3],:D1 [4],:S1 [5],:F1 [6],:Fmt1 [7],
      :R2 [1+DCount*7],:C2,:N2,:D2,:S2,:F2,:Fmt2,
      :R3,:C3,:N3,:D3,:S3,:F3,:Fmt3,
      :R4,:C4,:N4,:D4,:S4,:F4,:Fmt4,
      :R5,:C5,:N5,:D5,:S5,:F5,:Fmt5,
      :SHEET,:SHEET_NUM,:BOOK);}
    SQL_IC.Params[DCount*7+1].asInteger:=r;
    SQL_IC.Params[DCount*7+2].asInteger:=c;
    SQL_IC.Params[DCount*7+3].Value:=Null;
    SQL_IC.Params[DCount*7+4].asDate:=d;
    SQL_IC.Params[DCount*7+5].Value:=Null;
    SQL_IC.Params[DCount*7+6].asString:=f;
    if XF=15 then
      SQL_IC.Params[DCount*7+7].asInteger:=0
    else
      SQL_IC.Params[DCount*7+7].asInteger:=XF;
    DCount:=DCount+1;
    SQL_IC.Params[0].asInteger:=DCount;
    if DCount=5 then
      begin
        SQl_IC.Execute;
        DCount:=0;
      end;
  end;
  procedure ImportString;
  begin
    {KOCEL.INSERT_5CELLS(
      :COUNT [0],
      :R1 [1],:C1 [2],:N1 [3],:D1 [4],:S1 [5],:F1 [6],:Fmt1 [7],
      :R2 [1+DCount*7],:C2,:N2,:D2,:S2,:F2,:Fmt2,
      :R3,:C3,:N3,:D3,:S3,:F3,:Fmt3,
      :R4,:C4,:N4,:D4,:S4,:F4,:Fmt4,
      :R5,:C5,:N5,:D5,:S5,:F5,:Fmt5,
      :SHEET,:SHEET_NUM,:BOOK);}
    SQL_IC.Params[DCount*7+1].asInteger:=r;
    SQL_IC.Params[DCount*7+2].asInteger:=c;
    SQL_IC.Params[DCount*7+3].Value:=Null;
    SQL_IC.Params[DCount*7+4].Value:=Null;
    SQL_IC.Params[DCount*7+5].asString:=s;
    SQL_IC.Params[DCount*7+6].asString:=f;
    if XF=15 then
      SQL_IC.Params[DCount*7+7].asInteger:=0
    else
      SQL_IC.Params[DCount*7+7].asInteger:=XF;
    DCount:=DCount+1;
    SQL_IC.Params[0].asInteger:=DCount;
    if DCount=5 then
      begin
        SQl_IC.Execute;
        DCount:=0;
      end;
  end;
begin
with MainForm do
begin
  SQL_IC:=SQLImportCells;
  PlsNeedAbort:=false;
  book:=bookName;
  d:=now;
  ASheet:=FlexCelImportFile.ActiveSheet;
  n:=0;
  try
    ImportStage:='Clearing book';
    UExec.FormExec.OpProgress.Caption:= ImportStage;
    Application.ProcessMessages;
    Application.HandleMessage;
    OraSession.ExecProc('KOCEL.CELL.DELETEBOOK',[book]);
    // Импорт типа адресации книги.
    if FlexCelImportFile.OptionsR1C1 then R1C1:='R1C1'else R1C1:='A1';
    OraSession.ExecProcEx('KOCEL.SET_R1C1',
     ['UR1C1',R1C1,'UBOOK',book]);
    // Импорт параметров книги.
    SQLImportPar.ParamByName('ParName').AsString:='FileName';
    SQLImportPar.ParamByName('T').AsString:='S';
    SQLImportPar.ParamByName('S').AsString:=FlexCelImportFile.ActiveFileName;
    SQLImportPar.ParamByName('sheet').AsString:='';
    SQLImportPar.ParamByName('book').AsString:=book;
    SQLImportPar.Execute;
    SQLImportPar.ParamByName('ParName').AsString:='ActiveSheet';
    SQLImportPar.ParamByName('T').AsString:='N';
    SQLImportPar.ParamByName('N').AsInteger:=ASheet;
    SQLImportPar.ParamByName('sheet').AsString:='';
    SQLImportPar.ParamByName('book').AsString:=book;
    SQLImportPar.Execute;
    // Импорт форматов.
    for XF:=0 to FlexCelImportFile.FormatListCount-1 do
      with SQLImportFormat do
      begin
        KDebug.Debug('XF',toStr(XF));
        // Не заносим в базу формат по умолчанию.
        // Может не заносить перед ним и предыдущие 15!!!!
        if XF=15 then continue;
        FlexCelImportFile.GetFormatList(XF,Fmt);
        // 0 FmtNum.
        Params[0].asInteger:=XF;
        // 1 Font_Name.
        Params[1].asString:=Fmt.Font.Name;
        // 2 Font_Size20.
        Params[2].asInteger:=Fmt.Font.Size20;
        // 3 Font_Color.
        Params[3].asInteger:=GetColor(Fmt.Font.ColorIndex);
        // 4 Font_Style.
        FlxFontStyle:=Fmt.Font.Style;
        {-- Font style for a cell.
        Bold constant NUMBER(2):= 1;
        Italic constant NUMBER(2):= 2;
        StrikeOut constant NUMBER(2):= 4;
        Superscript constant NUMBER(2):= 8;
        Subscript constant NUMBER(2):= 16;
        }
        OraFontStyle:=0;
        if flsBold in FlxFontStyle then
          OraFontStyle:=OraFontStyle+1;
        if flsItalic in FlxFontStyle then
          OraFontStyle:=OraFontStyle+2;
        if flsStrikeOut in FlxFontStyle then
          OraFontStyle:=OraFontStyle+4;
        if flsSuperscript in FlxFontStyle then
          OraFontStyle:=OraFontStyle+8;
        if flsSubscript in FlxFontStyle then
          OraFontStyle:=OraFontStyle+16;
        Params[4].asInteger:=OraFontStyle;
        // 5 Font_Underline.
        Params[5].asInteger:=ord(Fmt.Font.Underline);
        // 6 Font_Family.
        Params[6].asInteger:=Fmt.Font.Family;
        // 7 Font_CharSet.
        Params[7].asInteger:=Fmt.Font.CharSet;
        // 8 Left_Style.
        Params[8].asInteger:=ord(Fmt.Borders.Left.Style);
        // 9 Left_Color.
        Params[9].asInteger:=GetColor(Fmt.Borders.Left.ColorIndex);
        // 10 Right_Style.
        Params[10].asInteger:=ord(Fmt.Borders.Right.Style);;
        // 11 Right_Color.
        Params[11].asInteger:=GetColor(Fmt.Borders.Right.ColorIndex);
        // 12 Top_Style.
        Params[12].asInteger:=ord(Fmt.Borders.Top.Style);;
        // 13 Top_Color.
        Params[13].asInteger:=GetColor(Fmt.Borders.Top.ColorIndex);
        // 14 Bottom_Style.
        Params[14].asInteger:=ord(Fmt.Borders.Bottom.Style);;
        // 15 Bottom_Color.
        Params[15].asInteger:=GetColor(Fmt.Borders.Bottom.ColorIndex);
        // 16 Diagonal.
        Params[16].asInteger:=ord(Fmt.Borders.Diagonal.Style);;
        // 17 Diagonal_Style.
        Params[17].asInteger:=ord(Fmt.Borders.DiagonalStyle);;
        // 18 Diagonal_Color.
        Params[18].asInteger:=GetColor(Fmt.Borders.Diagonal.ColorIndex);
        // 19 Format_String.
        Params[19].asString:=Fmt.Format;
        // 20 Fill_Pattern.
        Params[20].asInteger:=ord(Fmt.FillPattern.Pattern);
        // 21 Fill_FgColor.
        Params[21].asInteger:=GetColor(Fmt.FillPattern.FgColorIndex);
        // 22 Fill_BgColor.
        Params[22].asInteger:=GetColor(Fmt.FillPattern.BgColorIndex);
        // 23 H_Alignment.
        Params[23].asInteger:=ord(Fmt.HAlignment);
        // 24 V_Alignment.
        Params[24].asInteger:=ord(Fmt.VAlignment);;
        // 25 E_Locked.
        Params[25].asInteger:=b2i(Fmt.Locked);
        // 26 E_Hidden.
        Params[26].asInteger:=b2i(Fmt.Hidden);
        // 27 Parent_Fmt.
        Params[27].asInteger:=0;
        // 28 Wrap_Text.
        Params[28].asInteger:=b2i(Fmt.WrapText);
        // 29 Shrink_To_Fit.
        Params[29].asInteger:=b2i(Fmt.ShrinkToFit);
        // 30 Text_Rotation.
        Params[30].asInteger:=Fmt.Rotation;
        // 31 Text_Indent.
        Params[31].asInteger:=Fmt.Indent;
        // Вставляем формат.
        execute;
      end;
    DCount:=0;
    for sheet:=1 to FlexCelImportFile.SheetCount do
      begin
        FlexCelImportFile.ActiveSheet:=sheet;
        MRow:=FlexCelImportFile.MaxRow;
        MCol:=FlexCelImportFile.MaxCol;
        ShName:=FlexCelImportFile.ActiveSheetName;
        // Если есть не отправленные данные предыдущего листа,
        // то выполняем SQL.
        if DCount>0 then
          begin
            SQL_IC.Params[0].asInteger:=DCount;
            SQL_IC.Execute;
            DCount:=0;
          end;
        // Задаём имя листа, вставляя ячейку R=0 C=0.
        // Настройка параметров импорта данных.
        SQLSheetName.ParamByName('sheet').AsString:=ShName;
        SQLSheetName.ParamByName('sheet_num').AsInteger:=sheet;
        SQLSheetName.ParamByName('book').AsString:=book;
        SQLSheetName.execute;
        SQL_IC.ParamByName('sheet').AsString:=ShName;
        SQL_IC.ParamByName('sheet_num').AsInteger:=sheet;
        SQL_IC.ParamByName('book').AsString:=book;
        SQLImportColumn.ParamByName('sheet').AsString:=ShName;
        SQLImportColumn.ParamByName('sheet_num').AsInteger:=sheet;
        SQLImportColumn.ParamByName('book').AsString:=book;
        SQLImportRow.ParamByName('sheet').AsString:=ShName;
        SQLImportRow.ParamByName('sheet_num').AsInteger:=sheet;
        SQLImportRow.ParamByName('book').AsString:=book;
        // Импорт объединённых ячеек.
        SQLImportMergedCells.ParamByName('sheet').AsString:=ShName;
        SQLImportMergedCells.ParamByName('book').AsString:=book;
        for i:=0 to FlexCelImportFile.CellMergedListCount-1 do
          begin
            MRange:=FlexCelImportFile.CellMergedList[i];
            //values(:L,:T,:R,:B,:sheet,:book);
            SQLImportMergedCells.Params[0].asInteger:=MRange.Left;
            SQLImportMergedCells.Params[1].asInteger:=MRange.Top;
            SQLImportMergedCells.Params[2].asInteger:=MRange.Right;
            SQLImportMergedCells.Params[3].asInteger:=MRange.Bottom;
            SQLImportMergedCells.Execute;
          end;
        // Импорт параметров листа.
        // :ParName - 0; :T - 1; :N - 2; :D - 3; :S - 4;
        SQLImportPar.ParamByName('sheet').AsString:=ShName;
        SQLImportPar.ParamByName('book').AsString:=book;
        //
        SQLImportPar.Params[0].asString:='ZOOM';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=FlexCelImportFile.SheetZoom;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PageHeader';
        SQLImportPar.Params[1].asString:='S';
        SQLImportPar.Params[4].asString:=FlexCelImportFile.PageHeader;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PageFooter';
        SQLImportPar.Params[1].asString:='S';
        SQLImportPar.Params[4].asString:=FlexCelImportFile.PageFooter;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintGridLines';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=
          b2i(FlexCelImportFile.PrintGridLines);
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='ShowGridLines';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=b2i(FlexCelImportFile.ShowGridLines);
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Left';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Left;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Top';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Top;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Right';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Right;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Bottom';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Bottom;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Header';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Header;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintMargins.Footer';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asFloat:=FlexCelImportFile.PrintMargins.Footer;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintOptions';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=FlexCelImportFile.PrintOptions;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintToFit';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=b2i(FlexCelImportFile.PrintToFit);
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintScale';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=FlexCelImportFile.PrintScale;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintNumberOfHorizontalPages';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=
          FlexCelImportFile.PrintNumberOfHorizontalPages;
        SQLImportPar.Execute;
        //
        SQLImportPar.Params[0].asString:='PrintNumberOfVerticalPages';
        SQLImportPar.Params[1].asString:='N';
        SQLImportPar.Params[2].asInteger:=
          FlexCelImportFile.PrintNumberOfVerticalPages;
        SQLImportPar.Execute;
        // Импорт ширин и форматов колонок.
        //(:C - 0 ,:W - 1 ,:SHEET - 2 ,:BOOK - 3,:Fmt -4);
        default_i:=FlexCelImportFile.DefaultColWidth;
        for i:=1 to MCol do
          begin
            // Только для тех колонок у которых формат или ширина
            // отличается от умолчаний.
            tmp_i:=FlexCelImportFile.ColumnWidth[i];
            tmp_fmt:=FlexCelImportFile.ColumnFormat[i];
            if (tmp_fmt=15) or (tmp_fmt=-1) then tmp_Fmt:=0;
            if (tmp_Fmt=0) and (tmp_i=default_i) then continue;
            SQLImportColumn.Params[0].asInteger:=i;
            SQLImportColumn.Params[1].asInteger:=tmp_i;
            SQLImportColumn.Params[5].asInteger:=tmp_Fmt;
            SQLImportColumn.Execute;
          end;
        // Импорт ширины и формата ряда производиться вместе с данными.
        default_i:=FlexCelImportFile.DefaultRowHeight;
        // Импорт данных
        for r := 1 to MRow do
          begin
            ImportStage:=ShName+', row:'+inttostr(r)+'.';
            Application.HandleMessage;
            //(:R - 0 ,:H - 1 ,:SHEET - 2 ,:BOOK - 3,:Fmt -4);
            tmp_i:=FlexCelImportFile.RowHeight[r];
            tmp_fmt:=FlexCelImportFile.RowFormat[r];
            // Формат по умолчанию.
            if (tmp_fmt=15) or (tmp_fmt=-1) then tmp_Fmt:=0;
            // Если ширина равна ширине по умолчанию или включен автородбор
            // высоты, то импортируем значение "0".
            if (tmp_i=default_i) or FlexCelImportFile.AutoRowHeight[r] then
              tmp_i:=0;
            if (tmp_Fmt<>0) or (tmp_i<>0) then
              begin
                SQLImportRow.Params[0].asInteger:=r;
                SQLImportRow.Params[1].asInteger:=tmp_i;
                SQLImportRow.Params[5].asInteger:=tmp_Fmt;
                SQLImportRow.Execute;
              end;
            //Instead of looping in all the columns,
            // we will just loop in the ones
            //that have data. This is much faster.
            for cIndex := 1 to FlexCelImportFile.ColIndexCount[r] do
              begin
                Application.ProcessMessages;
                if PlsNeedAbort then
                  begin
                    Rollback;
                    exit;
                  end;
                //The real column.
                c := FlexCelImportFile.ColByIndex[r, cIndex];
                // Игнорируем все объединённые ячейки кроме левой верхней.
                if (FlexCelImportFile.CellMergedBounds[r, c].Left<>c)
                  or (FlexCelImportFile.CellMergedBounds[r, c].Top<>r)
                then
                  continue;
                // Находим формулу.
                v := FlexCelImportFile.Cell[r, c];
                if v.IsFormula and importFormulasMM.Checked then
                  f:= FlexCelImportFile.CellFormula[r,c]
                else
                  f:='';
                // Находим индекс формата.
                XF := v.XF;
                if (XF < 0) or (XF >= FlexCelImportFile.FormatListCount)then
                  XF := 15; //Default format.
                t:=xtString;
                case VarType(v.Value) of
                  varBoolean: s:= string(v.Value);
                  varDouble:
                    begin
                      //Remember, dates are doubles with date format.
                      //Also, all numbers are returned as doubles,
                      // even if they are integers.
                      FlexCelImportFile.GetFormatList(XF, Fmt);
                      if HasXlsDateTime(fmt.Format, HasDate, HasTime) then
                        begin
                          d:= FlexCelImportFile.FromOADate(v.Value);
                          t:=xtDate;
                        end
                      else
                        begin
                          n:=v.Value;
                          t:=xtNumber;
                        end;
                    end;
                  varOleStr: s:=v.Value;
                  //Чтобы сохранить форматирование пишем пустую строку.
                  1: s:='';
                  0: continue;
                else
                  raise Exception.Create('Unexpected value on cell => '
                                          + inttoStr(VarType(v.Value)));
                end;
                case t of
                  xtNumber: ImportFloat;
                  xtDate: ImportDate;
                  xtString: ImportString;
                end;
              end;//for CIndex
        end;// for r
      end;// for sheet
    // Если в буфере остались данные, то выполняем SQL_IC
    if DCount>0 then
      begin
        SQL_IC.Params[0].asInteger:=DCount;
        SQl_IC.Execute;
      end;
    ImportStage:='Finalizing Import.';
    Application.ProcessMessages;
    Application.HandleMessage;
    OraSession.ExecProc('KOCEL.COMMIT_INSERTS',[]);
    MainForm.QueryLookUpTable.execute;
    MainForm.QueryLookupTableImport.execute;
    FlexCelImportFile.ActiveSheet:=ASheet;
    SourceXlsSheets.TabIndex:=FlexCelImportFile.ActiveSheet-1;
    SourceXlsGrid.LoadSheet;
    Application.Restore;
    UExec.FormExec.Hide;
    MainForm.Show;
  except
    Rollback;
    raise;
  end;
end;
end;


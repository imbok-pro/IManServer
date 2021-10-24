CREATE OR REPLACE PACKAGE KOCEL.BOOK
-- KOCEL BOOK package
-- create 08.02.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 
--*****************************************************************************

as
-- Освобождение переменных пакета.
procedure ClearData;
-- Загрузка и подготовка данных.
procedure PrepareData(UBOOK in VARCHAR2);

-- Предоставляет для запроса параметры листов книги "UBOOK".
-- Если номер листа 0, а имя нулл, то это глобальный параметр книги.
function Pars return KOCEL.TSHEET_PARS pipelined;

-- Предоставляет для запроса форматы, использующиеся в книге "UBOOK".
-- Поле "Fmt" содержит идентификатор формата, а поле "Tag" порядковый номер.
-- Первая запись содержит количество форматов в поле "Tag".
function Formats return KOCEL.TFORMATS pipelined;

-- Предоставляет для запроса номера листов книги "UBOOK".
-- Первая запись содержит не номер, а количество листов.
-- Информация о листах книги и их именах хранится в пакете.
function Sheets return KOCEL.TSHEET_NUMS pipelined;

-- Предоставляет для запроса форматы и высоты рядов листа  "USHEET" из книги
-- "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Row_s(USHEET in VARCHAR2) return KOCEL.TROW_DATAS pipelined;

-- Предоставляет для запроса форматы и высоты рядов листов книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Row_s return KOCEL.TROW_DATAS pipelined;

-- Предоставляет для запроса форматы и ширины колонок листа  "USHEET" из книги
-- "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Column_s(USHEET in VARCHAR2) return KOCEL.TCOLUMN_DATAS
pipelined;

-- Предоставляет для запроса форматы и ширины колонок листов книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Column_s return KOCEL.TCOLUMN_DATAS pipelined;

-- Предоставляет для запроса данные листа "USHEET" из книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Cells(USHEET in VARCHAR2) return KOCEL.TCELL_DATAS pipelined;

-- Предоставляет для запроса данные книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Cells return KOCEL.TCELL_DATAS pipelined;

-- Предоставляет для запроса объединённые ячейки листa "USHEET" из книги
-- "UBOOK".
function Sheet_MCells(USHEET in VARCHAR2) return KOCEL.TMCELL_DATAS pipelined;

-- Предоставляет для запроса объединённые ячейки листов книги "UBOOK".
function MCells return KOCEL.TMCELL_DATAS pipelined;

END;
/

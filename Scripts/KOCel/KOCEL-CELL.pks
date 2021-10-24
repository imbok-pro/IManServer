CREATE OR REPLACE PACKAGE KOCEL.CELL
-- KOCEL  CELL package
-- by Nikolai Krasilnikov
-- create 17.04.2009
-- update 18.05.2009 15.12.2009 28.01.2010 01.02.2010 13.02.2010 03.03.2010
--        17.08.2011 11.11.2014 20.02.20
--*****************************************************************************

AS
-- Флаг работы триггера KOCEL.SHEETS_ad.
ClearBOOKS BOOLEAN; 
-- !!! добавить процедуры переименования листа или книги. Преобразование должно отключить триггера и проверить отсутствие целевого имени в базе.

-- При занесения значения в книгу будет занесено только одно из полей N,D,S.
-- При неоднократном использовнии необходимо не забывать очищать неиспользуемые
-- поля. 
type TCellValue is record(
R NUMBER(6),
C NUMBER(3),
N FLOAT(49),
D DATE,
S VARCHAR2(4000),
F VARCHAR2(4000)
);

type TColumn is Table of TCellValue index by BINARY_INTEGER;
type TRow is Table of TCellValue index by BINARY_INTEGER;
type TRange is Table of TColumn index by BINARY_INTEGER;

-- Входной (источник) и выходной (результат) листы, используемые по умолчанию.
inBOOK VARCHAR2(255);
inSHEET VARCHAR2(255);
outBOOK VARCHAR2(255);
outSHEET VARCHAR2(255);

tmpRange TRange;

overwrite constant BOOLEAN:= true;

-- Создание новой книги и (или) листа.
-- Если лист уже существует, то ошибка.
-- Книга существует, если в ней хотябы один лист.
-- Лист книги существует, если в таблицу занесена хотябы одна ячейка.
-- в данном случае заносится нулевая ячейка в ячейку(R=0 и C=0).
PROCEDURE New_SHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2);

-- Создание нового листа.
PROCEDURE New_outSHEET;
-- Создание нового листа и установка его как приёмник по умолчанию.
PROCEDURE New_outSHEET(newSHEET in VARCHAR2);
PROCEDURE New_outSHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2);

-- Проверка что лист существует.
FUNCTION is_inSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN;
FUNCTION is_inSHEET_exist return BOOLEAN;
FUNCTION is_outSHEET_exist return BOOLEAN;
FUNCTION is_outSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN;
FUNCTION isSHEET_exist(eSHEET in VARCHAR2,eBOOK in VARCHAR2)
return BOOLEAN;

-- Получение значения из текущей книги и (или) листа.
FUNCTION Val(CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

-- Получение значения из любой книги,листа.
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue;

FUNCTION Val(CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

-- Получение значения из любой книги,листа.
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue;

-- Проверка, что значение дата.
FUNCTION isDate(CellValue in TCellValue)
return BOOLEAN;

-- Проверка, что значение число.
FUNCTION isNumber(CellValue in TCellValue)
return BOOLEAN;

-- Проверка, что значение null.
FUNCTION isNull(CellValue in TCellValue)
return BOOLEAN;

-- Проверка, что значение строка.
FUNCTION isString(CellValue in TCellValue)
return BOOLEAN;

-- Проверка, что присутствует формула.
FUNCTION hasFormula(CellValue in TCellValue)
return BOOLEAN;

--Получение значения, как даты. Если это не дата, то нулл.
FUNCTION asDate(CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE;

FUNCTION asDate(CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE;

--Получение значения, как число. Если это не число, то нулл.
FUNCTION asNumber(CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER;

FUNCTION asNumber(CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER;

--Получение значения, как строка.
FUNCTION asString(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION asString(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

--Получение формулы.
FUNCTION Formula(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2;

FUNCTION Formula(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2;

-- Получение колонки.
-- Результат является разреженным массивом, если значение отсутствует в книге
-- его не будет и среди элементов массива.
-- Так индекс ноль, содержащий ширину колонки, присутствует только, если ширина
-- колонки была изменена пользователем.
-- В общем случае, для организации циклов нужно использовать атрибуты массивов:
-- first,next,last.
-- Индекс массива соответствует номену ряда в книге. 
FUNCTION GetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in NUMBER)
return TColumn;

FUNCTION GetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(entColumn in VARCHAR2)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn;

FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn;

-- Получение ряда.
-- Результат является разреженным массивом, если значение отсутствует в книге
-- его не будет и среди элементов массива.
-- Так элемент с индексом ноль, содержащий высоту ряда будет присутствовать
-- только в том случае, если его высота была изменена пользователем.
-- В общем случае, для организации циклов нужно использовать атрибуты массивов:
-- first,next,last.
-- Индекс массива соответствует номеру колонки в книге.
FUNCTION GetRow(StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(entRow in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                entRow in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                entRow in NUMBER)
return TRow;

FUNCTION GetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow;

-- Получение диапазона.
-- Результат является разреженным массивом, если значение отсутствует в книге
-- его не будет и среди элементов массива.
-- В общем случае, для организации циклов нужно использовать атрибуты массивов:
-- first,next,last.
-- Индексы массива соответствуют: первый - номеру ряда, второй номеру колонки.
FUNCTION GetRange(StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange;

FUNCTION GetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;

FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange;


-- Сохранение значения.
-- Значение сохраняется всегда согласно полям R,C.
-- Если поля (N,D,S) определены неоднозначно, то ошибка.
PROCEDURE SetVal(val in TCellValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,val in TCellValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2, val in TCellValue);

-- Сохранение значения, если аргумент KOCEL.TVALUE.
PROCEDURE SetVal(val in KOCEL.TValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,val in KOCEL.TValue);

PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2,val in KOCEL.TValue);


-- Сохранение значения, как даты.
PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in NUMBER,
                       val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE);

PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in VARCHAR2,
                       val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE);

PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE);

-- Сохранение значения, как числа.
PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in NUMBER,
                         val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER);

PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER);

-- Сохранение значения, как строки.
PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

-- Сохранение формулы.
-- Значение при этом не изменяется.
PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2);

PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2);

-- Сохранение колонки.
-- Сохранение происходит согласно индексам массива,
-- а не полям (R,C) значения.
-- Первоначально индексы совпадают со значением полей, однако следует учеть
-- что соответствие нарушается при изменении порядка следования элементов.
-- Для сохранения согласно значениям индексов полей нужно сохранить значения,
-- используя процедуру (setVal), в цикле по массиву.
PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn);

PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                    ColumnVals in TColumn);

PROCEDURE SetColumn(asColumn in VARCHAR2,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn);

PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn);

-- Сохранение ряда.
-- Сохранение происходит согласно индексам массива,
-- а не полям (R,C) значения.
-- Первоначально индексы совпадают со значением полей, однако следует учеть
-- что соответствие нарушается при изменении порядка следования элементов.
-- Для сохранения согласно значениям индексов полей нужно сохранить значения,
-- используя процедуру (setVal), в цикле по массиву.
PROCEDURE SetRow(StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow);

PROCEDURE SetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow);

-- Сохранение диапазона.
-- Сохранение происходит согласно индексам массива,
-- а не полям (R,C) значения.
-- Первоначально индексы совпадают со значением полей, однако следует учеть
-- что соответствие нарушается при изменении порядка следования элементов.
-- Для сохранения согласно значениям индексов полей нужно сохранить значения,
-- используя процедуру (setVal), в цикле по массиву.
PROCEDURE SetRange(StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange);

PROCEDURE SetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange);

-- Копирование листа.
PROCEDURE CopySHEET(fromSHEET in VARCHAR2,fromBook in VARCHAR2,
                    toSHEET in VARCHAR2,toBook in VARCHAR2,
										doOverwrire in BOOLEAN default false);

-- Копирование книги.
PROCEDURE CopyBook(fromBook in VARCHAR2,toBook in VARCHAR2,
                   doOverwrire in BOOLEAN default false);
                   
-- Переименование книги.
PROCEDURE RenameBook(fromBook in VARCHAR2,toBook in VARCHAR2);

-- Удаление книги.
PROCEDURE DeleteBook(DBook in VARCHAR2);

-- Удаление листа.
PROCEDURE DeleteSheet(DBook in VARCHAR2, DSheet in VARCHAR2);

-- Очистка данных всех листов книги.
-- Порядок листов и форматирование колонок остаётся.
-- Объединённые ячейки разъединяются.
PROCEDURE ClearBook(DBook in VARCHAR2);
PROCEDURE ClearOutBook;

-- Очистка данных листа книги.
-- Порядок листов и форматирование колонок остаётся.
-- Объединённые ячейки разъединяются.
PROCEDURE ClearSheet(DBook in VARCHAR2, DSheet in VARCHAR2);
PROCEDURE ClearOutSheet(DSheet in VARCHAR2);
PROCEDURE ClearOutSheet;

-- Предоставление колонки или ряда, состоящих из дат, для запроса.
-- Отсутствующие значения игнорируются.
-- Прередаются только значения с датой, которая не нулл.
FUNCTION Dates(RowVals in TRow)
return KOCEL.TDATES pipelined;

FUNCTION Dates(ColumnVals in TColumn)
return KOCEL.TDATES pipelined;

-- Предоставление колонки или ряда, состоящих из чисел, для запроса.
-- Отсутствующие значения игнорируются.
-- Прередаются только значения с числом, которое не нулл.
FUNCTION Nums(RowVals in TRow)
return KOCEL.TNUMS pipelined;

FUNCTION Nums(ColumnVals in TColumn)
return KOCEL.TNUMS pipelined;

-- Предоставление колонки или ряда, состоящих из строк, для запроса.
-- Отсутствующие значения игнорируются.
-- Прередаются только значения, если строка не пустая.
FUNCTION Strings(RowVals in TRow)
return KOCEL.TSTRINGS pipelined;

FUNCTION Strings(ColumnVals in TColumn)
return KOCEL.TSTRINGS pipelined;

-- Преобразование буквы колонки в номер.
FUNCTION Col2Num(columnChar in VARCHAR2) return NUMBER;

-- Преобразование номера колонки в строку.
FUNCTION Col2Char(columnNum in NUMBER) return VARCHAR2;


-- Предоставление диапазона для запроса.
-- Номера колонки должны быть от 1 до 26 (A..Z).
-- Отсутствующие в диапазоне ряды игнорируются.
FUNCTION RANGE(OutRange in TRange)
return KOCEL.TCELLS pipelined;

-- Предоставление листа для запроса.
-- Номера колонки должны быть от 1 до 26 (A..Z).
-- Отсутствующие в листе ряды игнорируются.
FUNCTION Vals(anySHEET in VARCHAR2,anyBOOK in VARCHAR2)
return KOCEL.TCELLS pipelined;

-- Предоставление входящего листа для запроса.
-- Номера колонки должны быть от 1 до 26 (A..Z).
-- Отсутствующие в листе ряды игнорируются.
FUNCTION inVals
return KOCEL.TCELLS pipelined;

-- Предоставление листа для запроса в виде значений, преобразованных в строки.
-- Номера колонки должны быть от 1 до 26 (A..Z).
-- Отсутствующие в листе ряды игнорируются.
FUNCTION Vals_as_Str(anySHEET in VARCHAR2,anyBOOK in VARCHAR2)
return KOCEL.TSCELLS pipelined;

end CELL;
/

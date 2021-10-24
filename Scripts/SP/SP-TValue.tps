-- TYPES
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010 
-- update 06.09.2010 14.09.2010 16.09.2010 08.10.2010 13.10.2010 20.10.2010
--        28.10.2010 19.11.2010 24.11.2010 10.12.2010 17.12.2010 09.02.2011
--		    18.03.2011 11.05.2011 17.10.2011 10.11.2011 27.01.2012 11.04.2012 
--        04.04.2013 09.04.2013 04.06.2013 17.06.2013 22.08.2013 03.07.2014
--        21.04.2015 12.03.2018
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TValue 
/* Универсальное значение для параметров оъектов каталога или модели,
а также глобальных параметров. Если глобальный параметр Check_ValEnabled не
установлен, то проверка значения не производится во всех членах типа! */
/* SP-TValue.tps*/
AS OBJECT
(
/* Тип параметра.*/
T  NUMBER,
/* Поле может содержать описание для параметра или самого значения.*/
COMMENTS VARCHAR2(4000),
/* Данное поле используется при организации диалога с пользователем в команде Get_User_Input. Если R_ONLY = 0, то значение параметра можно читать и записывать. Если R_ONLY = 1, то значение параметра можно только читать. Если R_ONLY = -1, то значение параметра должно быть обязательно обновлено пользователем. */
R_ONLY NUMBER(1),
/* Если тип имеет конечный набор значений, то поле содержит имя текущего
значения. Это же значение и есть представление данного значения в виде
строки.*/
E  VARCHAR2(128),
/* Часть значения.*/
N  NUMBER,
/* Часть значения.*/
D  DATE,
/* Часть значения. 
Как правило не совпадает с представлением значения в виде строки.*/
S  VARCHAR2(4000),
/* Часть значения.*/
X  NUMBER,
/* Часть значения.*/
Y  NUMBER,
--
/* Конструктор для создания нулл значения.*/
CONSTRUCTOR FUNCTION TValue 
RETURN SELF AS RESULT,
/* Конструктор проверяет существование типа значения.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2) 
RETURN SELF AS RESULT,
/* Конструктор проверяет существование типа значения.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER) 
RETURN SELF AS RESULT,
/* Конструктор проверяет значение и, если оно не подходит и установлен атрибут 
"Safe" != 0, то конструктор установит первое значение из набора значений,
определённого для данного типа.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2,StrValue IN VARCHAR2,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/* Конструктор проверяет значение и, если оно не подходит и установлен атрибут 
"Safe" != 0,  то конструктор установит первое значение из набора значений,
определённого для данного типа.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,StrValue IN VARCHAR2,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/* Конструктор проверяет существование типа значения и самого значения.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2,NumValue IN NUMBER)
RETURN SELF AS RESULT,
/* Конструктор проверяет существование типа значения и самого значения.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,NumValue IN NUMBER)
RETURN SELF AS RESULT,
/* Конструктор проверяет тип значения и, если тип имеет именованные значения,
то находит добавляет имя значения. Если параметр "DisN" равен нулл или "1", 
то поле дата будет нулл вне зависимости от параметра "D".
Конструктор проверяет значение и, если оно не подходит и установлен атрибут 
"Safe" != 0,  то конструктор установит первое значение из набора значений,
определённого для данного типа. Для ссылочного типа, если заполнено поле S, но отсутствует ссылка на идентификатор объекта в модели, то конструктор пытается его найти. Если ссылка недействительна, то будет возбуждена ошибка.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,
                            N    IN NUMBER,
                            D    IN DATE DEFAULT NULL,
                            DisN IN NUMBER DEFAULT 1,
                            S    IN VARCHAR2,
                            X    IN NUMBER,
                            Y    IN NUMBER,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/*Конструктор проверяет существование типа значения и самого значения. 
Если параметр "DisN" равен нулл или "1", то поле дата будет нулл вне
зависимости от параметра "D".Для ссылочного типа, если заполнено поле S, но отсутствует ссылка на идентификатор объекта в модели, то конструктор пытается его найти. Если ссылка недействительна, то будет возбуждена ошибка.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,
                            E    IN VARCHAR2,
                            N    IN NUMBER,
                            D    IN DATE DEFAULT NULL,
                            DisN IN NUMBER DEFAULT 1,
                            S    IN VARCHAR2,
                            X    IN NUMBER,
                            Y    IN NUMBER)
RETURN SELF AS RESULT,
--
/* Функция предоставляет для сравнения строку  состоящую из идентификатора
   типа и преобразованного к строке значения. 
   Возможна ошибка. Если строки длинные и отличаются в последних байтах,
   то будут равны!*/
MAP MEMBER FUNCTION map_values(self IN OUT NOCOPY SP.TVALUE) RETURN VARCHAR2,
/* Функция возвращает имя типа значения.*/
MEMBER FUNCTION TypeName RETURN VARCHAR2,
/* Функция возвращает значение в виде строки.*/
MEMBER FUNCTION asString(self IN OUT NOCOPY SP.TVALUE) RETURN VARCHAR2,
/* Функция возвращает значение в виде логического типа, если это возможно,
иначе возникает прерывание.*/
MEMBER FUNCTION asBoolean RETURN BOOLEAN,
/* Функция возвращает значение в виде логического типа, если это возможно,
иначе возникает прерывание.*/
MEMBER FUNCTION B RETURN BOOLEAN,
/* Процедура заполняет все поля значения на основании его строкового
представления, если это возможно. Если значение не подходит и установлен флаг 
"Safe" = true,  то процедура установит первое значение из набора значений,
определённого для данного типа. Если это невозможно или флаг "Safe" != true
то возникает прерывание.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, StrValue IN VARCHAR2,
                        Safe in BOOLEAN default false),
/* Процедура заполняет все поля значения на основании логического значения,
если это возможно, иначе возникает прерывание.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, BoolValue IN BOOLEAN),
/* Процедура заполняет все поля значения на основании числового значения,
если это возможно, иначе возникает прерывание.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, NumValue IN NUMBER),
/* Процедура копирует все поля значения.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, Val IN SP.TVALUE),
/* Процедура устанавливает поле R_ONLY = 1.*/
MEMBER PROCEDURE READ_ONLY(self IN OUT NOCOPY SP.TVALUE),
/* Процедура устанавливает поле R_ONLY = 0.*/
MEMBER PROCEDURE READ_WRITE(self IN OUT NOCOPY SP.TVALUE),
/* Процедура устанавливает поле R_ONLY = -1.*/
MEMBER PROCEDURE REQUIRED(self IN OUT NOCOPY SP.TVALUE)
);
/
GRANT EXECUTE ON SP.TValue TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM V_ FOR SP.TValue; 
--
-- end of file

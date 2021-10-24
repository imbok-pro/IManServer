CREATE OR REPLACE PACKAGE SP.INPUT
-- SP Input package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 13.10.2010 18.11.2010 22.11.2010 29.11.2010 20.12.2010 11.01.2011
--        13.01.2012 15.03.2012 04.06.2013 10.06.2013 22.08.2013 25.08.2013
--        04.10.2013 11.10.2013 16.10.2013 27.11.2013 13.02.2014 12.06.2014
--        13.06.2013 14.06.2014 15.07.2014 30.08.2014 08.09.2014 17.10.2014
--        04.11.2014 26.11.2014 28.11.2014 03.01.2015 06.01.2015 22.03.2015
--        25.03.2015 31.03.2015 20.04.2015-21.04.2015 10.07.2015 10.10.2016
--        12.04.2017 17.01.2018-19.01.2018 08.09.2021
AS
type TCatObject is Record(Name VARCHAR2(4000),ID NUMBER,GID NUMBER);
-- 1
FMT VARCHAR2(80) := NULL;
-- 2
NLS VARCHAR2(80) := NULL;
-- 3
CurType NUMBER := NULL;
-- 4
CurObject NUMBER := NULL;
-- 5
CurModelObject NUMBER:= NULL;
-- 6
CurDocGroupName SP.GROUPS.NAME%type := '';
-- 7
CurMacroCommand NUMBER := NULL;
-- 8
CurMacroLine NUMBER := NULL;
-- 9
CurMacroLineRef NUMBER := NULL;
-- 10
CurUser VARCHAR2(30) := NULL;
-- 11
CurPOID SP.COMMANDS.COMMENTS%type := '';
-- 12
CurParent SP.COMMANDS.COMMENTS%type := '\';
-- 13
CurModel NUMBER := NULL; 
-- 14
CurModelObjectParent NUMBER := NULL;
-- 15
CurAppName VARCHAR2(128) := NULL;
-- 16
CurFormName VARCHAR2(128) := NULL;
-- 17
CurSignature NUMBER := NULL;
-- 18
CurFormUserName VARCHAR2(128) := NULL;
-- 19
CurFormObjectName SP.COMMANDS.COMMENTS%type := NULL;
-- 20
CurParName VARCHAR2(128) := '';
-- 21
CurArrName SP.ARRAYS.NAME%type := '';
-- 22
CurArrGroup SP.GROUPS.NAME%type := '';
-- Признак исправления ошибочных именованных значений.
Safe BOOLEAN := false;

-- Сброс настройки формата и локализации даты, очистка временных таблиц.
PROCEDURE RESET;

-- Установка формата даты.
PROCEDURE SET_NLS(DFMT IN VARCHAR2, DNLS IN VARCHAR2);

-- Добавление роли.
PROCEDURE ROLE(NAME IN VARCHAR2, Comments IN VARCHAR2, ORA in NUMBER);

-- Добавление иерархии ролей.
PROCEDURE ROLE_REL(NAME IN VARCHAR2, PARENT IN VARCHAR2);

-- Добавление пользователя. (Пароль зашифрован) 
PROCEDURE USER(NAME IN VARCHAR2, PSW IN VARCHAR2);

-- Добавление роли пользователя.
PROCEDURE UserRole(NAME IN VARCHAR2, RoleName IN VARCHAR2);

-- Подкручивание последовательности.
PROCEDURE SEQ(NAME IN VARCHAR2, LAST_NUM IN NUMBER);

-- Добавление типа, или обновление, если тип существует.
PROCEDURE "Type"(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  -- Если блок проверки не определён, то значение именованное,
  -- и следующие поля несущественны.
  CheckVal IN VARCHAR2 DEFAULT NULL,
	StringToVal IN VARCHAR2 DEFAULT NULL,
	ValToString IN VARCHAR2 DEFAULT NULL,
	SetOfValues IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- Добавление или обновление именованного значения, если значение существует.
PROCEDURE Enum(
  NAME IN VARCHAR2,
	Comments IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
  EType IN VARCHAR2 DEFAULT NULL,
  EN IN NUMBER DEFAULT NULL,
  ED IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL, -- формат даты
  DNLS IN VARCHAR2 DEFAULT NULL, -- язык даты
  ES IN VARCHAR2 DEFAULT NULL,
	EX IN NUMBER DEFAULT NULL,
	EY IN NUMBER DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- Добавление глобального параметра и установка его значения по умолчанию
-- для нового пользователя.
PROCEDURE GlobalPar(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
	ParType IN VARCHAR2,
  Reaction IN VARCHAR2 DEFAULT NULL,
  R_ONLY IN NUMBER DEFAULT NULL,
	V IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL 
  );

-- Установка значения глобального параметра конкретного пользователя.
-- Если имя пользователя не указано, то добавляем последнему добавленному
-- пользователю или пользователю, которому только что добавляли параметр.
	PROCEDURE GlobalParValue(
  ParName IN VARCHAR2,
  V IN VARCHAR2,
  UserName IN VARCHAR2 DEFAULT NULL);

-- Добавление узла дерева каталога.
-- Если нужно присвоить родителю значение нулл, то нужно присвоить
-- параметру "ParentNode" значение "\".
PROCEDURE Node(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParentNode IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL);

-- Добавление группы, её описания, её родителя,
-- её позиции при упорядочивании групп одного родителя
-- и роли редактирования.
PROCEDURE BGroup(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER default null,
  Line IN NUMBER default null,
	Comments IN VARCHAR2 default null,
  Parent_Name IN VARCHAR2 default null,
  RoleName IN VARCHAR2 default null,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER default null);
  
-- Изменение группы - добавление ссылки на объект модели.
-- Группа становится прозвищем объекта.
PROCEDURE Alias(
  GroupName IN VARCHAR2,
  -- Имя модели => полное имя объекта
  ObjectName IN VARCHAR2);
  
-- Добавление документа, его формата, ссылки на группу, и номера параграфа
-- внутри одной группы, а также ролей доступа и редактирования.
PROCEDURE DOC(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER default null);

-- временнная заглушка.!!!!
PROCEDURE DOCs(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
	Q IN NUMBER default null);
  
-- Добавление элемента массива.
PROCEDURE ArrValue(
  -- полное имя массива.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- числовые индексы.
  indX in NUMBER DEFAULT NULL,
  indY in NUMBER DEFAULT NULL,
  indZ in NUMBER DEFAULT NULL,
  -- строковый индекс.
  indS in VARCHAR2 DEFAULT NULL,
  -- индекс по дате.
  indD in DATE DEFAULT NULL,
  -- строковое значение типа значения элемента массива.
  T IN VARCHAR2, 
  -- строковое значение элемента массива.  
  V IN VARCHAR2 DEFAULT NULL, 
  -- дата присвоения или изменения значения
  MDATE IN VARCHAR2 DEFAULT NULL,
  -- пользователь, изменивший или присвоивший значение.
  MUSER IN VARCHAR2 DEFAULT NULL
  );

-- Добавление объекта.
-- Если имя объекта содержит точку,
-- то считается что оно есть полное имя объекта.
-- В этом случае имя группы объекта игнорируется.
PROCEDURE OBJECT(
  NAME IN VARCHAR2,
  OID IN VARCHAR2 DEFAULT NULL,
  Kind IN VARCHAR2 DEFAULT NULL, -- (Single, Composit, Macro, Operation)
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
	GroupName IN VARCHAR2 DEFAULT NULL,
  -- Имя объекта шаблона, для добавлении всех его свойств в данный объект.
  Pars IN VARCHAR2 DEFAULT NULL,
  -- Множество параметров (строка, состоящая из имен параметров через запятую),
  -- которые не добавляются.
  ExceptPars IN VARCHAR2 DEFAULT NULL,
  UsingRole IN VARCHAR2 DEFAULT NULL,
  EditRole IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUser IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  -- Если параметр равен "-1", то при совпадении имён,
  -- произойдёт удаление всех параметров и макрокоманд у существующей
  -- макропроцедуры.
  -- При этом будет сохранён существующий OID!
	Q IN NUMBER DEFAULT NULL);

-- Добавление параметра объекта.
-- Параметры добавляются последнему добавленному объекту или объекту,
-- определённому переменными CurObject и CurObjectGroup.
-- Если группа объекта не определена, то объект ищется исключительно по имени.
-- Если имя объекта содержит точку, то трактуется как полное имя объекта,
-- в этом случае входной параметр "ObjectGroup" игнорируется.
-- Поиск без учёта группы существует для обратной совместимости.
-- Если определили один раз параметр DFMT или DNLS, то они становятся
-- умолчанием для последующих вызовов.
PROCEDURE ObjectPar(
  NAME IN VARCHAR2,
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParType IN VARCHAR2,
  V IN VARCHAR2 DEFAULT NULL,-- строковое значение
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
	X IN NUMBER DEFAULT NULL,
	Y IN NUMBER DEFAULT NULL,
  -- допустимые значения, регистр не учитывается :
  -- (R/W, R_Only , Required, ReadWrite, ReadOnly, Fixed)
  R_ONLY IN VARCHAR2 DEFAULT 'R/W',
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL -- при отладке содержит Object_ID
  );

-- Добавление Макрокоманды. Если имя объекта нулл,
-- то используется последний добавленный объект.
-- Указание имени объекта лишь для первой строчки последовательности
-- макрокоманд ускоряет загрузку.
-- Если группа объекта не определена, то объект ищется исключительно по имени.
-- Если имя объекта содержит точку, то трактуется как полное имя объекта,
-- в этом случае входной параметр "ObjectGroup" игнорируется.
-- Аналогично для используемого объекта.
-- Поиск без учёта группы существует для обратной совместимости.
-- Всё вышеизложенное про группу объекта так же относиться  и к определению
-- используемого объекта.
PROCEDURE Macro(
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
  -- Если номер строки не определён,
  -- то добавляем номер на единицу больше максимального.
  LineNum IN NUMBER DEFAULT NULL,
  Command IN VARCHAR2,
	Comments IN VARCHAR2 DEFAULT NULL,
  Alias IN VARCHAR2 DEFAULT NULL,
  UsedObject IN VARCHAR2 DEFAULT NULL,
  UsedObjectGroup IN VARCHAR2 DEFAULT NULL,
	MacroBlock IN VARCHAR2 DEFAULT NULL,
	Condition IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- Добавление  модели.
PROCEDURE MODEL(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
  PERSISTENT IN NUMBER DEFAULT 0,
  LOCAL IN NUMBER DEFAULT 0,
  USING_ROLE IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL
  );

-- Добавление объекта модели.
PROCEDURE ModelObject(
  -- Имя модели. Если опущено, то используется предыдущее значение.
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Имя объекта в модели.
  ObjectName IN VARCHAR2,
  -- Уникальный идентификатор объекта в сторонней модели.
  OID IN VARCHAR2 DEFAULT NULL,
  -- Ссылка на уникальный идентификатор родительского объекта.
  -- Значение null, указывает на необходимость использовать параметр ObjectPath
  -- Если опущены оба параметра, то используется предыдущее значение.
  POID IN VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя родительского объекта в модели.
  -- Если необходимо ввести корень дерева модели,
  -- то необходимо присвоить ObjectPath значение '/'.
  -- Если присутствует параметр POID, то значения этого параметра будет
  -- проигнорировано.
  -- Если опущено, то используется предыдущее значение.
  ObjectPath IN VARCHAR2 DEFAULT NULL,
  -- Имя прообраза параметра в каталоге.
  -- Если имя прообраза объекта содержит точку, 
  -- то трактуется как полное имя объекта,
  -- в этом случае входной параметр "CatalogGroupName" игнорируется.
  CatalogName IN VARCHAR2,
  -- Имя группы прообраза объекта в каталоге. 
  -- При отсутствии данного параметра предполагается уникальность имени в
  -- каталоге. Добавлено для совместимость с наборами данных предыдущих версий.
  CatalogGroupName IN VARCHAR2 DEFAULT NULL,
	-- Имя композитного объекта - непосредственно построившего объект.
  -- Если имя прообраза объекта содержит точку, 
  -- то трактуется как полное имя объекта,
  -- в этом случае входной параметр "CatalogGroupName" игнорируется.
	CompositName IN VARCHAR2 DEFAULT NULL,
  -- Группа композита.
	CompositGroupName IN VARCHAR2 DEFAULT NULL,
	-- Имя композитного объекта, с которого было начато построение объекта
  -- модели.
  -- Если имя прообраза объекта содержит точку, 
  -- то трактуется как полное имя объекта,
  -- в этом случае входной параметр "CatalogGroupName" игнорируется.
	StartCompositName IN VARCHAR2 DEFAULT NULL,
  -- Группа композитного объекта, с которого было начато построение объекта
  -- модели.
  StartCompositGroupName IN VARCHAR2 DEFAULT NULL,
  -- Флаг, требующий пересоздать объект.
  Modified IN BOOLEAN  DEFAULT NULL,
  -- Роль использования объекта модели.
  UsingRoleName IN VARCHAR2 DEFAULT NULL,
  -- Роль изменения объекта модели.
  EditRoleName IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  );

-- Добавление не каталожного или переопределённого каталожного параметра
-- объекта модели.
-- Если имя модели и имя объекта (и его OID) равны нулл,
-- то параметры добавляются последнему добавленному объекту.
PROCEDURE ModelObjectPar(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID IN VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели используется,
  -- если опущен уникальный идентификатор.
  -- Если опущены как OID так и FullName, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра.
  NAME IN VARCHAR2,
  -- Тип параметра, необходим для сторонних параметров объекта,
  -- параметров, отсутствующих в описании прообраза объекта в каталоге.
  T IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
  X IN NUMBER DEFAULT NULL,
  Y IN NUMBER DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  );

-- Добавление параметра типа ссылка на объект модели.
-- Если имя модели и имя объекта (и его OID) равны нулл,
-- то параметры добавляются последнему добавленному объекту.
PROCEDURE ModelObjectRel(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID IN VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра.
  NAME IN VARCHAR2,
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  );

-- Добавление истории параметра объекта модели.
-- Если имя модели и имя объекта (и его OID) равны нулл,
-- то значения добавляются последнему добавленному объекту.
-- Если имя параметра опущено,
-- то сохраняется история последнего сохраняемого параметра.
PROCEDURE ModelObjectParStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра. Если опущен берём предыдущее значение.
  NAME IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
  X IN NUMBER DEFAULT NULL,
  Y IN NUMBER DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  );

-- Добавление истории связей объектов модели.
-- Если имя модели и имя объекта (и его OID) равны нулл,
-- то значения добавляются последнему добавленному объекту.
-- Если имя параметра опущено,
-- то сохраняется история последнего сохраняемого параметра.
PROCEDURE ModelObjectRelStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра. Если опущен берём предыдущее значение.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- Ссылка по OID имеет приоритет.
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  );

-- Добавление сохранённого параметра формы приложения.
-- Если имя приложения, имя формы, её сигнатура или имя объекта равны нулл,
-- то параметры добавляются к последнему добавленному объекту.
-- Аналогично с именем пользователя.
-- При изменении любого параметра, идентифицирующего форму,
-- производится фиксация значений параметров,
-- добавленных в предыдущих вызовах этой процедуры.
PROCEDURE FormPar(
  AppName IN VARCHAR2 DEFAULT NULL,
  FormName IN VARCHAR2 DEFAULT NULL,
  FormSignature IN NUMBER DEFAULT NULL,
  UserName IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  NAME IN VARCHAR2,
  V IN VARCHAR2,
  Ord IN NUMBER
  );

END INPUT;
/

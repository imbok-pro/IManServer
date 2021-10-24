-- SP ENUMS
-- by Nikolay Krasilnikov
-- create 05.08.2010
-- update 02.09.2010 22.09.2010 03.11.2010 08.11.2010 19.11.2010 09.12.2010
--        22.12.2010 18.01.2011 26.01.2011 10.02.2011 15.03.2011 17.03.2011
--				06.04.2011 04.05.2011 13.05.2011 19.05.2011 08.06.2011 06.10.2011
--        12.10.2011 14.10.2011 23.10.2011 25.10.2011 02.11.2011 09.11.2011
--        18.11.2011 25.11.2011 30.11.2011 05.12.2011 21.12.2011 16.03.2012
--        20.03.2012 04.06.2012 17.08.2012 24.12.2012 24.01.2013 04.02.2013
--        04.03.2013 22.03.2013 10.06.2013 25.06.2013 20.08.2013 25.08.2013
--        04.10.2013 30.04.2014 04.06.2014 11.06.2014 13.06.2014 15.06.2014
--        30.06.2014 01.07.2014 10.07.2014 22.07.2014 25.07.2014-26.08.2014
--        30.08.2014 01.09.2014 08.09.2014 13.10.2014 04.11.2014
--        16.11.2014 by Piatakov
--        11.01.2017 28.02.2017 10.03.2017 13.03.2017 16.03.2017 28.03.2017
--        19.11.2020 07.03.2021 29.03.2021 01.07.2021 15.07.2021-16.07.2021
--        20.07.2021 02.08.2021 07.08.2021
--*****************************************************************************
declare
i NUMBER;
tmp SP.COMMANDS.COMMENTS%type;
begin
i:=0;
-- TBoolean
-------------------------------------------------------------------------------
tmp:='Логическая ложь.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBoolean,'false',tmp,0,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Логическая истина.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBoolean,'true',tmp,1,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

-- TNullBoolean
-------------------------------------------------------------------------------
tmp:='Логическая ложь.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNullBoolean,'false',tmp,0,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Логическая истина.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNullBoolean,'true',tmp,1,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='null';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNullBoolean,'null',tmp,-1,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

-- TNLang	
-------------------------------------------------------------------------------
tmp:='Язык сессии русский.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNLang,'RU',tmp,null,null,'RUSSIAN',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Язык сессии английский.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNLang,'EN',tmp,null,null,'AMERICAN',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
	
-- TNTerritory	
-------------------------------------------------------------------------------
tmp:='Территория сессии Россия.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNTerritory,'RU',tmp,null,null,'RUSSIA',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Территория сессии Америка.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNTerritory,'US',tmp,null,null,'AMERICA',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
	
-- TNNumChars	
-------------------------------------------------------------------------------
tmp:='Десятичный разделитель запятая, а тысяч - точка.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNNumChars,'DComaTPoint',tmp,null,null,', .',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Десятичный разделитель точка, а тысяч - запятая.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNNumChars,'DPointTComa',tmp,null,null,'. ,',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Десятичный разделитель запятая, а тысяч - пробел.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNNumChars,'DComaTBlank',tmp,null,null,',  ',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Десятичный разделитель точка, а тысяч - пробел.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNNumChars,'DPointTBlank',tmp,null,null,'.  ',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
	
-- TNSort	
-------------------------------------------------------------------------------
tmp:='Правила сортировки сессии по русски.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNSort,'RU',tmp,null,null,'RUSSIAN',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Бинарные правила сортировки.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNSort,'BINARY',tmp,null,null,'BINARY',null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	

-- TIType
-------------------------------------------------------------------------------
tmp:='Тип не определён. Используется при создании неполностью определённых псевдообъектов. Данные объекты могут применяться, например, для нахождения реального объекта по его имени или идентификатору.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'notDef',tmp,
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('04-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система общего назначения. Композитные объекты всегда принадлежат некоторой системе общего назначения.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GenericSystem',tmp,
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система координат.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CoordinateSystem',tmp,
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система, определяющая рабочую площадку или участок большого объекта.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'AreaSystem',tmp,
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система кабельных коммуникаций.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ConduitSystem',tmp,
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Электротехническая система.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ElectricalSystem',tmp,
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система, содержащая некоторое оборудование.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'EquipmentSystem',tmp,
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система воздуховодов.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DuctingSystem',tmp,
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система трубопроводов.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipingSystem',tmp,
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Состав трубопровода.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Pipeline',tmp,
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система из строительных конструкций.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'StructuralSystem',tmp,
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Система содержащая отдельный блок завода.';
insert into SP.ENUM_VAL_S 
 VALUES (i,null,SP.G.TIType,'UnitSystem',tmp,
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Прямоугольные оси XYZ.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridAxis',tmp,
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Плоскость перпендикулярная оси X или Y. Плоскость системы коорданат в Tekla';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridPlane',tmp,
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Линия сетки';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridLine',tmp,
    14,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Плоскость перпендикулярная оси Z.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridElevationPlane',tmp,
    15,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Плоскость, включающая в себя ось Z.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridRadialPlane',tmp,
    16,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Цилиндр вокруг оси Z.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridCylinder',tmp,
    17,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Окружность.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GridArc',tmp,
    18,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Четвёртая часть от GridArc.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ArcQuadrant',tmp,
    19,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--	
tmp:='Металлоконструкция - MemberSystem.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'MemberSystem',tmp,
    20,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Соединение металлоконструкций - AssemblyConnection.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'AssemblyConnection',tmp,
    21,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Лестница - Stair.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Stair',tmp,
    22,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Вертикальная летница Ladder.';
insert into SP.ENUM_VAL_S 
 VALUES (i,null,SP.G.TIType,'Ladder',tmp,
    23,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Рельс для тельфера - HandRail.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HandRail',tmp,
    24,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Плита пола - Slab.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Slab',tmp,
    25,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Плита стены - Wall';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'WallSystem',tmp,
    26,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Оборудование - Equipment';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Equipment',tmp,
    27,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Формы Shape- GenericShape';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GenericShape',tmp,
    28,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Призматическая форма - PrismaticShape';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PrismaticShape',tmp,
    29,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Ноззл трубопроводный - PipeNozzle';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeNozzle',tmp,
    30,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Трубопоток - PipeRun';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeRun',tmp,
    31,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Трубопроводный разветвитель - PipeBranchFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeBranchFeature',tmp,
    32,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Опора трубопроводная - PipeSupport';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeSupport',tmp,
    33,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Труба - PipeStraightFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeStraightFeature',tmp,
    34,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Колено трубопроводное - PipeTurnFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeTurnFeature',tmp,
    35,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Конец трубопроводный - PipeEndFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeEndFeature',tmp,
    36,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='HrgConnection - ';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HrgConnection',tmp,
    37,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='StandartComponent';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'StandartComponent',tmp,
    38,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='ConnectionComponent';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ConnectionComponent',tmp,
    39,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='LogicalComponent';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LogicalComponent',tmp,
    40,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='PipeAlongLegFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeAlongLegFeature',tmp,
    41,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='RootSystem';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HierarchiesRoot',tmp,
    42,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Прямой отрезок трубы.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeStockPart',tmp,
    43,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Компонент прубопровода - ревизия, муфта, торойник и т.д.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeComponent',tmp,
    44,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Designed Solid';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BusinessObjectEx1',tmp,
    45,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='UnSupported';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'UnSupported',tmp,
    46,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='ControlPoint';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ControlPoint',tmp,
    47,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='PipeSpecialty';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeSpecialty',tmp,
    48,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='PipeInstrument';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeInstrument',tmp,
    49,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Абстрактный класс для трубопроводного соединения в SP3D, а также соединение в Tekla.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Connection',tmp,
    50,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Сварное соединение трубопровода';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeWeld',tmp,
    51,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Затвор трубопроводный';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeBoltSet',tmp,
    52,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='прокладка трубопроводная';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeGasket',tmp,
    53,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='каталожный компонент трубопровода';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CataloguePipeComponent',tmp,
    54,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='опора (подвеска), разработанная пользователем';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DesignSupport',tmp,
    55,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='HgrPort';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HgrPort',tmp,
    56,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='PipeTapFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'PipeTapFeature',tmp,
    57,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Трасса кабельных лотков - Cableway';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Cableway',tmp,
    58,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Узел прямолинейного участка трассы кабельных лотков - CablewayStraightFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CablewayStraightFeature',tmp,
    59,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Компонент трассы кабельных лотков - CableTrayComponent';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CableTrayComponent',tmp,
    60,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Прямолинейный отрезок трассы кабельных лотков - CableTrayStockPart';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CableTrayStockPart',tmp,
    61,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Узел разветвительного участка трассы кабельных лотков - CablewayAlongLegFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CablewayAlongLegFeature',tmp,
    62,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Узел переходного участка трассы кабельных лотков - CablewayAlongLegTransitionFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CablewayAlongLegTransitionFeature',tmp,
    63,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Узел поворотного участка трассы кабельных лотков - CablewayTurnFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CablewayTurnFeature',tmp,
    64,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='Узел оконечности трассы кабельных лотков - CablewayEndFeature';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CablewayEndFeature',tmp,
    65,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Ноззл кабельного лотка - CableTrayPort';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CableTrayPort',tmp,
    66,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Соединение стен - WallConnection';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'WallConnection',tmp,
    67,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Система кабельных лотков - CableTraySystem. То же, что и Cableway, но без SKETCH points, сечения и оконечных элементов';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CableTraySystem',tmp,
    68,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
tmp:='Пользовательское (некаталожное) оборудование - DesignedEquipment.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DesignedEquipment',tmp,
    69,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Данные таблицы Word, Excel etc.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'OLETable',tmp,
    70,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Строка таблицы Word, Excel etc.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'OLERow',tmp,
    71,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Ячейка таблицы Word, Excel etc.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'OLECell',tmp,
    72,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The beam.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BEAM',tmp,
    73,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The polybeam.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'POLYBEAM',tmp,
    74,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The contour plate.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CONTOURPLATE',tmp,
    75,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The boolean part.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BOOLEANPART',tmp,
    76,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The fitting.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'FITTING',tmp,
    77,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The cutplane.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CUTPLANE',tmp,
    78,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The surface treatment.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'SURFACE_TREATMENT',tmp,
    79,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The weld.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'WELD',tmp,
    80,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The assembly.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ASSEMBLY',tmp,
    81,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The single rebar.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'SINGLEREBAR',tmp,
    82,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The rebar group.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REBARGROUP',tmp,
    83,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The rebar mesh.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REBARMESH',tmp,
    84,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The rebar strand.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REBARSTRAND',tmp,
    85,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The control plane.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CONTROL_PLANE',tmp,
    86,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The bolt array.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BOLT_ARRAY',tmp,
    87,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The bolt circle.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BOLT_CIRCLE',tmp,
    88,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The bolt XY list.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BOLT_XYLIST',tmp,
    89,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The point load.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_POINT',tmp,
    90,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The line load.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_LINE',tmp,
    91,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The area load.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_AREA',tmp,
    92,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The uniform load.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_UNIFORM',tmp,
    93,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The grid.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'GRID',tmp,
    94,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

-- Повтор названий интерграфа - объеденены
-- tmp:='The grid plane.';
-- insert into SP.ENUM_VAL_S 
--   VALUES (i,null,SP.G.TIType,'GRIDPLANE',tmp,
--     XX,null,null,null,null,
--     G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- i:=i+1;
--	
-- tmp:='The connection.';
-- insert into SP.ENUM_VAL_S 
--   VALUES (i,null,SP.G.TIType,'CONNECTION',tmp,
--     XX,null,null,null,null,
--     G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- i:=i+1;
--	
tmp:='The component.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'COMPONENT',tmp,
    95,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The seam.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'SEAM',tmp,
    96,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The detail.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DETAIL',tmp,
    97,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The reference model.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REFERENCE_MODEL',tmp,
    98,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The rebar splice.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REBAR_SPLICE',tmp,
    99,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The load group.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_GROUP',tmp,
    100,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The task.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'TASK',tmp,
    101,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The task dependency.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'TASK_DEPENDENCY',tmp,
    102,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The task worktype.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'TASK_WORKTYPE',tmp,
    103,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The polygon weld.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'POLYGON_WELD',tmp,
    104,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The logical weld.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOGICAL_WELD',tmp,
    105,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The circle rebar.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CIRCLEREBAR',tmp,
    106,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The hierarchic definition.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HIERARCHIC_DEFINITION',tmp,
    107,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The hierarchic object.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'HIERARCHIC_OBJECT',tmp,
    108,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The analysis geometry.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ANALYSIS_GEOMETRY',tmp,
    109,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
tmp:='The analysis part.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'ANALYSIS_PART',tmp,
    110,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The reference model object.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'REFERENCE_MODEL_OBJECT',tmp,
    111,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The custom part object.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CUSTOM_PART',tmp,
    112,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The circle rebar group.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CIRCLE_REBARGROUP',tmp,
    113,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The curved rebar group.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CURVED_REBARGROUP',tmp,
    114,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The edge chamfer.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'EDGE_CHAMFER',tmp,
    115,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The pour object.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'POUR_OBJECT',tmp,
    116,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The pour break.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'POUR_BREAK',tmp,
    117,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The control line.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CONTROL_LINE',tmp,
    118,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The temperature load.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'LOAD_TEMPERATURE',tmp,
    119,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='The Brep part instance.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'BREP',tmp,
    120,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Папка, каталог, директория файловой системы.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Folder',tmp,
    121,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Файл, документ файловой системы.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'File',tmp,
    122,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Операция считывания каталожной структуры в текущую модель в текущий Root.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opReadFolderStructure',tmp,
    123,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:=
'Опреация создания каталожной структуры по образцу модели и указанному пути';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opCreateFolderStructure',tmp,
    124,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--	
tmp:='Сотрудник';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Employee',tmp,
    125,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Операция черчения Текла.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Drawing',tmp,
    126,null,null,null,null,
    G.OTHER_GROUP, to_date('22-07-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Псевдообъект - коллекция свойств родительского объекта.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Properties',tmp,
    127,null,null,null,null,
    G.OTHER_GROUP, to_date('25-07-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Бухгалтерская операция, показывающая изменения стоимости или количества на двух корреспондирующих бухгалтерских счетах.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Transaction',tmp,
    128,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Статья бухгалтерского или оперативного учёта.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'Account',tmp,
    129,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Сектора шаблонов заголовков документов.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CodeSectors',tmp,
    130,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Шаблоны заголовков документов.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DocPrjHeaders',tmp,
    131,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Справочник возможных значений секторов шаблона документа,  с типом REFS.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CodeSectorsRefs',tmp,
    132,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Справочник возможных значений секторов шаблона документа,  с типом REFS - строки.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'CodeSectorsRefRows',tmp,
    133,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Операция чтения информации о файлe (файлах).';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opGetFileInfo',tmp,
    134,null,null,null,null,
    G.OTHER_GROUP, to_date('08-09-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Замечание к документу DocFlow.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'DocNote',tmp,
    135,null,null,null,null,
    G.OTHER_GROUP, to_date('08-09-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--

tmp:=' Загрузить содержимое файла в базу, так же и с выделением структурной информации.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opChangeStorage',tmp,
    136,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--

tmp:='Загрузить содержимое файла в базу, так же и с выделением структурной информации.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opLoadFile',tmp,
    137,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Скопировать файл.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opCopyFile',tmp,
    138,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:=' Получает табличные данные из документов Word и Excel .';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opGetTableData',tmp,
    139,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:=' Начинает экспорт в файлы Word и Excel.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opStartOleExport',tmp,
    140,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Выводит текст в файл.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opAddText',tmp,
    141,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:=' Устанавливает формат последующего текста.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opSetStyle',tmp,
    142,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:=' Добавляет таблицу в файл';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opAddTable',tmp,
    143,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Добавляет строку';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opAddRow',tmp,
    144,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Заполняет ячейку ';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opPutCell',tmp,
   145 ,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Заканчивает вывод файла Word или Excel.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'opFinishOleExport',tmp,
    146,null,null,null,null,
    G.OTHER_GROUP, to_date('16-11-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Составной объект Zuken e3.series.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'E3_SYSTEM',tmp,
    147,null,null,null,null,
    G.OTHER_GROUP, to_date('28-03-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:='Атомарный объект Zuken e3.series.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TIType,'E3_ELEMENT',tmp,
    148,null,null,null,null,
    G.OTHER_GROUP, to_date('28-03-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--

--TCardinalPoint
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Bound','Привязка.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Bottom Left','Нижний левый.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Bottom Center','Нижний в центре.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Bottom Right','Нижний правый.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Center Left','Центральный левый.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Center','Центральный.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Center Right','Центральный правый.',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Top Left','Верхний левый.',
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Top Center','Верхний в центре.',
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Top Right','Верхний правый.',
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Centroid','Центроид.',
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Centroid Bottom','Центроид нижний.',
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Centroid Left','Центроид левый.',
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Centroid Right','Центроид правый.',
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Centroid Top','Центроид верхний.',
    014,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCardinalPoint,'Shear Center','Центр кручения.',
    15,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--
--TCSType
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSType,'Grids','Сетка.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSType,'Ship','Неизучено.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSType,'Other','Неизучено.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TCSHand
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSHand,'LeftHand','Правило левой руки.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSHand,'RightHand','Правило правой руки.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCSHand,'RightAndLeftHand','Не изучено.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TAxisType
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAxisType,'Radial',
    'Радиальноя ось радиальной системы координат.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAxisType,'Cylindrical',
    'Цилиндрическая ось цилиндрической системы координат.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAxisType,'X','Ось Х.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAxisType,'Y','Ось Y.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAxisType,'Z','Ось Z.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TNotePurpose
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'null',
    'Не определено.',
    -1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'General',
    'Общий.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Design',
    'Конструкция.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Fabrication','Для изготовления.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Instalation','Монтировать.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Operation and Maintenance',
          'Эксплуатация и поддержка.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Inspection','Ревизия.',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Remark','Примечание.',
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Material of Construction',
          'Материал и конструкция.',
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Design Review','Проверка конструкции.',
          9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Piping Specification note','Подробное описание.',
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Justification','Оправдание.',
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Procurement','Снабжение.',
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TNotePurpose,'Standard note',
          'Стандартное примечание note.',
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TObjectKind
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TObjectKind,'NATIVE',
    'Объект интерграфа.',
    -1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TObjectKind,'SINGLE',
    'Еденичный элемент.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TObjectKind,'COMPOSIT','Сборная конструкция.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TObjectKind,'MACRO','Макропроцедура.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TObjectKind,'OPERATION','Единичная операция сервера моделей.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TCurveType
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCurveType,'Line',
    'Прямая рисуется начиная с точки номер которой является суффиксом параметра.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCurveType,'Arc',
    'Дуга рисуется начиная с точки номер которой является суффиксом параметра, при этом третья точка относительно начала определяет конец дуги. А все три точки вместе определяют единственную окружность.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TFacePosition
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFacePosition,'Top',
    'Опорная плоскость - верхняя грань плиты.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFacePosition,'Center',
    'Опорная плоскость - срединная плоскость плиты.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFacePosition,'Bottom',
    'Опорная плоскость - нижняя грань плиты ',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--THandrailOrientation
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.THandrailOrientation,'Always Vertical',
    'Столбики расположены вертикально.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.THandrailOrientation,'Perpendicular to Slope',
    'Столбики расположены перпендикулярно поручням.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--THandrailEndTreatment - края-окончания перил
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.THandrailEndTreatment,'None',
    'Простое окончание перил.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.THandrailEndTreatment,'Circular',
    'Закругленное окончание перил.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.THandrailEndTreatment,'Rectangular',
    'Прямоугольное окончание перил.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TPostConnType - способ крепленя столбиков перил
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPostConnType,'Top flush mounted with pad',
    'Top flush mounted with pad.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPostConnType,'Top mounted embedded',
    'Top mounted embedded.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPostConnType,'Side mount with pad',
    'Side mount with pad.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPostConnType,'Side mount with bracket',
    'Side mount with bracket.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TGraphicPrimitive
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'RtCircularCylinder',
    'Круговой цилиндр (RtCircularCylinder).',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'RtCircularCone',
    'Усеченный круговой правильный конус (RtCircularCone).',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'EccentricCone',
    'Эксцентрический усеченный конус (EccentricCone).',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'Sphere',
    'Сфера (Sphere).',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'SemiEllipticalHead',
    'Половина элипсоида вращения (SemiEllipticalHead).',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'RectangularSolid',
    'Параллелепипед (Rectangular Solid).',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'TriangularSolid',
    'Треугольная призма (TriangularSolid).',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'CircularTori',
    'Сегмент кругового тора (Circular torus).',
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'RectangularTorus',
    'Сектор прямоугольного тора (Rectangular Torus).',
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'EccentricRectangularPrism',
    'Эксцентрический прямоугольный трапециоид (Eccentric Rectangular Prism).',
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'TransitionElement',
    'Переходный элемент (TransitionElement).',
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'TruncatedRectangularPrism',
    'Равнобочный трапециоид (TruncatedRectangularPrism).',
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'EccentricTransitionElement',
    'Эксцентрический переходной элемент (Eccentric Transition Element).',
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'Platform1',
    'Платформа 1 (Platform1).',
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'Platform2',
    'Платформа 2 (Platform2).',
    14,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'OctogonalSolid',
    'Восьмигранный цилиндр (Octagonal Solid).',
    15,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'HexagonalSolid',
    'Шестигранный цилиндр (Hexagonal Solid).',
    16,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'DatumShape',
    'Репер (datum shape).',
    17,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TGraphicPrimitive,'SemiPrism',
    'Усечённая четырёхугольная призма.',
    18,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TGraphicPrimitive
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Circle','Circle.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Rectangle','Rectangle.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Triangle','Triangle.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Ellipse','Ellipse.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Hexagon', 'Hexagon.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Sector','Sector.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'Road','Road.',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'TrapezeR','TrapezeR.',
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'TrapezeC','TrapezeC.',
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TSection,'IBeam','IBeam.',
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TBeep
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBeep,'Beep','Универсальный звук.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBeep,'Asterix','Звёздочка.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBeep,'Exclamation','Восклицание.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBeep,'Hand','Неизучено.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TBeep,'Question','Вопрос.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--TAspectCode
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Simple physical', 'The Simple Physical aspect includes primitive shapes. The space could be a field junction box displayed in both the model and in drawings. This is the default aspect when publishing 3D Model Data documents if no other aspects are selected.',
    power(2,0),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Detailed physical', 'The Detailed Physical aspect provides a more detailed view of equipment in the model. For example, certain types of equipment may include legs and lugs. You select the Simple Physical aspect to create a less cluttered view of the object, showing only the body of the equipment. However, the Detailed Physical aspect shows all the graphical details associated with the equipment.',
    power(2,4),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Insulation', 'The Insulation aspect shows an area around a piece of equipment indicating insulation is present. For example, a 4-inch pipe with insulation might look like an 8-inch pipe when the Insulation aspect is selected.',
    power(2,5),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Operation', 'The Operation aspect includes the area or space around the object required for operation of the object. This space shows in the model but not in drawings. The Operation aspect leaves enough space around a motor for a person to operate the motor.',
    power(2,6),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Maintenance', 'The Maintenance aspect includes the area or space around the object required to perform maintenance on the object. This space may appear in the model but not in drawings. The Maintenance aspect leaves enough space around a motor to perform maintenance on the motor, including space to remove the motor, if necessary.',
    power(2,7),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Reference Geometry', 'The Reference Geometry aspect allows you to construct or add graphical objects that do not participate in interference checking. For example, a reference geometry object could be the obstruction volume for a door on a field junction box. Another example is a spherical control point.',
    power(2,8),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TAspectCode,'Centerline', 'Скелет из поверхностей.',
    power(2,9),null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--TCPSubType Подтип контрольной точки.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Process Equipment', 'Process Equipment',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Mechanical Equipment', 'Mechanical Equipment',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Foundation', 'Foundation',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Structure', 'Structure',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Piping Mfg Limit Point',
    'Piping Mfg Limit Point',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Spool Break', 'Spool Break',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Duct Break Point', 'Duct Break Point',
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Pipe Break - Fabrication',
    'WBS Pipe Break - Fabrication',
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Break Point Type 1',
    'WBS Break Point Type 1',
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Break Point Type 2',
    'WBS Break Point Type 2',
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Break Point Type 3',
    'WBS Break Point Type 3',
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Break Point Type 4',
    'WBS Break Point Type 4',
    14,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Break Point Type 5',
    'WBS Break Point Type 5',
    16,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Pipe Break - Generic',
    'WBS Pipe Break - Generic',
    18,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Pipe Break - Stress',
    'WBS Pipe Break - Stress',
    15,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Pipe Break - Tracing',
    'WBS Pipe Break - Tracing',
    17,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'WBS Pipe Break - System',
    'WBS Pipe Break - System',
    19,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Elevation Callout', 'Elevation Callout',
    51,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Ad Hoc Note', 'Ad Hoc Note',
    52,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'CAD Detail', 'CAD Detail',
    53,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPSubType,'Key Plan Callout', 'Key Plan Callout',
    54,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--TCPType Тип контрольной точки.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPType,'Control Point', 'Control Point',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPType,'Key Point', 'Key Point',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCPType,'Insertion Point', 'Insertion Point',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
	
--TCableTrayShape Форма сечения кабельного лотка.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCableTrayShape,'Rectangular', 'Rectangular',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCableTrayShape,'FlatOval', 'Flat Oval',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TCableTrayShape,'Round', 'Round',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	

-- PositionDepth.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionDepth,'MIDDLE', 'Середина профиля.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionDepth,'FRONT', 'Передняя часть профиля.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionDepth,'BEHIND', 'Задняя часть профиля.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
-- PositionPlane.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionPlane,'MIDDLE', 'Середина профиля.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionPlane,'LEFT', 'Левая часть профиля.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionPlane,'RIGHT', 'Правая часть профиля.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
-- PositionRotation.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionRotation,'FRONT', 'Левая часть профиля.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionRotation,'TOP', 'Дальняя  часть профиля.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionRotation,'BACK', 'Ближняя часть профиля.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TPositionRotation,'BELOW', 'Правая часть профиля.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
-- ServerType.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TServerType,'Local', 'Локальный сервер модели. Модель строится только в базе алгоритмов и не привязана к внешнему серверу модели.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TServerType,'Primary', 'Первичный сервер модели.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TServerType,'Secondary', 'Вторичный сервер модели.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
-- DrawingType.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TDrawingType,'GADrawing', 'Создание чертежа общего вида.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('22-07-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
-- insert into SP.ENUM_VAL_S 
--   VALUES (i,null,SP.G.TDrawingType,'...', '...',
--     1,null,null,null,null,
--     G.OTHER_GROUP, to_date('22-07-2014','dd-mm-yyyy'), 'SP');
-- i:=i+1;	
-- --
-- insert into SP.ENUM_VAL_S 
--   VALUES (i,null,SP.G.TDrawingType,'...', '...',
--     2,null,null,null,null,
--     G.OTHER_GROUP, to_date('22-07-2014','dd-mm-yyyy'), 'SP');
-- i:=i+1;	
--
-- Modified.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TModified,'Unchanged', 'Сущьность неизменена.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TModified,'Inserted', 'Сущьность добавлена.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TModified,'Updated', 'Сущьность изменена.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TModified,'Deleted', 'Сущьность удалена.',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('26-08-2014','dd-mm-yyyy'), 'SP');
i:=i+1;	
--
--Типы объектов Pointcad.E3Series.
--копия перечисления Pointcad.E3Series.Wrapper.Enums.ItemTypes
--Список неизвестных типов с номерами:
--7,9,18,35,36,49,59,66,69,71,74,106,109,124,125,134,140,141,142,144,145,146,
--153,155,157,158,159,160,162,181,182,183,184,185,186,191,195,196,197,198,199
--------------------------------------------------------------------------------
tmp:= 'Не известно что?';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Проект.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Job', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Компонент в БД.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Component', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 3.'
	||'Похоже на тип наконечник.'
	||'Участвует в таблице DBCIRC в поле GATID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown3', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Вывод компонента в БД.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'ComponentPin', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Шаблон неразмещенного символа для размещения.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'SymbolType', tmp,
	5, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Графический элемент символа БД.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'DBSymbolGraph', tmp,
	6, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 8.'
	||'Похоже на тип "Вывода символа БД".'
	||'Участвует в таблице DBSYMPIN в поле ID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown8', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Изделие.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Device', tmp,
	10, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Щит?';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Gate', tmp,
	11, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Вывод изделия.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'DevicePin', tmp,
	12, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Блок.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Block', tmp,
	13, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Блочный соединитель.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'BlockConnector', tmp,
	14, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Вывод блочного соединителя.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'BlockConnectorPin', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Кабельный соединитель.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Connector', tmp,
	17, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Вывод кабельного соединителя.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'ConnectorPin', tmp,
	19, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Кабель.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Cable', tmp,
	20, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Провод или жила.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'WireOrCore', tmp,
	22, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Сигнал.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Signal', tmp,
	24, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 26.'
	||'Похоже на тип атрибута в БД.'
	||'Участвует в таблице ATTNAM в поле ATTNAMID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown26', tmp,
	26, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Атрибут.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Attribute', tmp,
	27, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Лист.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Sheet', tmp,
	28, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Ссылка.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Reference', tmp,
	29, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Размещенный символ.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Cell', tmp,
	30, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Надпись.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Text', tmp,
	31, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Линия.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Line', tmp,
	32, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Узел.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Node', tmp,
	33, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Графический объект.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'GraphicObject', tmp,
	34, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 37.'
	||'Участвует в таблице DSPORDER в поле PAIRVAL.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown37', tmp,
	37, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Цепь.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Net', tmp,
	38, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Сегмент.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'NetSegment', tmp,
	39, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 46.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown46', tmp,
	46, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Связка.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Bundle', tmp,
	50, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Компонент типа "Кабель" или "Марка провода"'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'CableType', tmp,
	51, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Компонент типа провод с "Марки провода"'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'CoreType', tmp,
	52, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'outline of a phys. component';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Outline', tmp,
	60, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 61.'
	||'Участвует в таблице POSITION в поле POSID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown61', tmp,
	61, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Группа.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Group', tmp,
	110, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Внешний документ.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'ExternalDocument', tmp,
	142, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Соединение.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Connection', tmp,
	143, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Размер.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Dimension', tmp,
	151, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Варианты/Опции.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'OptionOrVariant', tmp,
	154, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'PanelPath - читается EcubeNetSegment.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'PanelPath', tmp,
	156, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Внутренний идектификатор матрицы трансформации объекта.'
	||'Участвует в таблице TRAFORMS в поле ID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'TRAFORMS', tmp,
	171, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Структурный узел.';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'StructureNode', tmp,
	180, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 193.'
	||'Участвует в таблице PAIRS в поле ID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown193', tmp,
	193, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--
tmp:= 'Неизвестный номер 201.'
	||'Похоже на внутренний системный идентификатор провода.'
	||'Участвует в таблице CBNETSEG в поле CABWIRID.'
	||'Выявлено новое значение';
Insert Into SP.ENUM_VAL_S
	Values (i, null, SP.G.TE3Type, 'Unknown201', tmp,
	201, null, null, null, null,
	G.OTHER_GROUP, to_date('11-01-2017','dd-mm-yyyy'), 'SP');
i:=i+1;
--

-- TextAlignments
--------------------------------------------------------------------------------
tmp:='Undefined';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'Undefined', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Left';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'Left', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Center';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'Center', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Right';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'Right', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='LeftAndRotated';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'LeftAndRotated', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='CenterAndRotated';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'CenterAndRotated', tmp,
	5, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='RightAndRotated';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'RightAndRotated', tmp,
	6, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='LeftAndMirrored';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'LeftAndMirrored', tmp,
	7, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='CenterAndMirrored';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'CenterAndMirrored', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='RightAndMirrored';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextAlignments,'RightAndMirrored', tmp,
	9, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- TextBalloonings
--------------------------------------------------------------------------------
tmp:='Без контура и линии выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'None', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Окружность';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'Circle', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Овал';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'Oval', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Прямоугольник';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'Rectangle', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Эллипс';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'Ellipse', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Линия выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'LineToOwner', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Окружность и линия выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'CircleAndLine', tmp,
	17, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Овал и линия выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'OvalAndLine', tmp,
	18, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Прямоугольник и линия выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'RectangleAndLine', tmp,
	20, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Эллипс и линия выноски';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextBalloonings,'EllipseAndLine', tmp,
	24, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- TextModes
--------------------------------------------------------------------------------
tmp:='Неопределенный';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextModes,'Unknown', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Нормальный';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextModes,'Normal', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Узкий';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextModes,'Narrow', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Широкий';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextModes,'Wide', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- TextStyles
--------------------------------------------------------------------------------
tmp:='None';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'None', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Bold';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'Bold', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Italic';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'Italic', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Underline';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'Underline', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Strikeout';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'Strikeout', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Opaque';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TTextStyles,'Opaque', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('27-02-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--
-- PinPhysicalConnectionDirection
--------------------------------------------------------------------------------
tmp:='AllDirections';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'AllDirections', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Right';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Right', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Top';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Top', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Left';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Left', tmp,
	5, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Bottom';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Bottom', tmp,
	7, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Vertical';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Vertical', tmp,
	9, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Horizontal';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Horizontal', tmp,
	10, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Automatic';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinPhyslConnDirection,'Automatic', tmp,
	14, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- PinTypeId
--------------------------------------------------------------------------------
tmp:='Undefined';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'Undefined', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='DevicePin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'DevicePin', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='ConnectorPin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'ConnectorPin', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='BlockConnectorPin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'BlockConnectorPin', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='ComponentPin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'ComponentPin', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='NormalNode';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'NormalNode', tmp,
	5, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='ConnectorSymbolPin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'ConnectorSymbolPin', tmp,
	6, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='NetNode';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'NetNode', tmp,
	7, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='WireCountNode';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'WireCountNode', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='TemplateSymbolPin';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'TemplateSymbolPin', tmp,
	9, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='SheetReferenceNode';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'SheetReferenceNode', tmp,
	10, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='SignalCarryingNode';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'SignalCarryingNode', tmp,
	11, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='CabWir';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'CabWir', tmp,
	12, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Hose';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'Hose', tmp,
	13, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Tube';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'Tube', tmp,
	14, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='WireChange';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'WireChange', tmp,
	15, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='HoseChange';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'HoseChange', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='TubeChange';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3PinTypeId,'TubeChange', tmp,
	17, null, null, null, null,
	G.OTHER_GROUP, to_date('10-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- AttributeOwner2
--------------------------------------------------------------------------------
tmp:='None';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'None', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Модуль';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'Module', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Раздел структурного дерева';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'StructureNode', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Рукав/Труба';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTube', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Конец Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeEnd', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeType', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип конца Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeTypeEnd', tmp,
	32, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Внутреннее покрытие Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeInside', tmp,
	64, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Конец внутреннего покрытия Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeInsideEnd', tmp,
	128, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип внутреннего покрытия Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeInsideType', tmp,
	256, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип конца внутреннего покрытия Рукава/Трубы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'HoseTubeInsideTypeEnd', tmp,
	512, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Группа';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'Group', tmp,
	1024, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Объект функциональной схемы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'FunctionalUnit', tmp,
	2048, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Класс цепей';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'SignalClass', tmp,
	4096, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Варианты/Опции';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'VariantsOptions', tmp,
	8192, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Размер';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'Dimension', tmp,
	16384, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Графика';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'Graph', tmp,
	32768, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Надпись';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'Text', tmp,
	65536, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Узел цепи';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'NetNode', tmp,
	131072, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Порт на функциональной схеме';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner2,'FunctionalPort', tmp,
	262144, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- AttributeOwner
--------------------------------------------------------------------------------
tmp:='Ничто';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'None', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Символ';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Symbol', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Кабель';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Cable', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Жила кабеля';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CableCore', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Адресный конец кабеля';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CableEnd', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Адресный конец жилы кабеля';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CableCoreEnd', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Изделие в БД';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Component', tmp,
	32, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Вывод изделия в БД';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'ComponentPin', tmp,
	64, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Соединитель';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Connector', tmp,
	128, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Вывод соединителя';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'ConnectorPin', tmp,
	256, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Блочный соединитель';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'BlockConnector', tmp,
	512, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Вывод блока';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'BlockPin', tmp,
	1024, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Изделие в проекте';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Device', tmp,
	2048, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Вывод изделия в проекте';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'DevicePin', tmp,
	4096, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Имя цепи';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Signal', tmp,
	8192, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Проект';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Project', tmp,
	16384, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Блок как изделие';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'BlockDevice', tmp,
	65536, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип кабеля';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CableType', tmp,
	131072, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип жилы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CoreType', tmp,
	262144, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип адресного конца кабеля';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CableTypeEnd', tmp,
	524288, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Тип адресного конца жилы';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'CoreTypeEnd', tmp,
	1048576, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Связка';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Bundle', tmp,
	2097152, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Символ в Базе Данных';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'DatabaseSymbol', tmp,
	4194304, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Цепь';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Net', tmp,
	8388608, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Участок цепи';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'NetSegment', tmp,
	16777216, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Лист';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Sheet', tmp,
	33554432, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Лист (База Данных)';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'SheetDatabase', tmp,
	268435456, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Модель';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'Model', tmp,
	536870912, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Символ области';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3AttributeOwner,'FieldSymbol', tmp,
	-2147483648, null, null, null, null,
	G.OTHER_GROUP, to_date('13-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

-- SymbolCodes
--------------------------------------------------------------------------------
tmp:='Undefined';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Undefined', tmp,
	0, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Sheet';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Sheet', tmp,
	1, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Normal';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Normal', tmp,
	2, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Signal';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Signal', tmp,
	3, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Reference4';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Reference4', tmp,
	4, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Reference';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Reference', tmp,
	5, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Master';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Master', tmp,
	6, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Block';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Block', tmp,
	8, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='ConnectorBlock';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'ConnectorBlock', tmp,
	9, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Connector';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Connector', tmp,
	10, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Connector11';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Connector11', tmp,
	11, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Field';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Field', tmp,
	13, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Dynamic';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Dynamic', tmp,
	14, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Asic';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Asic', tmp,
	15, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='FormboardTable';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'FormboardTable', tmp,
	16, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='ContactArrangement';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'ContactArrangement', tmp,
	17, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='HierarchicalBlock';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'HierarchicalBlock', tmp,
	38, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='PortOnHierarchicalBlock';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'PortOnHierarchicalBlock', tmp,
	39, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='PortOnHierarchicalSheet';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'PortOnHierarchicalSheet', tmp,
	40, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='TerminalRow';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'TerminalRow', tmp,
	50, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Mount';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Mount', tmp,
	60, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='Panel';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'Panel', tmp,
	61, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='CableDuct';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'CableDuct', tmp,
	62, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='TemplateForPins';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'TemplateForPins', tmp,
	100, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='TemplateForTexts';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'TemplateForTexts', tmp,
	101, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='AttributeTemplate';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'AttributeTemplate', tmp,
	102, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='PinTemplate';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'PinTemplate', tmp,
	103, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--

tmp:='PadTemplate';
Insert Into SP.ENUM_VAL_S
	Values (i, null,SP.G.TE3SymbolCodes,'PadTemplate', tmp,
	104, null, null, null, null,
	G.OTHER_GROUP, to_date('16-03-2017','dd-mm-yyyy'),'SP');
i:=i+1;
--
-- ClientCommand.
-------------------------------------------------------------------------------
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'printLog', 'Команда выводит накопившийся лог в окно протокола. Можно использовать при дливельном выполнении команд на стороне сервера алгоритмов.',
    0,null,null,null,null,
    G.OTHER_GROUP, to_date('19.11.2020','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'Repot', 'Запуск KOCEL_REPORT из программы клиента и выполнение отчёта.',
    1,null,null,null,null,
    G.OTHER_GROUP, to_date('19.11.2020','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'KOCEL2Word', 'Выгрузка данных из схемы KOCEL по шаблону в файл MS_Word.',
    2,null,null,null,null,
    G.OTHER_GROUP, to_date('19.11.2020','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'KOCEL2Access', 'Выгрузка данных из схемы KOCEL в таблицы Access',
    3,null,null,null,null,
    G.OTHER_GROUP, to_date('19.11.2020','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'Access2KOCEL', 'Загрузка данных из Access в KOCEL.',
    4,null,null,null,null,
    G.OTHER_GROUP, to_date('19.11.2020','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'getCatalog', 'Загрузка данных о файлах каталога в массив SYSTEMS.',
    5,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'FileUpload', 'Загрузка файла с именем в параметре fileName на сервер и запись ссылки на него в параметр fileRef.',
    6,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'FileDownload', 'Выгрузка файла, определяемого ссылкой на него в параметре fileRef под именем, определённом параметром fileName.',
    7,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'TextUpload', 'Загрузка текстового файла с именем в параметре fileName на сервер и запись ссылки на него в параметр fileRef.',
    8,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'TextDownload', 'Выгрузка текстового файла, определяемого ссылкой на него в параметре fileRef под именем, определённом параметром fileName.',
    9,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'DeleteFile', 'Удаление файла или каталога, определённом параметром fileName.',
    10,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'ChangeFile', 'Изменение имени или свойств файла или каталога, определённом параметром fileName.',
    11,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'MakeDirectory', 'Создание каталога, определённом параметром fileName.',
    12,null,null,null,null,
    G.OTHER_GROUP, to_date('07.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'getFileName', 'Запрос имени файла, существующего на клиенте, у пользователя. При получении команды, клиент инициирует диалог открытия файла. Результат возвращается в параметре fileName.',
    13,null,null,null,null,
    G.OTHER_GROUP, to_date('29.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'isFileExist', 'Проверка, что файл, определённый параметром fileName, существует.',
    14,null,null,null,null,
    G.OTHER_GROUP, to_date('29.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TClientCommand,'SysData', 'Получение системной информации - имя рабочей станции.',
    15,null,null,null,null,
    G.OTHER_GROUP, to_date('29.03.2021','dd-mm-yyyy'), 'SP');
i:=i+1;  
--

-- TFileType
-------------------------------------------------------------------------------
tmp:='Значение не определено.';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'notDef',tmp,0,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--  
tmp:='pdf';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'pdf',tmp,1,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
 
--  
tmp:='Excel';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'xls',tmp,2,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Excel';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'xlsx',tmp,3,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--  
tmp:='Autodesk';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'dwg',tmp,4,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Bentley';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'dgn',tmp,5,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Revit';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'rvt',tmp,6,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;
--  
tmp:='Excel with macros';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'xlsm',tmp,7,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Word';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'doc',tmp,8,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Word';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'docx',tmp,9,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='IFC';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'ifc',tmp,10,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='PNG';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'PNG',tmp,11,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Text';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'txt',tmp,12,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='Jpeg';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'jpg',tmp,13,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

--  
tmp:='zip Файл архива';
insert into SP.ENUM_VAL_S 
  VALUES (i,null,SP.G.TFileType,'zip',tmp,14,null,null,null,null,
          G.OTHER_GROUP, to_date('05-01-2014','dd-mm-yyyy'), 'SP');
i:=i+1;

commit;
end;
/

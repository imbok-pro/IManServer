CREATE OR REPLACE TYPE SP.CS_CYLINDR AS OBJECT 
/* SP-CS_CYLINDR.tps
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-02-12 
-- update 2018-02-13
*/
( 
    /*Ноль локальной системы координат*/
    P0 SP.TVALUE,
    /*
    вариант состемы коордниат
    "LEFT" - луч особенностей слева от нуля, угол изменияется минус пи до пи
    "RIGHT" - луч особенностей справа от нуля, угол изменияется 0 до двух пи
    */
    CS_variant CHAR(5),
    /*Создает систему координат, в которой дуга от левой точки до правой
    не пересекает луч особенностей цилиндрической стстемы координат,
    при условии, что дуга имеет угол раствора меньше 180 градусов.
    Polus   точка в 3D декартовой системе координат (тип SP.G.TXYZ),
            координаты полюса полярной системы координат
    PLeft   точка в 3D декартовой системе координат (тип SP.G.TXYZ),
            координаты точки левого луча угла
    PRight  точка в 3D декартовой системе координат (тип SP.G.TXYZ),
            координаты точки правого луча угла
    */
    CONSTRUCTOR Function CS_CYLINDR
    (Polus In SP.TVALUE, PLeft SP.TVALUE, PRight SP.TVALUE) 
    Return SELF as Result,
  
    /*Присвоение системы координат.*/
    Member Procedure Assign
    (Self In Out NoCopy CS_CYLINDR, P0$ In SP.TVALUE, cs_variant In CHAR),
    
    /*
    Конвертирование координат из локальной системы в декартову
    ptIn$ SP.G.TCylindr
    ptOut$ SP.G.TXYZ  должна быть определена и ее тип должен быть задан
    */
    Member Procedure ToDesc(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE),
    
    /*
    Конвертирование координат из декартовой системы в локальную
    ptIn$ SP.G.TXYZ
    ptOut$ SP.G.TCylindr  должна быть определена и ее тип должен быть задан
    */
    Member Procedure FromDesc(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE),

    /*
    Поворачивает точку ptToMove$ на угол Angle$
    ptToRotate$ SP.G.TXYZ или SP.G.TCylindr
    Angle$ угол поворота
    */
    Member Procedure Rotate(Self In Out NoCopy CS_CYLINDR
    ,ptToRotate$ In Out Nocopy SP.TVALUE, Angle$ In Number),

    /*
    Возвращает угол для точки ptIn$ в локальной системе координат
    ptIn$ доожна быть SP.G.TXYZ 
    */
    Member Function GetAngle(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE) return Number,
    
    /*Функция ATAN2(dy,dx) соотвествующий варианту системы координат*/
    Member Function Arctg2(Self In Out NoCopy CS_CYLINDR
    ,dy$ in Number, dx$ in Number) return Number,
    
    /*Арктангенс от минус пи до пи.*/
    Static Function ArctgLeft(dy In Number, dx In Number) Return Number,
    
    /*Арктангенс от нуля до двух пи*/
    Static Function ArctgRight(dy In Number, dx In Number) Return Number
);


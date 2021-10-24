create or replace TYPE BODY SP.CS_CYLINDR AS
-- SP-CS_CYLINDR.tpb
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-02-12 
-- update 2018-02-13
-------------------------------------------------------------------------------
  
  --TODO заменить выбор системы координат с первой подход€щей на оптимальную
  --в смысле наиболее далеко расположенную от луча особенностей.
  CONSTRUCTOR Function CS_CYLINDR
  (Polus In SP.TVALUE, PLeft SP.TVALUE, PRight SP.TVALUE) 
  Return SELF as Result
  Is
    ph1 Number;
    ph2 Number;
  Begin
    ph1:=CS_CYLINDR.ArctgLeft(PLeft.Y-Polus.Y,PLeft.X-Polus.X);
    ph2:=CS_CYLINDR.ArctgLeft(PRight.Y-Polus.Y,PRight.X-Polus.X);
    If ph1>ph2 Then
        Assign(P0$ => Polus, cs_variant => 'LEFT');
        Return;
    End if;
    ph1:=CS_CYLINDR.ArctgRight(PLeft.Y-Polus.Y,PLeft.X-Polus.X);
    ph2:=CS_CYLINDR.ArctgRight(PRight.Y-Polus.Y,PRight.X-Polus.X);
    If ph1>ph2 Then
        Assign(P0$ => Polus, cs_variant => 'RIGHT');
        Return;
    End if;
	raise_application_error(-20033,'–аствор угла превышает 180 градусов!');
    Return;
  End CS_CYLINDR;
  
  Member Procedure Assign
    (Self In Out NoCopy CS_CYLINDR, P0$ In SP.TVALUE, cs_variant In CHAR)
  AS
  BEGIN
    If P0$.T!=SP.G.TXYZ Then
      raise_application_error(-20033,
      '“очка начала системы координат должна быть задана в '
      ||'3D ƒекартовой системе координат.');
    End If;
  
    SELF.P0:=P0$;
    SELF.CS_variant:=UPPER(cs_variant);
  END Assign;

  Member Procedure ToDesc(Self In Out NoCopy CS_CYLINDR
  ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE)
  As
  BEGIN
    If ptIn$.T!=SP.G.TCylindr Then
      raise_application_error(-20033,
      '¬ходна€ точка ptIn должна быть задана в цилиндрической системе координат.');
    End If;

    If ptOut$.T!=SP.G.TXYZ Then
      raise_application_error(-20033,
      '¬ыходна€ точка ptOut должна быть задана в 3D ƒекартовой системе координат.');
    End If;

    ptOut$.X:=Self.P0.X+ptIn$.X*cos(ptIn$.Y);
    ptOut$.Y:=Self.P0.Y+ptIn$.X*sin(ptIn$.Y);
    ptOut$.N:=Self.P0.N+ptIn$.N;
  END ToDesc;

  Member Procedure FromDesc(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE)
    As
    dx Number;
    dy number;
  BEGIN

    If ptIn$.T!=SP.G.TXYZ Then
      raise_application_error(-20033,
      '¬ходна€ точка ptOut должна быть задана в 3D ƒекартовой системе координат.');
    End If;

    If ptOut$.T!=SP.G.TCylindr Then
      raise_application_error(-20033,
      '¬ыходна€ точка ptIn должна быть задана в цилиндрической системе координат.');
    End If;

    dx:=ptIn$.X-SELF.P0.X;
    dy:=ptIn$.Y-SELF.P0.Y;
     ptOut$.X:=SQRT(Power(dx,2)+Power(dy,2));
     ptOut$.Y:=Arctg2(dy, dx);
     ptOut$.N:=ptIn$.N-SELF.P0.N;
  END FromDesc;

    /*
    ѕоворачивает точку ptToMove$ на угол Angle$
    ptToRotate$ SP.G.TXYZ или SP.G.TCylindr
    Angle$ угол поворота
    */
    Member Procedure Rotate(Self In Out NoCopy CS_CYLINDR
    ,ptToRotate$ In Out Nocopy SP.TVALUE, Angle$ In Number)
    As
     v SP.TVALUE;
    Begin
        If ptToRotate$.T!=SP.G.TXYZ And ptToRotate$.T!=SP.G.TCylindr Then
          raise_application_error(-20033,
          '¬ходна€ точка ptOut должна быть задана в 3D ƒекартовой'
          ||' или цилиндрической системе координат.');
        End If;
    
        If ptToRotate$.T=SP.G.TCylindr Then
           ptToRotate$.Y:=ptToRotate$.Y+Angle$;
           Return;
        End If;
        
        v:=SP.TVALUE(SP.G.TCylindr);
        Self.FromDesc(ptToRotate$,v);
        v.Y:=v.Y+Angle$;
        Self.ToDesc(v,ptToRotate$);
    End;

  /*
  ¬озвращает угол дл€ точки ptIn$ в локальной системе координат
  ptIn$ доожна быть SP.G.TXYZ 
  */
  Member Function GetAngle(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE) return Number
    Is
  Begin
    If ptIn$.T!=SP.G.TXYZ Then
      raise_application_error(-20033,
      '¬ходна€ точка ptOut должна быть задана в 3D ƒекартовой системе координат.');
    End If;
    return Self.Arctg2(ptIn$.Y-Self.P0.Y,ptIn$.X-Self.P0.X);
  End;

  Member Function Arctg2(Self In Out NoCopy CS_CYLINDR
  , dy$ in Number, dx$ in Number) return Number
  Is
  Begin
    Case 
     When SELF.CS_variant='LEFT' then                  
      return CS_CYLINDR.ArctgLeft(dy$,dx$);
     When SELF.CS_variant='RIGHT' then  
      return CS_CYLINDR.ArctgRight(dy$,dx$);      
     Else             
      raise_application_error(-20033,
      'Ќепредусмотренное значение ['||CS_variant
      ||'] варианта цилиндрической системы координат.'
      || ' ƒопустимые значени€ суть LEFT и RIGHT.');
      return null;
    End Case;    
  End;
  
  Static Function ArctgLeft(dy In Number, dx In Number) Return Number
  Is
  Begin
    Return ATAN2(dy,dx);
  End;
  
  Static Function ArctgRight(dy In Number, dx In Number) Return Number
  Is
  Begin
    return ArctgLeft(-dy,-dx)+G.PI;
  End;
  
END;
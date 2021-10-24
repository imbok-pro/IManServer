CREATE OR REPLACE PACKAGE BODY SP.VEC#SEGMENT
-- VEC#SEGMENT ������ � ��������� � ������������
-- ����� VEC#SEGMENT ������� �� ������ SP.VEC
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-06-27
-- update 2019-06-27:2019-07-05
AS
--��������� ��������� ��������� ������
Eps0$$ Number;  --���������� ����������� ��������� �� ����� ����������
ZeroVectorEps$$ Number;
ZeroVectorEps2$$ Number;  --������� ZeroVectorEps$$
ParallelEps$$  Number;


--�������� ����� ������ A, B, C, D
PA$$ SP.VEC.AA_Vector;
PB$$ SP.VEC.AA_Vector;
PC$$ SP.VEC.AA_Vector;
PD$$ SP.VEC.AA_Vector;

--����������� ����� ������ a,b,c
va$$ SP.VEC.AA_Vector;
--������������� ������ va$$
va_n$$ SP.VEC.AA_Vector;
vb$$ SP.VEC.AA_Vector;
vc$$ SP.VEC.AA_Vector;

--��������� ��������
dp_aa$$ Number;   --<va$$,va$$>
dp_bb$$ Number;   --<vb$$,vb$$>

--��������� �� ������
em$$ Varchar2(4000);
--==============================================================================
--����� �������� ��������� ��������, ����������� ��� ������� �����������
--Eps0$ - ���������� ����������� ��������� �������� ���������� � ��
--  ��� �� - ���. ����������� ��������� ��������� �������
--
--������� ����������� ���� �����
--������ ������� ����� ���������� ������ �������
--ParallelEps$ ��� ��������� ������� ��������� ���������������, ���� ���������� 
--����� ���� �� ����������� ParallelEps$ 
Procedure SetEps(
Eps0$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
)
As
Begin
  Eps0$$:=Eps0$;
  ParallelEps$$:=ParallelEps$;
End;
--==============================================================================
--����� ����� ������� [AB]
Procedure SetAB(AX$ In Number, AY$ In Number, AZ$ In Number
,BX$ In Number, BY$ In Number, BZ$ In Number)
As
Begin
  SetAB(SP.VEC.CreateV3(AX$, AY$, AZ$),SP.VEC.CreateV3(BX$, BY$, BZ$));
End;
--==============================================================================
--����� ����� ������� [CD]
Procedure SetCD(CX$ In Number, CY$ In Number, CZ$ In Number
,DX$ In Number, DY$ In Number, DZ$ In Number)
As
Begin
  SetCD(SP.VEC.CreateV3(CX$, CY$, CZ$),SP.VEC.CreateV3(DX$, DY$, DZ$));
End;
--==============================================================================
--����� ����� ������� [AB]
Procedure SetAB(A$ In SP.VEC.AA_Vector, B$ In SP.VEC.AA_Vector)
As
Begin
  ZeroVectorEps2$$:=4*A$.Count*Eps0$$*Eps0$$;
  ZeroVectorEps$$:=SQRT(ZeroVectorEps2$$);
  PA$$:=A$;
  PB$$:=B$;
  va$$:=SP.VEC.Substract(PA$$,PB$$);
  If SP.VEC.Normalize(va$$, ZeroVectorEps$$, va_n$$) Then 
    dp_aa$$:= SP.VEC.GetLastNorma2_2;
  Else 
    em$$:='������� [AB] ����������� A('||SP.VEC.to_str(PA$$)||'), B('
    ||SP.VEC.to_str(PB$$)||').';
    D(em$$, 'ERROR In SP.VEC#SEGMENT.SetAB');
    raise_application_error(-20033, em$$);
  End If;

End SetAB;

--==============================================================================
--����� ����� ������� [CD]
Procedure SetCD(C$ In SP.VEC.AA_Vector, D$ In SP.VEC.AA_Vector)
As
Begin
  PC$$:=C$;
  PD$$:=D$;
  vb$$:=SP.VEC.Substract(PD$$,PC$$);  
  dp_bb$$:= SP.VEC.Dotproduct(vb$$,vb$$);
  If dp_bb$$< ZeroVectorEps2$$ Then
    em$$:='������� [CD] ����������� �('||SP.VEC.to_str(PC$$)||'), D('
    ||SP.VEC.to_str(PD$$)||').';
    D(em$$, 'ERROR In SP.VEC#SEGMENT.SetCD');
    raise_application_error(-20033, em$$);
  End If;

End SetCD;
--==============================================================================
--���������� ����� ����������� �������� [AB] � [CD], ���� ����
Procedure CalcSegmentIntersection
Is
--�������
  dp_ab# Number;  --<va#,vb#>
  dp_ac# Number;  --<va#,vc#>
  dp_bc# Number;  --<vb#,vc#>
  dp_cc# Number;
--������������ ��� ������� �������  
  dd# Number;
  dp# Number;
  dq# Number;
-- p, q
  p# Number;
  q# Number;
  dist# Number;
--�����  
  n_a# Number;
  n_b# Number;
  n_c# Number;

  vBC# SP.VEC.AA_Vector;
  vBD# SP.VEC.AA_Vector;

  coordC# Number;
  coordD# Number;

Begin
  Intersected11:=null;
  PT.Delete;
  PS.Delete;
  vc$$:=SP.VEC.Substract(PB$$,PD$$);

  dp_ab#:= SP.VEC.Dotproduct(va$$,vb$$);
  dp_ac#:= SP.VEC.Dotproduct(va$$,vc$$);
  dp_bc#:=SP.VEC.Dotproduct(vb$$,vc$$);
  n_a#:=SQRT(dp_aa$$);
  n_b#:=SQRT(dp_bb$$);
    
  
  If ABS( 1.0-ABS( dp_ab#/(n_a#*n_b#) ) ) 
        > ParallelEps$$*ParallelEps$$*0.5    Then
    -- ������� �������� ��������� ����������� 
    -- �.�. �������� va$$ � vb$$ ��������������)

    dd#:=dp_aa$$*dp_bb$$-dp_ab#*dp_ab#;

    dp#:=dp_ab#*dp_bc# - dp_ac#*dp_bb$$;
    dq#:=dp_ab#*dp_ac# - dp_aa$$*dp_bc#;
    p#:=dp#/dd#;
    q#:=dq#/dd#;
    
--      DBMS_OUTPUT.put_line
--      ('DEBUG case '||CaseNum||': , p# = '||to_char(p#)||',q# = '
--      ||to_char(q#)||', dd = '||dd#||', dp = '||dp#||', dq = '||dq#||'.');   
  
    If p#<0.0 Then
      p#:=0.0;
    ElsIf p#>1.0 Then
      p#:=1.0;
    ElsIf p#*n_a#<ZeroVectorEps$$ Then 
      p#:=0.0;
    ElsIf (1.0-p#)*n_a#<ZeroVectorEps$$ Then 
      p#:=1.0;
    End If;
    
    If q#<0.0 Then
      q#:=0.0;
    ElsIf q#>1.0 Then
      q#:=1.0;
    ElsIf q#*n_b#<ZeroVectorEps$$ Then 
      q#:=0.0;
    ElsIf (1.0-q#)*n_b#<ZeroVectorEps$$ Then 
      q#:=1.0;
    End If;

    If p#<=0.0 Then 
      p#:=0.0;
      PT:=PB$$;
      If q#<=0.0 Then 
        q#:=0.0;
        CaseNum:=1;
        PS:=PD$$;
      ElsIf q#>=1.0 Then
        q#:=1.0;
        CaseNum:=2;
        PS:=PC$$;
      Else
        CaseNum:=3;
        PS:= SP.VEC.Middle(m$=> q#, v1$ => PC$$, v2$ =>PD$$);        

      End If;
    ElsIf p#>=1.0 Then
      p#:=1.0;
      PT:=PA$$;
      If q#<=0.0 Then 
        q#:=0.0;
        CaseNum:=4;
        PS:=PD$$;
      ElsIf q#>=1.0 Then
        q#:=1.0;
        CaseNum:=5;
        PS:=PC$$;
      Else
        CaseNum:=6;
        PS:= SP.VEC.Middle(m$=> q#, v1$ => PC$$, v2$ =>PD$$);
      End If;
    Else
      PT:= SP.VEC.Middle(m$=> p#, v1$ => PA$$, v2$ =>PB$$);
      If q#<=0.0 Then 
        q#:=0.0;
        PS:=PD$$;
        CaseNum:=7;
      ElsIf q#>=1.0 Then
        q#:=1.0;
        PS:=PC$$;
        CaseNum:=8;
      Else
        CaseNum:=9;
        PS:= SP.VEC.Middle(m$=> q#, v1$ => PC$$, v2$ =>PD$$); 
      End If;
    End If;
  
    SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PT,PS));
--    If SegmentDist Is Null Or dist#<SegmentDist Then
--      SegmentDist:=dist#;
--    End If;
--      DBMS_OUTPUT.put_line
--      ('DEBUG case '||CaseNum||': Dist = '||SegmentDist||', Intersect '
--      ||SP.TO_.STR(Intersected)||', p# = '||to_char(p#)||',q# = '
--      ||to_char(q#)||', dd = '||dd#||', ZeroVectorEps$$ = '||ZeroVectorEps$$||'.');   
--  
--    
    
    Return ;
  End If;
  --������� �������� ��������� ��������� (�������� va$$ � vb$$ ����������)
  CaseNum:=-1;--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  vBC#:=SP.VEC.Substract(PC$$,PB$$);
  coordC#:=SP.VEC.Dotproduct(va_n$$,vBC#);
  vBD#:=SP.VEC.Substract(PD$$,PB$$);
  coordD#:=SP.VEC.Dotproduct(va_n$$,vBD#);
  
--      DBMS_OUTPUT.put_line
--      ('DEBUG case '||CaseNum||': , CoordC# = '||to_char(CoordC#)||',CoordD# = '
--      ||to_char(CoordD#)||', n_a# = '||n_a#||'.');   
  
  If coordC#<coordD# Then
    If coordD# < ZeroVectorEps$$ Then
      --D ��������� � B
      CaseNum:=1;
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PD$$,PB$$));
    ElsIf coordC# > n_a# - ZeroVectorEps$$ Then
      --C ��������� � A
      CaseNum:=5;
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PA$$,PC$$));
    ElsIf CoordC# < ZeroVectorEps$$ Then
      CaseNum:=3;
      PT:=PB$$;
      q#:=-dp_bc#/dp_bb$$;
      PS:= SP.VEC.Middle(m$=> q#, v1$ => PC$$, v2$ =>PD$$); 
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PB$$,PS));
    Else 
      CaseNum:=8;
      p#:=-(dp_ab#+dp_ac#)/dp_aa$$;
      PT:= SP.VEC.Middle(m$=> p#, v1$ => PA$$, v2$ =>PB$$); 
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PC$$,PT));
    End If;
  Else -- coordD# < coordC# :::::::::::::::::::::::::
    If coordC# < ZeroVectorEps$$ Then
      --C ��������� � B
      CaseNum:=2;
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PC$$,PB$$));
    ElsIf coordD# > n_a# - ZeroVectorEps$$ Then
      --D ��������� � A
      CaseNum:=4;
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PA$$,PD$$));
    ElsIf CoordD# < ZeroVectorEps$$ Then
      CaseNum:=3;
      PT:=PB$$;
      q#:=-dp_bc#/dp_bb$$;
      PS:= SP.VEC.Middle(m$=> q#, v1$ => PC$$, v2$ =>PD$$); 
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PB$$,PS));
    Else 
      CaseNum:=7;
      p#:=-dp_ac#/dp_aa$$;

      PT:= SP.VEC.Middle(m$=> p#, v1$ => PA$$, v2$ =>PB$$); 
      SegmentDist:=Sqrt(SP.VEC.Dist_2_2(PD$$,PT));
    End If;
  End If;
End CalcSegmentIntersection;
--==============================================================================
-- ���������� ������, ���� ������� [AB] � [CD] ������������ � ���������� 
-- ������������ ZeroVectorEps$$
Function Intersected Return Boolean
Is
Begin
  Return (SegmentDist<=ZeroVectorEps$$);
End;
--==============================================================================
--���������� ������, ���� ������� [AB] ������ �� ����� 
Function Is_AB_Fragmented Return Boolean
Is
Begin
  Return (CaseNum >= 7) ;
End;
--==============================================================================
--���������� ������, ���� ������� [CD] ������ �� ����� 
Function Is_CD_Fragmented Return Boolean
Is
Begin
  Return (CaseNum In (3,6,9));
End;

--==============================================================================
--���������� ���������� ������� [AB] 
Function OrientationAB Return BINARY_INTEGER
Is
Begin
  If 1<= CaseNum And CaseNum <= 3 Then
    Return 1;
  End If;
  If 4<= CaseNum And CaseNum <= 6 Then
    Return -1;
  End If;
  Return 0;
End;
--==============================================================================
--���������� ���������� ������� [CD] 
Function OrientationCD Return BINARY_INTEGER
Is
Begin
  If CaseNum In (1,4,7) Then
    Return -1;
  End If;
  If CaseNum In (2,5,8) Then
    Return 1;
  End If;
  Return 0;
End;

END VEC#SEGMENT;


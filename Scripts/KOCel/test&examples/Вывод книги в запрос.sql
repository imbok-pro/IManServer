select A,B,C from table (KOCEL.CELL.VALs_as_str('���� ������������ � ����', '����� ������������ � ����'))

select c.A.S from table(KOCEL.CELL.VALs('���� ������������ � ����', '����� ������������ � ����')) c

select c.A.as_Str() from table(KOCEL.CELL.VALs('���� ������������ � ����', '����� ������������ � ����')) c

select A from table (KOCEL.CELL.VALs('���� ������������ � ����', '����� ������������ � ����'))
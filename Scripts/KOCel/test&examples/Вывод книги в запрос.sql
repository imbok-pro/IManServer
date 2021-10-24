select A,B,C from table (KOCEL.CELL.VALs_as_str('Лист Пользователи и роли', 'Отчет Пользователи и роли'))

select c.A.S from table(KOCEL.CELL.VALs('Лист Пользователи и роли', 'Отчет Пользователи и роли')) c

select c.A.as_Str() from table(KOCEL.CELL.VALs('Лист Пользователи и роли', 'Отчет Пользователи и роли')) c

select A from table (KOCEL.CELL.VALs('Лист Пользователи и роли', 'Отчет Пользователи и роли'))
begin
  kocel.book.PrepareData('Q');
end;


select cast(c+0.5 as integer) from KOCEL.V_BOOK_CELLS
select cast(to_.str(c+0.5) as integer) from KOCEL.V_BOOK_CELLS
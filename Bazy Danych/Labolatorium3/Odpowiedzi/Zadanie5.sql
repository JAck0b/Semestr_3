#Zadanie5

delimiter $$
create procedure funkcje_agregujące(in agg varchar(30), in kol varchar(30))
begin
  if agg in ('count', 'min', 'avg', 'max') and kol in ('PESEL', 'imie', 'nazwisko', 'data_urodzenia', 'wzrost', 'waga', 'rozmiar_buta', 'ulubiony_kolor') then
     set @comenda = concat('select ', '\'', kol, '\', \'', agg, '\', ', agg, '(', kol, ')', ' from ', 'ludzie');
    prepare statement from @comenda;
    execute statement;
    deallocate prepare statement;
  else
    signal sqlstate '50000' set MESSAGE_TEXT = 'Zła funkcja agregująca lub kolumna.';
  end if ;
end $$
delimiter ;

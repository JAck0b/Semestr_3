#Zadanie7

delimiter $$
create procedure prywatnosc_roznicowa(in kol varchar(15), in zaw varchar(50))
begin
  declare delta double;
  declare epsilon double default 0.5;
  declare szukane varchar(30);
  declare b double;
  if kol not in ('wzrost', 'waga', 'pensja') then
    signal sqlstate '19283' set message_text = 'Nieprawidłowa kolumna';
  end if ;
  if zaw not in ('aktor', 'agent', 'informatyk', 'reporter', 'sprzedawca') then
    signal sqlstate '19382' set message_text = 'Nieprawidłowy zawód';
  end if ;

  set @ma = 0;
  set @mi = 0;
  set @tmp = concat('select max(', kol,' ) from pracownicy join ludzie l on pracownicy.PESEL = l.PESEL where zawod like \'', zaw, '\' into @ma');

  prepare stat1 from @tmp;
  execute stat1;
  deallocate prepare stat1;

  set @tmp = concat('select min(', kol,' ) from pracownicy join ludzie l on pracownicy.PESEL = l.PESEL where zawod like \'', zaw, '\' into @mi');

  prepare stat2 from @tmp;
  execute stat2;
  deallocate prepare stat2;

  set delta = @ma - @mi;
  set b = delta/epsilon;
  select b;

  if b <> 0 then
    set @tmp = concat('select sum(', kol,') from pracownicy join ludzie l3 on pracownicy.PESEL = l3.PESEL where zawod like \'', zaw, '\' into @ma');
    prepare stat3 from @tmp;
    execute stat3;
    deallocate prepare stat3;

    set szukane = cast((1/(2*b))*exp(-(@ma)/b) as char(30));
  else
    set szukane = '0';
  end if ;

  set @q = concat('select \'', kol, '\', \'', zaw, '\', \'', szukane, '\', sum(', kol, '), sum(', kol, ') + ', szukane,' from pracownicy join ludzie on pracownicy.PESEL = ludzie.PESEL where zawod like \'', zaw, '\';');

  prepare statement from @q;
  execute statement;

  deallocate prepare statement;

end $$
delimiter ;

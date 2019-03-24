#Zadanie4

create database Lista3;
create table ludzie (PESEL char(11) not null primary key ,
imie varchar(30) not null,
nazwisko varchar(30) not null ,
data_urodzenia date not null,
wzrost float not null,
waga float not null,
rozmiar_buta int not null,
ulubiony_kolor enum ('czarny', 'czerwony', 'zielony', 'niebieski', 'bialy') not null);

create table pracownicy (
                          PESEL char(11) not null,
                          constraint PESEL
                            foreign key (PESEL)
                              references ludzie(PESEL)
                              on update no action
                              on delete no action,
                          zawod varchar(50) not null,
                          pensja float not null);

delimiter $$
create trigger before_ludzie_insert
  before INSERT
  on ludzie
  for each row
begin
  declare sprawdzenie int default 0;
  set sprawdzenie = mod(9*cast(substring(new.PESEL, 1, 1) as signed ) +
                    7*cast(substring(new.PESEL, 2, 1) as signed ) +
                    3*cast(substring(new.PESEL, 3, 1) as signed ) +
                    1*cast(substring(new.PESEL, 4, 1) as signed ) +
                    9*cast(substring(new.PESEL, 5, 1) as signed ) +
                    7*cast(substring(new.PESEL, 6, 1) as signed ) +
                    3*cast(substring(new.PESEL, 7, 1) as signed ) +
                    1*cast(substring(new.PESEL, 8, 1) as signed ) +
                    9*cast(substring(new.PESEL, 9, 1) as signed ) +
                    7*cast(substring(new.PESEL, 10, 1) as signed ), 10);
  if year(new.data_urodzenia) > 1999 then
    if substring(new.PESEL, 1, 2) not like substring(new.data_urodzenia, 3, 2) or
       substring(new.PESEL, 3, 2) not like cast(cast(substring(new.data_urodzenia, 6, 2) as signed ) + 20 as char(2)) or
       substring(new.PESEL, 5, 2) not like substring(new.data_urodzenia, 9, 2) or
       sprawdzenie <> cast(substring(new.PESEL, 11, 1) as signed ) then
      signal sqlstate '19000' set message_text = 'Zły pesel.';
    end if ;
  elseif substring(new.PESEL, 1, 2) not like substring(year(new.data_urodzenia), 3, 2) or
         substring(new.PESEL, 3, 2) not like substring(new.data_urodzenia, 6, 2) or
         substring(new.PESEL, 5, 2) not like substring(new.data_urodzenia, 9, 2) or
         sprawdzenie <> cast(substring(new.PESEL, 11, 1) as signed ) then
    signal sqlstate '20000' set message_text = 'Zły pesel.';
  end if ;
  if new.wzrost < 0 then
    signal sqlstate '12345' set message_text = 'Wzrost nie może być ujemny.';
  end if ;
  if new.waga < 0 then
    signal sqlstate '12345' set message_text = 'Waga nie może być ujemna.';
  end if ;
  if new.rozmiar_buta < 0 then
    signal sqlstate '12345' set message_text = 'Rozmiar buta nie może być ujemny.';
  end if ;
end $$
delimiter ;

delimiter $$
create trigger before_ludzie_update
  before update
  on ludzie
  for each row
begin
  declare sprawdzenie int default 0;
  set sprawdzenie = mod(9*cast(substring(new.PESEL, 1, 1) as signed ) +
                    7*cast(substring(new.PESEL, 2, 1) as signed ) +
                    3*cast(substring(new.PESEL, 3, 1) as signed ) +
                    1*cast(substring(new.PESEL, 4, 1) as signed ) +
                    9*cast(substring(new.PESEL, 5, 1) as signed ) +
                    7*cast(substring(new.PESEL, 6, 1) as signed ) +
                    3*cast(substring(new.PESEL, 7, 1) as signed ) +
                    1*cast(substring(new.PESEL, 8, 1) as signed ) +
                    9*cast(substring(new.PESEL, 9, 1) as signed ) +
                    7*cast(substring(new.PESEL, 10, 1) as signed ), 10);
  if year(new.data_urodzenia) > 1999 then
    if substring(new.PESEL, 1, 2) not like substring(new.data_urodzenia, 3, 2) or
       substring(new.PESEL, 3, 2) not like cast(cast(substring(new.data_urodzenia, 6, 2) as signed ) + 20 as char(2)) or
       substring(new.PESEL, 5, 2) not like substring(new.data_urodzenia, 9, 2) or
       sprawdzenie <> cast(substring(new.PESEL, 11, 1) as signed ) then
      signal sqlstate '19000' set message_text = 'Zły pesel.';
    end if ;
  elseif substring(new.PESEL, 1, 2) not like substring(year(new.data_urodzenia), 3, 2) or
         substring(new.PESEL, 3, 2) not like substring(new.data_urodzenia, 6, 2) or
         substring(new.PESEL, 5, 2) not like substring(new.data_urodzenia, 9, 2) or
         sprawdzenie <> cast(substring(new.PESEL, 11, 1) as signed ) then
    signal sqlstate '20000' set message_text = 'Zły pesel.';
  end if ;
  if new.wzrost < 0 then
    signal sqlstate '12345' set message_text = 'Wzrost nie może być ujemny.';
  end if ;
  if new.waga < 0 then
    signal sqlstate '12345' set message_text = 'Waga nie może być ujemna.';
  end if ;
  if new.rozmiar_buta < 0 then
    signal sqlstate '12345' set message_text = 'Rozmiar buta nie może być ujemny.';
  end if ;
end $$
delimiter ;



delimiter $$
create procedure dodawanie_ludzi()
begin
  declare iterator int default 0;
  declare data0 date default '1998-07-15';
  declare imie varchar(10);
  declare nazwisko varchar(10);
  declare data date;
  declare liczbaPesel varchar(6) default 0;
  declare wzrost int default 0;
  declare waga int default 0;
  declare rozmiarButa int default 0;
  declare pesel varchar(11);
  declare kolor varchar(11);
  declare tmp int;

  while iterator < 198 do

  set liczbaPesel = cast((iterator+1000) as char(6));

  set data = date_add(data0, interval -(cast(liczbaPesel as signed )) day );
  set tmp = mod(9*substring(data, 3, 1) + 7*substring(data, 4, 1) + 3*substring(data, 6, 1) + 1*substring(data, 7, 1) +
                9*substring(data, 9, 1) + 7*substring(data, 10, 1) + 3*substring(liczbaPesel, 1, 1) + 1*substring(liczbaPesel, 2, 1) +
                9*substring(liczbaPesel, 3, 1) + 7*substring(liczbaPesel, 4, 1), 10);
  set pesel = concat(substring(data, 3, 2), substring(data, 6, 2), substring(data, 9, 2), liczbaPesel, cast(tmp as char(1)));

  set tmp = round(rand()*1000);

  if mod(tmp, 3) = 0 then
    set imie = 'Mask';
  elseif mod(tmp, 3) = 1 then
    set imie = 'Kuba';
  else
    set imie = 'Adam';
  end if ;

  set tmp = round(rand()*1000);

  if mod(tmp, 3) = 0 then
    set nazwisko = 'Koza';
  elseif mod(tmp, 3) = 1 then
    set nazwisko = 'Kula';
  else
    set nazwisko = 'Pyla';
  end if ;

  set tmp = mod (round(rand()*1000), 5);

  if tmp = 0 then
    set kolor = 'czarny';
  elseif tmp = 1 then
    set kolor = 'czerwony';
  elseif tmp = 2 then
    set kolor = 'zielony';
  elseif tmp = 3 then
    set kolor = 'niebieski';
  else
    set kolor = 'bialy';
  end if ;

  set wzrost = round(rand()*100 + 100);

  set rozmiarButa = round(rand()*35 + 15);

  set waga = round(rand()*50 + 50);

  insert into ludzie (pesel, imie, nazwisko, data_urodzenia, wzrost, waga, rozmiar_buta, ulubiony_kolor)
  values (pesel, imie, nazwisko, data, wzrost, waga, rozmiarButa, kolor);

  set iterator = iterator + 1;
  end while ;
end $$
delimiter ;

insert into ludzie (PESEL, imie, nazwisko, data_urodzenia, wzrost, waga, rozmiar_buta, ulubiony_kolor)
VALUES ('20092487653', 'Zdigniew', 'Wolski', '1920-09-24', 123, 123, 123, 'czarny');

insert into ludzie (PESEL, imie, nazwisko, data_urodzenia, wzrost, waga, rozmiar_buta, ulubiony_kolor)
VALUES ('05292487656', 'Andrzej', 'Koszyczek', '2005-09-24', 123, 123, 123, 'czarny');




delimiter $$
create trigger before_pracownicy_inset
  before insert on pracownicy
  for each row
begin
  declare minimalna int default 0;
  declare roznicaDni int default 0;
  declare roznicaMiesiecy int default 0;
  declare roznicaLat int default 0;

  if new.pensja < 0 then
    signal sqlstate '46931' set message_text = 'Pensja nie może być ujemna.';
  end if ;

  if cast(substring(new.PESEL, 3, 2) as signed ) <= 12 then
    set roznicaLat = cast(year(now()) as signed ) - cast(concat('19', substring(new.PESEL, 1, 2)) as signed );
    set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed );
    set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
  elseif cast(substring(new.PESEL, 3, 2) as signed ) >= 21 then
    set roznicaLat = cast(year(now()) as signed ) - cast(concat('20', substring(new.PESEL, 1, 2)) as signed );
    set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed ) + 20;
    set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
  end if ;

  if roznicaLat <= 18 and
     (roznicaLat <> 18 or roznicaMiesiecy <= 0) and
     (roznicaLat <> 18 or roznicaMiesiecy <> 0 or roznicaDni < 0) then
    signal sqlstate '24680' set message_text = 'Człowiek nie jest pełnoletni.';
  end if ;

  if new.zawod like 'sprzedawca' then

    if cast(substring(new.PESEL, 3, 2) as signed ) <= 12 then
      set roznicaLat = cast(year(now()) as signed ) - cast(concat('19', substring(new.PESEL, 1, 2)) as signed );
      set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed );
      set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
    elseif cast(substring(new.PESEL, 3, 2) as signed ) >= 21 then
      set roznicaLat = cast(year(now()) as signed ) - cast(concat('20', substring(new.PESEL, 1, 2)) as signed );
      set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed ) + 20;
      set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
    end if ;

    if roznicaLat > 66 or
       (roznicaLat = 66 and roznicaMiesiecy > 0) or
       (roznicaLat = 66 and roznicaMiesiecy = 0 and roznicaDni >= 0) then
      signal sqlstate '13579' set message_text = 'Sprzadaca nie może mieć więcej niż 65 lat.';
    end if ;

  end if;

  select min(pensja) from pracownicy where zawod like 'informatyk' into minimalna;

  if minimalna*3 < new.pensja and new.zawod like 'informatyk' then
    signal sqlstate '34567' set message_text = 'Za duża pencja';
  end if ;



end $$
delimiter ;

delimiter $$
create trigger before_pracownicy_update
  before update on pracownicy
  for each row
begin
  declare minimalna int default 0;
  declare roznicaDni int default 0;
  declare roznicaMiesiecy int default 0;
  declare roznicaLat int default 0;

  if new.pensja < 0 then
    signal sqlstate '46931' set message_text = 'Pensja nie może być ujemna.';
  end if ;

  if cast(substring(new.PESEL, 3, 2) as signed ) <= 12 then
    set roznicaLat = cast(year(now()) as signed ) - cast(concat('19', substring(new.PESEL, 1, 2)) as signed );
    set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed );
    set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
  elseif cast(substring(new.PESEL, 3, 2) as signed ) >= 21 then
    set roznicaLat = cast(year(now()) as signed ) - cast(concat('20', substring(new.PESEL, 1, 2)) as signed );
    set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed ) + 20;
    set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
  end if ;

  if roznicaLat <= 18 and
     (roznicaLat <> 18 or roznicaMiesiecy <= 0) and
     (roznicaLat <> 18 or roznicaMiesiecy <> 0 or roznicaDni < 0) then
    signal sqlstate '24680' set message_text = 'Człowiek nie jest pełnoletni.';
  end if ;

  if new.zawod like 'sprzedawca' then

    if cast(substring(new.PESEL, 3, 2) as signed ) <= 12 then
      set roznicaLat = cast(year(now()) as signed ) - cast(concat('19', substring(new.PESEL, 1, 2)) as signed );
      set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed );
      set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
    elseif cast(substring(new.PESEL, 3, 2) as signed ) >= 21 then
      set roznicaLat = cast(year(now()) as signed ) - cast(concat('20', substring(new.PESEL, 1, 2)) as signed );
      set roznicaMiesiecy = cast(month(now()) as signed ) - cast(substring(new.PESEL, 3, 2) as signed ) + 20;
      set roznicaDni = cast(day(now()) as signed ) - cast(substring(new.PESEL, 5, 2) as signed );
    end if ;

    if roznicaLat > 66 or
       (roznicaLat = 66 and roznicaMiesiecy > 0) or
       (roznicaLat = 66 and roznicaMiesiecy = 0 and roznicaDni >= 0) then
      signal sqlstate '13579' set message_text = 'Sprzadaca nie może mieć więcej niż 65 lat.';
    end if ;

  end if;

  select min(pensja) from pracownicy where zawod like 'informatyk' into minimalna;

  if minimalna*3 < new.pensja and new.zawod like 'informatyk' then
    signal sqlstate '34567' set message_text = 'Za duża pencja';
  end if ;


end $$
delimiter ;


delimiter $$
create procedure dodawanie_pracownikow()
begin
  declare iterator int default 2;
  declare peselek char(11);

  while iterator < 52 do
    select PESEL from ludzie order by PESEL limit iterator,1 into peselek;
    insert into pracownicy (PESEL, zawod, pensja)
    values (peselek, 'aktor', 15000);

    set iterator = iterator + 1;
  end while ;

  while iterator < 85 do
    select PESEL from ludzie order by PESEL limit iterator,1 into peselek;
    insert into pracownicy (PESEL, zawod, pensja)
    values (peselek, 'agent', 10000);

    set iterator = iterator + 1;
  end while ;

  while iterator < 98 do
    select PESEL from ludzie order by PESEL limit iterator,1 into peselek;
    insert into pracownicy (PESEL, zawod, pensja)
    values (peselek, 'informatyk', 20000);

    set iterator = iterator + 1;
  end while ;

  while iterator < 100 do
    select PESEL from ludzie order by PESEL limit iterator,1 into peselek;
    insert into pracownicy (PESEL, zawod, pensja)
    values (peselek, 'reporter', 7000);

    set iterator = iterator + 1;
  end while ;

  while iterator < 177 do
    select PESEL from ludzie order by PESEL limit iterator,1 into peselek;
    insert into pracownicy (PESEL, zawod, pensja)
    values (peselek, 'sprzedawca', 3000);

    set iterator = iterator + 1;
  end while ;

end $$
delimiter ;

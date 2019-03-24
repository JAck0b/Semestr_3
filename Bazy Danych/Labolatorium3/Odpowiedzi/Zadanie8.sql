#Zadanie8
create database Logi;
create table Logi.zmiany (poprzednia_pensja float not null, obecna_pensja float not null, data datetime not null, użytkownik varchar(50) not null);

  delimiter $$
create trigger after_pracownicy_insert
  after insert on pracownicy
  for each row
  begin
    insert into Logi.zmiany (poprzednia_pensja, obecna_pensja, data, użytkownik)
    values (-1, new.pensja, now(), current_user);
  end $$
delimiter ;

delimiter $$
create trigger after_pracownicy_update
  after update on pracownicy
  for each row
  begin
    if OLD.pensja <> NEW.pensja then
      insert into Logi.zmiany (poprzednia_pensja, obecna_pensja, data, użytkownik)
      values (OLD.pensja, new.pensja, now(), current_user);
    end if ;
  end $$
delimiter ;

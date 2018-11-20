#Zadanie1
create database `Labolatorium-Filmoteka`;
create user '244977'@'localhost' identified by 'jakub977';
grant select, update, insert ON `Labolatorium-Filmoteka`.* to '244977'@'localhost';
flush privileges;
(show grants for '244977'@'localhost';)

#Zadanie2
create table aktorzy (aktor_id int, imie varchar(255), nazwisko varchar(255));

create table filmy (film_id int, tytuł varchar(255), gatunek varchar(255), czar_trwania int, kategoria_wiekowa varchar(255));

create table zagrali (aktor_id int, film_id int);

insert into `Labolatorium-Filmoteka`.aktorzy (aktor_id, imie, nazwisko)
select actor_id, first_name, last_name
from sakila.actor
where first_name not like "%v%" and first_name not like "%x%" and first_name not like "%q%"
	and last_name not like "%v%" and last_name not like "%x%" and last_name not like "%q%";

insert into `Labolatorium-Filmoteka`.filmy (film_id, tytuł, gatunek, czas_trwania, kategoria_wiekowa)
select film.film_id, film.title, category.name, film.length,  film.rating
from sakila.film join sakila.film_category on film.film_id = film_category.film_id
	join category on film_category.category_id = category.category_id
where film.title not like "%v%" and film.title not like "%x%" and film.title not like "%q%";

insert into zagrali (aktor_id, film_id)
select film_actor.actor_id, film_actor.film_id
from sakila.film_actor join aktorzy on sakila.film_actor.actor_id = aktorzy.aktor_id
	join filmy on sakila.film_actor.film_id = filmy.film_id;

#Zadanie3
alter table aktorzy add liczba_filmów int after nazwisko;
alter table aktorzy add lista_filmów varchar(255) after liczba_filmów;

delimiter $$
create procedure list (in id int, out result varchar(255))
  begin
    declare amount int default 0;
    declare iterator int default 0;
    declare line varchar(255) default '';
    set result = '';
    select count(*)
    from aktorzy join zagrali on aktorzy.aktor_id = zagrali.aktor_id
    join filmy on zagrali.film_id = filmy.film_id
    where aktorzy.aktor_id = id
    having count(filmy.film_id) < 4
    into amount;
    while iterator < amount do
      set line = '';
      select filmy.tytuł
      from aktorzy join zagrali on aktorzy.aktor_id = zagrali.aktor_id
      join filmy on zagrali.film_id = filmy.film_id
      where aktorzy.aktor_id = id limit iterator,1
      into line;
      set result = concat(result, ';', line);
      set iterator = iterator + 1;
    end while ;
  end $$
delimiter ;

delimiter &&
create procedure listOfFilms ()
  begin
    declare iterator int default 0;
    declare amount int default 0;
    declare tmpidx int default 0;

    select count(*)
    from aktorzy
    into amount;

    while iterator < amount do
      select aktor_id
      from aktorzy
      limit iterator,1
      into tmpidx;

      call list(tmpidx, @l);
      update aktorzy
      set lista_filmów = @l
      where aktor_id = tmpidx;

      set iterator = iterator + 1;
    end while ;
  end &&
delimiter ;

call listOfFilms();

delimiter $$
create procedure quantityOfFilms ()
  begin
    declare iterator int default 0;
    declare amount int default 0;
    declare tmpidx int default 0;

    select count(*)
    from aktorzy
        into amount;

    while iterator < amount do
      select aktor_id
      from aktorzy
      limit iterator,1
          into tmpidx;

      update aktorzy
      set liczba_filmów = (select count(film_id)
                           from zagrali
                           where aktor_id = tmpidx)
      where aktor_id = tmpidx;

      set iterator = iterator + 1;
    end while ;
  end $$
delimiter ;

call quantityOfFilms();

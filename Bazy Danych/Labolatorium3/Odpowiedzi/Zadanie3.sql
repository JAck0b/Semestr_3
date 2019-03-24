#Zadanie3
# Nie zostanie użyte, ponieważ użyłem indeksu używając bdrzewa oraz mam indeks na pierwszej literze imienia skonkatetowany.
select distinct imie
from aktorzy
where imie LIKE 'J%';

# Nie zostanie użyte, bo nie mamy indeksu na liczbia_filmów.
select distinct nazwisko
from aktorzy
where liczba_filmów >= 12;

# Tak przy wyszukiwaniu aktora Zaro Cage
select distinct tytuł
from zagrali
       join
     (select distinct aktor_id
      from zagrali
             join
           (select b.film_id as film
            from zagrali b join aktorzy on b.aktor_id = aktorzy.aktor_id
            where aktorzy.imie like 'Zero' and aktorzy.nazwisko like 'Cage') as tmp
           on zagrali.film_id = tmp.film) as a
     on a.aktor_id = zagrali.aktor_id
       join filmy on zagrali.film_id = filmy.film_id;

# Nie jest używane, bo wyszukujemy dokładnie tę wartość
select m, aktor
from
  (select aktor, min(datediff(koniec, now())) as m
  from kontrakty
  where datediff(koniec, now()) > 0
    group by aktor ) as tmp
order by m asc
limit 1;

# Nie, bo nie porównujemy nigdzie pierwszych liter imienia
select imie
from
  (select imie, count(aktor_id) as quantity
  from aktorzy
  group by imie) as tmp
order by quantity desc, imie asc
limit 1;

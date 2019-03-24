#Zadanie2
# Wybieram btree, ponieważ ono pozwala na szybsze przeszukiwanie zbiorów w zapytaniach o przedział.
# Pytanie: Czy można zrobić hasha i potem przyrównywać do miesiąca?

create index kontrakty_index using btree on kontrakty (koniec);

  select aktor
  from kontrakty
  where koniec > now() and koniec <= date_add(now(), interval 1 month );
# Tak naprawdę biorę przedział, czy to do czego służy bdrzewo.

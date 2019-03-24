#Zadanie1
create index tytuł_index using btree on   filmy (tytuł);
create index aktorzy_index using btree on aktorzy (imie(1), nazwisko);
create index zagrali_index using btree on zagrali (aktor_id);

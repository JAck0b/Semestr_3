#Zadanie6
delimiter $$
create procedure wyplata(in budzet int, in zaw varchar(50))
begin
  declare tmp int default 0;
  declare koniec int default true;
  declare iterator cursor for (select pensja
                               from pracownicy
                               where zawod like zaw);
  declare continue handler for not found set koniec = false;

  set autocommit = 0;
  start transaction;
  open iterator;
  fetch iterator into tmp;
  while koniec = true do

    set budzet = budzet - tmp;
    if budzet < 0 then
      rollback ;
      signal sqlstate '10000' set message_text = 'Za mały budżet.';
    end if ;
    commit ;
    fetch iterator into tmp;
  end while ;

  select concat('********', substring(PESEL, 9, 3)), 'wyplacono'
  from pracownicy where zawod like zaw;
  close iterator;
end $$
delimiter ;

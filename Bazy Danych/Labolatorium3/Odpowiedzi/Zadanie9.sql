#Zadanie9
mysqldump -u root -p kuba  > /home/jakub/Dokumenty/Studia/Backup/dump.sql
mysql -u root -p  Lista3 < /home/jakub/Dokumenty/Studia/Backup/dump.sql

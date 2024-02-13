1. Starte MySQL und öffne die MySQL Workbench.
2. Führe die Datei 'create_zootopia.sql' aus.
3. Führe das Skript 'stored_programs.sql' zur Erstellung der Stored Programs aus (insgesamt 8).
4. Führe die Datei 'insertdata_zootopia.sql' aus.
5. Führe das Skript 'views.sql' zur Erstellung der Views aus (insgesamt 4).
6. Öffne den Ordner 'Code'.
7. Öffne die Datei 'app.js'.
   Passe das Passwort in der Zeile 14 an.
8. Führe die Node.js Datei aus, indem du 'node app.js' in deinem Terminal eingibst und mit Enter bestätigst.
9. Öffne nun die Seite 'localhost:8081' in deinem Browser.


Falls es nicht funktioniert:
1. Führe in der Workbench folgende Statements aus:
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'passwort';
   flush privileges;
ODER:
2. Ändere die Portnummer in der Zeile 143.
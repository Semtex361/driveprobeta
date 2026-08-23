DrivePro V91.4

Dieses Gesamtupdate behebt die kontotypabhängige Fahrschüler-Löschung.

Wichtig:
- index.html ins GitHub-Pages-Root legen.
- Die Supabase-Funktion drivepro_delete_student wurde bereits im verbundenen Projekt korrigiert.
- Die SQL-Datei ist als dokumentierte, wiederholbare Migration enthalten.
- Keine bestehenden Fahrschülerdaten werden durch die Migration gelöscht.

Löschrechte:
- Fahrschulkonto: Fahrschüler der eigenen Fahrschule.
- Fahrlehrer: nur zugewiesene Fahrschüler der eigenen Fahrschule.
- Fahrschüler: keine Löschberechtigung.

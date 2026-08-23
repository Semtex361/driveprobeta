DrivePro V91.19

Kontenstruktur:
- Admin erstellt Fahrschulkonten.
- Fahrschulkonten erstellen Fahrlehrer- und Fahrschülerkonten direkt mit E-Mail und Passwort.
- Keine Einladungslinks im neuen DrivePro-Kontenprozess.
- Bestehende Funktionen und der V91.18-Backup-Stand bleiben die Grundlage.

Supabase:
- Neue Edge Function: drivepro-create-account (JWT erforderlich).
- Server prüft die Rolle des aufrufenden Kontos.
- Nur Admins dürfen account_type=school erstellen.
- Nur Fahrschulkonten dürfen account_type=instructor oder student für ihre school_id erstellen.
- Auth-Benutzer und Profile werden serverseitig angelegt.
- Neue Fahrschüler werden anschließend mit linked_user_id mit ihrem DrivePro-Konto verknüpft.
- Die bisherige drivepro-invite-account-Funktion bleibt für den V91.18-Rollback unverändert bestehen.

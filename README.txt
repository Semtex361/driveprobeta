DrivePro V91.21.0

Berechtigungs- und Rollenupdate

Rollen:
- Plattform-Admin: Fahrschulen erstellen, ansehen, bearbeiten, löschen.
- Fahrschule: Fahrlehrer/Fahrschüler/Fahrzeuge verwalten, Zuweisungen, Kalender mit Fahrlehrerfilter.
- Fahrlehrer: nur zugewiesene Fahrschüler, Bearbeitung des Ausbildungs-/Prüfungsstands, eigener Kalender, Logbuch, Anfragen.
- Fahrschüler: eigener Leistungsstand nur lesbar, eigener Kalender, Terminanfragen für zugewiesene Fahrlehrer.

Supabase:
- Rollen-RLS für profiles, students, training_progress, lessons, vehicles und lesson_requests gehärtet.
- Fahrzeuge können einem aktiven Fahrlehrer der eigenen Fahrschule zugewiesen werden.
- Neue RPCs für sichere Terminanfragen und Annahme/Ablehnung.
- Neue Edge Function: drivepro-manage-account für Bearbeiten/Löschen verwalteter Konten.
- drivepro-create-account V4 bleibt für die funktionierende direkte Kontoerstellung bestehen.

Wichtig:
- V91.18 bleibt der bekannte Realtime-Backupstand.
- index.html ersetzt die bisherige index.html.

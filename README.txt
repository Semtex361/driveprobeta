DrivePro V91.2 – Cloud-Synchronisation repariert

1. Supabase: supabase_v91_2_cloud_sync_repair.sql einmal im SQL Editor ausführen.
2. Danach alle bisherigen GitHub-Dateien durch den Inhalt dieses Ordners ersetzen.
3. GitHub Pages neu deployen lassen.
4. Browser mit Strg+F5 bzw. im privaten Fenster öffnen.

Die Migration ist additiv/idempotent und löscht keine DrivePro-Daten.
Die bestehende Einzelzuweisung students.instructor_id bleibt als Fallback erhalten.

Bei einem echten Cloud-Fehler kann in der Browser-Konsole:
window.driveProCloudDiagnostics()
ausgeführt werden. Das Ergebnis zeigt nur technische Statuswerte der Cloud-Tabellen.

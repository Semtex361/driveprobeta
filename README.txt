DrivePro V91.20.0

Basis: V91.19.2
Backup: V91.18

Changes:
- Plattform-Admin und Fahrschulkonto werden über is_platform_admin unterschieden.
- Bestehende Fahrschulkonten sind keine Plattform-Admins.
- Direkte Kontoerstellung bleibt über drivepro-create-account.
- Keine Einladungsfunktion im Frontend.
- Keine Änderung an der funktionierenden Realtime-Zuweisung.
- Supabase handle_new_user wurde serverseitig auf account_type/school_id umgestellt.
- Supabase Account-Creation-Berechtigung verwendet is_platform_admin.

Supabase Edge Function: drivepro-create-account v3
Supabase migration: drivepro_direct_account_creation_roles_v3

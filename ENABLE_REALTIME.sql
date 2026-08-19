-- DrivePro V90.5: einmalig im Supabase SQL Editor ausführen.
-- Fügt die DrivePro-Tabellen nur dann zur Realtime-Publication hinzu,
-- wenn sie dort noch nicht enthalten sind.
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['students','lessons','training_progress']
  LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = t
    ) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    END IF;
  END LOOP;
END $$;

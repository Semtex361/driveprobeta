-- DrivePro V90.6: einmalig im Supabase SQL Editor ausführen.
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['students','lessons','training_progress']
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname='supabase_realtime'
        AND schemaname='public'
        AND tablename=t
    ) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    END IF;
  END LOOP;
END $$;

-- Kontrolle: hier müssen die drei Tabellen auftauchen.
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname='supabase_realtime'
  AND schemaname='public'
  AND tablename IN ('students','lessons','training_progress')
ORDER BY tablename;

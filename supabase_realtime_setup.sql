-- DrivePro V90.23: enable targeted Supabase Realtime.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename='students') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.students;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename='lessons') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.lessons;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename='training_progress') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.training_progress;
  END IF;
END $$;

ALTER TABLE public.students REPLICA IDENTITY FULL;
ALTER TABLE public.lessons REPLICA IDENTITY FULL;
ALTER TABLE public.training_progress REPLICA IDENTITY FULL;

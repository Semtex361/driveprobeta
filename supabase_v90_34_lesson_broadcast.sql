-- DrivePro V90.34 — Realtime lesson delete via Supabase Database Broadcast
-- This replaces the fragile Postgres-Changes DELETE path for lessons only.
-- It does NOT delete or modify students.

create or replace function public.drivepro_broadcast_lesson_deleted()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform realtime.send(
    jsonb_build_object(
      'lesson_id', OLD.id,
      'student_id', OLD.student_id,
      'deleted_at', clock_timestamp()
    ),
    'LESSON_DELETED',
    'drivepro-live-' || OLD.user_id::text,
    true
  );
  return OLD;
end;
$$;

drop trigger if exists drivepro_lesson_deleted_broadcast on public.lessons;

create trigger drivepro_lesson_deleted_broadcast
after delete on public.lessons
for each row
execute function public.drivepro_broadcast_lesson_deleted();

-- Realtime Authorization: a logged-in user may receive broadcasts only on
-- the topic belonging to their own auth.uid().
drop policy if exists "DrivePro users receive own lesson broadcasts" on realtime.messages;

create policy "DrivePro users receive own lesson broadcasts"
on realtime.messages
for select
to authenticated
using (
  extension = 'broadcast'
  and realtime.topic() = 'drivepro-live-' || (select auth.uid())::text
);

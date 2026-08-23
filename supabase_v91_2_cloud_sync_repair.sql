-- DrivePro V91.2 — Cloud/RLS synchronization repair
-- Idempotent. Does not delete data. Aligns student visibility with the
-- multi-instructor assignment table and keeps legacy instructor_id working.

begin;

-- Students: school sees all; student sees own; instructor sees assigned students
-- through student_instructors OR legacy instructor_id.
drop policy if exists "DrivePro multi role students select" on public.students;
create policy "DrivePro multi role students select"
on public.students
for select to authenticated
using (
  school_id = (select private.drivepro_current_school_id())
  and (
    (select private.drivepro_current_account_type()) = 'school'
    or linked_user_id = (select auth.uid())
    or exists (
      select 1
      from public.student_instructors si
      where si.student_id = students.id
        and si.school_id = students.school_id
        and si.instructor_id = (select auth.uid())
    )
    or instructor_id = (select auth.uid())
  )
);

-- Training progress: instructors see progress of all assigned students.
drop policy if exists "DrivePro multi role progress select" on public.training_progress;
create policy "DrivePro multi role progress select"
on public.training_progress
for select to authenticated
using (
  school_id = (select private.drivepro_current_school_id())
  and (
    (select private.drivepro_current_account_type()) = 'school'
    or student_id in (
      select s.id
      from public.students s
      where s.linked_user_id = (select auth.uid())
         or s.instructor_id = (select auth.uid())
         or exists (
           select 1 from public.student_instructors si
           where si.student_id=s.id
             and si.school_id=s.school_id
             and si.instructor_id=(select auth.uid())
         )
    )
  )
);

-- Lessons: instructors see lessons belonging to assigned students as well as
-- lessons explicitly carrying their instructor_id.
drop policy if exists "DrivePro multi role lessons select" on public.lessons;
create policy "DrivePro multi role lessons select"
on public.lessons
for select to authenticated
using (
  school_id = (select private.drivepro_current_school_id())
  and (
    (select private.drivepro_current_account_type()) = 'school'
    or instructor_id = (select auth.uid())
    or student_id in (
      select s.id
      from public.students s
      where s.linked_user_id = (select auth.uid())
         or s.instructor_id = (select auth.uid())
         or exists (
           select 1 from public.student_instructors si
           where si.student_id=s.id
             and si.school_id=s.school_id
             and si.instructor_id=(select auth.uid())
         )
    )
  )
);

-- Ensure the assignment table is part of Realtime.
do $$
begin
  if to_regclass('public.student_instructors') is not null
     and exists (select 1 from pg_publication where pubname='supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname='supabase_realtime'
         and schemaname='public'
         and tablename='student_instructors'
     ) then
    alter publication supabase_realtime add table public.student_instructors;
  end if;
end $$;

commit;

select
  to_regclass('public.student_instructors') is not null as assignment_table_exists,
  exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='student_instructors') as assignment_realtime_enabled,
  (select count(*) from public.student_instructors) as assignment_count;

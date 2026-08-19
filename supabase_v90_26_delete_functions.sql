-- DrivePro V90.26
-- Atomic, authenticated deletes. Run once in Supabase SQL Editor.

create or replace function public.drivepro_delete_lesson(p_lesson_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  delete from public.lessons
  where id = p_lesson_id
    and user_id = auth.uid()
  returning id into deleted_id;

  if deleted_id is null then
    raise exception 'lesson_not_found_or_not_owned';
  end if;

  return deleted_id;
end;
$$;

revoke all on function public.drivepro_delete_lesson(uuid) from public;
grant execute on function public.drivepro_delete_lesson(uuid) to authenticated;


create or replace function public.drivepro_delete_student(
  p_student_id uuid,
  p_student_name text default ''
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if not exists (
    select 1 from public.students
    where id = p_student_id
      and user_id = auth.uid()
  ) then
    raise exception 'student_not_found_or_not_owned';
  end if;

  -- Tombstone uses the existing allowed action value 'deleted'.
  insert into public.activity_log
    (id,user_id,student_id,student_name,action,details,metadata)
  values
    (gen_random_uuid(),auth.uid(),null,coalesce(p_student_name,''),
     'deleted',
     'Fahrschüler gelöscht: ' || coalesce(p_student_name,p_student_id::text),
     jsonb_build_object(
       'deleted_student_id',p_student_id,
       'deleted_at',now(),
       'tombstone_type','student'
     ));

  delete from public.training_progress
  where student_id = p_student_id
    and user_id = auth.uid();

  delete from public.lessons
  where student_id = p_student_id
    and user_id = auth.uid();

  delete from public.students
  where id = p_student_id
    and user_id = auth.uid()
  returning id into deleted_id;

  return deleted_id;
end;
$$;

revoke all on function public.drivepro_delete_student(uuid,text) from public;
grant execute on function public.drivepro_delete_student(uuid,text) to authenticated;

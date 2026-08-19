-- DrivePro V90.31
-- The lesson delete function intentionally touches ONLY public.lessons.
-- Activity logging is handled locally by DrivePro so deleting a lesson can
-- never cascade through unrelated student data.

create or replace function public.drivepro_delete_lesson(p_lesson_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, auth
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

-- Keep the existing student-delete function unchanged; it is only called
-- by the explicit "Fahrschüler löschen" action.

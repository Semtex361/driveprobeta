-- DrivePro V91.4
-- Account-aware student deletion. Safe to run repeatedly.

create or replace function public.drivepro_delete_student(p_student_id uuid, p_student_name text default '')
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  deleted_id uuid;
  v_school_id uuid;
  v_account_type text;
  v_uid uuid;
begin
  v_uid := (select auth.uid());
  if v_uid is null then raise exception 'not_authenticated'; end if;

  v_school_id := (select private.drivepro_current_school_id());
  v_account_type := (select private.drivepro_current_account_type());

  if v_school_id is null or v_account_type not in ('school','instructor') then
    raise exception 'drivepro_account_required';
  end if;

  if not exists (
    select 1 from public.students s
    where s.id = p_student_id
      and s.school_id = v_school_id
      and (
        v_account_type = 'school'
        or s.instructor_id = v_uid
        or exists (
          select 1 from public.student_instructors si
          where si.student_id = s.id
            and si.school_id = v_school_id
            and si.instructor_id = v_uid
        )
      )
  ) then
    raise exception 'student_not_found_or_not_owned';
  end if;

  insert into public.activity_log(
    id,user_id,student_id,student_name,school_id,action,details,metadata
  ) values (
    gen_random_uuid(),v_uid,null,coalesce(p_student_name,''),v_school_id,'deleted',
    'Fahrschüler gelöscht: ' || coalesce(nullif(p_student_name,''),p_student_id::text),
    jsonb_build_object('deleted_student_id',p_student_id,'deleted_at',now(),'tombstone_type','student')
  );

  delete from public.training_progress where student_id=p_student_id and school_id=v_school_id;
  delete from public.lessons where student_id=p_student_id and school_id=v_school_id;
  delete from public.student_instructors where student_id=p_student_id and school_id=v_school_id;
  delete from public.students where id=p_student_id and school_id=v_school_id returning id into deleted_id;

  if deleted_id is null then raise exception 'student_delete_failed'; end if;
  return deleted_id;
end;
$function$;

grant execute on function public.drivepro_delete_student(uuid,text) to authenticated;
revoke execute on function public.drivepro_delete_student(uuid,text) from anon, public;

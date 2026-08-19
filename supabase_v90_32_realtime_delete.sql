-- DrivePro V90.32 — Realtime DELETE delivery
-- Required for reliable DELETE payloads on lessons.
alter table public.lessons replica identity full;

do $$
begin
  if not exists (
    select 1
    from pg_publication_rel pr
    join pg_publication p on p.oid=pr.prpubid
    join pg_class c on c.oid=pr.prrelid
    join pg_namespace n on n.oid=c.relnamespace
    where p.pubname='supabase_realtime'
      and n.nspname='public'
      and c.relname='lessons'
  ) then
    alter publication supabase_realtime add table public.lessons;
  end if;
end $$;

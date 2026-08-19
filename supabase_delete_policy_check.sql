-- Optional diagnostic only: run if DrivePro reports that a lesson could not be deleted.
-- It shows the current DELETE policies on lessons.
select policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname='public' and tablename='lessons'
order by policyname;

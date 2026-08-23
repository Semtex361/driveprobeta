-- DrivePro V90.36 — Cloud-synchronised application settings
-- Stores the shared DrivePro settings per authenticated user and broadcasts
-- changes instantly to the user's other devices.
--
-- Synced settings:
--   theme, schoolName, schoolAddress, schoolPhone, schoolEmail,
--   trainingAreas, durations
-- Browser notification permission is intentionally NOT synced because the
-- permission belongs to the individual browser/device.

create table if not exists public.drivepro_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.drivepro_settings enable row level security;

-- Keep the migration idempotent if the table/policies are run more than once.
drop policy if exists "DrivePro settings select own" on public.drivepro_settings;
drop policy if exists "DrivePro settings insert own" on public.drivepro_settings;
drop policy if exists "DrivePro settings update own" on public.drivepro_settings;
drop policy if exists "DrivePro settings delete own" on public.drivepro_settings;

create policy "DrivePro settings select own"
on public.drivepro_settings
for select
to authenticated
using (user_id = (select auth.uid()));

create policy "DrivePro settings insert own"
on public.drivepro_settings
for insert
to authenticated
with check (user_id = (select auth.uid()));

create policy "DrivePro settings update own"
on public.drivepro_settings
for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy "DrivePro settings delete own"
on public.drivepro_settings
for delete
to authenticated
using (user_id = (select auth.uid()));

grant select, insert, update, delete on public.drivepro_settings to authenticated;

create or replace function public.drivepro_settings_set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = clock_timestamp();
  return new;
end;
$$;

drop trigger if exists drivepro_settings_updated_at on public.drivepro_settings;
create trigger drivepro_settings_updated_at
before update on public.drivepro_settings
for each row
execute function public.drivepro_settings_set_updated_at();

-- Broadcast the complete canonical settings object. This avoids relying on
-- Postgres-Changes DELETE/OLD payload behaviour and makes the update instant.
create or replace function public.drivepro_broadcast_settings_changed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform realtime.send(
    jsonb_build_object(
      'user_id', NEW.user_id,
      'settings', NEW.settings,
      'updated_at', NEW.updated_at
    ),
    'SETTINGS_UPDATED',
    'drivepro-live-' || NEW.user_id::text,
    true
  );
  return NEW;
end;
$$;

drop trigger if exists drivepro_settings_broadcast on public.drivepro_settings;
create trigger drivepro_settings_broadcast
after insert or update on public.drivepro_settings
for each row
execute function public.drivepro_broadcast_settings_changed();

-- The existing DrivePro V90.34 Realtime policy already authorizes private
-- broadcasts on drivepro-live-<auth.uid()>. Keep this migration independent
-- so it can be applied after V90.34 without replacing that policy.

-- Ensure the existing private DrivePro broadcast channel remains authorized
-- for the logged-in owner only. This is the same policy used by V90.34.
drop policy if exists "DrivePro users receive own lesson broadcasts" on realtime.messages;
create policy "DrivePro users receive own lesson broadcasts"
on realtime.messages
for select
to authenticated
using (
  extension = 'broadcast'
  and realtime.topic() = 'drivepro-live-' || (select auth.uid())::text
);

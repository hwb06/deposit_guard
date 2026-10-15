-- DepositGuard cloud backup setup.
-- Run once in Supabase Dashboard > SQL Editor. Safe to run again.

-- 1. Tables ------------------------------------------------------------
create table if not exists public.rentals (
  id uuid primary key,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  address text not null check (char_length(address) between 1 and 200),
  lease_start timestamptz not null,
  lease_end timestamptz not null,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create table if not exists public.issues (
  id uuid primary key,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  rental_id uuid not null references public.rentals (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  room text not null check (char_length(room) between 1 and 50),
  severity text not null check (severity in ('minor', 'moderate', 'severe')),
  stage text not null check (stage in ('moveIn', 'duringStay', 'moveOut')),
  note text check (note is null or char_length(note) <= 1000),
  photo_path text check (photo_path is null or char_length(photo_path) <= 200),
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create index if not exists rentals_user_id_idx on public.rentals (user_id);
create index if not exists issues_user_id_idx on public.issues (user_id);
create index if not exists issues_rental_id_idx on public.issues (rental_id);

-- 2. Permissions (signed-in users only, never anonymous visitors) -------
revoke all on public.rentals, public.issues from anon;
grant select, insert, update, delete on public.rentals to authenticated;
grant select, insert, update, delete on public.issues to authenticated;

-- 3. Row Level Security: each user sees only their own rows --------------
alter table public.rentals enable row level security;
alter table public.issues enable row level security;

drop policy if exists "rentals_select_own" on public.rentals;
drop policy if exists "rentals_insert_own" on public.rentals;
drop policy if exists "rentals_update_own" on public.rentals;
drop policy if exists "rentals_delete_own" on public.rentals;

create policy "rentals_select_own" on public.rentals
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "rentals_insert_own" on public.rentals
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "rentals_update_own" on public.rentals
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "rentals_delete_own" on public.rentals
  for delete to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "issues_select_own" on public.issues;
drop policy if exists "issues_insert_own" on public.issues;
drop policy if exists "issues_update_own" on public.issues;
drop policy if exists "issues_delete_own" on public.issues;

create policy "issues_select_own" on public.issues
  for select to authenticated
  using ((select auth.uid()) = user_id);

-- An issue can only point at a rental that belongs to the same user.
create policy "issues_insert_own" on public.issues
  for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.rentals r
      where r.id = rental_id and r.user_id = (select auth.uid())
    )
  );

create policy "issues_update_own" on public.issues
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.rentals r
      where r.id = rental_id and r.user_id = (select auth.uid())
    )
  );

create policy "issues_delete_own" on public.issues
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- 4. Private photo bucket -----------------------------------------------
-- Files are stored as <user id>/<file name>.
insert into storage.buckets
  (id, name, public, file_size_limit, allowed_mime_types)
values (
  'issue-photos', 'issue-photos', false, 5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "photos_select_own" on storage.objects;
drop policy if exists "photos_insert_own" on storage.objects;
drop policy if exists "photos_update_own" on storage.objects;
drop policy if exists "photos_delete_own" on storage.objects;

create policy "photos_select_own" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'issue-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "photos_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'issue-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "photos_update_own" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'issue-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'issue-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "photos_delete_own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'issue-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
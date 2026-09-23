-- RLS hardening for SawaLove (Supabase).
--
-- The PHP API is the primary data path, but every policy below assumes the
-- anon/authenticated PostgREST roles too, because the service role bypasses
-- RLS anyway. Threats addressed:
--
--   1. PRIVILEGE ESCALATION — a signed-in user could previously PATCH their
--      own users row and set status='active', visible=true, isPremium=true,
--      or (once the column exists) role='admin'. RLS checked only WHOSE row
--      it was, not WHAT could change. Restrictive policies below pin those
--      columns to their current values for self-writes.
--   2. CONTACT-DATA HARVESTING — email and phone were readable by any client
--      on every visible profile. Column privileges now hide them entirely
--      from PostgREST; clients use the PHP API /session endpoint (which only
--      ever returns contact data for the authenticated owner).
--   3. STORAGE MODERATION — uploaded photo objects stayed publicly readable
--      even after their owner was banned or hidden. The public read policy
--      now requires the owner to be visible AND active. Moderators/admins
--      get a separate policy to review everything for moderation work.
--   4. PATH TRAVERSAL — object keys containing '..' are rejected outright,
--      belt-and-braces on top of storage.foldername() owner checks.
--
-- Parity note: the MySQL schema (backend/php/schema.sql) carries the same
-- users.role column; grants happen only via direct DB change in both stores.

alter table public.users add column if not exists role text not null default 'user';

-- ── 1. Self-write escalation guard ────────────────────────────────────────
-- The permissive policy (unchanged) grants users access to their own row.
-- This RESTRICTIVE policy additionally requires that protected columns keep
-- their current values, so they can only ever be changed by the service role
-- or the PHP API's DB connection (both bypass RLS).

drop policy if exists "Own row update keeps protected columns" on public.users;
create policy "Own row update keeps protected columns"
on public.users
as restrictive
for update
to authenticated
using (auth.uid() = id)
with check (
  auth.uid() = id
  and status = (select u.status from public.users u where u.id = auth.uid())
  and role = (select u.role from public.users u where u.id = auth.uid())
  and "isPremium" = (select u."isPremium" from public.users u where u.id = auth.uid())
  and visible = (select u.visible from public.users u where u.id = auth.uid())
);

-- ── 2. Contact columns are invisible to PostgREST ─────────────────────────
-- Column-level REVOKE overrides the table-level grant Supabase provisions by
-- default. pin_hash was never meant to leave the server; email/phone are
-- served exclusively by the PHP API for the authenticated owner.

revoke select (email, phone, pin_hash) on public.users from anon, authenticated;
grant select (
  id, name, country, age, city, location, village, goal, intent, bio, photo,
  visible, status, "isPremium", role, lat, lng, distance, preferences,
  paused_at, deletion_requested_at, delete_after, created_at, updated_at
) on public.users to anon, authenticated;

-- ── 3. Moderation-aware storage rules ─────────────────────────────────────

drop policy if exists "Profile photos bucket is publicly readable" on storage.objects;
create policy "Profile photos bucket is publicly readable"
on storage.objects
for select
to anon, authenticated
using (
  (
    bucket_id = 'profile-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  or (
    bucket_id = 'profile-photos'
    and exists (
      select 1
      from public.users u
      where u.id::text = (storage.foldername(name))[1]
        and u.visible = true
        and u.status = 'active'
    )
  )
);

-- Staff review access: moderators and admins can read every uploaded object
-- regardless of the owner's account state, for moderation workflows only.
drop policy if exists "Moderators can review uploaded photos" on storage.objects;
create policy "Moderators can review uploaded photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'profile-photos'
  and exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role in ('moderator', 'admin')
  )
);

-- ── 4. Object keys can never traverse paths ───────────────────────────────

drop policy if exists "Upload object names cannot traverse paths" on storage.objects;
create policy "Upload object names cannot traverse paths"
on storage.objects
as restrictive
for all
to authenticated
using (position('..' in name) = 0)
with check (position('..' in name) = 0);

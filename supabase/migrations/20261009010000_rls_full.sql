-- RLS + authorization for the full SawaLove backend on Supabase.
-- Threats addressed (same list as the PHP regression suite guarded):
--   1. PRIVILEGE ESCALATION via self-update (status/role/isPremium/visible pins)
--   2. CONTACT-DATA HARVESTING (email/phone/pin_hash invisible to clients)
--   3. CROSS-USER DATA ACCESS (matches/messages/swipes/blocks are private)
--   4. MODERATION QUEUE EXPOSURE (moderator/admin only)
--   5. STORAGE moderation-aware read rules (already in 20260603000000)

-- ─────────────────────────────────────────────────────────────────────────────
-- Helper: current user's role
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.current_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select role from public.users where id = auth.uid()), 'user');
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────────────────────────────────────

-- Contact columns stay invisible to PostgREST clients; they are served only
-- via auth (GoTrue) for the authenticated owner. Re-grant the safe columns.
revoke select (email, phone, pin_hash) on public.users from anon, authenticated;
grant select (
  id, name, country, age, city, location, village, goal, intent, bio, photo,
  visible, status, "isPremium", role, lat, lng, distance, preferences,
  last_active_at, paused_at, deletion_requested_at, delete_after, created_at, updated_at
) on public.users to anon, authenticated;

-- Self-write escalation guard: restrictive policy pins protected columns.
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

-- ─────────────────────────────────────────────────────────────────────────────
-- SWIPES
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.swipes enable row level security;

drop policy if exists "Users can insert own swipes" on public.swipes;
create policy "Users can insert own swipes"
on public.swipes
for insert
to authenticated
with check (auth.uid() = swiper_id);

drop policy if exists "Users can read own swipes" on public.swipes;
create policy "Users can read own swipes"
on public.swipes
for select
to authenticated
using (auth.uid() = swiper_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- MATCHES
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.matches enable row level security;

drop policy if exists "Participants can read matches" on public.matches;
create policy "Participants can read matches"
on public.matches
for select
to authenticated
using (auth.uid() in (user_a_id, user_b_id));

drop policy if exists "Participants can unmatch own side" on public.matches;
create policy "Participants can unmatch own side"
on public.matches
for update
to authenticated
using (auth.uid() in (user_a_id, user_b_id))
with check (auth.uid() in (user_a_id, user_b_id));

-- Match rows are created exclusively by the record_swipe RPC (service role).

-- ─────────────────────────────────────────────────────────────────────────────
-- MESSAGES
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.messages enable row level security;

drop policy if exists "Participants can read messages" on public.messages;
create policy "Participants can read messages"
on public.messages
for select
to authenticated
using (
  exists (
    select 1 from public.matches m
    where m.id = messages.match_id
      and auth.uid() in (m.user_a_id, m.user_b_id)
      and m.unmatched_by is null
  )
  or sender_id = auth.uid()
);

drop policy if exists "Participants can send messages" on public.messages;
create policy "Participants can send messages"
on public.messages
for insert
to authenticated
with check (
  auth.uid() = sender_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and auth.uid() in (m.user_a_id, m.user_b_id)
      and m.unmatched_by is null
  )
);

-- ─────────────────────────────────────────────────────────────────────────────
-- BLOCKS
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.blocks enable row level security;

drop policy if exists "Users can insert own blocks" on public.blocks;
create policy "Users can insert own blocks"
on public.blocks
for insert
to authenticated
with check (auth.uid() = blocker_id);

drop policy if exists "Users can read own blocks" on public.blocks;
create policy "Users can read own blocks"
on public.blocks
for select
to authenticated
using (auth.uid() = blocker_id);

drop policy if exists "Users can remove own blocks" on public.blocks;
create policy "Users can remove own blocks"
on public.blocks
for delete
to authenticated
using (auth.uid() = blocker_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- REPORTS: users file and read their own; moderators/admins see all + resolve.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.reports enable row level security;

drop policy if exists "Users can file reports" on public.reports;
create policy "Users can file reports"
on public.reports
for insert
to authenticated
with check (
  auth.uid() = reporter_id
  and reported_user_id <> auth.uid()
);

drop policy if exists "Users can read own reports" on public.reports;
create policy "Users can read own reports"
on public.reports
for select
to authenticated
using (
  auth.uid() = reporter_id
  or public.current_role() in ('moderator', 'admin')
);

drop policy if exists "Moderators can resolve reports" on public.reports;
create policy "Moderators can resolve reports"
on public.reports
for update
to authenticated
using (public.current_role() in ('moderator', 'admin'))
with check (public.current_role() in ('moderator', 'admin'));

-- ─────────────────────────────────────────────────────────────────────────────
-- MODERATION ACTIONS: staff-only, insert-only audit trail.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.moderation_actions enable row level security;

drop policy if exists "Moderators can record actions" on public.moderation_actions;
create policy "Moderators can record actions"
on public.moderation_actions
for insert
to authenticated
with check (
  auth.uid() = moderator_id
  and public.current_role() in ('moderator', 'admin')
);

drop policy if exists "Moderators can read actions" on public.moderation_actions;
create policy "Moderators can read actions"
on public.moderation_actions
for select
to authenticated
using (public.current_role() in ('moderator', 'admin'));

-- ─────────────────────────────────────────────────────────────────────────────
-- PUSH TOKENS: owner-only.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.push_tokens enable row level security;

drop policy if exists "Users can manage own push tokens" on public.push_tokens;
create policy "Users can manage own push tokens"
on public.push_tokens
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- RATE LIMITS / AI USAGE: no client access at all. Only service role (Edge
-- Functions, security-definer RPCs) touch these. RLS enabled with no policies
-- = fully locked for anon/authenticated.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.rate_limits enable row level security;
alter table public.ai_usage enable row level security;

revoke all on public.rate_limits from anon, authenticated;
revoke all on public.ai_usage from anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXECUTE privileges on RPCs: deny by default, grant explicitly in rpcs.sql.
-- ─────────────────────────────────────────────────────────────────────────────

revoke execute on function public.current_role() from anon, authenticated;

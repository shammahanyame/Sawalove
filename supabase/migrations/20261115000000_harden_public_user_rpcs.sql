-- ─────────────────────────────────────────────────────────────────────────────
-- CONTACT-DATA LEAK FIX
--
-- `fetch_discovery_deck`, `fetch_incoming_likes` and `fetch_blocked_users`
-- returned `setof public.users` via `select u.*`. Because they are SECURITY
-- DEFINER, the column-level revoke in 20261009010000_rls_full.sql
-- (`revoke select (email, phone, pin_hash) ...`) does not apply inside the
-- function body: the caller received every column of the row, including
-- email, phone and pin_hash.
--
-- These functions keep their exact signature and return type so existing
-- app builds keep working, but the row is now rebuilt from JSON without the
-- contact/credential columns. `jsonb_populate_record` keeps this resilient to
-- future column additions (nothing to keep in sync by hand).
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.fetch_discovery_deck(
  p_limit integer default 20
)
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select (jsonb_populate_record(
            null::public.users,
            to_jsonb(u) - 'email' - 'phone' - 'pin_hash'
          )).*
  from public.users u
  where u.id <> auth.uid()
    and u.visible = true
    and u.status = 'active'
    and not exists (
      select 1 from public.blocks b
      where (b.blocker_id = auth.uid() and b.blocked_id = u.id)
         or (b.blocker_id = u.id and b.blocked_id = auth.uid())
    )
    and not exists (
      select 1 from public.swipes s
      where s.swiper_id = auth.uid() and s.target_id = u.id
    )
  order by u.last_active_at desc
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$$;

create or replace function public.fetch_incoming_likes(
  p_limit integer default 20
)
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select (jsonb_populate_record(
            null::public.users,
            to_jsonb(u) - 'email' - 'phone' - 'pin_hash'
          )).*
  from public.swipes s
  join public.users u on u.id = s.swiper_id
  where s.target_id = auth.uid()
    and s.action in ('like', 'super_like')
    and not exists (
      select 1 from public.swipes mine
      where mine.swiper_id = auth.uid() and mine.target_id = s.swiper_id
    )
    and u.status = 'active'
    and not exists (
      select 1 from public.blocks b
      where (b.blocker_id = auth.uid() and b.blocked_id = u.id)
         or (b.blocker_id = u.id and b.blocked_id = auth.uid())
    )
  order by s.created_at desc
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- MATCHES LIST: the last-message preview is plain text but the return column
-- is jsonb, so assigning it directly made Postgres parse the message body as
-- JSON — any message like `hello` raised "invalid input syntax for type json"
-- and broke the whole inbox. Wrap it with to_jsonb so it stays a JSON string.
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.fetch_matches(
  p_limit integer default 30
)
returns table (
  match_id uuid,
  created_at timestamptz,
  peer jsonb,
  last_message jsonb
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  return query
  with my_matches as (
    select m.id, m.created_at,
      case when m.user_a_id = auth.uid() then m.user_b_id else m.user_a_id end as peer_id
    from public.matches m
    where auth.uid() in (m.user_a_id, m.user_b_id)
      and m.unmatched_by is null
    order by m.created_at desc
    limit greatest(1, least(coalesce(p_limit, 30), 100))
  )
  select
    mm.id,
    mm.created_at,
    to_jsonb(u) - 'email' - 'phone' - 'pin_hash',
    to_jsonb(last_msg.body_preview)
  from my_matches mm
  join public.users u on u.id = mm.peer_id
  left join lateral (
    select msg.body as body_preview
    from public.messages msg
    where msg.match_id = mm.id
    order by msg.created_at desc
    limit 1
  ) last_msg on true;
end;
$$;

create or replace function public.fetch_blocked_users()
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select (jsonb_populate_record(
            null::public.users,
            to_jsonb(u) - 'email' - 'phone' - 'pin_hash'
          )).*
  from public.blocks b
  join public.users u on u.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by b.created_at desc;
$$;

-- SawaLove RPCs — all backend logic as security-definer Postgres functions.
-- Every write path goes through here; clients cannot touch swipes/matches/
-- moderation rows directly thanks to RLS (no policies) on those tables.
--
-- Enforcement model per function:
--   1. auth.uid() must be present (PostgREST injects request.jwt claims)
--   2. fixed-window rate limit (hashed-IP or user bucket)
--   3. authorization + input validation (types, lengths, enums)
--   4. the write itself

-- ─────────────────────────────────────────────────────────────────────────────
-- RATE LIMIT PRIMITIVE
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.rate_limit_take(
  p_bucket text,
  p_window_minutes integer,
  p_max integer
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_window timestamptz := date_trunc('minute', now());
  v_current integer;
begin
  insert into public.rate_limits (bucket, window_start, attempts)
  values (p_bucket, v_window, 1)
  on conflict (bucket, window_start)
  do update set attempts = public.rate_limits.attempts + 1
  returning attempts into v_current;

  return v_current <= p_max;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- LOG PRIMITIVE
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.log_event(
  p_level text,
  p_event text,
  p_context jsonb default '{}'::jsonb
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.app_logs (level, event, user_id, context)
  values (p_level, p_event, auth.uid(), p_context);
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- DISCOVERY: visible users excluding blocked/self, with distance
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
  select u.*
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

-- ─────────────────────────────────────────────────────────────────────────────
-- SWIPES: like/nope/super_like, creates match on reciprocity, flood-limited
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.record_swipe(
  p_target_id uuid,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_match_id uuid;
  v_matched boolean := false;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  if p_action not in ('like', 'nope', 'super_like') then
    raise exception 'invalid_action' using errcode = '22023';
  end if;

  -- Rate limit: 120 swipes / minute / user.
  if not public.rate_limit_take('user:' || v_uid || ':swipe', 1, 120) then
    raise exception 'over_rate_limit' using errcode = '53400';
  end if;

  -- Cannot swipe yourself; target must exist (FK) and not be blocked.
  if p_target_id = v_uid then
    raise exception 'self_swipe' using errcode = '23514';
  end if;

  if exists (
    select 1 from public.blocks b
    where (b.blocker_id = v_uid and b.blocked_id = p_target_id)
       or (b.blocker_id = p_target_id and b.blocked_id = v_uid)
  ) then
    raise exception 'blocked_user' using errcode = 'P0001';
  end if;

  -- Record the swipe (idempotent per target — re-swipe overwrites action).
  insert into public.swipes (swiper_id, target_id, action)
  values (v_uid, p_target_id, p_action)
  on conflict (swiper_id, target_id) do update
    set action = excluded.action, created_at = now();

  -- Reciprocity check → create/reactivate a match.
  if p_action in ('like', 'super_like') then
    if exists (
      select 1 from public.swipes s
      where s.swiper_id = p_target_id
        and s.target_id = v_uid
        and s.action in ('like', 'super_like')
    ) then
      v_match_id := public.ensure_match(v_uid, p_target_id);
      v_matched := true;
    end if;
  end if;

  perform public.log_event('info', 'swipe', jsonb_build_object(
    'target', p_target_id, 'action', p_action, 'matched', v_matched));

  return jsonb_build_object('matched', v_matched, 'match_id', v_match_id);
end;
$$;

-- Match rows use canonical ordering (user_a_id < user_b_id) so the unique
-- constraint holds regardless of who liked first. Re-liking after unmatch
-- clears the unmatch flag and reactivates the conversation.
create or replace function public.ensure_match(p_a uuid, p_b uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lo uuid := least(p_a, p_b);
  v_hi uuid := greatest(p_a, p_b);
  v_id uuid;
begin
  insert into public.matches (user_a_id, user_b_id, unmatched_by, unmatched_at)
  values (v_lo, v_hi, null, null)
  on conflict (user_a_id, user_b_id) do update
    set unmatched_by = null, unmatched_at = null
  returning id into v_id;
  return v_id;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- LIKES: users who liked me and I have not swiped yet
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.fetch_incoming_likes(
  p_limit integer default 20
)
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select u.*
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
-- MATCHES LIST: active matches with peer profile + last message preview
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
    last_msg.body_preview
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

-- ─────────────────────────────────────────────────────────────────────────────
-- MESSAGES: send (flood-limited) + fetch history for a match I'm in
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.send_message(
  p_match_id uuid,
  p_body text
)
returns public.messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_msg public.messages;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  -- Input validation.
  if p_body is null or char_length(trim(p_body)) = 0 then
    raise exception 'empty_message' using errcode = '22004';
  end if;
  if char_length(p_body) > 4000 then
    raise exception 'message_too_long' using errcode = '22001';
  end if;

  -- Flood limit: 30 messages / minute / user.
  if not public.rate_limit_take('user:' || v_uid || ':message', 1, 30) then
    raise exception 'over_rate_limit' using errcode = '53400';
  end if;

  -- Authorization: must be an active participant of an active match.
  if not exists (
    select 1 from public.matches m
    where m.id = p_match_id
      and v_uid in (m.user_a_id, m.user_b_id)
      and m.unmatched_by is null
  ) then
    raise exception 'match_not_found' using errcode = 'P0002';
  end if;

  insert into public.messages (match_id, sender_id, body)
  values (p_match_id, v_uid, trim(p_body))
  returning * into v_msg;

  perform public.log_event('info', 'message_sent', jsonb_build_object(
    'match_id', p_match_id));

  return v_msg;
end;
$$;

create or replace function public.fetch_messages(
  p_match_id uuid,
  p_limit integer default 50,
  p_before timestamptz default null
)
returns setof public.messages
language sql
stable
security definer
set search_path = public
as $$
  select msg.*
  from public.messages msg
  where msg.match_id = p_match_id
    and (p_before is null or msg.created_at < p_before)
    and exists (
      select 1 from public.matches m
      where m.id = p_match_id
        and auth.uid() in (m.user_a_id, m.user_b_id)
        and (m.unmatched_by is null or msg.sender_id = auth.uid())
    )
  order by msg.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 100));
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- UNMATCH
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.unmatch(
  p_match_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.matches
  set unmatched_by = auth.uid(), unmatched_at = now()
  where id = p_match_id
    and auth.uid() in (user_a_id, user_b_id)
    and unmatched_by is null;

  if not found then
    raise exception 'match_not_found' using errcode = 'P0002';
  end if;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- BLOCKS: idempotent block/unblock + list
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.block_user(p_target_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.blocks (blocker_id, blocked_id)
  values (auth.uid(), p_target_id)
  on conflict (blocker_id, blocked_id) do nothing;
$$;

create or replace function public.unblock_user(p_target_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.blocks
  where blocker_id = auth.uid() and blocked_id = p_target_id;
$$;

create or replace function public.fetch_blocked_users()
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select u.*
  from public.blocks b
  join public.users u on u.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by b.created_at desc;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- REPORTS: file + moderator queue + resolve
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.submit_report(
  p_reported_user_id uuid,
  p_reason text,
  p_details text default null
)
returns public.reports
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_report public.reports;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  -- Input validation.
  if p_reason not in ('harassment', 'fake_profile', 'inappropriate_photos', 'scam', 'other') then
    raise exception 'invalid_reason' using errcode = '22023';
  end if;
  if p_details is not null and char_length(p_details) > 2000 then
    raise exception 'details_too_long' using errcode = '22001';
  end if;
  if p_reported_user_id = v_uid then
    raise exception 'self_report' using errcode = '23514';
  end if;

  -- Flood limit: 10 reports / hour / user.
  if not public.rate_limit_take('user:' || v_uid || ':report', 60, 10) then
    raise exception 'over_rate_limit' using errcode = '53400';
  end if;

  insert into public.reports (reporter_id, reported_user_id, reason, details)
  values (v_uid, p_reported_user_id, p_reason, nullif(trim(coalesce(p_details, '')), ''))
  returning * into v_report;

  perform public.log_event('warn', 'report_filed', jsonb_build_object(
    'reported', p_reported_user_id, 'reason', p_reason, 'report_id', v_report.id));

  return v_report;
end;
$$;

create or replace function public.fetch_moderation_reports(
  p_status text default 'pending',
  p_limit integer default 50
)
returns setof public.reports
language sql
stable
security definer
set search_path = public
as $$
  select r.*
  from public.reports r
  where public.current_role() in ('moderator', 'admin')
    and r.status = p_status
  order by r.created_at asc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

create or replace function public.resolve_report(
  p_report_id uuid,
  p_outcome text,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_report public.reports;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  if public.current_role() not in ('moderator', 'admin') then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_outcome not in ('uphold', 'dismiss') then
    raise exception 'invalid_outcome' using errcode = '22023';
  end if;

  select * into v_report from public.reports where id = p_report_id;
  if not found then
    raise exception 'report_not_found' using errcode = 'P0002';
  end if;

  update public.reports
  set status = case p_outcome when 'uphold' then 'upheld' else 'dismissed' end,
      resolved_by = v_uid,
      resolution_note = nullif(trim(coalesce(p_note, '')), '')
  where id = p_report_id;

  if p_outcome = 'uphold' then
    update public.users
    set status = 'paused', paused_at = now()
    where id = v_report.reported_user_id and status = 'active';
    perform public.log_event('warn', 'moderation_upheld', jsonb_build_object(
      'report_id', p_report_id, 'target', v_report.reported_user_id));
  end if;

  perform public.log_event('info', 'report_resolved', jsonb_build_object(
    'report_id', p_report_id, 'outcome', p_outcome));
end;
$$;

create or replace function public.set_user_status(
  p_user_id uuid,
  p_action text,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or public.current_role() not in ('moderator', 'admin') then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_action not in ('pause', 'ban', 'reinstate') then
    raise exception 'invalid_action' using errcode = '22023';
  end if;

  case p_action
    when 'pause' then
      update public.users set status = 'paused', paused_at = now()
      where id = p_user_id and status = 'active';
    when 'ban' then
      update public.users set status = 'banned'
      where id = p_user_id and status <> 'banned';
    when 'reinstate' then
      update public.users set status = 'active', paused_at = null
      where id = p_user_id and status in ('paused', 'banned');
  end case;

  insert into public.moderation_actions (moderator_id, target_user_id, action, note)
  values (auth.uid(), p_user_id, p_action, nullif(trim(coalesce(p_note, '')), ''));

  perform public.log_event('warn', 'user_status_changed', jsonb_build_object(
    'target', p_user_id, 'action', p_action));
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- ACCOUNT: PIN, pause, deletion request, data export request
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.save_pin(p_pin text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  -- Validation: exactly 4-8 digits.
  if p_pin is null or p_pin !~ '^\d{4,8}$' then
    raise exception 'invalid_pin' using errcode = '22023';
  end if;

  -- Rate limit PIN changes: 5 / hour.
  if not public.rate_limit_take('user:' || auth.uid() || ':pin', 60, 5) then
    raise exception 'over_rate_limit' using errcode = '53400';
  end if;

  update public.users
  set pin_hash = crypt(p_pin, gen_salt('bf', 10))
  where id = auth.uid();
end;
$$;

create or replace function public.pause_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set status = 'paused', paused_at = now(), visible = false
  where id = auth.uid() and status = 'active';
end;
$$;

create or replace function public.request_account_deletion()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set status = 'deletion_requested', deletion_requested_at = now(),
      delete_after = now() + interval '30 days', visible = false
  where id = auth.uid() and status in ('active', 'paused');

  insert into public.account_deletion_requests (user_id, delete_after)
  values (auth.uid(), now() + interval '30 days')
  on conflict (user_id) do update
    set requested_at = now(), delete_after = now() + interval '30 days',
        status = 'pending';
end;
$$;

create or replace function public.request_data_export()
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.data_export_requests (user_id) values (auth.uid());
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXECUTE GRANTS: only the functions clients need; all are security definer
-- so RLS on underlying tables stays the real authorization boundary.
-- ─────────────────────────────────────────────────────────────────────────────

grant execute on function
  public.fetch_discovery_deck(integer),
  public.record_swipe(uuid, text),
  public.fetch_incoming_likes(integer),
  public.fetch_matches(integer),
  public.send_message(uuid, text),
  public.fetch_messages(uuid, integer, timestamptz),
  public.unmatch(uuid),
  public.block_user(uuid),
  public.unblock_user(uuid),
  public.fetch_blocked_users(),
  public.submit_report(uuid, text, text),
  public.fetch_moderation_reports(text, integer),
  public.resolve_report(uuid, text, text),
  public.set_user_status(uuid, text, text),
  public.save_pin(text),
  public.pause_account(),
  public.request_account_deletion(),
  public.request_data_export(),
  public.log_event(text, text, jsonb)
to authenticated;

revoke execute on function
  public.rate_limit_take(text, integer, integer),
  public.ensure_match(uuid, uuid),
  public.housekeeping()
from anon, authenticated;

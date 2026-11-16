-- Call signalling for the Agora video calls.
--
-- Clients never write this table directly: start/answer/end all go through
-- security-definer RPCs, which is also where membership of the match is
-- checked. Clients can only SELECT their own calls, and that same policy is
-- what lets Supabase Realtime deliver the answer/decline/end updates.

create table if not exists public.calls (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  caller_id uuid not null references public.users(id) on delete cascade,
  callee_id uuid not null references public.users(id) on delete cascade,
  channel_name text not null unique,
  status text not null default 'ringing'
    check (status in ('ringing', 'active', 'declined', 'ended', 'missed')),
  started_at timestamptz not null default now(),
  answered_at timestamptz,
  ended_at timestamptz
);

-- The table can already exist from an earlier out-of-band deploy that used
-- `created_at` and no `channel_name`. Bring it up to this migration's shape
-- before the indexes below, so the push is safe either way.
alter table public.calls
  add column if not exists channel_name text,
  add column if not exists started_at timestamptz not null default now();

update public.calls
   set channel_name = 'sl_' || replace(id::text, '-', '')
 where channel_name is null;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'calls'
      and column_name = 'created_at'
  ) then
    execute 'update public.calls set started_at = created_at';
  end if;
end;
$$;

alter table public.calls alter column channel_name set not null;

create unique index if not exists calls_channel_name_key
  on public.calls (channel_name);

create index if not exists calls_callee_status_idx
  on public.calls (callee_id, status, started_at desc);
create index if not exists calls_caller_status_idx
  on public.calls (caller_id, status, started_at desc);
create index if not exists calls_match_idx on public.calls (match_id);

alter table public.calls enable row level security;

drop policy if exists "Participants can read their calls" on public.calls;
create policy "Participants can read their calls"
on public.calls
for select
to authenticated
using (auth.uid() in (caller_id, callee_id));

-- Realtime UPDATE events carry the full row (filters on callee_id need it).
alter table public.calls replica identity full;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = 'calls'
     ) then
    alter publication supabase_realtime add table public.calls;
  end if;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- RPC: start (or rejoin) a call for a match I'm part of
-- ─────────────────────────────────────────────────────────────────────────────

-- An earlier out-of-band deploy created these with different return types,
-- which `create or replace` cannot change. Drop them first; the grants at the
-- end of this file are re-applied afterwards.
drop function if exists public.start_call(uuid);
drop function if exists public.answer_call(uuid);
drop function if exists public.end_call(uuid, text);
drop function if exists public.end_call(uuid);
drop function if exists public.fetch_call(uuid);

create or replace function public.start_call(
  p_match_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_peer uuid;
  v_id uuid := gen_random_uuid();
  v_channel text;
  v_existing public.calls;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  select case when m.user_a_id = v_uid then m.user_b_id else m.user_a_id end
    into v_peer
  from public.matches m
  where m.id = p_match_id
    and v_uid in (m.user_a_id, m.user_b_id)
    and m.unmatched_by is null;

  if v_peer is null then
    raise exception 'match_not_found' using errcode = 'P0002';
  end if;

  if not public.rate_limit_take('user:' || v_uid || ':call', 1, 10) then
    raise exception 'over_rate_limit' using errcode = '53400';
  end if;

  -- Stale rings (caller closed the app) must not block a new call forever.
  update public.calls
     set status = 'missed', ended_at = now()
   where status = 'ringing'
     and started_at < now() - interval '60 seconds'
     and v_uid in (caller_id, callee_id);

  select * into v_existing
  from public.calls c
  where c.status in ('ringing', 'active')
    and ((c.caller_id = v_uid and c.callee_id = v_peer)
      or (c.caller_id = v_peer and c.callee_id = v_uid))
  order by c.started_at desc
  limit 1;

  if found then
    return jsonb_build_object(
      'call_id', v_existing.id,
      'channel_name', v_existing.channel_name,
      'callee_id', v_existing.callee_id,
      'caller_id', v_existing.caller_id,
      'status', v_existing.status
    );
  end if;

  v_channel := 'sl_' || replace(v_id::text, '-', '');

  insert into public.calls (id, match_id, caller_id, callee_id, channel_name)
  values (v_id, p_match_id, v_uid, v_peer, v_channel);

  return jsonb_build_object(
    'call_id', v_id,
    'channel_name', v_channel,
    'callee_id', v_peer,
    'caller_id', v_uid,
    'status', 'ringing'
  );
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- RPC: callee accepts the ring
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.answer_call(
  p_call_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.calls
     set status = 'active',
         answered_at = coalesce(answered_at, now())
   where id = p_call_id
     and callee_id = auth.uid()
     and status = 'ringing';
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- RPC: either side hangs up, or the callee declines
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.end_call(
  p_call_id uuid,
  p_status text default 'ended'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_status not in ('ended', 'declined') then
    raise exception 'invalid_status' using errcode = '22023';
  end if;

  if p_status = 'declined' then
    update public.calls
       set status = 'declined', ended_at = now()
     where id = p_call_id
       and callee_id = auth.uid()
       and status in ('ringing', 'active');
  else
    update public.calls
       set status = 'ended', ended_at = now()
     where id = p_call_id
       and auth.uid() in (caller_id, callee_id)
       and status in ('ringing', 'active');
  end if;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- RPC: read one call (caller polls this as a fallback to Realtime)
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.fetch_call(
  p_call_id uuid
)
returns setof public.calls
language sql
stable
security definer
set search_path = public
as $$
  select c.*
  from public.calls c
  where c.id = p_call_id
    and auth.uid() in (c.caller_id, c.callee_id);
$$;

revoke execute on function
  public.start_call(uuid),
  public.answer_call(uuid),
  public.end_call(uuid, text),
  public.fetch_call(uuid)
from anon;

grant execute on function
  public.start_call(uuid),
  public.answer_call(uuid),
  public.end_call(uuid, text),
  public.fetch_call(uuid)
to authenticated;

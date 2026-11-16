-- ─────────────────────────────────────────────────────────────────────────────
-- RPC GRANTS: authenticated only.
--
-- Postgres grants EXECUTE on every new function to PUBLIC. The earlier
-- migration revoked EXECUTE from `anon` alone, which left that PUBLIC grant
-- untouched — `anon` still inherited it, so every client RPC stayed callable
-- without a session. `record_swipe` and `send_message` do raise
-- `not_authenticated` when `auth.uid()` is null, so nothing leaked, but the
-- grant should match the intent: only signed-in users reach these functions.
--
-- Revoking from PUBLIC/anon/authenticated and re-granting to authenticated
-- (plus service_role for Edge Functions) makes that explicit.
-- ─────────────────────────────────────────────────────────────────────────────

do $$
declare
  fn text;
begin
  foreach fn in array array[
    'public.fetch_discovery_deck(integer)',
    'public.record_swipe(uuid, text)',
    'public.fetch_incoming_likes(integer)',
    'public.fetch_matches(integer)',
    'public.send_message(uuid, text)',
    'public.fetch_messages(uuid, integer, timestamptz)',
    'public.unmatch(uuid)',
    'public.block_user(uuid)',
    'public.unblock_user(uuid)',
    'public.fetch_blocked_users()',
    'public.submit_report(uuid, text, text)',
    'public.fetch_moderation_reports(text, integer)',
    'public.resolve_report(uuid, text, text)',
    'public.set_user_status(uuid, text, text)',
    'public.save_pin(text)',
    'public.pause_account()',
    'public.request_account_deletion()',
    'public.request_data_export()',
    'public.log_event(text, text, jsonb)',
    'public.start_call(uuid)',
    'public.answer_call(uuid)',
    'public.end_call(uuid, text)',
    'public.fetch_call(uuid)'
  ]
  loop
    execute format(
      'revoke execute on function %s from public, anon, authenticated', fn);
    execute format(
      'grant execute on function %s to authenticated, service_role', fn);
  end loop;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- CALL RPCs: reject a missing session explicitly.
--
-- Both previously no-opped for an anonymous caller. They are unreachable for
-- anon after the grant change above, but the guard makes the contract obvious
-- and gives the client the same `not_authenticated` error every other RPC
-- returns.
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
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

  update public.calls
     set status = 'active',
         answered_at = coalesce(answered_at, now())
   where id = p_call_id
     and callee_id = auth.uid()
     and status = 'ringing';
end;
$$;

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
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;

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

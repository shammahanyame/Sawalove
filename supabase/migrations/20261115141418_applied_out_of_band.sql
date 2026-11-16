-- Applied straight to the remote project (Supabase dashboard) before this
-- repository tracked it in migration history. Recorded as a no-op so
-- `supabase db push` can match local and remote histories; its DDL is already
-- covered by the tracked migrations around it (call signalling / RPC
-- hardening).
select 1;

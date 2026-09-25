create table if not exists users (
  id char(36) primary key,
  name varchar(120) null,
  email varchar(190) null,
  email_normalized varchar(190) null,
  phone varchar(32) null,
  country varchar(8) null,
  password_hash varchar(255) null,
  age int null,
  city varchar(120) not null default 'Douala',
  location varchar(120) not null default 'Cameroon',
  village varchar(120) not null default 'Cameroon',
  goal varchar(120) not null default 'Connection',
  intent varchar(120) null,
  bio text null,
  photo varchar(512) null,
  visible tinyint(1) not null default 0,
  status enum('active', 'paused', 'deletion_requested', 'banned') not null default 'active',
  -- ROLE-BASED ACCESS CONTROL: 'user' is the default. 'moderator' and 'admin'
  -- are granted ONLY by a direct DB change (ops runbook) — no API endpoint
  -- can create, read, or modify roles.
  role enum('user', 'moderator', 'admin') not null default 'user',
  is_premium tinyint(1) not null default 0,
  lat decimal(10, 7) not null default 0,
  lng decimal(10, 7) not null default 0,
  distance decimal(8, 2) not null default 2.5,
  preferences json null,
  pin_hash varchar(255) null,
  paused_at datetime null,
  deletion_requested_at datetime null,
  delete_after datetime null,
  created_at datetime not null default current_timestamp,
  updated_at datetime not null default current_timestamp on update current_timestamp,
  unique key users_email_normalized_unique (email_normalized),
  unique key users_phone_unique (phone),
  key users_visible_status_idx (visible, status)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists sessions (
  id bigint unsigned auto_increment primary key,
  user_id char(36) not null,
  token_hash char(64) not null,
  expires_at datetime not null,
  revoked_at datetime null,
  created_at datetime not null default current_timestamp,
  unique key sessions_token_hash_unique (token_hash),
  key sessions_user_id_idx (user_id),
  key sessions_expires_at_idx (expires_at),
  constraint sessions_user_id_fk foreign key (user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists phone_otps (
  id bigint unsigned auto_increment primary key,
  phone varchar(32) not null,
  code_hash char(64) not null,
  attempts int not null default 0,
  request_ip varchar(64) null,
  expires_at datetime not null,
  consumed_at datetime null,
  created_at datetime not null default current_timestamp,
  key phone_otps_phone_created_idx (phone, created_at),
  key phone_otps_expires_at_idx (expires_at)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists profile_photos (
  id bigint unsigned auto_increment primary key,
  user_id char(36) not null,
  slot_index int not null,
  storage_path varchar(512) not null,
  url varchar(512) not null,
  created_at datetime not null default current_timestamp,
  updated_at datetime not null default current_timestamp on update current_timestamp,
  unique key profile_photos_user_slot_unique (user_id, slot_index),
  constraint profile_photos_user_id_fk foreign key (user_id) references users(id) on delete cascade,
  constraint profile_photos_slot_check check (slot_index between 0 and 5)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists account_deletion_requests (
  user_id char(36) primary key,
  requested_at datetime not null default current_timestamp,
  delete_after datetime not null,
  status enum('pending', 'cancelled', 'completed') not null default 'pending',
  created_at datetime not null default current_timestamp,
  updated_at datetime not null default current_timestamp on update current_timestamp,
  constraint account_deletion_requests_user_id_fk foreign key (user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists data_export_requests (
  id bigint unsigned auto_increment primary key,
  user_id char(36) not null,
  requested_at datetime not null default current_timestamp,
  status enum('pending', 'processing', 'completed', 'failed') not null default 'pending',
  created_at datetime not null default current_timestamp,
  updated_at datetime not null default current_timestamp on update current_timestamp,
  key data_export_requests_user_id_idx (user_id),
  constraint data_export_requests_user_id_fk foreign key (user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- Fixed-window brute-force protection buckets for credential endpoints.
-- Buckets are keyed like 'ip:<sha256-hash>:<path>' (IPs are never stored raw).
create table if not exists auth_rate_limits (
  bucket varchar(128) not null,
  window_start datetime not null,
  attempts int unsigned not null default 0,
  primary key (bucket, window_start),
  key auth_rate_limits_window_idx (window_start)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- AI SPEND LEDGER: one row per completed model call. The API sums this table
-- (per day, globally and per user) BEFORE making any model request, so the
-- configured daily caps are hard limits, not suggestions. Cost is stored in
-- whole US cents (estimated, rounded up).
create table if not exists ai_usage (
  id bigint unsigned auto_increment primary key,
  user_id char(36) not null,
  endpoint varchar(64) not null,
  model varchar(64) not null,
  cost_usd_cents int unsigned not null default 0,
  day date not null,
  created_at datetime not null default current_timestamp,
  key ai_usage_day_idx (day),
  key ai_usage_user_day_idx (user_id, day),
  constraint ai_usage_user_id_fk foreign key (user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists reports (
  id char(36) primary key,
  reporter_id char(36) not null,
  reported_user_id char(36) not null,
  reason enum('harassment', 'fake_profile', 'inappropriate_photos', 'scam', 'other') not null,
  details text null,
  status enum('pending', 'upheld', 'dismissed') not null default 'pending',
  resolved_by char(36) null,
  resolution_note text null,
  created_at datetime not null default current_timestamp,
  updated_at datetime not null default current_timestamp on update current_timestamp,
  key reports_status_idx (status, created_at),
  key reports_reporter_idx (reporter_id),
  key reports_reported_idx (reported_user_id),
  constraint reports_reporter_fk foreign key (reporter_id) references users(id) on delete cascade,
  constraint reports_reported_fk foreign key (reported_user_id) references users(id) on delete cascade,
  -- A moderator's account may be deleted; keep the resolver reference but
  -- null it out rather than deleting the audit trail.
  constraint reports_resolved_by_fk foreign key (resolved_by) references users(id) on delete set null
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table if not exists moderation_actions (
  id bigint unsigned auto_increment primary key,
  moderator_id char(36) not null,
  report_id char(36) null,
  target_user_id char(36) not null,
  action enum('warn', 'pause', 'ban', 'reinstate', 'dismiss') not null,
  note text null,
  created_at datetime not null default current_timestamp,
  key moderation_actions_target_idx (target_user_id, created_at),
  key moderation_actions_moderator_idx (moderator_id, created_at),
  constraint moderation_actions_moderator_fk foreign key (moderator_id) references users(id) on delete cascade,
  constraint moderation_actions_report_fk foreign key (report_id) references reports(id) on delete set null,
  constraint moderation_actions_target_fk foreign key (target_user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- SWIPES: one row per like/nope/super_like. A mutual pair of likes creates
-- a match row. Swipes are kept (not deleted) so a user cannot re-swipe the
-- same target infinitely and 'who liked me' can be answered efficiently.
create table if not exists swipes (
  id bigint unsigned auto_increment primary key,
  swiper_id char(36) not null,
  target_id char(36) not null,
  action enum('like', 'nope', 'super_like') not null,
  created_at datetime not null default current_timestamp,
  unique key swipes_swiper_target_unique (swiper_id, target_id),
  key swipes_target_action_idx (target_id, action, created_at),
  constraint swipes_swiper_fk foreign key (swiper_id) references users(id) on delete cascade,
  constraint swipes_target_fk foreign key (target_id) references users(id) on delete cascade,
  constraint swipes_no_self_swipe_check check (swiper_id <> target_id)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- MATCHES: created when two users like each other. Either side can unmatch,
-- which nulls their side; the row is only deleted when both sides unmatch or
-- an account is deleted.
create table if not exists matches (
  id char(36) primary key,
  user_a_id char(36) not null,
  user_b_id char(36) not null,
  -- 'a' or 'b': which side has unmatched (null = both active).
  unmatched_by enum('a', 'b') null,
  unmatched_at datetime null,
  created_at datetime not null default current_timestamp,
  unique key matches_pair_unique (user_a_id, user_b_id),
  key matches_user_a_idx (user_a_id, created_at),
  key matches_user_b_idx (user_b_id, created_at),
  constraint matches_user_a_fk foreign key (user_a_id) references users(id) on delete cascade,
  constraint matches_user_b_fk foreign key (user_b_id) references users(id) on delete cascade,
  constraint matches_distinct_users_check check (user_a_id <> user_b_id)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- MESSAGES: chat messages inside a match. Soft-deleted via deleted_at when a
-- user unmatches (conversation is hidden, audit trail remains).
create table if not exists messages (
  id char(36) primary key,
  seq bigint unsigned not null auto_increment,
  match_id char(36) not null,
  sender_id char(36) not null,
  body text not null,
  created_at datetime not null default current_timestamp,
  deleted_at datetime null,
  unique key messages_seq_unique (seq),
  key messages_match_seq_idx (match_id, seq),
  constraint messages_match_fk foreign key (match_id) references matches(id) on delete cascade,
  constraint messages_sender_fk foreign key (sender_id) references users(id) on delete cascade,
  constraint messages_body_len_check check (char_length(body) between 1 and 4000)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- BLOCKS: one row per blocking direction. A block by either side hides both
-- accounts from each other (discovery deck, likes, matches, profile lookups)
-- and stops swipes/messages between them. Reversible via unblock.
create table if not exists blocks (
  id bigint unsigned auto_increment primary key,
  blocker_id char(36) not null,
  blocked_id char(36) not null,
  created_at datetime not null default current_timestamp,
  unique key blocks_pair_unique (blocker_id, blocked_id),
  key blocks_blocked_idx (blocked_id),
  constraint blocks_blocker_fk foreign key (blocker_id) references users(id) on delete cascade,
  constraint blocks_blocked_fk foreign key (blocked_id) references users(id) on delete cascade,
  constraint blocks_no_self_block_check check (blocker_id <> blocked_id)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- Housekeeping: purge stale rows so these tables do not grow forever.
-- Kept as single-statement events so the file imports with the plain
-- mysql CLI (no DELIMITER juggling required).
create event if not exists sawalove_housekeeping_rate_limits
on schedule every 1 hour
do
  delete from auth_rate_limits where window_start < utc_timestamp() - interval 1 day;

create event if not exists sawalove_housekeeping_otps
on schedule every 1 hour
do
  delete from phone_otps where created_at < utc_timestamp() - interval 2 day;

create event if not exists sawalove_housekeeping_sessions
on schedule every 1 hour
do
  delete from sessions where expires_at < utc_timestamp() - interval 7 day;

create event if not exists sawalove_housekeeping_ai_usage
on schedule every 1 day
do
  delete from ai_usage where day < utc_date() - interval 90 day;

create event if not exists sawalove_housekeeping_swipes
on schedule every 1 day
do
  delete from swipes
  where action = 'nope'
    and created_at < utc_timestamp() - interval 90 day;

-- Push notification tokens (FCM registration tokens per device).
-- A user may be signed in on several devices; each device has its own token.
-- Stale tokens are replaced by the upsert on /me/push-token and pruned here
-- when the device never refreshes them (apps refresh on every launch).
create table if not exists push_tokens (
  token varchar(4096) not null,
  user_id char(36) not null,
  platform varchar(20) not null default 'android',
  created_at datetime not null default current_timestamp,
  last_seen_at datetime not null default current_timestamp,
  primary key token_pk (token(255)),
  key push_tokens_user_idx (user_id),
  constraint push_tokens_user_fk foreign key (user_id) references users(id) on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create event if not exists sawalove_housekeeping_push_tokens
on schedule every 1 day
do
  delete from push_tokens where last_seen_at < utc_timestamp() - interval 90 day;

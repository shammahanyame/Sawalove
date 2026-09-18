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

-- Housekeeping: purge stale rows so these tables do not grow forever.
-- Kept as three single-statement events so the file imports with the plain
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

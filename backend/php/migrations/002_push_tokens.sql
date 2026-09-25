-- Migration 002 — push notification tokens (FCM).
-- Apply to existing databases; fresh installs get this via schema.sql.

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

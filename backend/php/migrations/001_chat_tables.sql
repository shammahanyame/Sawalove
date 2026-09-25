-- Migration 001: likes, matches & messages (chat).
-- For databases created from an older schema.sql. Fresh installs do NOT need
-- this file — schema.sql already contains these tables.

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

create table if not exists matches (
  id char(36) primary key,
  user_a_id char(36) not null,
  user_b_id char(36) not null,
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

create event if not exists sawalove_housekeeping_swipes
on schedule every 1 day
do
  delete from swipes
  where action = 'nope'
    and created_at < utc_timestamp() - interval 90 day;

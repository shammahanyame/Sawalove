-- Migration 003 — user blocking.
-- Apply to existing databases; fresh installs get this via schema.sql.

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

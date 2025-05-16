
CREATE TABLE IF NOT EXISTS `rooms` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT NOT NULL,
	`password` TEXT NOT NULL,
	`host_user_id` INTEGER NOT NULL,
	`rules` TEXT NOT NULL,
	`chartmeta_key` TEXT NOT NULL,
	`replay_base` TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS `room_users` (
	`id` INTEGER PRIMARY KEY,
	`room_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`chart_found` INTEGER NOT NULL,
	`is_ready` INTEGER NOT NULL,
	`is_playing` INTEGER NOT NULL,
	`chartmeta_key` TEXT NOT NULL,
	`replay_base` TEXT NOT NULL,
	`chartplay_computed` TEXT NOT NULL
);

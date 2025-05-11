CREATE TABLE IF NOT EXISTS `users` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT NOT NULL,
	`email` TEXT NOT NULL,
	`password` TEXT NOT NULL,
	`description` TEXT NOT NULL,
	`latest_activity` INTEGER NOT NULL,
	`created_at` INTEGER NOT NULL,
	`is_banned` INTEGER NOT NULL,
	`chartplays_count` INTEGER NOT NULL,
	`chartmetas_count` INTEGER NOT NULL,
	`chartdiffs_count` INTEGER NOT NULL,
	`chartfiles_upload_size` INTEGER NOT NULL,
	`chartplays_upload_size` INTEGER NOT NULL,
	`play_time` INTEGER NOT NULL,
	`color_left` INTEGER,
	`color_right` INTEGER,
	`banner` TEXT,
	`discord` TEXT,
	`custom_link` TEXT,
	UNIQUE(`name`),
	UNIQUE(`email`)
);

CREATE TABLE IF NOT EXISTS `user_roles` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL,
	`role` INTEGER NOT NULL,
	`started_at` INTEGER NOT NULL,
	`expires_at` INTEGER,
	`total_time` INTEGER NOT NULL,
	UNIQUE(`user_id`, `role`)
);

CREATE TABLE IF NOT EXISTS `user_locations` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL,
	`ip` TEXT NOT NULL,
	`created_at` INTEGER NOT NULL,
	`updated_at` INTEGER NOT NULL,
	`is_register` INTEGER NOT NULL,
	`sessions_count` INTEGER NOT NULL,
	UNIQUE(`user_id`, `ip`)
);

CREATE TABLE IF NOT EXISTS `sessions` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL,
	`active` INTEGER NOT NULL,
	`ip` INTEGER NOT NULL,
	`created_at` INTEGER NOT NULL,
	`updated_at` INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS `chartfiles` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`size` INTEGER NOT NULL,
	`compute_state` INTEGER NOT NULL,
	`computed_at` INTEGER NOT NULL,
	`creator_id` INTEGER NOT NULL,
	`submitted_at` INTEGER NOT NULL,
	UNIQUE(`hash`)
);

CREATE TABLE IF NOT EXISTS `compute_processes` (
	`id` INTEGER PRIMARY KEY,
	`created_at` INTEGER NOT NULL,
	`completed_at` INTEGER,
	`state` INTEGER NOT NULL,
	`target` INTEGER NOT NULL,
	`current` INTEGER NOT NULL,
	`total` INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS `leaderboards` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT,
	`description` TEXT,
	`created_at` INTEGER,
	`rating_calc` INTEGER,
	`nearest` INTEGER,
	`pass` INTEGER,
	`judges` INTEGER,
	`allow_custom` INTEGER,
	`allow_const` INTEGER,
	`allow_pause` INTEGER,
	`allow_reorder` INTEGER,
	`allow_modifiers` INTEGER,
	`allow_tap_only` INTEGER,
	`allow_free_timings` INTEGER,
	`allow_free_healths` INTEGER,
	`timings` INTEGER,
	`healths` INTEGER,
	`starts_at` INTEGER,
	`ends_at` INTEGER,
	`mode` INTEGER,
	`rate` BLOB,
	`difftables` BLOB,
	`chartmeta_inputmode` BLOB,
	`chartdiff_inputmode` BLOB,
	UNIQUE(`name`)
);

CREATE TABLE IF NOT EXISTS `leaderboard_users` (
	`id` INTEGER PRIMARY KEY,
	`leaderboard_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`total_rating` REAL NOT NULL,
	`rank` INTEGER NOT NULL,
	`updated_at` INTEGER NOT NULL,
	UNIQUE(`leaderboard_id`, `user_id`)
);

CREATE TABLE IF NOT EXISTS `leaderboard_difftables` (
	`id` INTEGER PRIMARY KEY,
	`leaderboard_id` INTEGER,
	`difftable_id` INTEGER,
	UNIQUE(`leaderboard_id`, `difftable_id`)
);

CREATE TABLE IF NOT EXISTS `difftables` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT,
	`description` TEXT,
	`symbol` TEXT,
	`created_at` INTEGER,
	UNIQUE(`name`)
);

CREATE TABLE IF NOT EXISTS `difftable_chartmetas` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER,
	`difftable_id` INTEGER NOT NULL,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`level` REAL NOT NULL,
	`created_at` INTEGER,
	UNIQUE(`hash`, `index`, `difftable_id`)
);

CREATE TABLE IF NOT EXISTS `teams` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT,
	`alias` TEXT,
	`description` TEXT,
	`owner_id` INTEGER,
	`type` INTEGER,
	`users_count` INTEGER,
	`created_at` INTEGER,
	UNIQUE(`name`),
	UNIQUE(`alias`)
);

CREATE TABLE IF NOT EXISTS `team_users` (
	`id` INTEGER PRIMARY KEY,
	`team_id` INTEGER NOT NULL,
	`user_id` INTEGER NOT NULL,
	`is_accepted` INTEGER,
	`is_invitation` INTEGER,
	`created_at` INTEGER,
	UNIQUE(`team_id`, `user_id`)
);

CREATE TABLE `files` (
	`id` INTEGER PRIMARY KEY,
	`hash` BLOB NOT NULL,
	`name` TEXT NOT NULL DEFAULT '',
	`format` INTEGER NOT NULL,
	`storage` INTEGER NOT NULL,
	`uploaded` INTEGER NOT NULL DEFAULT 0,
	`size` INTEGER NOT NULL DEFAULT 0,
	`loaded` INTEGER NOT NULL DEFAULT 0,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	UNIQUE(`hash`)
);

CREATE TABLE `notecharts` (
	`id` INTEGER PRIMARY KEY,
	`file_id` INTEGER NOT NULL DEFAULT 0,
	`index` INTEGER NOT NULL,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	`is_complete` INTEGER NOT NULL DEFAULT 0,
	`is_valid` INTEGER NOT NULL DEFAULT 0,
	`scores_count` INTEGER NOT NULL DEFAULT 0,
	`inputmode` INTEGER NOT NULL,
	`difficulty` float NOT NULL DEFAULT 0,
	`song_title` text NOT NULL,
	`song_artist` text NOT NULL,
	`difficulty_name` text NOT NULL,
	`difficulty_creator` text NOT NULL,
	`level` INTEGER NOT NULL DEFAULT 0,
	`length` INTEGER NOT NULL DEFAULT 0,
	`notes_count` INTEGER NOT NULL DEFAULT 0,
	UNIQUE(`file_id`,`index`)
);

CREATE TABLE `scores` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL DEFAULT 0,
	`notechart_id` INTEGER NOT NULL DEFAULT 0,
	`modifierset_id` INTEGER NOT NULL DEFAULT 0,
	`file_id` INTEGER NOT NULL DEFAULT 0,
	`inputmode` INTEGER NOT NULL,
	`is_complete` INTEGER NOT NULL DEFAULT 0,
	`is_valid` INTEGER NOT NULL DEFAULT 0,
	`is_ranked` INTEGER NOT NULL DEFAULT 0,
	`is_top` INTEGER NOT NULL DEFAULT 0,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	`score` float NOT NULL DEFAULT 0,
	`accuracy` float NOT NULL DEFAULT 0,
	`max_combo` INTEGER NOT NULL DEFAULT 0,
	`misses_count` INTEGER NOT NULL DEFAULT 0,
	`difficulty` float NOT NULL DEFAULT 0,
	`rating` float NOT NULL DEFAULT 0,
	`rate` float NOT NULL DEFAULT 0,
	`const` INTEGER NOT NULL DEFAULT 0,
	UNIQUE(`file_id`)
);

CREATE TABLE `sessions` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL DEFAULT 0,
	`active` INTEGER NOT NULL DEFAULT 0,
	`ip` INTEGER NOT NULL DEFAULT 0,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	`updated_at` INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE `user_locations` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL DEFAULT 0,
	`ip` INTEGER NOT NULL DEFAULT 0,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	`updated_at` INTEGER NOT NULL DEFAULT 0,
	`is_register` INTEGER NOT NULL DEFAULT 0,
	`sessions_count` INTEGER NOT NULL DEFAULT 0,
	UNIQUE(`user_id`,`ip`)
);

CREATE TABLE `user_roles` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL DEFAULT 0,
	`role` INTEGER NOT NULL,
	`expires_at` INTEGER NOT NULL DEFAULT 0,
	`total_time` INTEGER NOT NULL DEFAULT 0,
	UNIQUE(`user_id`,`role`)
);

CREATE TABLE `users` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT NOT NULL DEFAULT '',
	`email` TEXT NOT NULL,
	`password` TEXT NOT NULL DEFAULT '',
	`latest_activity` INTEGER NOT NULL DEFAULT 0,
	`latest_score_submitted_at` INTEGER NOT NULL DEFAULT 0,
	`created_at` INTEGER NOT NULL DEFAULT 0,
	`is_banned` INTEGER NOT NULL DEFAULT 0,
	`is_restricted_info` INTEGER NOT NULL DEFAULT 0,
	`description` TEXT NOT NULL DEFAULT '',
	`scores_count` INTEGER NOT NULL DEFAULT 0,
	`notecharts_count` INTEGER NOT NULL DEFAULT 0,
	`notes_count` INTEGER NOT NULL DEFAULT 0,
	`notecharts_upload_size` INTEGER NOT NULL DEFAULT 0,
	`replays_upload_size` INTEGER NOT NULL DEFAULT 0,
	`play_time` INTEGER NOT NULL DEFAULT 0,
	`color_left` INTEGER NOT NULL DEFAULT 0,
	`color_right` INTEGER NOT NULL DEFAULT 0,
	`banner` TEXT NOT NULL DEFAULT '',
	`discord` TEXT NOT NULL DEFAULT '',
	`twitter` TEXT NOT NULL DEFAULT '',
	`custom_link` TEXT NOT NULL DEFAULT '',
	UNIQUE(`name`),
	UNIQUE(`email`)
);

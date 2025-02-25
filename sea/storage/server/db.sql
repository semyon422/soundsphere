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
	`color_left` INTEGER NOT NULL,
	`color_right` INTEGER NOT NULL,
	`banner` TEXT NOT NULL,
	`discord` TEXT NOT NULL,
	`custom_link` TEXT NOT NULL,
	UNIQUE(`name`),
	UNIQUE(`email`)
);

CREATE TABLE IF NOT EXISTS `chartfiles` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`size` INTEGER NOT NULL,
	`compute_state` INTEGER NOT NULL,
	`creator_id` INTEGER NOT NULL,
	`submitted_at` INTEGER NOT NULL,
	UNIQUE(`hash`)
);

CREATE TABLE IF NOT EXISTS `chartmetas` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`timings` INTEGER,
	`healths` INTEGER,
	`title` TEXT,
	`title_unicode` TEXT,
	`artist` TEXT,
	`artist_unicode` TEXT,
	`name` TEXT,
	`creator` TEXT,
	`level` REAL,
	`inputmode` TEXT,
	`source` TEXT,
	`tags` TEXT,
	`format` TEXT,
	`audio_path` TEXT,
	`background_path` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
	`osu_od` REAL,
	`osu_hp` REAL,
	`osu_ranked_status` INTEGER,
	`tempo` REAL,
	`duration` REAL,
	`has_video` INTEGER,
	`has_storyboard` INTEGER,
	`has_subtitles` INTEGER,
	`has_negative_speed` INTEGER,
	`has_stacked_notes` INTEGER,
	`breaks_count` INTEGER,
	`played_at` INTEGER,
	`added_at` INTEGER,
	`created_at` INTEGER,
	`plays_count` INTEGER,
	`pitch` REAL,
	`audio_channels` INTEGER,
	`used_columns` INTEGER,
	`comment` TEXT,
	`chart_preview` TEXT,
	UNIQUE(`hash`, `index`)
);

CREATE INDEX IF NOT EXISTS chartmetas_inputmode_idx ON chartmetas (`inputmode`);

CREATE TABLE IF NOT EXISTS `chartdiffs` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`modifiers` TEXT NOT NULL,
	`rate` INTEGER NOT NULL,
	`rate_type` INTEGER NOT NULL DEFAULT 0,
	`mode` INTEGER NOT NULL,
	`notes_hash` TEXT,
	`inputmode` TEXT,
	`notes_count` INTEGER,
	`judges_count` INTEGER,
	`note_types_count` TEXT,
	`density_data` TEXT,
	`sv_data` TEXT,
	`enps_diff` REAL,
	`osu_diff` REAL,
	`msd_diff` REAL,
	`msd_diff_data` TEXT,
	`user_diff` REAL,
	`user_diff_data` TEXT,
	UNIQUE(`hash`, `index`, `modifiers`, `rate`)
);

CREATE INDEX IF NOT EXISTS chartdiffs_inputmode_idx ON chartdiffs (`inputmode`);
CREATE INDEX IF NOT EXISTS chartdiffs_enps_idx ON chartdiffs (`enps_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_osu_idx ON chartdiffs (`osu_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_msd_idx ON chartdiffs (`msd_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_user_idx ON chartdiffs (`user_diff`);

CREATE TABLE IF NOT EXISTS `chartplays` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER,
	`events_hash` TEXT NOT NULL DEFAULT "",
	`notes_hash` TEXT NOT NULL DEFAULT "",
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`modifiers` TEXT NOT NULL,
	`custom` INTEGER NOT NULL DEFAULT 0,
	`rate` INTEGER NOT NULL,
	`rate_type` INTEGER NOT NULL DEFAULT 0,
	`mode` INTEGER,
	`const` INTEGER,
	`nearest` INTEGER,
	`tap_only` INTEGER,
	`timings` INTEGER,
	`healths` INTEGER,
	`columns_order` BLOB,
	`created_at` INTEGER,
	`submitted_at` INTEGER,
	`computed_at` INTEGER,
	`compute_state` INTEGER,
	`pause_count` INTEGER,
	`result` INTEGER,
	`judges` BLOB,
	`accuracy` REAL,
	`max_combo` INTEGER,
	`perfect_count` INTEGER,
	`miss_count` INTEGER,
	`rating` REAL,
	`accuracy_osu` REAL,
	`accuracy_etterna` REAL,
	`rating_pp` REAL,
	`rating_msd` REAL
);

CREATE INDEX IF NOT EXISTS chartplays_user_id_idx ON chartplays (`user_id`);
CREATE INDEX IF NOT EXISTS chartplays_himr_idx ON chartplays (`hash`, `index`, `modifiers`, `rate`);

CREATE TABLE IF NOT EXISTS `leaderboards` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT,
	`description` TEXT,
	`created_at` INTEGER,
	`rating_calc` INTEGER,
	`scores_comb` INTEGER,
	`scores_comb_count` INTEGER,
	`nearest` INTEGER,
	`result` INTEGER,
	`allow_custom` INTEGER,
	`allow_const` INTEGER,
	`allow_pause` INTEGER,
	`allow_reorder` INTEGER,
	`allow_modifiers` INTEGER,
	`allow_tap_only` INTEGER,
	`allow_free_timings` INTEGER,
	`allow_free_healths` INTEGER,
	`mode` INTEGER,
	`rate` BLOB,
	`difftables` BLOB,
	`chartmeta_inputmode` BLOB,
	`chartdiff_inputmode` BLOB,
	UNIQUE(`name`)
);

CREATE TABLE IF NOT EXISTS `leaderboard_users` (
	`id` INTEGER PRIMARY KEY,
	`leaderboard_id` INTEGER,
	`user_id` INTEGER,
	`total_rating` REAL,
	`rank` INTEGER,
	`updated_at` INTEGER,
	UNIQUE(`leaderboard_id`, `user_id`)
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

CREATE TEMP VIEW IF NOT EXISTS `chartplayviews` AS
SELECT
chartplays.id AS chartplay_id,
chartdiffs.id AS chartdiff_id,
chartmetas.id AS chartmeta_id,
difftable_chartmetas.difftable_id AS difftable_id,
difftable_chartmetas.level AS difftable_level,
chartmetas.level AS chartmeta_level,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.inputmode AS chartmeta_inputmode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.notes_count,
chartplays.*
FROM chartplays
LEFT JOIN chartmetas ON
chartmetas.hash = chartplays.hash
LEFT JOIN chartdiffs ON
chartdiffs.hash = chartplays.hash AND
chartdiffs.`index` = chartplays.`index` AND
chartdiffs.mode = chartplays.mode AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
LEFT JOIN difftable_chartmetas ON
difftable_chartmetas.hash = chartplays.hash
;

CREATE TEMP VIEW IF NOT EXISTS `leaderboard_users_ranked` AS
SELECT
ROW_NUMBER() OVER (PARTITION BY leaderboard_id ORDER BY total_rating DESC) row_number,
leaderboard_users.*
FROM leaderboard_users
;

CREATE TABLE IF NOT EXISTS `chartfiles` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT NOT NULL,
	`hash` TEXT,
	`set_id` INTEGER NOT NULL,
	`modified_at` INTEGER NOT NULL,
	`size` INTEGER,
	FOREIGN KEY (set_id) REFERENCES chartfile_sets(id) ON DELETE CASCADE,
	UNIQUE(`set_id`, `name`)
);

CREATE INDEX IF NOT EXISTS chartfiles_hash_idx ON chartfiles (`hash`);

CREATE TABLE IF NOT EXISTS `chartfile_sets` (
	`id` INTEGER PRIMARY KEY,
	`dir` TEXT,
	`name` TEXT NOT NULL,
	`modified_at` INTEGER NOT NULL,
	`is_file` INTEGER NOT NULL,
	`location_id` INTEGER NOT NULL,
	FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE,
	UNIQUE(`location_id`, `dir`, `name`)
);

CREATE TABLE IF NOT EXISTS `locations` (
	`id` INTEGER PRIMARY KEY,
	`path` TEXT UNIQUE,
	`name` TEXT NOT NULL,
	`is_relative` INTEGER NOT NULL,
	`is_internal` INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS `chartmetas` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`title` TEXT,
	`artist` TEXT,
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
	`modifiers` TEXT NOT NULL DEFAULT "",
	`rate` INTEGER NOT NULL DEFAULT 1000,

	`rate_type` INTEGER NOT NULL DEFAULT 0,

	`inputmode` TEXT,
	`notes_count` INTEGER,
	`long_notes_count` INTEGER,
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

CREATE TABLE IF NOT EXISTS `scores` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`modifiers` TEXT NOT NULL DEFAULT "",
	`rate` INTEGER NOT NULL DEFAULT 1000,

	`rate_type` INTEGER NOT NULL DEFAULT 0,

	`const` INTEGER,
	`timings` TEXT,
	`single` INTEGER,

	`time` INTEGER,
	`accuracy` REAL,
	`max_combo` INTEGER,
	`replay_hash` TEXT,
	`ratio` REAL,
	`perfect` INTEGER,
	`not_perfect` INTEGER,
	`miss` INTEGER,
	`mean` REAL,
	`earlylate` REAL,
	`pauses` INTEGER
);

CREATE INDEX IF NOT EXISTS scores_himr_idx ON scores (`hash`, `index`, `modifiers`, `rate`);

CREATE TABLE IF NOT EXISTS `collections` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT
);

CREATE TABLE IF NOT EXISTS `chart_collections` (
	`id` INTEGER PRIMARY KEY,
	`collection_id` INTEGER,
	`chartdiff_id` INTEGER
);

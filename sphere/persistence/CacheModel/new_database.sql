CREATE TABLE IF NOT EXISTS `chartfiles` (
	`id` INTEGER PRIMARY KEY,
	`dir` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`status` INTEGER NOT NULL,
	`hash` TEXT,
	`chartfile_set_id` INTEGER,
	`modified_at` INTEGER,
	`size` INTEGER,
	UNIQUE(`dir`, `name`)
);

CREATE TABLE IF NOT EXISTS `chartfile_sets` (
	`id` INTEGER PRIMARY KEY,
	`dir` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`status` INTEGER NOT NULL DEFAULT 0,
	`chart_files_count` INTEGER NOT NULL DEFAULT 0,
	`modified_at` INTEGER NOT NULL,
	UNIQUE(`dir`, `name`)
);

CREATE TABLE IF NOT EXISTS `charts` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`title` TEXT,
	`artist` TEXT,
	`name` TEXT,
	`creator` TEXT,
	`level` REAL,
	`input_mode` TEXT,
	`source` TEXT,
	`tags` TEXT,
	`audio` TEXT,
	`background` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
	`osu_ranked_status` INTEGER,
	`tempo` REAL,
	-- `min_max_avg_tempo` REAL,
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
	`chart_preview` TEXT
);

CREATE TABLE IF NOT EXISTS `chart_difficulty` (
	`id` INTEGER PRIMARY KEY,
	`input_mode` TEXT,
	`notes_count` INTEGER,
	`long_notes_count` INTEGER,
	`density_data` TEXT,
	`sv_data` TEXT,
	`enps_difficulty` REAL,
	`osu_difficulty` REAL,
	`msd_difficulty` REAL,
	`msd_difficulty_data` REAL
)

CREATE TABLE IF NOT EXISTS `play_configs` (
	`id` INTEGER PRIMARY KEY,
	`modifiers` TEXT,
	`rate` REAL,
	`const` INTEGER,
	`timings` TEXT,
	`single` INTEGER
)

CREATE TABLE IF NOT EXISTS `chart_play_presets` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`play_config_id` INTEGER,
	`chart_difficulty_id` INTEGER
)

CREATE TABLE IF NOT EXISTS `collections` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT
)

CREATE TABLE IF NOT EXISTS `chart_collections` (
	`id` INTEGER PRIMARY KEY,
	`collection_id` INTEGER,
	`chart_play_preset_id` INTEGER,
)

CREATE TABLE IF NOT EXISTS `chart_plays` (  -- scores
	`id` INTEGER PRIMARY KEY,
	`chart_play_preset_id` INTEGER,
	`is_top` REAL DEFAULT 0,
	`time` REAL,
	`accuracy` REAL,
	`max_combo` REAL,
	`replay_hash` TEXT,
	`ratio` REAL,
	`perfect` REAL,
	`not_perfect` REAL,
	`miss` REAL,
	`mean` REAL,
	`earlylate` REAL,
	`pauses` REAL
)

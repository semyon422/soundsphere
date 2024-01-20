CREATE TABLE IF NOT EXISTS `chartfiles` (
	`id` INTEGER PRIMARY KEY,
	`dir` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`hash` TEXT,
	`set_id` INTEGER NOT NULL,
	`modified_at` INTEGER NOT NULL,
	`size` INTEGER,
	UNIQUE(`dir`, `name`)
);

CREATE INDEX IF NOT EXISTS chartfiles_hash_idx ON chartfiles (`hash`);
CREATE INDEX IF NOT EXISTS chartfiles_set_id_idx ON chartfiles (`set_id`);

CREATE TABLE IF NOT EXISTS `chartfile_sets` (
	`id` INTEGER PRIMARY KEY,
	`dir` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`status` INTEGER NOT NULL DEFAULT 0,
	`modified_at` INTEGER NOT NULL,
	UNIQUE(`dir`, `name`)
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
	`audio` TEXT,
	`background` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
	`osu_ranked_status` INTEGER,
	`tempo` REAL,
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

CREATE INDEX IF NOT EXISTS chartmetas_inputmode_idx ON chartmetas (`inputmode`);
CREATE INDEX IF NOT EXISTS chartmetas_name_idx ON chartmetas (`name`);

CREATE TABLE IF NOT EXISTS `chart_difficulty` (
	`id` INTEGER PRIMARY KEY,
	`inputmode` TEXT,
	`notes_count` INTEGER,
	`long_notes_count` INTEGER,
	`density_data` TEXT,
	`sv_data` TEXT,
	`enps_difficulty` REAL,
	`osu_difficulty` REAL,
	`msd_difficulty` REAL,
	`msd_difficulty_data` TEXT
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

CREATE TEMP VIEW IF NOT EXISTS chartset_list AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
scores.id AS score_id,
chartfiles.set_id AS chartfile_set_id,
chartfiles.dir || "/" || chartfiles.name AS path,
scores.accuracy,
scores.miss,
chartmetas.*
FROM chartmetas
INNER JOIN chartfiles ON chartmetas.hash = chartfiles.hash
LEFT JOIN scores ON
chartmetas.hash = scores.chart_hash AND
chartmetas.`index` = scores.chart_index AND
scores.is_top = TRUE;

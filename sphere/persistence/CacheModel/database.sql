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
	`format` TEXT,
	`audio_path` TEXT,
	`background_path` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
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
	`chart_preview` TEXT
);

CREATE INDEX IF NOT EXISTS chartmetas_inputmode_idx ON chartmetas (`inputmode`);
CREATE INDEX IF NOT EXISTS chartmetas_name_idx ON chartmetas (`name`);

CREATE TABLE IF NOT EXISTS `chartdiffs` (
	`id` INTEGER PRIMARY KEY,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`modifiers` TEXT,
	`rate` REAL DEFAULT 1.0,

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

CREATE TABLE IF NOT EXISTS `scores` (
	`id` INTEGER PRIMARY KEY,
	`chartdiff_id` INTEGER,
	`const` INTEGER,
	`timings` TEXT,
	`single` INTEGER,

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
);

CREATE TABLE IF NOT EXISTS `collections` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT
);

CREATE TABLE IF NOT EXISTS `chart_collections` (
	`id` INTEGER PRIMARY KEY,
	`collection_id` INTEGER,
	`chartdiff_id` INTEGER
);

CREATE TEMP VIEW IF NOT EXISTS chartset_list AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
scores.id AS score_id,
chartfiles.set_id AS chartfile_set_id,
chartfiles.dir || "/" || chartfiles.name AS path,
scores.accuracy,
scores.miss,
chartmetas.*,
chartdiffs.notes_count,
chartdiffs.long_notes_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.user_diff,
chartdiffs.user_diff_data
FROM chartmetas
INNER JOIN chartfiles ON
chartmetas.hash = chartfiles.hash
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
LEFT JOIN scores ON
chartdiffs.id = scores.chartdiff_id AND
scores.is_top = TRUE
WHERE
chartdiffs.modifiers IS NULL AND
chartdiffs.rate IS 1.0
;

CREATE TEMP VIEW IF NOT EXISTS scores_list AS
SELECT
scores.id AS score_id,
scores.*,
chartdiffs.enps_diff AS difficulty,
chartdiffs.hash,
chartdiffs.`index`,
chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.inputmode,
chartdiffs.notes_count,
chartdiffs.long_notes_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.user_diff,
chartdiffs.user_diff_data
FROM scores
LEFT JOIN chartdiffs ON
scores.chartdiff_id = chartdiffs.id
;

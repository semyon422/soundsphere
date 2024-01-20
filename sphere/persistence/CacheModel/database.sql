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

CREATE INDEX IF NOT EXISTS chartfiles_hash_idx ON chartfiles (`hash`);
CREATE INDEX IF NOT EXISTS chartfiles_set_id_idx ON chartfiles (`set_id`);
CREATE INDEX IF NOT EXISTS chartmetas_input_mode_idx ON chartmetas (`input_mode`);
CREATE INDEX IF NOT EXISTS chartmetas_name_idx ON chartmetas (`name`);

CREATE TEMP VIEW IF NOT EXISTS chartset_list AS

SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
scores.id AS score_id,
chartfiles.set_id,
chartfiles.dir || "/" || chartfiles.name as path,
scores.accuracy,
scores.miss,
chartmetas.*

FROM chartmetas
INNER JOIN chartfiles ON chartmetas.hash = chartfiles.hash
LEFT JOIN scores ON
chartmetas.hash = scores.chart_hash AND
chartmetas.`index` = scores.chart_index AND
scores.is_top = TRUE;

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
	`created_at` INTEGER,
	`osu_ranked_status` INTEGER,

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
	`format` INTEGER,
	`audio_path` TEXT,
	`background_path` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
	`tempo` REAL,
	`tempo_avg` REAL,
	`tempo_max` REAL,
	`tempo_min` REAL
);

CREATE INDEX IF NOT EXISTS chartmetas_hash_idx ON chartmetas (`hash`);
CREATE UNIQUE INDEX IF NOT EXISTS chartmetas_hash_index_idx ON chartmetas (`hash`, `index`);
CREATE INDEX IF NOT EXISTS chartmetas_inputmode_idx ON chartmetas (`inputmode`);

CREATE TABLE IF NOT EXISTS `chartdiffs` (
	`id` INTEGER PRIMARY KEY,
	`custom_user_id` INTEGER,
	`created_at` INTEGER,

	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`modifiers` TEXT NOT NULL,
	`rate` INTEGER NOT NULL,
	`mode` INTEGER NOT NULL,

	`inputmode` TEXT,
	`duration` REAL,
	`start_time` REAL,
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
	`notes_preview` BLOB
);

CREATE INDEX IF NOT EXISTS chartdiffs_hi_idx ON chartdiffs (`hash`, `index`);
CREATE INDEX IF NOT EXISTS chartdiffs_himr_idx ON chartdiffs (`hash`, `index`, `modifiers`, `rate`);
CREATE UNIQUE INDEX IF NOT EXISTS chartdiffs_himrmc_idx ON chartdiffs (`hash`, `index`, `modifiers`, `rate`, `mode`, `custom_user_id`);
CREATE INDEX IF NOT EXISTS chartdiffs_inputmode_idx ON chartdiffs (`inputmode`);
CREATE INDEX IF NOT EXISTS chartdiffs_enps_idx ON chartdiffs (`enps_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_osu_idx ON chartdiffs (`osu_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_msd_idx ON chartdiffs (`msd_diff`);
CREATE INDEX IF NOT EXISTS chartdiffs_user_idx ON chartdiffs (`user_diff`);

CREATE TABLE IF NOT EXISTS `chartplays` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER,
	`compute_state` INTEGER,
	`submitted_at` INTEGER,
	`computed_at` INTEGER,

	`replay_hash` TEXT,
	`pause_count` INTEGER,
	`created_at` INTEGER,

	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,

	`modifiers` TEXT NOT NULL,
	`rate` INTEGER NOT NULL,
	`mode` INTEGER,

	`nearest` INTEGER,
	`tap_only` INTEGER,
	`timings` INTEGER,
	`subtimings` INTEGER,
	`healths` INTEGER,
	`columns_order` BLOB,

	`custom` INTEGER,
	`const` INTEGER,
	`rate_type` INTEGER,

	`judges` BLOB,
	`accuracy` REAL,
	`max_combo` INTEGER,
	`miss_count` INTEGER,
	`not_perfect_count` INTEGER,
	`pass` INTEGER,
	`rating` REAL,
	`rating_pp` REAL,
	`rating_msd` REAL
);

CREATE INDEX IF NOT EXISTS chartplays_himr_idx ON chartplays (`hash`, `index`, `modifiers`, `rate`);
CREATE INDEX IF NOT EXISTS chartplays_himrm_idx ON chartplays (`hash`, `index`, `modifiers`, `rate`, `mode`);

CREATE TABLE IF NOT EXISTS `collections` (
	`id` INTEGER PRIMARY KEY,
	`name` TEXT
);

CREATE TABLE IF NOT EXISTS `chart_collections` (
	`id` INTEGER PRIMARY KEY,
	`collection_id` INTEGER,
	`chartdiff_id` INTEGER
);

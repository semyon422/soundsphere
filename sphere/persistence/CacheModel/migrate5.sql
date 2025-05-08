CREATE TABLE IF NOT EXISTS `chartmetas_new` (
	`id` INTEGER PRIMARY KEY,
	`created_at` INTEGER,
	`computed_at` INTEGER,
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
	`audio_offset` REAL,
	`background_path` TEXT,
	`preview_time` REAL,
	`osu_beatmap_id` INTEGER,
	`osu_beatmapset_id` INTEGER,
	`tempo` REAL,
	`tempo_avg` REAL,
	`tempo_max` REAL,
	`tempo_min` REAL
);

INSERT INTO chartmetas_new (
`id`,
`created_at`,
`osu_ranked_status`,
`hash`,
`index`,
`timings`,
`healths`,
`title`,
`title_unicode`,
`artist`,
`artist_unicode`,
`name`,
`creator`,
`level`,
`inputmode`,
`source`,
`tags`,
`format`,
`audio_path`,
`audio_offset`,
`background_path`,
`preview_time`,
`osu_beatmap_id`,
`osu_beatmapset_id`,
`tempo`,
`tempo_avg`,
`tempo_max`,
`tempo_min`
)
SELECT
`id`,
NULL,
NULL,
`hash`,
`index`,
NULL,
NULL,
`title`,
`title`,
`artist`,
`artist`,
`name`,
`creator`,
`level`,
`inputmode`,
`source`,
`tags`,
NULL,
`audio_path`,
`audio_offset`,
`background_path`,
`preview_time`,
`osu_beatmap_id`,
`osu_beatmapset_id`,
`tempo`,
NULL,
NULL,
NULL
FROM chartmetas;

DROP TABLE chartmetas;

ALTER TABLE chartmetas_new RENAME TO chartmetas;

CREATE INDEX IF NOT EXISTS chartmetas_hash_idx ON chartmetas (`hash`);
CREATE UNIQUE INDEX IF NOT EXISTS chartmetas_hash_index_idx ON chartmetas (`hash`, `index`);
CREATE INDEX IF NOT EXISTS chartmetas_inputmode_idx ON chartmetas (`inputmode`);


CREATE TABLE IF NOT EXISTS `chartdiffs_new` (
	`id` INTEGER PRIMARY KEY,
	`custom_user_id` INTEGER,
	`created_at` INTEGER,
	`computed_at` INTEGER,

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

INSERT INTO chartdiffs_new (
`id`,
`hash`,
`index`,
`modifiers`,
`rate`,
`mode`,
`inputmode`,
`duration`,
`start_time`,
`notes_count`,
`judges_count`,
`note_types_count`,
`density_data`,
`sv_data`,
`enps_diff`,
`osu_diff`,
`msd_diff`,
`msd_diff_data`,
`user_diff`,
`user_diff_data`,
`notes_preview`
)
SELECT
`id`,
`hash`,
`index`,
`modifiers`,
`rate`,
0,
`inputmode`,
NULL,
NULL,
`notes_count`,
NULL,
NULL,
`density_data`,
`sv_data`,
`enps_diff`,
`osu_diff`,
`msd_diff`,
`msd_diff_data`,
`user_diff`,
`user_diff_data`,
`notes_preview`
FROM chartdiffs;

DROP TABLE chartdiffs;

ALTER TABLE chartdiffs_new RENAME TO chartdiffs;

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

INSERT INTO chartplays (
`id`,
`replay_hash`,
`pause_count`,
`created_at`,
`hash`,
`index`,
`modifiers`,
`rate`,
`mode`,
`const`,
`rate_type`,
`accuracy`,
`max_combo`,
`not_perfect_count`,
`miss_count`
)
SELECT
`id`,
`replay_hash`,
`pauses`,
`time`,
`hash`,
`index`,
`modifiers`,
`rate`,
`single`,
`const`,
`rate_type`,
`accuracy`,
`max_combo`,
`not_perfect`,
`miss`
FROM scores;

DROP INDEX scores_himr_idx;
DROP TABLE scores;

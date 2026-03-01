CREATE TEMP VIEW IF NOT EXISTS located_chartfiles AS
SELECT
chartmetas.id AS chartmeta_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfiles.name AS chartfile_name,
chartfiles.*
FROM chartfiles
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
;

CREATE TEMP VIEW IF NOT EXISTS chartmetas_diffs_missing AS
SELECT
chartmetas.id,
chartmetas.hash,
chartmetas.`index`
FROM chartmetas
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = '' AND
chartdiffs.rate = 1000
WHERE
chartdiffs.id IS NULL
;

CREATE TEMP VIEW IF NOT EXISTS chartviews AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
MAX(chartplays.id) AS chartplay_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = '' AND
chartdiffs.rate = 1000
LEFT JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index`
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id
;

CREATE TEMP VIEW IF NOT EXISTS chartviews_no_preview AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
MAX(chartplays.id) AS chartplay_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = '' AND
chartdiffs.rate = 1000
LEFT JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index`
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id
;

CREATE TEMP VIEW IF NOT EXISTS chartdiffviews AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
MAX(chartplays.id) AS chartplay_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
LEFT JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index` AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate AND
chartdiffs.mode = chartplays.mode
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id
;

CREATE TEMP VIEW IF NOT EXISTS chartdiffviews_no_preview AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
MAX(chartplays.id) AS chartplay_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
LEFT JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index` AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate AND
chartdiffs.mode = chartplays.mode
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id
;

CREATE TEMP VIEW IF NOT EXISTS chartplayviews AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
chartplays.id AS chartplay_id,

chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,

chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,

chartplays.accuracy AS accuracy,
chartplays.miss_count AS miss_count,
chartplays.created_at AS chartplay_created_at,

chartplays.nearest,
chartplays.tap_only,
chartplays.timings,
chartplays.subtimings,
chartplays.healths,
chartplays.columns_order,
chartplays.custom,
chartplays.const,
chartplays.rate_type,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
INNER JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index` AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id,
chartplay_id
;

CREATE TEMP VIEW IF NOT EXISTS chartplayviews_no_preview AS
SELECT
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id,
chartplays.id AS chartplay_id,
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at,
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash,

chartplays.accuracy AS accuracy,
chartplays.miss_count AS miss_count,
chartplays.created_at AS chartplay_created_at,

chartplays.nearest,
chartplays.tap_only,
chartplays.timings,
chartplays.subtimings,
chartplays.healths,
chartplays.columns_order,
chartplays.custom,
chartplays.const,
chartplays.rate_type,

chartmetas.`index`,

chartmetas.inputmode,
chartmetas.format,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.title,
chartmetas.title_unicode,
chartmetas.artist,
chartmetas.artist_unicode,
chartmetas.name,
chartmetas.creator,
chartmetas.level,
chartmetas.source,
chartmetas.tags,
chartmetas.audio_path,
chartmetas.audio_offset,
chartmetas.background_path,
chartmetas.preview_time,
chartmetas.osu_beatmap_id,
chartmetas.osu_beatmapset_id,
chartmetas.tempo,
chartmetas.tempo_avg,
chartmetas.tempo_max,
chartmetas.tempo_min,

chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment,

chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
INNER JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index` AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id,
chartplay_id
;

CREATE TEMP VIEW IF NOT EXISTS chartplays_list AS
SELECT
chartplays.id AS chartplay_id,
chartplays.*,
chartmetas.id AS chartmeta_id,
chartdiffs.id AS chartdiff_id,
chartdiffs.enps_diff AS difficulty,
chartdiffs.hash,
chartdiffs.`index`,
chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.msd_diff_rates,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartplays
LEFT JOIN chartdiffs ON
chartplays.hash = chartdiffs.hash AND
chartplays.`index` = chartdiffs.`index` AND
chartplays.modifiers = chartdiffs.modifiers AND
chartplays.rate = chartdiffs.rate
LEFT JOIN chartmetas ON
chartplays.hash = chartmetas.hash AND
chartplays.`index` = chartmetas.`index`
;

CREATE TEMP VIEW IF NOT EXISTS chartplays_computable AS
SELECT DISTINCT
chartplays.*
FROM chartplays
INNER JOIN chartfiles ON
chartplays.hash = chartfiles.hash
;

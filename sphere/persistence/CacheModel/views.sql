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
chartdiffs.modifiers = "" AND
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
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = "" AND
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
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = "" AND
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
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
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
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
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
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
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
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at,
chartmetas.*,
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
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
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
SELECT
chartplays.*
FROM chartplays
INNER JOIN chartfiles ON
chartplays.hash = chartfiles.hash
;

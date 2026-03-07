local QueryFragments = {}

QueryFragments.FIELDS_IDS = [[
chartmetas.id AS chartmeta_id,
chartfiles.id AS chartfile_id,
chartdiffs.id AS chartdiff_id,
chartfiles.set_id AS chartfile_set_id
]]

QueryFragments.FIELDS_CHARTFILE_SET = [[
chartfile_sets.location_id,
chartfile_sets.is_file AS set_is_file,
chartfile_sets.dir AS set_dir,
chartfile_sets.name AS set_name,
chartfile_sets.modified_at AS set_modified_at
]]

QueryFragments.FIELDS_CHARTFILE = [[
chartfiles.name AS chartfile_name,
chartfiles.modified_at,
chartfiles.hash
]]

QueryFragments.FIELDS_CHARTMETA = [[
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
chartmetas.tempo_min
]]

QueryFragments.FIELDS_CHARTMETA_USER_DATA = [[
chartmeta_user_datas.local_offset as chartmeta_local_offset,
chartmeta_user_datas.rating as chartmeta_rating,
chartmeta_user_datas.comment as chartmeta_comment
]]

QueryFragments.FIELDS_CHARTDIFF = [[
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
chartdiffs.user_diff_data
]]

QueryFragments.FIELDS_CHARTDIFF_PREVIEW = [[
chartdiffs.notes_preview
]]

QueryFragments.FIELDS_CHARTPLAY = [[
chartplays.nearest,
chartplays.tap_only,
chartplays.timings,
chartplays.subtimings,
chartplays.healths,
chartplays.columns_order,
chartplays.custom,
chartplays.const,
chartplays.rate_type
]]

QueryFragments.FIELDS_CHARTPLAY_STAT = [[
chartplays.id AS chartplay_id,
chartplays.accuracy AS accuracy,
chartplays.miss_count AS miss_count,
chartplays.created_at AS chartplay_created_at
]]

QueryFragments.FIELDS_CHARTPLAY_AGGREGATED = [[
MAX(chartplays.id) AS chartplay_id,
MIN(chartplays.accuracy) AS accuracy,
MIN(chartplays.miss_count) AS miss_count,
MAX(chartplays.created_at) AS chartplay_created_at
]]

QueryFragments.JOINS_CHARTFILES_METAS_SETS = [[
FROM chartfiles
LEFT JOIN chartmetas ON
chartfiles.hash = chartmetas.hash
LEFT JOIN chartmeta_user_datas ON
chartmetas.hash = chartmeta_user_datas.hash AND
chartmetas.`index` = chartmeta_user_datas.`index`
INNER JOIN chartfile_sets ON
chartfiles.set_id = chartfile_sets.id
]]

QueryFragments.JOINS_CHARTDIFF = [[
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index`
]]

QueryFragments.JOINS_CHARTDIFF_DEFAULT = QueryFragments.JOINS_CHARTDIFF .. [[
AND chartdiffs.modifiers = '' AND
chartdiffs.rate = 1000
]]

QueryFragments.JOINS_CHARTPLAY = [[
LEFT JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index`
]]

QueryFragments.JOINS_CHARTPLAY_BY_MODS = QueryFragments.JOINS_CHARTPLAY .. [[
AND chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
]]

QueryFragments.JOINS_CHARTPLAY_BY_MODE = QueryFragments.JOINS_CHARTPLAY_BY_MODS .. [[
AND chartdiffs.mode = chartplays.mode
]]

return QueryFragments

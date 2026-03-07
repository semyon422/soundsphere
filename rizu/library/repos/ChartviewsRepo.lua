local thread = require("thread")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local ffi = require("ffi")
local class = require("class")
local QueryFragments = require("rizu.library.sql.QueryFragments")
local Model = require("rdb.Model")
local chartview_base = require("rizu.library.models.chartview_base")

---@class rizu.library.ChartviewsRepo
---@operator call: rizu.library.ChartviewsRepo
local ChartviewsRepo = class()

---@param models rdb.Models
function ChartviewsRepo:new(models)
	self.chartviews_count = 0
	---@type {[integer]: rizu.library.IChartviewBase}
	self.chartviews = {}
	self.set_id_to_global_index = {}
	self.chartfile_id_to_global_index = {}
	self.chartdiff_id_to_global_index = {}
	self.chartplay_id_to_global_index = {}
	self.params = {}

	self.models = models
	self.is_sync = false
end

---@param is_sync boolean
function ChartviewsRepo:setSync(is_sync)
	self.is_sync = is_sync
end

----------------------------------------------------------------

ffi.cdef [[
	typedef struct {
		int32_t chartfile_id;
		int32_t chartfile_set_id;
		int32_t chartmeta_id;
		int32_t chartdiff_id;
		int32_t chartplay_id;
		bool lamp;
	} chartview_struct
]]

ChartviewsRepo.chartview_struct = ffi.typeof("chartview_struct")

---@return table
function ChartviewsRepo:getQueryResult()
	return {
		chartviews_count = self.chartviews_count,
		set_id_to_global_index = self.set_id_to_global_index,
		chartfile_id_to_global_index = self.chartfile_id_to_global_index,
		chartdiff_id_to_global_index = self.chartdiff_id_to_global_index,
		chartplay_id_to_global_index = self.chartplay_id_to_global_index,
		chartviews = ffi.string(self.chartviews, ffi.sizeof(self.chartviews)),
	}
end

---@param t table
function ChartviewsRepo:applyQueryResult(t)
	self.chartviews_count = t.chartviews_count
	self.set_id_to_global_index = t.set_id_to_global_index
	self.chartfile_id_to_global_index = t.chartfile_id_to_global_index
	self.chartdiff_id_to_global_index = t.chartdiff_id_to_global_index
	self.chartplay_id_to_global_index = t.chartplay_id_to_global_index

	local size = ffi.sizeof("chartview_struct")
	self.chartviews = ffi.new("chartview_struct[?]", #t.chartviews / size)
	ffi.copy(self.chartviews, t.chartviews, #t.chartviews)
end

local _queryAsync = thread.async(function(params)
	local time = love.timer.getTime()
	local ChartviewsRepo = require("rizu.library.repos.ChartviewsRepo")
	local Database = require("rizu.library.Database")
	local LoveFilesystem = require("fs.LoveFilesystem")

	local db = Database(LoveFilesystem())
	db:load()

	local self = ChartviewsRepo(db.models)
	self.params = params
	local status, err = pcall(self.queryNoteChartSets, self)
	db:unload()

	if not status then
		print(err)
		return
	end

	local t = self:getQueryResult()

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d bytes"):format(#t.chartviews))
	return t
end)

---@param params table
function ChartviewsRepo:queryAsync(params)
	self.params = params

	if self.is_sync then
		self:queryNoteChartSets()
		return
	end

	local t = _queryAsync(params)
	if not t then
		return
	end

	self:applyQueryResult(t)
end

local LEVELS = {
	chartfile_sets = 1,
	chartfiles = 2,
	chartmetas = 3,
	chartdiffs = 4,
	chartplays = 5,
}

local LEVEL_GROUPS = {
	chartfile_sets = {"chartfile_set_id"},
	chartfiles = {"chartfile_set_id", "chartfile_id"},
	chartmetas = {"chartfile_set_id", "chartfile_id", "chartmeta_id"},
	chartdiffs = {"chartfile_set_id", "chartfile_id", "chartmeta_id", "chartdiff_id"},
	chartplays = {"chartfile_set_id", "chartfile_id", "chartmeta_id", "chartdiff_id", "chartplay_id"},
}

function ChartviewsRepo:_buildViewSubquery(params, mode, use_preview)
	local view_group = LEVEL_GROUPS[mode]
	local level = LEVELS[mode]

	local columns = {
		QueryFragments.FIELDS_IDS,
		QueryFragments.FIELDS_CHARTFILE_SET,
		QueryFragments.FIELDS_CHARTFILE,
		QueryFragments.FIELDS_CHARTMETA,
		QueryFragments.FIELDS_CHARTMETA_USER_DATA,
		QueryFragments.FIELDS_CHARTDIFF,
	}

	if use_preview then
		table.insert(columns, QueryFragments.FIELDS_CHARTDIFF_PREVIEW)
	end

	local joins = {
		QueryFragments.JOINS_CHARTFILES_METAS_SETS,
	}

	table.insert(columns, QueryFragments.FIELDS_CHARTPLAY_STAT)
	table.insert(columns, QueryFragments.FIELDS_CHARTPLAY)

	table.insert(joins, "LEFT JOIN chartdiffs ON " .. QueryFragments.COND_CHARTDIFF)

	if level < LEVELS.chartplays then
		table.insert(joins, "LEFT JOIN chartplays ON " .. (
			level == LEVELS.chartdiffs and QueryFragments.COND_CHARTPLAY_BY_MODE or QueryFragments.COND_CHARTPLAY
		))
	elseif level == LEVELS.chartplays then
		table.insert(joins, "INNER JOIN chartplays ON " .. QueryFragments.COND_CHARTPLAY_BY_MODS)
	end

	if params.lamp then
		table.insert(columns, QueryFragments.getLampField(params.lamp, false))
	end

	if params.difficulty then
		table.insert(columns, params.difficulty .. " AS difficulty")
	end

	local sql = "SELECT " .. table.concat(columns, ", ")
		.. " FROM chartfiles " .. table.concat(joins, " ")

	return sql
end

---@param params table
---@param mode string
---@param use_preview boolean
---@return rdb.Model
function ChartviewsRepo:_getDynamicViewModel(params, mode, use_preview)
	local subquery = self:_buildViewSubquery(params, mode, use_preview)
	return Model({
		subquery = subquery,
		types = chartview_base.types,
		from_db = chartview_base.from_db,
	}, self.models)
end

function ChartviewsRepo:queryNoteChartSets()
	local params = self.params
	local mode = params.primary_mode or "chartmetas"
	local model = self:_getDynamicViewModel(params, mode, false)
	local level = LEVELS[mode]
	local view_group = LEVEL_GROUPS[mode]

	local columns = {
		level >= LEVELS.chartfiles and "chartfile_id" or "MAX(chartfile_id) AS chartfile_id",
		"chartfile_set_id",
		level >= LEVELS.chartmetas and "chartmeta_id" or "MAX(chartmeta_id) AS chartmeta_id",
		level >= LEVELS.chartdiffs and "chartdiff_id" or "MAX(chartdiff_id) AS chartdiff_id",
		level >= LEVELS.chartplays and "chartplay_id" or "MAX(chartplay_id) AS chartplay_id",
	}

	if level < LEVELS.chartplays then
		table.insert(columns, "MIN(accuracy) AS accuracy")
		table.insert(columns, "MIN(miss_count) AS miss_count")
		table.insert(columns, "MAX(chartplay_created_at) AS chartplay_created_at")
	else
		table.insert(columns, "accuracy")
		table.insert(columns, "miss_count")
		table.insert(columns, "chartplay_created_at")
	end

	if params.lamp then
		if level < LEVELS.chartplays then
			table.insert(columns, "MAX(lamp) AS lamp")
		else
			table.insert(columns, "lamp")
		end
	end

	if params.difficulty then
		if level < LEVELS.chartplays then
			table.insert(columns, "MAX(difficulty) AS difficulty")
		else
			table.insert(columns, "difficulty")
		end
	end

	local where = table_util.copy(params.where)
	local having

	local options = {
		columns = columns,
		order = params.order,
		having = having,
		group = view_group,
	}

	local count_options = {
		columns = {"1"},
		having = having,
		group = view_group,
	}
	local count = model:count(where, count_options)

	local noteChartSets = ffi.new("chartview_struct[?]", count)
	local chartfile_id_to_global_index = {}
	local chartdiff_id_to_global_index = {}
	local chartplay_id_to_global_index = {}
	local set_id_to_global_index = {}
	self.chartviews = noteChartSets
	self.chartfile_id_to_global_index = chartfile_id_to_global_index
	self.chartdiff_id_to_global_index = chartdiff_id_to_global_index
	self.chartplay_id_to_global_index = chartplay_id_to_global_index
	self.set_id_to_global_index = set_id_to_global_index

	local c = 0
	for i, row in model:select_iter(where, options) do
		local entry = noteChartSets[i - 1]
		entry.chartfile_id = row.chartfile_id
		entry.chartfile_set_id = row.chartfile_set_id
		entry.chartmeta_id = row.chartmeta_id or 0
		entry.chartdiff_id = row.chartdiff_id or 0
		entry.chartplay_id = row.chartplay_id or 0
		entry.lamp = sql_util.toboolean(row.lamp or 0)
		set_id_to_global_index[entry.chartfile_set_id] = i
		chartfile_id_to_global_index[entry.chartfile_id] = i
		chartdiff_id_to_global_index[entry.chartdiff_id] = i
		chartplay_id_to_global_index[entry.chartplay_id] = i
		c = c + 1
	end

	self.chartviews_count = c
end

---@param chartview rizu.library.IChartviewBase
---@return rizu.library.Chartview[]
function ChartviewsRepo:getSecondaryViews(chartview)
	local params = self.params
	local primary_mode = params.primary_mode or "chartmetas"
	local secondary_mode = params.secondary_mode or "chartmetas"

	local primary_level = LEVELS[primary_mode]
	local secondary_level = LEVELS[secondary_mode]

	local filter_level = math.min(primary_level, secondary_level)
	local group_mode = secondary_level >= primary_level and secondary_mode or primary_mode

	local model = self:_getDynamicViewModel(params, group_mode, true)

	local columns = {"*"}
	local group_level = LEVELS[group_mode]

	if group_level < LEVELS.chartplays then
		columns = {
			group_level >= LEVELS.chartfiles and "chartfile_id" or "MAX(chartfile_id) AS chartfile_id",
			"chartfile_set_id",
			group_level >= LEVELS.chartmetas and "chartmeta_id" or "MAX(chartmeta_id) AS chartmeta_id",
			group_level >= LEVELS.chartdiffs and "chartdiff_id" or "MAX(chartdiff_id) AS chartdiff_id",
			group_level >= LEVELS.chartplays and "chartplay_id" or "MAX(chartplay_id) AS chartplay_id",
			"location_id", "set_is_file", "set_dir", "set_name", "set_modified_at",
			"chartfile_name", "modified_at", "hash",
			"`index`", "inputmode", "format", "chartmeta_timings", "chartmeta_healths",
			"title", "title_unicode", "artist", "artist_unicode", "name", "creator",
			"level", "source", "tags", "audio_path", "audio_offset", "background_path",
			"preview_time", "osu_beatmap_id", "osu_beatmapset_id",
			"tempo", "tempo_avg", "tempo_max", "tempo_min",
			"chartmeta_local_offset", "chartmeta_rating", "chartmeta_comment",
			"modifiers", "rate", "mode", "chartdiff_inputmode", "duration", "start_time",
			"notes_count", "judges_count", "long_notes_ratio", "note_types_count",
			"density_data", "sv_data", "enps_diff", "osu_diff", "msd_diff",
			"msd_diff_data", "msd_diff_rates", "user_diff", "user_diff_data",
			"notes_preview",
			"MIN(accuracy) AS accuracy",
			"MIN(miss_count) AS miss_count",
			"MAX(chartplay_created_at) AS chartplay_created_at"
		}
	else
		table.insert(columns, "accuracy")
		table.insert(columns, "miss_count")
		table.insert(columns, "chartplay_created_at")
	end

	if group_level < LEVELS.chartplays then
		table.insert(columns, "MAX(difficulty) AS difficulty")
	else
		table.insert(columns, "difficulty")
	end

	if params.lamp then
		if group_level < LEVELS.chartplays then
			table.insert(columns, QueryFragments.getLampField(params.lamp, true))
		else
			table.insert(columns, "lamp")
		end
	end

	local order = {
		"length(inputmode)",
		"chartdiff_inputmode",
		"inputmode",
		"difficulty",
		"name",
		"chartmeta_id",
		"chartdiff_id",
		"chartplay_id",
	}

	local where = table_util.copy(params.where)
	if filter_level >= LEVELS.chartfile_sets then where.chartfile_set_id = chartview.chartfile_set_id end
	if filter_level >= LEVELS.chartfiles then where.chartfile_id = chartview.chartfile_id end
	if filter_level >= LEVELS.chartmetas then where.chartmeta_id = chartview.chartmeta_id end
	if filter_level >= LEVELS.chartdiffs then where.chartdiff_id = chartview.chartdiff_id end
	if filter_level >= LEVELS.chartplays then where.chartplay_id = chartview.chartplay_id end

	local having

	if secondary_mode == "chartplayviews" then -- Legacy compat, but better use LEVELS
		order = {"chartplay_id"}
	end
	if secondary_level == LEVELS.chartplays then
		order = {"chartplay_id"}
	end

	local options = {
		columns = columns,
		order = order,
		having = having,
		group = LEVEL_GROUPS[group_mode],
	}

	---@type rizu.library.Chartview[]
	local objs = model:select(where, options)

	for _, obj in ipairs(objs) do
		self:_fillRichData(obj)
	end

	return objs
end

---@param obj rizu.library.LocatedChartview
---@return rizu.library.LocatedChartview
function ChartviewsRepo:_fillRichData(obj)
	local hash, index = obj.hash, obj.index
	if hash and index then
		obj.difftable_chartmetas = self.models.difftable_chartmetas:select({
			hash = hash,
			index = index,
		})
	end
	return obj
end

---@param _chartview rizu.library.IChartviewBase
---@return rizu.library.Chartview?
function ChartviewsRepo:getChartview(_chartview)
	local chartfile_id = _chartview.chartfile_id
	local chartmeta_id = _chartview.chartmeta_id
	local chartdiff_id = _chartview.chartdiff_id
	local chartplay_id = _chartview.chartplay_id

	local params = self.params
	local mode = params.secondary_mode or params.primary_mode or "chartmetas"
	local model = self:_getDynamicViewModel(params, mode, true)
	local level = LEVELS[mode]

	local columns = {"*"}
	if level < LEVELS.chartplays then
		columns = {
			level >= LEVELS.chartfiles and "chartfile_id" or "MAX(chartfile_id) AS chartfile_id",
			"chartfile_set_id",
			level >= LEVELS.chartmetas and "chartmeta_id" or "MAX(chartmeta_id) AS chartmeta_id",
			level >= LEVELS.chartdiffs and "chartdiff_id" or "MAX(chartdiff_id) AS chartdiff_id",
			level >= LEVELS.chartplays and "chartplay_id" or "MAX(chartplay_id) AS chartplay_id",
			"location_id", "set_is_file", "set_dir", "set_name", "set_modified_at",
			"chartfile_name", "modified_at", "hash",
			"`index`", "inputmode", "format", "chartmeta_timings", "chartmeta_healths",
			"title", "title_unicode", "artist", "artist_unicode", "name", "creator",
			"level", "source", "tags", "audio_path", "audio_offset", "background_path",
			"preview_time", "osu_beatmap_id", "osu_beatmapset_id",
			"tempo", "tempo_avg", "tempo_max", "tempo_min",
			"chartmeta_local_offset", "chartmeta_rating", "chartmeta_comment",
			"modifiers", "rate", "mode", "chartdiff_inputmode", "duration", "start_time",
			"notes_count", "judges_count", "long_notes_ratio", "note_types_count",
			"density_data", "sv_data", "enps_diff", "osu_diff", "msd_diff",
			"msd_diff_data", "msd_diff_rates", "user_diff", "user_diff_data",
			"notes_preview",
			"MIN(accuracy) AS accuracy",
			"MIN(miss_count) AS miss_count",
			"MAX(chartplay_created_at) AS chartplay_created_at"
		}
	else
		table.insert(columns, "accuracy")
		table.insert(columns, "miss_count")
		table.insert(columns, "chartplay_created_at")
	end

	if level < LEVELS.chartplays then
		table.insert(columns, "MAX(difficulty) AS difficulty")
	else
		table.insert(columns, "difficulty")
	end

	if params.lamp then
		if level < LEVELS.chartplays then
			table.insert(columns, "MAX(lamp) AS lamp")
		else
			table.insert(columns, "lamp")
		end
	end

	local having
	local where = {}

	local options = {
		columns = columns,
		limit = 1,
		having = having,
		group = level < LEVELS.chartplays and LEVEL_GROUPS[mode] or nil,
	}

	---@type rizu.library.Chartview?
	local obj
	if chartplay_id then
		where.chartfile_id = chartfile_id
		where.chartplay_id = chartplay_id
		obj = model:find(where, options)
	end
	if not obj and chartdiff_id then
		where.chartfile_id = chartfile_id
		where.chartplay_id = nil
		where.chartdiff_id = chartdiff_id
		obj = model:find(where, options)
	end
	if not obj and chartmeta_id then
		where.chartfile_id = chartfile_id
		where.chartdiff_id = nil
		where.chartmeta_id = chartmeta_id
		obj = model:find(where, options)
	end
	if not obj then
		where.chartfile_id = chartfile_id
		where.chartmeta_id = nil
		obj = model:find(where, options)
	end

	if obj then
		self:_fillRichData(obj)
	end

	return obj
end

return ChartviewsRepo

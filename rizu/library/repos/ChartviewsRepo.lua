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

function ChartviewsRepo:_buildViewSubquery(params, use_preview)
	local view_group
	if params.chartviews_table == "chartviews" then
		view_group = {"chartfile_set_id", "chartfile_id", "chartmeta_id"}
	elseif params.chartviews_table == "chartdiffviews" then
		view_group = {"chartfile_set_id", "chartfile_id", "chartmeta_id", "chartdiff_id"}
	elseif params.chartviews_table == "chartplayviews" then
		view_group = {"chartfile_set_id", "chartfile_id", "chartmeta_id", "chartdiff_id", "chartplay_id"}
	end

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

	if params.chartviews_table == "chartviews" then
		table.insert(columns, QueryFragments.FIELDS_CHARTPLAY_AGGREGATED)
		table.insert(joins, "LEFT JOIN chartdiffs ON " .. QueryFragments.COND_CHARTDIFF_DEFAULT)
		table.insert(joins, "LEFT JOIN chartplays ON " .. QueryFragments.COND_CHARTPLAY)
	elseif params.chartviews_table == "chartdiffviews" then
		table.insert(columns, QueryFragments.FIELDS_CHARTPLAY_AGGREGATED)
		table.insert(joins, "LEFT JOIN chartdiffs ON " .. QueryFragments.COND_CHARTDIFF)
		table.insert(joins, "LEFT JOIN chartplays ON " .. QueryFragments.COND_CHARTPLAY_BY_MODE)
	elseif params.chartviews_table == "chartplayviews" then
		table.insert(columns, QueryFragments.FIELDS_CHARTPLAY_STAT)
		table.insert(columns, QueryFragments.FIELDS_CHARTPLAY)
		table.insert(joins, "LEFT JOIN chartdiffs ON " .. QueryFragments.COND_CHARTDIFF)
		table.insert(joins, "INNER JOIN chartplays ON " .. QueryFragments.COND_CHARTPLAY_BY_MODS)
	end

	if params.lamp then
		table.insert(columns, QueryFragments.getLampField(params.lamp, view_group ~= nil))
	end

	if params.difficulty then
		table.insert(columns, params.difficulty .. " AS difficulty")
	end

	local sql = "SELECT " .. table.concat(columns, ", ")
		.. " FROM chartfiles " .. table.concat(joins, " ")

	if view_group then
		sql = sql .. " GROUP BY " .. table.concat(view_group, ", ")
	end

	return sql
end

---@param params table
---@param use_preview boolean
---@return rdb.Model
function ChartviewsRepo:_getDynamicViewModel(params, use_preview)
	local subquery = self:_buildViewSubquery(params, use_preview)
	return Model({
		subquery = subquery,
		types = chartview_base.types,
		from_db = chartview_base.from_db,
	}, self.models)
end

function ChartviewsRepo:queryNoteChartSets()
	local params = self.params
	local model = self:_getDynamicViewModel(params, false)

	local columns = {
		"chartfile_id",
		"chartfile_set_id",
		"chartmeta_id",
		"chartdiff_id",
		"chartplay_id",
	}

	if params.lamp then
		table.insert(columns, "lamp")
	end

	if params.difficulty then
		table.insert(columns, "difficulty")
	end

	local options = {
		columns = columns,
		order = params.order,
		group = params.group,
	}

	-- Aggregate results if grouped at the top level
	if params.group then
		options.columns = {
			"MAX(chartfile_id) AS chartfile_id",
			"chartfile_set_id",
			"MAX(chartmeta_id) AS chartmeta_id",
			"MAX(chartdiff_id) AS chartdiff_id",
			"MAX(chartplay_id) AS chartplay_id",
		}
		if params.lamp then table.insert(options.columns, "MAX(lamp) AS lamp") end
		if params.difficulty then table.insert(options.columns, "MAX(difficulty) AS difficulty") end
	end

	local where = table_util.copy(params.where)

	local count_options = {
		group = params.group,
		columns = {"1"},
	}
	local count = model:count(where, count_options)
	print("count", count)

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
		entry.lamp = row.lamp or false
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
function ChartviewsRepo:getChartviewsAtSet(chartview)
	local params = self.params
	local model = self:_getDynamicViewModel(params, true)

	local columns = {"*", "difficulty"}
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
	where.chartfile_set_id = chartview.chartfile_set_id

	if params.chartviews_table == "chartdiffviews" then
		where.chartmeta_id = chartview.chartmeta_id
	elseif params.chartviews_table == "chartplayviews" then
		where.chartmeta_id = chartview.chartmeta_id
		order = {"chartplay_id"}
	end

	local options = {
		columns = columns,
		order = order,
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
	local model = self:_getDynamicViewModel(params, true)

	local options = {
		columns = {"*", "difficulty"},
		limit = 1,
	}

	---@type rizu.library.Chartview?
	local obj
	if chartplay_id then
		obj = model:find({
			chartfile_id = chartfile_id,
			chartplay_id = chartplay_id,
		}, options)
	end
	if not obj and chartdiff_id then
		obj = model:find({
			chartfile_id = chartfile_id,
			chartdiff_id = chartdiff_id,
		}, options)
	end
	if not obj and chartmeta_id then
		obj = model:find({
			chartfile_id = chartfile_id,
			chartmeta_id = chartmeta_id,
		}, options)
	end
	if not obj then
		obj = model:find({
			chartfile_id = chartfile_id,
		}, options)
	end

	if obj then
		self:_fillRichData(obj)
	end

	return obj
end

return ChartviewsRepo

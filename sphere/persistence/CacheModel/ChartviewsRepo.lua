local thread = require("thread")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local ffi = require("ffi")
local class = require("class")

---@class sphere.ChartviewsRepo
---@operator call: sphere.ChartviewsRepo
local ChartviewsRepo = class()

---@param models sphere.CacheModelModels
function ChartviewsRepo:new(models)
	self.chartviews_count = 0
	self.chartviews = {}
	self.set_id_to_global_index = {}
	self.chartfile_id_to_global_index = {}
	self.chartdiff_id_to_global_index = {}
	self.chartplay_id_to_global_index = {}
	self.params = {}

	self.models = models
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		int32_t chartfile_id;
		int32_t chartfile_set_id;
		int32_t chartmeta_id;
		int32_t chartdiff_id;
		int32_t chartplay_id;
		bool lamp;
	} chartview_struct
]])

ChartviewsRepo.chartview_struct = ffi.typeof("chartview_struct")

local _queryAsync = thread.async(function(params)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local ChartviewsRepo = require("sphere.persistence.CacheModel.ChartviewsRepo")
	local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")

	local gdb = GameDatabase()
	gdb:load()

	local self = ChartviewsRepo(gdb.models)
	self.params = params
	local status, err = pcall(self.queryNoteChartSets, self)
	gdb:unload()

	if not status then
		print(err)
		return
	end
	local t = {
		chartviews_count = self.chartviews_count,
		set_id_to_global_index = self.set_id_to_global_index,
		chartfile_id_to_global_index = self.chartfile_id_to_global_index,
		chartdiff_id_to_global_index = self.chartdiff_id_to_global_index,
		chartplay_id_to_global_index = self.chartplay_id_to_global_index,
		chartviews = ffi.string(self.chartviews, ffi.sizeof(self.chartviews)),
	}

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d bytes"):format(#t.chartviews))
	return t
end)

---@param params table
function ChartviewsRepo:queryAsync(params)
	self.params = params
	local t = _queryAsync(params)
	if not t then
		return
	end

	self.chartviews_count = t.chartviews_count
	self.set_id_to_global_index = t.set_id_to_global_index
	self.chartfile_id_to_global_index = t.chartfile_id_to_global_index
	self.chartdiff_id_to_global_index = t.chartdiff_id_to_global_index
	self.chartplay_id_to_global_index = t.chartplay_id_to_global_index

	local size = ffi.sizeof("chartview_struct")
	self.chartviews = ffi.new("chartview_struct[?]", #t.chartviews / size)
	ffi.copy(self.chartviews, t.chartviews, #t.chartviews)
end

function ChartviewsRepo:queryNoteChartSets()
	local params = self.params

	local columns = {
		"chartfile_id",
		"chartfile_set_id",
		"chartmeta_id",
		"chartdiff_id",
		"chartplay_id",
		params.difficulty .. " AS difficulty",
	}

	if params.lamp then
		local case = ("CASE WHEN %s THEN TRUE ELSE FALSE END"):format(
			sql_util.bind(sql_util.conditions(params.lamp))
		)
		if params.group then
			case = ("max(%s)"):format(case)
		end
		table.insert(columns, case .. " AS lamp")
	end

	local options = {
		columns = columns,
		group = params.group,
		order = params.order,
	}

	local where = table_util.copy(params.where)

	-- views without preview are 2x times faster
	local model = self.models.chartviews_no_preview
	if params.chartviews_table == "chartviews" then
		model = self.models.chartviews_no_preview
	elseif params.chartviews_table == "chartdiffviews" then
		model = self.models.chartdiffviews_no_preview
	elseif params.chartviews_table == "chartplayviews" then
		model = self.models.chartplayviews_no_preview
	end

	local count = model:count(where, options)
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

---@param chartview table
---@return rdb.Row[]
function ChartviewsRepo:getChartviewsAtSet(chartview)
	local params = self.params

	local columns = {
		"*",
		params.difficulty .. " AS difficulty",
	}
	local where = table_util.copy(params.where)
	where.chartfile_set_id = chartview.chartfile_set_id

	if params.lamp then
		local case = ("CASE WHEN %s THEN TRUE ELSE FALSE END lamp"):format(
			sql_util.bind(sql_util.conditions(params.lamp))
		)
		table.insert(columns, case)
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

	local model = self.models.chartviews
	if params.chartviews_table == "chartviews" then
		model = self.models.chartviews
	elseif params.chartviews_table == "chartdiffviews" then
		model = self.models.chartdiffviews
		where.chartmeta_id = chartview.chartmeta_id
	elseif params.chartviews_table == "chartplayviews" then
		model = self.models.chartplayviews
		where.chartmeta_id = chartview.chartmeta_id
		order = {"chartplay_id"}
	end

	local options = {
		columns = columns,
		order = order,
	}

	local objs = model:select(where, options)

	for _, obj in ipairs(objs) do
		local hash, index = obj.hash, obj.index
		if hash and index then
			obj.difftable_chartmetas = self.models.difftable_chartmetas:select({
				hash = hash,
				index = index,
			})
		end
	end

	return objs
end

---@param _chartview table
---@return rdb.Row
function ChartviewsRepo:getChartview(_chartview)
	local chartfile_id = _chartview.chartfile_id
	local chartmeta_id = _chartview.chartmeta_id
	local chartdiff_id = _chartview.chartdiff_id
	local chartplay_id = _chartview.chartplay_id

	local params = self.params
	local model = self.models.chartviews
	if params.chartviews_table == "chartviews" then
		model = self.models.chartviews
	elseif params.chartviews_table == "chartdiffviews" then
		model = self.models.chartdiffviews
	elseif params.chartviews_table == "chartplayviews" then
		model = self.models.chartplayviews
	end

	local obj = model:find({
		chartfile_id = chartfile_id,
		chartplay_id = chartplay_id,
		chartplay_id__isnull = not chartplay_id,
	})
	if obj then
		return obj
	end

	obj = model:find({
		chartfile_id = chartfile_id,
		chartdiff_id = chartdiff_id,
		chartdiff_id__isnull = not chartdiff_id,
	})
	if obj then
		return obj
	end

	obj = model:find({
		chartfile_id = chartfile_id,
		chartmeta_id = chartmeta_id,
		chartmeta_id__isnull = not chartmeta_id,
	})
	if obj then
		return obj
	end

	obj = model:find({
		chartfile_id = chartfile_id,
		chartmeta_id__isnull = true,
	})

	return obj
end

return ChartviewsRepo

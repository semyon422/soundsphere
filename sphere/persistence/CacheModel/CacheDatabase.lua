local thread = require("thread")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local ffi = require("ffi")
local class = require("class")

---@class sphere.CacheDatabase
---@operator call: sphere.CacheDatabase
local CacheDatabase = class()

---@param cdb sphere.ChartsDatabase
function CacheDatabase:new(cdb)
	self.chartviews_count = 0
	self.chartviews = {}
	self.set_id_to_global_index = {}
	self.chartfile_id_to_global_index = {}
	self.chartdiff_id_to_global_index = {}
	self.params = {}

	self.models = cdb.models
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		int32_t chartfile_id;
		int32_t chartfile_set_id;
		int32_t chartmeta_id;
		int32_t chartdiff_id;
		bool lamp;
	} EntryStruct
]])

CacheDatabase.EntryStruct = ffi.typeof("EntryStruct")

local _queryAsync = thread.async(function(params)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
	local ChartsDatabase = require("sphere.persistence.CacheModel.ChartsDatabase")

	local cdb = ChartsDatabase()
	cdb:load()

	local self = CacheDatabase(cdb)
	self.params = params
	local status, err = pcall(self.queryNoteChartSets, self)
	cdb:unload()

	if not status then
		print(err)
		return
	end
	local t = {
		chartviews_count = self.chartviews_count,
		set_id_to_global_index = self.set_id_to_global_index,
		chartfile_id_to_global_index = self.chartfile_id_to_global_index,
		chartdiff_id_to_global_index = self.chartdiff_id_to_global_index,
		chartviews = ffi.string(self.chartviews, ffi.sizeof(self.chartviews)),
	}

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d bytes"):format(#t.chartviews))
	return t
end)

---@param params table
function CacheDatabase:queryAsync(params)
	self.params = params
	local t = _queryAsync(params)
	if not t then
		return
	end

	self.chartviews_count = t.chartviews_count
	self.set_id_to_global_index = t.set_id_to_global_index
	self.chartfile_id_to_global_index = t.chartfile_id_to_global_index
	self.chartdiff_id_to_global_index = t.chartdiff_id_to_global_index

	local size = ffi.sizeof("EntryStruct")
	self.chartviews = ffi.new("EntryStruct[?]", #t.chartviews / size)
	ffi.copy(self.chartviews, t.chartviews, #t.chartviews)
end

function CacheDatabase:queryNoteChartSets()
	local params = self.params

	local columns = {
		"chartfile_id",
		"chartfile_set_id",
		"chartmeta_id",
		"chartdiff_id",
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
	local model = self.models.chartviews
	if params.chartdiffs_list then
		model = self.models.chartdiffviews
	end

	local objs = model:select(where, options)
	print("count", #objs)

	local noteChartSets = ffi.new("EntryStruct[?]", #objs)
	local chartfile_id_to_global_index = {}
	local chartdiff_id_to_global_index = {}
	local set_id_to_global_index = {}
	self.chartviews = noteChartSets
	self.chartfile_id_to_global_index = chartfile_id_to_global_index
	self.chartdiff_id_to_global_index = chartdiff_id_to_global_index
	self.set_id_to_global_index = set_id_to_global_index

	local c = 0
	for i, row in ipairs(objs) do
		local entry = noteChartSets[i - 1]
		entry.chartfile_id = row.chartfile_id
		entry.chartfile_set_id = row.chartfile_set_id
		entry.chartmeta_id = row.chartmeta_id or 0
		entry.chartdiff_id = row.chartdiff_id or 0
		entry.lamp = row.lamp
		set_id_to_global_index[entry.chartfile_set_id] = i
		chartfile_id_to_global_index[entry.chartfile_id] = i
		chartdiff_id_to_global_index[entry.chartdiff_id] = i
		c = c + 1
	end

	self.chartviews_count = c
end

---@param chartview table
---@return rdb.ModelRow[]
function CacheDatabase:getChartviewsAtSet(chartview)
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

	local model = self.models.chartviews
	if params.chartdiffs_list then
		model = self.models.chartdiffviews
		where.chartmeta_id = chartview.chartmeta_id
	end

	local options = {
		columns = columns,
		order = {
			"length(inputmode)",
			"inputmode",
			"difficulty",
			"name",
			"chartmeta_id",
			"chartdiff_id",
		},
	}

	local objs = model:select(where, options)

	return objs
end

---@param _chartview table
---@return rdb.ModelRow
function CacheDatabase:getChartview(_chartview)
	local chartfile_id = _chartview.chartfile_id
	local chartmeta_id = _chartview.chartmeta_id
	local chartdiff_id = _chartview.chartdiff_id

	local params = self.params
	local model = self.models.chartviews
	if params.chartdiffs_list then
		model = self.models.chartdiffviews
	end

	local obj = model:find({
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

return CacheDatabase

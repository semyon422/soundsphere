local thread = require("thread")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local ffi = require("ffi")
local class = require("class")

---@class sphere.CacheDatabase
---@operator call: sphere.CacheDatabase
local CacheDatabase = class()

function CacheDatabase:new(cdb)
	self.noteChartSetItemsCount = 0
	self.noteChartSetItems = {}
	self.set_id_to_global_offset = {}
	self.id_to_global_offset = {}
	self.queryParams = {}

	self.models = cdb.models
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		int32_t chartmeta_id;
		int32_t chartfile_id;
		int32_t chartfile_set_id;
		int32_t score_id;
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
	self.queryParams = params
	local status, err = pcall(self.queryNoteChartSets, self)
	cdb:unload()

	if not status then
		print(err)
		return
	end
	local t = {
		noteChartSetItemsCount = self.noteChartSetItemsCount,
		set_id_to_global_offset = self.set_id_to_global_offset,
		id_to_global_offset = self.id_to_global_offset,
		noteChartSetItems = ffi.string(self.noteChartSetItems, ffi.sizeof(self.noteChartSetItems)),
	}

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d bytes"):format(#t.noteChartSetItems))
	return t
end)

---@param params table
function CacheDatabase:queryAsync(params)
	self.queryParams = params
	local t = _queryAsync(params)
	if not t then
		return
	end

	self.noteChartSetItemsCount = t.noteChartSetItemsCount
	self.id_to_global_offset = t.id_to_global_offset
	self.set_id_to_global_offset = t.set_id_to_global_offset

	local size = ffi.sizeof("EntryStruct")
	self.noteChartSetItems = ffi.new("EntryStruct[?]", #t.noteChartSetItems / size)
	ffi.copy(self.noteChartSetItems, t.noteChartSetItems, #t.noteChartSetItems)
end

---@param t table
---@param entry table
---@param offset number
local function chart_id_to_offset(t, entry, offset)
	local c, d = entry.chartfile_id, entry.chartmeta_id
	t[c] = t[c] or {}
	t[c][d] = offset
end

function CacheDatabase:queryNoteChartSets()
	local params = self.queryParams

	local columns = {
		"chartmeta_id",
		"chartfile_id",
		"chartfile_set_id",
		"score_id",
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

	if params.group then
		columns[4] = "max(score_id)"
	end

	local objs = self.models.chartviews:select(params.where, options)
	print("count", #objs)

	local noteChartSets = ffi.new("EntryStruct[?]", #objs)
	local id_to_global_offset = {}
	local set_id_to_global_offset = {}
	self.noteChartSetItems = noteChartSets
	self.id_to_global_offset = id_to_global_offset
	self.set_id_to_global_offset = set_id_to_global_offset

	local c = 0
	for i, row in ipairs(objs) do
		local j = i - 1
		local entry = noteChartSets[j]
		entry.chartmeta_id = row.chartmeta_id or 0
		entry.chartfile_id = row.chartfile_id
		entry.chartfile_set_id = row.chartfile_set_id
		entry.score_id = row.score_id or 0
		entry.lamp = row.lamp
		set_id_to_global_offset[entry.chartfile_set_id] = j
		chart_id_to_offset(id_to_global_offset, entry, j)
		c = c + 1
	end

	self.noteChartSetItemsCount = c
end

---@param chartfile_set_id number
---@return rdb.ModelRow[]
function CacheDatabase:getChartviewsAtSet(chartfile_set_id)
	local params = self.queryParams

	local columns = {
		"*",
		params.difficulty .. " AS difficulty",
	}
	local where = table_util.copy(params.where)
	where.chartfile_set_id = chartfile_set_id

	if params.lamp then
		local case = ("CASE WHEN %s THEN TRUE ELSE FALSE END lamp"):format(
			sql_util.bind(sql_util.conditions(params.lamp))
		)
		table.insert(columns, case)
	end

	local options = {
		columns = columns,
		order = {
			"length(inputmode)",
			"inputmode",
			"difficulty",
			"name",
			"chartmeta_id",
		},
	}

	local objs = self.models.chartviews:select(where, options)

	return objs
end

---@param chartfile_id number
---@param chartmeta_id number
---@return rdb.ModelRow
function CacheDatabase:getNoteChartSetItem(chartfile_id, chartmeta_id)
	local where = {
		chartfile_id = chartfile_id,
		{
			"or",
			chartmeta_id = chartmeta_id,
			chartmeta_id__isnull = true,
		},
	}

	local obj = self.models.chartviews:find(where)
	return obj
end

return CacheDatabase

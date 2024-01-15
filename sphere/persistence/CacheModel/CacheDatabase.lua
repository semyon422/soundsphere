local thread = require("thread")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")
local ObjectQuery = require("ObjectQuery")
local ffi = require("ffi")
local class = require("class")

---@class sphere.CacheDatabase
---@operator call: sphere.CacheDatabase
local CacheDatabase = class()

CacheDatabase.dbpath = "userdata/charts.db"

function CacheDatabase:load()
	if self.loaded then
		return
	end

	local db = LjsqliteDatabase()
	self.db = db

	db:open(self.dbpath)
	local sql = love.filesystem.read("sphere/persistence/CacheModel/database.sql")
	db:exec(sql)
	self:attachScores()

	local _models = autoload("sphere.persistence.CacheModel.models")
	local orm = TableOrm(db)
	local models = Models(_models, orm)

	self.orm = orm
	self.models = models

	self.loaded = true

	self.noteChartSetItemsCount = 0
	self.noteChartSetItems = {}
	self.noteChartItemsCount = 0
	self.noteChartItems = {}
	self.noteChartSlices = {}
	self.set_id_to_global_offset = {}
	self.id_to_global_offset = {}
	self.id_to_local_offset = {}

	self.queryParams = {}
end

function CacheDatabase:unload()
	if not self.loaded then
		return
	end
	self.loaded = false
	self:detachScores()
	return self.db:close()
end

function CacheDatabase:attachScores()
	self.db:exec("ATTACH 'userdata/scores.db' AS scores_db")
end

function CacheDatabase:detachScores()
	self.db:exec("DETACH scores_db")
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		int32_t noteChartDataId;
		int32_t noteChartId;
		int32_t setId;
		int32_t scoreId;
		bool lamp;
	} EntryStruct
]])

CacheDatabase.EntryStruct = ffi.typeof("EntryStruct")

---@param object table
---@param row table
local function fillObject(object, row)
	for k, v in pairs(row) do
		if k:find("^__boolean_") then
			k = k:sub(11)
			if tonumber(v) == 1 then
				v = true
			else
				v = false
			end
		elseif type(v) == "cdata" then
			v = tonumber(v) or v
		end
		object[k] = v or 0
	end
end

function CacheDatabase:queryAll()
	self:queryNoteChartSets()
	self:queryNoteCharts()
	self:reassignData()
end

local _asyncQueryAll = thread.async(function(queryParams)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
	local self = CacheDatabase()
	self:load()
	self.queryParams = queryParams
	local status, err = pcall(self.queryAll, self)
	if not status then
		print(err)
		return
	end
	local t = {
		noteChartSetItemsCount = self.noteChartSetItemsCount,
		noteChartItemsCount = self.noteChartItemsCount,
		noteChartSlices = self.noteChartSlices,
		set_id_to_global_offset = self.set_id_to_global_offset,
		id_to_global_offset = self.id_to_global_offset,
		id_to_local_offset = self.id_to_local_offset,
		noteChartSetItems = ffi.string(self.noteChartSetItems, ffi.sizeof(self.noteChartSetItems)),
		noteChartItems = ffi.string(self.noteChartItems, ffi.sizeof(self.noteChartItems)),
	}
	self:unload()

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d + %d bytes"):format(#t.noteChartSetItems, #t.noteChartItems))
	return t
end)

function CacheDatabase:asyncQueryAll()
	local t = _asyncQueryAll(self.queryParams)
	if not t then
		return
	end

	self.noteChartSetItemsCount = t.noteChartSetItemsCount
	self.id_to_global_offset = t.id_to_global_offset
	self.set_id_to_global_offset = t.set_id_to_global_offset
	self.noteChartItemsCount = t.noteChartItemsCount
	self.noteChartSlices = t.noteChartSlices
	self.id_to_local_offset = t.id_to_local_offset

	local size = ffi.sizeof("EntryStruct")
	self.noteChartSetItems = ffi.new("EntryStruct[?]", #t.noteChartSetItems / size)
	self.noteChartItems = ffi.new("EntryStruct[?]", #t.noteChartItems / size)
	ffi.copy(self.noteChartSetItems, t.noteChartSetItems, #t.noteChartSetItems)
	ffi.copy(self.noteChartItems, t.noteChartItems, #t.noteChartItems)
end

---@param t table
---@param entry table
---@param offset number
local function chart_id_to_offset(t, entry, offset)
	local c, d = entry.noteChartId, entry.noteChartDataId
	t[c] = t[c] or {}
	t[c][d] = offset
end

function CacheDatabase:queryNoteChartSets()
	local params = self.queryParams

	local objectQuery = ObjectQuery()

	objectQuery.table = "chartset_list"
	objectQuery.fields = {
		"noteChartDataId",
		"noteChartId",
		"setId",
		"scoreId",
	}

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = params.groupBy
	objectQuery.orderBy = params.orderBy

	local count = self.db:query(objectQuery:getCountQuery())[1].c
	local noteChartSets = ffi.new("EntryStruct[?]", count)
	local id_to_global_offset = {}
	local set_id_to_global_offset = {}
	self.noteChartSetItems = noteChartSets
	self.id_to_global_offset = id_to_global_offset
	self.set_id_to_global_offset = set_id_to_global_offset

	local c = 0
	for i, row in self.db:iter(objectQuery:getQueryParams()) do
		local j = i - 1
		local entry = noteChartSets[j]
		fillObject(entry, row)
		set_id_to_global_offset[entry.setId] = j
		chart_id_to_offset(id_to_global_offset, entry, j)
		c = c + 1
	end

	self.noteChartSetItemsCount = c
end

function CacheDatabase:queryNoteCharts()
	local params = self.queryParams

	local objectQuery = ObjectQuery()

	self:load()

	objectQuery.table = "chartset_list"
	objectQuery.fields = {
		"noteChartDataId",
		"noteChartId",
		"setId",
		"scoreId",
	}

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = nil
	objectQuery.orderBy = [[
		setId ASC,
		length(inputMode) ASC,
		inputMode ASC,
		difficulty ASC,
		name ASC,
		noteChartDataId ASC
	]]

	local count = self.db:query(objectQuery:getCountQuery())[1].c

	local noteCharts = ffi.new("EntryStruct[?]", count)
	local slices = {}
	local id_to_local_offset = {}
	self.noteChartItems = noteCharts
	self.noteChartSlices = slices
	self.id_to_local_offset = id_to_local_offset

	local offset = 0
	local size = 0
	local setId
	local c = 0
	for i, row in self.db:iter(objectQuery:getQueryParams()) do
		local j = i - 1
		local entry = noteCharts[j]
		fillObject(entry, row)
		if setId and setId ~= entry.setId then
			slices[setId] = {
				offset = offset,
				size = size,
			}
			offset = j
		end
		size = j - offset + 1
		setId = entry.setId
		chart_id_to_offset(id_to_local_offset, entry, j - offset)
		c = c + 1
	end

	if setId then
		slices[setId] = {
			offset = offset,
			size = size,
		}
	end

	self.noteChartItemsCount = c
end

function CacheDatabase:reassignData()
	if not self.queryParams.groupBy then
		return
	end

	for i = 0, self.noteChartSetItemsCount - 1 do
		local entry = self.noteChartSetItems[i]
		local setId = entry.setId
		local slice = self.noteChartSlices[setId]

		local lastScoreId = 0
		local currentEntry = entry
		local lamp = false

		for j = slice.offset, slice.offset + slice.size - 1 do
			local entry = self.noteChartItems[j]
			if entry.lamp then
				lamp = true
			end
			if entry.scoreId > lastScoreId then
				lastScoreId = entry.scoreId
				currentEntry = entry
			end
		end

		entry.noteChartDataId = currentEntry.noteChartDataId
		entry.noteChartId = currentEntry.noteChartId
		entry.scoreId = currentEntry.scoreId
		entry.lamp = lamp
	end
end

return CacheDatabase

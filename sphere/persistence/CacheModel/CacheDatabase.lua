local thread = require("thread")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
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
	self.set_id_to_global_offset = {}
	self.id_to_global_offset = {}

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

local select_columns = {
	"noteChartDataId",
	"noteChartId",
	"setId",
	"scoreId",
}

---@param object table
---@param row table
local function fillObject(object, row)
	object.noteChartDataId = tonumber(row.noteChartDataId) or 0
	object.noteChartId = tonumber(row.noteChartId) or 0
	object.setId = tonumber(row.setId) or 0
	object.scoreId = tonumber(row.scoreId) or 0
	object.lamp = tonumber(row.lamp) ~= 0
end

local _asyncQueryAll = thread.async(function(queryParams)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
	local self = CacheDatabase()
	self:load()
	self.queryParams = queryParams
	local status, err = pcall(self.queryNoteChartSets, self)
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
	self:unload()

	local dt = math.floor((love.timer.getTime() - time) * 1000)
	print("query all: " .. dt .. "ms")
	print(("size: %d bytes"):format(#t.noteChartSetItems))
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

	local size = ffi.sizeof("EntryStruct")
	self.noteChartSetItems = ffi.new("EntryStruct[?]", #t.noteChartSetItems / size)
	ffi.copy(self.noteChartSetItems, t.noteChartSetItems, #t.noteChartSetItems)
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

	local columns = table_util.copy(select_columns)

	if params.lamp then
		local case = ("CASE WHEN %s THEN TRUE ELSE FALSE END"):format(
			sql_util.bind(sql_util.conditions(params.lamp))
		)
		if params.groupBy then
			case = ("max(%s)"):format(case)
		end
		table.insert(columns, case .. " AS lamp")
	end

	local options = {
		columns = columns,
		group = params.groupBy,
		order = params.orderBy,
	}

	if params.groupBy then
		columns[4] = "max(scoreId)"
	end

	local objs = self.orm:select("chartset_list", params.where, options)
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
		fillObject(entry, row)
		set_id_to_global_offset[entry.setId] = j
		chart_id_to_offset(id_to_global_offset, entry, j)
		c = c + 1
	end

	self.noteChartSetItemsCount = c
end

---@param setId number
---@return rdb.ModelRow[]
function CacheDatabase:getNoteChartItemsAtSet(setId)
	local params = self.queryParams

	local columns = {"*"}
	local where = table_util.copy(params.where)
	where.setId = setId

	if params.lamp then
		local case = ("CASE WHEN %s THEN TRUE ELSE FALSE END lamp"):format(
			sql_util.bind(sql_util.conditions(params.lamp))
		)
		table.insert(columns, case)
	end

	local options = {
		columns = columns,
		order = {
			"setId ASC",
			"length(inputMode) ASC",
			"inputMode ASC",
			"difficulty ASC",
			"name ASC",
			"noteChartDataId ASC",
		},
	}

	local objs = self.orm:select("chartset_list", where, options)
	for _, obj in ipairs(objs) do
		fillObject(obj, obj)
	end

	return objs
end

return CacheDatabase

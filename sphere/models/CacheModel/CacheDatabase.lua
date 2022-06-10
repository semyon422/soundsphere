local TimedCache = require("aqua.util.TimedCache")
local aquathread = require("aqua.thread")
local Orm = require("sphere.Orm")
local ObjectQuery = require("sphere.ObjectQuery")
local ffi = require("ffi")
local byte = require("byte")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"

CacheDatabase.load = function(self)
	if self.loaded then
		return
	end
	self.db = Orm:new()
	local db = self.db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/CacheModel/database.sql"))
	self:attachScores()
	self.loaded = true

	self.noteChartSetItemsCount = 0
	self.noteChartSetItems = {}
	self.entryKeyToGlobalOffset = {}
	self.noteChartSetIdToOffset = {}
	self.noteChartItemsCount = 0
	self.noteChartItems = {}
	self.noteChartSlices = {}
	self.entryKeyToLocalOffset = {}

	local entryCaches = {}
	for _, t in ipairs({"noteChartSets", "noteCharts", "noteChartDatas"}) do
		entryCaches[t] = TimedCache:new()
		entryCaches[t].timeout = 1
		entryCaches[t].loadObject = function(_, id)
			return self.db:select(t, "id = ?", id)[1]
		end
	end
	self.entryCaches = entryCaches

	self.queryParams = {}
end

CacheDatabase.unload = function(self)
	if not self.loaded then
		return
	end
	self.loaded = false
	self:detachScores()
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:begin()
end

CacheDatabase.commit = function(self)
	return self.db:commit()
end

CacheDatabase.attachScores = function(self)
	self.db:exec("ATTACH 'userdata/scores.db' AS scores_db")
end

CacheDatabase.detachScores = function(self)
	self.db:exec("DETACH scores_db")
end

----------------------------------------------------------------

CacheDatabase.getCachedEntry = function(self, t, id)
	return self.entryCaches[t]:getObject(id)
end

CacheDatabase.update = function(self)
	for _, entryCache in pairs(self.entryCaches) do
		entryCache:update()
	end
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartEntry = function(self, entry)
	return self.db:insert("noteCharts", entry, true)
end

CacheDatabase.updateNoteChartEntry = function(self, entry)
	return self.db:update("noteCharts", entry, "path = ?", entry.path)
end

CacheDatabase.selectNoteChartEntry = function(self, path)
	return self.db:select("noteCharts", "path = ?", path)[1]
end

CacheDatabase.selectNoteChartEntryById = function(self, id)
	return self.db:select("noteCharts", "id = ?", id)[1]
end

CacheDatabase.deleteNoteChartEntry = function(self, path)
	return self.db:delete("noteCharts", "path = ?", path)
end

CacheDatabase.getNoteChartsAtSet = function(self, setId)
	return self.db:select("noteCharts", "setId = ?", setId)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartSetEntry = function(self, entry)
	return self.db:insert("noteChartSets", entry, true)
end

CacheDatabase.updateNoteChartSetEntry = function(self, entry)
	return self.db:update("noteChartSets", entry, "path = ?", entry.path)
end

CacheDatabase.selectNoteChartSetEntry = function(self, path)
	return self.db:select("noteChartSets", "path = ?", path)[1]
end

CacheDatabase.selectNoteChartSetEntryById = function(self, id)
	return self.db:select("noteChartSets", "id = ?", id)[1]
end

CacheDatabase.deleteNoteChartSetEntry = function(self, path)
	return self.db:delete("noteChartSets", "path = ?", path)
end

CacheDatabase.selectNoteChartSets = function(self, path)
	return self.db:select("noteChartSets", "substr(path, 1, ?) = ?", #path, path)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartDataEntry = function(self, entry)
	return self.db:insert("noteChartDatas", entry, true)
end

CacheDatabase.updateNoteChartDataEntry = function(self, entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

CacheDatabase.selectNoteCharDataEntry = function(self, hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

CacheDatabase.selectNoteChartDataEntryById = function(self, id)
	return self.db:select("noteChartDatas", "id = ?", id)[1]
end

----------------------------------------------------------------

ffi.cdef([[
	typedef struct {
		uint32_t noteChartDataId;
		uint32_t noteChartId;
		uint32_t setId;
		uint32_t scoreId;
		bool lamp;
	} EntryStruct
]])

CacheDatabase.EntryStruct = ffi.typeof("EntryStruct")

ffi.metatype("EntryStruct", {__index = function(t, k)
	if k == "key" then
		return
			byte.double_to_string_le(t.noteChartDataId) ..
			byte.double_to_string_le(t.noteChartId) ..
			byte.double_to_string_le(t.setId)
	elseif k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "scoreId" or k == "lamp" then
		return rawget(t, k)
	end
end})

local function fillObject(object, row, colnames)
	for i, k in ipairs(colnames) do
		local value = row[i]
		if k:find("^__boolean_") then
			k = k:sub(11)
			if tonumber(value) == 1 then
				value = true
			else
				value = false
			end
		elseif type(value) == "cdata" then
			value = tonumber(value) or value
		end
		object[k] = value or 0
	end
end

CacheDatabase.queryAll = function(self)
	self:queryNoteChartSets()
	self:queryNoteCharts()
end

local _asyncQueryAll = aquathread.async(function(queryParams)
	local time = love.timer.getTime()
	local ffi = require("ffi")
	local self = require("sphere.models.CacheModel.CacheDatabase")
	self:load()
	self.queryParams = queryParams
	local status, err = pcall(self.queryAll, self)
	if not status then
		return
	end
	local t = {
		noteChartSetItemsCount = self.noteChartSetItemsCount,
		entryKeyToGlobalOffset = self.entryKeyToGlobalOffset,
		noteChartSetIdToOffset = self.noteChartSetIdToOffset,
		noteChartItemsCount = self.noteChartItemsCount,
		noteChartSlices = self.noteChartSlices,
		entryKeyToLocalOffset = self.entryKeyToLocalOffset,
		noteChartSetItems = ffi.string(self.noteChartSetItems, ffi.sizeof(self.noteChartSetItems)),
		noteChartItems = ffi.string(self.noteChartItems, ffi.sizeof(self.noteChartItems)),
	}
	self:unload()
	print("query all: " .. math.floor((love.timer.getTime() - time) * 1000) .. "ms")
	return t
end)

CacheDatabase.asyncQueryAll = function(self)
	local t = _asyncQueryAll(self.queryParams)
	if not t then
		return
	end

	self.noteChartSetItemsCount = t.noteChartSetItemsCount
	self.entryKeyToGlobalOffset = t.entryKeyToGlobalOffset
	self.noteChartSetIdToOffset = t.noteChartSetIdToOffset
	self.noteChartItemsCount = t.noteChartItemsCount
	self.noteChartSlices = t.noteChartSlices
	self.entryKeyToLocalOffset = t.entryKeyToLocalOffset

	local size = ffi.sizeof("EntryStruct")
	self.noteChartSetItems = ffi.new("EntryStruct[?]", #t.noteChartSetItems / size)
	self.noteChartItems = ffi.new("EntryStruct[?]", #t.noteChartItems / size)
	ffi.copy(self.noteChartSetItems, t.noteChartSetItems, #t.noteChartSetItems)
	ffi.copy(self.noteChartItems, t.noteChartItems, #t.noteChartItems)
end

CacheDatabase.queryNoteChartSets = function(self)
	local params = CacheDatabase.queryParams

	local objectQuery = ObjectQuery:new()

	objectQuery.db = self.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.setId",
		"scores.id AS scoreId",
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	objectQuery:setLeftJoin("scores", [[
		noteChartDatas.hash = scores.noteChartHash AND
		noteChartDatas.`index` = scores.noteChartIndex AND
		scores.isTop = TRUE
	]])

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = params.groupBy
	objectQuery.orderBy = params.orderBy

	local count = objectQuery:getCount()
	local noteChartSets = ffi.new("EntryStruct[?]", count)
	local entryKeyToGlobalOffset = {}
	local noteChartSetIdToOffset = {}
	self.noteChartSetItems = noteChartSets
	self.entryKeyToGlobalOffset = entryKeyToGlobalOffset
	self.noteChartSetIdToOffset = noteChartSetIdToOffset

	local stmt = self.db:stmt(objectQuery:getQueryParams())
	local colnames = {}

	local row = stmt:step({}, colnames)
	local i = 0
	while row do
		local entry = noteChartSets[i]
		fillObject(entry, row, colnames)
		noteChartSetIdToOffset[entry.setId] = i
		entryKeyToGlobalOffset[entry.key] = i
		i = i + 1
		row = stmt:step(row)
	end
	stmt:close()
	self.noteChartSetItemsCount = i
end

CacheDatabase.queryNoteCharts = function(self)
	local params = CacheDatabase.queryParams

	local objectQuery = ObjectQuery:new()

	self:load()
	objectQuery.db = self.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.setId",
		"scores.id AS scoreId",
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	objectQuery:setLeftJoin("scores", [[
		noteChartDatas.hash = scores.noteChartHash AND
		noteChartDatas.`index` = scores.noteChartIndex AND
		scores.isTop = TRUE
	]])

	if params.lamp then
		table.insert(objectQuery.fields, objectQuery:newBooleanCase("lamp", params.lamp))
	end

	objectQuery.where = params.where
	objectQuery.groupBy = nil
	objectQuery.orderBy = [[
		noteCharts.setId ASC,
		length(noteChartDatas.inputMode) ASC,
		noteChartDatas.inputMode ASC,
		noteChartDatas.difficulty ASC,
		noteChartDatas.name ASC,
		noteChartDatas.id ASC
	]]

	local count = objectQuery:getCount()
	local noteCharts = ffi.new("EntryStruct[?]", count)
	local slices = {}
	local entryKeyToLocalOffset = {}
	self.noteChartItems = noteCharts
	self.noteChartSlices = slices
	self.entryKeyToLocalOffset = entryKeyToLocalOffset

	local stmt = self.db:stmt(objectQuery:getQueryParams())
	local colnames = {}

	local offset = 0
	local size = 0
	local setId
	local row = stmt:step({}, colnames)
	local i = 0
	while row do
		local entry = noteCharts[i]
		fillObject(entry, row, colnames)
		if setId and setId ~= entry.setId then
			slices[setId] = {
				offset = offset,
				size = size,
			}
			offset = i
		end
		size = i - offset + 1
		setId = entry.setId
		entryKeyToLocalOffset[entry.key] = i - offset
		i = i + 1
		row = stmt:step(row)
	end
	if setId then
		slices[setId] = {
			offset = offset,
			size = size,
		}
	end
	stmt:close()
	self.noteChartItemsCount = i
end

return CacheDatabase

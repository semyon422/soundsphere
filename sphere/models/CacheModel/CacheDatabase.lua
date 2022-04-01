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
	self.loaded = true

	-- self.noteChartSetItemsCount = 0
	-- self.noteChartSetItems = {}
	-- self.entryKeyToGlobalOffset = {}
	-- self.noteChartSetIdToOffset = {}
	-- self.noteChartItemsCount = 0
	-- self.noteChartItems = {}
	-- self.noteChartSlices = {}
	-- self.entryKeyToLocalOffset = {}

	self:queryAll()
end

CacheDatabase.unload = function(self)
	if not self.loaded then
		return
	end
	self.loaded = false
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:begin()
end

CacheDatabase.commit = function(self)
	return self.db:commit()
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
		double noteChartDataId;
		double noteChartId;
		double setId;
	} EntryStruct
]])

CacheDatabase.EntryStruct = ffi.typeof("EntryStruct")

ffi.metatype("EntryStruct", {__index = function(t, k)
	if k == "key" then
		return
			byte.double_to_string_le(t.noteChartDataId) ..
			byte.double_to_string_le(t.noteChartId) ..
			byte.double_to_string_le(t.setId)
	elseif k == "noteChartDataId" or k == "noteChartId" or k == "setId" then
		return rawget(t, k)
	end
end})

local function fillObject(object, row, colnames)
	for i, k in ipairs(colnames) do
		object[k] = row[i]
	end
end

CacheDatabase.queryAll = function(self, params, ...)
	params = params or {}

	local objectQuery = ObjectQuery:new()

	self:load()
	objectQuery.db = self.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.setId",
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")

	-- notechart sets
	objectQuery.where = params.where
	objectQuery.groupBy = params.groupBy
	objectQuery.orderBy = params.orderBy

	local count = objectQuery:getCount(...)
	local noteChartSets = ffi.new("EntryStruct[?]", count)
	local entryKeyToGlobalOffset = {}
	local noteChartSetIdToOffset = {}
	self.noteChartSetItemsCount = count
	self.noteChartSetItems = noteChartSets
	self.entryKeyToGlobalOffset = entryKeyToGlobalOffset
	self.noteChartSetIdToOffset = noteChartSetIdToOffset

	local stmt = self.db:stmt(objectQuery:getQueryParams(), ...)
	local colnames = {}

	local row = stmt:step({}, colnames)
	local i = 0
	while row do
		if i < count then
			local entry = noteChartSets[i]
			fillObject(entry, row, colnames)
			noteChartSetIdToOffset[entry.setId] = i
			entryKeyToGlobalOffset[entry.key] = i
		end
		i = i + 1
		row = stmt:step(row)
	end

	-- notecharts
	objectQuery.where = params.where
	objectQuery.groupBy = nil
	objectQuery.orderBy = "setId ASC"  -- add sort by input mode, etc

	count = objectQuery:getCount(...)
	local noteCharts = ffi.new("EntryStruct[?]", count)
	local slices = {}
	local entryKeyToLocalOffset = {}
	self.noteChartItemsCount = count
	self.noteChartItems = noteCharts
	self.noteChartSlices = slices
	self.entryKeyToLocalOffset = entryKeyToLocalOffset

	stmt = self.db:stmt(objectQuery:getQueryParams(), ...)

	local offset = 0
	local size = 0
	local setId
	row = stmt:step({}, colnames)
	i = 0
	while row do
		if i < count then
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
		end
		i = i + 1
		row = stmt:step(row)
	end
end

return CacheDatabase

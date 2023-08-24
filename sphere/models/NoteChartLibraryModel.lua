local class = require("class")
local ExpireTable = require("ExpireTable")
local table_util = require("table_util")
local path_util = require("path_util")

---@class sphere.NoteChartLibraryModel
---@operator call: sphere.NoteChartLibraryModel
local NoteChartLibraryModel = class()

NoteChartLibraryModel.setId = 1
NoteChartLibraryModel.itemsCount = 1

function NoteChartLibraryModel:new()
	local cache = ExpireTable()
	self.cache = cache
	self.cache.load = function(_, k)
		return self:loadObject(k)
	end

	self.items = newproxy(true)
	local mt = getmetatable(self.items)
	function mt.__index(_, i)
		if i < 1 or i > self.itemsCount then return end
		return cache:get(i)
	end
	function mt.__len()
		return self.itemsCount
	end
end

local NoteChartItem = {}
NoteChartItem.__index = NoteChartItem

---@return string?
function NoteChartItem:getBackgroundPath()
	local path = self.path
	if not path or not self.stagePath then
		return
	end

	if path:find("%.ojn$") or path:find("%.mid$") then
		return path
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""
	local stagePath = self.stagePath

	if stagePath and stagePath ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. stagePath)
	end

	return directoryPath
end

---@return string?
---@return number?
function NoteChartItem:getAudioPathPreview()
	if not self.path or not self.audioPath then
		return
	end

	local directoryPath = self.path:match("^(.+)/(.-)$") or ""
	local audioPath = self.audioPath

	if audioPath and audioPath ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. audioPath), math.max(0, self.previewTime or 0)
	end

	return directoryPath .. "/preview.ogg", 0
end

---@param itemIndex number
---@return table
function NoteChartLibraryModel:loadObject(itemIndex)
	local chartRepo = self.cacheModel.chartRepo
	local slice = self.cacheModel.cacheDatabase.noteChartSlices[self.setId]
	local entry = self.cacheModel.cacheDatabase.noteChartItems[slice.offset + itemIndex - 1]
	local noteChart = chartRepo:selectNoteChartEntryById(entry.noteChartId)
	local noteChartData = chartRepo:selectNoteChartDataEntryById(entry.noteChartDataId)

	local item = {
		noteChartDataId = entry.noteChartDataId,
		noteChartId = entry.noteChartId,
		setId = entry.setId,
		lamp = entry.lamp,
		itemIndex = itemIndex,
	}

	table_util.copy(noteChart, item)
	table_util.copy(noteChartData, item)

	return setmetatable(item, NoteChartItem)
end

function NoteChartLibraryModel:clear()
	self.itemsCount = 0
	self.cache:new()
end

---@param setId number
function NoteChartLibraryModel:setNoteChartSetId(setId)
	self.setId = setId
	local slice = self.cacheModel.cacheDatabase.noteChartSlices[setId]
	if not slice then
		self.itemsCount = 0
		return
	end
	self.itemsCount = slice.size
	self.cache:new()
end

---@param noteChartId number?
---@return number
function NoteChartLibraryModel:getItemIndex(noteChartId)
	return (self.cacheModel.cacheDatabase.id_to_local_offset[noteChartId] or 0) + 1
end

return NoteChartLibraryModel

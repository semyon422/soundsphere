local class = require("class")
local ExpireTable = require("ExpireTable")
local table_util = require("table_util")

---@class sphere.NoteChartLibrary
---@operator call: sphere.NoteChartLibrary
local NoteChartLibrary = class()

NoteChartLibrary.setId = 0
NoteChartLibrary.itemsCount = 0

function NoteChartLibrary:new()
	self.items = {}
end

function NoteChartLibrary:clear()
	self.items = {}
end

---@param setId number
function NoteChartLibrary:setNoteChartSetId(setId)
	if setId == self.setId then
		return
	end
	self.setId = setId
	self.items = self.cacheModel.cacheDatabase:getNoteChartItemsAtSet(setId)
end

---@param noteChartId number?
---@param noteChartDataId number?
---@return number
function NoteChartLibrary:getItemIndex(noteChartId, noteChartDataId)
	for i, chart in ipairs(self.items) do
		if chart.noteChartId == noteChartId and chart.noteChartDataId == noteChartDataId then
			return i
		end
	end
	return 1
end

return NoteChartLibrary

local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local CustomList			= require("sphere.ui.CustomList")
local ScoreListButton		= require("sphere.ui.ScoreListButton")
local NoteChartList			= require("sphere.ui.NoteChartList")

local ScoreList = CustomList:new()

ScoreList.x = 0
ScoreList.y = 4/17
ScoreList.w = 0.2
ScoreList.h = 9/17

ScoreList.sender = ScoreList

ScoreList.buttonCount = 9
ScoreList.middleOffset = 5
ScoreList.startOffset = 5
ScoreList.endOffset = 5

ScoreList.needItemsSort = true

ScoreList.Button = ScoreListButton

ScoreList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

ScoreList.load = function(self)
	self:selectScores()
	self:reload()
end

ScoreList.receive = function(self, event)
	if event.action == "updateMetaData" then
		self:selectScores()
		self:reload()
	end

	return CustomList.receive(self, event)
end

ScoreList.selectScores = function(self)
	local items = {}

	local selectedItem = NoteChartList.items[NoteChartList.focusedItemIndex]
	if not selectedItem then
		print(NoteChartList.focusedItemIndex)
		return self:setItems(items)
	end

	local hash = selectedItem.noteChartDataEntry.hash
	local index = selectedItem.noteChartDataEntry.index
	local scoreEntries = self.scoreModel:getScoreEntries(hash, index)
	
	if not scoreEntries then
		return self:setItems(items)
	end

	for i = 1, #scoreEntries do
		items[#items + 1] = {
			scoreEntry = scoreEntries[i]
		}
	end

	return self:setItems(items)
end

ScoreList:init()

return ScoreList

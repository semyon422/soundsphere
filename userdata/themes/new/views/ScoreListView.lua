
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local ScoreListView = Node:new()

ScoreListView.init = function(self)
	local ListView = dofile(self.__path .. "/views/ListView.lua")
	local listView = ListView:new()
	self.listView = listView

	listView.__path = self.__path
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 17
	listView.selectedItem = 1

	self.selectedNoteChart = 1
	self.hash = ""
	self.index = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.selectNavigator.scoreList.selected

		local oldSelected = self.selectedNoteChart
		local newSelected = self.selectNavigator.noteChartList.selected
		if oldSelected ~= newSelected then
			self.hash = self.noteChartListView.listView.items[newSelected].noteChartDataEntry.hash
			self.index = self.noteChartListView.listView.items[newSelected].noteChartDataEntry.index
			self:reloadItems()
		end
		self.selectedSet = newSelected
	end)
	listView:on("select", function()
		self.selectNavigator:setNode("scoreList")
		self.view.selectedNode = self
	end)

	self:node(listView)
	self.pass = true
end

ScoreListView.reloadItems = function(self)
	local scoreEntries = self.view.scoreModel:getScoreEntries(
		self.hash,
		self.index
	)
	local items = {}
	if scoreEntries then
		for _, scoreEntry in ipairs(scoreEntries) do
			items[#items + 1] = {
				scoreEntry = scoreEntry,
				name = scoreEntry.score
			}
		end
	end
	self.listView.items = items
end

return ScoreListView

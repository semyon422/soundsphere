local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ScoreListItemView = require(viewspackage .. "SelectView.ScoreListItemView")

local ScoreListView = ListView:new()

ScoreListView.init = function(self)
	self.ListItemView = ScoreListItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 2 + 16 / 9 * (0.61803 ^ 2 - 0.61803 * (1 - 0.61803))
	self.y = 1 / 15
	self.w = 16 / 9 * 0.61803 * (1 - 0.61803)
	self.h = 13 / 15
	self.itemCount = 13
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.scoreItemIndex
		self:reloadItems()
	end)
	self:on("select", function()
		-- self.navigator:setNode("scoreList")
	end)
	self:on("draw", self.drawFrame)

	ListView.init(self)
end

ScoreListView.reloadItems = function(self)
	self.items = self.view.scoreLibraryModel.items
end

ScoreListView.drawFrame = function(self)
	if self.navigator:checkNode("scoreList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return ScoreListView

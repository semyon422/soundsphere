local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local InputListItemView = require(viewspackage .. "InputView.InputListItemView")

local InputListView = ListView:new()

InputListView.init = function(self)
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3 / 2
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1
	self.activeItem = self.selectedItem

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.inputList.selected
		-- self:reloadItems()
	end)
	self:on("select", function()
		-- self.navigator:setNode("inputList")
	end)
	self:on("draw", self.drawFrame)
	self:on("wheelmoved", self.receive)
	self:on("mousepressed", self.receive)
	self:on("mousereleased", self.receive)
	self:on("mousemoved", self.receive)

	self:on("wheelmoved", function(self, event)
		local mx, my = love.mouse.getPosition()
		local cs = self.cs
		local x = cs:X(self.x, true)
		local w = cs:X(self.w)
		if mx >= x and mx < x + w then
			local wy = event.args[2]
			if wy == 1 then
				self.navigator:call("up")
			elseif wy == -1 then
				self.navigator:call("down")
			end
		end
	end)

	ListView.init(self)
end

InputListView.createListItemViews = function(self)
	local itemView = InputListItemView:new()
	itemView.listView = self
	itemView:init()
	self.itemView = itemView
end

InputListView.getListItemView = function(self)
	return self.itemView
end

InputListView.reloadItems = function(self)
    local noteChart = self.view.noteChartModel.noteChart
    self.inputModeString = noteChart.inputMode:getString()
    self.items = self.view.inputModel:getInputs(self.inputModeString)
end

InputListView.drawFrame = function(self)
	if self.navigator:checkNode("inputList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return InputListView

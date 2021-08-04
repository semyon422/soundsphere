local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local InputListItemView = require(viewspackage .. "InputView.InputListItemView")

local InputListView = ListView:new()

InputListView.construct = function(self)
	ListView.construct(self)
	self.itemView = InputListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

InputListView.reloadItems = function(self)
    local noteChart = self.noteChartModel.noteChart
    local inputModeString = noteChart.inputMode:getString()
    self.state.items = self.inputModel:getInputs(inputModeString)
	self.inputModeString = inputModeString
end

InputListView.getItemIndex = function(self)
	return self.navigator.itemIndex
end

InputListView.scrollUp = function(self)
	self.navigator:scrollInput("up")
end

InputListView.scrollDown = function(self)
	self.navigator:scrollInput("down")
end

InputListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

return InputListView
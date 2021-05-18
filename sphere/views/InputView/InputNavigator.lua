local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local InputNavigator = Navigator:new()

InputNavigator.construct = function(self)
	self.itemIndex = 1
	self.inputItemIndex = 1
	self.virtualKey = ""
	self.activeElement = "list"
end

InputNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if self.activeElement == "list" then
		if scancode == "up" then self:scrollInput("up")
		elseif scancode == "down" then self:scrollInput("down")
		elseif scancode == "return" then self:setInputHandler()
		elseif scancode == "escape" then self:changeScreen("Select")
		end
	elseif self.activeElement == "inputHandler" then
		self:setInputBinding(scancode)
	end
end

InputNavigator.scrollInput = function(self, direction)
	local noteChart = self.noteChartModel.noteChart
	local inputModeString = noteChart.inputMode:getString()
	local inputs = self.inputModel:getInputs(inputModeString)

	direction = direction == "up" and -1 or 1
	if not inputs[self.itemIndex + direction] then
		return
	end
	self.itemIndex = self.itemIndex + direction
end

InputNavigator.setInputHandler = function(self, itemIndex)
	local noteChart = self.noteChartModel.noteChart
	local inputModeString = noteChart.inputMode:getString()
	local inputs = self.inputModel:getInputs(inputModeString)
	self.virtualKey = inputs[itemIndex or self.itemIndex].virtualKey
	self.inputModeString = inputModeString

	self.inputItemIndex = itemIndex or self.itemIndex
	self.activeElement = "inputHandler"
end

InputNavigator.setInputBinding = function(self, scancode)
	self:send({
		name = "setInputBinding",
		virtualKey = self.virtualKey,
		value = scancode,
		type = "keyboard",
		inputMode = self.inputModeString,
	})
	self.activeElement = "list"
end

return InputNavigator

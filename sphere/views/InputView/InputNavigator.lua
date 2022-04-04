local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local InputNavigator = Navigator:new({construct = false})

InputNavigator.construct = function(self)
	Navigator.construct(self)
	self.itemIndex = 1
	self.inputItemIndex = 1
	self.virtualKey = ""
	self.activeElement = "list"
end

InputNavigator.receive = function(self, event)
	if self.activeElement == "inputHandler" then
		if event.name == "keypressed" then
			self:setInputBinding("keyboard", event[2])
		elseif event.name == "gamepadpressed" then
			self:setInputBinding("gamepad", event[2])
		elseif event.name == "joystickpressed" then
			self:setInputBinding("joystick", event[2])
		elseif event.name == "midipressed" then
			self:setInputBinding("midi", event[1])
		end
		return
	end

	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]
	if self.activeElement == "list" then
		if scancode == "up" then self:scrollInput("up")
		elseif scancode == "down" then self:scrollInput("down")
		elseif scancode == "return" then self:setInputHandler()
		elseif scancode == "escape" then self:changeScreen("Select")
		elseif scancode == "f1" then self:switchSubscreen("debug")
		end
	end
end

InputNavigator.scrollInput = function(self, direction)
	local noteChart = self.gameController.noteChartModel.noteChart
	local inputModeString = noteChart.inputMode:getString()
	local inputs = self.gameController.inputModel:getInputs(inputModeString)

	direction = direction == "up" and -1 or 1
	if not inputs[self.itemIndex + direction] then
		return
	end
	self.itemIndex = self.itemIndex + direction
end

InputNavigator.setInputHandler = function(self, itemIndex)
	local noteChart = self.gameController.noteChartModel.noteChart
	local inputModeString = noteChart.inputMode:getString()
	local inputs = self.gameController.inputModel:getInputs(inputModeString)
	self.virtualKey = inputs[itemIndex or self.itemIndex].virtualKey
	self.inputModeString = inputModeString

	self.inputItemIndex = itemIndex or self.itemIndex
	self.activeElement = "inputHandler"
end

InputNavigator.setInputBinding = function(self, type, value)
	self:send({
		name = "setInputBinding",
		virtualKey = self.virtualKey,
		value = value,
		type = type,
		inputMode = self.inputModeString,
	})
	self.activeElement = "list"
end

return InputNavigator

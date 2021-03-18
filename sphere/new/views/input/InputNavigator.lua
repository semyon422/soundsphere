local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local InputNavigator = Navigator:new()

InputNavigator.construct = function(self)
	Navigator.construct(self)

	local inputList = Node:new()
	self.inputList = inputList
	inputList.selected = 1

	local inputHandler = Node:new()
	self.inputHandler = inputHandler
	inputHandler.virtualKey = ""
	inputHandler.key = ""
end

InputNavigator.scrollInput = function(self, direction, destination)
	local inputList = self.inputList

	local noteChart = self.view.noteChartModel.noteChart
	local inputModeString = noteChart.inputMode:getString()
	local inputs = self.view.inputModel:getInputs(inputModeString)

	direction = direction or destination - inputList.selected
	if not inputs[inputList.selected + direction] then
		return
	end

	inputList.selected = inputList.selected + direction
end

InputNavigator.addItems = function(self)
	local noteChart = self.menu.noteChart

	if not noteChart then
		return
	end

	local items = {}

	--value = self.inputModel:getKey(self:getSelectedInputMode(), self.item.virtualKey)
	for inputCount, inputType in self.noteChart.inputMode:getString():gmatch("([0-9]+)([a-z]+)") do
		for i = 1, inputCount do
			items[#items + 1] = {
				name = inputType .. i,
				type = "input",
				virtualKey = inputType .. i
			}
		end
	end

	return self:setItems(items)
end

InputNavigator.load = function(self)
	Navigator.load(self)

	local inputList = self.inputList
	local inputHandler = self.inputHandler

	self.node = inputList
	inputList:on("up", function()
		self:scrollInput(-1)
	end)
	inputList:on("down", function()
		self:scrollInput(1)
	end)
	inputList:on("return", function(_, itemIndex)
		local noteChart = self.view.noteChartModel.noteChart
		local inputModeString = noteChart.inputMode:getString()
		local inputs = self.view.inputModel:getInputs(inputModeString)
		inputHandler.virtualKey = inputs[itemIndex or inputList.selected].virtualKey
		inputHandler.inputModeString = inputModeString
		self.node = inputHandler
	end)
	inputList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)

	inputHandler:on("keypressed", function(_, key, type)
		self:send({
			name = "setInputBinding",
			virtualKey = inputHandler.virtualKey,
			value = key,
			type = type,
			inputMode = inputHandler.inputModeString,
		})
		self.node = inputList
	end)
end

InputNavigator.receive = function(self, event)
	if event.name == "keypressed" and self.node == self.inputList then
		self:call(event.args[1])
		return
	end

	if event.name == "keypressed" then
		self:call("keypressed", event.args[1], "keyboard")
	elseif event.name == "gamepadpressed" then
		self:call("keypressed", tostring(event.args[2]), "gamepad")
	elseif event.name == "joystickpressed" then
		self:call("keypressed", tostring(event.args[2]), "joystick")
	elseif event.name == "midipressed" then
		self:call("keypressed", tostring(event.args[1]), "midi")
	end
end

return InputNavigator

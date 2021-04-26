local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local SettingsNavigator = Navigator:new()

SettingsNavigator.construct = function(self)
	Navigator.construct(self)

	local settingsList = Node:new()
	self.settingsList = settingsList
	settingsList.selected = 1

	local sectionsList = Node:new()
	self.sectionsList = sectionsList
	sectionsList.selected = 1

	local inputHandler = Node:new()
	self.inputHandler = inputHandler
	inputHandler.key = ""
end

SettingsNavigator.scrollCategories = function(self, direction, destination)
	local sectionsList = self.sectionsList

	local sections = self.view.settingsModel.sections

	direction = direction or destination - sectionsList.selected
	if not sections[sectionsList.selected + direction] then
		return
	end

	sectionsList.selected = sectionsList.selected + direction
end

SettingsNavigator.scrollSettings = function(self, direction, destination)
	local settingsList = self.settingsList
	local sectionsList = self.sectionsList

	local settings = self.view.settingsModel.sections[sectionsList.selected]

	direction = direction or destination - settingsList.selected
	if not settings[settingsList.selected + direction] then
		return
	end

	settingsList.selected = settingsList.selected + direction
end

SettingsNavigator.load = function(self)
	Navigator.load(self)

	local sectionsList = self.sectionsList
	local settingsList = self.settingsList
	local inputHandler = self.inputHandler

	self.node = sectionsList
	sectionsList:on("up", function()
		self:scrollCategories(-1)
	end)
	sectionsList:on("down", function()
		self:scrollCategories(1)
	end)
	sectionsList:on("tab", function()
		self.node = settingsList
	end)
	sectionsList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)

	settingsList:on("up", function()
		self:scrollSettings(-1)
	end)
	settingsList:on("down", function()
		self:scrollSettings(1)
	end)
	settingsList:on("tab", function()
		self.node = sectionsList
	end)
	settingsList:on("backspace", function(_, itemIndex)
		self:send({
			name = "resetSettingsItem",
			sectionIndex = sectionsList.selected,
			settingIndex = itemIndex or settingsList.selected
		})
	end)
	settingsList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)

	inputHandler:on("keypressed", function(_, key, type)
		self:send({
			name = "setInputBinding",
			sectionName = inputHandler.sectionName,
			settingName = inputHandler.settingName,
			value = key,
			type = type
		})
		self.node = settingsList
	end)
end

SettingsNavigator.receive = function(self, event)
	if event.name == "keypressed" and self.node ~= self.inputHandler then
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

return SettingsNavigator

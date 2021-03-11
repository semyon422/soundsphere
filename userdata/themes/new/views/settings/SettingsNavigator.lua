local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local SettingsNavigator = Navigator:new()

SettingsNavigator.construct = function(self)
	Navigator.construct(self)

	local settingsList = Node:new()
	self.settingsList = settingsList
	settingsList.selected = 1

	local categoriesList = Node:new()
	self.categoriesList = categoriesList
	categoriesList.selected = 1

	local inputHandler = Node:new()
	self.inputHandler = inputHandler
	inputHandler.key = ""
end

SettingsNavigator.scrollCategories = function(self, direction, destination)
	local categoriesList = self.categoriesList

	local categories = self.config_settings_model

	direction = direction or destination - categoriesList.selected
	if not categories[categoriesList.selected + direction] then
		return
	end

	categoriesList.selected = categoriesList.selected + direction
end

SettingsNavigator.scrollSettings = function(self, direction, destination)
	local settingsList = self.settingsList
	local categoriesList = self.categoriesList

	local settings = self.config_settings_model[categoriesList.selected].items

	direction = direction or destination - settingsList.selected
	if not settings[settingsList.selected + direction] then
		return
	end

	settingsList.selected = settingsList.selected + direction
end

SettingsNavigator.load = function(self)
	Navigator.load(self)

	local categoriesList = self.categoriesList
	local settingsList = self.settingsList
	local inputHandler = self.inputHandler

	self.node = categoriesList
	categoriesList:on("up", function()
		self:scrollCategories(-1)
	end)
	categoriesList:on("down", function()
		self:scrollCategories(1)
	end)
	categoriesList:on("tab", function()
		self.node = settingsList
	end)
	categoriesList:on("escape", function()
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
		self.node = categoriesList
	end)
	settingsList:on("backspace", function(_, itemIndex)
		self:send({
			name = "resetSettingsItem",
			categoryIndex = categoriesList.selected,
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
			categoryName = inputHandler.categoryName,
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

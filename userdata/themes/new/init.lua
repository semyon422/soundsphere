local themepackage = (...) .. "."

local Theme = require("sphere.models.ThemeModel.Theme")
local SelectView = require(themepackage .. "views.select.SelectView")
local ModifierView = require(themepackage .. "views.modifier.ModifierView")
local NoteSkinView = require(themepackage .. "views.noteskin.NoteSkinView")
local InputView = require(themepackage .. "views.input.InputView")
local SettingsView = require(themepackage .. "views.settings.SettingsView")

local UserTheme = Theme:new()

UserTheme.newView = function(self, name)
	if name == "SelectView" then
		return SelectView:new()
	elseif name == "ModifierView" then
		return ModifierView:new()
	elseif name == "NoteSkinView" then
		return NoteSkinView:new()
	elseif name == "InputView" then
		return InputView:new()
	elseif name == "SettingsView" then
		return SettingsView:new()
	end
	return self.viewFactory:newView(name)
end

return UserTheme

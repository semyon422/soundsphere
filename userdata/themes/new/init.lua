local themepackage = (...) .. "."

local Theme = require("sphere.models.ThemeModel.Theme")
local SelectView = require(themepackage .. "views.select.SelectView")
local ModifierView = require(themepackage .. "views.modifier.ModifierView")

local UserTheme = Theme:new()

UserTheme.newView = function(self, name)
	if name == "SelectView" then
		return SelectView:new()
	elseif name == "ModifierView" then
		return ModifierView:new()
	end
	return self.viewFactory:newView(name)
end

return UserTheme

local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SelectView = require(viewspackage .. "SelectView")
local ModifierView = require(viewspackage .. "ModifierView")
local NoteSkinView = require(viewspackage .. "NoteSkinView")
local InputView = require(viewspackage .. "InputView")
local SettingsView = require(viewspackage .. "SettingsView")
local ResultView = require(viewspackage .. "ResultView")
local GameplayView = require(viewspackage .. "GameplayView")
local ErrorView = require(viewspackage .. "ErrorView")

local ViewFactory = Class:new()

ViewFactory.newView = function(self, name)
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
	elseif name == "ResultView" then
		return ResultView:new()
	elseif name == "GameplayView" then
		return GameplayView:new()
	elseif name == "ErrorView" then
		return ErrorView:new()
	end
end

return ViewFactory

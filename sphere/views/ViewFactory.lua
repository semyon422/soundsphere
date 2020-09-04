local Class = require("aqua.util.Class")
local SelectView = require("sphere.views.SelectView")
local SettingsView = require("sphere.views.SettingsView")
local ResultView = require("sphere.views.ResultView")
local GameplayView = require("sphere.views.GameplayView")
local BrowserView = require("sphere.views.BrowserView")

local ViewFactory = Class:new()

ViewFactory.newView = function(self, name)
	if name == "SelectView" then
		return SelectView:new()
	elseif name == "SettingsView" then
		return SettingsView:new()
	elseif name == "ResultView" then
		return ResultView:new()
	elseif name == "GameplayView" then
		return GameplayView:new()
	elseif name == "BrowserView" then
		return BrowserView:new()
	end
end

return ViewFactory

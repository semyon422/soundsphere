local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GUI = require("sphere.ui.GUI")

local SettingsList		= require("sphere.ui.SettingsList")
local CategoriesList	= require("sphere.ui.CategoriesList")
local SelectFrame		= require("sphere.ui.SelectFrame")

local SettingsView = Class:new()

SettingsView.construct = function(self)
    self.container = Container:new()
	self.gui = GUI:new()
end

SettingsView.load = function(self)
    local container = self.container
	local gui = self.gui

	gui.container = container
	gui:load("userdata/interface/settings.json")
	gui.observable:add(self)
	gui.observable:add(self.controller)

	SettingsList.configModel = self.configModel

	SettingsList:init()
	CategoriesList:init()
	SettingsList.observable:add(self)
    CategoriesList.observable:add(self)
	SettingsList.observable:add(self.controller)
    CategoriesList.observable:add(self.controller)

	gui:reload()

	SettingsList:load()
	CategoriesList:load()
	SelectFrame:reload()

	BackgroundManager:setColor({63, 63, 63})
end

SettingsView.unload = function(self)
	SettingsList.observable:remove(self)
    CategoriesList.observable:remove(self)
	SettingsList.observable:remove(self.controller)
    CategoriesList.observable:remove(self.controller)
	self.gui.observable:remove(self)
	self.gui.observable:remove(self.controller)
end

SettingsView.receive = function(self, event)
    if event.name == "resize" then
		SettingsList:reload()
		CategoriesList:reload()
		SelectFrame:reload()
		return
	end

	SettingsList:receive(event)
	CategoriesList:receive(event)
	self.gui:receive(event)

	if event.name == "keypressed" and event.args[1] == self.configModel:get("screen.settings") then
		self.controller:receive({
			name = "setScreen",
			screenName = "SelectScreen"
		})
	end
end

SettingsView.update = function(self, dt)
    self.container:update()

	SettingsList:update()
	CategoriesList:update()

	self.gui:update()
end

SettingsView.draw = function(self)
	self.container:draw()

	SettingsList:draw()
	CategoriesList:draw()
	SelectFrame:draw()
end

return SettingsView

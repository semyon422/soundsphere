local Config			= require("sphere.config.Config")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local SettingsList		= require("sphere.screen.Settings.SettingsList")
local CategoriesList	= require("sphere.screen.Settings.CategoriesList")
local SelectFrame		= require("sphere.screen.Settings.SelectFrame")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local SettingsScreen = Screen:new()

SettingsScreen.init = function(self)
	SelectFrame:init()
	SettingsList:init()
	CategoriesList:init()
	SettingsList.observable:add(self)
	CategoriesList.observable:add(self)
end

SettingsScreen.load = function(self)
	SettingsList:load()
	CategoriesList:load()
	SelectFrame:reload()
	
	BackgroundManager:setColor({63, 63, 63})
end

SettingsScreen.unload = function(self)
	Config:write()
end

SettingsScreen.update = function(self)
	Screen.update(self)
	
	SettingsList:update()
	CategoriesList:update()
end

SettingsScreen.draw = function(self)
	Screen.draw(self)
	
	SettingsList:draw()
	CategoriesList:draw()
	SelectFrame:draw()
end

SettingsScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "f1" then
		return ScreenManager:set(require("sphere.screen.select.SelectScreen"))
	elseif event.name == "resize" then
		SettingsList:reload()
		CategoriesList:reload()
		SelectFrame:reload()
		return
	end
	
	SettingsList:receive(event)
	CategoriesList:receive(event)
end

return SettingsScreen

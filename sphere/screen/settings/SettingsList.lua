local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local Observable			= require("aqua.util.Observable")
local Cache					= require("sphere.database.Cache")
local CollectionManager		= require("sphere.database.CollectionManager")
local SettingsListButton	= require("sphere.screen.settings.SettingsListButton")
local CustomList			= require("sphere.ui.CustomList")
local NotificationLine		= require("sphere.ui.NotificationLine")

local SettingsList = CustomList:new()

SettingsList.x = 0.5
SettingsList.y = 0
SettingsList.w = 1
SettingsList.h = 1

SettingsList.sender = "SettingsList"
SettingsList.needFocusToInteract = false

SettingsList.buttonCount = 17
SettingsList.middleOffset = 9
SettingsList.startOffset = 9
SettingsList.endOffset = 9

SettingsList.category = "general"
SettingsList.Button = SettingsListButton

SettingsList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "h")
end

SettingsList.load = function(self)
	self:addItems()
	self:reload()
end

SettingsList.send = function(self, event)
	if event.action == "buttonInteract" then
		local item = self.items[event.itemIndex]
		if event.button == 1 then
		elseif event.button == 2 then
		end
	end
	
	return CustomList.send(self, event)
end

SettingsList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
		end
	elseif event.action == "scrollTarget" then
		local item = event.list.items[event.itemIndex]
		if item and event.list.sender == "CategoriesList" then
			self.category = item.category
			self:addItems()
		end
	end
	
	return CustomList.receive(self, event)
end

SettingsList.addItems = function(self)
	if self.category == "general" then
		self:setGeneralItems()
	elseif self.category == "graphics" then
		self:setGraphicsItems()
	elseif self.category == "sound" then
		self:setSoundItems()
	elseif self.category == "input" then
		self:setGeneralItems()
	end
end

SettingsList.setGeneralItems = function(self)
	local items = {}
	
	return self:setItems(items)
end

SettingsList.setGraphicsItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "dim select",
		configKey = "dim.select",
		type = "slider",
		minValue = 0,
		maxValue = 100
	}
	items[#items + 1] = {
		name = "dim gameplay",
		configKey = "dim.gameplay",
		type = "slider",
		minValue = 0,
		maxValue = 100
	}
	
	return self:setItems(items)
end

SettingsList.setSoundItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "global",
		configKey = "volume.global",
		type = "slider",
		minValue = 0,
		maxValue = 100
	}
	items[#items + 1] = {
		name = "music",
		configKey = "volume.music",
		type = "slider",
		minValue = 0,
		maxValue = 100
	}
	items[#items + 1] = {
		name = "effects",
		configKey = "volume.effects",
		type = "slider",
		minValue = 0,
		maxValue = 100
	}
	
	return self:setItems(items)
end

return SettingsList

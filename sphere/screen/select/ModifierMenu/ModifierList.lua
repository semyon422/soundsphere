local CoordinateManager				= require("aqua.graphics.CoordinateManager")
local Observable					= require("aqua.util.Observable")
local Cache							= require("sphere.database.Cache")
local CollectionManager				= require("sphere.database.CollectionManager")
local ModifierDisplay				= require("sphere.screen.select.ModifierDisplay")
local InconsequentialModifierButton	= require("sphere.screen.select.ModifierMenu.InconsequentialModifierButton")
local CustomList					= require("sphere.ui.CustomList")
local NotificationLine				= require("sphere.ui.NotificationLine")

local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local AutoKeySound	= require("sphere.screen.gameplay.ModifierManager.AutoKeySound")
local Automap		= require("sphere.screen.gameplay.ModifierManager.Automap")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local SetInput		= require("sphere.screen.gameplay.ModifierManager.SetInput")
local WindUp		= require("sphere.screen.gameplay.ModifierManager.WindUp")
local TimeRate		= require("sphere.screen.gameplay.ModifierManager.TimeRate")
local NoScratch		= require("sphere.screen.gameplay.ModifierManager.NoScratch")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local CMod			= require("sphere.screen.gameplay.ModifierManager.CMod")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local ModifierList = CustomList:new()

ModifierList.x = 0
ModifierList.y = 0
ModifierList.w = 0.5
ModifierList.h = 1

ModifierList.textAlign = {x = "center", y = "center"}

ModifierList.sender = "ModifierList"
ModifierList.needFocusToInteract = false

ModifierList.buttonCount = 17
ModifierList.middleOffset = 9
ModifierList.startOffset = 9
ModifierList.endOffset = 9

ModifierList.Button = InconsequentialModifierButton

ModifierList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
	self:addItems()
end

ModifierList.load = function(self)
	self:reload()
end

ModifierList.send = function(self, event)
	-- if event.action == "buttonInteract" and event.button == 1 then
	-- 	ModifierDisplay:updateText()
	-- end
	
	CustomList.send(self, event)
end

ModifierList.addItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		modifier = AutoPlay
	}
	items[#items + 1] = {
		modifier = AutoKeySound
	}
	items[#items + 1] = {
		modifier = Automap
	}
	items[#items + 1] = {
		modifier = ProMode
	}
	items[#items + 1] = {
		modifier = SetInput
	}
	items[#items + 1] = {
		modifier = WindUp
	}
	items[#items + 1] = {
		modifier = TimeRate
	}
	items[#items + 1] = {
		modifier = NoScratch
	}
	items[#items + 1] = {
		modifier = Mirror
	}
	items[#items + 1] = {
		modifier = NoLongNote
	}
	items[#items + 1] = {
		modifier = NoMeasureLine
	}
	items[#items + 1] = {
		modifier = CMod
	}
	items[#items + 1] = {
		modifier = FullLongNote
	}
	items[#items + 1] = {
		modifier = ToOsu
	}
	
	return self:setItems(items)
end

return ModifierList

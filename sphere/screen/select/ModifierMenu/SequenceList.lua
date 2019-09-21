local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local Observable				= require("aqua.util.Observable")
local Cache						= require("sphere.database.Cache")
local CollectionManager			= require("sphere.database.CollectionManager")
local ModifierManager			= require("sphere.screen.gameplay.ModifierManager")
local ModifierDisplay			= require("sphere.screen.select.ModifierDisplay")
local SequentialModifierButton	= require("sphere.screen.select.ModifierMenu.SequentialModifierButton")
local CustomList				= require("sphere.ui.CustomList")
local NotificationLine			= require("sphere.ui.NotificationLine")

local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local SetInput		= require("sphere.screen.gameplay.ModifierManager.SetInput")
local Pitch			= require("sphere.screen.gameplay.ModifierManager.Pitch")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local CMod			= require("sphere.screen.gameplay.ModifierManager.CMod")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local SequenceList = CustomList:new()

SequenceList.x = 0.5
SequenceList.y = 0
SequenceList.w = 0.5
SequenceList.h = 1

SequenceList.textAlign = {x = "center", y = "center"}

SequenceList.sender = "SequenceList"
SequenceList.needFocusToInteract = false

SequenceList.buttonCount = 17
SequenceList.middleOffset = 9
SequenceList.startOffset = 9
SequenceList.endOffset = 9

SequenceList.Button = SequentialModifierButton

SequenceList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

SequenceList.load = function(self)
	self:reload()
end

SequenceList.reloadItems = function(self)
	local sequential = ModifierManager.sequence.sequential
	
	local items = {}
	for _, modifier in ipairs(sequential) do
		items[#items + 1] = {
			modifier = modifier
		}
	end
	
	return self:setItems(items)
end

SequenceList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		ModifierDisplay:updateText()
	end
	
	CustomList.send(self, event)
end

return SequenceList

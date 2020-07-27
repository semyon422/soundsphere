local CoordinateManager				= require("aqua.graphics.CoordinateManager")
-- local ModifierManager				= require("sphere.screen.gameplay.ModifierManager")
local InconsequentialModifierButton	= require("sphere.screen.select.ModifierMenu.InconsequentialModifierButton")
local CustomList					= require("sphere.ui.CustomList")

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
	
	-- for _, Modifier in ipairs(ModifierManager.sequence.modifiers) do
	-- 	items[#items + 1] = {
	-- 		name = Modifier.name,
	-- 		Modifier = Modifier,
	-- 		modifier = ModifierManager.sequence:get(Modifier)
	-- 	}
	-- end
	
	return self:setItems(items)
end

return ModifierList

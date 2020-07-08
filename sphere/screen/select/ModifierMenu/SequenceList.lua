local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ModifierManager			= require("sphere.screen.gameplay.ModifierManager")
local SequentialModifierButton	= require("sphere.screen.select.ModifierMenu.SequentialModifierButton")
local CustomList				= require("sphere.ui.CustomList")

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
			name = modifier.name,
			modifier = modifier,
			Modifier = modifier.Class
		}
	end
	
	return self:setItems(items)
end

SequenceList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		-- ModifierDisplay:updateText()
	end
	
	CustomList.send(self, event)
end

return SequenceList

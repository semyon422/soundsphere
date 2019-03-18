local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local CustomList = require("sphere.ui.CustomList")
local ModifierManager = require("sphere.game.ModifierManager")
local ModifierSequence = require("sphere.game.ModifierSequence")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")
local modifiers = require("sphere.game.modifiers")

local ModifierList = CustomList:new()

ModifierList.sender = "ModifierList"

ModifierList.x = 0
ModifierList.y = 13 / 17
ModifierList.w = 0.3
ModifierList.h = 3 / 17
ModifierList.buttonCount = 3
ModifierList.middleOffset = 1
ModifierList.startOffset = 1
ModifierList.endOffset = 2

ModifierList.observable = Observable:new()

ModifierList.load = function(self)
	self:loadModifiers()
	
	self.modifierSequence = self.modifierSequence or ModifierSequence:new()
	ModifierManager.modifierSequence = self.modifierSequence
	
	CustomList.load(self)
end

ModifierList.send = function(self, event)
	if event.action == "buttonInteract" then
		local modifier = self.items[event.itemIndex].modifier
		self.modifierSequence:add(modifier)
		ModifierDisplay:updateText()
	end
	
	CustomList.send(self, event)
end

ModifierList.loadModifiers = function(self)
	local items = {}
	
	for _, modifier in ipairs(modifiers) do
		table.insert(items, self:getItem(modifier))
	end
	
	self:setItems(items)
end

ModifierList.getItem = function(self, modifier)
	local item = {}
	
	item.modifier = modifier
	item.name = modifier.name
	
	return item
end

return ModifierList

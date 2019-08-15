local OverlayMenu = require("sphere.ui.OverlayMenu")
local ModifierManager = require("sphere.game.ModifierManager")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")

local ModsMenu = {}

ModsMenu.createItems = function(self)
	local items = {}
	
	for _, modifier in ipairs(ModifierManager.modifiers) do
		table.insert(items, self:getItem(modifier))
	end
	
	self.items = items
	
	self.loaded = true
end

ModsMenu.getItem = function(self, modifier)
	local modifierSequence = ModifierManager:getSequence()
	
	local item = {}
	
	item.modifier = modifier
	item.name = modifier.name
	item.onClick = function()
		modifierSequence:add(modifier)
		ModifierDisplay:updateText()
	end
	
	return item
end

ModsMenu.show = function(self)
	if not self.loaded then
		self:createItems()
	end
	
	OverlayMenu:show()
	OverlayMenu:setTitle("Mods")
	OverlayMenu:setItems(self.items)
end

return ModsMenu

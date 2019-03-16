local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local sign = require("aqua.math").sign
local belong = require("aqua.math").belong

local spherefonts = require("sphere.assets.fonts")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local CustomList = require("sphere.game.CustomList")

local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierManager = require("sphere.game.ModifierManager")
local ModifierSequence = require("sphere.game.ModifierSequence")
local ModifierDisplay = require("sphere.game.ModifierDisplay")
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
	
	self.modifierSequence = ModifierSequence:new()
	ModifierManager.modifierSequence = self.modifierSequence
	
	CustomList.load(self)
end

ModifierList.send = function(self, event)
	if event.action == "buttonInteract" then
		local modifier = self.items[event.itemIndex].modifier
		self.modifierSequence:add(modifier)
		ModifierDisplay:updateText()
		print(self.modifierSequence:tostring())
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

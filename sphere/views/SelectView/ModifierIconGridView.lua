local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ModifierIconView = require("sphere.views.ModifierView.ModifierIconView")

local ModifierIconGridView = Class:new()

ModifierIconGridView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
	self.modifierIconView = ModifierIconView:new()
	self.iconConfig = {}
	self.modifierIconView.config = self.iconConfig
end

ModifierIconGridView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen
	local modifierIconView = self.modifierIconView
	local configModifier = self.configModifier
	local modifierModel = self.modifierModel

	local i = 1

	love.graphics.setColor(1, 1, 1, 1)

	local iconConfig = self.iconConfig
	iconConfig.screen = config.screen
	iconConfig.size = config.w / config.columns
	for column = 1, config.columns do
		for row = 1, config.rows do
			local modifierConfig = configModifier[i]
			if modifierConfig then
				local modifier = modifierModel:getModifier(modifierConfig)
				iconConfig.modifierString = modifier:getString(modifierConfig)
				iconConfig.modifierSubString = modifier:getSubString(modifierConfig)
				i = i + 1
			else
				return
			end
			iconConfig.x = config.x + iconConfig.size * (column - 1)
			iconConfig.y = config.y + iconConfig.size * (row - 1)
			modifierIconView:draw()
		end
	end
end

return ModifierIconGridView

local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local ModifierIconView = require("sphere.views.ModifierView.ModifierIconView")

local ModifierIconGridView = Class:new()

ModifierIconGridView.construct = function(self)
	self.modifierIconView = ModifierIconView:new()
	self.iconConfig = {}
	self.modifierIconView.config = self.iconConfig
end

ModifierIconGridView.draw = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local modifierIconView = self.modifierIconView
	local configModifier = self.configModifier
	local modifierModel = self.modifierModel

	local i = 1

	local iconConfig = self.iconConfig
	iconConfig.transform = config.transform
	iconConfig.size = config.w / config.columns
	for row = 1, config.rows do
		for column = 1, config.columns do
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

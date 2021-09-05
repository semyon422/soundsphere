local Class = require("aqua.util.Class")
local inside = require("aqua.util.inside")
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
	local configModifier = inside(self, config.config)
	local modifierModel = self.modifierModel
	if type(configModifier) == "string" then
		configModifier = modifierModel:decode(configModifier)
	end
	configModifier = configModifier or {}

	if config.noModifier and #configModifier == 0 then
		return self:drawNoModifier()
	end

	local modifierIndex = 1
	local drawIndex = 1

	local iconConfig = self.iconConfig
	iconConfig.transform = config.transform
	iconConfig.size = config.w / config.columns
	local maxIndex = config.rows * config.columns

	while true do
		local row = math.floor((drawIndex - 1) / config.columns) + 1
		local column = (drawIndex - 1) % config.columns + 1
		local modifierConfig = configModifier[modifierIndex]
		if modifierConfig then
			if drawIndex == maxIndex and #configModifier + drawIndex - modifierIndex > maxIndex then
				return self:drawMoreModifier()
			end
			local modifier = modifierModel:getModifier(modifierConfig)

			local modifierString = modifier:getString(modifierConfig)
			if modifierString then
				iconConfig.modifierString = modifierString
				iconConfig.modifierSubString = modifier:getSubString(modifierConfig)
				iconConfig.x = config.x + iconConfig.size * (column - 1)
				iconConfig.y = config.y + iconConfig.size * (row - 1)
				modifierIconView:draw()
				drawIndex = drawIndex + 1
			end
		else
			return
		end
		modifierIndex = modifierIndex + 1
	end
end

ModifierIconGridView.drawNoModifier = function(self)
	local config = self.config
	local modifierIconView = self.modifierIconView

	local iconConfig = self.iconConfig
	iconConfig.transform = config.transform
	iconConfig.size = config.w / config.columns
	iconConfig.modifierString = "NO"
	iconConfig.modifierSubString = "MOD"
	iconConfig.x = config.x
	iconConfig.y = config.y
	iconConfig.shape = "empty"
	modifierIconView:draw()
	iconConfig.shape = nil
end

ModifierIconGridView.drawMoreModifier = function(self)
	local config = self.config
	local modifierIconView = self.modifierIconView

	local iconConfig = self.iconConfig
	iconConfig.transform = config.transform
	iconConfig.size = config.w / config.columns
	iconConfig.modifierString = "..."
	iconConfig.modifierSubString = nil
	iconConfig.x = config.x + iconConfig.size * (config.columns - 1)
	iconConfig.y = config.y + iconConfig.size * (config.rows - 1)
	iconConfig.shape = "empty"
	modifierIconView:draw()
	iconConfig.shape = nil
end

return ModifierIconGridView

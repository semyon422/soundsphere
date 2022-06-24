local Class = require("aqua.util.Class")
local inside = require("aqua.util.inside")
local transform = require("aqua.graphics.transform")
local ModifierIconView = require("sphere.views.ModifierView.ModifierIconView")

local ModifierIconGridView = Class:new()

ModifierIconGridView.construct = function(self)
	self.modifierIconView = ModifierIconView:new()
end

ModifierIconGridView.draw = function(self)
	local modifierModel = self.game.modifierModel

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local modifierIconView = self.modifierIconView
	local configModifier = inside(self, self.config)
	if type(configModifier) == "string" then
		configModifier = modifierModel:decode(configModifier)
	end
	configModifier = configModifier or {}

	if self.noModifier and #configModifier == 0 then
		return self:drawNoModifier()
	end

	local modifierIndex = 1
	local drawIndex = 1

	modifierIconView.transform = self.transform
	modifierIconView.size = self.w / self.columns
	local maxIndex = self.rows * self.columns

	while true do
		local row = math.floor((drawIndex - 1) / self.columns) + 1
		local column = (drawIndex - 1) % self.columns + 1
		local modifierConfig = configModifier[modifierIndex]
		if modifierConfig then
			if drawIndex == maxIndex and #configModifier + drawIndex - modifierIndex > maxIndex then
				return self:drawMoreModifier()
			end
			local modifier = modifierModel:getModifier(modifierConfig)
			if modifier then
				local modifierString = modifier:getString(modifierConfig)
				if modifierString then
					modifierIconView.modifierString = modifierString
					modifierIconView.modifierSubString = modifier:getSubString(modifierConfig)
					modifierIconView.x = self.x + modifierIconView.size * (column - 1)
					modifierIconView.y = self.y + modifierIconView.size * (row - 1)
					modifierIconView:draw()
					drawIndex = drawIndex + 1
				end
			end
		else
			return
		end
		modifierIndex = modifierIndex + 1
	end
end

ModifierIconGridView.drawNoModifier = function(self)
	local modifierIconView = self.modifierIconView

	modifierIconView.transform = self.transform
	modifierIconView.size = self.w / self.columns
	modifierIconView.modifierString = "NO"
	modifierIconView.modifierSubString = "MOD"
	modifierIconView.x = self.x
	modifierIconView.y = self.y
	modifierIconView.shape = "empty"
	modifierIconView:draw()
	modifierIconView.shape = nil
end

ModifierIconGridView.drawMoreModifier = function(self)
	local modifierIconView = self.modifierIconView

	modifierIconView.transform = self.transform
	modifierIconView.size = self.w / self.columns
	modifierIconView.modifierString = "..."
	modifierIconView.modifierSubString = nil
	modifierIconView.x = self.x + modifierIconView.size * (self.columns - 1)
	modifierIconView.y = self.y + modifierIconView.size * (self.rows - 1)
	modifierIconView.shape = "empty"
	modifierIconView:draw()
	modifierIconView.shape = nil
end

return ModifierIconGridView

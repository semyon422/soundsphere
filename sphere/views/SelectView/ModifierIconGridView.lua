local class = require("class")
local ModifierIconView = require("sphere.views.ModifierView.ModifierIconView")
local ModifierEncoder = require("sphere.models.ModifierEncoder")

---@class sphere.ModifierIconGridView
---@operator call: sphere.ModifierIconGridView
local ModifierIconGridView = class()

---@param configModifier table|string
---@param w number
---@param h number
---@param size number
---@param noModifier boolean?
---@param growUp boolean?
function ModifierIconGridView:draw(configModifier, w, h, size, noModifier, growUp)
	local modifierModel = self.game.modifierModel

	if type(configModifier) == "string" then
		configModifier = ModifierEncoder:decode(configModifier)
	end
	configModifier = configModifier or {}

	if noModifier and #configModifier == 0 then
		ModifierIconView:draw(size, "empty", "NO", "MOD")
	end

	local modifierIndex = 1
	local drawIndex = 1

	local columns = math.floor(w / size)
	local rows = math.floor(h / size)

	local maxIndex = rows * columns

	while true do
		local row = math.floor((drawIndex - 1) / columns) + 1
		local column = (drawIndex - 1) % columns + 1
		local modifierConfig = configModifier[modifierIndex]
		if modifierConfig then
			local modifier = modifierModel:getModifier(modifierConfig.name)
			if modifier then
				local modifierString, modifierSubString = modifier:getString(modifierConfig)
				if modifierString then
					local y = size * (row - 1)
					if growUp then
						y = size * (rows - row)
					end
					love.graphics.push()
					love.graphics.translate(size * (column - 1), y)
					if drawIndex == maxIndex and #configModifier + drawIndex - modifierIndex > maxIndex then
						ModifierIconView:draw(size, "empty", "...")
						love.graphics.pop()
						break
					end
					ModifierIconView:draw(size, nil, modifierString, modifierSubString)
					love.graphics.pop()
					drawIndex = drawIndex + 1
				end
			end
		else
			return
		end
		modifierIndex = modifierIndex + 1
	end
end

return ModifierIconGridView

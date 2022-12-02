local ListView = require("sphere.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")

local AvailableModifierListView = ListView:new()

AvailableModifierListView.rows = 11

AvailableModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.scroll = function(self, count)
	self.game.modifierModel:scrollAvailableModifier(count)
end

AvailableModifierListView.drawItem = function(self, i, w, h)
	local item = self.items[i]
	local prevItem = self.items[i - 1]

	local id = "available modifier" .. i
	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if changed then
		local modifier = self.game.modifierModel.modifiers[i]
		self.game.modifierModel:add(modifier)
	end

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	if item.oneUse and item.added then
		love.graphics.setColor(1, 1, 1, 0.5)
	end

	just.row(true)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(item.name, 44, 0, w - 44, h, "left", "center")
	if just.mouse_over(id, just.is_over(w, h), "mouse") then
		self.game.gameView.tooltip = item.description
	end

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or prevItem.oneUse ~= item.oneUse then
		local text = "One use modifiers"
		if not item.oneUse then
			text = "Sequential modifiers"
		end
		love.graphics.setFont(spherefonts.get("Noto Sans", 16))
		gfx_util.printFrame(text, 0, 0, w - 22, h / 4, "right", "center")
	end
	just.row()
end

return AvailableModifierListView

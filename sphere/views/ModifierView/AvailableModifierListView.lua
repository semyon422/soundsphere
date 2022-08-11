local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.views.SelectView.TextCellImView")

local AvailableModifierListView = ListView:new({construct = false})

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

	if just.button(i, just.is_over(w, h)) then
		local modifier = self.game.modifierModel.modifiers[i]
		self.game.modifierModel:add(modifier)
	end

	love.graphics.setColor(1, 1, 1, 1)
	if item.oneUse and item.added then
		love.graphics.setColor(1, 1, 1, 0.5)
	end

	just.row(true)
	just.indent(44)
	TextCellImView(410, 72, "left", "", item.name)
	if just.mouse_over(i, just.is_over(-410, 72), "mouse") then
		self.game.gameView.tooltip = item.description
	end
	just.indent(-410 - 44)

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or prevItem.oneUse ~= item.oneUse then
		local text = "One use modifiers"
		if not item.oneUse then
			text = "Sequential modifiers"
		end
		TextCellImView(410, 72, "right", text, "")
	end
	just.row(false)
end

return AvailableModifierListView

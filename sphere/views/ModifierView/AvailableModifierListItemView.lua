local just = require("just")

local ListItemView = require("sphere.views.ListItemView")

local AvailableModifierListItemView = ListItemView:new({construct = false})

AvailableModifierListItemView.draw = function(self, w, h)
	local listView = self.listView

	if just.button_behavior(tostring(self.item) .. "1", self:isOver(w, h)) then
		self.listView.navigator:addModifier(self.itemIndex)
	end

	local item = self.item
	local prevItem = self.prevItem

	love.graphics.setColor(1, 1, 1, 1)
	if item.oneUse and item.added then
		love.graphics.setColor(listView.name.addedColor)
	end

	self:drawValue(listView.name, item.name)

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or prevItem.oneUse ~= item.oneUse then
		local text = "One use modifiers"
		if not item.oneUse then
			text = "Sequential modifiers"
		end
		self:drawValue(listView.section, text)
	end
end

return AvailableModifierListItemView

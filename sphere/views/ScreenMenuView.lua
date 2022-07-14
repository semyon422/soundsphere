local transform = require("aqua.graphics.transform")
local just = require("just")
local Class = require("aqua.util.Class")
local ScreenMenuItemView = require("sphere.views.ScreenMenuItemView")
local spherefonts		= require("sphere.assets.fonts")

local ScreenMenuView = Class:new()

ScreenMenuView.construct = function(self)
	self.itemView = ScreenMenuItemView:new()
	self.itemView.listView = self
end

ScreenMenuView.load = function(self)
	self.selectedItem = 1
end

ScreenMenuView.draw = function(self)
	love.graphics.setFont(spherefonts.get(unpack(self.text.font)))

	local items = self.items
	for i = 1, self.rows do
		for j = 1, self.columns do
			local item = items[i] and items[i][j]
			if item and item.displayName then
				local itemView = self.itemView
				itemView.item = item

				local x = (j - 1) * self.w / self.columns
				local y = (i - 1) * self.h / self.rows
				local w = self.w / self.columns
				local h = self.h / self.rows
				local tf = transform(self.transform):translate(self.x + x, self.y + y)
				love.graphics.replaceTransform(tf)

				itemView:draw(item.displayName, w, h, item.method, item.value)
			end
		end
	end
end

ScreenMenuView.button = function(self, text, w, h, method, ...)
	local changed, active, hovered = just.button_behavior(text .. w .. h, just.is_over(w, h))
	if changed then
		self.navigator:call(method, ...)
	end

	self.itemView:_draw(text, w, h, active, hovered)

	just.next(w, h)

	return changed
end

return ScreenMenuView

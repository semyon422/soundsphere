
local transform = require("aqua.graphics.transform")
local ListItemView = require("sphere.views.ListItemView")

local CollectionListItemView = ListItemView:new()

CollectionListItemView.draw = function(self)
	self.item.tagged = self.item == self.listView.state.selectedCollection

	ListItemView.draw(self)
end

CollectionListItemView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local config = self.listView.config

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local tf = transform(config.transform):clone():translate(config.x, config.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event.args[3]
		if button == 1 then
			self.listView.navigator:setCollection(self.itemIndex)
		end
	end
end

return CollectionListItemView

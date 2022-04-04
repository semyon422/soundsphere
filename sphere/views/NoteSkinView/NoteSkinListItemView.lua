local transform = require("aqua.graphics.transform")
local ListItemView = require("sphere.views.ListItemView")

local NoteSkinListItemView = ListItemView:new({construct = false})

NoteSkinListItemView.draw = function(self)
	self.item.lamp = self.item == self.listView.state.selectedNoteSkin

	ListItemView.draw(self)
end

NoteSkinListItemView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local config = self.listView.config

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local tf = transform(config.transform):translate(config.x, config.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())
	tf:release()

	if (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event[3]
		if button == 1 then
			self.listView.navigator:setNoteSkin(self.itemIndex)
		end
	end
end

return NoteSkinListItemView

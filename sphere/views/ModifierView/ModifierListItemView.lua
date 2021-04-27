local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ListItemView = require(viewspackage .. "ListItemView")

local ModifierListItemView = ListItemView:new()

ModifierListItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
end

ModifierListItemView.draw = function(self) end

ModifierListItemView.receive = function(self, event)
	local listView = self.listView

	local x, y, w, h = self:getPosition()
	local mx, my = love.mouse.getPosition()

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		listView.activeItem = self.itemIndex
		local button = event.args[3]
		if button == 2 then
			self.listView.navigator:call("backspace", self.itemIndex)
		end
	end
	if event.name == "mousereleased" then
		listView.activeItem = listView.selectedItem
	end
end

return ModifierListItemView

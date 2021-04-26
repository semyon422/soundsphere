local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ListItemView = require(viewspackage .. "ListItemView")

local CollectionListItemView = ListItemView:new()

CollectionListItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
end

CollectionListItemView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

	local collection = item

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1, 0.33)
	end

	local prefix = ""
	if collection == listView.selectedCollection then
		prefix = "★ "
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		prefix .. collection,
		x,
		y,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(120 / cs.one),
		-cs:Y(18 / cs.one)
	)
end

CollectionListItemView.receive = function(self, event)
	local listView = self.listView

	local x, y, w, h = self:getPosition()
	local mx, my = love.mouse.getPosition()

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		listView.activeItem = self.itemIndex
		local button = event.args[3]
		if button == 1 then
			self.listView.navigator:call("return", self.itemIndex)
		end
	end
end

return CollectionListItemView

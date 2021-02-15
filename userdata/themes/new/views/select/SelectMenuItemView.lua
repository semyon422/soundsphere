
local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")
local belong		= require("aqua.math").belong

local SelectMenuItemView = Node:new()

SelectMenuItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
end

SelectMenuItemView.draw = function(self)
	local listView = self.listView

	local item = self.item

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index

	local deltaItemIndex = math.abs(index - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1, 0.66)
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		item.name,
		x + (index - 1) * w / listView.itemCount,
		y,
		w / cs.one * 1080 / listView.itemCount,
		"center",
		0,
		cs.one / 1080,
		cs.one / 1080,
		cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)
end

SelectMenuItemView.receive = function(self, event)
	local listView = self.listView

	local cs = listView.cs

	local x = cs:X(listView.x, true) + (self.index - 1) * cs:X(listView.w) / listView.itemCount
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w) / listView.itemCount
	local h = cs:Y(listView.h)

	if event.name == "mousemoved" then
		local mx = event.args[1]
		local my = event.args[2]
		if belong(mx, x, x + w) and belong(my, y, y + h) then
			listView.navigator.selectMenu.selected = self.index
		end
	end
end

return SelectMenuItemView

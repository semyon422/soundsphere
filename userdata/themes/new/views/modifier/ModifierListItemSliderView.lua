local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierListItemView = require(viewspackage .. "modifier.ModifierListItemView")

local ModifierListItemSliderView = ModifierListItemView:new()

ModifierListItemSliderView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
end

ModifierListItemSliderView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	local item = self.item

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index
    local modifierConfig = item
    local modifier = listView.view.modifierModel:getModifier(modifierConfig)
    local realValue = modifier:getRealValue(modifierConfig)

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.33
		)
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		modifierConfig.name .. realValue .. "slider",
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(120 / cs.one),
		-cs:Y(18 / cs.one)
	)
end

ModifierListItemSliderView.receive = function(self, event)
	local listView = self.listView

	local cs = listView.cs

	local index = self.index
	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true) + (index - 1) * cs:Y(listView.h) / listView.itemCount
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h) / listView.itemCount

	local mx, my = love.mouse.getPosition()
	if event.name == "wheelmoved" then
		if mx >= x and mx <= x + w and my >= y and my <= y + h then
			if mx >= x + w * 0.5 and mx <= x + w then
				local wy = event.args[2]
				if wy == 1 then
					self.listView.navigator:call("right")
				elseif wy == -1 then
					self.listView.navigator:call("left")
				end
			else
				local wy = event.args[2]
				if wy == 1 then
					self.listView.navigator:call("up")
				elseif wy == -1 then
					self.listView.navigator:call("down")
				end
			end
		end
	end
end

return ModifierListItemSliderView

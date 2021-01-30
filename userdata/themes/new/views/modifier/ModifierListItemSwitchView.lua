local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierListItemView = require(viewspackage .. "modifier.ModifierListItemView")
local icons			= require("sphere.assets.icons")

local ModifierListItemSwitchView = ModifierListItemView:new()

ModifierListItemSwitchView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	self.checkboxOffImage = love.graphics.newImage(icons.ic_check_box_outline_blank_white_24dp)
	self.checkboxOnImage = love.graphics.newImage(icons.ic_check_box_white_24dp)
end

ModifierListItemSwitchView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	local item = self.item

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local ih = h / listView.itemCount

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
		modifierConfig.name .. realValue .. "switch",
		x,
		y + (index - 1) * ih,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(120 / cs.one),
		-cs:Y(18 / cs.one)
	)

	local drawable = self.checkboxOnImage
	if realValue == 0 then
		drawable = self.checkboxOffImage
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(
		drawable,
		x + w - ih / 2,
		y + (index - 1) * ih + ih / 2,
		0,
		ih / drawable:getWidth() * 0.5,
		ih / drawable:getHeight() * 0.5,
		drawable:getWidth() / 2,
		drawable:getHeight() / 2
	)
end

ModifierListItemSwitchView.receive = function(self, event)
	local listView = self.listView

	local cs = listView.cs

	local index = self.index
	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true) + (index - 1) * cs:Y(listView.h) / listView.itemCount
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h) / listView.itemCount

	local mx, my = love.mouse.getPosition()
	if mx >= x and mx <= x + w and my >= y and my <= y + h then
		if event.name == "wheelmoved" then
			if mx >= 0 and mx < x + w - h then
				local wy = event.args[2]
				if wy == 1 then
					self.listView.navigator:call("up")
				elseif wy == -1 then
					self.listView.navigator:call("down")
				end
			end
		elseif event.name == "mousepressed" then
			if mx >= x + w - h and mx <= x + w then
				local button = event.args[3]
				if button == 1 then
					local modifierConfig = self.item
					local modifier = listView.view.modifierModel:getModifier(modifierConfig)
					local realValue = modifier:getRealValue(modifierConfig)
					if realValue == 1 then
						self.listView.navigator:call("left")
					else
						self.listView.navigator:call("right")
					end
				end
			end
		end
	end
end

return ModifierListItemSwitchView

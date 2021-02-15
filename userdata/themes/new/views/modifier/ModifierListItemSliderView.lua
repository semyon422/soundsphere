local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierListItemView = require(viewspackage .. "modifier.ModifierListItemView")
local SliderView = require(viewspackage .. "SliderView")

local ModifierListItemSliderView = ModifierListItemView:new()

ModifierListItemSliderView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.sliderView = SliderView:new()
end

ModifierListItemSliderView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

    local modifierConfig = item
    local modifier = listView.view.modifierModel:getModifier(modifierConfig)
    local realValue = modifier:getRealValue(modifierConfig)

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1, 0.33)
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		modifierConfig.name .. " " .. realValue,
		x,
		y,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)

	local sliderView = self.sliderView
	sliderView:setPosition(x + w / 2, y, w / 2, h)
	sliderView:setValue(modifier:getNormalizedValue(modifierConfig))
	sliderView:draw()
end

ModifierListItemSliderView.receive = function(self, event)
	local listView = self.listView

	local x, y, w, h = self:getPosition()

	local mx, my = love.mouse.getPosition()
	if event.name == "wheelmoved" and not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	local slider = listView.slider

	local modifierConfig = self.item
	local modifier = listView.view.modifierModel:getModifier(modifierConfig)
	slider:setPosition(x + w / 2, y, w / 2, h)
	slider:setValue(modifier:getNormalizedValue(modifierConfig))
	slider:receive(event)

	if slider.valueUpdated then
		self.listView.navigator:send({
			name = "setModifierValue",
			modifierConfig = modifierConfig,
			value = modifier:fromNormalizedValue(slider.value)
		})
		slider.valueUpdated = false
	end

	if mx >= x and mx <= x + w and my >= y and my <= y + h then
		if mx >= x + w * 0.5 and mx <= x + w then
			local wy = event.args[2]
			if wy == 1 then
				self.listView.navigator:call("right", self.itemIndex)
			elseif wy == -1 then
				self.listView.navigator:call("left", self.itemIndex)
			end
		end
	end
end

return ModifierListItemSliderView

local viewspackage = (...):match("^(.-%.views%.)")

local ModifierListItemView = require(viewspackage .. "ModifierView.ModifierListItemView")
local SliderView = require(viewspackage .. "SliderView")

local ModifierListItemSliderView = ModifierListItemView:new()

ModifierListItemSliderView.construct = function(self)
	self.sliderView = SliderView:new()
end

ModifierListItemSliderView.draw = function(self)
	local modifierConfig = self.item

	local modifier = self.listView.modifierModel:getModifier(modifierConfig)

	ModifierListItemView.draw(self)

	local config = self.listView.config
	self:drawValue(config.slider.value)

	local sliderView = self.sliderView
	sliderView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.slider))
	sliderView:setValue(modifier:toNormValue(modifierConfig.value))
	sliderView:draw()
end

ModifierListItemSliderView.receive = function(self, event)
	ModifierListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView
	if listView.activeItem ~= self.itemIndex then
		return
	end

	local config = listView.config
	local slider = listView.slider
	local modifierConfig = self.item
	local modifier = listView.modifierModel:getModifier(modifierConfig)
	slider:setPosition(listView:getItemElementPosition(self.itemIndex, config.slider))
	slider:setValue(modifier:toNormValue(modifierConfig.value))
	slider:receive(event)

	if slider.valueUpdated then
		self.listView.navigator:setModifierValue(
			modifierConfig,
			modifier:fromNormValue(slider.value)
		)
		slider.valueUpdated = false
	end
end

ModifierListItemSliderView.wheelmoved = function(self, event)
	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local mx, my = love.mouse.getPosition()

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	x, y, w, h = self.listView:getItemElementPosition(self.itemIndex, self.listView.config.slider)
	if mx >= x and mx <= x + w then
		local wy = event.args[2]
		if wy == 1 then
			self.listView.navigator:increaseModifierValue(self.itemIndex, 1)
		elseif wy == -1 then
			self.listView.navigator:increaseModifierValue(self.itemIndex, -1)
		end
	end
end

return ModifierListItemSliderView

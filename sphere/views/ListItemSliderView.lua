local just = require("just")
local ListItemView = require("sphere.views.ListItemView")
local SliderView = require("sphere.views.SliderView")

local ListItemSliderView = ListItemView:new({construct = false})

ListItemSliderView.construct = function(self)
	ListItemView.construct(self)
	self.sliderView = SliderView:new()
end

ListItemSliderView.getName = function(self) end
ListItemSliderView.getValue = function(self) end
ListItemSliderView.getDisplayValue = function(self) end
ListItemSliderView.getNormValue = function(self) end
ListItemSliderView.updateNormValue = function(self, normValue) end
ListItemSliderView.increaseValue = function(self, delta) end

ListItemSliderView.draw = function(self)
	ListItemView.draw(self)

	local listView = self.listView
	self:drawValue(listView.name, self:getName())
	self:drawValue(listView.slider.value, self:getDisplayValue())

	local sliderView = self.sliderView
	local x, y, w, h = listView:getItemElementPosition(self.itemIndex, listView.slider)
	love.graphics.push()
	love.graphics.translate(x, y)

	local value = self:getNormValue()
	local over = sliderView:isOver(w, h)
	local pos = sliderView:getPosition(w, h)

	local scrolled, delta = just.wheel_behavior(self.item, over)
	local changed, value, active, hovered = just.slider_behavior(self.item, over, pos, value, 0, 1)
	if changed then
		self:updateNormValue(value)
	elseif delta ~= 0 then
		self:increaseValue(delta)
	end
	sliderView:draw(w, h, value)

	love.graphics.pop()
end

return ListItemSliderView

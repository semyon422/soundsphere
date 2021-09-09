local viewspackage = (...):match("^(.-%.views%.)")

local ListItemView = require(viewspackage .. "ListItemView")
local SliderView = require(viewspackage .. "SliderView")
local transform = require("aqua.graphics.transform")

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

	local config = self.listView.config
	self:drawValue(config.name, self:getName())
	self:drawValue(config.slider.value, self:getDisplayValue())

	local sliderView = self.sliderView
	sliderView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.slider))
	sliderView:setValue(self:getNormValue())
	sliderView:draw()
end

ListItemSliderView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView
	if listView.activeItem ~= self.itemIndex then
		return
	end

	local config = listView.config
	local slider = listView.slider
	slider:setTransform(transform(config.transform):clone():translate(config.x, config.y))
	slider:setPosition(listView:getItemElementPosition(self.itemIndex, config.slider))
	slider:setValue(self:getNormValue())
	slider:receive(event)

	if slider.valueUpdated then
		self:updateNormValue(slider.value)
		slider.valueUpdated = false
	end
end

ListItemSliderView.wheelmoved = function(self, event)
	local config = self.listView.config

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local tf = transform(config.transform):clone():translate(config.x, config.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	x, y, w, h = self.listView:getItemElementPosition(self.itemIndex, config.slider)
	if mx >= x and mx <= x + w then
		local wy = event.args[2]
		if wy == 1 then
			self:increaseValue(1)
		elseif wy == -1 then
			self:increaseValue(-1)
		end
	end
end

return ListItemSliderView

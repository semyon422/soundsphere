local just = require("just")
local ListItemView = require("sphere.views.ListItemView")
local SliderView = require("sphere.views.SliderView")
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

	local listView = self.listView
	self:drawValue(listView.name, self:getName())
	self:drawValue(listView.slider.value, self:getDisplayValue())

	local sliderView = self.sliderView
	local x, y, w, h = listView:getItemElementPosition(self.itemIndex, listView.slider)
	love.graphics.push()
	love.graphics.translate(x, y)

	local ptr = {value = self:getNormValue()}
	local over = sliderView:isOver(w, h)
	local pos = sliderView:getPosition(w, h)

	local changed, active, hovered = just.slider_behavior(self.item, over, pos, {value = ptr}, 0, 1)
	if changed then
		self:updateNormValue(ptr.value)
	end
	sliderView:draw(w, h, ptr.value)

	love.graphics.pop()
end

ListItemSliderView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
end

ListItemSliderView.wheelmoved = function(self, event)
	local listView = self.listView

	local x, y, w, h = listView:getItemPosition(self.itemIndex)
	local tf = transform(listView.transform):translate(listView.x, listView.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	x, y, w, h = listView:getItemElementPosition(self.itemIndex, listView.slider)
	if mx >= x and mx <= x + w then
		local wy = event[2]
		if wy == 1 then
			self:increaseValue(1)
		elseif wy == -1 then
			self:increaseValue(-1)
		end
	end
end

return ListItemSliderView

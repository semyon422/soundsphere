local ListItemView = require("sphere.views.ListItemView")
local ListItemSliderView = require("sphere.views.ListItemSliderView")
local StepperView = require("sphere.views.StepperView")
local just = require("just")

local ListItemStepperView = ListItemView:new({construct = false})

ListItemStepperView.construct = function(self)
	ListItemView.construct(self)
	self.stepperView = StepperView:new()
end

ListItemStepperView.getName = function(self) end
ListItemStepperView.getValue = function(self) end
ListItemStepperView.getDisplayValue = function(self) end
ListItemStepperView.getIndexValue = function(self) end
ListItemStepperView.getCount = function(self) end
ListItemStepperView.updateIndexValue = function(self, indexValue) end
ListItemStepperView.increaseValue = function(self, delta) end

ListItemStepperView.draw = function(self)
	ListItemView.draw(self)

	local listView = self.listView
	self:drawValue(listView.name, self:getName())
	self:drawValue(listView.stepper.value, self:getDisplayValue())

	local stepperView = self.stepperView
	local x, y, w, h = listView:getItemElementPosition(self.itemIndex, listView.stepper)
	love.graphics.push()
	love.graphics.translate(x, y)

	local value = self:getIndexValue()
	local count = self:getCount()

	local overAll, overLeft, overRight = stepperView:isOver(w, h)

	local changedLeft = just.button_behavior(tostring(self.item) .. "L", overLeft)
	local changedRight = just.button_behavior(tostring(self.item) .. "R", overRight)
	if changedLeft then
		value = math.max(value - 1, 1)
		self:updateIndexValue(value)
	elseif changedRight then
		value = math.min(value + 1, count)
		self:updateIndexValue(value)
	end
	stepperView:draw(w, h, value, count)

	love.graphics.pop()
end

ListItemStepperView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
end

ListItemStepperView.wheelmoved = ListItemSliderView.wheelmoved

return ListItemStepperView

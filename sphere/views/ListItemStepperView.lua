local ListItemView = require("sphere.views.ListItemView")
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
	local x, y, w, h = listView:getItemElementPosition(listView.stepper)
	love.graphics.push()
	love.graphics.translate(x, y)

	local value = self:getIndexValue()
	local count = self:getCount()

	local overAll, overLeft, overRight = stepperView:isOver(w, h)

	local id = tostring(self.item)
	local scrolled, delta = just.wheel_behavior(id .. "A", overAll)
	local changedLeft = just.button_behavior(id .. "L", overLeft)
	local changedRight = just.button_behavior(id .. "R", overRight)

	if changedLeft or delta == -1 then
		self:increaseValue(-1)
	elseif changedRight or delta == 1 then
		self:increaseValue(1)
	end
	stepperView:draw(w, h, value, count)

	love.graphics.pop()
end

return ListItemStepperView

local viewspackage = (...):match("^(.-%.views%.)")

local ListItemView = require(viewspackage .. "ListItemView")
local ListItemSliderView = require(viewspackage .. "ListItemSliderView")
local StepperView = require(viewspackage .. "StepperView")
local transform = require("aqua.graphics.transform")

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

	local config = self.listView.config
	self:drawValue(config.name, self:getName())
	self:drawValue(config.stepper.value, self:getDisplayValue())

	local stepperView = self.stepperView
	stepperView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.stepper))
	stepperView:setValue(self:getIndexValue())
	stepperView:setCount(self:getCount())
	stepperView:draw()
end

ListItemStepperView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView
	if listView.activeItem ~= self.itemIndex then
		return
	end

	local config = listView.config
	local stepper = listView.stepper
	local tf = transform(config.transform):translate(config.x, config.y)
	stepper:setTransform(tf)
	stepper:setPosition(listView:getItemElementPosition(self.itemIndex, config.stepper))
	stepper:setValue(self:getIndexValue())
	stepper:setCount(self:getCount())
	stepper:receive(event)
	tf:release()

	if stepper.valueUpdated then
		self:updateIndexValue(stepper.value)
		stepper.valueUpdated = false
	end
end

ListItemStepperView.wheelmoved = ListItemSliderView.wheelmoved

return ListItemStepperView

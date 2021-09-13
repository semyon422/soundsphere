
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local StepperView = require("sphere.views.StepperView")
local Stepper = require("sphere.views.Stepper")

local SortStepperView = Class:new()

SortStepperView.construct = function(self)
	self.stepperView = StepperView:new()
	self.stepper = Stepper:new()
end

SortStepperView.getIndexValue = function(self)
	return self.sortModel:toIndexValue(self.sortModel.name)
end

SortStepperView.getCount = function(self)
	return #self.sortModel.names
end

SortStepperView.updateIndexValue = function(self, indexValue)
	self.navigator:setSortFunction(self.sortModel:fromIndexValue(indexValue))
end

SortStepperView.increaseValue = function(self, delta)
	self.navigator:scrollSortFunction(delta)
end

SortStepperView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		self.sortModel.name,
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	love.graphics.setLineWidth(config.frame.lineWidth)
	love.graphics.setLineStyle(config.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		config.frame.x,
		config.frame.y,
		config.frame.w,
		config.frame.h,
		config.frame.h / 2,
		config.frame.h / 2
	)

	love.graphics.setColor(1, 1, 1, 1)
	local stepperView = self.stepperView
	stepperView:setPosition(0, 0, config.w, config.h)
	stepperView:setValue(self:getIndexValue())
	stepperView:setCount(self:getCount())
	stepperView:draw()
end

SortStepperView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	if event.name ~= "mousepressed" then
		return
	end

	local config = self.config
	local stepper = self.stepper
	local tf = transform(config.transform)
	stepper:setTransform(tf)
	stepper:setPosition(config.x, config.y, config.w, config.h)
	stepper:setValue(self:getIndexValue())
	stepper:setCount(self:getCount())
	stepper:receive(event)
	tf:release()

	if stepper.valueUpdated then
		self:updateIndexValue(stepper.value)
		stepper.valueUpdated = false
	end
end

SortStepperView.wheelmoved = function(self, event)
	local config = self.config

	local x, y, w, h = config.x, config.y, config.w, config.h
	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	local wy = event.args[2]
	if wy == 1 then
		self:increaseValue(1)
	elseif wy == -1 then
		self:increaseValue(-1)
	end
end

return SortStepperView

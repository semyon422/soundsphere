
local Class = require("aqua.util.Class")
local just = require("just")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local StepperView = require("sphere.views.StepperView")

local SortStepperView = Class:new()

SortStepperView.construct = function(self)
	self.stepperView = StepperView:new()
end

SortStepperView.getIndexValue = function(self)
	return self.game.sortModel:toIndexValue(self.game.sortModel.name)
end

SortStepperView.getCount = function(self)
	return #self.game.sortModel.names
end

SortStepperView.updateIndexValue = function(self, indexValue)
	self.navigator:setSortFunction(self.game.sortModel:fromIndexValue(indexValue))
end

SortStepperView.increaseValue = function(self, delta)
	self.navigator:scrollSortFunction(delta)
end

SortStepperView.draw = function(self)
	local sortModel = self.game.sortModel

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(self.text.font)
	love.graphics.setFont(font)
	baseline_print(
		sortModel.name,
		self.text.x,
		self.text.baseline,
		self.text.limit,
		1,
		self.text.align
	)

	love.graphics.setLineWidth(self.frame.lineWidth)
	love.graphics.setLineStyle(self.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		self.frame.x,
		self.frame.y,
		self.frame.w,
		self.frame.h,
		self.frame.h / 2,
		self.frame.h / 2
	)

	love.graphics.setColor(1, 1, 1, 1)
	local stepperView = self.stepperView
	local w, h = self.w, self.h

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
end

SortStepperView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
end

SortStepperView.wheelmoved = function(self, event)
	local x, y, w, h = self.x, self.y, self.w, self.h
	local tf = transform(self.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	local wy = event[2]
	if wy == 1 then
		self:increaseValue(1)
	elseif wy == -1 then
		self:increaseValue(-1)
	end
end

return SortStepperView

local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Colors = require("yi.Colors")
local math_util = require("math_util")
local h = require("yi.h")

---@class yi.NumericStepper : yi.View
---@overload fun(value: number, min: number, max: number, step: number?, on_change: fun(value: number)): yi.NumericStepper
local NumericStepper = View + {}

-- Internal button class for stepper
---@class yi.NumericStepper.Button : yi.View
local StepperButton = View + {}

function StepperButton:new(text, callback)
	View.new(self)
	self.text = text
	self.callback = callback
end

function StepperButton:load()
	local res = self:getResources()
	local font = res:getFont("bold", 24)

	self:setup({
		w = 32,
		h = 32,
		mouse = true,
		arrange = "flex_row",
		justify_content = "center",
		align_items = "center",
	})

	self:add(Label(font, self.text))
end

function StepperButton:onMouseClick()
	self.callback()
end

function StepperButton:draw()
	if self.mouse_over then
		love.graphics.setColor(Colors.button_hover)
	else
		love.graphics.setColor(Colors.button)
	end
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	love.graphics.rectangle("fill", 0, 0, w, h, 4, 4)

	love.graphics.setColor(Colors.outline)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", 0, 0, w, h, 4, 4)
end


---@param value number
---@param min number
---@param max number
---@param step number?
---@param on_change fun(value: number)
function NumericStepper:new(value, min, max, step, on_change)
	View.new(self)
	self.value = value or 0
	self.min = min or 0
	self.max = max or 100
	self.step = step or 1
	self.on_change = on_change
end

function NumericStepper:load()
	local res = self:getResources()
	local font = res:getFont("bold", 24)

	self:setup({
		arrange = "flex_row",
		align_items = "center",
		gap = 12,
	})

	self.label = Label(font, tostring(self.value))

	h(self, {}, {
		StepperButton("-", function() self:changeValue(-self.step) end),
		self.label,
		StepperButton("+", function() self:changeValue(self.step) end),
	})
end

---@param delta number
function NumericStepper:changeValue(delta)
	local new_value = self.value + delta
	new_value = math_util.round(new_value, self.step)
	new_value = math_util.clamp(new_value, self.min, self.max)

	if new_value ~= self.value then
		self.value = new_value
		self.label:setText(tostring(self.value))
		if self.on_change then
			self.on_change(self.value)
		end
	end
end

return NumericStepper

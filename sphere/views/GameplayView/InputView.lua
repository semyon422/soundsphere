local class = require("class")

---@class sphere.InputView
---@operator call: sphere.InputView
local InputView = class()

function InputView:load()
	if self.pressed then
		self.pressed.hidden = true
	end
end

---@param event table
function InputView:receive(event)
	if not event.virtual then
		return
	end

	local key = event and event[1]
	if key == self.input then
		if event.name == "keypressed" then
			self:switchPressed(true)
		elseif event.name == "keyreleased" then
			self:switchPressed(false)
		end
	end
end

---@param value boolean
function InputView:switchPressed(value)
	if self.pressed then
		self.pressed.hidden = not value
	end
	if self.released then
		self.released.hidden = value
	end
end

return InputView

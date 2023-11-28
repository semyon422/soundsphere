local class = require("class")

---@class sphere.InputView
---@operator call: sphere.InputView
local InputView = class()

function InputView:load()
	if self.pressed then
		self.pressed.hidden = true
	end
	self.count = 0
end

---@param event table
function InputView:receive(event)
	if not event.virtual then
		return
	end

	local key = event and event[1]

	local found
	for _, input in ipairs(self.inputs) do
		if key == input then
			found = true
			break
		end
	end
	if not found then
		return
	end

	if event.name == "keypressed" then
		self.count = self.count + 1
	elseif event.name == "keyreleased" then
		self.count = self.count - 1
	end

	if self.count > 0 then
		self:switchPressed(true)
	else
		self:switchPressed(false)
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

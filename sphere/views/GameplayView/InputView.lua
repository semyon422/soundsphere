local Class = require("Class")

local InputView = Class:new()

InputView.load = function(self)
	if self.pressed then
		self.pressed.hidden = true
	end
end

InputView.receive = function(self, event)
	if not event.virtual then
		return
	end

	local key = event and event[1]
	if key == self.inputType .. self.inputIndex then
		if event.name == "keypressed" then
			self:switchPressed(true)
		elseif event.name == "keyreleased" then
			self:switchPressed(false)
		end
	end
end

InputView.switchPressed = function(self, value)
	if self.pressed then
		self.pressed.hidden = not value
	end
	if self.released then
		self.released.hidden = value
	end
end

return InputView

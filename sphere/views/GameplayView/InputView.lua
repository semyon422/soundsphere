local Class = require("aqua.util.Class")

local InputView = Class:new()

InputView.load = function(self)
	local config = self.config
	local state = self.state

	if config.pressed then
		state.pressed = self.sequenceView:getView(config.pressed).state
		state.pressed.hidden = true
	end
	if config.released then
		state.released = self.sequenceView:getView(config.released).state
	end
end

InputView.receive = function(self, event)
	if not event.virtual then
		return
	end
	local config = self.config

	local key = event and event[1]
	if key == config.inputType .. config.inputIndex then
		if event.name == "keypressed" then
			self:switchPressed(true)
		elseif event.name == "keyreleased" then
			self:switchPressed(false)
		end
	end
end

InputView.switchPressed = function(self, value)
	local state = self.state
	if state.pressed then
		state.pressed.hidden = not value
	end
	if state.released then
		state.released.hidden = value
	end
end

return InputView

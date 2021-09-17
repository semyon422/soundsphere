local Class = require("aqua.util.Class")

local InputView = Class:new()

InputView.load = function(self)
	local config = self.config
	local state = self.state

	if config.pressed then
		state.pressed = self.sequenceView:getView(config.pressed).state
	end
	if config.released then
		state.released = self.sequenceView:getView(config.released).state
	end
	if config.mode == "switch" and state.pressed then
		state.pressed.hidden = true
	end
end

InputView.receive = function(self, event)
	local config = self.config
	local state = self.state

	local key = event.args and event.args[1]
	if key == config.inputType .. config.inputIndex then
		if event.name == "keypressed" then
			if config.mode == "switch" then
				self:switchPressed(true)
			elseif config.mode == "reset" and config.pressed then
				self.sequenceView:getView(config.pressed):reset()
			end
		elseif event.name == "keyreleased" then
			if config.mode == "switch" then
				self:switchPressed(false)
			elseif config.mode == "reset" and config.released then
				self.sequenceView:getView(config.released):reset()
			end
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

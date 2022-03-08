local Class = require("aqua.util.Class")

local InputAnimationView = Class:new()

InputAnimationView.load = function(self)
	local config = self.config
	local state = self.state

	if config.pressed then
		state.pressed = self.sequenceView:getView(config.pressed).state
	end
	if config.released then
		state.released = self.sequenceView:getView(config.released).state
	end
	if config.hold then
		state.hold = self.sequenceView:getView(config.hold).state
	end
end

InputAnimationView.receive = function(self, event)
	local config = self.config

	local key = event and event[1]
	if key == config.inputType .. config.inputIndex then
		if event.name == "keypressed" then
			-- if config.released then
			-- 	self.sequenceView:getView(config.released):setTime(math.huge)
			-- end
			if config.pressed then
				self.sequenceView:getView(config.pressed):setTime(0)
			end
			if config.hold then
				local time = 0
				if config.pressed then
					local range = config.pressed.range
					time = (math.abs(range[2] - range[1]) + 1) / config.pressed.rate
				end
				self.sequenceView:getView(config.hold):setCycles(math.huge)
				self.sequenceView:getView(config.hold):setTime(-time)
			end
		elseif event.name == "keyreleased" then
			if config.released then
				self.sequenceView:getView(config.released):setTime(0)
			end
			-- if config.pressed then
			-- 	self.sequenceView:getView(config.pressed):setTime(math.huge)
			-- end
			if config.hold then
				self.sequenceView:getView(config.hold):setCycles(1)
				self.sequenceView:getView(config.hold):setTime(math.huge)
			end
		end
	end
end

return InputAnimationView

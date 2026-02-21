local class = require("class")

---@class sphere.InputAnimationView
---@operator call: sphere.InputAnimationView
local InputAnimationView = class()

function InputAnimationView:load()
	self.count = 0
	self.last_pressed = false
end

function InputAnimationView:draw()
	local re = self.game and self.game.rhythm_engine
	if re and self.column then
		local pressed = re:isColumnPressed(self.column)
		if pressed ~= self.last_pressed then
			self:switchPressed(pressed)
			self.last_pressed = pressed
		end
	end
end

function InputAnimationView:switchPressed(pressed)
	if pressed then
		-- if self.released then
		-- 	self.released:setTime(math.huge)
		-- end
		if self.pressed then
			self.pressed:setTime(0)
		end
		if self.hold then
			local time = 0
			if self.pressed then
				local range = self.pressed.range
				time = (math.abs(range[2] - range[1]) + 1) / self.pressed.rate
			end
			self.hold:setCycles(math.huge)
			self.hold:setTime(-time)
		end
	else
		if self.released then
			self.released:setTime(0)
		end
		-- if self.pressed then
		-- 	self.pressed:setTime(math.huge)
		-- end
		if self.hold then
			self.hold:setCycles(1)
			self.hold:setTime(math.huge)
		end
	end
end

return InputAnimationView

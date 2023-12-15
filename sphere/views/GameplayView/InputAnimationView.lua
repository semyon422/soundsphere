local class = require("class")

---@class sphere.InputAnimationView
---@operator call: sphere.InputAnimationView
local InputAnimationView = class()

function InputAnimationView:load()
	self.count = 0
end

---@param event table
function InputAnimationView:receive(event)
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

	self.count = math.max(self.count, 0)  -- first event can be release
	if self.count > 0 then
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

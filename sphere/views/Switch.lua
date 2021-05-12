
local Class			= require("aqua.util.Class")
local belong		= require("aqua.math").belong

local Switch = Class:new()

Switch.x = 0
Switch.y = 0
Switch.w = 0
Switch.h = 0
Switch.value = 0
Switch.pressed = false

Switch.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

Switch.setValue = function(self, value)
	self.value = value
end

Switch.receive = function(self, event)
	if event.name == "mousepressed" then
		local mx = event.args[1]
		local my = event.args[2]
		local x, y, w, h = self.x, self.y, self.w, self.h
		if belong(mx, x, x + w) and belong(my, y, y + h) then
			local button = event.args[3]
			if button == 1 then
				self.value = self.value == 0 and 1 or 0
				self.valueUpdated = true
			end
		end
	end
end

return Switch

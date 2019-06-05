local Class = require("aqua.util.Class")
local json = require("json")

local WindowManager = Class:new()

WindowManager.filePath = "userdata/window.json"

WindowManager.load = function(self)
	local file = io.open(self.filePath, "r")
	self.modes = json.decode(file:read("*all"))
	file:close()
	
	self.currentMode = 1
	self:setMode()
end

WindowManager.receive = function(self, event, object)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f11" then
			self.currentMode = self.currentMode % #self.modes + 1
			self:setMode(self.currentMode)
		end
	end
end

WindowManager.setMode = function(self)
	local mode = self.modes[self.currentMode]
	love.window.setMode(mode.width, mode.height, mode.flags)
	love.resize(mode.width, mode.height)
	print(mode.width, mode.height)
end

return WindowManager

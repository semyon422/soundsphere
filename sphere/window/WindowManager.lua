local json	= require("json")

local WindowManager = {}

WindowManager.path = "userdata/window.json"

WindowManager.load = function(self)
	local file = io.open(self.path, "r")
	self.modes = json.decode(file:read("*all"))
	file:close()
	
	self.currentMode = 1
	self:setMode()
end

WindowManager.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "f11" then
		self.currentMode = self.currentMode % #self.modes + 1
		self:setMode()
	end
end

WindowManager.setMode = function(self)
	local mode = self.modes[self.currentMode]
	love.window.setMode(mode.width, mode.height, mode.flags)
	love.resize(mode.width, mode.height)
end

return WindowManager

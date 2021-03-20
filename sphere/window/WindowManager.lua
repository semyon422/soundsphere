local Class	= require("aqua.util.Class")
local json	= require("json")

local WindowManager = Class:new()

WindowManager.path = "userdata/window.json"

WindowManager.load = function(self)
	self.modes = self.configModel:getConfig("window")

	self.currentMode = 1
	self:setMode()
	self:setIcon()
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

local icon_path = "resources/icon.png"
WindowManager.setIcon = function(self)
	local info = love.filesystem.getInfo(icon_path)
	if info then
		local imageData = love.image.newImageData(icon_path)
		love.window.setIcon(imageData)
	end
end

return WindowManager

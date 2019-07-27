local CoordinateManager = require("aqua.graphics.CoordinateManager")
local Rectangle = require("aqua.graphics.Rectangle")
local aquafonts = require("aqua.assets.fonts")
local Theme = require("aqua.ui.Theme")
local map = require("aqua.math").map
local spherefonts = require("sphere.assets.fonts")

local ProgressBar = {}

ProgressBar.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")

ProgressBar.load = function(self)
	self.font = self.font or aquafonts.getFont(spherefonts.NotoSansRegular, 48)
	
	self.progressRectangle = Rectangle:new({
		x = 0, y = 0.995,
		w = 1, h = 0.005,
		cs = self.cs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	self.progressRectangle:reload()
	
	self.startTime = self.engine.noteChart:hashGet("minTime")
	self.endTime = self.engine.noteChart:hashGet("maxTime")
end

ProgressBar.update = function(self, dt)
	local currentTime = self.engine.currentTime
	local x, width = 0, 1
	if currentTime < self.startTime then
		self.zeroTime = self.zeroTime or currentTime
		width = 1 - map(currentTime, self.zeroTime, self.startTime, 0, 1)
		x = 1 - width
	elseif currentTime < self.endTime then
		width = map(currentTime, self.startTime, self.endTime, 0, 1)
	end
	self.progressRectangle.x = x
	self.progressRectangle.w = width
	self.progressRectangle:reload()
end

ProgressBar.draw = function(self)
	self.progressRectangle:draw()
end

ProgressBar.receive = function(self, event)
	if event.name == "resize" then
		self.progressRectangle:reload()
	end
end

return ProgressBar

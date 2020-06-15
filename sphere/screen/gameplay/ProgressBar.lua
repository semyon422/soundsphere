local aquafonts			= require("aqua.assets.fonts")
local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local map				= require("aqua.math").map
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")

local ProgressBar = Class:new()

ProgressBar.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.color = self.data.color
	self.mode = self.data.mode
	self.direction = self.data.direction
	self.blendMode = self.data.blendMode
	self.blendAlphaMode = self.data.blendAlphaMode

	self.noteChart = self.gui.noteChart
	self.container = self.gui.container
	self.logicEngine = self.gui.logicEngine
	
	self:load()
end

ProgressBar.load = function(self)
	self.progressRectangle = Rectangle:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		cs = self.cs,
		color = self.color,
		mode = "fill",
		blendMode = self.blendMode,
		blendAlphaMode = self.blendAlphaMode,
		layer = self.layer
	})
	self.progressRectangle:reload()
	
	self.startTime = self.noteChart.metaData:get("minTime")
	self.endTime = self.noteChart.metaData:get("maxTime")

	self.container:add(self.progressRectangle)
end

ProgressBar.unload = function(self)
	self.container:remove(self.progressRectangle)
end

ProgressBar.update = function(self, dt)
	local currentTime = self.logicEngine.currentTime
	self.zeroTime = self.zeroTime or currentTime
	
	local x0, w0 = self.x, self.w
	local y0, h0 = self.y, self.h
	local x, y, w, h
	if self.mode == "+" then
		if self.direction == "left-right" then
			if currentTime < self.startTime then
				w = w0 - map(currentTime, self.zeroTime, self.startTime, 0, w0)
				x = x0 + w0 - w
			elseif currentTime < self.endTime then
				w = map(currentTime, self.startTime, self.endTime, 0, w0)
			end
		elseif self.direction == "right-left" then
			if currentTime < self.startTime then
				w = w0 - map(currentTime, self.zeroTime, self.startTime, 0, w0)
			elseif currentTime < self.endTime then
				w = map(currentTime, self.startTime, self.endTime, 0, w0)
				x = x0 + w0 - w
			end
		elseif self.direction == "up-down" then
			if currentTime < self.startTime then
				h = h0 - map(currentTime, self.zeroTime, self.startTime, 0, h0)
				y = y0 + h0 - h
			elseif currentTime < self.endTime then
				h = map(currentTime, self.startTime, self.endTime, 0, h0)
			end
		elseif self.direction == "down-up" then
			if currentTime < self.startTime then
				h = h0 - map(currentTime, self.zeroTime, self.startTime, 0, h0)
			elseif currentTime < self.endTime then
				h = map(currentTime, self.startTime, self.endTime, 0, h0)
				y = y0 + h0 - h
			end
		else
		end
	elseif self.mode == "-" then
		if self.direction == "left-right" then
			if currentTime < self.startTime then
				w = map(currentTime, self.zeroTime, self.startTime, 0, w0)
			elseif currentTime < self.endTime then
				w = w0 - map(currentTime, self.startTime, self.endTime, 0, w0)
				x = x0 + w0 - w
			end
		elseif self.direction == "right-left" then
			if currentTime < self.startTime then
				w = map(currentTime, self.zeroTime, self.startTime, 0, w0)
				x = x0 + w0 - w
			elseif currentTime < self.endTime then
				w = w0 - map(currentTime, self.startTime, self.endTime, 0, w0)
			end
		elseif self.direction == "up-down" then
			if currentTime < self.startTime then
				h = map(currentTime, self.zeroTime, self.startTime, 0, h0)
			elseif currentTime < self.endTime then
				h = h0 - map(currentTime, self.startTime, self.endTime, 0, h0)
				y = y0 + h0 - h
			end
		elseif self.direction == "down-up" then
			if currentTime < self.startTime then
				h = map(currentTime, self.zeroTime, self.startTime, 0, h0)
				y = y0 + h0 - h
			elseif currentTime < self.endTime then
				h = h0 - map(currentTime, self.startTime, self.endTime, 0, h0)
			end
		end
	end
	self.progressRectangle.x = x or x0
	self.progressRectangle.w = w or w0
	self.progressRectangle.y = y or y0
	self.progressRectangle.h = h or h0
	self.progressRectangle:reload()
end

ProgressBar.draw = function(self)
	self.progressRectangle:draw()
end

ProgressBar.receive = function(self, event) end

ProgressBar.reload = function(self)
	self.progressRectangle:reload()
end

return ProgressBar

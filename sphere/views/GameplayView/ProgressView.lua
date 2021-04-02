local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local map				= require("aqua.math").map

local ProgressView = Class:new()

ProgressView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))

	state.startTime = self.noteChartModel.noteChart.metaData:get("minTime")
	state.endTime = self.noteChartModel.noteChart.metaData:get("maxTime")
end

ProgressView.update = function(self, dt) end
ProgressView.unload = function(self) end

ProgressView.draw = function(self)
	local config = self.config
	local state = self.state

	local cs = state.cs
    local x, y, w, h = self:getRectangle()

	love.graphics.setColor(config.color)
	love.graphics.rectangle(
		"fill",
		cs:X(x, true),
		cs:Y(y, true),
		cs:X(w),
		cs:Y(h)
	)
end

ProgressView.receive = function(self, event)
	if event.name == "TimeState" then
		self.state.currentTime = event.exactCurrentTime
	end
end

ProgressView.getRectangle = function(self)
	local config = self.config
	local state = self.state

	local currentTime = state.currentTime or 0
	state.zeroTime = state.zeroTime or currentTime

	local direction = config.direction
	local startTime = state.startTime
	local endTime = state.endTime
	local zeroTime = state.zeroTime

	local x0, y0, w0, h0 = config.x, config.y, config.w, config.h
	local x, y, w, h = x0, y0, w0, h0
	if config.mode == "+" then
		if direction == "left-right" then
			if currentTime < startTime then
				w = w0 - map(currentTime, zeroTime, startTime, 0, w0)
				x = x0 + w0 - w
			elseif currentTime < endTime then
				w = map(currentTime, startTime, endTime, 0, w0)
			end
		elseif direction == "right-left" then
			if currentTime < startTime then
				w = w0 - map(currentTime, zeroTime, startTime, 0, w0)
			elseif currentTime < endTime then
				w = map(currentTime, startTime, endTime, 0, w0)
				x = x0 + w0 - w
			end
		elseif direction == "up-down" then
			if currentTime < startTime then
				h = h0 - map(currentTime, zeroTime, startTime, 0, h0)
				y = y0 + h0 - h
			elseif currentTime < endTime then
				h = map(currentTime, startTime, endTime, 0, h0)
			end
		elseif direction == "down-up" then
			if currentTime < startTime then
				h = h0 - map(currentTime, zeroTime, startTime, 0, h0)
			elseif currentTime < endTime then
				h = map(currentTime, startTime, endTime, 0, h0)
				y = y0 + h0 - h
			end
		end
	elseif config.mode == "-" then
		if direction == "left-right" then
			if currentTime < startTime then
				w = map(currentTime, zeroTime, startTime, 0, w0)
			elseif currentTime < endTime then
				w = w0 - map(currentTime, startTime, endTime, 0, w0)
				x = x0 + w0 - w
			end
		elseif direction == "right-left" then
			if currentTime < startTime then
				w = map(currentTime, zeroTime, startTime, 0, w0)
				x = x0 + w0 - w
			elseif currentTime < endTime then
				w = w0 - map(currentTime, startTime, endTime, 0, w0)
			end
		elseif direction == "up-down" then
			if currentTime < startTime then
				h = map(currentTime, zeroTime, startTime, 0, h0)
			elseif currentTime < endTime then
				h = h0 - map(currentTime, startTime, endTime, 0, h0)
				y = y0 + h0 - h
			end
		elseif direction == "down-up" then
			if currentTime < startTime then
				h = map(currentTime, zeroTime, startTime, 0, h0)
				y = y0 + h0 - h
			elseif currentTime < endTime then
				h = h0 - map(currentTime, startTime, endTime, 0, h0)
			end
		end
	end
    return x, y, w, h
end

return ProgressView

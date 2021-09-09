local Class				= require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local ValueView = require("sphere.views.ValueView")

local ProgressView = Class:new()

ProgressView.load = function(self) end
ProgressView.update = function(self, dt) end
ProgressView.unload = function(self) end
ProgressView.receive = function(self, event) end

ProgressView.getValue = ValueView.getValue

ProgressView.draw = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

    local x, y, w, h = self:getRectangle()

	love.graphics.setColor(config.color)
	love.graphics.rectangle("fill", x, y, w, h)
end

ProgressView.getRectangle = function(self)
	local config = self.config

	local direction = config.direction
	local minTime = self:getValue(config.minField) or 0
	local maxTime = self:getValue(config.maxField) or 1
	local startTime = self:getValue(config.startField) or 0
	local currentTime = self:getValue(config.currentField) or 0

	local normTime = 1
	if currentTime < minTime then
		normTime = map(currentTime, startTime, minTime, 0, 1)
	elseif currentTime < maxTime then
		normTime = map(currentTime, minTime, maxTime, 0, 1)
	end
	local rNormTime = 1 - normTime

	local x0, y0, w0, h0 = config.x, config.y, config.w, config.h
	local x, y, w, h = x0, y0, w0, h0
	if config.mode == "+" then
		if direction == "left-right" then
			if currentTime < minTime then
				w = w0 * rNormTime
				x = x0 + w0 - w
			elseif currentTime < maxTime then
				w = w0 * normTime
			end
		elseif direction == "right-left" then
			if currentTime < minTime then
				w = w0 * rNormTime
			elseif currentTime < maxTime then
				w = w0 * normTime
				x = x0 + w0 - w
			end
		elseif direction == "up-down" then
			if currentTime < minTime then
				h = h0 * rNormTime
				y = y0 + h0 - h
			elseif currentTime < maxTime then
				h = h0 * normTime
			end
		elseif direction == "down-up" then
			if currentTime < minTime then
				h = h0 * rNormTime
			elseif currentTime < maxTime then
				h = h0 * normTime
				y = y0 + h0 - h
			end
		end
	elseif config.mode == "-" then
		if direction == "left-right" then
			if currentTime < minTime then
				w = w0 * normTime
			elseif currentTime < maxTime then
				w = w0 * rNormTime
				x = x0 + w0 - w
			end
		elseif direction == "right-left" then
			if currentTime < minTime then
				w = w0 * normTime
				x = x0 + w0 - w
			elseif currentTime < maxTime then
				w = w0 * rNormTime
			end
		elseif direction == "up-down" then
			if currentTime < minTime then
				h = h0 * normTime
			elseif currentTime < maxTime then
				h = h0 * rNormTime
				y = y0 + h0 - h
			end
		elseif direction == "down-up" then
			if currentTime < minTime then
				h = h0 * normTime
				y = y0 + h0 - h
			elseif currentTime < maxTime then
				h = h0 * rNormTime
			end
		end
	end
    return x, y, w, h
end

return ProgressView

local Class				= require("Class")
local transform = require("gfx_util").transform
local map				= require("math_util").map

local ProgressView = Class:new()

ProgressView.draw = function(self)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

    local x, y, w, h = self:getRectangle()

	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", x, y, w, h)
end

ProgressView.getMin = function(self) return 0 end
ProgressView.getMax = function(self) return 1 end
ProgressView.getStart = function(self) return 0 end
ProgressView.getCurrent = function(self) return 0 end

ProgressView.getRectangle = function(self)
	local direction = self.direction
	local minTime = self:getMin()
	local maxTime = self:getMax()
	local startTime = self:getStart()
	local currentTime = self:getCurrent()

	local normTime = 1
	if currentTime < minTime then
		normTime = map(currentTime, startTime, minTime, 0, 1)
	elseif currentTime < maxTime then
		normTime = map(currentTime, minTime, maxTime, 0, 1)
	end
	local rNormTime = 1 - normTime

	local x0, y0, w0, h0 = self.x, self.y, self.w, self.h
	local x, y, w, h = x0, y0, w0, h0
	if self.mode == "+" then
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
	elseif self.mode == "-" then
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

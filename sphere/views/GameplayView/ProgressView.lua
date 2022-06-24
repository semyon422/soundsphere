local Class				= require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local inside = require("aqua.util.inside")

local ProgressView = Class:new()

ProgressView.draw = function(self)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

    local x, y, w, h = self:getRectangle()

	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", x, y, w, h)
end

ProgressView.getValue = function(self, field)
	if type(field) == "number" then
		return field
	elseif type(field) == "string" then
		return inside(self, field)
	elseif type(field) == "function" then
		return field(self)
	elseif type(field) == "table" then
		if field.value then
			return self:getValue(field.value)
		elseif field.key then
			return inside(self, field.key)
		end
	end
end

ProgressView.getRectangle = function(self)
	local direction = self.direction
	local minTime = self:getValue(self.min) or 0
	local maxTime = self:getValue(self.max) or 1
	local startTime = self:getValue(self.start) or 0
	local currentTime = self:getValue(self.current) or 0

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

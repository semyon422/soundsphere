local class = require("class")
local map = require("math_util").map

---@class sphere.ProgressView
---@operator call: sphere.ProgressView
local ProgressView = class()

function ProgressView:draw() end

---@return number
function ProgressView:getMin() return 0 end

---@return number
function ProgressView:getMax() return 1 end

---@return number
function ProgressView:getStart() return 0 end

---@return number
function ProgressView:getCurrent() return 0 end

---@return number
function ProgressView:getNormTime()
	local minTime = self:getMin()
	local maxTime = self:getMax()
	local startTime = self:getStart()
	local currentTime = self:getCurrent()

	local time = 1
	if currentTime < minTime then
		time = map(currentTime, startTime, minTime, -1, 0)
	elseif currentTime < maxTime then
		time = map(currentTime, minTime, maxTime, 0, 1)
	end

	return math.min(math.max(time, -1), 1)
end

---@param t number
---@return number
---@return number
local function form(t)
	if t < 0 then
		return 1 + t, -t
	end
	return 0, t
end

---@param t number
---@return number
---@return number
local function invf(t)
	local x, w = form(t)
	return x ~= 0 and 0 or w, 1 - w
end

---@return number
---@return number
function ProgressView:getForm()
	local dir = self.direction
	local time = self:getNormTime()

	if dir == "right-left" or dir == "down-up" then
		time = -time
	end

	local f = self.mode == "-" and invf or form
	return f(time)
end

return ProgressView

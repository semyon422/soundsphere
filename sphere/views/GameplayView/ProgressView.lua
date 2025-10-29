local class = require("class")
local map = require("math_util").map

---@class sphere.ProgressView
---@operator call: sphere.ProgressView
local ProgressView = class()

function ProgressView:draw() end

---@return number
function ProgressView:getProgress()
	return 0
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
	local time = self:getProgress()

	if dir == "right-left" or dir == "down-up" then
		time = -time
	end

	local f = self.mode == "-" and invf or form
	return f(time)
end

return ProgressView

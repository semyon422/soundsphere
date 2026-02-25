local class = require("class")
local sleep = require("sleep")
local jit = require("jit")

if jit.os == "Windows" then
	sleep = love.timer.sleep
end

---@class rizu.loop.LoopLimiter
---@operator call: rizu.loop.LoopLimiter
local LoopLimiter = class()

function LoopLimiter:new()
	self.fps_limit = 240
	self.unlimited_fps = false
	self.busy_loop_ratio = 0
	self.target_time = 0
end

---@param time number
function LoopLimiter:reset(time)
	self.target_time = time
end

---@return boolean
function LoopLimiter:shouldSleep()
	return self.fps_limit > 0 and not self.unlimited_fps
end

---@param frame_end_time number
function LoopLimiter:limit(frame_end_time)
	if not self:shouldSleep() then
		return
	end

	self.target_time = math.max(self.target_time + 1 / self.fps_limit, frame_end_time)
	self:sleep(self.target_time, frame_end_time)
end

---@param target_time number
---@param frame_end_time number
function LoopLimiter:sleep(target_time, frame_end_time)
	local frame_time = 1 / self.fps_limit
	local busy_time = self.busy_loop_ratio * frame_time
	local to_sleep = target_time - frame_end_time - busy_time
	if to_sleep > 0 then
		sleep(to_sleep)
	end
	while love.timer.getTime() < target_time do end
end

return LoopLimiter

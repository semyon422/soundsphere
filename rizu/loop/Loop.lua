local Observable = require("Observable")
local thread = require("thread")
local delay = require("delay")
local asynckey = require("asynckey")
local flux = require("flux")
local reqprof = require("reqprof")

local LoopEvents = require("rizu.loop.LoopEvents")
local LoopLimiter = require("rizu.loop.LoopLimiter")
local LoopQuitting = require("rizu.loop.LoopQuitting")
local LoopGraphics = require("rizu.loop.LoopGraphics")

---@class rizu.loop.Loop: util.Observable
---@operator call: rizu.loop.Loop
local Loop = Observable + {}

function Loop:init()
	self.limiter = LoopLimiter()
	self.events = LoopEvents(self)
	self.quitter = LoopQuitting(self)
	self.graphics = LoopGraphics(self)

	self.time = 0
	self.dt = 0
	self.start_time = 0
	self.stats = {}
	self.dt_limit = 1 / 10
	self.timings = {
		event = 0,
		update = 0,
		draw = 0,
	}

	self.quitting = false

	love.quit = function(...)
		print("Quitting")
		self.quitting = true
		return true
	end
end

-- Setters for configuration
function Loop:setFpsLimit(limit) self.limiter.fps_limit = limit end
function Loop:setUnlimitedFps(enabled) self.limiter.unlimited_fps = enabled end
function Loop:setBusyLoopRatio(ratio) self.limiter.busy_loop_ratio = ratio end
function Loop:setAsynckey(enabled) self.events.asynckey = enabled end
function Loop:setDwmFlush(enabled) self.graphics.dwm_flush = enabled end

---@return number?
function Loop:quittingLoop()
	return self.quitter:update()
end

function Loop:_update(dt)
	local timings_update_start = love.timer.getTime()

	thread.update()
	delay.update()
	flux.update(math.min(dt, self.dt_limit))
	self.events:dispatchEvent("update", dt)

	self.timings.update = love.timer.getTime() - timings_update_start
end

---@return function
function Loop:run()
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time())
	love.timer.step()

	local start_time = love.timer.getTime()
	self.limiter:reset(start_time)
	self.prev_time = start_time
	self.time = start_time
	self.start_time = start_time
	self.dt = 0

	return function()
		if self.quitting then
			return self:quittingLoop()
		end

		reqprof.start()

		if self.events.asynckey and asynckey.start then
			asynckey.start()
		end

		love.timer.step()
		local time = love.timer.getTime()

		self.dt = time - self.time
		self.prev_time, self.time = self.time, time

		local quit_res = self.events:pollEvents(time)
		if quit_res then return quit_res end

		self:_update(self.dt)

		local frame_end_time = self.graphics:draw()

		self.limiter:limit(frame_end_time)
	end
end

return Loop

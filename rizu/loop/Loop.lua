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
local SleepFunctionFactory = require("rizu.loop.sleep.SleepFunctionFactory")

---@class rizu.Loop: util.Observable
---@operator call: rizu.Loop
local Loop = Observable + {}

function Loop:init()
	self.limiter = LoopLimiter(self)
	self.events = LoopEvents(self)
	self.quitter = LoopQuitting(self)
	self.graphics = LoopGraphics(self)
	self.sleep_function_factory = SleepFunctionFactory()

	self.time = 0
	self.dt = 0
	self.start_time = 0
	self.stats = {}
	self.dt_limit = 1 / 10
	self.timings = {
		event = 0,
		update = 0,
		draw = 0,
		present = 0,
		sleep = 0,
		busy = 0,
	}

	self.mem_count = collectgarbage("count")
	self.mem_delta = 0
	self.ema_dt = 0
	self.ema_jitter = 0
	self.prev_frame_dt = 0

	self.quitting = false

	self.frame_started = {name = "framestarted"}

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
function Loop:setSleepFunction(_type)
	self.limiter.sleep_function = self.sleep_function_factory:get(_type)
end

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

		-- Metrics calculation
		local alpha = 0.05
		self.ema_dt = self.ema_dt == 0 and self.dt or (self.ema_dt * (1 - alpha) + self.dt * alpha)
		self.jitter = math.abs(self.dt - self.prev_frame_dt)
		self.ema_jitter = self.ema_jitter == 0 and self.jitter or (self.ema_jitter * (1 - alpha) + self.jitter * alpha)
		self.prev_frame_dt = self.dt

		local current_mem = collectgarbage("count")
		self.mem_delta = current_mem - self.mem_count
		self.mem_count = current_mem

		self.frame_started.time = self.time
		self.frame_started.dt = self.dt
		self:send(self.frame_started)

		local quit_res = self.events:pollEvents(time)
		if quit_res then return quit_res end

		self:_update(self.dt)

		local frame_end_time = self.graphics:draw()

		self.limiter:limit(frame_end_time)
	end
end

return Loop

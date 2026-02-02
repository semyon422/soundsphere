local Observable = require("Observable")
local thread = require("thread")
local delay = require("delay")
local asynckey = require("asynckey")
local just = require("just")
local flux = require("flux")
local reqprof = require("reqprof")
local sleep = require("sleep")
local jit = require("jit")

local MidiInputFactory = require("native.midi.MidiInputFactory")

if jit.os == "Windows" then
	sleep = love.timer.sleep
end

-- Static class

---@class sphere.Loop: util.Observable
---@operator call: sphere.Loop
local Loop = Observable + {}

Loop.fpslimit = 240
Loop.unlimited_fps = false
Loop.time = 0
Loop.dt = 0
Loop.eventTime = 0
Loop.startTime = 0
Loop.stats = {}
Loop.asynckey = false
Loop.dwmflush = false
Loop.timings = {
	event = 0,
	update = 0,
	draw = 0,
}

local dwmapi
if love.system.getOS() == "Windows" then
	local ffi = require("ffi")
	dwmapi = ffi.load("dwmapi")
	ffi.cdef("void DwmFlush();")
end

Loop.quitting = false
---@return number?
function Loop:quittingLoop()
	love.event.pump()

	for name, a, b, c, d, e, f in love.event.poll() do
		if name == "quit" then
			Loop:send({name = "quit"})
			return 0
		end
	end

	thread.update()
	delay.update()

	if thread.current == 0 then
		Loop:send({name = "quit"})
		return 0
	end

	if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("waiting for " .. thread.current .. " coroutines", 0, 0, 1000, "left")
		love.graphics.present()
	end

	love.timer.sleep(0.1)
end

local framestarted = {name = "framestarted"}
---@return function
function Loop:run()
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time())
	love.timer.step()

	local fpsLimitTime = love.timer.getTime()
	Loop.prevTime = fpsLimitTime
	Loop.time = fpsLimitTime
	Loop.startTime = fpsLimitTime
	Loop.dt = 0

	local midiInputFactory = MidiInputFactory()
	local midiInput = midiInputFactory:getMidiInput()

	return function()
		if Loop.quitting then
			return Loop:quittingLoop()
		end

		reqprof.start()

		if Loop.asynckey and asynckey.start then
			asynckey.start()
		end

		love.timer.step()
		local time = love.timer.getTime()

		Loop.dt = time - Loop.time
		Loop.prevTime, Loop.time = Loop.time, time

		local timingsEvent = Loop.time

		love.event.pump()

		local asynckeyWorking = Loop.asynckey and asynckey.events
		if asynckeyWorking then
			if love.window.hasFocus() then
				for event in asynckey.events do
					Loop.eventTime = event.time
					if event.state then
						love.keypressed(event.key, event.key)
					else
						love.keyreleased(event.key, event.key)
					end
				end
			else
				asynckey.clear()
			end
		end

		Loop.eventTime = (Loop.prevTime + Loop.time) / 2
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					Loop:quit()
					return a or 0
				end
			end
			if not asynckeyWorking or name ~= "keypressed" and name ~= "keyreleased" then
				love.handlers[name](a, b, c, d, e, f)
			end
		end

		for port, note, status in midiInput:events() do
			if status then
				love.midipressed(note)
			else
				love.midireleased(note)
			end
		end

		framestarted.time = Loop.time
		framestarted.dt = Loop.dt
		Loop:send(framestarted)

		local timingsUpdate = love.timer.getTime()
		Loop.timings.event = timingsUpdate - timingsEvent

		thread.update()
		delay.update()
		flux.update(math.min(Loop.dt, 1 / 60))
		love.update(Loop.dt)

		local timingsDraw = love.timer.getTime()
		Loop.timings.update = timingsDraw - timingsUpdate

		local frameEndTime
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.draw()
			just._end()
			love.graphics.origin()
			love.graphics.getStats(Loop.stats)
			love.graphics.present() -- all new events are read when present is called
			if dwmapi and Loop.dwmflush then
				dwmapi.DwmFlush()
			end
			frameEndTime = love.timer.getTime()
		end

		local timingsSleep = love.timer.getTime()
		Loop.timings.draw = timingsSleep - timingsDraw

		if Loop.fpslimit > 0 and not Loop.unlimited_fps then
			fpsLimitTime = math.max(fpsLimitTime + 1 / Loop.fpslimit, frameEndTime)
			sleep(fpsLimitTime - frameEndTime)
		end
	end
end

Loop.callbacks = {
	"update",
	"draw",
	"textinput",
	"keypressed",
	"keyreleased",
	"mousepressed",
	"gamepadaxis",
	"gamepadpressed",
	"gamepadreleased",
	"joystickaxis",
	"joystickpressed",
	"joystickreleased",
	"midipressed",
	"midireleased",
	"mousemoved",
	"mousereleased",
	"wheelmoved",
	"resize",
	-- "quit",
	"filedropped",
	"directorydropped",
	"focus",
	"mousefocus",
}

-- all events are from [time - dt, time]

---@param time number
---@return number
local function clampEventTime(time)
	return math.min(math.max(time, Loop.prevTime), Loop.time)
end

local function transformInputEvent(name, ...)
	if name == "keypressed" then
		return "keyboard", 1, select(2, ...), true
	elseif name == "keyreleased" then
		return "keyboard", 1, select(2, ...), false
	elseif name == "gamepadpressed" then
		return "gamepad", select(1, ...):getID(), select(2, ...), true
	elseif name == "gamepadreleased" then
		return "gamepad", select(1, ...):getID(), select(2, ...), false
	elseif name == "joystickpressed" then
		return "joystick", select(1, ...):getID(), select(2, ...), true
	elseif name == "joystickreleased" then
		return "joystick", select(1, ...):getID(), select(2, ...), false
	elseif name == "midipressed" then
		return "midi", 1, select(1, ...), true
	elseif name == "midireleased" then
		return "midi", 1, select(1, ...), false
	end
end

local re = {}
local function resend_transformed(...)
	if not ... then
		return
	end
	local name = "inputchanged"
	local icb = just.callbacks[name]
	if icb and icb(...) then return end
	re[1], re[2], re[3], re[4], re[5], re[6] = ...
	re.name = name
	re.time = clampEventTime(Loop.eventTime)
	return Loop:send(re)
end

function Loop:init()
	local e = {}
	for _, name in pairs(Loop.callbacks) do
		love[name] = function(...)
			resend_transformed(transformInputEvent(name, ...))
			local icb = just.callbacks[name]
			if icb and icb(...) then return end
			e[1], e[2], e[3], e[4], e[5], e[6] = ...
			e.name = name
			e.time = clampEventTime(Loop.eventTime)
			return Loop:send(e)
		end
	end
	love.quit = function(...)
		print("Quitting")
		Loop.quitting = true
		return true
	end
end

function Loop:quit()
	LuaMidi.gc()
end

return Loop

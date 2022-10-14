local Observable = require("Observable")
local thread = require("thread")
local delay = require("delay")
local asynckey = require("asynckey")
local just = require("just")
local LuaMidi = require("luamidi")

local loop = Observable:new()

loop.fpslimit = 240
loop.time = 0
loop.dt = 0
loop.eventTime = 0
loop.startTime = 0
loop.stats = {}
loop.asynckey = false
loop.dwmflush = false
loop.timings = {
	event = 0,
	update = 0,
	draw = 0,
}

loop.midistate = {}
loop.keystate = {}
loop.gamepadstate = {}
loop.joystickstate = {}

local dwmapi
if love.system.getOS() == "Windows" then
	local ffi = require("ffi")
	dwmapi = ffi.load("dwmapi")
	ffi.cdef("void DwmFlush();")
end

local hasMidi
local function getinportcount()
	return hasMidi and LuaMidi.getinportcount() or 0
end

local framestarted = {name = "framestarted"}
loop.run = function()
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time())
	love.timer.step()

	local fpsLimitTime = love.timer.getTime()
	loop.time = fpsLimitTime
	loop.startTime = fpsLimitTime
	loop.dt = 0

	hasMidi = LuaMidi.getinportcount() > 0

	return function()
		if loop.asynckey and asynckey.start then
			asynckey.start()
		end

		loop.dt = love.timer.step()
		loop.time = love.timer.getTime()

		local timingsEvent = loop.time

		love.event.pump()

		framestarted.time = loop.time
		framestarted.dt = loop.dt
		loop:send(framestarted)

		local asynckeyWorking = loop.asynckey and asynckey.events
		if asynckeyWorking then
			if love.window.hasFocus() then
				for event in asynckey.events do
					loop.eventTime = event.time
					if event.state then
						love.keypressed(event.key, event.key)
						loop.keystate[event.key] = true
					else
						love.keyreleased(event.key, event.key)
						loop.keystate[event.key] = nil
					end
				end
			else
				asynckey.clear()
			end
		end

		loop.eventTime = loop.time - loop.dt / 2
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					loop.quit()
					return a or 0
				end
			end
			if not asynckeyWorking or name ~= "keypressed" and name ~= "keyreleased" then
				if name == "keypressed" then
					loop.keystate[b] = true
				elseif name == "keyreleased" then
					loop.keystate[b] = nil
				elseif name == "gamepadpressed" then
					loop.gamepadstate[b] = true
				elseif name == "gamepadreleased" then
					loop.gamepadstate[b] = nil
				elseif name == "joystickpressed" then
					loop.joystickstate[b] = true
				elseif name == "joystickreleased" then
					loop.joystickstate[b] = nil
				end
				love.handlers[name](a, b, c, d, e, f)
			end
		end

		for i = 0, getinportcount() - 1 do
			-- command, note, velocity, delta-time-to-last-event
			local a, b, c, d = LuaMidi.getMessage(i)
			while a do
				if a == 144 and c ~= 0 then
					love.midipressed(b, c, d)
					loop.midistate[b] = true
				elseif a == 128 or c == 0 then
					love.midireleased(b, c, d)
					loop.midistate[b] = nil
				end
				a, b, c, d = LuaMidi.getMessage(i)
			end
		end

		local timingsUpdate = love.timer.getTime()
		loop.timings.event = timingsUpdate - timingsEvent

		thread.update()
		delay.update()
		love.update(loop.dt)

		local timingsDraw = love.timer.getTime()
		loop.timings.update = timingsDraw - timingsUpdate

		local frameEndTime
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.draw()
			just._end()
			love.graphics.origin()
			love.graphics.getStats(loop.stats)
			love.graphics.present() -- all new events are read when present is called
			if dwmapi and loop.dwmflush then
				dwmapi.DwmFlush()
			end
			frameEndTime = love.timer.getTime()
		end

		local timingsSleep = love.timer.getTime()
		loop.timings.draw = timingsSleep - timingsDraw

		if loop.fpslimit > 0 then
			fpsLimitTime = math.max(fpsLimitTime + 1 / loop.fpslimit, frameEndTime)
			love.timer.sleep(fpsLimitTime - frameEndTime)
		end
	end
end

loop.callbacks = {
	"update",
	"draw",
	"textinput",
	"keypressed",
	"keyreleased",
	"mousepressed",
	"gamepadpressed",
	"gamepadreleased",
	"joystickpressed",
	"joystickreleased",
	"midipressed",
	"midireleased",
	"mousemoved",
	"mousereleased",
	"wheelmoved",
	"resize",
	"quit",
	"filedropped",
	"directorydropped",
	"focus",
	"mousefocus",
}

-- all events are from [time - dt, time]
local clampEventTime = function(time)
	return math.min(math.max(time, loop.time - loop.dt), loop.time)
end

loop.init = function()
	local e = {}
	for _, name in pairs(loop.callbacks) do
		love[name] = function(...)
			local icb = just.callbacks[name]
			if icb and icb(...) then return end
			e[1], e[2], e[3], e[4], e[5], e[6] = ...
			e.name = name
			e.time = clampEventTime(loop.eventTime)
			return loop:send(e)
		end
	end
end

loop.quit = function()
	LuaMidi.gc()
end

return loop

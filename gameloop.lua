local Observable = require("Observable")
local aquathread = require("thread")
local aquadelay = require("delay")
local asynckey = require("asynckey")
local just = require("just")
local LuaMidi = require("luamidi")

local gameloop = Observable:new()

gameloop.fpslimit = 240
gameloop.tpslimit = 240
gameloop.time = 0
gameloop.dt = 0
gameloop.eventTime = 0
gameloop.startTime = 0
gameloop.stats = {}
gameloop.asynckey = false
gameloop.dwmflush = false
gameloop.timings = {
	event = 0,
	update = 0,
	draw = 0,
}

gameloop.midistate = {}
gameloop.keystate = {}
gameloop.gamepadstate = {}
gameloop.joystickstate = {}

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
gameloop.run = function()
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time())
	love.timer.step()

	local fpsLimitTime = love.timer.getTime()
	gameloop.time = fpsLimitTime
	gameloop.startTime = fpsLimitTime
	gameloop.dt = 0

	hasMidi = LuaMidi.getinportcount() > 0

	return function()
		if gameloop.asynckey and asynckey.start then
			asynckey.start()
		end

		gameloop.dt = love.timer.step()
		gameloop.time = love.timer.getTime()

		local timingsEvent = gameloop.time

		love.event.pump()

		framestarted.time = gameloop.time
		framestarted.dt = gameloop.dt
		gameloop:send(framestarted)

		local asynckeyWorking = gameloop.asynckey and asynckey.events
		if asynckeyWorking then
			if love.window.hasFocus() then
				for event in asynckey.events do
					gameloop.eventTime = event.time
					if event.state then
						love.keypressed(event.key, event.key)
						gameloop.keystate[event.key] = true
					else
						love.keyreleased(event.key, event.key)
						gameloop.keystate[event.key] = nil
					end
				end
			else
				asynckey.clear()
			end
		end

		gameloop.eventTime = gameloop.time - gameloop.dt / 2
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					gameloop.quit()
					return a or 0
				end
			end
			if not asynckeyWorking or name ~= "keypressed" and name ~= "keyreleased" then
				if name == "keypressed" then
					gameloop.keystate[b] = true
				elseif name == "keyreleased" then
					gameloop.keystate[b] = nil
				elseif name == "gamepadpressed" then
					gameloop.gamepadstate[b] = true
				elseif name == "gamepadreleased" then
					gameloop.gamepadstate[b] = nil
				elseif name == "joystickpressed" then
					gameloop.joystickstate[b] = true
				elseif name == "joystickreleased" then
					gameloop.joystickstate[b] = nil
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
					gameloop.midistate[b] = true
				elseif a == 128 or c == 0 then
					love.midireleased(b, c, d)
					gameloop.midistate[b] = nil
				end
				a, b, c, d = LuaMidi.getMessage(i)
			end
		end

		local timingsUpdate = love.timer.getTime()
		gameloop.timings.event = timingsUpdate - timingsEvent

		aquathread.update()
		aquadelay.update()
		love.update(gameloop.dt)

		local timingsDraw = love.timer.getTime()
		gameloop.timings.update = timingsDraw - timingsUpdate

		local frameEndTime
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.draw()
			just._end()
			love.graphics.origin()
			love.graphics.getStats(gameloop.stats)
			love.graphics.present() -- all new events are read when present is called
			if dwmapi and gameloop.dwmflush then
				dwmapi.DwmFlush()
			end
			frameEndTime = love.timer.getTime()
		end

		local timingsSleep = love.timer.getTime()
		gameloop.timings.draw = timingsSleep - timingsDraw

		fpsLimitTime = math.max(fpsLimitTime + 1 / gameloop.fpslimit, frameEndTime)
		love.timer.sleep(fpsLimitTime - frameEndTime)
	end
end

gameloop.callbacks = {
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
	return math.min(math.max(time, gameloop.time - gameloop.dt), gameloop.time)
end

gameloop.init = function()
	local e = {}
	for _, name in pairs(gameloop.callbacks) do
		love[name] = function(...)
			local icb = just.callbacks[name]
			if icb and icb(...) then return end
			e[1], e[2], e[3], e[4], e[5], e[6] = ...
			e.name = name
			e.time = clampEventTime(gameloop.eventTime)
			return gameloop:send(e)
		end
	end
end

gameloop.quit = function()
	LuaMidi.gc()
end

return gameloop

local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Replay		= require("sphere.screen.gameplay.ReplayManager.Replay")

local ReplayManager = Class:new()

ReplayManager.init = function(self)
	self.observable = Observable:new()
	self.mode = "record"
end

ReplayManager.load = function(self)
	if self.mode == "record" then
		self.replay = Replay:new()
	elseif self.mode == "replay" then
		self.replay:reset()
	end
end

ReplayManager.setMode = function(self, mode)
	self.mode = mode
end

ReplayManager.send = function(self, event)
	return self.observable:send(event)
end

ReplayManager.receive = function(self, event)
	local timeEngine = self.timeEngine
	if timeEngine.timeRate == 0 then
		return
	end
	local currentTime = timeEngine.exactCurrentTime

	local replay = self.replay
	local mode = self.mode
	if mode == "record" and event.virtual then
		event.time = currentTime
		replay:receive(event)
	elseif mode == "replay" and event.name == "TimeState" then
		local nextEvent = replay:getNextEvent()
		if not nextEvent then
			return
		end

		if currentTime >= nextEvent.time then
			self:send(nextEvent)
			replay:step()
		end
	end
end

return ReplayManager

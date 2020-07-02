local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Replay		= require("sphere.screen.gameplay.ReplayManager.Replay")
local md5			= require("md5")

local ReplayManager = Class:new()

ReplayManager.path = "userdata/replays"

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

ReplayManager.saveReplay = function(self, noteChartDataEntry, modifierSequence)
	local replay = self.replay
	replay.noteChartDataEntry = noteChartDataEntry
	replay.modifierSequence = modifierSequence

	local replayString = replay:toString()
	local replayHash = md5.sumhexa(replayString)

	local file = io.open(self.path .. "/" .. replayHash, "w")
	file:write(replayString)
	file:close()

	return replayHash
end

ReplayManager.loadReplay = function(self, replayHash)
	local file = io.open(self.path .. "/" .. replayHash, "r")
	local replayString = file:read("*all")
	file:close()

	return Replay:new():fromString(replayString)
end

return ReplayManager

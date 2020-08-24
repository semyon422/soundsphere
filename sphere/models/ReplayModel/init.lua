local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Replay		= require("sphere.models.ReplayModel.Replay")
local md5			= require("md5")

local ReplayModel = Class:new()

ReplayModel.path = "userdata/replays"

ReplayModel.construct = function(self)
	self.observable = Observable:new()
	self.mode = "record"
end

ReplayModel.load = function(self)
	if self.mode == "record" then
		self.replay = Replay:new()
	elseif self.mode == "replay" then
		self.replay:reset()
	end
end

ReplayModel.setMode = function(self, mode)
	self.mode = mode
end

ReplayModel.send = function(self, event)
	return self.observable:send(event)
end

ReplayModel.receive = function(self, event)
	if event.name == "TimeState" then
		self.currentTime = event.exactCurrentTime
		return
	end

	if self.mode == "record" and event.virtual then
		self.replay:receive(event)
	end
end

ReplayModel.update = function(self)
	if self.mode == "replay" then
		local replay = self.replay
		local nextEvent = replay:getNextEvent()
		if not nextEvent then
			return
		end

		if self.currentTime >= nextEvent.time then
			self:send(nextEvent)
			replay:step()
			return self:update()
		end
	end
end

ReplayModel.saveReplay = function(self, noteChartDataEntry, modifierSequence)
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

ReplayModel.loadReplay = function(self, replayHash)
	local path = self.path .. "/" .. replayHash

	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		return Replay:new()
	end

	local file = io.open(path, "r")
	local replayString = file:read("*all")
	file:close()

	return Replay:new():fromString(replayString)
end

return ReplayModel

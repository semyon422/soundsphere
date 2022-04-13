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
	self.replay.timeEngine = self.rhythmModel.timeEngine
end

ReplayModel.setMode = function(self, mode)
	self.mode = mode
end

ReplayModel.send = function(self, event)
	return self.observable:send(event)
end

ReplayModel.receive = function(self, event)
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

		nextEvent.baseTime = nextEvent.baseTime or nextEvent.time
		nextEvent.time = nextEvent.baseTime + self.rhythmModel.timeEngine.inputOffset
		if self.currentTime >= nextEvent.time then
			self:send(nextEvent)
			replay:step()
			return self:update()
		end
	end
end

ReplayModel.saveReplay = function(self)
	local replay = self.replay
	replay.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	replay.inputMode = self.noteChartModel.noteChart.inputMode
	replay.modifierTable = self.modifierModel.config
	replay.timings = self.timings

	local replayString = replay:toString()
	local replayHash = md5.sumhexa(replayString)

	assert(love.filesystem.write(self.path .. "/" .. replayHash, replayString))

	return replayHash
end

ReplayModel.loadReplay = function(self, replayHash)
	local path = self.path .. "/" .. replayHash

	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		return Replay:new()
	end

	local replayString = love.filesystem.read(path)
	return Replay:new():fromString(replayString)
end

return ReplayModel

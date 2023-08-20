local class = require("class")
local Replay = require("sphere.models.ReplayModel.Replay")
local md5 = require("md5")

---@class sphere.ReplayModel
---@operator call: sphere.ReplayModel
local ReplayModel = class()

ReplayModel.path = "userdata/replays"
ReplayModel.mode = "record"

function ReplayModel:load()
	if self.mode == "record" then
		self.replay = Replay()
	elseif self.mode == "replay" then
		self.replay:reset()
	end
	self.replay.timeEngine = self.rhythmModel.timeEngine
	self.replay.logicEngine = self.rhythmModel.logicEngine
end

---@param mode string
function ReplayModel:setMode(mode)
	self.mode = mode
end

---@param event table
function ReplayModel:receive(event)
	if self.mode == "record" and event.virtual then
		self.replay:receive(event)
	end
end

---@return nil?
function ReplayModel:update()
	if self.mode ~= "replay" then
		return
	end

	local replay = self.replay
	local nextEvent = replay:getNextEvent()
	if not nextEvent then
		return
	end

	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine
	local logicEngine = rhythmModel.logicEngine

	nextEvent.baseTime = nextEvent.baseTime or nextEvent.time
	nextEvent.time = nextEvent.baseTime + logicEngine.inputOffset
	if timeEngine.currentTime >= nextEvent.time then
		rhythmModel:receive(nextEvent)
		replay:step()
		return self:update()
	end
end

---@return string
function ReplayModel:saveReplay()
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

---@param content string
---@return sphere.Replay
function ReplayModel:loadReplay(content)
	local replay = Replay()
	if not content then
		return replay
	end

	return replay:fromString(content)
end

return ReplayModel

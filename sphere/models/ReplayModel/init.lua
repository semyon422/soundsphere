local class = require("class")
local Replay = require("sphere.models.ReplayModel.Replay")
local md5 = require("md5")
local path_util = require("path_util")

---@class sphere.ReplayModel
---@operator call: sphere.ReplayModel
local ReplayModel = class()

ReplayModel.path = "userdata/replays"
ReplayModel.mode = "record"

---@param rhythmModel sphere.RhythmModel
function ReplayModel:new(rhythmModel)
	self.rhythmModel = rhythmModel
end

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

---@param chartdiff table
---@param playContext sphere.PlayContext
---@return string
function ReplayModel:saveReplay(chartdiff, playContext)
	local replay = self.replay
	replay.hash = chartdiff.hash
	replay.index = chartdiff.index
	replay.inputMode = self.rhythmModel.chart.inputMode
	replay.rate_type = error("need ratetype here")
	playContext:save(replay)

	local replayString = replay:toString()
	local replayHash = md5.sumhexa(replayString)

	assert(love.filesystem.write(self.path .. "/" .. replayHash, replayString))

	return replayHash
end

---@param chartmeta sea.Chartmeta
function ReplayModel:saveOsr(chartmeta)
	local osr = self.replay:toOsr()
	local data = osr:encode()

	local display_title = ("%s - %s [%s]"):format(
		chartmeta.artist, chartmeta.title, chartmeta.name
	)

	local name = ("%s - %s (%s) OsuMania.osr"):format(
		osr.player_name,
		display_title,
		os.date("%Y-%m-%d", osr:getTimestamp())
	)

	love.filesystem.write(path_util.join("userdata", "export", name), data)
end

---@param content string
---@return sphere.Replay?
function ReplayModel:loadReplay(content)
	if not content then
		return
	end
	local replay = Replay()
	return replay:fromString(content)
end

return ReplayModel

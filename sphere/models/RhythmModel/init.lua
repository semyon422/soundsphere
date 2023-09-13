local class = require("class")
local Observable = require("Observable")
local ScoreEngine = require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine = require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine = require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine = require("sphere.models.RhythmModel.TimeEngine")
local InputManager = require("sphere.models.RhythmModel.InputManager")
local PauseManager = require("sphere.models.RhythmModel.PauseManager")
-- require("sphere.models.RhythmModel.LogicEngine.Test")

---@class sphere.RhythmModel
---@operator call: sphere.RhythmModel
local RhythmModel = class()

function RhythmModel:new()
	self.inputManager = InputManager()
	self.pauseManager = PauseManager()
	self.timeEngine = TimeEngine()
	self.scoreEngine = ScoreEngine()
	self.audioEngine = AudioEngine()
	self.logicEngine = LogicEngine()
	self.graphicEngine = GraphicEngine()
	self.observable = Observable()
	self.inputManager.rhythmModel = self
	self.pauseManager.rhythmModel = self
	self.timeEngine.rhythmModel = self
	self.scoreEngine.rhythmModel = self
	self.audioEngine.rhythmModel = self
	self.logicEngine.rhythmModel = self
	self.graphicEngine.rhythmModel = self
	self.observable.rhythmModel = self

	self.inputManager.observable:add(self.logicEngine)
	self.inputManager.observable:add(self.observable)

	self.logicEngine.observable:add(self.audioEngine)
end

function RhythmModel:load()
	local scoreEngine = self.scoreEngine
	local logicEngine = self.logicEngine

	scoreEngine.judgements = self.judgements
	scoreEngine.hp = self.hp
	scoreEngine.settings = self.settings

	logicEngine.timings = self.timings
end

function RhythmModel:loadAllEngines()
	self:loadLogicEngines()
	self.audioEngine:load()
	self.graphicEngine:load()
	self.pauseManager:load()
end

function RhythmModel:loadLogicEngines()
	self.timeEngine:load()
	self.scoreEngine:load()
	self.logicEngine:load()
end

function RhythmModel:unloadAllEngines()
	self.audioEngine:unload()
	self.logicEngine:unload()
	self.graphicEngine:unload()

	for _, inputType, inputIndex in self.noteChart:getInputIterator() do
		self.observable:send({
			name = "keyreleased",
			virtual = true,
			inputType .. inputIndex
		})
	end
end

function RhythmModel:unloadLogicEngines()
	self.scoreEngine:unload()
	self.logicEngine:unload()
end

---@param event table
function RhythmModel:receive(event)
	if event.name == "framestarted" then
		self.timeEngine:sync(event.time)
		return
	end

	self.inputManager:receive(event)
end

function RhythmModel:update()
	if self.timeEngine.timer.isPlaying then
		self.logicEngine:update()
	end
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update()
	self.pauseManager:update()
end

---@return boolean
function RhythmModel:hasResult()
	local timeEngine = self.timeEngine
	local base = self.scoreEngine.scoreSystem.base
	local entry = self.scoreEngine.scoreSystem.entry

	return
		not self.logicEngine.autoplay and
		not self.logicEngine.promode and
		not self.timeEngine.windUp and
		timeEngine.currentTime >= timeEngine.minTime and
		base.hitCount > 0 and
		entry.accuracy > 0 and
		entry.accuracy < math.huge
end

---@param windUp table?
function RhythmModel:setWindUp(windUp)
	self.timeEngine.windUp = windUp
end

---@param timeRate number
function RhythmModel:setTimeRate(timeRate)
	self.timeEngine:setBaseTimeRate(timeRate)
end

---@param autoplay boolean
function RhythmModel:setAutoplay(autoplay)
	self.logicEngine.autoplay = autoplay
end

---@param promode boolean
function RhythmModel:setPromode(promode)
	self.logicEngine.promode = promode
end

---@param adjustRate number
function RhythmModel:setAdjustRate(adjustRate)
	self.timeEngine.adjustRate = adjustRate
end

---@param noteChart ncdk.NoteChart
function RhythmModel:setNoteChart(noteChart)
	assert(noteChart)
	self.noteChart = noteChart
	self.timeEngine.noteChart = noteChart
	self.scoreEngine.noteChart = noteChart
	self.logicEngine.noteChart = noteChart
	self.graphicEngine.noteChart = noteChart
end

---@param range table
function RhythmModel:setDrawRange(range)
	self.graphicEngine.range = range
end

---@param volume table
function RhythmModel:setVolume(volume)
	self.audioEngine.volume = volume
	self.audioEngine:updateVolume()
end

---@param mode table
function RhythmModel:setAudioMode(mode)
	self.audioEngine.mode = mode
end

---@param visualTimeRate number
function RhythmModel:setVisualTimeRate(visualTimeRate)
	self.graphicEngine.visualTimeRate = visualTimeRate
	self.graphicEngine.targetVisualTimeRate = visualTimeRate
end

---@param longNoteShortening number
function RhythmModel:setLongNoteShortening(longNoteShortening)
	self.graphicEngine.longNoteShortening = longNoteShortening
end

---@param timeToPrepare number
function RhythmModel:setTimeToPrepare(timeToPrepare)
	self.timeEngine.timeToPrepare = timeToPrepare
end

---@param offset number
function RhythmModel:setInputOffset(offset)
	self.logicEngine.inputOffset = math.floor(offset * 1024) / 1024
end

---@param offset number
function RhythmModel:setVisualOffset(offset)
	self.graphicEngine.visualOffset = offset
end

---@param ... any?
function RhythmModel:setPauseTimes(...)
	self.pauseManager:setPauseTimes(...)
end

---@param scaleSpeed boolean
function RhythmModel:setVisualTimeRateScale(scaleSpeed)
	self.graphicEngine.scaleSpeed = scaleSpeed
end

return RhythmModel

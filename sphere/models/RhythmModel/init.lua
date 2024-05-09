local class = require("class")
local Observable = require("Observable")
local ScoreEngine = require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine = require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine = require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine = require("sphere.models.RhythmModel.TimeEngine")
local InputManager = require("sphere.models.RhythmModel.InputManager")
-- require("sphere.models.RhythmModel.LogicEngine.Test")

---@class sphere.RhythmModel
---@operator call: sphere.RhythmModel
local RhythmModel = class()

---@param inputModel sphere.InputModel
---@param resourceModel sphere.ResourceModel
function RhythmModel:new(inputModel, resourceModel)
	self.inputModel = inputModel
	self.resourceModel = resourceModel

	self.timeEngine = TimeEngine()
	self.inputManager = InputManager(self.timeEngine, inputModel)
	self.scoreEngine = ScoreEngine(self.timeEngine)
	self.audioEngine = AudioEngine(self.timeEngine, resourceModel)
	self.logicEngine = LogicEngine(self.timeEngine, self.scoreEngine)
	self.graphicEngine = GraphicEngine(self.timeEngine.visualTimeInfo, self.logicEngine)
	self.observable = Observable()

	self.timeEngine.audioEngine = self.audioEngine
	self.timeEngine.logicEngine = self.logicEngine

	self.inputManager.observable:add(self.logicEngine)
	self.inputManager.observable:add(self.observable)

	self.logicEngine.observable:add(self.audioEngine)
end

function RhythmModel:load()
	local scoreEngine = self.scoreEngine

	scoreEngine.judgements = self.judgements
	scoreEngine.hp = self.hp
	scoreEngine.settings = self.settings
end

function RhythmModel:loadAllEngines()
	self:loadLogicEngines()
	self.audioEngine:load()
	self.graphicEngine:load()
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

	for _, column in self.chart:getNotesIterator() do
		-- self.observable:send({
		-- 	name = "keyreleased",
		-- 	virtual = true,
		-- 	inputType .. inputIndex
		-- })
	end
end

function RhythmModel:unloadLogicEngines()
	self.scoreEngine:unload()
	self.logicEngine:unload()
end

function RhythmModel:play()
	self.timeEngine:play()
	self.audioEngine:play()
	self.inputManager:loadState()
end

function RhythmModel:pause()
	self.timeEngine:pause()
	self.audioEngine:pause()
	self.inputManager:saveState()
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
end

---@return boolean
function RhythmModel:hasResult()
	local timeEngine = self.timeEngine
	local base = self.scoreEngine.scoreSystem.base
	local accuracy = self.scoreEngine.scoreSystem.normalscore.accuracyAdjusted

	return
		not self.logicEngine.autoplay and
		not self.logicEngine.promode and
		not self.timeEngine.windUp and
		timeEngine.currentTime >= timeEngine.minTime and
		base.hitCount > 0 and
		accuracy > 0 and
		accuracy < math.huge
end

---@param timings table?
function RhythmModel:setTimings(timings)
	self.logicEngine.timings = timings
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

---@param singleHandler boolean
function RhythmModel:setSingleHandler(singleHandler)
	self.logicEngine.singleHandler = singleHandler
end

---@param constant boolean
function RhythmModel:setConstantSpeed(constant)
	self.graphicEngine.constant = constant
end

---@param adjustRate number
function RhythmModel:setAdjustRate(adjustRate)
	self.timeEngine.adjustRate = adjustRate
end

---@param chart ncdk2.Chart
function RhythmModel:setNoteChart(chart)
	assert(chart)
	self.chart = chart
	self.timeEngine.noteChart = chart
	self.scoreEngine.noteChart = chart
	self.logicEngine:setChart(chart)
	self.graphicEngine:setChart(chart)
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

---@param scaleSpeed boolean
function RhythmModel:setVisualTimeRateScale(scaleSpeed)
	self.graphicEngine.scaleSpeed = scaleSpeed
end

return RhythmModel

local class = require("class")
local Observable = require("Observable")
local ScoreSystemContainer = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

---@class sphere.ScoreEngine
---@operator call: sphere.ScoreEngine
local ScoreEngine = class()

function ScoreEngine:new()
	self.observable = Observable()
	self.scoreSystem = ScoreSystemContainer()
end

function ScoreEngine:load()
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self
	scoreSystem:load()

	self.inputMode = tostring(self.noteChart.inputMode)
	self.baseTimeRate = self.rhythmModel.timeEngine.baseTimeRate

	self.enps = self.baseEnps * self.baseTimeRate

	self.ratingDifficulty = self.enps * (1 + (self.longNoteRatio * (1 + self.longNoteArea)) * 0.25)

	self.pausesCount = 0
	self.paused = false

	self.minTime = self.noteChart.metaData.minTime
	self.maxTime = self.noteChart.metaData.maxTime
end

function ScoreEngine:update()
	local timeEngine = self.rhythmModel.timeEngine
	local timer = timeEngine.timer
	local currentTime = timeEngine.currentTime

	if currentTime < self.minTime or currentTime > self.maxTime then
		return
	end
	if not timer.isPlaying and not self.paused then
		self.paused = true
		self.pausesCount = self.pausesCount + 1
	elseif timer.isPlaying and self.paused then
		self.paused = false
	end
end

return ScoreEngine

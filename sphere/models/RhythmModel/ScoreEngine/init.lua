local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local ScoreSystemContainer	= require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

local ScoreEngine = Class:new()

ScoreEngine.construct = function(self)
	self.observable = Observable:new()
	self.scoreSystem = ScoreSystemContainer:new()
end

ScoreEngine.load = function(self)
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self
	scoreSystem:load()

	self.inputMode = self.noteChart.inputMode:getString()
	self.baseTimeRate = self.rhythmModel.timeEngine:getBaseTimeRate()

	self.sharedScoreNotes = {}
	self.enps = self.baseEnps * self.baseTimeRate

	self.bpm = self.noteChartDataEntry.bpm * self.baseTimeRate
	self.length = self.noteChartDataEntry.length / self.baseTimeRate

	self.pausesCount = 0
	self.paused = false

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")
end

ScoreEngine.update = function(self)
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

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
	self.currentTime = 0
	self.timeRate = self.baseTimeRate
	self.enps = self.baseEnps * self.baseTimeRate

	self.bpm = self.noteChartDataEntry.bpm * self.baseTimeRate
	self.length = self.noteChartDataEntry.length / self.baseTimeRate

	self.pausesCount = 0
	self.paused = false

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")
end

ScoreEngine.update = function(self)
	self.currentTime = self.rhythmModel.timeEngine.currentTime
	self.timeRate = self.rhythmModel.timeEngine.timeRate

	if self.currentTime < self.minTime or self.currentTime > self.maxTime then
		return
	end
	if self.timeRate == 0 and not self.paused then
		self.paused = true
		self.pausesCount = self.pausesCount + 1
	elseif self.timeRate ~= 0 and self.paused then
		self.paused = false
	end
end

ScoreEngine.unload = function(self) end

ScoreEngine.receive = function(self, event) end

ScoreEngine.send = function(self, event)
	-- return self.observable:send(event)
end

return ScoreEngine

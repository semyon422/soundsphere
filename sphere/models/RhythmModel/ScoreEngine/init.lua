local class = require("class")
local ScoreSystemContainer = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

---@class sphere.ScoreEngine
---@operator call: sphere.ScoreEngine
local ScoreEngine = class()

function ScoreEngine:new()
	self.scoreSystem = ScoreSystemContainer()
end

function ScoreEngine:load()
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self
	scoreSystem:load()

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

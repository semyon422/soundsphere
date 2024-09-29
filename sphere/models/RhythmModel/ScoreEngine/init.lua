local class = require("class")
local ScoreSystemContainer = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

---@class sphere.ScoreEngine
---@operator call: sphere.ScoreEngine
---@field judgement string
---@field ratingHitWindow number
---@field selectedScoring sphere.ScoreSystem
---@field accuracySource sphere.ScoreSystem
---@field scoreSource sphere.ScoreSystem
---@field loaded boolean
local ScoreEngine = class()

---@param timeEngine sphere.TimeEngine
function ScoreEngine:new(timeEngine)
	self.scoreSystem = ScoreSystemContainer()
	self.timeEngine = timeEngine
end

function ScoreEngine:load()
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self
	scoreSystem:load()

	self.pausesCount = 0
	self.paused = false

	self.minTime = self.noteChart.chartmeta.start_time
	self.maxTime = self.minTime + self.noteChart.chartmeta.duration

	local judge = scoreSystem.judgements[self.judgement]

	if not judge then
		return -- loading result screen
	end

	local scoring = scoreSystem[judge.scoreSystemName]
	local metadata = scoring.metadata

	local normalscore = scoreSystem["normalscore"]
	self.selectedScoring = scoring
	self.accuracySource = metadata.hasAccuracy and scoring or normalscore
	self.scoreSource = metadata.hasScore and scoring or normalscore
	self.loaded = true
end

function ScoreEngine:update()
	local timeEngine = self.timeEngine
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

function ScoreEngine:getAccuracy()
	return self.accuracySource:getAccuracy(self.judgement)
end

function ScoreEngine:getScore()
	return self.scoreSource:getScore(self.judgement)
end

function ScoreEngine:getJudge()
	return self.selectedScoring.judges[self.judgement]
end

return ScoreEngine

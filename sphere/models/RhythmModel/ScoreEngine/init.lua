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

	local judge = scoreSystem.judgements[self.judgement] or scoreSystem.judgements.soundsphere

	local scoring = scoreSystem[judge.scoreSystemName]
	local metadata = scoring.metadata

	local normalscore = scoreSystem["normalscore"]
	self.selectedScoring = scoring
	self.accuracySource = metadata.hasAccuracy and scoring or normalscore
	self.scoreSource = metadata.hasScore and scoring or normalscore
	self.loaded = true
end

---@param start_time number
---@param duration number
function ScoreEngine:setPlayTime(start_time, duration)
	self.minTime = start_time
	self.maxTime = start_time + duration
end

---@return number
function ScoreEngine:getAccuracy()
	return self.accuracySource:getAccuracy(self.judgement)
end

---@return number
function ScoreEngine:getScore()
	return self.scoreSource:getScore(self.judgement)
end

---@return sphere.Judge
function ScoreEngine:getJudge()
	return self.selectedScoring.judges[self.judgement] or self.selectedScoring.judges.soundsphere
end

return ScoreEngine

local normalscore = require("libchart.normalscore")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local NormalscoreScoreSystem = ScoreSystem:new()

NormalscoreScoreSystem.name = "normalscore"

NormalscoreScoreSystem.construct = function(self)
	self.normalscore = normalscore:new()
	self.hitTimingWindow = 0.12
end

NormalscoreScoreSystem.after = function(self, event)
	if math.abs(event.timeRate) == 0 then
		return
	end

	local ns = self.normalscore
	self.score = ns.score / math.abs(event.timeRate)
	self.scoreAdjusted = ns.score_adjusted / math.abs(event.timeRate)
	self.accuracy = ns.score
	self.accuracyAdjusted = ns.score_adjusted

	self.enps = self.scoreEngine.baseEnps * event.timeRate
	self.averageStrain = self.scoreEngine.baseAverageStrain * event.timeRate

	self.performance = self.enps / self.accuracyAdjusted
	self.adjustRatio = ns.score_adjusted / ns.score
end

NormalscoreScoreSystem.hit = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)

	self.normalscore:hit(deltaTime, self.hitTimingWindow)
end

NormalscoreScoreSystem.miss = function(self, event)
	self.normalscore:hit(self.hitTimingWindow + 1, self.hitTimingWindow)
end

NormalscoreScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = NormalscoreScoreSystem.hit,
			missed = NormalscoreScoreSystem.miss,
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = NormalscoreScoreSystem.hit,
			startMissed = NormalscoreScoreSystem.miss,
			startMissedPressed = NormalscoreScoreSystem.miss,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = nil,
			endPassed = nil,
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = nil,
		},
	},
}

return NormalscoreScoreSystem

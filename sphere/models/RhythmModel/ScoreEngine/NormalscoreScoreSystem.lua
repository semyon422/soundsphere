local normalscore = require("libchart.normalscore2_2")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local NormalscoreScoreSystem = ScoreSystem:new()

NormalscoreScoreSystem.name = "normalscore"

NormalscoreScoreSystem.load = function(self)
	self.normalscore = normalscore:new()
end

NormalscoreScoreSystem.after = function(self, event)
	if math.abs(event.timeRate) == 0 then
		return
	end

	local ns = self.normalscore

	ns:update()
	self.accuracy = ns.score
	self.accuracyAdjusted = ns.score_adjusted
	self.adjustRatio = ns.score_adjusted / ns.score

	self.enps = self.scoreEngine.baseEnps * event.timeRate
end

NormalscoreScoreSystem.hit = function(self, range_name, deltaTime)
	self.normalscore:hit(range_name, deltaTime)
end

NormalscoreScoreSystem.miss = function(self, range_name)
	self.normalscore:miss(range_name)
end

NormalscoreScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = function(self, event) self:hit("ShortNote", event.deltaTime) end,
			missed = function(self) self:miss("ShortNote") end,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = function(self, event) self:hit("LongNoteStart", event.deltaTime) end,
			startMissed = function(self) self:miss("LongNoteStart") end,
			startMissedPressed = function(self) self:miss("LongNoteStart") end,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = function(self) self:miss("LongNoteEnd") end,
			endPassed = function(self, event) self:hit("LongNoteEnd", event.deltaTime) end,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) self:hit("LongNoteEnd", event.deltaTime) end,
			startMissed = nil,
			endMissed = function(self) self:miss("LongNoteEnd") end,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = function(self) self:miss("LongNoteEnd") end,
		},
	},
}

return NormalscoreScoreSystem

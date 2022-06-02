local normalscore = require("libchart.normalscore2")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local NormalscoreScoreSystem = ScoreSystem:new()

NormalscoreScoreSystem.name = "normalscore"

NormalscoreScoreSystem.load = function(self)
	local timings = self.scoreEngine.timings
	self.ranges = {
		ShortNote = {timings.ShortNote.hit[1], timings.ShortNote.hit[2]},
		LongNoteStart = {timings.LongNote.startHit[1], timings.LongNote.startHit[2]},
		LongNoteEnd = {timings.LongNote.endHit[1], timings.LongNote.endHit[2]},
	}
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

NormalscoreScoreSystem.hit = function(self, event, timeKey)
	self.normalscore:press(event.deltaTime, assert(self.ranges[timeKey]))
end

NormalscoreScoreSystem.miss = function(self, timeKey)
	self.normalscore:press(math.huge, assert(self.ranges[timeKey]))
end

NormalscoreScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = function(self, event) self:hit(event, "ShortNote") end,
			missed = function(self) self:miss("ShortNote") end,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = function(self, event) self:hit(event, "LongNoteStart") end,
			startMissed = function(self) self:miss("LongNoteStart") end,
			startMissedPressed = function(self) self:miss("LongNoteStart") end,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = function(self) self:miss("LongNoteEnd") end,
			endPassed = function(self, event) self:hit(event, "LongNoteEnd") end,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) self:hit(event, "LongNoteEnd") end,
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

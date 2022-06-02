local normalscore = require("libchart.normalscore2")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local NormalscoreScoreSystem = ScoreSystem:new()

NormalscoreScoreSystem.name = "normalscore"

local rangeNames = {
	noteTime = 1,
	noteStartTime = 2,
	noteEndTime = 3,
}

NormalscoreScoreSystem.load = function(self)
	local timings = self.scoreEngine.timings
	local ranges = {
		{timings.ShortNote.hit[1], timings.ShortNote.hit[2]},
		{timings.LongNote.startHit[1], timings.LongNote.startHit[2]},
		{timings.LongNote.endHit[1], timings.LongNote.endHit[2]},
	}
	self.normalscore = normalscore:new(ranges)
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
	self.normalscore:press(event.deltaTime, assert(rangeNames[timeKey]))
end

NormalscoreScoreSystem.miss = function(self, timeKey)
	self.normalscore:press(math.huge, assert(rangeNames[timeKey]))
end

NormalscoreScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = function(self, event) self:hit(event, "noteTime") end,
			missed = function(self) self:miss("noteTime") end,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = function(self, event) self:hit(event, "noteStartTime") end,
			startMissed = function(self) self:miss("noteStartTime") end,
			startMissedPressed = function(self) self:miss("noteStartTime") end,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = function(self) self:miss("noteEndTime") end,
			endPassed = function(self, event) self:hit(event, "noteEndTime") end,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) self:hit(event, "noteEndTime") end,
			startMissed = nil,
			endMissed = function(self) self:miss("noteEndTime") end,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = function(self) self:miss("noteEndTime") end,
		},
	},
}

return NormalscoreScoreSystem

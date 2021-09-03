local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local BaseScoreSystem = ScoreSystem:new()

BaseScoreSystem.name = "base"

BaseScoreSystem.timingWindows = {
	ShortScoreNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.16}
	},
	LongScoreNote = {
		startHit = {-0.12, 0.12},
		startMiss = {-0.16, 0.16},
		endHit = {-0.12, 0.12},
		endMiss = {-0.16, 0.16}
	}
}

BaseScoreSystem.construct = function(self)
	self.hitCount = 0
	self.missCount = 0

	self.noteCount = 0
	self.combo = 0
	self.maxCombo = 0
	self.currentTime = 0

	self.counters = {}
end

BaseScoreSystem.before = function(self, event)
	self.currentTime = event.currentTime

	if self.noteCount ~= 0 then
		return
	end

	local noteCount = 0
	noteCount = noteCount + (event.scoreNotesCount["ShortScoreNote"] or 0)
	noteCount = noteCount + (event.scoreNotesCount["LongScoreNote"] or 0)

	self.noteCount = noteCount
end

BaseScoreSystem.success = function(self)
	self.hitCount = self.hitCount + 1
	self.combo = self.combo + 1
	self.maxCombo = math.max(self.maxCombo, self.combo)
end

BaseScoreSystem.breakCombo = function(self)
	self.combo = 0
end

BaseScoreSystem.miss = function(self)
	self.missCount = self.missCount + 1
end

BaseScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = BaseScoreSystem.success,
			missed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = nil,
			startMissed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
			startMissedPressed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
		},
		startPassedPressed = {
			startMissed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
			endMissed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
			endPassed = BaseScoreSystem.success,
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = BaseScoreSystem.breakCombo,
			endMissed = BaseScoreSystem.breakCombo,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = BaseScoreSystem.breakCombo,
		},
	},
}

return BaseScoreSystem

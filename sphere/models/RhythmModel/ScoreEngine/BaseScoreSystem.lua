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

	self.isMiss = false
	self.isLongNoteComboBreak = false

	self.counters = {}
end

BaseScoreSystem.before = function(self, event)
	self.currentTime = event.currentTime
	self.isMiss = false
	self.isLongNoteComboBreak = false

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

BaseScoreSystem.breakComboLongNote = function(self)
	self.combo = 0
	self.isLongNoteComboBreak = true
end

BaseScoreSystem.miss = function(self)
	self.missCount = self.missCount + 1
	self.isMiss = true
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
			startMissed = {BaseScoreSystem.breakComboLongNote, BaseScoreSystem.miss},
			startMissedPressed = {BaseScoreSystem.breakComboLongNote, BaseScoreSystem.miss},
		},
		startPassedPressed = {
			startMissed = {BaseScoreSystem.breakComboLongNote, BaseScoreSystem.miss},
			endMissed = {BaseScoreSystem.breakComboLongNote, BaseScoreSystem.miss},
			endPassed = BaseScoreSystem.success,
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = BaseScoreSystem.breakComboLongNote,
			endMissed = BaseScoreSystem.breakComboLongNote,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = BaseScoreSystem.breakComboLongNote,
		},
	},
}

return BaseScoreSystem

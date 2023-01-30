local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local RingBuffer = require("RingBuffer")
local map = require("math_util").map

local BaseScoreSystem = ScoreSystem:new()

BaseScoreSystem.name = "base"

BaseScoreSystem.construct = function(self)
	self.hitCount = 0
	self.missCount = 0
	self.earlyHitCount = 0

	self.noteCount = 0
	self.combo = 0
	self.maxCombo = 0
	self.currentTime = 0
	self.timeRate = 0

	self.isMiss = false
	self.isLongNoteComboBreak = false

	self.counters = {}

	self.lastMean = 0
end

BaseScoreSystem.before = function(self, event)
	local gameplay = self.scoreEngine.settings.gameplay
	self.meanRingBuffer = self.meanRingBuffer or RingBuffer:new({size = gameplay.lastMeanValues})

	self.currentTime = event.currentTime
	self.isMiss = false
	self.isLongNoteComboBreak = false

	self.timeRate =  math.abs(event.timeRate)

	if self.noteCount ~= 0 then
		return
	end

	local noteCount = 0
	noteCount = noteCount + (event.notesCount["ShortLogicalNote"] or 0)
	noteCount = noteCount + (event.notesCount["LongLogicalNote"] or 0)

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

BaseScoreSystem.earlyHit = function(self)
	self.earlyHitCount = self.earlyHitCount + 1
end

BaseScoreSystem.countLastMean = function(self, event)
	local rb = self.meanRingBuffer
	rb:write(event.deltaTime)
	local sum = 0
	for i = 1, rb.size do
		sum = sum + rb:read()
	end
	self.lastMean = sum / rb.size
end

BaseScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = {"success", "countLastMean"},
			missed = {"breakCombo", "miss"},
			clear = "earlyHit",
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "countLastMean",
			startMissed = "breakComboLongNote",
			startMissedPressed = "breakComboLongNote",
			clear = "earlyHit",
		},
		startPassedPressed = {
			startMissed = "breakComboLongNote",
			endMissed = {"breakComboLongNote", "miss"},
			endPassed = {"success", "countLastMean"},
		},
		startMissedPressed = {
			endMissedPassed = {"success", "countLastMean"},
			startMissed = "breakComboLongNote",
			endMissed = {"breakComboLongNote", "miss"},
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = {"breakComboLongNote", "miss"},
		},
	},
}

return BaseScoreSystem

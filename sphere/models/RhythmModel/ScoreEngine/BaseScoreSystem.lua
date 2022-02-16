local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local RingBuffer = require("aqua.util.RingBuffer")
local map = require("aqua.math").map

local BaseScoreSystem = ScoreSystem:new()

BaseScoreSystem.name = "base"

BaseScoreSystem.construct = function(self)
	self.hitCount = 0
	self.missCount = 0

	self.noteCount = 0
	self.combo = 0
	self.maxCombo = 0
	self.currentTime = 0
	self.timeRate = 0
	self.progress = 0

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

	if self.currentTime < math.huge then
		self.progress = map(self.currentTime, self.scoreEngine.minTime, self.scoreEngine.maxTime, 0, 1)
	end

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

BaseScoreSystem.countLastMean = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)

	local rb = self.meanRingBuffer
	rb:write(deltaTime)
	local sum = 0
	for i = 1, rb.size do
		sum = sum + rb:read()
	end
	self.lastMean = sum / rb.size
end

BaseScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = {BaseScoreSystem.success, BaseScoreSystem.countLastMean},
			missed = {BaseScoreSystem.breakCombo, BaseScoreSystem.miss},
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = BaseScoreSystem.countLastMean,
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

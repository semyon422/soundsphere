local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local RingBuffer = require("RingBuffer")

---@class sphere.BaseScoreSystem: sphere.ScoreSystem
---@operator call: sphere.BaseScoreSystem
local BaseScoreSystem = ScoreSystem + {}

BaseScoreSystem.name = "base"

function BaseScoreSystem:new()
	self.hitCount = 0
	self.missCount = 0
	self.earlyHitCount = 0

	self.notesCount = 0
	self.combo = 0
	self.maxCombo = 0
	self.currentTime = 0

	self.isMiss = false
	self.isLongNoteComboBreak = false

	self.counters = {}

	self.lastMean = 0
end

---@param event table
function BaseScoreSystem:before(event)
	local gameplay = self.scoreEngine.settings.gameplay
	self.meanRingBuffer = self.meanRingBuffer or RingBuffer(gameplay.lastMeanValues)

	self.currentTime = event.currentTime
	self.isMiss = false
	self.isLongNoteComboBreak = false

	self.notesCount = event.notesCount
end

---@param event table
function BaseScoreSystem:success(event)
	self.hitCount = self.hitCount + 1
	self.combo = self.combo + 1
	self.maxCombo = math.max(self.maxCombo, self.combo)
end

---@param event table
function BaseScoreSystem:breakCombo(event)
	self.combo = 0
end

---@param event table
function BaseScoreSystem:breakComboLongNote(event)
	self.combo = 0
	self.isLongNoteComboBreak = true
end

---@param event table
function BaseScoreSystem:miss(event)
	self.missCount = self.missCount + 1
	self.isMiss = true
end

---@param event table
function BaseScoreSystem:earlyHit(event)
	self.earlyHitCount = self.earlyHitCount + 1
end

---@param event table
function BaseScoreSystem:countLastMean(event)
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

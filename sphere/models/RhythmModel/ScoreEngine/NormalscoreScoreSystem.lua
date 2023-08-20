local normalscore = require("libchart.normalscore3")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.NormalscoreScoreSystem: sphere.ScoreSystem
---@operator call: sphere.NormalscoreScoreSystem
local NormalscoreScoreSystem = ScoreSystem + {}

NormalscoreScoreSystem.name = "normalscore"

function NormalscoreScoreSystem:load()
	self.normalscore = normalscore:new()
end

---@param event table
function NormalscoreScoreSystem:after(event)
	local ns = self.normalscore

	ns:update()

	local score_not_adjusted = math.sqrt(ns.score ^ 2 + ns.mean ^ 2)

	self.accuracy = score_not_adjusted
	self.accuracyAdjusted = ns.score
	self.adjustRatio = ns.score / score_not_adjusted

	self.enps = self.scoreEngine.baseEnps * event.timeRate
end

---@param range_name string
---@param deltaTime number
function NormalscoreScoreSystem:hit(range_name, deltaTime)
	self.normalscore:hit(range_name, deltaTime)
end

---@param range_name string
function NormalscoreScoreSystem:miss(range_name)
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

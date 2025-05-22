local normalscore = require("libchart.normalscore3")
local erfunc = require("libchart.erfunc")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local IScoreSource = require("sphere.models.RhythmModel.ScoreEngine.IScoreSource")

---@class sphere.NormalscoreScore: sphere.ScoreSystem, sphere.IAccuracySource, sphere.IScoreSource
---@operator call: sphere.NormalscoreScore
local NormalscoreScore = ScoreSystem + IAccuracySource + IScoreSource

function NormalscoreScore:new()
	self.accuracyMultiplier = 1000
	self.scoreMultiplier = 10000
	self.normalscore = normalscore:new()
	self.accuracyAdjusted = 0
	self.adjustRatio = 1
end

---@return string
function NormalscoreScore:getKey()
	return "normalscore"
end

---@param event table
function NormalscoreScore:after(event)
	local ns = self.normalscore

	ns:update()

	local score_not_adjusted = math.sqrt(ns.score ^ 2 + ns.mean ^ 2)

	self.accuracy = score_not_adjusted
	self.accuracyAdjusted = ns.score
	self.adjustRatio = ns.score / score_not_adjusted
end

function NormalscoreScore:getAccuracy()
	return self.accuracyAdjusted
end

function NormalscoreScore:getAccuracyString()
	return ("%0.2fms"):format(self:getAccuracy() * self.accuracyMultiplier)
end

function NormalscoreScore:getScore()
	return erfunc.erf(0.032 / ((self.accuracyAdjusted or math.huge) * math.sqrt(2)))
end

function NormalscoreScore:getScoreString()
	return ("%d"):format(self:getScore() * self.scoreMultiplier)
end

---@param range_name string
---@param deltaTime number
function NormalscoreScore:hit(range_name, deltaTime)
	self.normalscore:hit(range_name, deltaTime)
end

---@param range_name string
function NormalscoreScore:miss(range_name)
	self.normalscore:miss(range_name)
end

NormalscoreScore.events = {
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

return NormalscoreScore

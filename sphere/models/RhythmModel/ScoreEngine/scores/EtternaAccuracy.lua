--- SOURCE: https://github.com/etternagame/etterna
--- SOURCE: https://github.com/etternagame/etterna/blob/master/Themes/_fallback/Scripts/10%20Scores.lua

local erfunc = require("libchart.erfunc")
local math_util = require("math_util")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local Timings = require("sea.chart.Timings")

---@class sphere.EtternaAccuracy: sphere.ScoreSystem, sphere.IAccuracySource
---@operator call: sphere.EtternaAccuracy
local EtternaAccuracy = ScoreSystem + IAccuracySource

local judgeDifficulty = {0, 0, 0, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20}

---@param j integer
function EtternaAccuracy:new(j)
	self.timings = Timings("etternaj", j)
	self.accuracyMultiplier = 100

	self.judge = j

	self.difficulty = judgeDifficulty[j]

	self.maxPoints = 2
	self.missWeight = -5.5
	self.jPow = 0.75
	self.maxBooWeight = 180.0 * self.difficulty
	self.ridic = 5 * self.difficulty

	self.points = 0
	self.miss_count = 0
	self.notes = 0
end

---@return string
function EtternaAccuracy:getKey()
	return "etterna_accuracy_j" .. self.judge
end

---@param x number
---@return number
local function pointsMultiplier(x)
	return math_util.sign(x) * erfunc.erf(math.abs(x))
end

---@param deltaTimeMs number
---@return number
function EtternaAccuracy:getPoints(deltaTimeMs)
	if deltaTimeMs <= self.ridic then
		return self.maxPoints
	end

	local zero = 65.0 * math.pow(self.difficulty, self.jPow)
	local dev = 22.7 * math.pow(self.difficulty, self.jPow)

	if deltaTimeMs <= zero then
		return self.maxPoints * pointsMultiplier((zero - deltaTimeMs) / dev)
	end

	if deltaTimeMs <= self.maxBooWeight then
		return (deltaTimeMs - zero) * self.missWeight / (self.maxBooWeight - zero)
	end

	return self.missWeight
end

---@param event table
function EtternaAccuracy:hit(event)
	self.points = self.points + self:getPoints(math.abs(event.deltaTime) * 1000)
	self.notes = self.notes + 1
end

function EtternaAccuracy:miss()
	self.points = self.points + self:getPoints(math.huge)
	self.notes = self.notes + 1
end

function EtternaAccuracy:getAccuracy()
	return math.max(self.points / (self.notes * self.maxPoints), 0)
end

function EtternaAccuracy:getAccuracyString()
	return ("%0.02f%%"):format(self:getAccuracy() * self.accuracyMultiplier)
end

function EtternaAccuracy:getSlice()
	return {accuracy = self:getAccuracy()}
end

EtternaAccuracy.events = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "miss",
			startMissedPressed = nil,
			clear = nil,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = nil,
			endPassed = nil,
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = nil,
		},
	},
}

return EtternaAccuracy

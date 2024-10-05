--- SOURCE: https://github.com/etternagame/etterna
--- SOURCE: https://github.com/etternagame/etterna/blob/master/Themes/_fallback/Scripts/10%20Scores.lua

local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local erfunc = require("libchart.erfunc")
local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.EtternaScoring: sphere.ScoreSystem
---@operator call: sphere.EtternaScoring
local EtternaScoring = ScoreSystem + {}

EtternaScoring.name = "etterna"
EtternaScoring.metadata = {
	name = "Etterna J%d",
	range = { 4, 9 },
	hasAccuracy = true,
	hasScore = false,
	accuracyFormat = "%0.02f%%",
	accuracyMultiplier = 100
}

local judgeTimingWindows = {
	{ 33.75, 67.5, 135, 202.5, 270 },
	{ 29.925, 59.85, 119.7, 179.55, 239.4 },
	{ 26.1, 52.2, 104.4, 156.6, 208.8 },
	{ 22.5, 45, 90, 135, 180 },
	{ 18.9, 37.8, 75.6, 113.4, 180 },
	{ 14.85, 29.7, 59.4, 89.1, 180 },
	{ 11.25, 22.5, 45, 67.5, 180 },
	{ 7.425, 14.85, 29.7, 44.55, 180 },
	{ 4.5, 9, 18, 27, 180 },
}

local judgeDifficulty = { 0, 0, 0, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20 }

---@class sphere.EtternaJudge: sphere.Judge
---@operator call: sphere.EtternaJudge
local Judge = BaseJudge + {}
Judge.orderedCounters = { "marvelous", "perfect", "great", "bad", "boo" }

---@param j number
function Judge:new(j)
	BaseJudge.new(self)
	self.scoreSystemName = EtternaScoring.name

	self.difficulty = judgeDifficulty[j]

	self.maxPoints = 2
	self.maxBooWeight = 180.0 * self.difficulty
	self.missWeight = -5.5
	self.jPow = 0.75
	self.ridic = 5 * self.difficulty

	self.points = 0

	local w = judgeTimingWindows[j]
	self.windows = {
		marvelous = w[1] * 0.001,
		perfect = w[2] * 0.001,
		great = w[3] * 0.001,
		bad = w[4] * 0.001,
		boo = w[5] * 0.001,
	}

	self.counters = {
		marvelous = 0,
		perfect = 0,
		great = 0,
		bad = 0,
		boo = 0,
		miss = 0,
	}

	self.earlyHitWindow = -0.18
	self.lateHitWindow = 0.18
	self.earlyMissWindow = -0.18
	self.lateMissWindow = 0.18
	self.windowReleaseMultiplier = 1
end

---@param x number
---@return number
local function pointsMultiplier(x)
	local sign = 1

	if x < 0 then
		sign = -1
	end

	x = math.abs(x)
	local y = erfunc.erf(x)

	return sign * y
end

---@param deltaTimeMs number
---@return number
function Judge:getPoints(deltaTimeMs)
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
function Judge:hit(event)
	local delta_time = event.deltaTime

	if delta_time < self.earlyHitWindow or delta_time > self.lateHitWindow then
		self:addCounter("miss", event.currentTime)
		return
	end

	delta_time = math.abs(delta_time)
	self.points = self.points + self:getPoints(delta_time * 1000)

	local counter_name = self:getCounter(delta_time, self.windows) or "miss"
	self:addCounter(counter_name, event.currentTime)
end

function Judge:calculateAccuracy()
	self.accuracy = math.max(((self.points - (self.counters.miss * 5.5)) / (self.notes * self.maxPoints)), 0)
end

function EtternaScoring:load()
	self.judges = {}

	local name = self.metadata.name
	local range = self.metadata.range

	for i = range[1], range[2], 1 do
		self.judges[name:format(i)] = Judge(i)
	end
end

function EtternaScoring:getAccuracy(judge)
	return self.judges[judge].accuracy
end

function EtternaScoring:miss(event)
	for _, judge in pairs(self.judges) do
		judge:addCounter("miss", event.currentTime)
		judge:calculateAccuracy()
	end
end

---@param event table
function EtternaScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge:hit(event)
		judge:calculateAccuracy()
	end
end

function EtternaScoring:getTimings()
	local judge = Judge(4)
	return judge:getTimings()
end

function EtternaScoring:getSlice()
	local slice = {}

	for i, v in ipairs(self.judges) do
		slice[v.judgeName] = { accuracy = v.accuracy }
	end

	return slice
end

EtternaScoring.notes = {
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

return EtternaScoring

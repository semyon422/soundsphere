-- SOURCE: https://osu.ppy.sh/wiki/en/Gameplay/Judgement/osu!mania

local math_util = require("math_util")

local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.OsuLegacyScoring: sphere.ScoreSystem
---@operator call: sphere.OsuLegacyScoring
local OsuLegacyScoring = ScoreSystem + {}

OsuLegacyScoring.name = "osuLegacy"
OsuLegacyScoring.metadata = {
	name = "osu!legacy OD%d",
	range = { 0, 10 },
}

---@class sphere.OsuLegacyJudge: sphere.Judge
---@operator call: sphere.OsuLegacyJudge
local Judge = BaseJudge + {}

Judge.orderedCounters = { "perfect", "great", "good", "ok", "meh" }

local totalNotes = 0

local counterIndex = {
	perfect = 1,
	great = 2,
	good = 3,
	ok = 4,
	meh = 5,
}

local hitBonus = {
	perfect = 2,
	great = 1,
	good = -8,
	ok = -24,
	meh = -44,
	miss = -100,
}

local hitValue = {
	perfect = 320,
	great = 300,
	good = 200,
	ok = 100,
	meh = 50,
	miss = 0,
}

local hitBonusValue = {
	perfect = 32,
	great = 32,
	good = 16,
	ok = 8,
	meh = 4,
	miss = 0,
}

---@param od number
function Judge:new(od)
	self.scoreSystemName = OsuLegacyScoring.name

	self.weights = {
		perfect = 300,
		great = 300,
		good = 200,
		ok = 100,
		meh = 50,
		miss = 0,
	}

	local od3 = 3 * od

	self.windows = {
		perfect = 16 / 1000,
		great = (64 - od3) / 1000,
		good = (97 - od3) / 1000,
		ok = (127 - od3) / 1000,
		meh = (151 - od3) / 1000,
		miss = (188 - od3) / 1000,
	}

	local w = self.windows

	self.headWindows = {
		perfect = w.perfect * 1.2,
		great = w.great * 1.1,
		good = w.good,
		ok = w.ok,
		meh = w.meh,
		miss = w.miss,
	}

	self.tailWindows = {
		perfect = w.perfect * 2.4,
		great = w.great * 2.2,
		good = w.good * 2,
		ok = w.ok * 2,
		meh = w.meh,
		miss = w.miss,
	}

	self.pressedLongNotes = {}

	self.counters = {
		perfect = 0,
		great = 0,
		good = 0,
		ok = 0,
		meh = 0,
		miss = 0,
	}

	self.earlyHitWindow = -self.windows.meh
	self.lateHitWindow = self.windows.ok
	self.earlyMissWindow = -self.windows.miss
	self.lateMissWindow = self.windows.ok

	self.windowReleaseMultiplier = 1

	self.baseScore = 0
	self.bonusScore = 0
	self.score = 0

	self.bonus = 100
	self.hitValue = 0
	self.totalBonus = 0
end

---@param key string
---@param currentTime number
function Judge:addCounter(key, currentTime)
	self.notes = self.notes + 1
	self.counters[key] = self.counters[key] + 1
	self.lastCounter = key
	self.lastUpdateTime = currentTime

	self.hitValue = self.hitValue + hitValue[key]
	self.bonus = math_util.clamp(self.bonus + hitBonus[key], 0, 100)

	self.totalBonus = self.totalBonus + (hitBonusValue[key] * math.sqrt(self.bonus) / 320)

	self.baseScore = (500000 / totalNotes) * (self.hitValue / 320)
	self.bonusScore = (500000 / totalNotes) * self.totalBonus

	self.score = self.baseScore + self.bonusScore
end

---@param self sphere.OsuLegacyJudge
---@return string?
local function getStartCounter(self, event)
	return self.pressedLongNotes[event.noteIndexType]
end

---@param self sphere.OsuLegacyJudge
local function setStartCounter(self, event, counter_name)
	self.pressedLongNotes[event.noteIndexType] = counter_name
end

---@param event table
function Judge:addMiss(event)
	self:addCounter("miss", event.currentTime)

	if event.noteType == "LongNote" then
		setStartCounter(self, event, nil)
	end
end

---@param event table
function Judge:shortNoteHit(event)
	local delta_time = event.deltaTime

	if delta_time < self.earlyHitWindow or delta_time > self.lateHitWindow then
		self:addMiss(event)
		return
	end

	local counter_name = self:getCounter(delta_time, self.windows) or "miss"
	self:addCounter(counter_name, event.currentTime)
end

---@param event table
function Judge:longNoteStartHit(event)
	local delta_time = event.deltaTime

	local early_hit_window = -self.headWindows.meh
	local late_hit_window = self.headWindows.ok

	if delta_time < early_hit_window or delta_time > late_hit_window then
		self:addMiss(event)
		return
	end

	local counter_name = self:getCounter(delta_time, self.headWindows)

	setStartCounter(self, event, counter_name)
end

---@param event table
function Judge:didntReleased(event)
	local counter = getStartCounter(self, event) or "meh"
	local counter_index = math.min(counterIndex[counter] + 2, 5)
	self:addCounter(self.orderedCounters[counter_index], event.currentTime)

	setStartCounter(self, event, nil)
end

function Judge:longNoteFail(event)
	setStartCounter(self, event, "meh")
end

function Judge:longNoteRelease(event)
	local delta_time = event.deltaTime

	local late_hit_window = self.lateHitWindow * self.windowReleaseMultiplier
	local early_hit_winwow = self.earlyHitWindow * self.windowReleaseMultiplier

	if delta_time < early_hit_winwow or delta_time > late_hit_window then
		self:addMiss(event)
		return
	end

	local tail = self:getCounter(delta_time, self.tailWindows) or "meh"
	local start = getStartCounter(self, event)

	if not start then
		self:addCounter("meh", event.currentTime)
		return
	end

	local tail_index = counterIndex[tail]
	local start_index = counterIndex[start]

	local counter_name = self.orderedCounters[math.max(start_index, tail_index)]
	self:addCounter(counter_name, event.currentTime)

	setStartCounter(self, event, nil)
end

---@param func_name string
---@param event table
function OsuLegacyScoring:forEachJudge(func_name, event)
	for _, judge in pairs(self.judges) do
		judge[func_name](judge, event)
		judge:calculateAccuracy()
	end
end

function OsuLegacyScoring:shortNoteHit(event)
	self:forEachJudge("shortNoteHit", event)
end

function OsuLegacyScoring:miss(event)
	self:forEachJudge("addMiss", event)
end

function OsuLegacyScoring:longNoteStartHit(event)
	self:forEachJudge("longNoteStartHit", event)
end

function OsuLegacyScoring:longNoteFail(event)
	self:forEachJudge("longNoteFail", event)
end

function OsuLegacyScoring:longNoteRelease(event)
	self:forEachJudge("longNoteRelease", event)
end

function OsuLegacyScoring:didntReleased(event)
	self:forEachJudge("didntReleased", event)
end

function OsuLegacyScoring:load()
	self.judges = {}

	local range = self.metadata.range
	local name = self.metadata.name

	for od = range[1], range[2], 1 do
		self.judges[name:format(od)] = Judge(od)
	end

	totalNotes = self.scoreEngine.noteChart.chartmeta.notes_count
end

function OsuLegacyScoring:getTimings(od)
	local judge = Judge(od)
	local timings = judge:getTimings()
	timings.nearest = false
	return timings
end

OsuLegacyScoring.notes = {
	ShortNote = {
		clear = {
			passed = "shortNoteHit",
			missed = "miss",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "longNoteStartHit",
			startMissed = "longNoteFail",
			startMissedPressed = "longNoteFail",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = "longNoteFail",
			endMissed = "didntReleased",
			endPassed = "longNoteRelease",
		},
		startMissedPressed = {
			endMissedPassed = "longNoteRelease",
			startMissed = "longNoteFail",
			endMissed = "didntReleased",
		},
		startMissed = {
			startMissedPressed = "longNoteFail",
			endMissed = "miss",
		},
	},
}

return OsuLegacyScoring

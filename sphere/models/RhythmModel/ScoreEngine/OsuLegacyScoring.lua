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

local counterIndex = {
	perfect = 1,
	great = 2,
	good = 3,
	ok = 4,
	meh = 5,
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

	self.headWindow = {
		perfect = w.perfect * 1.2,
		great = w.great * 1.1,
		good = w.good,
		ok = w.ok,
		meh = w.meh,
		miss = w.miss,
	}

	self.tailWindow = {
		perfect = w.perfect * 2.4,
		great = w.great * 2.2,
		good = w.good * 2,
		ok = w.ok * 2,
		meh = w.meh,
		miss = w.miss,
	}

	self.downLongNotes = {}

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

	self.windowReleaseMultiplier = 2.4
end

---@param self sphere.OsuLegacyJudge
---@param delta_time number
---@param windows table
local function getCounter(self, delta_time, windows)
	for _, key in ipairs(self.orderedCounters) do
		local window = windows[key]

		if delta_time < window then
			return key
		end
	end
end

---@param self sphere.OsuLegacyJudge
---@return string?
local function getStartCounter(self, event)
	local input = self.downLongNotes[event.inputIndex]

	if input then
		return input[event.noteIndex]
	end
end

---@param self sphere.OsuLegacyJudge
local function setStartCounter(self, event, counter_name)
	local input = self.downLongNotes[event.inputIndex] or {}
	input[event.noteIndex] = counter_name

	self.downLongNotes[event.inputIndex] = input
end

---@param event table
function Judge:processEvent(event)
	local is_release = event.newState == "endPassed" or event.newState == "endMissedPassed"
	local is_long_note = event.noteType == "LongNote"

	local delta_time = event.deltaTime

	local late_hit_window = is_release and self.lateHitWindow * self.windowReleaseMultiplier or self.lateHitWindow

	if delta_time < self.earlyHitWindow or delta_time > late_hit_window then
		self:addCounter("miss", event.currentTime)
		return
	end

	delta_time = math.abs(delta_time)

	local counter_name

	if is_release then
		local tail = getCounter(self, delta_time, self.tailWindow)
		local start = getStartCounter(self, event)

		if not start then
			self:addCounter("meh", event.currentTime)
			return
		end

		local tail_index = counterIndex[tail]
		local start_index = counterIndex[start]

		counter_name = self.orderedCounters[math.max(start_index, tail_index)]
		self:addCounter(counter_name, event.currentTime)
	elseif not is_release and is_long_note then
		counter_name = getCounter(self, delta_time, self.headWindow)
		setStartCounter(self, event, counter_name)
	else
		counter_name = getCounter(self, delta_time, self.windows)
		self:addCounter(counter_name, event.currentTime)
	end
end

---@param event table
function Judge:processMiss(event)
	if event.noteType == "ShortNote" then
		self:addCounter("miss", event.currentTime)
		return
	end

	local old = event.oldState
	local new = event.newState

	if old == "startMissed" and new == "endMissed" then
		self:addCounter("miss", event.currentTime)
		return
	end

	-- Mashing near the tail but not hitting it should give miss instead of nothing
	if old == "startMissedPressed" and new == "endMissed" then
		self:addCounter("miss", event.currentTime)
		return
	end

	if old == "startPassedPressed" and new == "endMissed" then
		local counter = getStartCounter(self, event) or "meh"
		local counter_index = math.min(counterIndex[counter] + 2, 5)
		self:addCounter(self.orderedCounters[counter_index], event.currentTime)
		return
	end

	if old == "startPassedPressed" and new == "startMissed" then
		setStartCounter(self, event, "meh")
		return
	end

	-- Pressed out of hit window. Still counts as hit
	if old == "clear" and new == "startMissedPressed" then
		setStartCounter(self, event, "meh")
		return
	end

	--- Pressing on body several times
	if old == "startMissed" and new == "startMissedPressed" then
		setStartCounter(self, event, "meh")
		return
	end
end

function OsuLegacyScoring:load()
	self.judges = {}

	local range = self.metadata.range
	local name = self.metadata.name

	for od = range[1], range[2], 1 do
		self.judges[name:format(od)] = Judge(od)
	end
end

---@param event table
function OsuLegacyScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge:processEvent(event)
		judge:calculateAccuracy()
	end
end

---@param event table
function OsuLegacyScoring:miss(event)
	for _, judge in pairs(self.judges) do
		judge:processMiss(event)
		judge:calculateAccuracy()
	end
end

OsuLegacyScoring.notes = {
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
			startMissedPressed = "miss",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = "miss", -- !!! 50
			endMissed = "miss", -- !!! - 50
			endPassed = "hit", -- !!! - any
		},
		startMissedPressed = {
			endMissedPassed = "hit", -- !!! 50
			startMissed = nil,
			endMissed = "miss",
		},
		startMissed = {
			startMissedPressed = "miss",
			endMissed = "miss",
		},
	},
}

return OsuLegacyScoring

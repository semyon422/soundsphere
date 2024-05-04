-- SOURCE: https://hitkey.nekokan.dyndns.info/diary1501.php#D150119

local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.LunaticRaveScoring: sphere.ScoreSystem
---@operator call: sphere.LunaticRaveScoring
local LunaticRaveScoring = ScoreSystem + {}

LunaticRaveScoring.name = "lr2"
LunaticRaveScoring.metadata = {
	name = "LR2 %s",
	range = { 0, 3 },
	rangeValueAlias = {
		[0] = "Easy",
		[1] = "Normal",
		[2] = "Hard",
		[3] = "Very hard",
	},
}

---@class sphere.LunaticRaveJudge: sphere.Judge
---@operator call: sphere.LunaticRaveJudge
local Judge = BaseJudge + {}

Judge.orderedCounters = { "pgreat", "great", "good", "bad" }

---@param windows table
function Judge:new(windows)
	self.scoreSystemName = LunaticRaveScoring.name

	self.weights = {
		pgreat = 2,
		great = 1,
		good = 0,
		bad = 0,
	}

	self.windows = windows

	self.counters = {
		pgreat = 0,
		great = 0,
		good = 0,
		bad = 0,
		miss = 0,
	}

	self.earlyHitWindow = -self.windows.bad
	self.lateHitWindow = self.windows.bad
	self.earlyMissWindow = -self.windows.bad
	self.lateMissWindow = self.windows.bad

	self.windowReleaseMultiplier = 1
end

local windows = {
	Easy = {
		pgreat = 0.021,
		great = 0.060,
		good = 0.120,
		bad = 0.200,
	},
	Normal = {
		pgreat = 0.018,
		great = 0.040,
		good = 0.100,
		bad = 0.200,
	},
	Hard = {
		pgreat = 0.015,
		great = 0.030,
		good = 0.060,
		bad = 0.200,
	},
	["Very hard"] = {
		pgreat = 0.008,
		great = 0.024,
		good = 0.040,
		bad = 0.200,
	},
}

---@param event table
function Judge:mash(event)
	self.counters["miss"] = self.counters["miss"] + 1
	self.lastCounter = "miss"
	self.lastUpdateTime = event.currentTime
end

function Judge:calculateAccuracy()
	-- AKA exscore
	self.accuracy = ((self.counters.pgreat * 2) + self.counters.great) / (2 * self.notes)
end

function LunaticRaveScoring:load()
	self.judges = {}

	local range = self.metadata.range
	local name = self.metadata.name

	for rank = range[1], range[2], 1 do
		local judge_name = self.metadata.rangeValueAlias[rank]
		self.judges[name:format(judge_name)] = Judge(windows[judge_name])
	end
end

---@param event table
function LunaticRaveScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge:processEvent(event)
		judge:calculateAccuracy()
	end
end

---@param event table
function LunaticRaveScoring:miss(event)
	for _, judge in pairs(self.judges) do
		judge:addCounter("miss", event.currentTime)
		judge:calculateAccuracy()
	end
end

---@param event table
function LunaticRaveScoring:mash(event)
	for _, judge in pairs(self.judges) do
		judge:mash(event)
		judge:calculateAccuracy()
	end
end

---@return table
function LunaticRaveScoring:getTimings()
	local timings = Judge(windows["Easy"]):getTimings()
	timings.nearest = false
	return timings
end

LunaticRaveScoring.notes = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = "mash",
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "miss",
			startMissedPressed = nil,
			clear = "mash",
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

return LunaticRaveScoring

-- SOURCE: https://osu.ppy.sh/wiki/en/Gameplay/Judgement/osu!mania

local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.OsuManiaScoring: sphere.ScoreSystem
---@operator call: sphere.OsuManiaScoring
local OsuManiaScoring = ScoreSystem + {}

OsuManiaScoring.name = "osuMania"
OsuManiaScoring.metadata = {
	name = "osu!mania OD%d",
	range = { 0, 10 },
}

---@class sphere.OsuJudge: sphere.Judge
---@operator call: sphere.OsuJudge
local Judge = BaseJudge + {}

Judge.orderedCounters = { "perfect", "great", "good", "ok", "meh" }

---@param od number
function Judge:new(od)
	self.scoreSystemName = OsuManiaScoring.name

	self.weights = {
		perfect = 305,
		great = 300,
		good = 200,
		ok = 100,
		meh = 50,
		miss = 0,
	}

	local od3 = 3 * od

	local perfect_window = od < 5 and 22.4 - 0.6 * od or 24.9 - 1.1 * od

	self.windows = {
		perfect = perfect_window / 1000,
		great = (64 - od3) / 1000,
		good = (97 - od3) / 1000,
		ok = (127 - od3) / 1000,
		meh = (151 - od3) / 1000,
		miss = (188 - od3) / 1000,
	}

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

	self.windowReleaseMultiplier = 1.5
end

function OsuManiaScoring:load()
	self.judges = {}

	local range = self.metadata.range
	local name = self.metadata.name

	for od = range[1], range[2], 1 do
		self.judges[name:format(od)] = Judge(od)
	end
end

---@param event table
function OsuManiaScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge:processEvent(event)
		judge:calculateAccuracy()
	end
end

---@param event table
function OsuManiaScoring:miss(event)
	for _, judge in pairs(self.judges) do
		judge:addCounter("miss", event.currentTime)
		judge:calculateAccuracy()
	end
end

---@param od number
---@return table
function OsuManiaScoring:getTimings(od)
	local judge = Judge(od)
	return judge:getTimings()
end

OsuManiaScoring.notes = {
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
			startMissed = "miss",
			endMissed = "miss",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = "hit",
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return OsuManiaScoring

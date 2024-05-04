-- SOURCE: https://github.com/Quaver/Quaver.API/blob/43e800efb079e9c099315c4b365490e357e2380c/Quaver.API/Maps/Processors/Scoring/ScoreProcessorKeys.cs

local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.QuaverScoring: sphere.ScoreSystem
---@operator call: sphere.QuaverScoring
local QuaverScoring = ScoreSystem + {}

QuaverScoring.name = "quaver"
QuaverScoring.metadata = {
	name = "Quaver standard",
}

local Judge = BaseJudge + {}

Judge.orderedCounters = { "marvelous", "perfect", "great", "good", "okay" }

---@param windows table
function Judge:new(windows)
	self.scoreSystemName = QuaverScoring.name

	self.windows = windows

	self.counters = {
		marvelous = 0,
		perfect = 0,
		great = 0,
		good = 0,
		okay = 0,
		miss = 0,
	}

	self.weights = {
		marvelous = 100,
		perfect = 98.25,
		great = 65,
		good = 25,
		okay = -100,
		miss = -50,
	}

	self.earlyHitWindow = -self.windows.okay
	self.lateHitWindow = self.windows.okay
	self.earlyMissWindow = -self.windows.miss
	self.lateMissWindow = self.windows.miss

	self.windowReleaseMultiplier = 1.5
end

function Judge:getTimings()
	local early_hit = self.earlyHitWindow
	local late_hit = self.lateHitWindow
	local early_miss = self.earlyMissWindow
	local late_miss = self.lateMissWindow

	return {
		nearest = false,
		ShortNote = {
			hit = { early_hit, late_hit },
			miss = { early_miss, late_miss },
		},
		LongNoteStart = {
			hit = { early_hit, late_hit },
			miss = { early_miss, late_miss },
		},
		LongNoteEnd = {
			hit = { early_hit, late_hit },
			miss = { early_miss, late_miss },
		},
	}
end

local stdWindows = {
	marvelous = 0.018,
	perfect = 0.043,
	great = 0.076,
	good = 0.106,
	okay = 0.127,
	miss = 0.164,
}

function QuaverScoring:load()
	self.judges = {
		[self.metadata.name] = Judge(stdWindows),
	}
end

---@param event table
function QuaverScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge:processEvent(event)
		judge:calculateAccuracy()
	end
end

function QuaverScoring:releaseFail(event)
	for _, judge in pairs(self.judges) do
		judge:addCounter("good", event.currentTime)
		judge:calculateAccuracy()
	end
end

function QuaverScoring:miss(event)
	for _, judge in pairs(self.judges) do
		judge:addCounter("miss", event.currentTime)
		judge:calculateAccuracy()
	end
end

function QuaverScoring:getTimings()
	local judge = Judge(stdWindows)
	return judge:getTimings()
end

QuaverScoring.notes = {
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
			endMissed = "releaseFail",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return QuaverScoring

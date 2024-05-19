local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.SoundsphereScoring: sphere.ScoreSystem
---@operator call: sphere.SoundsphereScoring
local SoundsphereScoring = ScoreSystem + {}

SoundsphereScoring.name = "soundsphere"
SoundsphereScoring.metadata = {
	name = "soundsphere",
}

---@class sphere.SoundsphereJudge: sphere.Judge
---@operator call: sphere.SoundsphereJudge
local Judge = BaseJudge + {}

Judge.orderedCounters = { "perfect", "not perfect" }

function Judge:new()
	self.scoreSystemName = SoundsphereScoring.name

	BaseJudge.accuracy = nil

	self.windows = {
		perfect = 0.016,
		["not perfect"] = math.huge,
	}

	self.counters = {
		perfect = 0,
		["not perfect"] = 0,
		miss = 0,
	}

	self.earlyLate = {
		early = 0,
		late = 0,
	}
end

function Judge:hit(event)
	local delta = event.deltaTime

	if delta < 0 then
		self.earlyLate.early = self.earlyLate.early + 1
	else
		self.earlyLate.late = self.earlyLate.late + 1
	end

	if math.abs(delta) < 0.016 then
		self:addCounter("perfect", event.currentTime)
		return
	end

	self:addCounter("not perfect", event.currentTime)
end

function SoundsphereScoring:load()
	self.judges = {
		[self.metadata.name] = Judge(),
	}
end

function SoundsphereScoring:hit(event)
	self.judges[self.metadata.name]:hit(event)
end

function SoundsphereScoring:miss(event)
	local judge = self.judges[self.metadata.name]
	judge:addCounter("miss", event.currentTime)
end

SoundsphereScoring.notes = {
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
			startMissed = nil,
			startMissedPressed = nil,
			clear = nil,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = "miss",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = "hit",
			startMissed = nil,
			endMissed = "miss",
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return SoundsphereScoring

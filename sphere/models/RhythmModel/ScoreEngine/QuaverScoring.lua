local class = require("class")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.QuaverScoring: sphere.ScoreSystem
---@operator call: sphere.QuaverScoring
local QuaverScoring = ScoreSystem + {}

QuaverScoring.name = "quaver"
QuaverScoring.metadata = {
	name = "Quaver standard"
}

local Judge = class()

local orderedCounters = {"marvelous", "perfect", "great", "good", "okay"}

function Judge:new(windows)
	self.windows = windows
	self.accuracy = 0
	self.notes = 0
	self.counters = {
		marvelous = 0,
		perfect = 0,
		great = 0,
		good = 0,
		okay = 0,
		miss = 0,
	}

	self.hitWindow = self.windows.okay
	self.missWindow = self.windows.miss

	self.windowReleaseMultiplier = 1.5

	self.weights = {
		marvelous = 100,
		perfect = 98.25,
		great = 65,
		good = 25,
		okay = -100,
		miss = -50
	}
end

function Judge:setCounter(event)
	local deltaTime = math.abs(event.deltaTime)

	if deltaTime > self.hitWindow then
		self.counters.miss = self.counters.miss + 1
		return
	end

	deltaTime = event.newState == "endPassed" and deltaTime / self.windowReleaseMultiplier or deltaTime

	for _, key in ipairs(orderedCounters) do
		local window  = self.windows[key]

		if deltaTime < window then
			self.counters[key] = self.counters[key] + 1
			return
		end
	end
end

function Judge:calculateAccuracy()
	local score = 0

	for key, value in pairs(self.counters) do
		score = score + (value * self.weights[key])
	end

	self.accuracy = math.max(score / (self.notes * self.weights.marvelous), 0)
end

function Judge:getTimings()
	local hit = self.hitWindow
	local miss = self.missWindow

	return {
		nearest = false,
		ShortNote = {
			hit = {-hit, hit},
			miss = {-miss, miss}
		},
		LongNoteStart = {
			hit = {-hit, hit},
			miss = {-miss, miss},
		},
		LongNoteEnd = {
			hit = {-hit, hit},
			miss = {-miss, miss}
		}
	}
end

function Judge:getOrderedCounterNames()
	return orderedCounters
end

local stdWindows = {
	marvelous = 0.018,
	perfect = 0.043,
	great = 0.076,
	good = 0.106,
	okay = 0.127,
	miss = 0.164
}

function QuaverScoring:load()
	self.judges = {
		[self.metadata.name] = Judge(stdWindows)
	}
end

function QuaverScoring:hit(event)
	for _, judge in pairs(self.judges) do
		judge.notes = judge.notes + 1
		judge:setCounter(event)
		judge:calculateAccuracy()
	end
end

function QuaverScoring:releaseFail()
	for _, judge in pairs(self.judges) do
		judge.notes = judge.notes + 1
		judge.counters.good = judge.counters.good + 1
		judge:calculateAccuracy()
	end
end

function QuaverScoring:miss()
	for _, judge in pairs(self.judges) do
		judge.notes = judge.notes + 1
		judge.counters.miss = judge.counters.miss + 1
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

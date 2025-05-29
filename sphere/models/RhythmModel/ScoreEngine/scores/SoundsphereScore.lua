local JudgeCounter = require("sphere.models.RhythmModel.ScoreEngine.JudgeCounter")
local JudgeWindows = require("sphere.models.RhythmModel.ScoreEngine.JudgeWindows")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local SimpleJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.SimpleJudgesSource")
local Timings = require("sea.chart.Timings")

---@class sphere.SoundsphereScore: sphere.ScoreSystem, sphere.SimpleJudgesSource
---@operator call: sphere.SoundsphereScore
local SoundsphereScore = ScoreSystem + SimpleJudgesSource

SoundsphereScore.judge_names = {"perfect", "good", "miss"}

local windows = {0.016, 0.120, 0.160}

function SoundsphereScore:new()
	self.timings = Timings("sphere")
	self.judge_windows = JudgeWindows(windows)
	self.judge_counter = JudgeCounter(3)
end

---@return string
function SoundsphereScore:getKey()
	return "soundsphere"
end

function SoundsphereScore:hit(event)
	local index = self.judge_windows:get(event.deltaTime) or -1
	self.judge_counter:add(index)
end

function SoundsphereScore:miss(event)
	self.judge_counter:add(-1)
end

SoundsphereScore.events = {
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

return SoundsphereScore

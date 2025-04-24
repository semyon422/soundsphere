--- SOURCE: https://github.com/etternagame/etterna
--- SOURCE: https://github.com/etternagame/etterna/blob/master/Themes/_fallback/Scripts/10%20Scores.lua

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local JudgeCounter = require("sphere.models.RhythmModel.ScoreEngine.JudgeCounter")
local JudgeWindows = require("sphere.models.RhythmModel.ScoreEngine.JudgeWindows")
local Timings = require("sea.chart.Timings")

local judgeTimingWindows = {
	{33.75, 67.5, 135, 202.5, 270},
	{29.925, 59.85, 119.7, 179.55, 239.4},
	{26.1, 52.2, 104.4, 156.6, 208.8},
	{22.5, 45, 90, 135, 180},
	{18.9, 37.8, 75.6, 113.4, 180},
	{14.85, 29.7, 59.4, 89.1, 180},
	{11.25, 22.5, 45, 67.5, 180},
	{7.425, 14.85, 29.7, 44.55, 180},
	{4.5, 9, 18, 27, 180},
}

---@class sphere.EtternaJudges: sphere.ScoreSystem
---@operator call: sphere.EtternaJudges
local EtternaJudges = ScoreSystem + {}

EtternaJudges.hasJudges = true

EtternaJudges.judge_names = {"marvelous", "perfect", "great", "bad", "boo", "miss"}

---@param j number
function EtternaJudges:new(j)
	self.timings = Timings("etternaj", j)

	self.judge = j

	local w = judgeTimingWindows[j]
	local windows = {
		w[1] * 0.001,
		w[2] * 0.001,
		w[3] * 0.001,
		w[4] * 0.001,
		w[5] * 0.001,
	}

	self.judge_windows = JudgeWindows(windows)
	self.judge_counter = JudgeCounter(6)
end

---@return string
function EtternaJudges:getKey()
	return "etterna_judges_j" .. self.judge
end

---@param event table
function EtternaJudges:hit(event)
	local index = self.judge_windows:get(event.deltaTime) or -1
	self.judge_counter:add(index)
end

function EtternaJudges:miss()
	self.judge_counter:add(-1)
end

EtternaJudges.events = {
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

return EtternaJudges

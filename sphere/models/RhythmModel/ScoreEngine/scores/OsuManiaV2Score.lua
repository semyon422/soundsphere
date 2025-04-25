-- SOURCE: https://osu.ppy.sh/wiki/en/Gameplay/Judgement/osu!mania

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local SimpleJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.SimpleJudgesSource")
local JudgeAccuracy = require("sphere.models.RhythmModel.ScoreEngine.JudgeAccuracy")
local JudgeCounter = require("sphere.models.RhythmModel.ScoreEngine.JudgeCounter")
local JudgeWindows = require("sphere.models.RhythmModel.ScoreEngine.JudgeWindows")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sphere.OsuManiaV2Score: sphere.ScoreSystem, sphere.IAccuracySource, sphere.SimpleJudgesSource
---@operator call: sphere.OsuManiaV2Score
local OsuManiaV2Score = ScoreSystem + IAccuracySource + SimpleJudgesSource

OsuManiaV2Score.judge_names = {"perfect", "great", "good", "ok", "meh", "miss"}

local weights = {305, 300, 200, 100, 50, 0}

---@param od number
function OsuManiaV2Score:new(od)
	self.timings = Timings("osuod", od)
	self.subtimings = Subtimings("scorev", 2)

	self.od = od

	self.judge_counter = JudgeCounter(6)
	self.judge_accuracy = JudgeAccuracy(weights)

	local od3 = 3 * od

	local perfect_window = od < 5 and 22.4 - 0.6 * od or 24.9 - 1.1 * od

	self.windows = {
		perfect_window / 1000,
		(64 - od3) / 1000,
		(97 - od3) / 1000,
		(127 - od3) / 1000,
		(151 - od3) / 1000,
		(188 - od3) / 1000,
	}

	self.judge_windows = JudgeWindows(self.windows)
end

---@return string
function OsuManiaV2Score:getKey()
	return "osu_mania_v2_od" .. self.od
end

---@param event table
function OsuManiaV2Score:hit(event)
	local is_release = event.newState == "endPassed" or event.newState == "endMissedPassed"

	---@type number
	local delta_time = event.deltaTime
	if is_release then
		delta_time = delta_time / 1.5
	end

	local index = self.judge_windows:get(delta_time) or -1
	self.judge_counter:add(index)
end

function OsuManiaV2Score:miss()
	self.judge_counter:add(-1)
end

function OsuManiaV2Score:getAccuracy()
	return self.judge_accuracy:get(self.judge_counter.judges)
end

function OsuManiaV2Score:getAccuracyString()
	return ("%0.02f%%"):format(self:getAccuracy() * 100)
end

function OsuManiaV2Score:getSlice()
	return {
		accuracy = self:getAccuracy(),
		last_judge = self:getLastJudge(),
	}
end

OsuManiaV2Score.events = {
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

return OsuManiaV2Score

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local OsuManiaScoring = require("sphere.models.RhythmModel.ScoreEngine.OsuManiaScoring")

---@class sphere.JudgementScoreSystem: sphere.ScoreSystem
---@operator call: sphere.JudgementScoreSystem
local JudgementScoreSystem = ScoreSystem + {}

JudgementScoreSystem.name = "judgement"

function JudgementScoreSystem:load()
	self.judgements = {
		all = { "count" },
		earlylate = { "early", 0, "late" },
		soundsphere = {
			{ "early not perfect", "not perfect" },
			-0.016,
			"perfect",
			0.016,
			{ "late not perfect",  "not perfect" }
		},
	}

	self.judgementLists = {
		soundsphere = {
			"perfect",
			"not perfect",
		},
	}

	self.judgementSelectors = {
		{ "soundsphere" },
	}

	self.counter = 0

	self.counters = {
		soundsphere = {
			perfect = 0,
			["not perfect"] = 0
		},
		all = {
			count = 0
		},
		earlylate = {
			early = 0,
			late = 0
		}
	}
end

---@param event table
function JudgementScoreSystem:hit(event)
	self.counter = self.counter + 1
end

JudgementScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "hit",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "hit",
			startMissedPressed = "hit",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = "hit",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = "hit",
			startMissed = nil,
			endMissed = "hit",
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "hit",
		},
	},
}

return JudgementScoreSystem

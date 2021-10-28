local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local JudgementScoreSystem = ScoreSystem:new()

JudgementScoreSystem.name = "judgement"

JudgementScoreSystem.judgements = {
	all = {"count"},
	earlylate = {"early", 0, "late"},
	soundsphere = {
		{"early not perfect", "not perfect"},
		-0.016,
		"perfect",
		0.016,
		{"late not perfect", "not perfect"}
	},
}

for od = 0, 10 do
	local _3od = 3 * od
	local _300g = 16
	local _300 = 64 - _3od
	local _200 = 97 - _3od
	local _100 = 127 - _3od
	local _50 = 151 - _3od
	local _0 = 188 - _3od
	local judgements = {
		-_0,
		"0",
		-_50,
		"50",
		-_100,
		"100",
		-_200,
		"200",
		-_300,
		"300",
		-_300g,
		"300g",
		_300g,
		"300",
		_300,
		"200",
		_200,
		"100",
		_100,
		"50",
		_50,
		"0"
	}
	for i = 1, #judgements do
		if type(judgements[i]) == "number" then
			judgements[i] = judgements[i] / 1000
		end
	end
	JudgementScoreSystem.judgements["osuOD" .. od] = judgements
end

JudgementScoreSystem.construct = function(self)
	self.counters = {}
end

JudgementScoreSystem.load = function(self)
	for name, judgements in pairs(self.scoreEngine.judgements) do
		self.judgements[name] = judgements
	end
	local counters = self.counters
	for name, judgements in pairs(self.judgements) do
		counters[name] = counters[name] or {}
	end
end

JudgementScoreSystem.getJudgement = function(_, judgements, deltaTime)
	for i, v in ipairs(judgements) do
		if type(v) ~= "number" then
			local prev = judgements[i - 1] or -math.huge
			local next = judgements[i + 1] or math.huge
			if deltaTime >= prev and deltaTime < next then
				return v
			end
		end
	end
end

JudgementScoreSystem.processJudgement = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)

	local counters = self.counters
	for name, judgements in pairs(self.judgements) do
		counters[name] = counters[name] or {}
		local judgement = self:getJudgement(judgements, deltaTime)
		if judgement then
			if type(judgement) == "string" then
				counters[name][judgement] = (counters[name][judgement] or 0) + 1
			elseif type(judgement) == "table" then
				for _, j in ipairs(judgement) do
					counters[name][j] = (counters[name][j] or 0) + 1
				end
			end
		end
	end
end

JudgementScoreSystem.processMiss = JudgementScoreSystem.processJudgement

JudgementScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = JudgementScoreSystem.processJudgement,
			missed = JudgementScoreSystem.processMiss,
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = JudgementScoreSystem.processJudgement,
			startMissed = JudgementScoreSystem.processMiss,
			startMissedPressed = JudgementScoreSystem.processMiss,
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

return JudgementScoreSystem

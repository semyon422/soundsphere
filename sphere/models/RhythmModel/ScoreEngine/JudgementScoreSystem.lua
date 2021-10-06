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

JudgementScoreSystem.construct = function(self)
	self.ratio = 0
	self.judgementName = ""
	self.maxDeltaTime = 0
	self.deltaTime = 0
	self.earlylate = 0
	self.counters = {}
	table.sort(self.judgements, function(a, b) return math.abs(a[1]) < math.abs(b[1]) end)
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

JudgementScoreSystem.getSlice = function(self)
	return {
		ratio = self.ratio,
		judgementName = self.judgementName,
		maxDeltaTime = self.maxDeltaTime,
		deltaTime = self.deltaTime,
		earlylate = self.earlylate,
	}
end

JudgementScoreSystem.processJudgement = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

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

	self.ratio = (counters.soundsphere.perfect or 0) / (counters.all.count or 1)
	self.earlylate = (counters.earlylate.early or 0) / (counters.earlylate.late or 1)
end

JudgementScoreSystem.processMiss = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)
	self.deltaTime = deltaTime
end

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

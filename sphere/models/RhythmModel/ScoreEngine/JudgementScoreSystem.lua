local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local JudgementScoreSystem = ScoreSystem:new()

JudgementScoreSystem.name = "judgement"

JudgementScoreSystem.judgements = {
	{-1, "early not perfect", "not perfect", "all", "early"},
	{-0.016, "perfect", "all", "early"},
	{0.016, "perfect", "all", "late"},
	{1, "late not perfect", "not perfect", "all", "late"},
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

JudgementScoreSystem.getSlice = function(self)
	local counters = {}
	for k, v in pairs(self.counters) do
		counters[k] = v
	end
	return {
		counters = counters,
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
	for _, judgement in ipairs(self.judgements) do
		local time = judgement[1]
		if deltaTime * time > 0 and math.abs(deltaTime) <= math.abs(time) then
			for i = 2, #judgement do
				local name = judgement[i]
				counters[name] = (counters[name] or 0) + 1
			end
			self.judgementName = judgement[2]
			break
		end
	end

	self.ratio = (counters.perfect or 0) / (counters.all or 1)
	self.earlylate = (counters.early or 0) / (counters.late or 1)
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

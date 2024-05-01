local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.JudgementScoreSystem: sphere.ScoreSystem
---@operator call: sphere.JudgementScoreSystem
local JudgementScoreSystem = ScoreSystem + {}

JudgementScoreSystem.name = "judgement"

function JudgementScoreSystem:load()
	self.judges = {}
	self.judgementList = {}

	local _j = self.scoreEngine.judgements

	if not _j.judgements or not _j.judgementLists or not _j.judgementSelectors then
		return
	end

	for _, judge in ipairs(_j.judgementSelectors) do
		local name = judge[1]
		self.judges[name] = {}
		table.insert(self.judgementList, { name = name })
	end

	for name, judge in pairs(_j.judgementLists) do
		self.judges[name].orderedCounters = judge
	end

	for name, judgements in pairs(_j.judgements) do
		local counters = {}
		for _, judgement in ipairs(judgements) do
			if type(judgement) ~= "number" then
				if type(judgement) == "string" then
					counters[judgement] = 0
				elseif type(judgement) == "table" then
					for _, j in ipairs(judgement) do
						counters[j] = 0
					end
				end
			end
		end

		local judge = self.judges[name]
		judge.scoreSystemName = JudgementScoreSystem.name
		judge.counters = counters
		judge.windows = judgements
		judge.accuracy = 0
		judge.notes = 0
		judge.accuracyFunc = judgements.accuracy
	end
end

---@param judgements table
---@param deltaTime number
---@return string|table?
function JudgementScoreSystem:getJudgement(judgements, deltaTime)
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

---@param event table
function JudgementScoreSystem:hit(event)
	for _, judge in pairs(self.judges) do
		local counter = self:getJudgement(judge.windows, event.deltaTime)
		if counter then
			if type(counter) == "string" then
				judge.counters[counter] = judge.counters[counter] + 1
				judge.notes = judge.notes + 1
			elseif type(counter) == "table" then
				for _, j in ipairs(counter) do
					judge.counters[j] = judge.counters[j] + 1
				end
				judge.notes = judge.notes + 1
			end
		end

		judge.accuracy = judge.accuracyFunc(judge.counters, judge.notes)
	end
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

local class = require("class")

---@class sphere.JudgementView
---@operator call: sphere.JudgementView
---@field counterIndex {[string]: number}
local JudgementView = class()

function JudgementView:load()
	local score_engine = self.game.rhythmModel.scoreEngine
	if not score_engine.loaded then
		return
	end

	self.judge = self.game.rhythmModel.scoreEngine:getJudge()
	self.notes = 0

	self.counterIndex = {}

	local counters = self.judge.orderedCounters
	for i, v in ipairs(counters) do
		self.counterIndex[v] = i
	end

	self.counterIndex.miss = #self.judgements
end

---@param dt number
function JudgementView:update(dt)
	local judge = self.judge

	local notes = judge.notes
	if notes == self.notes then
		return
	end
	self.notes = notes

	local counter_index = self.counterIndex[judge.lastCounter]
	for i, view in ipairs(self.judgements) do
		if i == counter_index then
			view:setTime(0)
		else
			view:setTime(math.huge)
		end
	end
end

return JudgementView

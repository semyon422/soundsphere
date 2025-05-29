local class = require("class")

---@class sphere.DeltaTimeJudgementView
---@operator call: sphere.DeltaTimeJudgementView
local DeltaTimeJudgementView = class()

function DeltaTimeJudgementView:load()
	self.deltaTime = 0
	self.judgement = nil
	self.judgementCounter = 0
end

---@param judgements table
---@param deltaTime number
---@return string|table?
function DeltaTimeJudgementView:getJudgement(judgements, deltaTime)
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

function DeltaTimeJudgementView:update()
	local scores = self.game.rhythmModel.scoreEngine.scores
	local judge = scores.base

	if judge.hitCount == self.judgementCounter then
		return
	end
	self.judgementCounter = judge.hitCount
	self.deltaTime = scores.misc.deltaTime

	local judgement = self:getJudgement(self.judgements, self.deltaTime)
	self.judgement = judgement
	if not judgement then
		return
	end

	for _, view in ipairs(self.judgements) do
		if type(view) ~= "number" then
			if view == judgement then
				view:setTime(0)
			else
				view:setTime(math.huge)
			end
		end
	end
end

return DeltaTimeJudgementView

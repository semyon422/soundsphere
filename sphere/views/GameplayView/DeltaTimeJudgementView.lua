local class = require("class")

-- local JudgementScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem")

---@class sphere.DeltaTimeJudgementView
---@operator call: sphere.DeltaTimeJudgementView
local DeltaTimeJudgementView = class()

function DeltaTimeJudgementView:load()
	self.deltaTime = 0
	self.judgement = nil
	self.judgementCounter = 0
end

function DeltaTimeJudgementView:update()
	local scores = self.game.rhythmModel.scoreEngine.scores
	local judge = scores.soundsphere.judges["soundsphere"]

	if judge.notes == self.judgementCounter then
		return
	end
	self.judgementCounter = judge.notes
	self.deltaTime = scores.misc.deltaTime

	local judgement = JudgementScoreSystem:getJudgement(self.judgements, self.deltaTime)
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

local Class				= require("Class")
local JudgementScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem")

local DeltaTimeJudgementView = Class:new()

DeltaTimeJudgementView.load = function(self)
	self.deltaTime = 0
	self.judgement = nil
	self.judgementCounter = 0
end

DeltaTimeJudgementView.update = function(self)
	local scoreSystem = self.game.rhythmModel.scoreEngine.scoreSystem

	if scoreSystem.judgement.counter == self.judgementCounter then
		return
	end
	self.judgementCounter = scoreSystem.judgement.counter
	self.deltaTime = scoreSystem.misc.deltaTime

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

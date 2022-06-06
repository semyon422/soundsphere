local Class				= require("aqua.util.Class")
local JudgementScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem")

local DeltaTimeJudgementView = Class:new()

DeltaTimeJudgementView.load = function(self)
	local state = self.state

	state.deltaTime = 0
	state.judgement = nil
	state.judgementCounter = 0
end

DeltaTimeJudgementView.update = function(self)
	local config = self.config
	local state = self.state
	local scoreSystem = self.game.rhythmModel.scoreEngine.scoreSystem

	if scoreSystem.judgement.counter == state.judgementCounter then
		return
	end
	state.judgementCounter = scoreSystem.judgement.counter
	state.deltaTime = scoreSystem.misc.deltaTime

	local judgement = JudgementScoreSystem:getJudgement(config.judgements, state.deltaTime)
	state.judgement = judgement
	if not judgement then
		return
	end

	for _, viewConfig in ipairs(config.judgements) do
		if type(viewConfig) ~= "number" then
			local view = self.sequenceView:getView(viewConfig)
			if viewConfig == judgement then
				view:setTime(0)
			else
				view:setTime(math.huge)
			end
		end
	end
end

return DeltaTimeJudgementView

local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")
local JudgementScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem")

local JudgementDeltaView = Class:new()

JudgementDeltaView.load = function(self)
	local config = self.config
	local state = self.state

	state.judgementTable = inside(self, config.key)
	state.deltaTime = state.judgementTable.deltaTime
	state.judgement = nil
end

JudgementDeltaView.update = function(self)
	local config = self.config
	local state = self.state
	local judgementTable = state.judgementTable

	if judgementTable.deltaTime == state.deltaTime then
		return
	end
	state.deltaTime = judgementTable.deltaTime

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

return JudgementDeltaView

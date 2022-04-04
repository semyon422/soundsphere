local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")

local JudgementView = Class:new()

JudgementView.load = function(self)
	local config = self.config
	local state = self.state

	local judgementTable = inside(self, config.key)
	local counters = {}
	state.counters = counters
	for name in pairs(config.judgements) do
		counters[name] = judgementTable[name]
	end
	state.judgement = nil
end

JudgementView.update = function(self, dt)
	local config = self.config
	local state = self.state
	local judgementTable = inside(self, config.key)

	local counters = state.counters
	local judgement
	for name in pairs(config.judgements) do
		if judgementTable[name] ~= counters[name] then
			counters[name] = judgementTable[name]
			judgement = name
		end
	end
	state.judgement = judgement
	if not judgement then
		return
	end
	for name, viewConfig in pairs(config.judgements) do
		local view = self.sequenceView:getView(viewConfig)
		if name == judgement then
			view:setTime(0)
		else
			view:setTime(math.huge)
		end
	end
end

return JudgementView

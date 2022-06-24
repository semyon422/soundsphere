local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")

local JudgementView = Class:new()

JudgementView.load = function(self)
	local judgementTable = inside(self, self.key)
	local counters = {}
	self.counters = counters
	for name in pairs(self.judgements) do
		counters[name] = judgementTable[name]
	end
	self.judgement = nil
end

JudgementView.update = function(self, dt)
	local judgementTable = inside(self, self.key)

	local counters = self.counters
	local judgement
	for name in pairs(self.judgements) do
		if judgementTable[name] ~= counters[name] then
			counters[name] = judgementTable[name]
			judgement = name
		end
	end
	self.judgement = judgement
	if not judgement then
		return
	end
	for name, view in pairs(self.judgements) do
		if name == judgement then
			view:setTime(0)
		else
			view:setTime(math.huge)
		end
	end
end

return JudgementView

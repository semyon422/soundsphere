local class = require("class")
local inside = require("table_util").inside

local JudgementView = class()

function JudgementView:load()
	local judgementTable = inside(self, self.key) or {}
	local counters = {}
	self.counters = counters
	for name in pairs(self.judgements) do
		counters[name] = judgementTable[name]
	end
	self.judgement = nil
end

function JudgementView:update(dt)
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

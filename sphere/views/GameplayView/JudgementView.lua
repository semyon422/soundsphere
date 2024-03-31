local class = require("class")
local inside = require("table_util").inside

---@class sphere.JudgementView
---@operator call: sphere.JudgementView
local JudgementView = class()

function JudgementView:load()
	self.judgement = nil
end

---@param dt number
function JudgementView:update(dt)
	local judge = inside(self, self.key)

	local judgement = judge.lastCounter
	if not judgement or judgement == self.judgement then
		return
	end
	self.judgement = judgement

	for name, view in pairs(self.judgements) do
		if name == judgement then
			view:setTime(0)
		else
			view:setTime(math.huge)
		end
	end
end

return JudgementView

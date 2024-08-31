local class = require("class")
local inside = require("table_util").inside

---@class sphere.JudgementView
---@operator call: sphere.JudgementView
local JudgementView = class()

function JudgementView:load()
	self.notes = 0
end

---@param dt number
function JudgementView:update(dt)
	local judge = inside(self, self.key)

	local notes = judge.notes
	if notes == self.notes then
		return
	end
	self.notes = notes

	local judgement = judge.lastCounter
	for name, view in pairs(self.judgements) do
		if name == judgement then
			view:setTime(0)
		else
			view:setTime(math.huge)
		end
	end
end

return JudgementView

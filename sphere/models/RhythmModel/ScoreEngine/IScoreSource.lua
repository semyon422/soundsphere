local class = require("class")

---@class sphere.IScoreSource
---@operator call: sphere.IScoreSource
local IScoreSource = class()

IScoreSource.score_multiplier = 1

---@return number
function IScoreSource:getScore()
	error("not implemented")
end

---@return string
function IScoreSource:getScoreString()
	return tostring(self:getScore())
end

return IScoreSource

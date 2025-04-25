local class = require("class")

---@class sphere.IScoreSource
---@operator call: sphere.IScoreSource
local IScoreSource = class()

---@return number
function IScoreSource:getScore()
	error("not implemented")
end

---@return string
function IScoreSource:getScoreString()
	return tostring(self:getScore())
end

return IScoreSource

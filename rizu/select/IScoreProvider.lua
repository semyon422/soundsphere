local class = require("class")

---@class rizu.select.IScoreProvider
---@operator call: rizu.select.IScoreProvider
local IScoreProvider = class()

---@param chartview rizu.Chartview
---@param exact boolean
---@return sea.Chartplay[]
function IScoreProvider:getScores(chartview, exact)
	error("not implemented")
end

return IScoreProvider

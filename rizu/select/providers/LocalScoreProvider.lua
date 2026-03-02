local class = require("class")
local IScoreProvider = require("rizu.select.IScoreProvider")

---@class rizu.select.providers.LocalScoreProvider: sphere.IScoreProvider
---@operator call: rizu.select.providers.LocalScoreProvider
local LocalScoreProvider = IScoreProvider + {}

---@param library rizu.library.Library
function LocalScoreProvider:new(library)
	self.library = library
end

---@param chartview sphere.Chartview
---@param exact boolean
---@return sea.Chartplay[]
function LocalScoreProvider:getScores(chartview, exact)
	if exact then
		return self.library.chartsRepo:getChartplaysForChartdiff(chartview)
	else
		return self.library.chartsRepo:getChartplaysForChartmeta(chartview)
	end
end

return LocalScoreProvider

local class = require("class")
local IScoreProvider = require("rizu.select.IScoreProvider")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@class rizu.select.providers.OnlineScoreProvider: sphere.IScoreProvider
---@operator call: rizu.select.providers.OnlineScoreProvider
local OnlineScoreProvider = IScoreProvider + {}

---@param onlineModel sphere.OnlineModel
function OnlineScoreProvider:new(onlineModel)
	self.onlineModel = onlineModel
end

---@param chartview sphere.Chartview
---@param exact boolean
---@return sea.Chartplay[]?
---@return string?
function OnlineScoreProvider:getScores(chartview, exact)
	local sea_client = self.onlineModel.authManager.sea_client
	if not sea_client.connected then
		return {}
	end

	local remote = sea_client.remote

	if exact then
		local chartdiff_key = ChartdiffKey()
		chartdiff_key:importChartdiffKey(chartview)
		return remote.submission:getBestChartplaysForChartdiff(chartdiff_key)
	else
		local chartmeta_key = ChartmetaKey()
		chartmeta_key:importChartmetaKey(chartview)
		return remote.submission:getBestChartplaysForChartmeta(chartmeta_key)
	end
end

return OnlineScoreProvider

local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")

---@class sea.SubmissionServerRemoteValidation: sea.SubmissionServerRemote
---@operator call: sea.SubmissionServerRemoteValidation
local SubmissionServerRemoteValidation = class()

---@param remote sea.SubmissionServerRemote
function SubmissionServerRemoteValidation:new(remote)
	self.remote = remote
end

---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function SubmissionServerRemoteValidation:submitChartplay(chartplay_values, chartdiff_values)
	assert(valid.format(Chartplay.validate(chartplay_values)))
	assert(valid.format(Chartdiff.validate(chartdiff_values)))

	setmetatable(chartplay_values, Chartplay)
	setmetatable(chartdiff_values, Chartdiff)

	return self.remote:submitChartplay(chartplay_values, chartdiff_values)
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemoteValidation:getBestChartplaysForChartmeta(chartmeta_key)
	assert(valid.format(ChartmetaKey.validate(chartmeta_key)))
	setmetatable(chartmeta_key, ChartmetaKey)

	return self.remote:getBestChartplaysForChartmeta(chartmeta_key)
end

---@param chartdiff_key sea.ChartdiffKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemoteValidation:getBestChartplaysForChartdiff(chartdiff_key)
	assert(valid.format(ChartdiffKey.validate(chartdiff_key)))
	setmetatable(chartdiff_key, ChartdiffKey)

	return self.remote:getBestChartplaysForChartdiff(chartdiff_key)
end

---@param replay_hash string
---@return string?
---@return string?
function SubmissionServerRemoteValidation:getReplayFile(replay_hash)
	assert(types.md5hash(replay_hash))

	return self.remote:getReplayFile(replay_hash)
end

return SubmissionServerRemoteValidation

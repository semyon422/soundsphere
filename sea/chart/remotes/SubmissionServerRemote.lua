local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param chartplay_submission sea.ChartplaySubmission
---@param chartplays sea.Chartplays
function SubmissionServerRemote:new(chartplay_submission, chartplays)
	self.chartplay_submission = chartplay_submission
	self.chartplays = chartplays
end

---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function SubmissionServerRemote:submitChartplay(chartplay_values, chartdiff_values)
	local ok, err = valid.format(Chartplay.validate(chartplay_values))
	if not ok then
		return nil, "chartplay submit: " .. err
	end
	setmetatable(chartplay_values, Chartplay)

	local ok, err = valid.format(Chartdiff.validate(chartdiff_values))
	if not ok then
		return nil, "chartdiff submit: " .. err
	end
	setmetatable(chartdiff_values, Chartdiff)

	return self.chartplay_submission:submitChartplay(self.user, os.time(), self.remote, chartplay_values, chartdiff_values)
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemote:getBestChartplaysForChartmeta(chartmeta_key)
	local ok, err = valid.format(ChartmetaKey.validate(chartmeta_key))
	if not ok then
		return nil, "validate chartmeta key: " .. err
	end
	setmetatable(chartmeta_key, ChartmetaKey)

	return self.chartplays:getBestChartplaysForChartmeta(self.user, chartmeta_key)
end

---@param chartdiff_key sea.ChartdiffKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemote:getBestChartplaysForChartdiff(chartdiff_key)
	local ok, err = valid.format(ChartdiffKey.validate(chartdiff_key))
	if not ok then
		return nil, "validate chartdiff_key: " .. err
	end
	setmetatable(chartdiff_key, ChartdiffKey)

	return self.chartplays:getBestChartplaysForChartdiff(self.user, chartdiff_key)
end

---@param replay_hash string
---@return string?
---@return string?
function SubmissionServerRemote:getReplayFile(replay_hash)
	if not types.md5hash(replay_hash) then
		return nil, "invalid replay hash"
	end

	return self.chartplays:getReplayFile(self.user, replay_hash)
end

return SubmissionServerRemote

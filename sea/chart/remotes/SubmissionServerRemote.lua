local class = require("class")
local valid = require("valid")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local ComputeDataLoader = require("sea.chart.ComputeDataLoader")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param chartplays sea.Chartplays
function SubmissionServerRemote:new(chartplays)
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

	local compute_data_loader = ComputeDataLoader(self.remote.compute_data_provider)

	local chartplay, err = self.chartplays:submit(self.user, compute_data_loader, chartplay_values, chartdiff_values)
	if not chartplay then
		return nil, "submit: " .. err
	end

	return chartplay
end

return SubmissionServerRemote

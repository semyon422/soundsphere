local class = require("class")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")

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
	if type(chartplay_values) ~= "table" then
		return nil, "chartplay is not a table"
	elseif type(chartdiff_values) ~= "table" then
		return nil, "chartdiff is not a table"
	end

	setmetatable(chartplay_values, Chartplay)
	---@cast chartplay_values sea.Chartplay
	setmetatable(chartdiff_values, Chartdiff)
	---@cast chartdiff_values sea.Chartdiff

	local ok, errs = chartplay_values:validate()
	if not ok then
		return nil, "chartplay submit: " .. table.concat(errs, ", ")
	end

	local ok, errs = chartdiff_values:validate()
	if not ok then
		return nil, "chartdiff submit: " .. table.concat(errs, ", ")
	end

	local chartplay, err = self.chartplays:submit(self.user, self.remote.submission, chartplay_values, chartdiff_values)
	if not chartplay then
		return nil, "submit: " .. err
	end

	return chartplay
end

return SubmissionServerRemote

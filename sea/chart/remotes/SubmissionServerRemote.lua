local class = require("class")
local Chartplay = require("sea.chart.Chartplay")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param chartplays sea.Chartplays
function SubmissionServerRemote:new(chartplays)
	self.chartplays = chartplays
end

---@param chartplay_values any?
---@return sea.Chartplay?
---@return string?
function SubmissionServerRemote:submitChartplay(chartplay_values)
	if type(chartplay_values) ~= "table" then
		return nil, "not a table"
	end

	setmetatable(chartplay_values, Chartplay)
	---@cast chartplay_values sea.Chartplay

	local ok, errs = chartplay_values:validate()
	if not ok then
		return nil, table.concat(errs, ", ")
	end

	return self.chartplays:submit(self.user, self.remote.submission, chartplay_values)
end

return SubmissionServerRemote

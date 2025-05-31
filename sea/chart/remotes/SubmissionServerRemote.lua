local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param domain sea.Domain
function SubmissionServerRemote:new(domain)
	self.domain = domain
	self.chartplays = domain.chartplays
end

---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay
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

	local time = os.time()
	local chartplay, err = self.domain:submitChartplay(self.user, time, compute_data_loader, chartplay_values, chartdiff_values)
	if not chartplay then
		return nil, "submit: " .. err
	end

	if self.domain.dans:isDan(chartdiff_values) then
		local dan_clear, err = self.domain.dans:submit(self.user, chartplay, chartdiff_values, time)
		self.remote:print(dan_clear and "dan cleared" or err)
	end

	return chartplay
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

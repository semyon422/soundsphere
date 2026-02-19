local class = require("class")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param chartplay_submission sea.ChartplaySubmission
---@param chartplays sea.Chartplays
---@param domain sea.Domain
function SubmissionServerRemote:new(chartplay_submission, chartplays, domain)
	self.chartplay_submission = chartplay_submission
	self.chartplays = chartplays
	self.domain = domain
end

---@param chartplay sea.Chartplay
---@param chartdiff sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function SubmissionServerRemote:submitChartplay(chartplay, chartdiff)
	return self.domain:transaction(function()
		return self.chartplay_submission:submitChartplay(self.user, os.time(), self.remote, chartplay, chartdiff)
	end)
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemote:getBestChartplaysForChartmeta(chartmeta_key)
	return self.chartplays:getBestChartplaysForChartmeta(self.user, chartmeta_key)
end

---@param chartdiff_key sea.ChartdiffKey
---@return sea.Chartplay[]?
---@return string?
function SubmissionServerRemote:getBestChartplaysForChartdiff(chartdiff_key)
	return self.chartplays:getBestChartplaysForChartdiff(self.user, chartdiff_key)
end

---@param replay_hash string
---@return string?
---@return string?
function SubmissionServerRemote:getReplayFile(replay_hash)
	return self.chartplays:getReplayFile(self.user, replay_hash)
end

return SubmissionServerRemote

local Leaderboard = require("sea.leaderboards.Leaderboard")

---@class sea.OsuLeaderboard: sea.Leaderboard
---@operator call: sea.OsuLeaderboard
local OsuLeaderboard = Leaderboard + {}

---@param chartplay sea.Chartplay
function OsuLeaderboard:addChartplay(chartplay)

end

---@param modifiers sea.Modifier[]
function OsuLeaderboard:isOsuModifiers(modifiers)
	-- 0.75, 1.5, mirror, etc
	return true
end

---@param timings sea.Timings
---@param od number
function OsuLeaderboard:isOsuTimings(timings, od)
	-- check timings equals OD
	return true
end

---@param chartplay sea.Chartplay
---@param chartdiff sea.Chartdiff
---@param chartmeta sea.Chartmeta
---@return boolean?
---@return string?
function OsuLeaderboard:check(chartplay, chartdiff, chartmeta)
	return
		chartmeta.format == "osu" and
		self:isOsuModifiers(chartdiff.modifiers) and
		self:isOsuTimings(chartplay.timings, chartmeta.osu_od)
end

return OsuLeaderboard

local class = require("class")

---@class sea.Leaderboard
---@operator call: sea.Leaderboard
---@field id integer
---@field name string
---@field description string
---@field owner_community_id integer - ?
---@field created_at integer
---@field rating_calculator integer enum
---@field scores_combiner integer enum
---@field scores_combiner_count integer
---@field communities_combiner integer enum
---@field communities_combiner_count integer
---@field difftables_count integer
---@field users_count integer
local Leaderboard = class()

---@param chartplay sea.Chartplay
function Leaderboard:addChartplay(chartplay)

end

---@param chartplay sea.Chartplay
---@param chartdiff sea.Chartdiff
---@param chartmeta sea.Chartmeta
---@return boolean? accept nil - error, true/false - accepted
---@return string?
function Leaderboard:check(chartplay, chartdiff, chartmeta)
	return true
end

return Leaderboard

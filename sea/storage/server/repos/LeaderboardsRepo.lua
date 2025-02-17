local class = require("class")
local Result = require("sea.chart.Result")

---@class sea.LeaderboardsRepo
---@operator call: sea.LeaderboardsRepo
local LeaderboardsRepo = class()

---@param models rdb.Models
function LeaderboardsRepo:new(models)
	self.models = models
end

---@return sea.Leaderboard[]
function LeaderboardsRepo:getLeaderboards()
	return self.models.leaderboards:select()
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:getLeaderboard(id)
	return self.models.leaderboards:find({id = id})
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:createLeaderboard(leaderboard)
	return self.models.leaderboards:create(leaderboard)
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:updateLeaderboard(leaderboard)
	return self.models.leaderboards:update(leaderboard, {id = leaderboard.id})[1]
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:deleteLeaderboard(id)
	return self.models.leaderboards:remove({id = id})[1]
end

local nearest_cond = {
	disabled = false,
	enabled = true,
	any = nil,
}

---@param lb sea.Leaderboard
---@param user sea.User
---@return sea.Chartplay[]
function LeaderboardsRepo:getBestChartplays(lb, user)
	---@type rdb.Conditions
	local conds = {
		user_id = user.id,
		nearest = nearest_cond[lb.nearest],
		result__in = Result:condition(lb.result),
		mode = lb.mode,
	}
	if not lb.allow_custom then
		conds.custom = false
	end
	if not lb.allow_pause then
		conds.pause_count = 0
	end
	if not lb.allow_reorder then
		conds.columns_order = {}
	end
	if not lb.allow_modifiers then
		conds.modifiers = {}
	end
	if not lb.allow_tap_only then
		conds.tap_only = false
	end
	if not lb.allow_free_timings then
		conds.timings_ = "chartmeta_timings"
	end

	local rate = lb.rate
	if type(rate) == "number" then
		conds.rate = rate
	elseif rate[1] then
		conds.rate__in = rate
	elseif rate.min then
		conds.rate__gte, conds.rate__lte = rate.min, rate.max
	end

	local inputmode = lb.inputmode
	if inputmode[1] then
		conds.inputmode__in = inputmode
	end

	local ranked_lists = lb.ranked_lists
	if ranked_lists[1] then
		conds.ranked_list_id__in = ranked_lists
	end

	---@type rdb.Options
	local options = {
		group = nil,
		limit = lb.scores_combiner_count,
		order = nil, -- rating_calculator
	}

	return self.models.chartplayviews:select(conds, options)
end

return LeaderboardsRepo

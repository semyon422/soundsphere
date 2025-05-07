local sql_util = require("rdb.sql_util")
local table_util = require("table_util")
local RatingCalc = require("sea.leaderboards.RatingCalc")
local ILeaderboardsRepo = require("sea.leaderboards.repos.ILeaderboardsRepo")
local Leaderboard = require("sea.leaderboards.Leaderboard")

---@class sea.LeaderboardsRepo: sea.ILeaderboardsRepo
---@operator call: sea.LeaderboardsRepo
local LeaderboardsRepo = ILeaderboardsRepo + {}

---@param models rdb.Models
function LeaderboardsRepo:new(models)
	self.models = models
end

---@return sea.Leaderboard[]
function LeaderboardsRepo:getLeaderboards()
	local lbs = self.models.leaderboards:select()
	self.models.leaderboards:preload(lbs, "leaderboard_difftables")
	return lbs
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:getLeaderboard(id)
	local lb = self.models.leaderboards:find({id = assert(id)})
	self.models.leaderboards:preload({lb}, {leaderboard_difftables = "difftable"})
	return lb
end

---@param name string
---@return sea.Leaderboard?
function LeaderboardsRepo:getLeaderboardByName(name)
	return self.models.leaderboards:find({name = assert(name)})
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:createLeaderboard(leaderboard)
	return self.models.leaderboards:create(leaderboard)
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:updateLeaderboard(leaderboard)
	return self.models.leaderboards:update(leaderboard, {id = assert(leaderboard.id)})[1]
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:updateLeaderboardFull(leaderboard)
	local values = sql_util.null_keys(Leaderboard.struct)
	table_util.copy(leaderboard, values)
	return self.models.leaderboards:update(values, {id = assert(leaderboard.id)})[1]
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:deleteLeaderboard(id)
	return self.models.leaderboards:delete({id = assert(id)})[1]
end

local nearest_cond = {
	disabled = false,
	enabled = true,
	any = nil,
}

---@param lb sea.Leaderboard
---@param user_id integer
---@return rdb.Conditions
---@return rdb.Options
function LeaderboardsRepo:getFilterConds(lb, user_id)
	---@type rdb.Conditions
	local conds = {
		user_id = assert(user_id),
		nearest = nearest_cond[lb.nearest],
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
		if lb.timings then
			conds.timings = lb.timings
		else
			conds.timings_ = "chartmeta_timings"
		end
	end
	if not lb.allow_free_healths then
		if lb.healths then
			conds.healths = lb.healths
		else
			conds.healths_ = "chartmeta_healths"
		end
	end
	if lb.pass then
		conds.pass = true
	end
	if lb.judges == "fc" then
		conds.miss_count = 0
	elseif lb.judges == "pfc" then
		conds.miss_count = 0
		conds.not_perfect_count = 0
	end

	local rate = lb.rate
	if type(rate) == "number" then
		conds.rate = rate
	elseif rate[1] then
		conds.rate__in = rate
	elseif rate.min then
		conds.rate__gte, conds.rate__lte = rate.min, rate.max
	end

	if lb.starts_at then
		conds.submitted_at__gte = lb.starts_at
	end
	if lb.ends_at then
		conds.submitted_at__lte = lb.ends_at
	end

	local chartmeta_inputmode = lb.chartmeta_inputmode
	if chartmeta_inputmode[1] then
		conds.chartmeta_inputmode__in = chartmeta_inputmode
	end

	local chartdiff_inputmode = lb.chartdiff_inputmode
	if chartdiff_inputmode[1] then
		conds.chartdiff_inputmode__in = chartdiff_inputmode
	end

	local difftable_ids = {}
	for _, lb_dt in ipairs(lb.leaderboard_difftables) do
		table.insert(difftable_ids, lb_dt.difftable_id)
	end
	if difftable_ids[1] then
		conds.difftable_id__in = difftable_ids
	end

	local rating_column = RatingCalc:column(lb.rating_calc)

	---@type rdb.Options
	local options = {
		group = {"hash"},
		limit = lb.scores_comb_count,
		order = {rating_column .. " DESC"}, -- TODO: rating_calculator
		columns = {"*", ("MAX(%s) AS _rating"):format(rating_column), "MAX(difftable_level) AS _difftable_level"}
	}

	return conds, options
end

---@param lb sea.Leaderboard
---@param chartplay sea.Chartplay
---@return boolean
function LeaderboardsRepo:checkChartplay(lb, chartplay)
	local conds, options = self:getFilterConds(lb, chartplay.user_id)
	conds.chartplay_id = assert(chartplay.id)
	return not not self.models.chartplayviews:select(conds, options)[1]
end

---@param lb sea.Leaderboard
---@param user_id integer
---@return sea.Chartplayview[]
function LeaderboardsRepo:getBestChartplays(lb, user_id)
	local conds, options = self:getFilterConds(lb, user_id)
	return self.models.chartplayviews:select(conds, options)
end

---@param lb sea.Leaderboard
---@param user_id integer
---@return sea.Chartplayview[]
function LeaderboardsRepo:getBestChartplaysFull(lb, user_id)
	local chartplayviews = self:getBestChartplays(lb, user_id)
	self.models.chartplayviews:preload(chartplayviews, "chartdiff", "chartmeta")
	return chartplayviews
end

--------------------------------------------------------------------------------

---@param leaderboard_id integer
---@param user_id integer
---@return sea.LeaderboardUser?
function LeaderboardsRepo:getLeaderboardUser(leaderboard_id, user_id)
	return self.models.leaderboard_users:find({
		leaderboard_id = assert(leaderboard_id),
		user_id = assert(user_id),
	})
end

---@param lb_user sea.LeaderboardUser
---@return sea.LeaderboardUser
function LeaderboardsRepo:createLeaderboardUser(lb_user)
	return self.models.leaderboard_users:create(lb_user)
end

---@param lb_user sea.LeaderboardUser
---@return sea.LeaderboardUser
function LeaderboardsRepo:updateLeaderboardUser(lb_user)
	return self.models.leaderboard_users:update(lb_user, {id = assert(lb_user.id)})[1]
end

---@param lb_user sea.LeaderboardUser
---@return integer
function LeaderboardsRepo:getLeaderboardUserRank(lb_user)
	return self.models.leaderboard_users:count({
		leaderboard_id = assert(lb_user.leaderboard_id),
		total_rating__gte = assert(lb_user.total_rating),
	})
end

--------------------------------------------------------------------------------

---@param leaderboard_id integer
---@return sea.LeaderboardDifftable[]
function LeaderboardsRepo:getLeaderboardDifftables(leaderboard_id)
	return self.models.leaderboard_difftables:select({leaderboard_id = assert(leaderboard_id)})
end

---@param leaderboard_difftable sea.LeaderboardDifftable
---@return sea.LeaderboardDifftable
function LeaderboardsRepo:createLeaderboardDifftable(leaderboard_difftable)
	return self.models.leaderboard_difftables:create(leaderboard_difftable)
end

---@param leaderboard_id integer
---@param difftable_id integer
---@return sea.LeaderboardDifftable
function LeaderboardsRepo:deleteLeaderboardDifftable(leaderboard_id, difftable_id)
	return self.models.leaderboard_difftables:delete({
		leaderboard_id = assert(leaderboard_id),
		difftable_id = assert(difftable_id),
	})[1]
end

return LeaderboardsRepo

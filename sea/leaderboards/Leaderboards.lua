local class = require("class")
local LeaderboardsAccess = require("sea.leaderboards.access.LeaderboardsAccess")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local LeaderboardUser = require("sea.leaderboards.LeaderboardUser")

---@class sea.Leaderboards
---@operator call: sea.Leaderboards
local Leaderboards = class()

---@param leaderboards_repo sea.ILeaderboardsRepo
function Leaderboards:new(leaderboards_repo)
	self.leaderboards_repo = leaderboards_repo
	self.leaderboards_access = LeaderboardsAccess()
end

---@param lb sea.Leaderboard
---@param user_id integer
function Leaderboards:updateLeaderboardUser(lb, user_id)
	local repo = self.leaderboards_repo

	local lb_user = repo:getLeaderboardUser(lb.id, user_id)
	if not lb_user then
		lb_user = LeaderboardUser()
		lb_user.leaderboard_id = lb.id
		lb_user.user_id = user_id
		lb_user = repo:createLeaderboardUser(lb_user)
	end

	local chartplays = repo:getBestChartplays(lb, user_id)

	local total_rating = 0
	if lb.scores_comb == "avg" then
		for i = 1, math.min(lb.scores_comb_count, #chartplays) do
			total_rating = total_rating + chartplays[i].rating
		end
		total_rating = total_rating / lb.scores_comb_count
	elseif lb.scores_comb == "exp95" then
		local mul = 1
		for i = 1, math.min(lb.scores_comb_count, #chartplays) do
			total_rating = total_rating + chartplays[i].rating * mul
			mul = mul * 0.95
		end
	end

	lb_user.total_rating = total_rating
	lb_user.rank = repo:getLeaderboardUserRank(lb_user)
	lb_user.updated_at = os.time()
	repo:updateLeaderboardUser(lb_user)
end

---@param chartplay sea.Chartplay
function Leaderboards:addChartplay(chartplay)
	local repo = self.leaderboards_repo

	-- TODO: optimize: cache leaderboards, fast check in lua before sql
	for _, lb in ipairs(repo:getLeaderboards()) do
		if repo:checkChartplay(lb, chartplay) then
			self:updateLeaderboardUser(lb, chartplay.user_id)
		end
	end
end

---@param user sea.User
---@param lb_values sea.Leaderboard
---@return sea.Leaderboard?
---@return string?
function Leaderboards:create(user, lb_values)
	local can, err = self.leaderboards_access:canManage(user)
	if not can then
		return nil, err
	end

	local lb = Leaderboard()

	lb.name = lb_values.name or "?"
	lb.description = ""
	lb.created_at = lb_values.created_at or os.time()
	lb.rating_calc = lb_values.rating_calc or "enps"
	lb.scores_comb = 0
	lb.scores_comb_count = 20

	lb.nearest = lb_values.nearest or "any"
	lb.result = lb_values.result or "fail"
	lb.allow_custom = not not lb_values.allow_custom
	lb.allow_const = not not lb_values.allow_const
	lb.allow_pause = not not lb_values.allow_pause
	lb.allow_reorder = not not lb_values.allow_reorder
	lb.allow_modifiers = not not lb_values.allow_modifiers
	lb.allow_tap_only = not not lb_values.allow_tap_only
	lb.allow_free_timings = not not lb_values.allow_free_timings
	lb.allow_free_healths = not not lb_values.allow_free_healths
	lb.mode = lb_values.mode or "mania"
	lb.rate = lb_values.rate or "any"
	lb.ranked_lists = lb_values.ranked_lists or {}
	lb.chartmeta_inputmode = lb_values.chartmeta_inputmode or {}
	lb.chartdiff_inputmode = lb_values.chartdiff_inputmode or {}

	lb = self.leaderboards_repo:createLeaderboard(lb)

	return lb
end

return Leaderboards

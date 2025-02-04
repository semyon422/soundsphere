local class = require("class")
local LeaderboardsAccess = require("sea.leaderboards.access.LeaderboardsAccess")
local Leaderboard = require("sea.leaderboards.Leaderboard")

---@class sea.Leaderboards
---@operator call: sea.Leaderboards
local Leaderboards = class()

---@param leaderboards_repo sea.ILeaderboardsRepo
function Leaderboards:new(leaderboards_repo)
	self.leaderboards_repo = leaderboards_repo
	self.leaderboards_access = LeaderboardsAccess()
end

---@param chartplay sea.Chartplay
function Leaderboards:addChartplay(chartplay)
	-- update leaderboards
end

---@param user sea.User
---@param leaderboard_values sea.Leaderboard
---@return sea.Leaderboard?
---@return string?
function Leaderboards:create(user, leaderboard_values)
	local can, err = self.leaderboards_access:canManage(user)
	if not can then
		return nil, err
	end

	local leaderboard = Leaderboard()

	leaderboard.name = leaderboard_values.name or "?"
	leaderboard.description = ""
	leaderboard.created_at = os.time()
	leaderboard.rating_calculator = 0
	leaderboard.scores_combiner = 0
	leaderboard.scores_combiner_count = 20
	leaderboard.communities_combiner = 0
	leaderboard.communities_combiner_count = 20

	leaderboard.nearest = "any"
	leaderboard.result = "fail"
	leaderboard.allow_custom = false
	leaderboard.allow_const = false
	leaderboard.allow_pause = true
	leaderboard.allow_reorder = true
	leaderboard.allow_modifiers = false
	leaderboard.allow_tap_only = false
	leaderboard.allow_free_timings = false
	leaderboard.mode = "mania"
	leaderboard.rate = "any"
	leaderboard.ranked_lists = {}
	leaderboard.inputmode = {}

	leaderboard = self.leaderboards_repo:createLeaderboard(leaderboard)

	return leaderboard
end

return Leaderboards

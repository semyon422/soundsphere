local class = require("class")
local table_util = require("table_util")
local LeaderboardsAccess = require("sea.leaderboards.access.LeaderboardsAccess")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local LeaderboardUser = require("sea.leaderboards.LeaderboardUser")
local LeaderboardDifftable = require("sea.leaderboards.LeaderboardDifftable")
local RatingCalc = require("sea.leaderboards.RatingCalc")
local TotalRating = require("sea.leaderboards.TotalRating")

---@class sea.Leaderboards
---@operator call: sea.Leaderboards
local Leaderboards = class()

---@param leaderboards_repo sea.LeaderboardsRepo
function Leaderboards:new(leaderboards_repo)
	self.total_rating = TotalRating()
	self.leaderboards_repo = leaderboards_repo
	self.leaderboards_access = LeaderboardsAccess()
end

---@return sea.Leaderboard[]
function Leaderboards:getLeaderboards()
	return self.leaderboards_repo:getLeaderboards()
end

---@param id integer?
---@return sea.Leaderboard?
function Leaderboards:getLeaderboard(id)
	if not id then
		return
	end
	return self.leaderboards_repo:getLeaderboard(id)
end

---@param lb_id integer
---@param user_id integer
---@return sea.LeaderboardUser?
function Leaderboards:getLeaderboardUser(lb_id, user_id)
	return self.leaderboards_repo:getLeaderboardUser(lb_id, user_id)
end

---@param lb sea.Leaderboard
---@param user_id integer
---@return sea.Chartplayview[]
function Leaderboards:getBestChartplaysFull(lb, user_id)
	return self.leaderboards_repo:getBestChartplaysFull(lb, user_id)
end

---@param chartplay sea.Chartplayview
---@param rating_calc sea.RatingCalc
local function get_rating(chartplay, rating_calc)
	return chartplay[RatingCalc:column(rating_calc)]
end

---@param lb sea.Leaderboard
---@param user_id integer
function Leaderboards:updateLeaderboardUser(lb, user_id)
	local repo = self.leaderboards_repo
	local total_rating = self.total_rating

	local lb_user = repo:getLeaderboardUser(lb.id, user_id)
	if not lb_user then
		lb_user = LeaderboardUser()
		lb_user.leaderboard_id = lb.id
		lb_user.user_id = user_id
		lb_user = repo:createLeaderboardUser(lb_user)
	end

	local chartplays = repo:getBestChartplays(lb, user_id)

	total_rating:calc(chartplays)

	lb_user.total_rating = total_rating:get(lb.rating_calc)
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

	local lb = self.leaderboards_repo:getLeaderboardByName(lb_values.name)
	if lb then
		return nil, "name_taken"
	end

	lb_values.created_at = os.time()

	lb = self.leaderboards_repo:createLeaderboard(lb_values)
	self:updateLeaderboardDifftables(lb.id, lb_values.leaderboard_difftables)

	return lb
end

---@param user sea.User
---@param id integer
---@param lb_values sea.Leaderboard
---@return sea.Leaderboard?
---@return string?
function Leaderboards:update(user, id, lb_values)
	local can, err = self.leaderboards_access:canManage(user)
	if not can then
		return nil, err
	end

	local lb = self.leaderboards_repo:getLeaderboardByName(lb_values.name)
	if lb and lb.id ~= id then
		return nil, "name_taken"
	end

	lb = lb or self.leaderboards_repo:getLeaderboard(id)

	if not lb then
		return nil, "not_found"
	end

	lb_values.id = lb.id

	lb = self.leaderboards_repo:updateLeaderboardFull(lb_values)
	self:updateLeaderboardDifftables(id, lb_values.leaderboard_difftables)

	return lb
end

---@param user sea.User
---@param id integer
---@return true?
---@return string?
function Leaderboards:delete(user, id)
	local can, err = self.leaderboards_access:canManage(user)
	if not can then
		return nil, err
	end

	self.leaderboards_repo:deleteLeaderboard(id)

	return true
end

---@param leaderboard_id integer
---@param lb_dts sea.LeaderboardDifftable[]
---@return true?
---@return string?
function Leaderboards:updateLeaderboardDifftables(leaderboard_id, lb_dts)
	local leaderboard_difftables = self.leaderboards_repo:getLeaderboardDifftables(leaderboard_id)

	local function get_id(ld) return ld.difftable_id end
	local new_difftable_ids, old_difftable_ids = table_util.array_update(
		lb_dts,
		leaderboard_difftables,
		get_id,
		get_id
	)

	for _, difftable_id in ipairs(old_difftable_ids) do
		self.leaderboards_repo:deleteLeaderboardDifftable(leaderboard_id, difftable_id)
	end

	for _, difftable_id in ipairs(new_difftable_ids) do
		local lb_dt = LeaderboardDifftable()
		lb_dt.leaderboard_id = leaderboard_id
		lb_dt.difftable_id = difftable_id
		self.leaderboards_repo:createLeaderboardDifftable(lb_dt)
	end
end

return Leaderboards

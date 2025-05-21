local http_util = require("web.http.util")
local math_util = require("math_util")
local IResource = require("web.framework.IResource")

---@class sea.RankingsResource: web.IResource
---@operator call: sea.RankingsResource
local RankingsResource = IResource + {}

RankingsResource.routes = {
	{"/rankings", {
		GET = "getRankings",
	}},
}

RankingsResource.users_per_page = 50

RankingsResource.ranking_type_tabs = {
	{name = "Rating", id = "rating"},
	-- {name = "Accuracy", id = "accuracy"},
	{name = "Charts", id = "charts"},
	{name = "Play count", id = "play_count"},
	{name = "Play time", id = "play_time"},
	-- {name = "Social rating", id = "social_rating"},
}

---@param users sea.Users
---@param leaderboards sea.Leaderboards
---@param views web.Views
function RankingsResource:new(users, leaderboards, views)
	self.users = users
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function RankingsResource:getRankings(req, res, ctx)
	local query = ctx.query

	local page = math.floor(tonumber(query.page) or 1)
	local leaderboard_id = math.max(tonumber(query.leaderboard_id) or 1)

	ctx.leaderboard_id = leaderboard_id

	---@type sea.RankingType
	local ranking_type = query.ranking_type or "rating"

	local per_page = self.users_per_page
	ctx.users_per_page = per_page
	if ranking_type == "rating" then
		local lbs = self.leaderboards
		ctx.leaderboards = lbs:getLeaderboards()
		ctx.leaderboard = lbs:getLeaderboard(leaderboard_id)
		ctx.pages_count = math.ceil(lbs:getLeaderboardUsersCount(leaderboard_id) / per_page)
		page = math.min(page, ctx.pages_count)
		ctx.leaderboard_users = lbs:getLeaderboardUsersFull(leaderboard_id, per_page, (page - 1) * per_page)
	else
		local order = "chartplays_count"
		if ranking_type == "charts" then
			order = "chartmetas_count"
		elseif ranking_type == "play_time" then
			order = "play_time"
		end
		ctx.pages_count = math.ceil(self.users:getUsersCount() / per_page)
		page = math.min(page, ctx.pages_count)
		ctx.users = self.users:getUsers(order, per_page, (page - 1) * per_page)
	end

	ctx.page_num = page

	-- local first = (page - 1) * self.users_per_page
	-- local last = math.min(first + self.users_per_page, #self.testUsers)

	ctx.ranking_type_tabs = self.ranking_type_tabs

	ctx.ranking_type = ranking_type
	ctx.display_leaderboards = ranking_type == "rating"

	self.views:render_send(res, "sea/leaderboards/http/rankings.etlua", ctx, true)
end

return RankingsResource

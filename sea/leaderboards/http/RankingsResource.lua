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

RankingsResource.maxUsersPerPage = 50

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
	local query = http_util.decode_query_string(ctx.parsed_uri.query)
	local page_count = 1

	local page = math.floor(math_util.clamp(tonumber(query.page) or 1, 1, page_count)) or 1
	local leaderboard_id = tonumber(query.leaderboard_id) or 1

	---@type sea.RankingType
	local ranking_type = query.ranking_type or "rating"

	if ranking_type == "rating" then
		ctx.leaderboards = self.leaderboards:getLeaderboards()
		ctx.leaderboard = self.leaderboards:getLeaderboard(leaderboard_id)
		ctx.leaderboard_users = self.leaderboards:getLeaderboardUsersFull(leaderboard_id)
	else
		ctx.users = self.users:getUsers()
	end
	-- local first = (page - 1) * self.maxUsersPerPage
	-- local last = math.min(first + self.maxUsersPerPage, #self.testUsers)

	ctx.page_count = page_count
	ctx.ranking_type_tabs = self.ranking_type_tabs
	ctx.query = {
		page = page,
		leaderboard_id = leaderboard_id,
		ranking_type = ranking_type,
	}

	ctx.ranking_type = ranking_type
	ctx.display_leaderboards = ranking_type == "rating"

	self.views:render_send(res, "sea/leaderboards/http/rankings.etlua", ctx, true)
end

return RankingsResource

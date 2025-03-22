local IResource = require("web.framework.IResource")

---@class sea.LeaderboardResource: web.IResource
---@operator call: sea.LeaderboardResource
local LeaderboardResource = IResource + {}

LeaderboardResource.uri = "/leaderboards/:leaderboard_id"

---@param leaderboards sea.Leaderboards
---@param views web.Views
function LeaderboardResource:new(leaderboards, views)
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardResource:GET(req, res, ctx)
	ctx.leaderboard = self.leaderboards:getLeaderboard(tonumber(ctx.path_params.leaderboard_id))
	if not ctx.leaderboard then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/leaderboards/http/leaderboard.etlua", ctx, true)
end

return LeaderboardResource

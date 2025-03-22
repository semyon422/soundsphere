local IResource = require("web.framework.IResource")

---@class sea.LeaderboardEditResource: web.IResource
---@operator call: sea.LeaderboardEditResource
local LeaderboardEditResource = IResource + {}

LeaderboardEditResource.uri = "/leaderboards/:leaderboard_id/edit"

---@param leaderboards sea.Leaderboards
---@param views web.Views
function LeaderboardEditResource:new(leaderboards, views)
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardEditResource:GET(req, res, ctx)
	ctx.leaderboard = self.leaderboards:getLeaderboard(tonumber(ctx.path_params.leaderboard_id))
	if not ctx.leaderboard then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/leaderboards/http/leaderboard_edit.etlua", ctx, true)
end

return LeaderboardEditResource

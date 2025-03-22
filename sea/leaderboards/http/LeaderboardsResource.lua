local IResource = require("web.framework.IResource")

---@class sea.LeaderboardsResource: web.IResource
---@operator call: sea.LeaderboardsResource
local LeaderboardsResource = IResource + {}

LeaderboardsResource.uri = "/leaderboards"

---@param leaderboards sea.Leaderboards
---@param views web.Views
function LeaderboardsResource:new(leaderboards, views)
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardsResource:GET(req, res, ctx)
	ctx.leaderboards = self.leaderboards:getLeaderboards()
	self.views:render_send(res, "sea/leaderboards/http/leaderboards.etlua", ctx, true)
end

return LeaderboardsResource

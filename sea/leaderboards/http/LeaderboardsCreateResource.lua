local IResource = require("web.framework.IResource")

---@class sea.LeaderboardsCreateResource: web.IResource
---@operator call: sea.LeaderboardsCreateResource
local LeaderboardsCreateResource = IResource + {}

LeaderboardsCreateResource.uri = "/leaderboards/create"

---@param leaderboards sea.Leaderboards
---@param views web.Views
function LeaderboardsCreateResource:new(leaderboards, views)
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardsCreateResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/leaderboards/http/leaderboards_create.etlua", ctx, true)
end

return LeaderboardsCreateResource

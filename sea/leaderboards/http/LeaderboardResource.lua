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
	local leaderboard_id = tonumber(ctx.path_params.leaderboard_id)
	ctx.leaderboard = self.leaderboards:getLeaderboard(leaderboard_id)
	if not ctx.leaderboard then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/leaderboards/http/leaderboard.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardResource:DELETE(req, res, ctx)
	local leaderboard_id = tonumber(ctx.path_params.leaderboard_id)

	if leaderboard_id then
		self.leaderboards:delete(ctx.session_user, leaderboard_id)
	end

	res.status = 302
	res.headers:set("HX-Location", "/leaderboards")
end

return LeaderboardResource

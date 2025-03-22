local IResource = require("web.framework.IResource")

---@class sea.TeamEditResource: web.IResource
---@operator call: sea.TeamEditResource
local TeamEditResource = IResource + {}

TeamEditResource.uri = "/teams/:team_id/edit"

---@param teams sea.Teams
---@param views web.Views
function TeamEditResource:new(teams, views)
	self.teams = teams
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:GET(req, res, ctx)
	ctx.team = self.teams:getTeam(tonumber(ctx.path_params.team_id))
	if not ctx.team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

return TeamEditResource

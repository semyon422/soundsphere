local IResource = require("web.framework.IResource")

---@class sea.TeamsResource: web.IResource
---@operator call: sea.TeamsResource
local TeamsResource = IResource + {}

TeamsResource.routes = {
	{"/teams", {
		GET = "getTeams",
	}},
	{"/teams/create", {
		GET = "getCreateTeam",
	}},
}

---@param teams sea.Teams
---@param views web.Views
function TeamsResource:new(teams, views)
	self.teams = teams
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamsResource:getTeams(req, res, ctx)
	ctx.teams = self.teams:getTeams()
	self.views:render_send(res, "sea/teams/http/teams.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamsResource:getCreateTeam(req, res, ctx)
	self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
end

return TeamsResource

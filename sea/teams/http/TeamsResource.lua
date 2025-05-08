local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")

---@class sea.TeamsResource: web.IResource
---@operator call: sea.TeamsResource
local TeamsResource = IResource + {}

TeamsResource.routes = {
	{"/teams", {
		GET = "getTeams",
	}},
	{"/teams/create", {
		GET = "getCreateTeam",
		POST = "createTeam"
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
	ctx.can_create = self.teams:canCreate(ctx.session_user)
	ctx.main_container_type = "vertically_centered"
	self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamsResource:createTeam(req, res, ctx)
	ctx.can_create = self.teams:canCreate(ctx.session_user)
	ctx.main_container_type = "vertically_centered"

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		ctx.creation_error = err
		self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
		return
	end

	---@cast body_params {[string]: string}
	local name = body_params.name
	local alias = body_params.alias
	local type = body_params.type

	local team, err = self.teams:create(ctx.session_user, name, alias, type)

	if not team then
		ctx.creation_error = err
		self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team.id))
end

return TeamsResource

local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local Team = require("sea.teams.Team")

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
	ctx.can_create = self.teams.teams_access:canCreate(ctx.session_user, os.time())
	ctx.main_container_type = "vertically_centered"
	self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamsResource:createTeam(req, res, ctx)
	ctx.can_create = self.teams.teams_access:canCreate(ctx.session_user, os.time())
	ctx.main_container_type = "vertically_centered"

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		ctx.creation_error = err
		self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
		return
	end

	local team_values = Team()
	team_values.name = body_params.name
	team_values.alias = body_params.alias
	team_values.type = body_params.type
	team_values.description = ""

	local ok, err = team_values:validate()
	if not ok then
		---@cast err -?
		ctx.creation_error = table.concat(err, ", ")
		self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
	end

	local team, err = self.teams:create(ctx.session_user, team_values)

	if not team then
		ctx.creation_error = err
		self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team.id))
end

return TeamsResource

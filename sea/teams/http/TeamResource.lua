local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.TeamResource: web.IResource
---@operator call: sea.TeamResource
local TeamResource = IResource + {}

TeamResource.routes = {
	{"/teams/:team_id", {
		GET = "getTeam",
	}},
	{"/teams/:team_id/update_description", {
		POST = "updateDescription",
	}},
	{"/teams/:team_id/edit", {
		GET = "getEditTeam",
	}},
}

TeamResource.descriptionLimit = 4096

---@param teams sea.Teams
---@param views web.Views
function TeamResource:new(teams, views)
	self.teams = teams
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:updateDescription(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 400
		return
	end

	if not self.teams:canUpdate(ctx.session_user, team) then
		res.status = 403
		return
	end

	---@type {[string]: any}?, string?
	local description, _ = http_util.get_json(req)

	if not description then
		res.status = 400
		return
	end

	local encoded = json.encode(description)

	if encoded:len() > self.descriptionLimit then
		res.status = 400
		return
	end

	if not description.ops then
		encoded = ""
	end

	if #description.ops == 1 and description.ops[1].insert == "\n" then
		encoded = ""
	end

	team.description = encoded
	self.teams:update(ctx.session_user, team)
	res.status = 200
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getTeam(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)
	ctx.team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not ctx.team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local can_update = self.teams:canUpdate(ctx.session_user, ctx.team)
	ctx.can_update = can_update
	ctx.edit_description = can_update and query.edit_description == "true"

	ctx.ignore_main_container = true
	self.views:render_send(res, "sea/teams/http/team.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getEditTeam(req, res, ctx)
	ctx.team = self.teams:getTeam(tonumber(ctx.path_params.team_id))
	if not ctx.team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

return TeamResource

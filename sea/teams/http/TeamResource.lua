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
	{"/teams/:team_id/edit", {
		GET = "redirectToSettings",
	}},
	{"/teams/:team_id/edit/:tab", {
		GET = "getEditTeam",
	}},
	{"/teams/:team_id/join", {
		POST = "join",
	}},
	{"/teams/:team_id/leave", {
		POST = "leave",
	}},
	{"/teams/:team_id/cancel_join_request", {
		POST = "cancelJoinRequest",
	}},
	{"/teams/:team_id/accept_join_request/:user_id", {
		POST = "acceptJoinRequest",
	}},
	{"/teams/:team_id/revoke_join_request/:user_id", {
		POST = "revokeJoinRequest",
	}},
	{"/teams/:team_id/kick_user/:user_id", {
		POST = "kickUser",
	}},
	{"/teams/:team_id/update_description", {
		POST = "updateDescription",
	}},
	{"/teams/:team_id/update_settings", {
		POST = "updateSettings",
	}},
}

---@param teams sea.Teams
---@param views web.Views
function TeamResource:new(teams, views)
	self.teams = teams
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getTeam(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	if team.owner_id == ctx.session_user.id then
		ctx.can_manage = true
	end

	local can_update = self.teams:canUpdate(ctx.session_user, team)

	ctx.team = team
	ctx.team_user = self.teams:getTeamUser(ctx.session_user, team)
	ctx.team_users = self.teams:getTeamUsersFull(team.id)
	ctx.can_update = can_update
	ctx.edit_description = can_update and query.edit_description == "true"

	ctx.ignore_main_container = true
	self.views:render_send(res, "sea/teams/http/team.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getEditTeam(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))
	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	if not self.teams:canUpdate(ctx.session_user, team) then
		res.status = 403
		return
	end

	local tab = ctx.path_params.tab

	if tab == "requests" then
		ctx.request_users = self.teams:getRequestTeamUsersFull(ctx.session_user, team)
	elseif tab == "members" then
		ctx.users = self.teams:getTeamUsersFull(team.id)
	end

	ctx.team = team
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:redirectToSettings(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	res.status = 302
	res.headers:set("Location", ("/teams/%i/edit/settings"):format(team_id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:join(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 400
		return
	end

	local user, err = self.teams:join(ctx.session_user, team)

	if not user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team.id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:leave(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 400
		return
	end

	local user, err = self.teams:leave(ctx.session_user, team)

	if not user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team.id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:kickUser(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:kickUser(ctx.session_user, team_id, user_id)

	if not team_user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i/edit/members"):format(team_id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:cancelJoinRequest(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)

	if not team_id then
		res.status = 400
		return
	end

	local user, err = self.teams:revokeJoinRequest(ctx.session_user, team_id, ctx.session_user.id)

	if not user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team_id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:acceptJoinRequest(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:acceptJoinRequest(ctx.session_user, team_id, user_id)

	if not team_user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i/edit/requests"):format(team_id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:revokeJoinRequest(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:revokeJoinRequest(ctx.session_user, team_id, user_id)

	if not team_user then
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i/edit/requests"):format(team_id))
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

	if not description.ops then
		encoded = ""
	end

	if #description.ops == 1 and description.ops[1].insert == "\n" then
		encoded = ""
	end

	team.description = encoded
	local success, err = team:validate()

	if not success then
		res.status = 400
		res:send(err)
		return
	end

	self.teams:update(ctx.session_user, team)
	res.status = 200
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:updateSettings(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		res:send(err)
		return
	end

	local team_id = tonumber(ctx.path_params.team_id)
	local team = self.teams:getTeam(team_id)

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	team.name = body_params.name
	team.alias = body_params.alias
	team.type = body_params.type

	local success, err = team:validate()

	if not success then
		res.status = 400
		res:send(err)
		return
	end

	self.teams:update(ctx.session_user, team)
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

return TeamResource

local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local json = require("web.json")
local types = require("sea.shared.types")
local Team = require("sea.teams.Team")

---@class sea.TeamResource: web.IResource
---@operator call: sea.TeamResource
local TeamResource = IResource + {}

TeamResource.routes = {
	{"/teams/user_team/:user_id", {
		GET = "redirectToUserTeam",
	}},
	{"/teams/:team_id", {
		GET = "getTeamPage",
	}},
	{"/teams/:team_id/join", {
		POST = "join",
	}},
	{"/teams/:team_id/leave", {
		POST = "leave",
	}},
	{"/teams/:team_id/accept_join_invite", {
		POST = "acceptJoinInvite",
	}},
	{"/teams/:team_id/cancel_join_request", {
		POST = "cancelJoinRequest",
	}},
	{"/teams/:team_id/update_description", {
		POST = "updateDescription",
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
function TeamResource:getTeamPage(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	if team.owner_id == ctx.session_user.id then
		ctx.can_manage = true
	end

	local can_update = self.teams.teams_access:canUpdate(ctx.session_user, team)

	local team_users = self.teams:getTeamUsers(team.id)
	ctx.team_users = team_users and self.teams:preloadUsers(team_users)

	if not ctx.session_user:isAnon() then
		ctx.team_user = self.teams:getTeamUser(ctx.session_user, team)
	end

	ctx.team = team
	ctx.can_update = can_update
	ctx.edit_description = can_update and ctx.query.edit_description == "true"

	ctx.main_container_type = "none"
	self.views:render_send(res, "sea/teams/http/team.etlua", ctx, true)
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
		---@cast err string
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
function TeamResource:acceptJoinInvite(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 400
		return
	end

	local team_user, err = self.teams:acceptJoinInvite(ctx.session_user, team)

	if not team_user then
		---@cast err string
		res.status = 400
		res:send(err)
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
		---@cast err string
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
function TeamResource:cancelJoinRequest(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)

	if not team_id then
		res.status = 400
		return
	end

	local user, err = self.teams:revokeJoinRequest(ctx.session_user, team_id, ctx.session_user.id)

	if not user then
		---@cast err string
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
function TeamResource:updateDescription(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 400
		return
	end

	if not self.teams.teams_access:canUpdate(ctx.session_user, team) then
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

	local ok, err = types.description(encoded)
	if not ok then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	local team_values = Team()
	team_values.description = encoded

	self.teams:update(ctx.session_user, team.id, team_values)
	res.status = 200
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:redirectToUserTeam(req, res, ctx)
	local user_id = tonumber(ctx.path_params.user_id)

	if not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:getUserAcceptedTeamUsers(user_id)

	if not team_user then
		res.status = 400
		return
	end

	res.status = 302
	res.headers:set("HX-Location", ("/teams/%i"):format(team_user[1].team_id))
end

return TeamResource

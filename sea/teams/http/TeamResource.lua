local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.TeamResource: web.IResource
---@operator call: sea.TeamResource
local TeamResource = IResource + {}

TeamResource.routes = {
	{"/teams/:team_id", {
		GET = "getTeamPage",
	}},
	{"/teams/:team_id/update_settings", {
		GET = "getSettings",
		POST = "updateSettings",
	}},
	{"/teams/:team_id/members", {
		GET = "getMembers",
	}},
	{"/teams/:team_id/requests", {
		GET = "getRequests",
	}},
	{"/teams/:team_id/invite_user", {
		GET = "getInvites",
		POST = "inviteUser"
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
	{"/teams/:team_id/transfer_owner/:user_id", {
		POST = "transferOwner",
	}},
	{"/teams/:team_id/revoke_join_invite/:user_id", {
		POST = "revokeJoinInvite"
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

---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:notFoundPage(res, ctx)
	res.status = 404
	self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
end

---@param team sea.Team
---@param res web.IResponse
---@param ctx sea.RequestContext
---@return boolean redirected
function TeamResource:redirectNotOwners(team, ctx, res)
	if not self.teams:canUpdate(ctx.session_user, team) then
		res.status = 302
		res.headers:set("Location", ("/teams/%i"):format(team.id))
		return true
	end
	return false
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getSettings(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	ctx.tab = "settings"
	ctx.team = team
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getMembers(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	---@cast team sea.Team
	ctx.users = self.teams:getTeamUsersFull(team.id)

	ctx.team = team
	ctx.tab = "members"
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getRequests(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	---@cast team sea.Team
	ctx.request_users = self.teams:getRequestTeamUsersFull(ctx.session_user, team)

	ctx.team = team
	ctx.tab = "requests"
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:getInvites(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	---@cast team sea.Team
	ctx.request_users = self.teams:getRequestTeamUsersFull(ctx.session_user, team)

	ctx.team = team
	ctx.tab = "invites"
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:updateSettings(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	ctx.team = team
	ctx.tab = "settings"

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		ctx.error = err
		self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
		return
	end

	team.name = body_params.name
	team.alias = body_params.alias
	team.type = body_params.type

	local success, err = team:validate()

	if success then
		self.teams:update(ctx.session_user, team)
		ctx.settings_updated = true
	else
		---@cast err string[]
		ctx.error = "Errors: " .. table.concat(err, ", ")
	end

	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end


---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamResource:inviteUser(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	ctx.team = team
	ctx.tab = "invites"

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	local username = body_params.username ---@type string

	if username == "404" then
		ctx.user_not_found_error = ("User '%s' not found"):format(username)
	elseif username == "200" then
		ctx.user_invited_message = ("Successfully sent an invitation to '%s'"):format(username)
	end

	self:getInvites(req, res, ctx)
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
function TeamResource:kickUser(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:kickUser(ctx.session_user, team_id, user_id)

	if not team_user then
		---@cast err string
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
function TeamResource:acceptJoinRequest(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team_user, err = self.teams:acceptJoinRequest(ctx.session_user, team_id, user_id)

	if not team_user then
		---@cast err string
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
		---@cast err string
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
function TeamResource:transferOwner(req, res, ctx)
	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		return
	end

	local team, err = self.teams:transferOwner(ctx.session_user, team_id, user_id)

	if not team then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	res.status = 302
	res.headers:set("Location", ("/teams/%i"):format(team_id))
	return team
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
		---@cast err string[]
		res.status = 400
		res:send(table.concat(err, ", "))
		return
	end

	self.teams:update(ctx.session_user, team)
	res.status = 200
end

return TeamResource

local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")

---@class sea.TeamEditResource: web.IResource
---@operator call: sea.TeamEditResource
local TeamEditResource = IResource + {}

TeamEditResource.routes = {
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
}

---@param teams sea.Teams
---@param views web.Views
function TeamEditResource:new(teams, users, views)
	self.teams = teams
	self.users = users
	self.views = views
end

---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:notFoundPage(res, ctx)
	res.status = 404
	self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
end

---@param team sea.Team
---@param res web.IResponse
---@param ctx sea.RequestContext
---@return boolean redirected
function TeamEditResource:redirectNotOwners(team, ctx, res)
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
function TeamEditResource:getSettings(req, res, ctx)
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
function TeamEditResource:getMembers(req, res, ctx)
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
function TeamEditResource:getRequests(req, res, ctx)
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
function TeamEditResource:getInvites(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		self:notFoundPage(res, ctx)
		return
	end
	if self:redirectNotOwners(team, ctx, res) then
		return
	end

	---@cast team sea.Team
	ctx.invite_users = self.teams:getInviteTeamUsers(ctx.session_user, team)

	ctx.team = team
	ctx.tab = "invites"
	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:updateSettings(req, res, ctx)
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
function TeamEditResource:inviteUser(req, res, ctx)
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
function TeamEditResource:kickUser(req, res, ctx)
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
function TeamEditResource:acceptJoinRequest(req, res, ctx)
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
function TeamEditResource:revokeJoinRequest(req, res, ctx)
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
function TeamEditResource:transferOwner(req, res, ctx)
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

return TeamEditResource

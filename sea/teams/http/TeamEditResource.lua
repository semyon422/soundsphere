local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")

---@class sea.TeamEditResource: web.IResource
---@operator call: sea.TeamEditResource
local TeamEditResource = IResource + {}

TeamEditResource.routes = {
	{"/teams/:team_id/edit", {
		GET = "getEditPage"
	}},
	{"/teams/:team_id/edit/", {
		GET = "getEditPage"
	}},
	{"/teams/:team_id/edit/:tab", {
		GET = "getEditPage"
	}},
	{"/teams/:team_id/update_settings", {
		POST = "updateSettings",
	}},
	{"/teams/:team_id/invite_user", {
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
---@param users sea.Users
---@param views web.Views
function TeamEditResource:new(teams, users, views)
	self.teams = teams
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:getEditPage(req, res, ctx)
	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	if not self.teams:canUpdate(ctx.session_user, team) then
		res.status = 302
		res.headers:set("Location", ("/teams/%i"):format(team.id))
		return
	end

	ctx.tab = ctx.tab or ctx.path_params.tab or "settings"
	ctx.team = team

	if ctx.tab == "members" then
		local team_users = self.teams:getTeamUsers(team.id)
		ctx.users = team_users and self.teams:preloadUsers(team_users)
	elseif ctx.tab == "requests" then
		local request_users = self.teams:getRequestTeamUsers(ctx.session_user, team)
		ctx.request_users = request_users and self.teams:preloadUsers(request_users)
	elseif ctx.tab == "invites" then
		local invite_users = self.teams:getInviteTeamUsers(ctx.session_user, team)
		ctx.invite_users = invite_users and self.teams:preloadUsers(invite_users)
	end

	self.views:render_send(res, "sea/teams/http/team_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:updateSettings(req, res, ctx)
	ctx.tab = "settings"

	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		ctx.settings_error = err
		self:getEditPage(req, res, ctx)
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
		ctx.settings_error = "Errors: " .. table.concat(err, ", ")
	end

	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:inviteUser(req, res, ctx)
	ctx.tab = "invites"

	local team = self.teams:getTeam(tonumber(ctx.path_params.team_id))

	if not team then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err string
		ctx.invitation_error = err
		self:getEditPage(req, res, ctx)
		return
	end

	local username = body_params.username ---@type string
	local user = self.users:findUserByName(username)

	if not user then
		ctx.invitation_error = ("User '%s' not found"):format(username)
		self:getEditPage(req, res, ctx)
		return
	end

	local team_user, err = self.teams:inviteUser(ctx.session_user, team, user.id)

	if not team_user then
		ctx.invitation_error = ("Failed to invite '%s'. %s"):format(username, err)
	else
		local invite_users = self.teams:getInviteTeamUsers(ctx.session_user, team)
		ctx.invite_users = invite_users and self.teams:preloadUsers(invite_users)
		ctx.invitation_success  = ("Successfully sent an invitation to '%s'"):format(username)
	end

	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:revokeJoinInvite(req, res, ctx)
	ctx.tab = "invites"

	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 400
		res:send("team or user does not exist")
		return
	end

	self.teams:revokeJoinInvite(ctx.session_user, team_id, user_id)
	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:kickUser(req, res, ctx)
	ctx.tab = "members"

	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local team_user, err = self.teams:kickUser(ctx.session_user, team_id, user_id)

	if not team_user then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:acceptJoinRequest(req, res, ctx)
	ctx.tab = "requests"

	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local team_user, err = self.teams:acceptJoinRequest(ctx.session_user, team_id, user_id)

	if not team_user then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:revokeJoinRequest(req, res, ctx)
	ctx.tab = "requests"

	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local team_user, err = self.teams:revokeJoinRequest(ctx.session_user, team_id, user_id)

	if not team_user then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	self:getEditPage(req, res, ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamEditResource:transferOwner(req, res, ctx)
	ctx.tab = "members"

	local team_id = tonumber(ctx.path_params.team_id)
	local user_id = tonumber(ctx.path_params.user_id)

	if not team_id or not user_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local team, err = self.teams:transferOwner(ctx.session_user, team_id, user_id)

	if not team then
		---@cast err string
		res.status = 400
		res:send(err)
		return
	end

	self:getEditPage(req, res, ctx)
end

return TeamEditResource

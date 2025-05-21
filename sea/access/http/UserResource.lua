local IResource = require("web.framework.IResource")
local UserPage = require("sea.access.http.UserPage")
local UserSettingsPage = require("sea.access.http.UserSettingsPage")
local UserUpdate = require("sea.access.UserUpdate")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.UserResource: web.IResource
---@operator call: sea.UserResource
local UserResource = IResource + {}

UserResource.routes = {
	{"/users/update_email", {
		GET = "getUpdateEmail",
		POST = "updateEmail",
	}},
	{"/users/update_password", {
		GET = "getUpdatePassword",
		POST = "updatePassword",
	}},
	{"/users/:user_id", {
		GET = "getUser",
	}},
	{"/users/:user_id/update_description", {
		POST = "updateDescription",
	}},
	{"/users/:user_id/sessions", {
		GET = "getUserSessions",
	}},
	{"/users/:user_id/settings", {
		GET = "getUserSettings",
		POST = "updateSettings",
	}},
	{"/users/:user_id/teams", {
		GET = "getUserTeams",
	}},
}

---@param users sea.Users
---@param leaderboards sea.Leaderboards
---@param views web.Views
function UserResource:new(users, leaderboards, views)
	self.users = users
	self.leaderboards = leaderboards
	self.views = views

	self.testActivity = {
		["21-03-2025"] = 30,
		["24-03-2025"] = 40,
		["25-03-2025"] = 10,
	}
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUser(req, res, ctx)
	local user = self.users:getUser(tonumber(ctx.path_params.user_id))

	if user:isAnon() then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local leaderboard_id = tonumber(ctx.query.lb) or 1
	ctx.leaderboard = assert(self.leaderboards:getLeaderboard(leaderboard_id))
	ctx.leaderboard_user = self.leaderboards:getLeaderboardUser(leaderboard_id, user.id)

	local page = UserPage(self.users.users_access, ctx.session_user, user, self.leaderboards)
	page:setActivity(self.testActivity)

	ctx.page = page
	ctx.user = user

	ctx.query.scores = ctx.query.scores or "top"

	ctx.general_stats = page:getGeneralStats(user.id)

	ctx.main_container_type = "none"
	ctx.edit_description = page:canUpdate() and ctx.query.edit_description == "true"
	ctx.leaderboards = self.leaderboards:getLeaderboards()
	ctx.scores, ctx.total_rating = page:getScores(ctx.leaderboard, user.id, ctx.query.scores)

	self.views:render_send(res, "sea/access/http/user.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:updateDescription(req, res, ctx)
	local user = self.users:getUser(tonumber(ctx.path_params.user_id))
	local page = UserPage(self.users.users_access, ctx.session_user, user)

	if not page:canUpdate() then
		res.status = 403
		res:send("forbidden")
		return
	end

	---@type {[string]: any}?, string?
	local description, _ = http_util.get_json(req)

	if not description then
		res.status = 400
		res:send("invalid json")
		return
	end

	local encoded = json.encode(description)

	if not description.ops then
		encoded = ""
	end

	if #description.ops == 1 and description.ops[1].insert == "\n" then
		encoded = ""
	end

	local user_update = UserUpdate()
	user_update.id = user.id
	user_update.description = encoded

	local user, err = self.users:updateUser(user, user_update, ctx.time)

	if not user then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	res.status = 200
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserSessions(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_sessions.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserSettings(req, res, ctx)
	ctx.user = self.users:getUser(tonumber(ctx.path_params.user_id))

	local page = UserSettingsPage(ctx.session_user, ctx.user)
	ctx.page = page

	if not page:canUpdate() then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	ctx.main_container_type = "vertically_centered"
	self.views:render_send(res, "sea/access/http/user_settings.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUpdateEmail(req, res, ctx)
	if not self.users.users_access:canUpdateSelf(ctx.session_user, ctx.session_user, ctx.time) then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	ctx.main_container_type = "vertically_centered"
	self.views:render_send(res, "sea/access/http/user_update_email.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUpdatePassword(req, res, ctx)
	if not self.users.users_access:canUpdateSelf(ctx.session_user, ctx.session_user, ctx.time) then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	ctx.main_container_type = "vertically_centered"
	self.views:render_send(res, "sea/access/http/user_update_password.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserTeams(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_teams.etlua", ctx, true)
end

---@param str string?
---@return integer
local function hex_to_integer(str)
	if not str then
		return 0
	end
	return tonumber(str:sub(2, #str), 16) or 0
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:updateSettings(req, res, ctx)
	local user_id = tonumber(ctx.path_params.user_id)
	if not user_id then
		res.status = 404
		return
	end

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	---@type sea.UserUpdate
	local user_update = UserUpdate()
	user_update.id = user_id
	user_update.name = body_params.name
	user_update.discord = body_params.discord
	user_update.banner = body_params.banner_url
	user_update.avatar = body_params.avatar_url
	user_update.enable_gradient = body_params.enable_gradient == "on"
	user_update.color_left = hex_to_integer(body_params.color_left)
	user_update.color_right = hex_to_integer(body_params.color_right)

	local ok, errs = user_update:validate()

	if not ok then
		---@cast errs -?
		res.status = 400
		res:send(table.concat(errs, ", "))
		return
	end

	local user, err = self.users:updateUser(ctx.session_user, user_update, ctx.time)

	if not user then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	res.headers:set("HX-Location", ("/users/%i/settings"):format(user_id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:updateEmail(req, res, ctx)
	if not self.users.users_access:canUpdateSelf(ctx.session_user, ctx.session_user, ctx.time) then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	local current_password = body_params.current_password ---@type string?
	local new_email = body_params.new_email ---@type string?

	if not current_password or not new_email then
		res.status = 400
		res:send("invalid body params")
		return
	end

	local user, err = self.users:updateEmail(ctx.session_user, current_password, new_email, ctx.time)

	if not user then
		ctx.main_container_type = "vertically_centered"
		ctx.update_email_error = err
		self.views:render_send(res, "sea/access/http/user_update_email.etlua", ctx, true)
		return
	end

	res.headers:set("HX-Location", ("/users/%i/settings"):format(ctx.session_user.id))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:updatePassword(req, res, ctx)
	if not self.users.users_access:canUpdateSelf(ctx.session_user, ctx.session_user, ctx.time) then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local body_params, err = http_util.get_form(req)
	if not body_params then
		---@cast err -?
		res.status = 400
		res:send(err)
		return
	end

	local current_password = body_params.current_password ---@type string?
	local new_password = body_params.new_password ---@type string?
	local confirm_new_password = body_params.confirm_new_password ---@type string?

	if not current_password or not new_password or not confirm_new_password then
		ctx.main_container_type = "vertically_centered"
		ctx.update_password_error = "invalid body params"
		self.views:render_send(res, "sea/access/http/user_update_password.etlua", ctx, true)
		return
	end

	if confirm_new_password ~= new_password then
		ctx.main_container_type = "vertically_centered"
		ctx.update_password_error = "new passwords don't match"
		self.views:render_send(res, "sea/access/http/user_update_password.etlua", ctx, true)
		return
	end

	local user, err = self.users:updatePassword(ctx.session_user, current_password, new_password, ctx.time)

	if not user then
		ctx.main_container_type = "vertically_centered"
		ctx.update_password_error = err
		self.views:render_send(res, "sea/access/http/user_update_password.etlua", ctx, true)
		return
	end

	res.headers:set("HX-Location", ("/users/%i/settings"):format(ctx.session_user.id))
end

return UserResource

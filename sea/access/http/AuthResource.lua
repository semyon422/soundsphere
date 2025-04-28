local http_util = require("web.http.util")
local json = require("web.json")
local IResource = require("web.framework.IResource")
local UserInsecure = require("sea.access.UserInsecure")

---@class sea.AuthResource: web.IResource
---@operator call: sea.AuthResource
local AuthResource = IResource + {}

AuthResource.routes = {
	{"/login", {
		GET = "getLogin",
		POST = "login",
	}},
	{"/api/v2/auth/login", {
		POST = "loginJson",
	}},
	{"/logout", {
		POST = "logout",
	}},
	{"/register", {
		GET = "getRegister",
		POST = "register",
	}},
}

---@param sessions web.Sessions
---@param users sea.Users
---@param views web.Views
function AuthResource:new(sessions, users, views)
	self.sessions = sessions
	self.users = users
	self.views = views
end

---@param recaptcha web.Recaptcha
---@param login_enabled boolean
---@param register_enabled boolean
function AuthResource:setRecaptcha(recaptcha, login_enabled, register_enabled)
	self.recaptcha = recaptcha
	self.is_login_captcha_enabled = login_enabled
	self.is_register_captcha_enabled = register_enabled
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:getLogin(req, res, ctx)
	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_login_captcha_enabled = self.is_login_captcha_enabled

	self.views:render_send(res, "sea/access/http/login.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:login(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local user = UserInsecure()
	user.email = body_params.email
	user.password = body_params.password

	ctx.user = user

	local valid, errs = user:validateLogin()
	if not valid then
		ctx.errors = errs
		self.views:render_send(res, "sea/access/http/login.etlua", ctx, true)
		return
	end

	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_login_captcha_enabled = self.is_login_captcha_enabled

	if self.is_login_captcha_enabled then
		local ok, err = self.recaptcha:verify(ctx.ip, body_params, "login")
		if not ok then
			ctx.errors = {err}
			self.views:render_send(res, "sea/access/http/login.etlua", ctx, true)
			return
		end
	end

	local su, err = self.users:login(ctx.session_user, ctx.ip, ctx.time, user)

	if not su then
		ctx.errors = {err}
		self.views:render_send(res, "sea/access/http/login.etlua", ctx, true)
		return
	end

	self.sessions:set(res.headers, {id = su.session.id})

	res.status = 302
	res.headers:set("Location", "/")
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:loginJson(req, res, ctx)
	local body_params, err = http_util.get_json(req)
	if not body_params then
		res.status = 400
		res:send(assert(err))
		return
	end

	local user = UserInsecure()
	user.email = body_params.email
	user.password = body_params.password

	ctx.user = user

	local valid, errs = user:validateLogin()
	if not valid then
		res:send(json.encode({errors = errs}))
		return
	end

	local su, err = self.users:login(ctx.session_user, ctx.ip, ctx.time, user)

	if not su then
		res:send(json.encode({errors = {err}}))
		return
	end

	res:send(json.encode({
		user = su.user,
		session = su.session,
		token = self.sessions:encode({id = su.session.id}),
	}))
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:logout(req, res, ctx)
	if not ctx.session then
		res.status = 400
		return
	end

	self.users:logout(ctx.session_user, ctx.session.id)
	self.sessions:set(res.headers, {})

	res.status = 302
	res.headers:set("HX-Location", "/")
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:getRegister(req, res, ctx)
	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_register_captcha_enabled = self.is_register_captcha_enabled

	self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function AuthResource:register(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local user = UserInsecure()
	user.email = body_params.email
	user.name = body_params.name
	user.password = body_params.password

	ctx.user = user

	if body_params.password ~= body_params.confirm_password then
		ctx.errors = {"passwords do not match"}
		self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
		return
	end

	local valid, errs = user:validateRegister()
	if not valid then
		ctx.errors = errs
		self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
		return
	end

	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_register_captcha_enabled = self.is_register_captcha_enabled

	if self.is_register_captcha_enabled then
		local ok, err = self.recaptcha:verify(ctx.ip, body_params, "register")
		if not ok then
			ctx.errors = {err}
			self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
			return
		end
	end

	local su, err = self.users:register(ctx.session_user, ctx.ip, ctx.time, user)

	if not su then
		ctx.errors = {err}
		self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
		return
	end

	self.sessions:set(res.headers, {id = su.session.id})

	res.status = 302
	res.headers:set("Location", "/")
end

return AuthResource

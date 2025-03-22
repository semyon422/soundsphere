local http_util = require("web.http.util")
local IResource = require("web.framework.IResource")
local User = require("sea.access.User")

---@class sea.LoginResource: web.IResource
---@operator call: sea.LoginResource
local LoginResource = IResource + {}

LoginResource.uri = "/login"

---@param sessions web.Sessions
---@param users sea.Users
---@param views web.Views
function LoginResource:new(sessions, users, views)
	self.sessions = sessions
	self.users = users
	self.views = views
end

---@param enabled boolean
---@param recaptcha web.Recaptcha
function LoginResource:setRecaptcha(enabled, recaptcha)
	self.is_captcha_enabled = enabled
	self.recaptcha = recaptcha
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LoginResource:GET(req, res, ctx)
	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_captcha_enabled = self.captcha_enabled

	self.views:render_send(res, "sea/access/http/login.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LoginResource:POST(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local user = User()
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
	ctx.is_captcha_enabled = self.captcha_enabled

	if self.is_captcha_enabled then
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

return LoginResource

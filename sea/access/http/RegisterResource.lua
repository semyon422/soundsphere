local http_util = require("web.http.util")
local IResource = require("web.framework.IResource")
local User = require("sea.access.User")

---@class sea.RegisterResource: web.IResource
---@operator call: sea.RegisterResource
local RegisterResource = IResource + {}

RegisterResource.uri = "/register"

---@param sessions web.Sessions
---@param users sea.Users
---@param views web.Views
function RegisterResource:new(sessions, users, views)
	self.sessions = sessions
	self.users = users
	self.views = views
end

---@param enabled boolean
---@param recaptcha web.Recaptcha
function RegisterResource:setRecaptcha(enabled, recaptcha)
	self.is_captcha_enabled = enabled
	self.recaptcha = recaptcha
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function RegisterResource:GET(req, res, ctx)
	ctx.recaptcha_site_key = self.recaptcha.site_key
	ctx.is_captcha_enabled = self.captcha_enabled

	self.views:render_send(res, "sea/access/http/register.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function RegisterResource:POST(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local user = User()
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
	ctx.is_captcha_enabled = self.captcha_enabled

	if self.is_captcha_enabled then
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

return RegisterResource

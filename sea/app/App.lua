local class = require("class")
local socket_url = require("socket.url")
local LsqliteDatabase = require("rdb.LsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local Resources = require("sea.app.Resources")
local Repos = require("sea.app.Repos")
local Domain = require("sea.app.Domain")
local Views = require("web.framework.page.Views")
local Router = require("web.framework.router.Router")
local Sessions = require("web.framework.Sessions")
local Recaptcha = require("web.framework.Recaptcha")
local etlua_util = require("web.framework.page.etlua_util")

---@class sea.RequestContext
---@field [any] any
---@field ip string
---@field time integer
---@field path_params {[string]: string}
---@field session_user sea.User
---@field session sea.Session?

---@class sea.App
---@operator call: sea.App
local App = class()

---@param app_config sea.AppConfig
function App:new(app_config)
	self.app_db = ServerSqliteDatabase(LsqliteDatabase())
	self.sessions = Sessions("sea", app_config.sessions_secret)
	self.recaptcha = Recaptcha(app_config.recaptcha.secret_key, app_config.recaptcha.site_key)

	self.repos = Repos(self.app_db.models)
	self.domain = Domain(self.repos)

	local views = Views(etlua_util.autoload(), "sea/shared/http/layout.etlua")
	self.resources = Resources(self.domain, views, self.sessions)

	local router = Router()
	self.router = router
	router:route(self.resources:getList())

	self.domain.users.is_login_enabled = app_config.is_login_enabled
	self.domain.users.is_register_enabled = app_config.is_register_enabled

	self.resources.auth:setRecaptcha(
		self.recaptcha,
		app_config.is_login_captcha_enabled,
		app_config.is_register_captcha_enabled
	)
end

function App:load()
	self.app_db:open()
end

function App:unload()
	self.app_db:close()
end

---@param req web.IRequest
---@param ctx sea.RequestContext
function App:handleSession(req, ctx)
	---@type {id: integer}?
	local t = self.sessions:get(req.headers)
	if not t or not t.id then
		return
	end

	local session = self.domain.users:getSession(t.id)
	if not session or not session.active then
		return
	end

	ctx.session = session
	ctx.session_user = self.domain.users:getUser(session.user_id)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ip string
function App:handle(req, res, ip)
	local parsed_uri = socket_url.parse(req.uri)

	local resource, path_params, methods = self.router:getResource(parsed_uri.path)

	if not resource or not path_params or not methods then
		res.status = 404
		res:set_chunked_encoding()
		res:send("not found")
		res:send("")
		return
	end

	local method = req.method
	local _method = methods[method]

	if method ~= method:upper() or not resource[_method] then
		res.status = 403
		res:set_chunked_encoding()
		res:send("invalid method")
		res:send("")
		return
	end

	---@type sea.RequestContext
	local ctx = {
		parsed_uri = parsed_uri,
		path_params = path_params,
		ip = ip,
		time = os.time(),
		session_user = self.domain.users.anon_user,
	}

	self:handleSession(req, ctx)

	local ok, err = xpcall(resource[_method], debug.traceback, resource, req, res, ctx)
	if not ok then
		local body = ("<pre>%s</pre>"):format(err)
		res.status = 500
		res:set_chunked_encoding()
		res:send(body)
		res:send("")
		return
	end

	res:send("")
end

return App

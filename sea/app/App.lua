local class = require("class")
local http_util = require("web.http.util")
local socket_url = require("socket.url")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local Resources = require("sea.app.Resources")
local Repos = require("sea.app.Repos")
local Domain = require("sea.app.Domain")
local ServerRemote = require("sea.app.remotes.ServerRemote")
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
---@field query {[string]: string}
---@field session_user sea.User
---@field session sea.Session?
---@field version any

---@class sea.App
---@operator call: sea.App
local App = class()

---@param app_config sea.AppConfig
function App:new(app_config)
	self.app_db = ServerSqliteDatabase(LjsqliteDatabase())
	self.sessions = Sessions("sea", app_config.sessions_secret)
	self.recaptcha = Recaptcha(app_config.recaptcha.secret_key, app_config.recaptcha.site_key, app_config.recaptcha.required_score)

	self.repos = Repos(self.app_db.models)
	self.domain = Domain(self.repos, app_config)
	self.server_remote = ServerRemote(self.domain, self.sessions)

	local views = Views(etlua_util.autoload(), "sea/shared/http/layout.etlua")
	self.resources = Resources(self.domain, self.server_remote, views, self.sessions, app_config)

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

---@param version any
---@return any
function App:setVersion(version)
	self.version = version
	return version
end

function App:getVersion()
	if self.version then
		return self.version
	end

	local p = io.popen("git log -1 --format=%H")
	if not p then
		return self:setVersion(os.time())
	end

	---@type string?
	local hash = p:read("*a"):match("^%s*(.+)%s*\n.*$")
	if not hash or #hash ~= 40 then
		return self:setVersion(os.time())
	end

	return self:setVersion(hash)
end

---@param req web.IRequest
---@param ctx sea.RequestContext
function App:handleSession(req, ctx)
	---@type sea.Session?
	local req_session = self.sessions:get(req.headers)
	if not req_session or not req_session.id then
		return
	end

	local session = self.domain.users:checkSession(req_session)
	if not session then
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
		query = http_util.decode_query_string(parsed_uri.query),
		ip = ip,
		time = os.time(),
		session = self.domain.users:getSession(),
		session_user = self.domain.users:getUser(),
		version = self:getVersion(),
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

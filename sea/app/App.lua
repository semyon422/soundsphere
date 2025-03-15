local class = require("class")
local socket_url = require("socket.url")
local LsqliteDatabase = require("rdb.LsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local UsersRepo = require("sea.access.repos.UsersRepo")
local Users = require("sea.access.Users")
local UsersResource = require("sea.access.http.UsersResource")
local StyleResource = require("sea.shared.http.StyleResource")
local IPasswordHasher = require("sea.access.IPasswordHasher")
local Views = require("web.framework.page.Views")
local Router = require("web.framework.router.Router")
local Sessions = require("web.framework.Sessions")
local etlua_util = require("web.framework.page.etlua_util")

---@class sea.RequestContext
---@field [any] any
---@field ip string
---@field time integer
---@field path_params {[string]: string}

---@class sea.App
---@operator call: sea.App
local App = class()

---@param app_config sea.AppConfig
function App:new(app_config)
	self.app_db = ServerSqliteDatabase(LsqliteDatabase())

	self.users_repo = UsersRepo(self.app_db.models)
	self.users = Users(self.users_repo, IPasswordHasher())

	self.sessions = Sessions("sea", app_config.sessions_secret)

	local views = Views(etlua_util.autoload())

	local router = Router()
	self.router = router
	router:route({
		StyleResource(),
		UsersResource(self.users, views),
	})
end

function App:load()
	self.app_db:open()
end

function App:unload()
	self.app_db:close()
end

---@param req web.IRequest
---@param res web.IResponse
function App:handle(req, res)
	req:receive_headers()
	res:set_chunked_encoding()

	local parsed_uri = socket_url.parse(req.uri)

	local resource, path_params = self.router:getResource(parsed_uri.path)

	if not resource or not path_params then
		res.status = 404
		res:send("not found")
		res:send("")
		return
	end

	local method = req.method
	if method ~= method:upper() or not resource[method] then
		res.status = 403
		res:send("invalid method")
		res:send("")
		return
	end

	---@type sea.RequestContext
	local ctx = {
		parsed_uri = parsed_uri,
		path_params = path_params,
		ip = req.headers:get("X-Real-IP"),
		time = os.time(),
	}

	ctx.session = self.sessions:get(req.headers)
	ctx.session_user = self.users:getUser(ctx.session and ctx.session.user_id)

	if resource.before then
		local ok, err = xpcall(resource.before, debug.traceback, resource, req, res, ctx)
		if not ok then
			local body = ("<pre>%s</pre>"):format(err)
			res.status = 500
			res:send(body)
			res:send("")
			return
		end
		if not err then
			res:send("")
			return
		end
	end

	local ok, err = xpcall(resource[method], debug.traceback, resource, req, res, ctx)
	if not ok then
		local body = ("<pre>%s</pre>"):format(err)
		res.status = 500
		res:send(body)
		res:send("")
		return
	end

	res:send("")
end

return App

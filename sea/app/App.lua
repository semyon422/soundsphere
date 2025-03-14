local class = require("class")
local LsqliteDatabase = require("rdb.LsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local UsersRepo = require("sea.access.repos.UsersRepo")
local Users = require("sea.access.Users")
local UsersResource = require("sea.access.http.UsersResource")
local IPasswordHasher = require("sea.access.IPasswordHasher")

---@class sea.App
---@operator call: sea.App
local App = class()

function App:new()
	self.app_db = ServerSqliteDatabase(LsqliteDatabase())

	self.users_repo = UsersRepo(self.app_db.models)
	self.users = Users(self.users_repo, IPasswordHasher())
	self.users_resource = UsersResource(self.users)
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
	res.status = 200
	res:set_chunked_encoding()
	self.users_resource:GET(req, res, {})
	res:send("")
end

return App

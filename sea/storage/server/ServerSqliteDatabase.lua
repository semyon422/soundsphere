local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.ServerSqliteDatabase
---@operator call: sphere.ServerSqliteDatabase
local ServerSqliteDatabase = class()

ServerSqliteDatabase.path = "server.db"

-- TODO: migrations

function ServerSqliteDatabase:new()
	self.db = LjsqliteDatabase()
	self.orm = TableOrm(self.db)
	self.models = Models(autoload("sea.storage.server.models"), self.orm)
end

function ServerSqliteDatabase:remove()
	os.remove(self.path)
end

function ServerSqliteDatabase:open()
	self.db:open(self.path)
	local sql = assert(love.filesystem.read("sea/storage/server/db.sql"))
	self.db:exec(sql)
	self.db:exec("PRAGMA foreign_keys = ON;")
end

function ServerSqliteDatabase:close()
	self.db:close()
end

return ServerSqliteDatabase

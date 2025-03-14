local class = require("class")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sea.ServerSqliteDatabase
---@operator call: sea.ServerSqliteDatabase
local ServerSqliteDatabase = class()

ServerSqliteDatabase.path = "server.db"

-- TODO: migrations

---@param db rdb.IDatabase
function ServerSqliteDatabase:new(db)
	self.db = db
	self.orm = TableOrm(self.db)
	self.models = Models(autoload("sea.storage.server.models", true), self.orm)
end

function ServerSqliteDatabase:remove()
	os.remove(self.path)
end

function ServerSqliteDatabase:open()
	local f = assert(io.open("sea/storage/server/db.sql"))
	local sql = f:read("*a")
	f:close()

	self.db:open(self.path)
	self.db:exec(sql)
	self.db:exec("PRAGMA foreign_keys = ON;")
end

function ServerSqliteDatabase:close()
	self.db:close()
end

return ServerSqliteDatabase

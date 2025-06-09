local class = require("class")
local io_util = require("io_util")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sea.ServerSqliteDatabase
---@operator call: sea.ServerSqliteDatabase
local ServerSqliteDatabase = class()

ServerSqliteDatabase.path = "server.db"

-- TODO: migrations

---@param db rdb.SqliteDatabase
function ServerSqliteDatabase:new(db)
	self.db = db
	self.orm = TableOrm(db)
	self.models = Models(autoload("sea.storage.server.models", true), self.orm)
end

function ServerSqliteDatabase:remove()
	os.remove(self.path)
end

function ServerSqliteDatabase:open()
	local db = self.db
	db:open(self.path)
	db:exec("PRAGMA busy_timeout = 10000")
	db:exec("PRAGMA foreign_keys = ON")
	db:exec(io_util.read_file("sea/storage/server/db.sql"))
	db:exec(io_util.read_file("sea/storage/shared/db.sql"))
end

function ServerSqliteDatabase:close()
	self.db:close()
end

return ServerSqliteDatabase

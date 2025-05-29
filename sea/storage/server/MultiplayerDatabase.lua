local class = require("class")
local io_util = require("io_util")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sea.MultiplayerDatabase
---@operator call: sea.MultiplayerDatabase
local MultiplayerDatabase = class()

MultiplayerDatabase.path = ":memory:"

---@param db rdb.SqliteDatabase
function MultiplayerDatabase:new(db)
	self.db = db
	self.orm = TableOrm(db)
	self.models = Models(autoload("sea.storage.server.models", true), self.orm)
end

function MultiplayerDatabase:remove()
	os.remove(self.path)
end

function MultiplayerDatabase:open()
	self.db:open(self.path)
	self.db:exec(io_util.read_file("sea/storage/server/mp_db.sql"))
	self.db:exec("PRAGMA foreign_keys = ON;")
end

function MultiplayerDatabase:close()
	self.db:close()
end

return MultiplayerDatabase

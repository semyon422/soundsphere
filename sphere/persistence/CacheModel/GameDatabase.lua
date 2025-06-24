local class = require("class")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local SqliteMigrator = require("rdb.db.SqliteMigrator")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.GameDatabase
---@operator call: sphere.GameDatabase
local GameDatabase = class()

local user_version = 7

---@param migrations table?
function GameDatabase:new(migrations)
	self.migrations = migrations or {}

	local db = LjsqliteDatabase()
	self.db = db

	local _models = autoload("sphere.persistence.CacheModel.models")
	self.orm = TableOrm(db)
	self.models = Models(_models, self.orm)

	self.migrator = SqliteMigrator(db)
end

function GameDatabase:load()
	local db = self.db

	db:open("userdata/data.db")
	db:exec("PRAGMA busy_timeout = 10000")
	db:exec("PRAGMA foreign_keys = ON")

	local ver = db:user_version()

	if ver == 0 then
		db:exec(assert(love.filesystem.read("sphere/persistence/CacheModel/database.sql")))
		db:exec(assert(love.filesystem.read("sea/storage/shared/db.sql")))
		db:user_version(user_version)
		ver = user_version
	elseif ver >= 4 then
		self:migrate()
	else
		error("outdated database")
	end

	local sql = assert(love.filesystem.read("sphere/persistence/CacheModel/views.sql"))
	db:exec(sql)
end

function GameDatabase:unload()
	self.db:close()
end

function GameDatabase:migrate()
	local count = self.migrator:migrate(user_version, self.migrations)
	if count > 0 then
		print("migrations applied: " .. count)
	end
end

return GameDatabase

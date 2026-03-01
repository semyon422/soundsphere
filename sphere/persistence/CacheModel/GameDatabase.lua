local class = require("class")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local SqliteMigrator = require("rdb.db.SqliteMigrator")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local sql_util = require("rdb.sql_util")
local autoload = require("autoload")

---@class sphere.CacheModelModels
---@field chartfile_sets rdb.Model
---@field chartfiles rdb.Model
---@field locations rdb.Model
---@field chartviews rdb.Model
---@field chartviews_no_preview rdb.Model
---@field chartdiffviews rdb.Model
---@field chartdiffviews_no_preview rdb.Model
---@field chartplayviews rdb.Model
---@field chartplayviews_no_preview rdb.Model
---@field difftable_chartmetas rdb.Model
---@field chartfile_set_dirs rdb.Model
---@field chartplays rdb.Model
---@field chartdiffs rdb.Model
---@field chartmetas rdb.Model

---@class sphere.GameDatabase
---@field models sphere.CacheModelModels
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

function GameDatabase:load(path)
	local db = self.db

	db:open(path or "userdata/data.db")
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

	self:applyViews()
end

function GameDatabase:unload()
	self.db:close()
end

function GameDatabase:applyViews()
	local sql = assert(love.filesystem.read("sphere/persistence/CacheModel/views.sql"))
	for _, q in ipairs(sql_util.split_sql(sql)) do
		self.db.c:exec(q)
	end
end

function GameDatabase:migrate()
	local count = self.migrator:migrate(user_version, self.migrations)
	if count > 0 then
		print("migrations applied: " .. count)
		self:applyViews()
	end
end

return GameDatabase

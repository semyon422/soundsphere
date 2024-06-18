local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.GameDatabase
---@operator call: sphere.GameDatabase
local GameDatabase = class()

local user_version = 3

---@param migrations table?
function GameDatabase:new(migrations)
	self.migrations = migrations or {}

	local db = LjsqliteDatabase()
	self.db = db

	local _models = autoload("sphere.persistence.CacheModel.models")
	self.orm = TableOrm(db)
	self.models = Models(_models, self.orm)
end

function GameDatabase:load()
	self.db:open("userdata/data.db")
	local sql = assert(love.filesystem.read("sphere/persistence/CacheModel/database.sql"))
	self.db:exec(sql)
	self.db:exec("PRAGMA foreign_keys = ON;")
	self:migrate()
end

function GameDatabase:unload()
	self.db:close()
end

function GameDatabase:migrate()
	local count = self.orm:migrate(user_version, self.migrations)
	if count > 0 then
		print("migrations applied: " .. count)
	end
end

return GameDatabase

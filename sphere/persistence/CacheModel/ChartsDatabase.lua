local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.ChartsDatabase
---@operator call: sphere.ChartsDatabase
local ChartsDatabase = class()

local user_version = 0

function ChartsDatabase:new()
	local db = LjsqliteDatabase()
	self.db = db

	local _models = autoload("sphere.persistence.CacheModel.models")
	self.orm = TableOrm(db)
	self.models = Models(_models, self.orm)
end

function ChartsDatabase:load()
	self.db:open("userdata/data.db")
	local sql = assert(love.filesystem.read("sphere/persistence/CacheModel/database.sql"))
	self.db:exec(sql)
	self.db:exec("PRAGMA foreign_keys = ON;")
	self:updateSchema()
end

function ChartsDatabase:unload()
	self.db:close()
end

function ChartsDatabase:updateSchema()
	local migrations = setmetatable({}, {__index = function(_, k)
		local data = love.filesystem.read(("sphere/persistence/CacheModel/migrate%s.sql"):format(k))
		return data
	end})

	local count = self.orm:migrate(user_version, migrations)
	if count > 0 then
		print("migrations applied: " .. count)
	end
end

return ChartsDatabase

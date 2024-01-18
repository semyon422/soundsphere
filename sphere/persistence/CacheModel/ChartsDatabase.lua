local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.ChartsDatabase
---@operator call: sphere.ChartsDatabase
local ChartsDatabase = class()

function ChartsDatabase:new()
	local db = LjsqliteDatabase()
	self.db = db

	local _models = autoload("sphere.persistence.CacheModel.models")
	self.orm = TableOrm(db)
	self.models = Models(_models, self.orm)
end

function ChartsDatabase:load()
	self.db:open("userdata/charts.db")
	local sql = assert(love.filesystem.read("sphere/persistence/CacheModel/database.sql"))
	self.db:exec(sql)
	self.orm:attach("userdata/scores.db", "scores_db")
end

function ChartsDatabase:unload()
	self.orm:detach("scores_db")
	self.db:close()
end

return ChartsDatabase

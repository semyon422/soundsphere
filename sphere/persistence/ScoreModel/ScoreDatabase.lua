local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

local user_version = 0

local _models = {}
local scores = {}
scores.table_name = "scores"
scores.types = {}
scores.relations = {}
_models.scores = scores

function ScoreDatabase:load()
	if self.loaded then
		return
	end

	local db = LjsqliteDatabase()
	self.db = db

	db:open(self.dbpath)
	local sql = love.filesystem.read("sphere/persistence/ScoreModel/database.sql")
	db:exec(sql)

	local orm = TableOrm(db)
	local models = Models(_models, orm)

	self.orm = orm
	self.models = models

	self:updateSchema()

	self.loaded = true
end

function ScoreDatabase:unload()
	if not self.loaded then
		return
	end
	self.db:close()
	self.loaded = false
end

---@return table
function ScoreDatabase:selectAllScores()
	return self.models.scores:select()
end

---@param id number
---@return table?
function ScoreDatabase:selectScore(id)
	return self.models.scores:find({id = id})
end

---@param score table
---@return table?
function ScoreDatabase:insertScore(score)
	return self.models.scores:create(score, true)
end

---@param score table
---@return table?
function ScoreDatabase:updateScore(score)
	return self.models.scores:update(score, {id = score.id})
end

---@param hash string
---@param index number
---@return table
function ScoreDatabase:getScoreEntries(hash, index)
	return self.models.scores:select({chart_hash = hash, chart_index = index})
end

function ScoreDatabase:updateSchema()
	local migrations = setmetatable({}, {__index = function(_, k)
		local data = love.filesystem.read(("sphere/persistence/ScoreModel/migrate%s.sql"):format(k))
		return data
	end})

	local count = self.orm:migrate(user_version, migrations)
	if count > 0 then
		print("migrations applied: " .. count)
	end
end

return ScoreDatabase

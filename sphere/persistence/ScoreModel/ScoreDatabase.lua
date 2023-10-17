local Orm = require("Orm")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

local defaultInfo = {
	version = 5
}

function ScoreDatabase:load()
	if self.loaded then
		return
	end
	self.db = Orm()
	local db = self.db
	db:open(self.dbpath)

	local sql = love.filesystem.read("sphere/persistence/ScoreModel/database.sql")
	db:exec(sql)

	self:insertDefaultInfo()
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
	return self.db:select("scores")
end

---@param id number
---@return table?
function ScoreDatabase:selectScore(id)
	return self.db:select("scores", "id = ?", id)[1]
end

---@param score table
---@return table
function ScoreDatabase:insertScore(score)
	return self.db:insert("scores", score, true)
end

---@param score table
---@return table?
function ScoreDatabase:updateScore(score)
	return self.db:update("scores", score, "id = ?", score.id)
end

---@param hash string
---@param index number
---@return table
function ScoreDatabase:getScoreEntries(hash, index)
	return self.db:select("scores", "chart_hash = ? AND chart_index = ?", hash, index)
end

---@return table
function ScoreDatabase:selectInfo()
	local info = {}
	local objects = self.db:select("info")
	for _, object in ipairs(objects) do
		info[object.key] = tonumber(object.value) or object.value or ""
	end
	return info
end

---@param key string
---@param value any
---@return table
function ScoreDatabase:insertInfo(key, value)
	return self.db:insert("info", {key = key, value = value}, true)
end

---@param key string
---@param value any
---@return table?
function ScoreDatabase:updateInfo(key, value)
	return self.db:update("info", {key = key, value = value}, "key = ?", key)
end

function ScoreDatabase:insertDefaultInfo()
	for key, value in pairs(defaultInfo) do
		self:insertInfo(key, value)
	end
end

function ScoreDatabase:updateSchema()
	local info = self:selectInfo()

	if info.version > defaultInfo.version then
		error("you can not use newer score database in older game versions")
	end

	while info.version < defaultInfo.version do
		info.version = info.version + 1
		self.db:exec(love.filesystem.read(("sphere/persistence/ScoreModel/migrate%s.sql"):format(info.version)))
		print("schema was updated", info.version)
	end
	self:updateInfo("version", defaultInfo.version)
end

return ScoreDatabase

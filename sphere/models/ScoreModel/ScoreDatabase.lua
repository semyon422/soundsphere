local Orm = require("sphere.Orm")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

local defaultInfo = {
	version = 3
}

ScoreDatabase.load = function(self)
	if self.loaded then
		return
	end
	self.db = Orm:new()
	local db = self.db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/ScoreModel/database.sql"))

	self:insertDefaultInfo()
	self:updateSchema()

	self.loaded = true
end

ScoreDatabase.unload = function(self)
	if not self.loaded then
		return
	end
	self.db:close()
	self.loaded = false
end

ScoreDatabase.selectScore = function(self, id)
	return self.db:select("scores", "id = ?", id)[1]
end

ScoreDatabase.insertScore = function(self, score)
	return self.db:insert("scores", score, true)
end

ScoreDatabase.getScoreEntries = function(self, hash, index)
	return self.db:select("scores", "noteChartHash = ? AND noteChartIndex = ?", hash, index)
end

ScoreDatabase.selectInfo = function(self)
	local info = {}
	local objects = self.db:select("info")
	for _, object in ipairs(objects) do
		info[object.key] = tonumber(object.value) or object.value or ""
	end
	return info
end

ScoreDatabase.insertInfo = function(self, key, value)
	return self.db:insert("info", {key = key, value = value}, true)
end

ScoreDatabase.updateInfo = function(self, key, value)
	return self.db:update("info", {key = key, value = value}, "key = ?", key)
end

ScoreDatabase.insertDefaultInfo = function(self)
	for key, value in pairs(defaultInfo) do
		self:insertInfo(key, value)
	end
end

ScoreDatabase.updateSchema = function(self)
	local info = self:selectInfo()

	if info.version > defaultInfo.version then
		error("you can not use newer score database in older game versions")
	end

	while info.version < defaultInfo.version do
		info.version = info.version + 1
		self.db:exec(love.filesystem.read(("sphere/models/ScoreModel/migrate%s.sql"):format(info.version)))
		print("schema was updated", info.version)
	end
	self:updateInfo("version", defaultInfo.version)
end

return ScoreDatabase

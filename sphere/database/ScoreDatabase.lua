local sqlite	= require("ljsqlite3")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

ScoreDatabase.scoresColumns = {
	"id",
	"noteChartHash",
	"noteChartIndex",
	"playerName",
	"time",
	"score",
	"accuracy",
	"maxCombo",
	"scoreRating",
	"modifiers",
	"replayHash"
}

ScoreDatabase.scoresNumberColumns = {
	"id",
	"noteChartIndex",
	"time",
	"score",
	"maxCombo",
	"scoreRating"
}

local createTableRequest = [[
	CREATE TABLE IF NOT EXISTS `info` (
		`key` NOT NULL PRIMARY KEY,
		`value` TEXT NOT NULL
	);
	CREATE TABLE IF NOT EXISTS `scores` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`noteChartHash` TEXT NOT NULL,
		`noteChartIndex` REAL NOT NULL,
		`playerName` TEXT,
		`time` INTEGER,
		`score` REAL,
		`accuracy` REAL,
		`maxCombo` INTEGER,
		`scoreRating` REAL,
		`modifiers` TEXT,
		`replayHash` TEXT
	);
]]

local insertScoreRequest = [[
	INSERT OR IGNORE INTO `scores` (
		noteChartHash,
		noteChartIndex,
		playerName,
		time,
		score,
		accuracy,
		maxCombo,
		scoreRating,
		modifiers,
		replayHash
	)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
]]

local selectScoreRequest = [[
	SELECT * FROM `scores` WHERE noteChartHash = ? AND noteChartIndex = ?
]]

local selectScoresRequest = [[
	SELECT * FROM `scores`;
]]

local selectInfoRequest = [[
	SELECT * FROM `info`;
]]

local insertInfoRequest = [[
	INSERT OR IGNORE INTO `info` (`key`, `value`) VALUES (?, ?);
]]

local updateInfoRequest = [[
	UPDATE `info` SET `value` = ? WHERE `key` = ?;
]]

local defaultInfo = {
	version = 2
}

ScoreDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)

	self.db:exec(createTableRequest)

	self.selectInfoStatement = self.db:prepare(selectInfoRequest)
	self.insertInfoStatement = self.db:prepare(insertInfoRequest)
	self.updateInfoStatement = self.db:prepare(updateInfoRequest)

	self:insertDefaultInfo()
	self:updateSchema()

	self.insertScoreStatement = self.db:prepare(insertScoreRequest)
	self.selectScoreStatement = self.db:prepare(selectScoreRequest)

	self.selectScoresStatement = self.db:prepare(selectScoresRequest)

	self.loaded = true
end

ScoreDatabase.selectInfo = function(self)
	local info = {}

	local stmt = self.selectInfoStatement:reset()
	local row = stmt:step()
	while row do
		info[row[1]] = tonumber(row[2]) or row[2] or ""

		row = stmt:step()
	end

	return info
end

ScoreDatabase.insertInfo = function(self, key, value)
	return self.insertInfoStatement:reset():bind(
		key, value
	):step()
end

ScoreDatabase.updateInfo = function(self, key, value)
	return self.updateInfoStatement:reset():bind(
		value, key
	):step()
end

ScoreDatabase.insertDefaultInfo = function(self)
	for key, value in pairs(defaultInfo) do
		self:insertInfo(key, value)
	end
end

ScoreDatabase.unload = function(self)
	self.db:close()
	self.loaded = false
end

ScoreDatabase.insertScore = function(self, scoreData)
	-- self.log:write("score", scoreData.noteChartHash, scoreData.noteChartIndex, scoreData.score)
	self.insertScoreStatement:reset():bind(
		scoreData.noteChartHash,
		scoreData.noteChartIndex,
		scoreData.playerName,
		scoreData.time,
		scoreData.score,
		scoreData.accuracy,
		scoreData.maxCombo,
		scoreData.scoreRating,
		scoreData.modifiers,
		scoreData.replayHash
	):step()
end

ScoreDatabase.transformEntry = function(self, row, columns, numberColumns)
	local entry = {}

	for i = 1, #columns do
		entry[columns[i]] = row[i] or ""
	end
	for i = 1, #numberColumns do
		entry[numberColumns[i]] = tonumber(entry[numberColumns[i]]) or 0
	end

	return entry
end

ScoreDatabase.transformScoreEntry = function(self, entry)
	return self:transformEntry(entry, self.scoresColumns, self.scoresNumberColumns)
end

local updates = {}

updates[2] = [[
	ALTER TABLE scores RENAME TO temp;
	CREATE TABLE IF NOT EXISTS `scores` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`noteChartHash` TEXT NOT NULL,
		`noteChartIndex` REAL NOT NULL,
		`playerName` TEXT,
		`time` INTEGER,
		`score` REAL,
		`accuracy` REAL,
		`maxCombo` INTEGER,
		`scoreRating` REAL,
		`modifiers` TEXT,
		`replayHash` TEXT
	);
	INSERT INTO scores(id, noteChartHash, noteChartIndex, playerName, time, score, accuracy, maxCombo, scoreRating, modifiers, replayHash)
	SELECT id, noteChartHash, noteChartIndex, playerName, time, score, accuracy, maxCombo, scoreRating, mods, "" FROM temp;
	DROP TABLE temp;
]]

ScoreDatabase.updateSchema = function(self)
	local info = self:selectInfo()

	if info.version > defaultInfo.version then
		error("you can not use newer score database in older game versions")
	end

	while info.version < defaultInfo.version do
		info.version = info.version + 1
		self.db:exec(updates[info.version])
		print("schema was updated")
	end
	self:updateInfo("version", defaultInfo.version)
end

return ScoreDatabase

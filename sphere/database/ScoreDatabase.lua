local Log		= require("aqua.util.Log")
local sqlite	= require("ljsqlite3")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

ScoreDatabase.scoreColumns = {
	"id",
	"chartHash",
	"playerName",
	"time",
	"score",
	"accuracy",
	"maxCombo",
	"scoreRating",
	"mods"
}

ScoreDatabase.scoreNumberColumns = {
	"id",
	"time",
	"maxCombo"
}

local createTableRequest = [[
	CREATE TABLE IF NOT EXISTS `scores` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`chartHash` TEXT NOT NULL DEFAULT '',
		`playerName` TEXT,
		`time` INTEGER,
		`score` REAL,
		`accuracy` REAL,
		`maxCombo` INTEGER,
		`scoreRating` REAL,
		`mods` TEXT
	);
]]

local insertScoreRequest = [[
	INSERT OR IGNORE INTO `scores` (
		chartHash,
		playerName,
		time,
		score,
		accuracy,
		maxCombo,
		scoreRating,
		mods
	)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?);
]]

local selectScoreRequest = [[
	SELECT * FROM `scores` WHERE chartHash = ?
]]

ScoreDatabase.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/scores.log"
end

ScoreDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec(createTableRequest)
	
	self.insertScoreStatement = self.db:prepare(insertScoreRequest)
	self.selectScoreStatement = self.db:prepare(selectScoreRequest)
end

ScoreDatabase.unload = function(self)
	self.db:close()
end

ScoreDatabase.insertScore = function(self, scoreData)
	self.log:write("score", scoreData.chartHash, scoreData.score)
	self.insertScoreStatement:reset():bind(
		scoreData.chartHash,
		scoreData.playerName,
		scoreData.time,
		scoreData.score,
		scoreData.accuracy,
		scoreData.maxCombo,
		scoreData.scoreRating,
		scoreData.mods
	):step()
end

return ScoreDatabase

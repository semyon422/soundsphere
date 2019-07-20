local sqlite = require("ljsqlite3")
local Log = require("aqua.util.Log")

local ScoreDatabase = {}

ScoreDatabase.dbpath = "userdata/scores.db"

ScoreDatabase.scoreColumns = {
	"id",
	"chartHash",
	"score",
	"accuracy"
}

ScoreDatabase.scoreNumberColumns = {
	"id"
}

ScoreDatabase.unload = function(self)
	self.db:close()
end

ScoreDatabase.load = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/scores.log"
	
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec[[
		CREATE TABLE IF NOT EXISTS `scores` (
			`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			`chartHash` TEXT NOT NULL DEFAULT '',
			`score` REAL,
			`accuracy` REAL
		);
	]]
	
	self.insertScoreStatement = self.db:prepare([[
		INSERT OR IGNORE INTO `scores` (
			chartHash,
			score,
			accuracy
		)
		VALUES (?, ?, ?);
	]])
	
	self.selectScoreStatement = self.db:prepare([[
		SELECT * FROM `scores` WHERE chartHash = ?
	]])
end

ScoreDatabase.insertScore = function(self, chartHash, score, accuracy)
	self.log:write("score", chartHash, score, accuracy)
	self.insertScoreStatement:reset():bind(chartHash, score, accuracy):step()
end

return ScoreDatabase

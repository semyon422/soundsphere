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
	"mods"
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
		`mods` TEXT
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
		mods
	)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
]]

local selectScoreRequest = [[
	SELECT * FROM `scores` WHERE noteChartHash = ? AND noteChartIndex = ?
]]

local selectScoresRequest = [[
	SELECT * FROM `scores`;
]]

ScoreDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec(createTableRequest)
	
	self.insertScoreStatement = self.db:prepare(insertScoreRequest)
	self.selectScoreStatement = self.db:prepare(selectScoreRequest)

	self.selectScoresStatement = self.db:prepare(selectScoresRequest)

	self.loaded = true
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
		scoreData.mods
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

return ScoreDatabase

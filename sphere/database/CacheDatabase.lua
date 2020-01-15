local ThreadPool		= require("aqua.thread.ThreadPool")
local Log				= require("aqua.util.Log")
local sqlite			= require("ljsqlite3")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"
CacheDatabase.chartspath = "userdata/charts"

----------------------------------------------------------------

CacheDatabase.noteChartDatasColumns = {
	"hash",
	"title",
	"artist",
	"source",
	"tags",
	"name",
	"creator",
	"audioPath",
	"stagePath",
	"previewTime",
	"inputMode",
	"noteCount",
	"length",
	"bpm",
	"level",
	"difficultyRate"
}

CacheDatabase.noteChartsColumns = {
	"id",
	"path",
	"hash",
	"setId",
	"lastModified"
}

CacheDatabase.noteChartSetsColumns = {
	"id",
	"path",
	"lastModified"
}

----------------------------------------------------------------

CacheDatabase.noteChartDatasNumberColumns = {
	"previewTime",
	"noteCount",
	"length",
	"bpm",
	"level",
	"difficultyRate"
}

CacheDatabase.noteChartsNumberColumns = {
	"id",
	"setId",
	"lastModified"
}

CacheDatabase.noteChartSetsNumberColumns = {
	"id",
	"lastModified"
}

----------------------------------------------------------------

local createTableRequest = [[
	CREATE TABLE IF NOT EXISTS `noteCharts` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`path` TEXT NOT NULL UNIQUE,
		`hash` TEXT,
		`setId` INTEGER,
		`lastModified` INTEGER
	);
	CREATE TABLE IF NOT EXISTS `noteChartSets` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`path` TEXT NOT NULL UNIQUE,
		`lastModified` INTEGER
	);
	CREATE TABLE IF NOT EXISTS `noteChartDatas` (
		`hash` TEXT UNIQUE NOT NULL PRIMARY KEY,
		`title` TEXT,
		`artist` TEXT,
		`source` TEXT,
		`tags` TEXT,
		`name` TEXT,
		`creator` TEXT,
		`audioPath` TEXT,
		`stagePath` TEXT,
		`previewTime` REAL,
		`inputMode` TEXT,
		`noteCount` REAL,
		`length` REAL,
		`bpm` REAL,
		`level` REAL,
		`difficultyRate` REAL
	);
]]

----------------------------------------------------------------

local insertNoteChartRequest = [[
	INSERT OR IGNORE INTO `noteCharts` (
		`path`, `hash`, `setId`, `lastModified`
	)
	VALUES (?, ?, ?, ?);
]]

local updateNoteChartRequest = [[
	UPDATE `noteCharts` SET
		`hash` = ?,
		`setId` = ?,
		`lastModified` = ?
	WHERE `path` = ?;
]]

local selectNoteChartRequest = [[
	SELECT * FROM `noteCharts` WHERE `path` = ?
]]

local selectAllNoteChartsRequest = [[
	SELECT * FROM `noteCharts`;
]]

----------------------------------------------------------------

local insertNoteChartSetRequest = [[
	INSERT OR IGNORE INTO `noteChartSets` (
		`path`, `lastModified`
	)
	VALUES (?, ?);
]]

local updateNoteChartSetRequest = [[
	UPDATE `noteChartSets` SET
		`lastModified` = ?
	WHERE `path` = ?;
]]

local selectNoteChartSetRequest = [[
	SELECT * FROM `noteChartSets` WHERE `path` = ?
]]

local selectAllNoteChartSetsRequest = [[
	SELECT * FROM `noteChartSets`;
]]

----------------------------------------------------------------

local insertNoteChartDataRequest = [[
	INSERT OR IGNORE INTO `noteChartDatas` (
		`hash`,
		`title`,
		`artist`,
		`source`,
		`tags`,
		`name`,
		`creator`,
		`audioPath`,
		`stagePath`,
		`previewTime`,
		`inputMode`,
		`noteCount`,
		`length`,
		`bpm`,
		`level`,
		`difficultyRate`
	)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
]]

local updateNoteChartDataRequest = [[
	UPDATE `noteChartDatas` SET
		`title` = ?,
		`artist` = ?,
		`source` = ?,
		`tags` = ?,
		`name` = ?,
		`creator` = ?,
		`audioPath` = ?,
		`stagePath` = ?,
		`previewTime` = ?,
		`inputMode` = ?,
		`noteCount` = ?,
		`length` = ?,
		`bpm` = ?,
		`level` = ?,
		`difficultyRate` = ?
	WHERE `hash` = ?;
]]

local selectNoteChartDataRequest = [[
	SELECT * FROM `noteChartDatas` WHERE `hash` = ?;
]]

local selectAllNoteChartDatasRequest = [[
	SELECT * FROM `noteChartDatas`;
]]

----------------------------------------------------------------

-- local deleteChartRequest = [[
-- 	DELETE FROM `charts` WHERE INSTR(`path`, ?) == 1
-- ]]

-- local deleteChartSetRequest = [[
-- 	DELETE FROM `chartSets` WHERE INSTR(`path`, ?) == 1
-- ]]

CacheDatabase.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/cache.log"
end

CacheDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	local db = self.db
	
	db:exec(createTableRequest)
	
	self.insertNoteChartStatement = db:prepare(insertNoteChartRequest)
	self.updateNoteChartStatement = db:prepare(updateNoteChartRequest)
	self.selectNoteChartStatement = db:prepare(selectNoteChartRequest)
	self.selectAllNoteChartsStatement = db:prepare(selectAllNoteChartsRequest)
	-- self.deleteChartStatement = self.db:prepare(deleteChartRequest)

	self.insertNoteChartSetStatement = db:prepare(insertNoteChartSetRequest)
	self.updateNoteChartSetStatement = db:prepare(updateNoteChartSetRequest)
	self.selectNoteChartSetStatement = db:prepare(selectNoteChartSetRequest)
	self.selectAllNoteChartSetsStatement = db:prepare(selectAllNoteChartSetsRequest)
	-- self.deleteChartSetStatement = self.db:prepare(deleteChartSetRequest)

	self.insertNoteChartDataStatement = db:prepare(insertNoteChartDataRequest)
	self.updateNoteChartDataStatement = db:prepare(updateNoteChartDataRequest)
	self.selectNoteChartDataStatement = db:prepare(selectNoteChartDataRequest)
	self.selectAllNoteChartDatasStatement = db:prepare(selectAllNoteChartDatasRequest)
	-- self.deleteChartStatement = self.db:prepare(deleteChartRequest)
end

CacheDatabase.unload = function(self)
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:exec("BEGIN;")
end

CacheDatabase.commit = function(self)
	return self.db:exec("COMMIT;")
end



-- CacheDatabase.checkChartSetData = function(self, path)
-- 	return self.selectChartSetStatement:reset():bind(path):step()
-- end

-- CacheDatabase.getChartSetData = function(self, path)
-- 	self.insertChartSetStatement:reset():bind(path):step()
-- 	return self:checkChartSetData(path)
-- end

-- CacheDatabase.deleteChartData = function(self, path)
-- 	return self.deleteChartStatement:reset():bind(path):step()
-- end

-- CacheDatabase.deleteChartSetData = function(self, path)
-- 	return self.deleteChartSetStatement:reset():bind(path):step()
-- end



----------------------------------------------------------------

CacheDatabase.insertNoteChartEntry = function(self, entry)
	return self.insertNoteChartStatement:reset():bind(
		entry.path,
		entry.hash,
		entry.setId,
		entry.lastModified
	):step()
end

CacheDatabase.updateNoteChartEntry = function(self, entry)
	return self.updateNoteChartStatement:reset():bind(
		entry.hash,
		entry.setId,
		entry.lastModified,
		entry.path
	):step()
end

CacheDatabase.selectNoteChartEntry = function(self, path)
	local entry = self.selectNoteChartStatement:reset():bind(path):step()
	return self:transformNoteChartEntry(entry)
end

CacheDatabase.setNoteChartEntry = function(self, entry)
	self:insertNoteChartEntry(entry)
	return self:updateNoteChartEntry(entry)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartSetEntry = function(self, entry)
	return self.insertNoteChartSetStatement:reset():bind(
		entry.path,
		entry.lastModified
	):step()
end

CacheDatabase.updateNoteChartSetEntry = function(self, entry)
	return self.insertNoteChartSetStatement:reset():bind(
		entry.lastModified,
		entry.path
	):step()
end

CacheDatabase.selectNoteChartSetEntry = function(self, path)
	local entry = self.selectNoteChartSetStatement:reset():bind(path):step()
	return self:transformNoteChartSetEntry(entry)
end

CacheDatabase.getNoteChartSetEntry = function(self, entry)
	self.insertNoteChartSetStatement:reset():bind(entry.path, entry.lastModified):step()
	return self:selectNoteChartSetEntry(entry.path)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartDataEntry = function(self, entry)
	return self.insertNoteChartDataStatement:reset():bind(
		entry.hash,
		entry.title,
		entry.artist,
		entry.source,
		entry.tags,
		entry.name,
		entry.creator,
		entry.audioPath,
		entry.stagePath,
		entry.previewTime,
		entry.inputMode,
		entry.noteCount,
		entry.length,
		entry.bpm,
		entry.level,
		entry.difficultyRate
	):step()
end

CacheDatabase.updateNoteChartDataEntry = function(self, entry)
	return self.updateNoteChartDataStatement:reset():bind(
		entry.title,
		entry.artist,
		entry.source,
		entry.tags,
		entry.name,
		entry.creator,
		entry.audioPath,
		entry.stagePath,
		entry.previewTime,
		entry.inputMode,
		entry.noteCount,
		entry.length,
		entry.bpm,
		entry.level,
		entry.difficultyRate,
		entry.hash
	):step()
end

CacheDatabase.selectNoteCharDatatEntry = function(self, hash)
	local entry = self.selectNoteChartDataStatement:reset():bind(hash):step()
	return self:transformNoteChartDataEntry(entry)
end

CacheDatabase.setNoteChartDataEntry = function(self, entry)
	self:insertNoteChartDataEntry(entry)
	return self:updateNoteChartDataEntry(entry)
end

----------------------------------------------------------------

CacheDatabase.transformEntry = function(self, row, columns, numberColumns)
	local entry = {}

	for i = 1, #columns do
		entry[columns[i]] = row[i]
	end
	for i = 1, #numberColumns do
		entry[numberColumns[i]] = tonumber(entry[numberColumns[i]])
	end

	return entry
end

CacheDatabase.transformNoteChartEntry = function(self, entry)
	return self:transformEntry(entry, self.noteChartsColumns, self.noteChartsNumberColumns)
end

CacheDatabase.transformNoteChartSetEntry = function(self, entry)
	return self:transformEntry(entry, self.noteChartSetsColumns, self.noteChartSetsNumberColumns)
end

CacheDatabase.transformNoteChartDataEntry = function(self, entry)
	return self:transformEntry(entry, self.noteChartDatasColumns, self.noteChartDatasNumberColumns)
end



-- CacheDatabase.setNoteChartData = function(self, data)
-- 	self:insertNoteChartData(data)
-- 	self:updateNoteChartData(data)
-- end

-- CacheDatabase.insertNoteChartData = function(self, data)
-- 	return self.insertChartStatement:reset():bind(
-- 		data.setId,
-- 		data.hash,
-- 		data.path,
-- 		data.title,
-- 		data.artist,
-- 		data.source,
-- 		data.tags,
-- 		data.name,
-- 		data.level,
-- 		data.creator,
-- 		data.audioPath,
-- 		data.stagePath,
-- 		data.previewTime,
-- 		data.noteCount,
-- 		data.length,
-- 		data.bpm,
-- 		data.inputMode
-- 	):step()
-- end

-- CacheDatabase.updateNoteChartData = function(self, data)
-- 	return self.updateChartStatement:reset():bind(
-- 		data.setId,
-- 		data.hash,
-- 		data.path,
-- 		data.title,
-- 		data.artist,
-- 		data.source,
-- 		data.tags,
-- 		data.name,
-- 		data.level,
-- 		data.creator,
-- 		data.audioPath,
-- 		data.stagePath,
-- 		data.previewTime,
-- 		data.noteCount,
-- 		data.length,
-- 		data.bpm,
-- 		data.inputMode,
-- 		data.path
-- 	):step()
-- end

-- CacheDatabase.insertNoteChartData = function(self, path)
-- 	self:setChartData({
-- 		setId	= 0,
-- 		path		= path,
-- 		hash		= "",
-- 		title		= "",
-- 		artist		= "",
-- 		source		= "",
-- 		tags		= "",
-- 		name		= "",
-- 		level		= 0,
-- 		creator		= "",
-- 		audioPath	= "",
-- 		stagePath	= "",
-- 		previewTime	= 0,
-- 		noteCount	= 0,
-- 		length		= 0,
-- 		bpm			= 0,
-- 		inputMode	= ""
-- 	})
-- end

return CacheDatabase

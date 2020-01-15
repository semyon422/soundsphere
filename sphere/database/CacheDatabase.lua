local ThreadPool		= require("aqua.thread.ThreadPool")
local Log				= require("aqua.util.Log")
local sqlite			= require("ljsqlite3")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"
CacheDatabase.chartspath = "userdata/charts"

CacheDatabase.chartColumns = {
	"id",
	"chartSetId",
	"hash",
	"path",
	"title",
	"artist",
	"source",
	"tags",
	"name",
	"level",
	"creator",
	"audioPath",
	"stagePath",
	"previewTime",
	"noteCount",
	"length",
	"bpm",
	"inputMode"
}

CacheDatabase.chartSetColumns = {
	"id",
	"path"
}

CacheDatabase.chartNumberColumns = {
	"id",
	"chartSetId",
	"level",
	"previewTime",
	"noteCount",
	"length",
	"bpm"
}

CacheDatabase.chartSetNumberColumns = {
	"id"
}

local createTableRequest = [[
	CREATE TABLE IF NOT EXISTS `noteСhartDatas` (
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

	CREATE TABLE IF NOT EXISTS `noteСharts` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`path` TEXT NOT NULL UNIQUE,
		`hash` TEXT,
		`chartSetId` INTEGER,
		`lastModified` INTEGER
	);
	CREATE TABLE IF NOT EXISTS `noteChartSets` (
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`path` TEXT NOT NULL UNIQUE,
		`lastModified` INTEGER
	);
]]

----------------------------------------------------------------

local insertNoteChartRequest = [[
	INSERT OR IGNORE INTO `noteСharts` (
		`path`, `hash`, `chartSetId`, `lastModified`
	)
	VALUES (?, ?, ?, ?);
]]

local updateNoteChartRequest = [[
	UPDATE `noteСharts` SET
		`hash` = ?,
		`chartSetId` = ?,
		`lastModified` = ?
	WHERE `path` = ?;
]]

local selectNoteChartRequest = [[
	SELECT * FROM `noteСharts` WHERE `path` = ?
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
	
	self.db:exec(createTableRequest)
	
	self.insertNoteChartStatement = self.db:prepare(insertNoteChartRequest)
	self.updateNoteChartStatement = self.db:prepare(updateNoteChartRequest)
	self.selectNoteChartStatement = self.db:prepare(selectNoteChartRequest)

	self.insertNoteChartSetStatement = self.db:prepare(insertNoteChartSetRequest)
	self.updateNoteChartSetStatement = self.db:prepare(updateNoteChartSetRequest)
	self.selectNoteChartSetStatement = self.db:prepare(selectNoteChartSetRequest)

	-- self.deleteChartStatement = self.db:prepare(deleteChartRequest)
	-- self.deleteChartSetStatement = self.db:prepare(deleteChartSetRequest)
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
		entry.chartSetId,
		entry.lastModified
	):step()
end

CacheDatabase.updateNoteChartEntry = function(self, entry)
	return self.updateNoteChartStatement:reset():bind(
		entry.hash,
		entry.chartSetId,
		entry.lastModified,
		entry.path
	):step()
end

CacheDatabase.selectNoteChartEntry = function(self, path)
	return self.selectNoteChartStatement:reset():bind(path):step()
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
	return self.selectNoteChartSetStatement:reset():bind(path):step()
end

CacheDatabase.getNoteChartSetEntry = function(self, path)
	self.insertNoteChartSetStatement:reset():bind(path, nil):step()
	return self.selectNoteChartSetStatement:reset():bind(path):step()
end

----------------------------------------------------------------





-- CacheDatabase.setNoteChartData = function(self, data)
-- 	self:insertNoteChartData(data)
-- 	self:updateNoteChartData(data)
-- end

-- CacheDatabase.insertNoteChartData = function(self, data)
-- 	return self.insertChartStatement:reset():bind(
-- 		data.chartSetId,
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
-- 		data.chartSetId,
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
-- 		chartSetId	= 0,
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

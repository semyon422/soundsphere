local ThreadPool		= require("aqua.thread.ThreadPool")
local Log				= require("aqua.util.Log")
local sqlite			= require("ljsqlite3")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"
CacheDatabase.chartspath = "userdata/charts"

----------------------------------------------------------------

CacheDatabase.noteChartDatasColumns = {
	"id",
	"hash",
	"index",
	"format",
	"title",
	"artist",
	"source",
	"tags",
	"name",
	"creator",
	"level",
	"audioPath",
	"stagePath",
	"previewTime",
	"inputMode",
	"noteCount",
	"length",
	"bpm"
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
	"id",
	"index",
	"level",
	"previewTime",
	"noteCount",
	"length",
	"bpm"
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
		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`hash` TEXT NOT NULL,
		`index` REAL NOT NULL,
		`format` TEXT,
		`title` TEXT,
		`artist` TEXT,
		`source` TEXT,
		`tags` TEXT,
		`name` TEXT,
		`creator` TEXT,
		`level` REAL,
		`audioPath` TEXT,
		`stagePath` TEXT,
		`previewTime` REAL,
		`inputMode` TEXT,
		`noteCount` REAL,
		`length` REAL,
		`bpm` REAL,
		UNIQUE(`hash`, `index`)
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

local deleteNoteChartRequest = [[
	DELETE FROM `noteCharts` WHERE `path` = ?
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

local deleteNoteChartSetRequest = [[
	DELETE FROM `noteChartSets` WHERE `path` = ?
]]

----------------------------------------------------------------

local insertNoteChartDataRequest = [[
	INSERT OR IGNORE INTO `noteChartDatas` (
		`hash`,
		`index`,
		`format`,
		`title`,
		`artist`,
		`source`,
		`tags`,
		`name`,
		`creator`,
		`level`,
		`audioPath`,
		`stagePath`,
		`previewTime`,
		`inputMode`,
		`noteCount`,
		`length`,
		`bpm`
	)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
]]

local updateNoteChartDataRequest = [[
	UPDATE `noteChartDatas` SET
		`format` = ?,
		`title` = ?,
		`artist` = ?,
		`source` = ?,
		`tags` = ?,
		`name` = ?,
		`creator` = ?,
		`level` = ?,
		`audioPath` = ?,
		`stagePath` = ?,
		`previewTime` = ?,
		`inputMode` = ?,
		`noteCount` = ?,
		`length` = ?,
		`bpm` = ?
	WHERE `hash` = ? AND `index` = ?;
]]

local selectNoteChartDataRequest = [[
	SELECT * FROM `noteChartDatas` WHERE `hash` = ? AND `index` = ?;
]]

local selectAllNoteChartDatasRequest = [[
	SELECT * FROM `noteChartDatas`;
]]

----------------------------------------------------------------

CacheDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	local db = self.db
	
	db:exec(createTableRequest)
	
	self.insertNoteChartStatement = db:prepare(insertNoteChartRequest)
	self.updateNoteChartStatement = db:prepare(updateNoteChartRequest)
	self.selectNoteChartStatement = db:prepare(selectNoteChartRequest)
	self.deleteNoteChartStatement = db:prepare(deleteNoteChartRequest)
	self.selectAllNoteChartsStatement = db:prepare(selectAllNoteChartsRequest)

	self.insertNoteChartSetStatement = db:prepare(insertNoteChartSetRequest)
	self.updateNoteChartSetStatement = db:prepare(updateNoteChartSetRequest)
	self.selectNoteChartSetStatement = db:prepare(selectNoteChartSetRequest)
	self.deleteNoteChartSetStatement = db:prepare(deleteNoteChartSetRequest)
	self.selectAllNoteChartSetsStatement = db:prepare(selectAllNoteChartSetsRequest)

	self.insertNoteChartDataStatement = db:prepare(insertNoteChartDataRequest)
	self.updateNoteChartDataStatement = db:prepare(updateNoteChartDataRequest)
	self.selectNoteChartDataStatement = db:prepare(selectNoteChartDataRequest)
	self.selectAllNoteChartDatasStatement = db:prepare(selectAllNoteChartDatasRequest)

	self.loaded = true
end

CacheDatabase.unload = function(self)
	self.loaded = false
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:exec("BEGIN;")
end

CacheDatabase.commit = function(self)
	return self.db:exec("COMMIT;")
end

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

CacheDatabase.deleteNoteChartEntry = function(self, path)
	return self.deleteNoteChartStatement:reset():bind(path):step()
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
	return self.updateNoteChartSetStatement:reset():bind(
		entry.lastModified,
		entry.path
	):step()
end

CacheDatabase.selectNoteChartSetEntry = function(self, path)
	local entry = self.selectNoteChartSetStatement:reset():bind(path):step()
	return self:transformNoteChartSetEntry(entry)
end

CacheDatabase.deleteNoteChartSetEntry = function(self, path)
	return self.deleteNoteChartSetStatement:reset():bind(path):step()
end

CacheDatabase.getNoteChartSetEntry = function(self, entry)
	self:insertNoteChartSetEntry(entry)
	self:updateNoteChartSetEntry(entry)
	return self:selectNoteChartSetEntry(entry.path)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartDataEntry = function(self, entry)
	return self.insertNoteChartDataStatement:reset():bind(
		entry.hash,
		entry.index,
		entry.format,
		entry.title,
		entry.artist,
		entry.source,
		entry.tags,
		entry.name,
		entry.creator,
		entry.level,
		entry.audioPath,
		entry.stagePath,
		entry.previewTime,
		entry.inputMode,
		entry.noteCount,
		entry.length,
		entry.bpm
	):step()
end

CacheDatabase.updateNoteChartDataEntry = function(self, entry)
	return self.updateNoteChartDataStatement:reset():bind(
		entry.format,
		entry.title,
		entry.artist,
		entry.source,
		entry.tags,
		entry.name,
		entry.creator,
		entry.level,
		entry.audioPath,
		entry.stagePath,
		entry.previewTime,
		entry.inputMode,
		entry.noteCount,
		entry.length,
		entry.bpm,
		entry.hash,
		entry.index
	):step()
end

CacheDatabase.selectNoteCharDatatEntry = function(self, hash, index)
	local entry = self.selectNoteChartDataStatement:reset():bind(hash, index):step()
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
		entry[columns[i]] = row[i] or ""
	end
	for i = 1, #numberColumns do
		entry[numberColumns[i]] = tonumber(entry[numberColumns[i]]) or 0
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

return CacheDatabase

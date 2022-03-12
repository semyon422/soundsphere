local Orm = require("sphere.Orm")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"

CacheDatabase.load = function(self)
	local db = Orm:new()
	self.db = db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/CacheModel/database.sql"))
	self.loaded = true
	db:table_info("noteCharts")
end

CacheDatabase.unload = function(self)
	self.loaded = false
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:begin()
end

CacheDatabase.commit = function(self)
	return self.db:commit()
end

----------------------------------------------------------------

CacheDatabase.selectAllNoteCharts = function(self)
	return self.db:select("noteCharts")
end

CacheDatabase.selectAllNoteChartSets = function(self)
	return self.db:select("noteChartSets")
end

CacheDatabase.selectAllNoteChartDatas = function(self)
	return self.db:select("noteChartDatas")
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartEntry = function(self, entry)
	return self.db:insert("noteCharts", entry, true)
end

CacheDatabase.updateNoteChartEntry = function(self, entry)
	return self.db:update("noteCharts", entry, "path = ?", entry.path)
end

CacheDatabase.selectNoteChartEntry = function(self, path)
	return self.db:select("noteCharts", "path = ?", path)[1]
end

CacheDatabase.deleteNoteChartEntry = function(self, path)
	return self.db:delete("noteCharts", "path = ?", path)
end

CacheDatabase.getNoteChartsAtSet = function(self, setId)
	return self.db:select("noteCharts", "setId = ?", setId)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartSetEntry = function(self, entry)
	return self.db:insert("noteChartSets", entry, true)
end

CacheDatabase.updateNoteChartSetEntry = function(self, entry)
	return self.db:update("noteChartSets", entry, "path = ?", entry.path)
end

CacheDatabase.selectNoteChartSetEntry = function(self, path)
	return self.db:select("noteChartSets", "path = ?", path)[1]
end

CacheDatabase.deleteNoteChartSetEntry = function(self, path)
	return self.db:delete("noteChartSets", "path = ?", path)
end

CacheDatabase.selectNoteChartSets = function(self, path)
	return self.db:select("noteChartSets", "substr(path, 1, ?) = ?", #path, path)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartDataEntry = function(self, entry)
	return self.db:insert("noteChartDatas", entry, true)
end

CacheDatabase.updateNoteChartDataEntry = function(self, entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

CacheDatabase.selectNoteCharDataEntry = function(self, hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

----------------------------------------------------------------

CacheDatabase.selectAllIdPairs = function(self, orders, conditions, ...)
	return self.db:query(([[
		SELECT noteCharts.id AS noteChartId, noteChartDatas.id AS noteChartDataId
		FROM noteCharts
		INNER JOIN noteChartDatas ON noteCharts.hash = noteChartDatas.hash
		%s
		ORDER BY %s
	]]):format(
		conditions and "WHERE " .. conditions or "",
		orders
	), ...) or {}
end

CacheDatabase.selectPairs = function(self, orders, conditions, ...)
	return self.db:query(([[
		SELECT noteChartDatas.*, noteCharts.id AS noteChartId, noteCharts.path AS path
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		%s
		ORDER BY %s
	]]):format(
		conditions and "WHERE " .. conditions or "",
		orders
	), ...) or {}
end

return CacheDatabase

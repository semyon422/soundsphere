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

CacheDatabase.setNoteChartEntry = function(self, entry)
	self:insertNoteChartEntry(entry)
	return self:updateNoteChartEntry(entry)
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

CacheDatabase.getNoteChartSetEntry = function(self, entry)
	self:insertNoteChartSetEntry(entry)
	self:updateNoteChartSetEntry(entry)
	return self:selectNoteChartSetEntry(entry.path)
end

----------------------------------------------------------------

CacheDatabase.insertNoteChartDataEntry = function(self, entry)
	return self.db:insert("noteChartDatas", entry, true)
end

CacheDatabase.updateNoteChartDataEntry = function(self, entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

CacheDatabase.selectNoteCharDatatEntry = function(self, hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

CacheDatabase.setNoteChartDataEntry = function(self, entry)
	self:insertNoteChartDataEntry(entry)
	return self:updateNoteChartDataEntry(entry)
end

return CacheDatabase

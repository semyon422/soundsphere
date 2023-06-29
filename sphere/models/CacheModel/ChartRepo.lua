local Class = require("Class")
local Orm = require("sphere.Orm")
local utf8 = require("utf8")

local CacheRepo = Class:new()

CacheRepo.dbpath = "userdata/charts.db"

CacheRepo.load = function(self)
	if self.loaded then
		return
	end
	self.loaded = true

	self.db = Orm:new()
	local db = self.db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/CacheModel/database.sql"))
end

CacheRepo.unload = function(self)
	if not self.loaded then
		return
	end
	self.loaded = false
	return self.db:close()
end

CacheRepo.begin = function(self)
	return self.db:begin()
end

CacheRepo.commit = function(self)
	return self.db:commit()
end

----------------------------------------------------------------

CacheRepo.insertNoteChartEntry = function(self, entry)
	return self.db:insert("noteCharts", entry, true)
end

CacheRepo.updateNoteChartEntry = function(self, entry)
	return self.db:update("noteCharts", entry, "path = ?", entry.path)
end

CacheRepo.selectNoteChartEntry = function(self, path)
	return self.db:select("noteCharts", "path = ?", path)[1]
end

CacheRepo.selectNoteChartEntryById = function(self, id)
	return self.db:select("noteCharts", "id = ?", id)[1]
end

CacheRepo.deleteNoteChartEntry = function(self, path)
	return self.db:delete("noteCharts", "path = ?", path)
end

CacheRepo.getNoteChartsAtSet = function(self, setId)
	return self.db:select("noteCharts", "setId = ?", setId)
end

----------------------------------------------------------------

CacheRepo.insertNoteChartSetEntry = function(self, entry)
	return self.db:insert("noteChartSets", entry, true)
end

CacheRepo.updateNoteChartSetEntry = function(self, entry)
	return self.db:update("noteChartSets", entry, "path = ?", entry.path)
end

CacheRepo.selectNoteChartSetEntry = function(self, path)
	return self.db:select("noteChartSets", "path = ?", path)[1]
end

CacheRepo.selectNoteChartSetEntryById = function(self, id)
	return self.db:select("noteChartSets", "id = ?", id)[1]
end

CacheRepo.deleteNoteChartSetEntry = function(self, path)
	return self.db:delete("noteChartSets", "path = ?", path)
end

CacheRepo.selectNoteChartSets = function(self, path)
	return self.db:select("noteChartSets", "substr(path, 1, ?) = ?", utf8.len(path), path)
end

----------------------------------------------------------------

CacheRepo.insertNoteChartDataEntry = function(self, entry)
	return self.db:insert("noteChartDatas", entry, true)
end

CacheRepo.updateNoteChartDataEntry = function(self, entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

CacheRepo.selectNoteCharDataEntry = function(self, hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

CacheRepo.selectNoteChartDataEntryById = function(self, id)
	return self.db:select("noteChartDatas", "id = ?", id)[1]
end

return CacheRepo

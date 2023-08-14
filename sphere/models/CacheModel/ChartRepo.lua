local class = require("class")
local Orm = require("sphere.Orm")
local utf8 = require("utf8")

local CacheRepo = class()

CacheRepo.dbpath = "userdata/charts.db"

function CacheRepo:load()
	if self.loaded then
		return
	end
	self.loaded = true

	self.db = Orm()
	local db = self.db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/CacheModel/database.sql"))
end

function CacheRepo:unload()
	if not self.loaded then
		return
	end
	self.loaded = false
	return self.db:close()
end

function CacheRepo:begin()
	return self.db:begin()
end

function CacheRepo:commit()
	return self.db:commit()
end

----------------------------------------------------------------

function CacheRepo:insertNoteChartEntry(entry)
	return self.db:insert("noteCharts", entry, true)
end

function CacheRepo:updateNoteChartEntry(entry)
	return self.db:update("noteCharts", entry, "path = ?", entry.path)
end

function CacheRepo:selectNoteChartEntry(path)
	return self.db:select("noteCharts", "path = ?", path)[1]
end

function CacheRepo:selectNoteChartEntryById(id)
	return self.db:select("noteCharts", "id = ?", id)[1]
end

function CacheRepo:deleteNoteChartEntry(path)
	return self.db:delete("noteCharts", "path = ?", path)
end

function CacheRepo:getNoteChartsAtSet(setId)
	return self.db:select("noteCharts", "setId = ?", setId)
end

----------------------------------------------------------------

function CacheRepo:insertNoteChartSetEntry(entry)
	return self.db:insert("noteChartSets", entry, true)
end

function CacheRepo:updateNoteChartSetEntry(entry)
	return self.db:update("noteChartSets", entry, "path = ?", entry.path)
end

function CacheRepo:selectNoteChartSetEntry(path)
	return self.db:select("noteChartSets", "path = ?", path)[1]
end

function CacheRepo:selectNoteChartSetEntryById(id)
	return self.db:select("noteChartSets", "id = ?", id)[1]
end

function CacheRepo:deleteNoteChartSetEntry(path)
	return self.db:delete("noteChartSets", "path = ?", path)
end

function CacheRepo:selectNoteChartSets(path)
	return self.db:select("noteChartSets", "substr(path, 1, ?) = ?", utf8.len(path), path)
end

----------------------------------------------------------------

function CacheRepo:insertNoteChartDataEntry(entry)
	return self.db:insert("noteChartDatas", entry, true)
end

function CacheRepo:updateNoteChartDataEntry(entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

function CacheRepo:selectNoteCharDataEntry(hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

function CacheRepo:selectNoteChartDataEntryById(id)
	return self.db:select("noteChartDatas", "id = ?", id)[1]
end

return CacheRepo

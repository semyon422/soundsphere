local class = require("class")
local Orm = require("sphere.Orm")
local utf8 = require("utf8")

---@class sphere.CacheRepo
---@operator call: sphere.CacheRepo
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
	local sql = love.filesystem.read("sphere/models/CacheModel/database.sql")
	db:exec(sql)
end

function CacheRepo:unload()
	if not self.loaded then
		return
	end
	self.loaded = false
	self.db:close()
end

function CacheRepo:begin()
	self.db:begin()
end

function CacheRepo:commit()
	self.db:commit()
end

----------------------------------------------------------------

---@param entry table
---@return table
function CacheRepo:insertNoteChartEntry(entry)
	return self.db:insert("noteCharts", entry, true)
end

---@param entry table
---@return table?
function CacheRepo:updateNoteChartEntry(entry)
	return self.db:update("noteCharts", entry, "path = ?", entry.path)
end

---@param path string
---@return table?
function CacheRepo:selectNoteChartEntry(path)
	return self.db:select("noteCharts", "path = ?", path)[1]
end

---@param id number
---@return table?
function CacheRepo:selectNoteChartEntryById(id)
	return self.db:select("noteCharts", "id = ?", id)[1]
end

---@param path string
function CacheRepo:deleteNoteChartEntry(path)
	self.db:delete("noteCharts", "path = ?", path)
end

---@param setId number
---@return table
function CacheRepo:getNoteChartsAtSet(setId)
	return self.db:select("noteCharts", "setId = ?", setId)
end

----------------------------------------------------------------

---@param entry table
---@return table
function CacheRepo:insertNoteChartSetEntry(entry)
	return self.db:insert("noteChartSets", entry, true)
end

---@param entry table
---@return table?
function CacheRepo:updateNoteChartSetEntry(entry)
	return self.db:update("noteChartSets", entry, "path = ?", entry.path)
end

---@param path string
---@return table?
function CacheRepo:selectNoteChartSetEntry(path)
	return self.db:select("noteChartSets", "path = ?", path)[1]
end

---@param id number
---@return table?
function CacheRepo:selectNoteChartSetEntryById(id)
	return self.db:select("noteChartSets", "id = ?", id)[1]
end

---@param path string
function CacheRepo:deleteNoteChartSetEntry(path)
	self.db:delete("noteChartSets", "path = ?", path)
end

---@param path string
---@return table
function CacheRepo:selectNoteChartSets(path)
	return self.db:select("noteChartSets", "substr(path, 1, ?) = ?", utf8.len(path), path)
end

----------------------------------------------------------------

---@param entry table
---@return table
function CacheRepo:insertNoteChartDataEntry(entry)
	return self.db:insert("noteChartDatas", entry, true)
end

---@param entry table
---@return table?
function CacheRepo:updateNoteChartDataEntry(entry)
	return self.db:update("noteChartDatas", entry, "hash = ? and `index` = ?", entry.hash, entry.index)
end

---@param hash string
---@param index number
---@return table?
function CacheRepo:selectNoteCharDataEntry(hash, index)
	return self.db:select("noteChartDatas", "hash = ? and `index` = ?", hash, index)[1]
end

---@param id number
---@return table?
function CacheRepo:selectNoteChartDataEntryById(id)
	return self.db:select("noteChartDatas", "id = ?", id)[1]
end

return CacheRepo

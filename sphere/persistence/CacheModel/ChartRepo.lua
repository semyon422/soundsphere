local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

---@class sphere.ChartRepo
---@operator call: sphere.ChartRepo
local ChartRepo = class()

ChartRepo.dbpath = "userdata/charts.db"

function ChartRepo:load()
	if self.loaded then
		return
	end
	self.loaded = true

	local db = LjsqliteDatabase()
	self.db = db

	db:open(self.dbpath)
	local sql = love.filesystem.read("sphere/persistence/CacheModel/database.sql")
	db:exec(sql)

	local _models = autoload("sphere.persistence.CacheModel.models")
	local orm = TableOrm(db)
	local models = Models(_models, orm)

	self.orm = orm
	self.models = models
end

function ChartRepo:unload()
	if not self.loaded then
		return
	end
	self.loaded = false
	self.db:close()
end

function ChartRepo:begin()
	-- self.db:begin()
end

function ChartRepo:commit()
	-- self.db:commit()
end

----------------------------------------------------------------

---@param entry table
function ChartRepo:insertNoteChartEntry(entry)
	self.models.noteCharts:create(entry, true)
end

---@param entry table
function ChartRepo:updateNoteChartEntry(entry)
	self.models.noteCharts:update(entry, {path = entry.path})
end

---@param path string
---@return rdb.ModelRow?
function ChartRepo:selectNoteChartEntry(path)
	return self.models.noteCharts:find({path = path})
end

---@param id number
---@return rdb.ModelRow?
function ChartRepo:selectNoteChartEntryById(id)
	return self.models.noteCharts:find({id = id})
end

---@param path string
function ChartRepo:deleteNoteChartEntry(path)
	self.models.noteCharts:delete({path = path})
end

---@param setId number
---@return rdb.ModelRow[]
function ChartRepo:getNoteChartsAtSet(setId)
	return self.models.noteCharts:select({setId = setId})
end

---@param hashes table
---@return rdb.ModelRow[]
function ChartRepo:getNoteChartsByHashes(hashes)
	return self.models.noteCharts:select({hash__in = hashes})
end

----------------------------------------------------------------

---@param entry table
---@return rdb.ModelRow?
function ChartRepo:insertNoteChartSetEntry(entry)
	return self.models.noteChartSets:create(entry, true)
end

---@param entry table
function ChartRepo:updateNoteChartSetEntry(entry)
	self.models.noteChartSets:update(entry, {path = entry.path})
end

---@param path string
---@return rdb.ModelRow?
function ChartRepo:selectNoteChartSetEntry(path)
	return self.models.noteChartSets:find({path = path})
end

---@param id number
---@return rdb.ModelRow?
function ChartRepo:selectNoteChartSetEntryById(id)
	return self.models.noteChartSets:find({id = id})
end

---@param path string
function ChartRepo:deleteNoteChartSetEntry(path)
	self.models.noteChartSets:delete({path = path})
end

---@param path string
---@return rdb.ModelRow[]
function ChartRepo:selectNoteChartSets(path)
	return self.models.noteChartSets:select({path__startswith = path})
end

----------------------------------------------------------------

---@param entry table
function ChartRepo:insertNoteChartDataEntry(entry)
	self.models.noteChartDatas:create(entry, true)
end

---@param entry table
function ChartRepo:updateNoteChartDataEntry(entry)
	self.models.noteChartDatas:update(entry, {hash = entry.hash, index = entry.index})
end

---@param hash string
---@param index number
---@return rdb.ModelRow?
function ChartRepo:selectNoteCharDataEntry(hash, index)
	return self.models.noteChartDatas:select({hash = hash, index = index})
end

---@param id number
---@return rdb.ModelRow?
function ChartRepo:selectNoteChartDataEntryById(id)
	return self.models.noteChartDatas:find({id = id})
end

return ChartRepo

local Orm = require("sphere.Orm")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"

CacheDatabase.load = function(self)
	local db = Orm:new()
	self.db = db
	db:open(self.dbpath)
	db:exec(love.filesystem.read("sphere/models/CacheModel/database.sql"))
	self.loaded = true

	-- print(require("inspect")(self:selectAllIdPairs("noteCharts.setId DESC", "noteCharts.id < ?", 10)))
	-- print(require("inspect")(self:selectPairs("level DESC")))
	-- print(require("inspect")(self:selectAllIdPairs("level DESC")))

	self.noteCharts = setmetatable({}, {__mode = "v"})
	self.noteChartDatas = setmetatable({}, {__mode = "v"})
	self.noteChartSets = setmetatable({}, {__mode = "v"})
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

CacheDatabase.getNoteChartData = function(self, id)
	local noteChartData = self.noteChartDatas[id]
	if noteChartData then
		return noteChartData
	end
	noteChartData = self.db:select("noteChartDatas", "id = ?", id)[1]
	self.noteChartDatas[id] = noteChartData
	return noteChartData
end

CacheDatabase.getNoteChart = function(self, id)
	local noteChart = self.noteCharts[id]
	if noteChart then
		return noteChart
	end
	noteChart = self.db:select("noteCharts", "id = ?", id)[1]
	self.noteCharts[id] = noteChart
	return noteChart
end

CacheDatabase.getNoteChartSet = function(self, id)
	local noteChartSet = self.noteChartSets[id]
	if noteChartSet then
		return noteChartSet
	end
	noteChartSet = self.db:select("noteChartSets", "id = ?", id)[1]
	self.noteChartSets[id] = noteChartSet
	return noteChartSet
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
		SELECT noteChartDatas.id AS noteChartDataId, noteCharts.id AS noteChartId, noteCharts.setId
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		%s
		ORDER BY %s
	]]):format(
		conditions and "WHERE " .. conditions or "",
		orders
	), ...) or {}
end

CacheDatabase.selectPairs = function(self, orders, conditions, ...)
	return self.db:query(([[
		SELECT noteChartDatas.*, noteCharts.id AS noteChartId, noteCharts.path, noteCharts.setId
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		%s
		ORDER BY %s
	]]):format(
		conditions and "WHERE " .. conditions or "",
		orders
	), ...) or {}
end

--[[
	SELECT * FROM
	(
		SELECT ROW_NUMBER() OVER(ORDER BY noteChartDatas.title ASC) AS pos, noteCharts.id as ncId, noteChartDatas.id as ncdId, noteCharts.setId
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		WHERE ncId > 100
	) A
	WHERE ncId = 2406 and ncdId = 2961 and setId = 612;
]]

--[[
    SELECT ROW_NUMBER() OVER(ORDER BY noteChartDatas.title ASC) AS pos, noteCharts.id as ncId, noteChartDatas.id as ncdId, noteCharts.setId,
    CASE WHEN difficulty > 10 THEN 'hard'
    ELSE 'easy'
    END diff
    FROM noteChartDatas
	INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
	WHERE ncId > 100
]]

return CacheDatabase

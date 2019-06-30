local sqlite = require("ljsqlite3")
local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local CacheDataFactory = require("sphere.game.NoteChartManager.CacheDataFactory")
local CacheDatabase = require("sphere.game.NoteChartManager.CacheDatabase")

local Cache = {}

Cache.load = function(self)
end

Cache.selectChartsRequest = [[
	SELECT * FROM `charts`;
]]

Cache.selectChartSetsRequest = [[
	SELECT * FROM `chartSets`;
]]

Cache.selectPacksRequest = [[
	SELECT * FROM `packs`;
]]

Cache.select = function(self)
	CacheDatabase:load()
	
	self.db = CacheDatabase.db
	self.selectChartsStatement = self.db:prepare(self.selectChartsRequest)
	self.selectChartSetsStatement = self.db:prepare(self.selectChartSetsRequest)
	self.selectPacksStatement = self.db:prepare(self.selectPacksRequest)
	
	local chartList = {}
	local chartSetList = {}
	local packList = {}
	self.chartList = chartList
	self.chartSetList = chartSetList
	self.packList = packList
	
	local chartColumns = CacheDatabase.chartColumns
	local chartSetColumns = CacheDatabase.chartSetColumns
	local packColumns = CacheDatabase.packColumns
	
	local stmt = self.selectPacksStatement:reset()
	local row = stmt:step()
	while row do
		local packData = {}
		for i = 1, #packColumns do
			packData[packColumns[i]] = row[i]
		end
		packList[#packList + 1] = packData
		row = stmt:step()
	end
	
	local stmt = self.selectChartSetsStatement:reset()
	local row = stmt:step()
	while row do
		local chartSetData = {}
		for i = 1, #chartSetColumns do
			chartSetData[chartSetColumns[i]] = row[i]
		end
		chartSetList[#chartSetList + 1] = chartSetData
		row = stmt:step()
	end
	
	local stmt = self.selectChartsStatement:reset()
	local row = stmt:step()
	while row do
		local chartData = {}
		for i = 1, #chartColumns do
			chartData[chartColumns[i]] = row[i]
		end
		chartList[#chartList + 1] = chartData
		row = stmt:step()
	end
	
	local chartDict = {}
	local chartSetDict = {}
	local packDict = {}
	self.chartDict = chartDict
	self.chartSetDict = chartSetDict
	self.packDict = packDict
	
	for _, chartData in ipairs(chartList) do
		chartDict[chartData.id] = chartData
	end
	for _, chartSetData in ipairs(chartSetList) do
		chartSetDict[chartSetData.id] = chartSetData
	end
	for _, packData in ipairs(packList) do
		packDict[packData.id] = packData
	end
	
	CacheDatabase:unload()
end

Cache.update = function(self, path, recursive, callback)
	CacheDatabase:update(path, recursive, callback)
end

return Cache

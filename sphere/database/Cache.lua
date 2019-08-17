local CacheDatabase = require("sphere.database.CacheDatabase")

local Cache = {}

local selectChartsRequest = [[
	SELECT * FROM `charts`;
]]

local selectChartSetsRequest = [[
	SELECT * FROM `chartSets`;
]]

Cache.select = function(self)
	if self.lock then
		return
	end
	
	CacheDatabase:load()
	
	local db = CacheDatabase.db
	local selectChartsStatement = db:prepare(selectChartsRequest)
	local selectChartSetsStatement = db:prepare(selectChartSetsRequest)
	
	local chartList = {}
	local chartSetList = {}
	self.chartList = chartList
	self.chartSetList = chartSetList
	
	local chartColumns = CacheDatabase.chartColumns
	local chartSetColumns = CacheDatabase.chartSetColumns
	local chartNumberColumns = CacheDatabase.chartNumberColumns
	local chartSetNumberColumns = CacheDatabase.chartSetNumberColumns
	
	local stmt = selectChartSetsStatement:reset()
	local row = stmt:step()
	while row do
		local chartSetData = {}
		for i = 1, #chartSetColumns do
			chartSetData[chartSetColumns[i]] = row[i]
		end
		for i = 1, #chartSetNumberColumns do
			chartSetData[chartSetNumberColumns[i]] = tonumber(chartSetData[chartSetNumberColumns[i]])
		end
		chartSetList[#chartSetList + 1] = chartSetData
		row = stmt:step()
	end
	
	local stmt = selectChartsStatement:reset()
	local row = stmt:step()
	while row do
		local chartData = {}
		for i = 1, #chartColumns do
			chartData[chartColumns[i]] = row[i]
		end
		for i = 1, #chartNumberColumns do
			chartData[chartNumberColumns[i]] = tonumber(chartData[chartNumberColumns[i]])
		end
		chartList[#chartList + 1] = chartData
		row = stmt:step()
	end
	
	local chartDict = {}
	local chartSetDict = {}
	self.chartDict = chartDict
	self.chartSetDict = chartSetDict
	
	for _, chartData in ipairs(chartList) do
		chartDict[chartData.id] = chartData
	end
	for _, chartSetData in ipairs(chartSetList) do
		chartSetDict[chartSetData.id] = chartSetData
	end
	
	local chartsAtSet = {}
	self.chartsAtSet = chartsAtSet
	
	for _, chartData in ipairs(chartList) do
		chartsAtSet[chartData.chartSetId] = chartsAtSet[chartData.chartSetId] or {}
		local list = chartsAtSet[chartData.chartSetId]
		list[#list + 1] = chartData
	end
	
	CacheDatabase:unload()
end

Cache.update = function(self, path, recursive)
	self.lock = true
	return CacheDatabase:update(path, recursive, function()
		self.lock = false
		self:select()
	end)
end

return Cache

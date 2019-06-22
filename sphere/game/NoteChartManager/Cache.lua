local sqlite = require("ljsqlite3")
local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local CacheDataFactory = require("sphere.game.NoteChartManager.CacheDataFactory")
local CacheDatabase = require("sphere.game.NoteChartManager.CacheDatabase")

local Cache = {}

Cache.load = function(self)
	self.cacheDatas = {}
	self.containers = {}
	self.db = CacheDatabase.db
	self.selectStatement = self.db:prepare(self.selectRequest)
end

Cache.selectRequest = [[
	SELECT * FROM `cache` ORDER BY `path`;
]]

Cache.select = function(self)
	local cacheDatas = {}
	
	local colnames = CacheDatabase.colnames
	local stmt = self.selectStatement:reset()
	local row = stmt:step()
	while row do
		local cacheData = {}
		for i = 1, #colnames do
			cacheData[colnames[i]] = row[i]
		end
		cacheDatas[#cacheDatas + 1] = cacheData
		row = stmt:step()
	end
	
	self.cacheDatas = cacheDatas
	
	local containers = {}
	for i = 1, #cacheDatas do
		local cacheData = cacheDatas[i]
		if cacheData.container == 0 then
			local parentPath = cacheData.path:match("^(.+)/.-$")
			containers[parentPath] = containers[parentPath] or {}
			table.insert(containers[parentPath], cacheData)
		end
	end
	
	self.containers = containers
end

return Cache

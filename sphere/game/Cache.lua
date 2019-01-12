local sqlite = require("ljsqlite3")
local NoteChartFactory = require("sphere.game.NoteChartFactory")
local ThreadPool = require("aqua.thread.ThreadPool")
local leftequal = require("aqua.table").leftequal

local isNoteChart = function(path) return NoteChartFactory:isNoteChart(path) end
local getNoteChart = function(path) return NoteChartFactory:getNoteChart(path) end

local Cache = {}

Cache.dbpath = "userdata/cache.sqlite"
Cache.chartspath = "userdata/charts"

Cache.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec[[
		CREATE TABLE IF NOT EXISTS `cache` (
			`path` TEXT,
			`hash` TEXT,
			`container` INTEGER,
			
			`title` TEXT,
			`artist` TEXT,
			`source` TEXT,
			`tags` TEXT,

			`name` TEXT,
			`creator` TEXT,

			`audioPath` TEXT,
			`stagePath` TEXT,
			`previewTime` REAL,
			`noteCount` INTEGER,
			`length` REAL,
			`bpm` REAL,
			`nps` REAL,
			`inputMode` TEXT,
			PRIMARY KEY (`path`)
		);
	]]
	
	self.db:setscalar("CHECKVISIBLE", function(...) return self:checkVisible(...) end)
	
	self.insertStatement = self.db:prepare([[
		INSERT INTO `cache` (
			path,
			hash,
			container,
			title,
			artist,
			source,
			tags,
			name,
			creator,
			audioPath,
			stagePath,
			previewTime,
			noteCount,
			length,
			bpm,
			nps,
			inputMode
		)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	]])
	self.setContainerStatement = self.db:prepare([[
		INSERT OR IGNORE INTO `cache` (path, container, name)
		VALUES (?, -1, '');
	]])
	self.updateContainerStatement = self.db:prepare([[
		UPDATE `cache` SET `container` = ? WHERE `path` == ?;
	]])
	
	self.rowByPathStatement = self.db:prepare([[
		SELECT * FROM `cache` WHERE path == ?
	]])
end

Cache.update = function(self, path, recursive, callback)
	if not self.isUpdating then
		ThreadPool:execute(
			[[
				local path, recursive = ...
				local Cache = require("sphere.game.Cache")
				Cache:clean(path)
				Cache:lookup(path, recursive)
			]],
			{},
			function()
				callback()
				self.isUpdating = false
			end
		)
		self.isUpdating = true
	end
	self:lookup(path, recursive)
	self:clean(path)
end

Cache.checkVisible = function(self, path)
	local subkey = path:split("/")
	table.remove(subkey, #subkey)
	if leftequal(subkey, self.selectionKey) then
		return 1
	else
		return 0
	end
end

Cache.rowByPath = function(self, path)
	return self.rowByPathStatement:reset():bind(path):step()
end

Cache.setContainer = function(self, path, container)
	self.setContainerStatement:reset():bind(path):step()
	self.updateContainerStatement:reset():bind(container, path):step()
end

Cache.addChart = function(self, ...)
	self.insertStatement:reset():bind(...):step()
end

Cache.clean = function(self, directoryPath)
	self.selectionKey = directoryPath:split("/")
	local result = self.db:exec("SELECT * FROM `cache` WHERE CHECKVISIBLE(path) ORDER BY `path`;")
	
	local row = 1
	if result then
		while result.path[row] do
			local path = result.path[row]
			if not love.filesystem.exists(path) then
				self.db:exec("DELETE FROM `cache` WHERE `path` == " .. string.format("%q", path) .. ";")
			end
			
			row = row + 1
		end
	end
end

Cache.lookup = function(self, directoryPath, recursive)
	if love.filesystem.isFile(directoryPath) then
		return -1
	end
	
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local charts = 0
	local containers = 0
	
	local extensionType
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		extensionType = self:getExtensionType(path)
		if love.filesystem.isFile(path) and extensionType then
			if not self:rowByPath(path) then
				if self:processFile(directoryPath, itemName, extensionType) == 0 then
					charts = charts + 1
				else
					containers = containers + 1
				end
			else
				charts = 1
			end
		end
	end
	
	if charts > 0 then
		self:setContainer(directoryPath, 1)
		return 1
	end
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) and (recursive or not self:rowByPath(path)) then
			if self:lookup(path, true) > 0 then
				containers = containers + 1
			end
		end
	end
	
	if containers > 0 then
		self:setContainer(directoryPath, 2)
		return 2
	end
	
	return -1
end

Cache.getCacheDataFilePath = function(self, cacheData)
	return cacheData.directoryPath .. "/" .. cacheData.fileName
end

Cache.select = function(self)
	local data = {}
	
	for _, cacheData in pairs(self.data) do
		table.insert(data, cacheData)
	end
	
	local cacheDataIndex = 1
	
	return function()
		local cacheData = data[cacheDataIndex]
		cacheDataIndex = cacheDataIndex + 1
		
		return cacheData
	end
end

Cache.extensions = {
	{
		type = "osu",
		patterns = {
			"%.osu$"
		}
	},
	{
		type = "bms",
		patterns = {
			"%.bms$", "%.bme$", "%.bml$", 
		}
	},
	{
		type = "o2jam",
		patterns = {
			"%.ojn$"
		}
	},
	-- {
		-- type = "ucs",
		-- patterns = {
			-- "%.ucs$"
		-- }
	-- },
	-- {
		-- type = "jnc",
		-- patterns = {
			-- "%.jnc$"
		-- }
	-- }
}

Cache.isNoteChart = function(self, path)
	return self:getExtensionType(path)
end

Cache.getExtensionType = function(self, fileName)
	for _, extensionData in ipairs(self.extensions) do
		for _, pattern in ipairs(extensionData.patterns) do
			if fileName:find(pattern) then
				return extensionData.type
			end
		end
	end
end

Cache.processFile = function(self, directoryPath, fileName, extensionType)
	print("processing file", fileName)
	
	if extensionType == "bms" then
		return self:generateBMSCacheData(directoryPath, fileName)
	elseif extensionType == "osu" then
		return self:generateOsuCacheData(directoryPath, fileName)
	elseif extensionType == "ucs" then
		return self:generateUCSCacheData(directoryPath, fileName)
	elseif extensionType == "jnc" then
		return self:generateJNCCacheData(directoryPath, fileName)
	elseif extensionType == "o2jam" then
		return self:generateOJNCacheData(directoryPath, fileName)
	end
end

Cache.addCacheData = function(self, cacheData)
	table.insert(self.data, cacheData)
	self.dataDict[self:getCacheDataFilePath(cacheData)] = cacheData
end


local iconv = require("iconv")
local fix = function(line)
	return iconv(line, "UTF-8", "SHIFT-JIS") or iconv(line, "UTF-8", "EUC-KR") or iconv(line, "UTF-8", "US-ASCII") or line
end

Cache.generateBMSCacheData = function(self, directoryPath, fileName)
	local path = ("%s/%s"):format(directoryPath, fileName)
	local noteChart = getNoteChart(path)
	self:addChart(
		path,
		"",
		0,
		fix(noteChart:hashGet("TITLE") or "title"),
		fix(noteChart:hashGet("ARTIST") or "artist"),
		"BMS",
		"",
		fix(noteChart:hashGet("PLAYLEVEL") or ""),
		"",
		"",
		fix(noteChart:hashGet("STAGEFILE") or ""),
		0,
		1000,
		300,
		120,
		0,
		noteChart.inputMode:getString()
	)
	
	return 0
end

Cache.generateOsuCacheData = function(self, directoryPath, fileName)
	local path = ("%s/%s"):format(directoryPath, fileName)
	local noteChart = getNoteChart(path)
	self:addChart(
		path,
		"",
		0,
		fix(noteChart:hashGet("Title") or "title"),
		fix(noteChart:hashGet("Artist") or "artist"),
		"BMS",
		"",
		fix(noteChart:hashGet("Version") or ""),
		"",
		"",
		"",
		0,
		1000,
		300,
		120,
		0,
		noteChart.inputMode:getString()
	)
	
	return 0
end

-- Cache.generateJNCCacheData = function(self, directoryPath, fileName)
	-- local title = "<title>"
	-- local artist = "<artist>"
	
	-- local path = ("%s/%s"):format(directoryPath, fileName)
	-- local noteChart = self:getNoteChart(path)
	
	-- title = noteChart:hashGet("title")
	-- artist = noteChart:hashGet("artist")
	
	-- local name = ("%s - %s"):format(artist, title)
	-- self:addChart(path, name)
	
	-- return 0
-- end

-- Cache.generateUCSCacheData = function(self, directoryPath, fileName)
	-- local path = ("%s/%s"):format(directoryPath, fileName)
	-- local title = fileName:match("^(.+)%.ucs$")
	
	-- self:setContainer(path, 1)
	-- self:addChart(path .. "/1", title)
	
	-- return 1
-- end

Cache.generateOJNCacheData = function(self, directoryPath, fileName)
	local path = ("%s/%s"):format(directoryPath, fileName)
	local file = love.filesystem.newFile(path)
	file:open("r")
	local ojn = o2jam.OJN:new(file:read(file:getSize()))
	file:close()
	
	self:setContainer(path, 1)
	
	local name
	for i = 1, 3 do
		self:addChart(
			path .. "/" .. i,
			"",
			0,
			fix(ojn.str_title),
			fix(ojn.str_artist),
			"o2jam",
			"",
			ojn.charts[i].level,
			fix(ojn.str_noter),
			"",
			"",
			0,
			ojn.charts[i].notes,
			ojn.charts[i].duration,
			ojn.bpm,
			ojn.charts[i].notes / ojn.charts[i].duration,
			"7key"
		)
	end
	
	return 1
end

return Cache

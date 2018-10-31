Cache = createClass()

Cache.filePath = "userdata/cache.sqlite"

Cache.construct = function(self)
	self.db = sqlite.open(self.filePath)
	
	self.db:exec[[
		CREATE TABLE IF NOT EXISTS `cache` (
			`path` TEXT,
			`hash` TEXT,
			`container` INTEGER,
			`name` TEXT,
			PRIMARY KEY (`path`)
		);
	]]
	
	self.db:setscalar("CHECKVISIBLE", function(...) return self:checkVisible(...) end)
end

Cache.update = function(self, path, recursive, callback)
	if not self.isUpdating then
		soul.async(
			"dofile(\"sources/async/updateCache.lua\")",
			path, recursive
		):trycatch(
			function()
				callback()
				self.isUpdating = false
			end,
			function(...)
				print(...)
			end)
		self.isUpdating = true
	end
end

Cache.checkVisible = function(self, path)
	local subkey = path:split("/")
	table.remove(subkey, #subkey)
	if table.leftequal(subkey, self.selectionKey) then
		return 1
	else
		return 0
	end
end

Cache.rowByPath = function(self, path)
	return self.db:rowexec(("SELECT * FROM cache WHERE path = %q"):format(path))
end

Cache.setContainer = function(self, path, container)
	return self.db:exec(([[
		INSERT OR IGNORE INTO `cache` (path, hash, container, name)
		VALUES (%q, '', -1, '');
		UPDATE `cache` SET `container` = %s WHERE `path` == %q;
	]]):format(path, container, path))
end

Cache.addChart = function(self, path, name)
	return self.db:exec(([[
		INSERT INTO `cache` (path, hash, container, name)
		VALUES (%q, '', 0, %q);
	]]):format(path, name))
end

Cache.processFile = function(self, directoryPath, fileName)
	local extensionType = self:getExtensionType(directoryPath .. "/" .. fileName)
	if extensionType then
		return self:generateCacheData(directoryPath, fileName, extensionType)
	end
end

Cache.clean = function(self, directoryPath)
	self.selectionKey = directoryPath:split("/")
	local result = self.db:exec("SELECT * FROM `cache` WHERE CHECKVISIBLE(path) ORDER BY `path`;")
	
	local row = 1
	while result.path[row] do
		local path = result.path[row]
		if not love.filesystem.exists(path) then
			self.db:exec("DELETE FROM `cache` WHERE `path` == " .. string.format("%q", path) .. ";")
		end
		
		row = row + 1
	end
end

Cache.lookup = function(self, directoryPath, recursive)
	if love.filesystem.isFile(directoryPath) then
		return -1
	end
	
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local charts = 0
	local containers = 0
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) then
			if not self:rowByPath(path) then
				if self:processFile(directoryPath, itemName) == 0 then
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
			".osu$"
		}
	},
	{
		type = "bms",
		patterns = {
			".bms$", ".bme$", ".bml$", 
		}
	},
	{
		type = "o2jam",
		patterns = {
			".ojn$"
		}
	},
	{
		type = "ucs",
		patterns = {
			".ucs$"
		}
	},
	{
		type = "jnc",
		patterns = {
			".jnc$"
		}
	}
}

Cache.getExtensionType = function(self, fileName)
	for _, extensionData in ipairs(self.extensions) do
		for _, pattern in ipairs(extensionData.patterns) do
			if fileName:find(pattern) then
				return extensionData.type
			end
		end
	end
end

Cache.generateCacheData = function(self, directoryPath, fileName, extensionType)
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

Cache.fixCharset = function(self, line)
	return iconv(line, "UTF-8", "SHIFT-JIS") or iconv(line, "UTF-8", "EUC-KR") or iconv(line, "UTF-8", "US-ASCII") or line
end

Cache.generateBMSCacheData = function(self, directoryPath, fileName)
	local title = "<title>"
	local artist = "<artist>"
	
	local path = ("%s/%s"):format(directoryPath, fileName)
	local file = love.filesystem.newFile(path)
	file:open("r")
	
	for line in file:lines() do
		local line = self:fixCharset(line)
		if line:find("^#TITLE .+$") then
			title = line:match("^#TITLE (.+)$")
		end
		if line:find("^#ARTIST .+$") then
			artist = line:match("^#ARTIST (.+)$")
		end
		if line:find("^#WAV") then
			break
		end
	end
	file:close()
	
	local name = ("%s - %s"):format(artist, title)
	self:addChart(path, name)
	
	return 0
end

Cache.generateOsuCacheData = function(self, directoryPath, fileName)
	local title = "<title>"
	local artist = "<artist>"
	
	local path = ("%s/%s"):format(directoryPath, fileName)
	local file = love.filesystem.newFile(path)
	file:open("r")
	
	for line in file:lines() do
		if line:find("Title:[ ]?.+$") then
			title = line:match("^Title:[ ]?(.+)$")
		end
		if line:find("Artist:[ ]?.+$") then
			artist = line:match("Artist:[ ]?(.+)$")
		end
		if line:find("Version:[ ]?.+$") then
			local version = line:match("Version:[ ]?(.+)$")
			title = title .. " [" .. version .. "]"
		end
		if line:find("^%[Events%]") then
			break
		end
	end
	file:close()
	
	local name = ("%s - %s"):format(artist, title)
	self:addChart(path, name)
	
	return 0
end

Cache.generateJNCCacheData = function(self, directoryPath, fileName)
	local title = "<title>"
	local artist = "<artist>"
	
	local path = ("%s/%s"):format(directoryPath, fileName)
	local file = love.filesystem.newFile(path)
	file:open("r")
	local jsonData = json.decode(file:read(file:getSize()))
	file:close()
	
	title = jsonData.metaData.title
	artist = jsonData.metaData.artist
	
	local name = ("%s - %s"):format(artist, title)
	self:addChart(path, name)
	
	return 0
end

Cache.generateUCSCacheData = function(self, directoryPath, fileName)
	local path = ("%s/%s"):format(directoryPath, fileName)
	local title = fileName:match("^(.+)%.ucs$")
	
	self:setContainer(path, 1)
	self:addChart(path .. "/1", title)
	
	return 1
end

Cache.generateOJNCacheData = function(self, directoryPath, fileName)
	local title = "<title>"
	local artist = "<artist>"
	
	local path = ("%s/%s"):format(directoryPath, fileName)
	local file = love.filesystem.newFile(path)
	file:open("r")
	local ojn = o2jam.OJN:new(file:read(file:getSize()))
	file:close()
	
	
	self:setContainer(path, 1)
	
	local name
	for i = 1, 3 do
		title = self:fixCharset(ojn.str_title) .. " [" .. ojn.charts[1].level .. "]"
		artist = self:fixCharset(ojn.str_artist)
		name = ("%s - %s"):format(artist, title)
		
		self:addChart(path .. "/" .. i, name)
	end
	
	return 1
end

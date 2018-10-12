Cache = createClass()

Cache.filePath = "userdata/cache.json"

Cache.init = function(self)
	self.data = {}
	self.dataDict = {}
	self.indexedPaths = {}
end

Cache.getList = function(self)
	return self.data
end

Cache.getDict = function(self)
	return self.dataDict
end

Cache.import = function(self)
	local file = io.open(self.filePath, "r")
	local content = file and file:read("*all") or ""
	self.data = json.decode(content ~= "" and content or "[]")
	if file then file:close() end
	for _, cacheData in ipairs(self.data) do
		self.dataDict[self:getCacheDataFilePath(cacheData)] = cacheData
	end
	self:clean()
	self:translate()
	self:lookup("userdata/charts")
end

Cache.export = function(self)
	local data = {}
	for _, cacheData in pairs(self.dataDict) do
		table.insert(data, cacheData)
	end
	table.sort(data, function(a, b)
		return self:getCacheDataFilePath(a) < self:getCacheDataFilePath(b)
	end)
	local file = io.open(self.filePath, "w")
	file:write(json.encode(data))
	file:close()
end

Cache.clean = function(self)
	local data = {}
	for _, cacheData in ipairs(self.data) do
		if love.filesystem.exists(self:getCacheDataFilePath(cacheData)) then
			table.insert(data, cacheData)
		end
	end
	self.data = data
end

Cache.translate = function(self)
	for _, cacheData in ipairs(self.data) do
		self:translateItem(cacheData)
	end
end

Cache.translateItem = function(self, cacheData)
	local filePathTable = cacheData.directoryPath:split("/")
	for level = 1, #filePathTable do
		self.indexedPaths[table.concat(filePathTable, "/")] = true
		table.remove(filePathTable, #filePathTable)
	end
end

Cache.processFile = function(self, directoryPath, fileName)
	local extensionType = self:getExtensionType(directoryPath .. "/" .. fileName)
	if extensionType then
		self:generateCacheData(directoryPath, fileName, extensionType)
	end
end

Cache.lookup = function(self, directoryPath, recursive)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local filePath = directoryPath .. "/" .. itemName
		if
			love.filesystem.isDirectory(filePath) and
			(recursive or
			not self.indexedPaths[filePath])
		then
			self:lookup(filePath, true)
			self.indexedPaths[filePath] = true
		elseif
			love.filesystem.isFile(filePath) and
			not self.dataDict[filePath]
		then
			self:processFile(directoryPath, itemName)
		end
	end
end

Cache.getCacheDataFilePath = function(self, cacheData)
	return cacheData.directoryPath .. "/" .. cacheData.fileName
end

Cache.getCacheDataIterator = function(self)
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

-- Cache.generateCacheDataDirectory = function(self, directoryPath)
	-- print("checking directory", directoryPath)
	-- local hasCharts = false
	-- for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		-- local extensionType = self:getExtensionType(itemName)
		-- if love.filesystem.isFile(directoryPath .. "/" .. itemName) and extensionType then
			-- self:generateCacheData(directoryPath, itemName, extensionType)
			-- hasCharts = true
		-- end
	-- end
	
	-- return hasCharts
-- end

Cache.generateCacheData = function(self, directoryPath, fileName, extensionType)
	print("processing file", fileName)
	if extensionType == "bms" then
		self:addCacheData(self:generateBMSCacheData(directoryPath, fileName))
	elseif extensionType == "osu" then
		self:addCacheData(self:generateOsuCacheData(directoryPath, fileName))
	elseif extensionType == "ucs" then
		self:addCacheData(self:generateUCSCacheData(directoryPath, fileName))
	elseif extensionType == "jnc" then
		self:addCacheData(self:generateJNCCacheData(directoryPath, fileName))
	elseif extensionType == "o2jam" then
		self:addCacheData(self:generateOJNCacheData(directoryPath, fileName, 1))
		self:addCacheData(self:generateOJNCacheData(directoryPath, fileName, 2))
		self:addCacheData(self:generateOJNCacheData(directoryPath, fileName, 3))
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
	local cacheData = {}
	cacheData.directoryPath = directoryPath
	cacheData.fileName = fileName
	cacheData.title = "<title>"
	cacheData.artist = "<artist>"
	cacheData.index = "1"
	
	cacheData.container = "directory"
	
	local file = love.filesystem.newFile(directoryPath .. "/" ..  fileName)
	file:open("r")
	
	for line in file:lines() do
		local line = self:fixCharset(line)
		if line:find("^#TITLE .+$") then
			cacheData.title = line:match("^#TITLE (.+)$")
		end
		if line:find("^#ARTIST .+$") then
			cacheData.artist = line:match("^#ARTIST (.+)$")
		end
		if line:find("^#PLAYLEVEL .+$") then
			cacheData.playlevel = line:match("^#PLAYLEVEL (.+)$")
		end
		if line:find("^#WAV") then
			break
		end
	end
	file:close()
	
	return cacheData
end

Cache.generateOsuCacheData = function(self, directoryPath, fileName)
	local cacheData = {}
	cacheData.directoryPath = directoryPath
	cacheData.fileName = fileName
	cacheData.title = "<title>"
	cacheData.artist = "<artist>"
	cacheData.index = "1"
	
	cacheData.container = "directory"
	
	local file = love.filesystem.newFile(directoryPath .. "/" ..  fileName)
	file:open("r")
	
	for line in file:lines() do
		if line:find("Title:[ ]?.+$") then
			cacheData.title = line:match("^Title:[ ]?(.+)$")
		end
		if line:find("Artist:[ ]?.+$") then
			cacheData.artist = line:match("Artist:[ ]?(.+)$")
		end
		if line:find("Version:[ ]?.+$") then
			local version = line:match("Version:[ ]?(.+)$")
			cacheData.title = cacheData.title .. " [" .. version .. "]"
		end
		if line:find("^%[Events%]") then
			break
		end
	end
	file:close()
	
	return cacheData
end

Cache.generateJNCCacheData = function(self, directoryPath, fileName)
	local cacheData = {}
	cacheData.directoryPath = directoryPath
	cacheData.fileName = fileName
	cacheData.title = "<title>"
	cacheData.artist = "<artist>"
	cacheData.index = "1"
	
	cacheData.container = "directory"
	
	local file = love.filesystem.newFile(directoryPath .. "/" ..  fileName)
	file:open("r")
	local jsonData = json.decode(file:read(file:getSize()))
	file:close()
	
	cacheData.title = jsonData.metaData.title
	cacheData.artist = jsonData.metaData.artist
	
	return cacheData
end

Cache.generateUCSCacheData = function(self, directoryPath, fileName)
	local cacheData = {}
	cacheData.directoryPath = directoryPath
	cacheData.fileName = fileName
	cacheData.title = fileName:match("^(.+)%.ucs$")
	cacheData.artist = "<artist>"
	cacheData.index = "1"
	
	cacheData.container = "file-single"
	
	return cacheData
end

Cache.generateOJNCacheData = function(self, directoryPath, fileName, chartIndex)
	local cacheData = {}
	cacheData.directoryPath = directoryPath
	cacheData.fileName = fileName
	cacheData.title = "<title>"
	cacheData.artist = "<artist>"
	cacheData.index = tostring(chartIndex)
	
	cacheData.container = "file-multiple"
	
	local file = love.filesystem.newFile(directoryPath .. "/" ..  fileName)
	file:open("r")
	local ojn = o2jam.OJN:new(file:read(file:getSize()))
	file:close()
	
	cacheData.title = self:fixCharset(ojn.str_title) .. " [" .. ojn.charts[chartIndex].level .. "]"
	cacheData.artist = self:fixCharset(ojn.str_artist)
	
	return cacheData
end

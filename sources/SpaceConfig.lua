SpaceConfig = createClass()

SpaceConfig.init = function(self)
	self.observable = Observable:new()
end

SpaceConfig.load = function(self, filePath)
	self.filePath = filePath
	self:readFile()
	self:processFile()
end

SpaceConfig.readFile = function(self)
	local configFile = io.open(self.filePath, "r")
	self.configString = configFile:read("*a")
	configFile:close()
end

SpaceConfig.processFile = function(self)
	self.data = {}
	self.keyData = {}
	for _, line in ipairs(self.configString:split("#")) do
		self:processLine(line:gsub("\n", " "):trim())
	end
end

SpaceConfig.getClearDataTable = function(self, dataTable, removingString)
	local newDataTable = {}
	
	for _, value in ipairs(dataTable) do
		if value ~= removingString then
			table.insert(newDataTable, value)
		end
	end
	
	return newDataTable
end

SpaceConfig.getKeyTable = function(self, key)
	local lastKeyTable = self.data
	
	for _, keyString in ipairs(key) do
		lastKeyTable[keyString] = lastKeyTable[keyString] or {}
		lastKeyTable = lastKeyTable[keyString]
	end
	
	return lastKeyTable
end

SpaceConfig.setKeyTableData = function(self, key, data)
	local keyTable = self:getKeyTable(key)
	
	for _, value in ipairs(data) do
		table.insert(keyTable, value)
		self.observable:sendEvent({
			name = "SpaceConfigAddValue",
			key = key,
			data = data,
			keyTable = keyTable,
			value = value
		})
	end
end

SpaceConfig.getKeyDataIterator = function(self)
	local keyDatas = {}
	for key, data in pairs(self.keyData) do
		table.insert(keyDatas, {key, data})
	end
	
	local keyDataIndex = 0
	return function()
		keyDataIndex = keyDataIndex + 1
		if keyDatas[keyDataIndex] then
			return keyDatas[keyDataIndex][1], keyDatas[keyDataIndex][2]
		end
	end
end

SpaceConfig.processLine = function(self, line)
	if line:find("^.+:.+$") then
		local keyString, dataString = line:match("^(.+):(.+)$")
		local key = self:getClearDataTable(keyString:split("%s+", true), "")
		local data = self:getClearDataTable(dataString:split("%s+", true), "")
		
		self:setKeyTableData(key, data)
		self.keyData[key] = data
		self.observable:sendEvent({
			name = "SpaceConfigProcessLine",
			key = key,
			data = data,
			keyString = keyString,
			dataString = dataString
		})
	end
end
local Config	= require("sphere.config.Config")
local json		= require("json")
local ncdk		= require("ncdk")

local NoteSkinManager = {}

NoteSkinManager.data = {}
NoteSkinManager.path = "userdata/skins"

NoteSkinManager.load = function(self)
	self.metaDatas = {}
	return self:lookup("userdata/skins")
end

NoteSkinManager.lookup = function(self, directoryPath)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) then
			if love.filesystem.exists(path .. "/metadata.json") then
				self:loadMetaData(path, "metadata.json")
			end
		end
	end
end

NoteSkinManager.loadMetaData = function(self, path, fileName)
	local file = io.open(path .. "/" .. fileName, "r")
	local jsonData = json.decode(file:read("*all"))
	file:close()

	local metaDatas = self.metaDatas
	for _, metaData in ipairs(jsonData) do
		metaData.directoryPath = path
		metaData.inputMode = ncdk.InputMode:new():setString(metaData.inputMode)
		metaDatas[#metaDatas + 1] = metaData
	end
end

NoteSkinManager.getMetaDataList = function(self, inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = {}

	for _, metaData in ipairs(self.metaDatas) do
		if metaData.inputMode >= inputMode then
			list[#list + 1] = metaData
		end
	end
	
	return list
end

NoteSkinManager.setDefaultNoteSkin = function(self, inputMode, metaData)
	if type(inputMode) == "table" then
		inputMode = inputMode:getString()
	end

	return Config:setNoEvent("noteskin." .. inputMode, metaData.directoryPath .. "/" .. metaData.path)
end

NoteSkinManager.getMetaData = function(self, inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = self:getMetaDataList(inputMode)
	local configValue = Config:get("noteskin." .. inputMode:getString())
	
	if configValue then
		for _, metaData in ipairs(list) do
			if metaData.directoryPath .. "/" .. metaData.path == configValue then
				return metaData
			end
		end
	end

	self:setDefaultNoteSkin(inputMode, list[1])

	return list[1]
end

return NoteSkinManager

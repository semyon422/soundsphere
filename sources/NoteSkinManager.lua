NoteSkinManager = createClass()

NoteSkinManager.load = function(self, filePath)
	self.data = {}
	self:lookup("userdata/skins")
end

NoteSkinManager.loadConfig = function(self, filePath)
	local file = io.open(self.directoryPath .. "/" .. filePath, "r")
	
	for _, noteSkinFilePath in ipairs(json.decode(file:read("*all"))) do
		self:loadNoteSkin(noteSkinFilePath)
	end
	
	file:close()
end

NoteSkinManager.loadNoteSkin = function(self, filePath)
	local file = io.open(self.directoryPath .. "/" .. filePath, "r")
	self:processNoteSkin(json.decode(file:read("*all")))
	file:close()
end

NoteSkinManager.loadPlayField = function(self, filePath)
	local file = io.open(self.directoryPath .. "/" .. filePath, "r")
	local playField = json.decode(file:read("*all"))
	file:close()
	
	return playField
end

NoteSkinManager.processNoteSkin = function(self, noteSkin)
	local data = {}
	data.directoryPath = self.directoryPath
	data.noteSkin = noteSkin
	
	data.inputMode = ncdk.InputMode:new()
	for inputType, maxInputIndex in pairs(noteSkin.inputMode) do
		data.inputMode:setInput(inputType, maxInputIndex, true)
	end
	
	if noteSkin.playfield then
		data.playField = self:loadPlayField(noteSkin.playfield)
	end
	
	table.insert(self.data, data)
end

NoteSkinManager.getNoteSkin = function(self, inputMode)
	for _, data in ipairs(self.data) do
		if data.inputMode == inputMode then
			return data
		end
	end
end

NoteSkinManager.lookup = function(self, directoryPath)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) then
			if love.filesystem.exists(path .. "/config.json") then
				self.directoryPath = path
				self:loadConfig("config.json")
			end
		end
	end
end
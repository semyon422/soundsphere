local Class			= require("aqua.util.Class")
local aquafs		= require("aqua.filesystem")
local json			= require("json")
local ncdk			= require("ncdk")
local NoteSkin		= require("sphere.models.NoteSkinModel.NoteSkin")

local NoteSkinModel = Class:new()

NoteSkinModel.construct = function(self)
	self.emptyNoteSkin = NoteSkin:new()
	self.items = {}
end

NoteSkinModel.path = "userdata/skins"
NoteSkinModel.inputMode = ""

NoteSkinModel.load = function(self)
	self.noteSkins = {}
	self.config = self.configModel:getConfig("settings")
	return self:lookup(self.path)
end

NoteSkinModel.lookup = function(self, directoryPath)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info.type == "directory" or info.type == "symlink" then
			local info = love.filesystem.getInfo(path .. "/metadata.json")
			if info then
				self:loadMetaData(path, "metadata.json")
			end
		elseif info.type == "file" and itemName:sub(-3, -1) == "zip" then
			local directoryPath = path:sub(1, -5)
			aquafs.mount(path, directoryPath, false)
			local info = love.filesystem.getInfo(directoryPath .. "/metadata.json")
			if info then
				self:loadMetaData(directoryPath, "metadata.json")
			end
		end
	end
end

NoteSkinModel.loadMetaData = function(self, path, fileName)
	local contents = love.filesystem.read(path .. "/" .. fileName)
	local jsonObject = json.decode(contents)

	local noteSkins = self.noteSkins
	for _, metaData in ipairs(jsonObject) do
		local noteSkin = NoteSkin:new()

		noteSkin.name = metaData.name
		noteSkin.inputMode = ncdk.InputMode:new():setString(metaData.inputMode)
		noteSkin.type =  metaData.type
		noteSkin.path = metaData.path
		noteSkin.directoryPath = path

		noteSkins[#noteSkins + 1] = noteSkin
	end
end

NoteSkinModel.getNoteSkins = function(self, inputMode)
	local stringInputMode = inputMode
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	else
		stringInputMode = inputMode:getString()
	end
	if self.inputMode == stringInputMode then
		return self.items
	end
	self.inputMode = stringInputMode

	local items = {}
	self.items = items

	for _, noteSkin in ipairs(self.noteSkins) do
		if noteSkin.inputMode >= inputMode then
			items[#items + 1] = noteSkin
		end
	end

	return items
end

NoteSkinModel.setDefaultNoteSkin = function(self, noteSkin)
	local inputMode = noteSkin.inputMode:getString()
	self.config.gameplay["noteskin" .. inputMode] = noteSkin.directoryPath .. "/" .. noteSkin.path
end

NoteSkinModel.getNoteSkin = function(self, inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = self:getNoteSkins(inputMode)
	local configValue = self.config.gameplay["noteskin" .. inputMode:getString()]

	if configValue then
		for _, noteSkin in ipairs(list) do
			if noteSkin.directoryPath .. "/" .. noteSkin.path == configValue then
				return noteSkin
			end
		end
	end

	if #list ~= 0 then
		self:setDefaultNoteSkin(list[1])
	end

	return list[1] or self.emptyNoteSkin
end

return NoteSkinModel

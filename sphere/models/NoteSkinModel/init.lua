local Class			= require("aqua.util.Class")
local json			= require("json")
local ncdk			= require("ncdk")
local NoteSkin		= require("sphere.models.NoteSkinModel.NoteSkin")

local NoteSkinModel = Class:new()

NoteSkinModel.construct = function(self)
	self.emptyNoteSkin = NoteSkin:new()
end

NoteSkinModel.path = "userdata/skins"

NoteSkinModel.load = function(self)
	self.noteSkins = {}
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
		end
	end
end

NoteSkinModel.loadMetaData = function(self, path, fileName)
	local file = io.open(path .. "/" .. fileName, "r")
	local jsonObject = json.decode(file:read("*all"))
	file:close()

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
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = {}

	for _, noteSkin in ipairs(self.noteSkins) do
		if noteSkin.inputMode >= inputMode then
			list[#list + 1] = noteSkin
		end
	end

	return list
end

NoteSkinModel.setDefaultNoteSkin = function(self, inputMode, noteSkin)
	if type(inputMode) == "table" then
		inputMode = inputMode:getString()
	end

	return self.configModel:set("noteskin." .. inputMode, noteSkin.directoryPath .. "/" .. noteSkin.path)
end

NoteSkinModel.getNoteSkin = function(self, inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = self:getNoteSkins(inputMode)
	local configValue = self.configModel:get("noteskin." .. inputMode:getString())

	if configValue then
		for _, noteSkin in ipairs(list) do
			if noteSkin.directoryPath .. "/" .. noteSkin.path == configValue then
				return noteSkin
			end
		end
	end

	if #list ~= 0 then
		self:setDefaultNoteSkin(inputMode, list[1])
	end

	return list[1] or self.emptyNoteSkin
end

return NoteSkinModel

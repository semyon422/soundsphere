local Class			= require("aqua.util.Class")
local ncdk			= require("ncdk")
local NoteSkin		= require("sphere.models.NoteSkinModel.NoteSkin")
local OsuNoteSkin		= require("sphere.models.NoteSkinModel.OsuNoteSkin")
local TomlNoteSkinLoader = require("sphere.models.NoteSkinModel.TomlNoteSkinLoader")

local NoteSkinModel = Class:new()

NoteSkinModel.construct = function(self)
	self.emptyNoteSkin = NoteSkin:new()
	self.items = {}
end

NoteSkinModel.path = "userdata/skins"
NoteSkinModel.inputMode = ""

NoteSkinModel.load = function(self)
	self.noteSkins = {}
	self.config = self.configModel.configs.settings
	return self:lookup(self.path)
end

NoteSkinModel.lookup = function(self, directoryPath)
	local items = love.filesystem.getDirectoryItems(directoryPath)

	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" and itemName:find("^.-skin%.%a-$") then
			self:loadNoteSkin(path, directoryPath, itemName)
		elseif info and info.type == "directory" then
			self:lookup(path)
		end
	end
end

NoteSkinModel.addNoteSkins = function(self, noteSkins)
	for _, noteSkin in ipairs(noteSkins) do
		table.insert(self.noteSkins, noteSkin)
	end
end

NoteSkinModel.loadNoteSkin = function(self, path, directoryPath, itemName)
	local noteSkin
	if path:find("^.+%.toml$") then
		noteSkin = TomlNoteSkinLoader:new():load(path, directoryPath, itemName)
	elseif path:find("^.+%.lua$") then
		noteSkin = self:loadLuaFullLatest(path, directoryPath, itemName)
	elseif path:find("^.+%.ini$") then
		return self:addNoteSkins(self:loadOsuLatest(path, directoryPath, itemName))
	end
	table.insert(self.noteSkins, noteSkin)
end

NoteSkinModel.loadLuaFullLatest = function(self, path, directoryPath, fileName)
	local noteSkin = assert(love.filesystem.load(path))(path)

	noteSkin.path = path
	noteSkin.directoryPath = directoryPath
	noteSkin.fileName = fileName
	noteSkin.inputMode = ncdk.InputMode:new():setString(noteSkin.inputMode)
	if type(noteSkin.playField) == "string" then
		noteSkin.playField = love.filesystem.load(directoryPath .. "/" .. noteSkin.playField)()
	end

	return noteSkin
end

NoteSkinModel.loadOsuLatest = function(self, path, directoryPath, fileName)
	local noteSkins = {}

	local skinini = OsuNoteSkin:parseSkinIni(love.filesystem.read(path))

	for i, mania in ipairs(skinini.Mania) do
		local noteSkin = OsuNoteSkin:new()
		noteSkin.path = path
		noteSkin.directoryPath = directoryPath
		noteSkin.fileName = fileName
		noteSkin.skinini = skinini
		noteSkin:setKeys(tonumber(mania.Keys))
		noteSkin.inputMode = ncdk.InputMode:new():setString(tonumber(mania.Keys) .. "key")
		local status, err = xpcall(noteSkin.load, debug.traceback, noteSkin)
		if status then
			table.insert(noteSkins, noteSkin)
		else
			print(err)
		end
	end

	return noteSkins
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
	self.config.gameplay["noteskin" .. inputMode] = noteSkin.path
end

NoteSkinModel.getNoteSkin = function(self, inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode:new():setString(inputMode)
	end

	local list = self:getNoteSkins(inputMode)
	local configValue = self.config.gameplay["noteskin" .. inputMode:getString()]

	if configValue then
		for _, noteSkin in ipairs(list) do
			if noteSkin.path == configValue then
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

local Class			= require("aqua.util.Class")
local ncdk			= require("ncdk")
local OsuNoteSkin		= require("sphere.models.NoteSkinModel.OsuNoteSkin")
local BaseNoteSkin = require("sphere.models.NoteSkinModel.BaseNoteSkin")

local NoteSkinModel = Class:new()

NoteSkinModel.construct = function(self)
	self.items = {}
	self.baseNoteSkins = {}
end

NoteSkinModel.path = "userdata/skins"

NoteSkinModel.load = function(self)
	self.inputMode = ""
	self.noteSkins = {}
	self.files = {}
	self.filesMap = {}
	self.foundNoteSkins = {}
	self.config = self.configModel.configs.settings
	self:lookup(self.path)
	self:loadNoteSkins()
end

NoteSkinModel.lookup = function(self, directoryPath)
	local items = love.filesystem.getDirectoryItems(directoryPath)

	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" then
			if itemName:lower():find("^.-skin%.%a-$") then
				table.insert(self.foundNoteSkins, {path, directoryPath, itemName})
			end
			self.filesMap[path] = true
		elseif info and info.type == "directory" and itemName ~= "__MACOSX" then
			self:lookup(path)
		end
	end
end

NoteSkinModel.loadNoteSkins = function(self)
	local files = self.files
	for _, paths in ipairs(self.foundNoteSkins) do
		local path, directoryPath, itemName = unpack(paths)
		files[directoryPath] = files[directoryPath] or {}
		local dfiles = files[directoryPath]
		for fpath in pairs(self.filesMap) do
			if fpath:find(directoryPath, 1, true) then
				table.insert(dfiles, fpath:sub(#directoryPath + 2))
			end
		end
		table.sort(dfiles)
		self:loadNoteSkin(path, directoryPath, itemName)
	end
end

NoteSkinModel.addNoteSkins = function(self, noteSkins)
	for _, noteSkin in ipairs(noteSkins) do
		table.insert(self.noteSkins, noteSkin)
	end
end

NoteSkinModel.loadNoteSkin = function(self, path, directoryPath, itemName)
	local noteSkin
	if path:find("^.+%.lua$") then
		noteSkin = self:loadLua(path, directoryPath, itemName)
	elseif path:find("^.+%.ini$") then
		return self:addNoteSkins(self:loadOsu(path, directoryPath, itemName))
	end
	table.insert(self.noteSkins, noteSkin)
end

NoteSkinModel.loadLua = function(self, path, directoryPath, fileName)
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

NoteSkinModel.loadOsu = function(self, path, directoryPath, fileName)
	local noteSkins = {}

	local skinini = OsuNoteSkin:parseSkinIni(love.filesystem.read(path))

	for i, mania in ipairs(skinini.Mania) do
		local keys = tonumber(mania.Keys)
		if keys then
			local noteSkin = OsuNoteSkin:new()
			noteSkin.files = self.files[directoryPath]
			noteSkin.path = path
			noteSkin.directoryPath = directoryPath
			noteSkin.fileName = fileName
			noteSkin.skinini = skinini
			noteSkin:setKeys(keys)
			noteSkin.inputMode = ncdk.InputMode:new():setString(keys .. "key")
			local status, err = xpcall(noteSkin.load, debug.traceback, noteSkin)
			if status then
				table.insert(noteSkins, noteSkin)
			else
				print(err)
			end
		end
	end

	return noteSkins
end

NoteSkinModel.getBaseNoteSkin = function(self, inputMode, stringInputMode)
	local baseNoteSkins = self.baseNoteSkins
	if baseNoteSkins[stringInputMode] then
		return baseNoteSkins[stringInputMode]
	end
	local noteSkin = BaseNoteSkin:new()
	noteSkin.directoryPath = "resources"
	noteSkin:setInputMode(inputMode, stringInputMode)
	noteSkin:load()
	baseNoteSkins[stringInputMode] = noteSkin
	return noteSkin
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

	items[#items + 1] = self:getBaseNoteSkin(inputMode, stringInputMode)
	for _, noteSkin in ipairs(self.noteSkins) do
		if noteSkin.inputMode == inputMode then
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

	return list[1]
end

return NoteSkinModel

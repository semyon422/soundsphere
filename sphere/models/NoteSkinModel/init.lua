local Class			= require("Class")
local ncdk			= require("ncdk")
local OsuNoteSkin		= require("sphere.models.NoteSkinModel.OsuNoteSkin")
local BaseNoteSkin = require("sphere.models.NoteSkinModel.BaseNoteSkin")
local utf8validate = require("utf8validate")

local NoteSkinModel = Class:new()

NoteSkinModel.construct = function(self)
	self.items = {}
end

NoteSkinModel.path = "userdata/skins"

NoteSkinModel.load = function(self)
	self.inputMode = ""
	self.noteSkins = {}
	self.files = {}
	self.foundNoteSkins = {}
	self.tree = {}
	self.config = self.game.configModel.configs.settings
	self:lookupTree(self.path, self.tree)
	self:lookupSkins(self.tree)
	-- local t = love.timer.getTime()
	self:loadNoteSkins()
	-- print("T", love.timer.getTime() - t)
end

local function combinePath(...)
	local t = {}
	for i = 1, select("#", ...) do
		table.insert(t, (select(i, ...)))  -- skips nils
	end
	return table.concat(t, "/")
end

NoteSkinModel.treeToList = function(self, tree, list, prefix)
	for _, item in ipairs(tree) do
		if type(item) == "string" then
			table.insert(list, combinePath(prefix, item))
		elseif type(item) == "table" then
			self:treeToList(item, list, combinePath(prefix, item.name))
		end
	end
end

NoteSkinModel.lookupTree = function(self, directoryPath, tree)
	local items = love.filesystem.getDirectoryItems(directoryPath)

	for _, name in ipairs(items) do
		local path = directoryPath .. "/" .. name
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" then
			table.insert(tree, name)
		elseif info and info.type == "directory" and name ~= "__MACOSX" then
			local dir = {name = name}
			table.insert(tree, dir)
			self:lookupTree(path, dir)
		end
	end
end

NoteSkinModel.lookupSkins = function(self, tree, prefix)
	local found = false
	for _, item in ipairs(tree) do
		if type(item) == "string" and item:lower():find("^.-skin%.%a-$") then
			table.insert(self.foundNoteSkins, {prefix, item})
			found = true
		end
	end

	for _, item in ipairs(tree) do
		if type(item) == "table" then
			self:lookupSkins(item, combinePath(prefix, item.name))
		end
	end

	if not found then
		return
	end

	local list = {}
	self:treeToList(tree, list)
	table.sort(list)

	self.files[tostring(prefix)] = list
end

NoteSkinModel.loadNoteSkins = function(self)
	for _, paths in ipairs(self.foundNoteSkins) do
		self:loadNoteSkin(paths[1], paths[2])
	end
end

NoteSkinModel.loadNoteSkin = function(self, prefix, name)
	if name:lower():find("^.+%.lua$") then
		table.insert(self.noteSkins, self:loadLua(prefix, name))
	elseif name:lower():find("^.+%.ini$") then
		for _, noteSkin in ipairs(self:loadOsu(prefix, name)) do
			table.insert(self.noteSkins, noteSkin)
		end
	end
end

NoteSkinModel.loadLua = function(self, prefix, name)
	local path = combinePath(self.path, prefix, name)
	local noteSkin = assert(love.filesystem.load(path))(path)

	noteSkin.path = path
	noteSkin.directoryPath = combinePath(self.path, prefix)
	noteSkin.fileName = name
	noteSkin.inputMode = ncdk.InputMode:new():setString(noteSkin.inputMode)
	if type(noteSkin.playField) == "string" then
		noteSkin.playField = love.filesystem.load(combinePath(self.path, prefix, name))()
	end

	return noteSkin
end

NoteSkinModel.loadOsu = function(self, prefix, name)
	local path = combinePath(self.path, prefix, name)
	local noteSkins = {}

	local content = love.filesystem.read(path)
	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	local files = OsuNoteSkin:processFiles(self.files[tostring(prefix)])

	for i, mania in ipairs(skinini.Mania) do
		local keys = tonumber(mania.Keys)
		if keys then
			local noteSkin = OsuNoteSkin:new()
			noteSkin.files = files
			noteSkin.path = path
			noteSkin.directoryPath = combinePath(self.path, prefix)
			noteSkin.fileName = name
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
	local noteSkin = BaseNoteSkin:new()
	noteSkin.directoryPath = "resources"
	noteSkin:setInputMode(inputMode, stringInputMode)
	noteSkin:load()
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

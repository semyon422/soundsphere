local class = require("class")
local ncdk = require("ncdk")
local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local BaseNoteSkin = require("sphere.models.NoteSkinModel.BaseNoteSkin")
local utf8validate = require("utf8validate")

---@class sphere.NoteSkinModel
---@operator call: sphere.NoteSkinModel
local NoteSkinModel = class()

function NoteSkinModel:new()
	self.items = {}
end

NoteSkinModel.path = "userdata/skins"

function NoteSkinModel:load()
	self.inputMode = ""
	self.noteSkins = {}
	self.files = {}
	self.foundNoteSkins = {}
	self.tree = {}
	self.config = self.configModel.configs.settings
	self:lookupTree(self.path, self.tree)
	self:lookupSkins(self.tree)
	-- local t = love.timer.getTime()
	self:loadNoteSkins()
	-- print("T", love.timer.getTime() - t)
end

---@param ... string?
---@return string
local function combinePath(...)
	local t = {}
	for i = 1, select("#", ...) do
		table.insert(t, (select(i, ...)))  -- skips nils
	end
	return table.concat(t, "/")
end

---@param tree table
---@param list table
---@param prefix string?
function NoteSkinModel:treeToList(tree, list, prefix)
	for _, item in ipairs(tree) do
		if type(item) == "string" then
			table.insert(list, combinePath(prefix, item))
		elseif type(item) == "table" then
			self:treeToList(item, list, combinePath(prefix, item.name))
		end
	end
end

---@param directoryPath string
---@param tree table
function NoteSkinModel:lookupTree(directoryPath, tree)
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

---@param tree table
---@param prefix string?
function NoteSkinModel:lookupSkins(tree, prefix)
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

function NoteSkinModel:loadNoteSkins()
	for _, paths in ipairs(self.foundNoteSkins) do
		self:loadNoteSkin(paths[1], paths[2])
	end
end

---@param prefix string?
---@param name string
function NoteSkinModel:loadNoteSkin(prefix, name)
	if name:lower():find("^.+%.lua$") then
		table.insert(self.noteSkins, self:loadLua(prefix, name))
	elseif name:lower():find("^.+%.ini$") then
		for _, noteSkin in ipairs(self:loadOsu(prefix, name)) do
			table.insert(self.noteSkins, noteSkin)
		end
	end
end

---@param prefix string?
---@param name string
---@return sphere.NoteSkin
function NoteSkinModel:loadLua(prefix, name)
	local path = combinePath(self.path, prefix, name)
	local noteSkin = assert(love.filesystem.load(path))(path)

	noteSkin.path = path
	noteSkin.directoryPath = combinePath(self.path, prefix)
	noteSkin.fileName = name
	noteSkin.inputMode = ncdk.InputMode(noteSkin.inputMode)
	if type(noteSkin.playField) == "string" then
		noteSkin.playField = love.filesystem.load(combinePath(self.path, prefix, name))()
	end

	return noteSkin
end

---@param prefix string?
---@param name string
---@return table
function NoteSkinModel:loadOsu(prefix, name)
	local path = combinePath(self.path, prefix, name)
	local noteSkins = {}

	local content = love.filesystem.read(path)
	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	local files = OsuNoteSkin:processFiles(self.files[tostring(prefix)])

	for i, mania in ipairs(skinini.Mania) do
		local keys = tonumber(mania.Keys)
		if keys then
			local noteSkin = OsuNoteSkin()
			noteSkin.files = files
			noteSkin.path = path
			noteSkin.directoryPath = combinePath(self.path, prefix)
			noteSkin.fileName = name
			noteSkin.skinini = skinini
			noteSkin:setKeys(keys)
			noteSkin.inputMode = ncdk.InputMode({key = keys})
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

---@param inputMode ncdk.InputMode
---@param stringInputMode string
---@return sphere.BaseNoteSkin
function NoteSkinModel:getBaseNoteSkin(inputMode, stringInputMode)
	local noteSkin = BaseNoteSkin()
	noteSkin.directoryPath = "resources"
	noteSkin:setInputMode(inputMode, stringInputMode)
	noteSkin:load()
	return noteSkin
end

---@param inputMode string|ncdk.InputMode
---@return table
function NoteSkinModel:getNoteSkins(inputMode)
	local stringInputMode = inputMode
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode(inputMode)
	else
		stringInputMode = tostring(inputMode)
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

---@param noteSkin sphere.NoteSkin
function NoteSkinModel:setDefaultNoteSkin(noteSkin)
	self.config.gameplay["noteskin" .. noteSkin.inputMode] = noteSkin.path
end

---@param inputMode string|ncdk.InputMode
---@return sphere.NoteSkin
function NoteSkinModel:getNoteSkin(inputMode)
	if type(inputMode) == "string" then
		inputMode = ncdk.InputMode(inputMode)
	end

	local list = self:getNoteSkins(inputMode)
	local configValue = self.config.gameplay["noteskin" .. inputMode]

	if configValue then
		for _, noteSkin in ipairs(list) do
			if noteSkin.path == configValue then
				self.noteSkin = noteSkin
				return noteSkin
			end
		end
	end

	if #list ~= 0 then
		self:setDefaultNoteSkin(list[1])
	end

	self.noteSkin = list[1]
	return list[1]
end

return NoteSkinModel

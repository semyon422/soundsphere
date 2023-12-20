local class = require("class")
local json = require("json")

---@class sphere.Updater
---@operator call: sphere.Updater
local Updater = class()

function Updater:new(updater_io)
	self.updater_io = updater_io
end

Updater.status = ""

---@param server table
---@param client table
---@return table
function Updater:mergeLists(server, client)
	local map = {}
	for _, file in ipairs(server) do
		local path = file.path
		map[path] = map[path] or {}
		map[path].hash = file.hash
		map[path].path = path
	end
	for _, file in ipairs(client) do
		local path = file.path
		map[path] = map[path] or {}
		map[path].hash_old = file.hash
		map[path].path = path
	end

	local list = {}
	for _, file in pairs(map) do
		table.insert(list, file)
	end
	table.sort(list, function(a, b)
		return a.path < b.path
	end)

	return list
end

function Updater:getActionLists(server_filelist, client_filelist)
	local filelist = self:mergeLists(server_filelist, client_filelist)

	local download = {}
	local remove = {}

	for _, file in ipairs(filelist) do
		if not file.hash then
			table.insert(remove, file.path)
		elseif not file.hash_old or file.hash ~= file.hash_old then
			local _hash = self.updater_io:crc32Async(file.path)
			if _hash ~= file.hash then
				table.insert(download, file.path)
			end
		end
	end

	return download, remove
end

---@param status string
function Updater:setStatus(status)
	self.status = status
	print(status)
end

function Updater:updateFilesAsync(update_url, client_filelist)
	self:setStatus("Checking for updates...")

	local response = self.updater_io:downloadAsync(update_url)
	if not response then
		self:setStatus("Can't download file list")
		return
	end

	local ok, server_filelist = pcall(json.decode, response)
	if not ok then
		self:setStatus("Can't decode json")
		return
	end

	-- TODO: move it to server file list after few months
	local prefix = update_url:match("^(.*)/.-$") .. "/soundsphere"

	local download, remove = self:getActionLists(server_filelist, client_filelist)

	local count = 0
	for _, path in ipairs(download) do
		local url = prefix .. "/" .. path
		self:setStatus("download: " .. path)
		local ok, err = self.updater_io:downloadAsync(url, path)
		if not ok then
			self:setStatus(err)
			return
		end
		count = count + 1
	end
	for _, path in ipairs(remove) do
		self:setStatus("remove: " .. path)
		self.updater_io:removeAsync(path)
		count = count + 1
	end

	self:setStatus("files updated: " .. count)

	return count > 0, server_filelist
end

return Updater

local Class = require("aqua.util.Class")
local json = require("json")
local thread = require("aqua.thread")

local UpdateModel = Class:new()

UpdateModel.status = ""

UpdateModel.load = function(self)
	local configs = self.configModel.configs

	if
		not configs.settings.miscellaneous.autoUpdate or
		configs.urls.update == "" or
		love.filesystem.getInfo(".git")
	then
		return
	end

	print("start auto update")
	self:updateFiles()
end

local crossFiles = function(server, client)
	local filemap = {}
	for _, file in ipairs(server) do
		local path = file.path
		filemap[path] = filemap[path] or {}
		filemap[path].hash = file.hash
		filemap[path].path = path
		filemap[path].url = file.url
	end
	for _, file in ipairs(client) do
		local path = file.path
		filemap[path] = filemap[path] or {}
		filemap[path].hash_old = file.hash
		filemap[path].path = path
	end

	local filelist = {}
	for _, file in pairs(filemap) do
		filelist[#filelist + 1] = file
	end
	table.sort(filelist, function(a, b)
		return a.path < b.path
	end)

	return filelist
end

local async_download = thread.async(function(url, path)
	local request = require("luajit-request")
	local socket_url = require("socket.url")
	require("preloaders.preloadall")

	url = socket_url.build(socket_url.parse(url))
	local response, _, err = request.send(url)
	local body = response and response.body
	if not body or not path then
		return body, err
	end

	local directory = path:match("^(.+)/.-$")
	if directory and not love.filesystem.createDirectory(directory) then
		return false, ("Could not open directory %s (not a directory)"):format(directory)
	end

	return love.filesystem.write(path, body)
end)

local async_remove = thread.async(function(...) return love.filesystem.remove(...) end)
local async_crc32 = thread.async(function(...)
	local content = love.filesystem.read(...)
	if not content then
		return
	end
	return require("crc32").hash(content)
end)

UpdateModel.setStatus = function(self, status)
	self.status = status
	print(status)
end

UpdateModel.updateFiles = thread.coro(function(self)
	local configs = self.configModel.configs
	self:setStatus("Checking for updates...")

	local response = async_download(configs.urls.update)
	if not response then
		return self:setStatus("Can't download file list")
	end

	local status, server_filelist = pcall(json.decode, response)
	if not status then
		return self:setStatus("Can't decode json")
	end

	local client_filelist = configs.files
	local filelist = crossFiles(server_filelist, client_filelist)

	local count = 0
	for _, file in ipairs(filelist) do
		if file.hash_old and not file.hash then
			self:setStatus(("remove: %s"):format(file.path))
			async_remove(file.path)
		elseif file.hash and not file.hash_old or file.hash ~= file.hash_old then
			print("check", file.path)
			if file.hash ~= async_crc32(file.path) then
				self:setStatus(("download: %s"):format(file.path))
				local res, err = async_download(file.url, file.path)
				if not res then
					return self:setStatus(err)
				end
				count = count + 1
			end
		end
	end

	self:setStatus(("files updated: %s"):format(count))
	if count == 0 then
		self:setStatus("")
	end

	for k in pairs(client_filelist) do
		client_filelist[k] = nil
	end
	for k, v in pairs(server_filelist) do
		client_filelist[k] = v
	end

	self.configModel:writeConfig("files")
end)

return UpdateModel

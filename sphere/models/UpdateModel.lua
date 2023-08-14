local class = require("class")
local json = require("json")
local thread = require("thread")

local UpdateModel = class()

UpdateModel.status = ""

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
	local http = require("http")
	local socket_url = require("socket.url")

	url = socket_url.build(socket_url.parse(url))

	local body, code = http.request(url)
	if not body or not path then
		return body, code
	end

	local directory = path:match("^(.+)/.-$")
	if directory and not love.filesystem.createDirectory(directory) then
		return false, ("Could not open directory %s (not a directory)"):format(directory)
	end

	local ok, err = love.filesystem.write(path, body)
	if ok then
		return ok, err
	end

	os.rename(path, path .. ".old")
	return love.filesystem.write(path, body)
end)

local async_remove = thread.async(function(path)
	local ok = love.filesystem.remove(path)
	if ok then
		return ok
	end
	return os.rename(path, path .. ".old")
end)
local async_copy = thread.async(function(src, dst)
	local ok, err = love.filesystem.read(src)
	if not ok then
		return ok, err
	end
	local content = ok
	ok, err = love.filesystem.write(dst, content)
	if ok then
		return ok, err
	end
	os.rename(dst, dst .. ".old")
	return love.filesystem.write(dst, content)
end)
local async_crc32 = thread.async(function(...)
	local content = love.filesystem.read(...)
	if not content then
		return
	end
	return require("crc32").hash(content)
end)

function UpdateModel:setStatus(status)
	self.status = status
	print(status)
end

function UpdateModel:updateFilesAsync()
	local configModel = self.configModel
	local configs = configModel.configs
	self:setStatus("Checking for updates...")

	local response = async_download(configs.urls.update)
	if not response then
		self:setStatus("Can't download file list")
		return
	end

	local status, server_filelist = pcall(json.decode, response)
	if not status then
		self:setStatus("Can't decode json")
		return
	end

	local client_filelist = configs.files
	local filelist = crossFiles(server_filelist, client_filelist)

	local client_filemap = {}
	for _, file in ipairs(client_filelist) do
		client_filemap[file.hash] = file
	end

	local downloadList = {}
	local copyList = {}
	local removeList = {}

	local count = 0
	for _, file in ipairs(filelist) do
		if file.hash_old and not file.hash then
			table.insert(removeList, file)
		elseif file.hash and not file.hash_old or file.hash ~= file.hash_old then
			local client_file = client_filemap[file.hash]
			if file.hash == async_crc32(file.path) then
				self:setStatus(("found: %s"):format(file.path))
			elseif client_file and file.hash == async_crc32(client_file.path) then
				table.insert(copyList, {client_file, file})
			else
				table.insert(downloadList, file)
			end
		end
	end

	for _, file in ipairs(downloadList) do
		self:setStatus(("download: %s"):format(file.path))
		local res, err = async_download(file.url, file.path)
		if not res then
			self:setStatus(err)
			return
		end
		count = count + 1
	end
	for _, files in ipairs(copyList) do
		local file1, file2 = unpack(files)
		self:setStatus(("copy: %s to %s"):format(file1.path, file2.path))
		local res, err = async_copy(file1.path, file2.path)
		if not res then
			self:setStatus(err)
			return
		end
		count = count + 1
	end
	for _, file in ipairs(removeList) do
		self:setStatus(("remove: %s"):format(file.path))
		async_remove(file.path)
		count = count + 1
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

	configModel:write()

	return count > 0
end

UpdateModel.updateFiles = thread.coro(UpdateModel.updateFilesAsync)

return UpdateModel

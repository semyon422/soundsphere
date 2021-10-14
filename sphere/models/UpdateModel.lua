local Class = require("aqua.util.Class")
local ThreadPool = require("aqua.thread.ThreadPool")
local json = require("json")
local crc32 = require("crc32")
local request = require("luajit-request")

local UpdateModel = Class:new()

UpdateModel.anyError = false
UpdateModel.status = ""
UpdateModel.filesUrl = ""

UpdateModel.construct = function(self) end

UpdateModel.load = function(self)
	local settings = self.configModel.configs.settings
	local online = self.configModel.configs.online

	self.filesUrl = online.update
	if not settings.miscellaneous.autoUpdate or online.update == "" or self.thread then
		return
	end

	ThreadPool.observable:add(self)
	print("start auto update")
	self:startUpdate()
	self.status = "Checking for updates..."
end

UpdateModel.receive = function(self, event)
	if event.name == "UpdateResultResponse" then
		print(event.status, event.result)
		if event.status and not self.anyError then
			self.status = ""
		else
			self.status = "Update error"
		end
	elseif event.name == "UpdateProgressResponse" then
		print(event.status, event.result)
		self.status = event.result
		if not event.status then
			self.anyError = true
		end
	end
end

UpdateModel.startUpdate = function(self)
	return ThreadPool:execute(
		[[
			local ConfigModel = require("sphere.models.ConfigModel")
			local configModel = ConfigModel:new()
			configModel:addConfig("settings", "userdata/settings.lua", "sphere/models/ConfigModel/settings.lua", "lua")
			configModel:addConfig("online", "userdata/online.lua", "sphere/models/ConfigModel/online.lua", "lua")
			configModel:addConfig("files", "userdata/files.lua", "sphere/models/ConfigModel/files.lua", "lua")
			configModel:readConfig("settings")
			configModel:readConfig("online")
			configModel:readConfig("files")

			local UpdateModel = require("sphere.models.UpdateModel")
			local updateModel = UpdateModel:new()
			updateModel.configModel = configModel
			updateModel.files = configModel.configs.files
			updateModel.thread = thread
			updateModel:load()

			local status, err = xpcall(updateModel.updateFiles, debug.traceback, updateModel, thread)
			thread:push({
				name = "UpdateResultResponse",
				status = status,
				result = err
			})
			configModel:writeConfig("files")
		]],
		{}
	)
end

UpdateModel.downloadFile = function(self, url, path)
	print("download", url, path)
	local result, err, message = request.send(url)
	if not result then
		return self.thread:push({
			name = "UpdateProgressResponse",
			status = false,
			result = message
		})
	end
	love.filesystem.createDirectory(path:match("^(.+)/.-$"))
	love.filesystem.write(path, result.body)
	self.thread:push({
		name = "UpdateProgressResponse",
		status = true,
		result = path
	})
end

UpdateModel.updateFiles = function(self)
	local thread = self.thread
	local result, err, message = request.send(self.filesUrl)
	if not result then
		thread:push({
			name = "UpdateProgressResponse",
			status = false,
			result = message
		})
		return
	end
	local status, server_filelist = pcall(json.decode, result.body)
	if not status then
		thread:push({
			name = "UpdateProgressResponse",
			status = false,
			result = server_filelist
		})
		return
	end

	local client_filelist = self.files

	local filemap = {}
	for _, file in ipairs(server_filelist) do
		local path = file.path
		filemap[path] = filemap[path] or {}
		filemap[path].hash = file.hash
		filemap[path].path = path
		filemap[path].url = file.url
	end
	for _, file in ipairs(client_filelist) do
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

	for _, file in ipairs(filelist) do
		if file.hash_old and not file.hash then
			print("remove", file.path)
			love.filesystem.remove(file.path)
		elseif file.hash and not file.hash_old or file.hash ~= file.hash_old then
			local info = love.filesystem.getInfo(file.path)
			if info then
				print("check", file.path)
				local f = love.filesystem.newFile(file.path)
				f:open("r")
				local hash = ("%8X"):format(crc32.hash(f:read()))
				f:close()
				if file.hash ~= hash then
					self:downloadFile(file.url, file.path)
				end
			else
				self:downloadFile(file.url, file.path)
			end
		end
	end

	for k in pairs(client_filelist) do
		client_filelist[k] = nil
	end
	for k, v in pairs(server_filelist) do
		client_filelist[k] = v
	end

	return true
end

return UpdateModel

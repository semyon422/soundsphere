local LibraryModel = require("sphere.models.LibraryModel")
local thread = require("aqua.thread")
local osudirect_urls = require("sphere.osudirect.urls")
local osudirect_parse = require("sphere.osudirect.parse")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")
local socket_url = require("socket.url")

local OsudirectModel = LibraryModel:new()

OsudirectModel.load = function(self)
	self.itemsCache.getObject = function(_, itemIndex)
		return setmetatable({}, {__index = function(t, k)
			local item = self.beatmapSets[itemIndex]
			if item then
				return item[k]
			end
		end})
	end
end

OsudirectModel.setBeatmap = function(self, beatmap)
	self.beatmap = beatmap
end

OsudirectModel.searchString = ""

OsudirectModel.setSearchString = function(self, s)
	self.searchString = s
	self:searchDebounce()
end

local empty = {}
OsudirectModel.getDifficulties = function(self)
	local beatmap = self.beatmap
	return beatmap and beatmap.difficulties or empty
end

local asyncRequest = thread.async(function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end
	return response.body, response.code
end)

OsudirectModel.searchDebounce = function(self)
	aquatimer.debounce(self, "loadDebounce", 0.1, self.search, self)
end

OsudirectModel.search = function(self)
	local searchString = self.searchString
	local config = self.configModel.configs.online.osu
	local url = socket_url.absolute(config.web, osudirect_urls.search(searchString))
	local body = asyncRequest(url)
	if not body then
		return
	end
	local beatmaps, err = osudirect_parse(body)
	self.beatmapSets = beatmaps
	self.itemsCount = #beatmaps
	if searchString ~= self.searchString then
		self:search()
	end
end

OsudirectModel.getBackgroundUrl = function(self)
	local config = self.configModel.configs.online.osu
	return socket_url.absolute(config.assets, osudirect_urls.cover(self.beatmap.setId, true))
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.configModel.configs.online.osu
	return socket_url.absolute(config.static, osudirect_urls.preview(self.beatmap.setId))
end

local download = aquathread.async(function(url, savePath)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end

	require("love.filesystem")
	return love.filesystem.write(savePath, response.body)
end)


local extract = aquathread.async(function(archive, path, remove)
	require("love.filesystem")
	local aquafs = require("aqua.filesystem")
	local rcopy = require("aqua.util.rcopy")
	local mount = path .. "_temp"
	local status, err = pcall(aquafs.mount, archive, mount, true)
	if not status then
		print(err)
		love.filesystem.remove(archive)
		return
	end
	rcopy(mount, path)
	assert(aquafs.unmount(archive))
	if remove then
		love.filesystem.remove(archive)
	end
	return true
end)

OsudirectModel.downloadBeatmapSet = aquathread.coro(function(self)
	local beatmap = self.beatmap
	if not beatmap then
		return
	end

	local config = self.configModel.configs.online.osu

	local setId = beatmap.setId
	local url = socket_url.absolute(config.storage, osudirect_urls.download(setId))
	local savePath = "userdata/charts/downloads/" .. setId .. ".osz"
	print(("Downloading: %s"):format(url))
	local downloaded = download(url, savePath)
	if not downloaded then
		return
	end
	print(("Downloaded: %s"):format(savePath))

	local extractPath = "userdata/charts/downloads/" .. setId
	print(("Extracting to: %s"):format(extractPath))
	local extracted = extract(savePath, extractPath, true)
	if not extracted then
		return
	end
	print(("Extracted to: %s"):format(extractPath))
end)

return OsudirectModel

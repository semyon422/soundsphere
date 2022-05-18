local LibraryModel = require("sphere.models.LibraryModel")
local osudirect_urls = require("sphere.osudirect.urls")
local osudirect_parse = require("sphere.osudirect.parse")
local fsextract = require("sphere.filesystem.extract")
local fsdownload = require("sphere.filesystem.download")
local fsrequest = require("sphere.filesystem.request")
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

local asyncRequest = aquathread.async(fsrequest)

OsudirectModel.searchDebounce = function(self)
	aquatimer.debounce(self, "loadDebounce", 0.1, self.search, self)
end

OsudirectModel.search = function(self)
	local searchString = self.searchString
	local config = self.configModel.configs.urls.osu
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
	local config = self.configModel.configs.urls.osu
	return socket_url.absolute(config.assets, osudirect_urls.cover(self.beatmap.setId, true))
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.configModel.configs.urls.osu
	return socket_url.absolute(config.static, osudirect_urls.preview(self.beatmap.setId))
end

local download = aquathread.async(fsdownload)
local extract = aquathread.async(fsextract)

OsudirectModel.downloadBeatmapSet = aquathread.coro(function(self)
	local beatmap = self.beatmap
	if not beatmap then
		return
	end

	local config = self.configModel.configs.urls.osu

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

local Class = require("aqua.util.Class")
local osudirect_urls = require("sphere.osudirect.urls")
local osudirect_parse = require("sphere.osudirect.parse")
local fsextract = require("sphere.filesystem.extract")
local fsdownload = require("sphere.filesystem.download")
local fsrequest = require("sphere.filesystem.request")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")
local socket_url = require("socket.url")

local OsudirectModel = Class:new()

OsudirectModel.load = function(self)
	self.items = {}
	self.processing = {}
end

OsudirectModel.isChanged = function(self)
	local changed = self.changed
	self.changed = false
	return changed
end

OsudirectModel.setBeatmap = function(self, beatmap)
	self.beatmap = beatmap
	self.changed = true
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
	local config = self.game.configModel.configs.urls.osu
	local url = socket_url.absolute(config.web, osudirect_urls.search(searchString))
	local body = asyncRequest(url)
	if not body then
		return
	end
	local beatmaps, err = osudirect_parse(body)
	if not beatmaps then
		self.items = {}
		return
	end
	self.items = beatmaps
	if searchString ~= self.searchString then
		return self:search()
	end

	self:setBeatmap(self.items[1])
end

OsudirectModel.getBackgroundUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return socket_url.absolute(config.assets, osudirect_urls.cover(self.beatmap.setId, true))
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return socket_url.absolute(config.static, osudirect_urls.preview(self.beatmap.setId))
end

local download = aquathread.async(fsdownload)
local extract = aquathread.async(fsextract)

OsudirectModel.downloadBeatmapSet = aquathread.coro(function(self)
	local beatmap = self.beatmap
	if not beatmap then
		return
	end

	table.insert(self.processing, 1, beatmap)
	print(require("inspect")(beatmap))

	local config = self.game.configModel.configs.urls.osu

	local saveDir = "userdata/charts/downloads"

	local setId = beatmap.setId
	local url = socket_url.absolute(config.storage, osudirect_urls.download(setId))
	print(("Downloading: %s"):format(url))
	beatmap.status = "Downloading"
	local downloaded, filename = download(url, saveDir)
	if not downloaded then
		beatmap.status = "Downloading error"
		return
	end

	local savePath = saveDir .. "/" .. filename
	print(("Downloaded: %s"):format(savePath))
	if not filename:find("%.osz$") then
		beatmap.status = "Unsupported file type"
		print("Unsupported file type")
		return
	end

	local extractPath = saveDir .. "/" .. filename:match("^(.+)%.osz$")
	print("Extracting")
	beatmap.status = "Extracting"
	local extracted = extract(savePath, extractPath, true)
	if not extracted then
		beatmap.status = "Extracting error"
		return
	end
	print(("Extracted to: %s"):format(extractPath))

	beatmap.status = "Extracted"
	for i, v in ipairs(self.processing) do
		if v == beatmap then
			table.remove(self.processing, i)
			break
		end
	end
end)

return OsudirectModel

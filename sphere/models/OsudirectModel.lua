local Class = require("Class")
local osudirect = require("libchart.osudirect")
local extractAsync = require("sphere.filesystem.extract")
local downloadAsync = require("sphere.filesystem.download")
local aquathread = require("thread")
local aquadelay = require("delay")
local socket_url = require("socket.url")

local OsudirectModel = Class:new()

OsudirectModel.load = function(self)
	self.statusBeatmap = {title = "LOADING", artist = ""}
	self.items = {self.statusBeatmap}
	self.processing = {}
	self.page = 1
end

OsudirectModel.update = function(self)
	local dl = aquathread.shared.download
	for _, b in ipairs(self.processing) do
		local status = dl[b.url]
		if status then
			if b.isDownloading then
				local status = dl[b.url]
				b.status = ("%0.1fmbps - %3.2f%%"):format(
					status.speed * 1e-6,
					(status.total / status.size) * 100
				)
			else
				dl[b.url] = nil
			end
		end
	end
end

OsudirectModel.isChanged = function(self)
	local changed = self.changed
	self.changed = false
	return changed
end

OsudirectModel.setBeatmap = function(self, beatmap)
	self.beatmap = beatmap
	self.changed = true

	local statusBeatmap = self.statusBeatmap
	if beatmap ~= statusBeatmap or self.items[1] == beatmap or statusBeatmap.title == "LOADING" then
		return
	end
	statusBeatmap.title = "LOADING"
	coroutine.wrap(function()
		self:searchNext()
	end)()
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

local requestAsync = aquathread.async(function(url)
	local https = require("ssl.https")
	return https.request(url)
end)

OsudirectModel.searchDebounce = function(self)
	aquadelay.debounce(self, "loadDebounce", 0.1, self.search, self)
end

OsudirectModel.searchNoDebounce = function(self)
	coroutine.wrap(function()
		self:search()
	end)()
end

OsudirectModel.search = function(self)
	self.statusBeatmap.title = "LOADING"
	self.items = {self.statusBeatmap}
	self.page = 0

	local searchString = self.searchString
	self:searchNext()
	if searchString ~= self.searchString then
		return self:search()
	end
end

OsudirectModel.searchRequest = function(self, searchString, page)
	local config = self.game.configModel.configs.urls.osu
	local url = socket_url.absolute(config.web, osudirect.search(searchString, nil, page - 1))
	print("GET " .. url)
	local body = requestAsync(url)
	if not body then
		return
	end
	return osudirect.parse(body)
end

OsudirectModel.searchNext = function(self)
	self.page = self.page + 1

	local searchString = self.searchString
	local beatmaps = self:searchRequest(searchString, self.page)
	if not beatmaps then
		self.statusBeatmap.title = "UNAVAILABLE"
		return
	end
	if #beatmaps == 0 then
		self.statusBeatmap.title = "NO RESULTS"
		return
	end

	local newPos = #self.items
	table.remove(self.items, newPos)
	for _, beatmap in ipairs(beatmaps) do
		table.insert(self.items, beatmap)
	end

	self.statusBeatmap.title = "LOAD MORE"
	table.insert(self.items, self.statusBeatmap)

	self:setBeatmap(self.items[newPos])
end

OsudirectModel.getBackgroundUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return socket_url.absolute(config.assets, osudirect.cover(self.beatmap.setId, true))
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return socket_url.absolute(config.static, osudirect.preview(self.beatmap.setId))
end

OsudirectModel.downloadBeatmapSet = aquathread.coro(function(self, beatmap, callback)
	if not beatmap or beatmap == self.statusBeatmap then
		return
	end

	table.insert(self.processing, 1, beatmap)

	local config = self.game.configModel.configs.urls.osu

	local saveDir = "userdata/charts/downloads"

	local setId = beatmap.setId
	local url = socket_url.absolute(config.storage, osudirect.download(setId))
	beatmap.url = url

	print(("Downloading: %s"):format(url))
	beatmap.status = "Downloading"

	beatmap.isDownloading = true
	local filename, err = downloadAsync(url, saveDir)
	beatmap.isDownloading = false

	if not filename then
		beatmap.status = err
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
	local extracted = extractAsync(savePath, extractPath, true)
	if not extracted then
		beatmap.status = "Extracting error"
		return
	end
	print(("Extracted to: %s"):format(extractPath))

	beatmap.status = "Cacheing"

	local c = coroutine.running()
	self.game.cacheModel:startUpdate(extractPath, true, function()
		coroutine.resume(c)
	end)
	coroutine.yield()

	for i, v in ipairs(self.processing) do
		if v == beatmap then
			table.remove(self.processing, i)
			break
		end
	end

	if callback then
		callback()
	end
end)

return OsudirectModel
